# WSMessenger Architecture

## Цель

WSMessenger — self-hosted Android/Web мессенджер на базе Matrix.

Проект должен:
- безопасно работать рядом с FastPanel;
- не ломать ArtistFlow;
- не вмешиваться в widget.stackworks.ru;
- масштабироваться;
- поддерживать Android/Web клиентов.

## Основные компоненты

### 1. Matrix Synapse

Назначение:
- транспорт сообщений;
- комнаты;
- события;
- federation (в будущем);
- media storage.

Работает:
- локально;
- только через reverse proxy.

Порт:
- 127.0.0.1:8008

### 2. PostgreSQL

Отдельная база данных для Matrix/SWMessenger.

Изоляция обязательна.

Запрещено использовать базы ArtistFlow.

### 3. Web Client

План:
- отдельный web-клиент;
- возможно Element Web на старте;
- позже собственный UI.

Домен:
- chat.stackworks.ru
- или messenger.stackworks.ru

### 4. Android Client

Основа:
- Matrix SDK;
- форк Element или собственный клиент позже.

План:
- собственный branding;
- push;
- комнаты;
- медиа;
- голосовые функции позже.

### 5. Admin Panel

Назначение:
- управление пользователями;
- мониторинг;
- healthcheck;
- настройки.

Домен:
- admin-messenger.stackworks.ru

### 6. TURN/STUN

coturn.

Понадобится позже для звонков.

## Изоляция от production

WSMessenger должен быть полностью изолирован от:
- ArtistFlow;
- widget.stackworks.ru;
- production-сайтов FastPanel.

## FastPanel

FastPanel используется только как:
- reverse proxy;
- SSL management;
- DNS/vhost gateway.

WSMessenger не должен:
- менять FastPanel автоматически;
- менять nginx configs самостоятельно;
- перезапускать production nginx.

## Директории

```text
/opt/swmessenger/source
/opt/swmessenger/app
/opt/swmessenger/matrix
/opt/swmessenger/backups
```

## Docker

Используем Docker Compose.

Преимущества:
- изоляция;
- простое обновление;
- rollback;
- переносимость.

## MVP v0.x

Первая цель:
- поднять Synapse;
- подключить PostgreSQL;
- открыть web-client;
- проверить регистрацию;
- не сломать production.
