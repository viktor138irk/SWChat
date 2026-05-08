# SWChat — пошаговое подключение FastPanel reverse proxy → Core

## Переменные

Заменить значения перед выполнением:

```text
FASTPANEL_PROXY_IP = IP сервера с FastPanel, где будут домены и SSL
CORE_SERVER_IP     = IP Core-сервера, где работает SWChat/Synapse
MATRIX_DOMAIN      = matrix.stackworks.ru
CHAT_DOMAIN        = chat.stackworks.ru или messenger.stackworks.ru
```

## 1. DNS

В панели DNS домена `stackworks.ru` создать A-записи:

```text
matrix.stackworks.ru    A    FASTPANEL_PROXY_IP
chat.stackworks.ru      A    FASTPANEL_PROXY_IP
```

Если используется `messenger.stackworks.ru`, добавить:

```text
messenger.stackworks.ru A    FASTPANEL_PROXY_IP
```

Проверка с любого компьютера:

```bash
nslookup matrix.stackworks.ru
nslookup chat.stackworks.ru
```

Ожидается IP FastPanel proxy сервера.

## 2. Core-сервер

На Core-сервере проверить, что Synapse работает локально:

```bash
cd /opt/swchat/source
docker ps
curl http://127.0.0.1:8008/_matrix/client/versions
```

Ожидается JSON Matrix API.

Проверить, открыт ли порт 8008:

```bash
ss -tulpn | grep 8008
```

## 3. Разрешить FastPanel доступ к Core:8008

На Core-сервере разрешить доступ к Synapse только с FastPanel proxy сервера.

Если используется UFW:

```bash
ufw allow from FASTPANEL_PROXY_IP to any port 8008 proto tcp
ufw deny 8008/tcp
ufw status numbered
```

Важно: сначала `allow`, потом `deny`.

Проверка с FastPanel-сервера:

```bash
curl http://CORE_SERVER_IP:8008/_matrix/client/versions
```

Ожидается JSON Matrix API.

## 4. FastPanel: создать сайт matrix.stackworks.ru

В FastPanel:

1. Сайты → Создать сайт.
2. Домен: `matrix.stackworks.ru`.
3. PHP можно не использовать.
4. Включить SSL/Let's Encrypt для домена.
5. Проверить, что сайт открывается по HTTPS.

## 5. FastPanel/Nginx proxy для matrix.stackworks.ru

В настройках сайта `matrix.stackworks.ru` добавить Nginx proxy-конфигурацию.

`CORE_SERVER_IP` заменить на IP Core-сервера.

```nginx
location / {
    proxy_pass http://CORE_SERVER_IP:8008;

    proxy_http_version 1.1;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto https;

    client_max_body_size 100M;
    proxy_read_timeout 600s;
    proxy_send_timeout 600s;
}
```

После сохранения перезагрузить конфигурацию сайта через FastPanel.

## 6. Проверка Matrix через публичный домен

С локального компьютера или любого сервера:

```bash
curl -I https://matrix.stackworks.ru/_matrix/client/versions
curl https://matrix.stackworks.ru/_matrix/client/versions
```

Ожидается:

```text
HTTP/2 200
```

И JSON Matrix API.

## 7. Создание первого пользователя Matrix

На Core-сервере:

```bash
docker exec -it swchat-synapse register_new_matrix_user \
  -c /data/homeserver.yaml \
  http://localhost:8008
```

Далее ввести:
- username;
- password;
- admin: yes/no.

Для первого пользователя рекомендуется `admin: yes`.

## 8. Проверка входа через Element

Открыть Element Web/Desktop/Android.

Homeserver:

```text
https://matrix.stackworks.ru
```

Войти созданным пользователем.

Проверить:
- логин;
- создание комнаты;
- отправку сообщения;
- отправку изображения/файла.

## 9. Web-клиент SWChat

После успешной проверки Matrix через Element можно создавать сайт:

```text
chat.stackworks.ru
```

На FastPanel-сервере он будет использоваться для будущего web-клиента SWChat.

До успешного Matrix-теста собственный web/android клиент не начинать.

## 10. Что не делать

Не размещать на FastPanel:
- PostgreSQL Matrix;
- Synapse DB;
- media storage Matrix;
- backups Matrix;
- TURN/STUN.

Не трогать:
- artistflow.ru;
- widget.stackworks.ru;
- production FastPanel, если это не отдельный proxy-сервер SWChat.
