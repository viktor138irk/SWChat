# SWChat: FastPanel reverse proxy → Core

Эта схема выбрана для публичного доступа к SWChat.

## Роль серверов

### Core-сервер

На Core-сервере работают:
- Matrix Synapse;
- PostgreSQL;
- media storage;
- backups;
- будущий TURN/STUN.

Core-сервер не обязан принимать публичные HTTPS-домены напрямую.

### FastPanel-сервер

Отдельный FastPanel-сервер принимает публичные домены и SSL:
- `matrix.stackworks.ru` — proxy до Synapse на Core-сервере;
- `chat.stackworks.ru` или `messenger.stackworks.ru` — web-клиент SWChat;
- `api-chat.stackworks.ru` — будущий backend API, если понадобится.

Текущий production FastPanel с ArtistFlow/widget.stackworks.ru не трогать.

## DNS

A-записи доменов SWChat должны указывать на IP FastPanel-сервера, который будет reverse proxy:

```text
matrix.stackworks.ru      A      FASTPANEL_PROXY_IP
chat.stackworks.ru        A      FASTPANEL_PROXY_IP
messenger.stackworks.ru   A      FASTPANEL_PROXY_IP
api-chat.stackworks.ru    A      FASTPANEL_PROXY_IP
```

## Core-сервер

Synapse должен быть доступен с FastPanel-сервера по адресу:

```text
http://CORE_SERVER_IP:8008
```

Если порт `8008` закрыт firewall, нужно разрешить доступ только с IP FastPanel-сервера.

Пример UFW на Core-сервере:

```bash
ufw allow from FASTPANEL_PROXY_IP to any port 8008 proto tcp
ufw deny 8008/tcp
```

Важно: сначала разрешить FastPanel IP, потом закрывать общий доступ.

## Nginx proxy-шаблон для matrix.stackworks.ru

Этот шаблон добавляется только в отдельном FastPanel-сервере для домена `matrix.stackworks.ru`.

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

## Проверка с FastPanel-сервера

```bash
curl -I http://CORE_SERVER_IP:8008/_matrix/client/versions
curl http://CORE_SERVER_IP:8008/_matrix/client/versions
```

Ожидается HTTP 200 и JSON Matrix API.

## Проверка публичного домена

После DNS и SSL:

```bash
curl -I https://matrix.stackworks.ru/_matrix/client/versions
curl https://matrix.stackworks.ru/_matrix/client/versions
```

Ожидается HTTP 200 и JSON Matrix API.

## Важное ограничение

Для стабильной работы Matrix server name должен совпадать с публичным именем в конфиге Synapse:

```text
SERVER_NAME=matrix.stackworks.ru
public_baseurl: https://matrix.stackworks.ru/
```

Если имя сервера будет изменено после создания пользователей, могут появиться проблемы с федерацией и ID пользователей.

## Следующий шаг

1. Настроить DNS `matrix.stackworks.ru` на FastPanel proxy server.
2. Выпустить SSL на FastPanel для `matrix.stackworks.ru`.
3. Добавить proxy до `http://CORE_SERVER_IP:8008`.
4. Ограничить доступ к Core:8008 только IP FastPanel-сервера.
5. Проверить Matrix API через публичный HTTPS.
6. Создать первого Matrix-пользователя.
7. Проверить вход через Element.
