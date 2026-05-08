# FastPanel Proxy Rules

## Главное правило

WSMessenger не должен автоматически менять FastPanel.

Любые изменения:
- вручную;
- или только после отдельной явной команды пользователя.

## Safe Proxy Architecture

```text
Internet
   ↓
FastPanel/Nginx
   ↓
Reverse Proxy
   ↓
WSMessenger Services
```

## Matrix Proxy

Пример:

```nginx
location / {
    proxy_pass http://127.0.0.1:8008;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

## Web Client Proxy

```nginx
location / {
    proxy_pass http://127.0.0.1:3000;
}
```

## Admin Panel Proxy

```nginx
location / {
    proxy_pass http://127.0.0.1:3100;
}
```

## Запрещено

- перезаписывать nginx.conf;
- менять production vhost;
- трогать ArtistFlow configs;
- трогать widget.stackworks.ru configs;
- перезапускать FastPanel без команды.

## Перед изменениями

Всегда делать backup:

```bash
cp -r /etc/nginx /opt/swmessenger/backups/nginx_$(date +%F_%H-%M-%S)
```
