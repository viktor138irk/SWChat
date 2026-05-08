# SWChat — приватная сеть между FastPanel proxy и Core

Если FastPanel proxy сервер и SWChat Core можно объединить в приватную локальную сеть, это предпочтительная схема.

## Почему это лучше

Преимущества:
- Matrix Core не светит порт `8008` в публичный интернет;
- FastPanel ходит к Synapse по внутреннему IP;
- меньше зависимость от публичного firewall;
- проще ограничить доступ;
- безопаснее для production;
- ниже риск случайного сканирования Matrix endpoint.

## Рекомендуемая схема

```text
Пользователь
  ↓ HTTPS
matrix.stackworks.ru
  ↓
FastPanel/Nginx reverse proxy
  ↓ private network
CORE_PRIVATE_IP:8008
  ↓
SWChat Core / Synapse
```

## DNS

Публичные DNS-записи остаются на FastPanel proxy сервер:

```text
matrix.stackworks.ru    A    FASTPANEL_PUBLIC_IP
chat.stackworks.ru      A    FASTPANEL_PUBLIC_IP
```

Core-сервер не обязан иметь публичный домен для Matrix API.

## Core-сервер

На Core-сервере нужно узнать приватный IP:

```bash
ip -4 addr
ip route
```

Пример приватного IP:

```text
10.10.0.12
```

## FastPanel-сервер

С FastPanel-сервера проверить доступ до Core по приватному IP:

```bash
ping CORE_PRIVATE_IP
curl http://CORE_PRIVATE_IP:8008/_matrix/client/versions
```

Ожидается JSON Matrix API.

## Nginx proxy для FastPanel

Для `matrix.stackworks.ru` использовать приватный IP Core-сервера:

```nginx
location / {
    proxy_pass http://CORE_PRIVATE_IP:8008;

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

## Firewall на Core

Разрешить порт 8008 только с приватного IP FastPanel-сервера.

```bash
ufw allow from FASTPANEL_PRIVATE_IP to any port 8008 proto tcp
ufw deny 8008/tcp
ufw status numbered
```

Если сервис слушает `127.0.0.1:8008`, FastPanel не сможет подключиться по приватной сети. В этом случае нужно пробросить Synapse на приватный IP или на `0.0.0.0:8008`, но закрыть firewall для всех кроме FastPanel private IP.

## Важное замечание про docker-compose

Текущий compose публикует Synapse так:

```yaml
ports:
  - '127.0.0.1:8008:8008'
```

Для приватной сети потребуется изменить на один из вариантов:

```yaml
ports:
  - 'CORE_PRIVATE_IP:8008:8008'
```

или:

```yaml
ports:
  - '8008:8008'
```

Второй вариант допустим только при строгом firewall.

## Выбранная рекомендация

Предпочтительно:

```yaml
ports:
  - 'CORE_PRIVATE_IP:8008:8008'
```

Так Synapse будет доступен только по приватному интерфейсу.

## Проверка

С FastPanel proxy сервера:

```bash
curl http://CORE_PRIVATE_IP:8008/_matrix/client/versions
```

С внешнего интернета прямой доступ к Core:8008 должен быть закрыт.

Публичная проверка:

```bash
curl https://matrix.stackworks.ru/_matrix/client/versions
```

Ожидается JSON Matrix API.
