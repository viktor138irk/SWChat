# Pulse Push Gateway

## Архитектура

```text
Synapse
    ↓
Pulse Push Gateway
    ↓
Firebase FCM
    ↓
Android Pulse
```

## Серверы

- FastPanel reverse proxy: `192.168.0.221`
- Matrix/Core: `192.168.0.141`

## Gateway

Gateway запускается на Matrix/Core сервере:

```text
192.168.0.141:8509
```

## Установка

```bash
cd /opt/swchat
mkdir -p push-gateway
cd push-gateway
```

Скопировать файлы из репозитория:

```text
push-gateway/main.py
push-gateway/requirements.txt
```

Установка зависимостей:

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## Firebase

В Firebase Console:

- Project settings
- Service accounts
- Generate new private key

Файл сохранить:

```text
/opt/swchat/push-gateway/firebase-service-account.json
```

## Запуск

```bash
cd /opt/swchat/push-gateway
source venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8509
```

## Проверка

На VPS/FastPanel:

```bash
curl http://192.168.0.141:8509/health
```

Ожидаемый ответ:

```json
{
  "status": "ok",
  "service": "pulse-push-gateway"
}
```

## nginx reverse proxy

На FastPanel/nginx:

```nginx
location /_matrix/push/v1/notify {
    proxy_pass http://192.168.0.141:8509/_matrix/push/v1/notify;
    proxy_set_header Host $host;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

## Важно

- Не открывать 8509 наружу.
- Доступ к 8509 только из локальной сети.
- SSL остаётся на FastPanel.
- Synapse использует публичный endpoint:

```text
https://matrix.stackworks.ru/_matrix/push/v1/notify
```
