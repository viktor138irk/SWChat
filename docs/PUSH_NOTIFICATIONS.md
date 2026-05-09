# Pulse Push Notifications

Дата: 2026-05-09
Репозиторий: viktor138irk/SWChat
Связанный клиент: viktor138irk/SWChat-App

## Цель

Добавить уведомления Pulse так, чтобы пользователь получал push на Android при новых сообщениях, но сервер Matrix/Synapse не зависел напрямую от клиентского UI.

## Важное решение

Уведомления делаем через отдельный серверный Push Gateway.

Схема:

```text
Synapse / Matrix
    ↓ Matrix push rules / pusher
Pulse Push Gateway
    ↓ FCM / Android push
Pulse Android App
```

Push Gateway должен жить в серверном репозитории `SWChat`, а клиентские настройки и регистрация pusher — в `SWChat-App`.

## Почему нужен Push Gateway

Matrix-клиент не получает push напрямую из Synapse в Firebase. Synapse отправляет push на gateway, а gateway уже отправляет уведомление в Firebase Cloud Messaging.

Это позволяет:
- не хранить Firebase-логику в Synapse;
- централизованно управлять push;
- позже добавить web push, desktop push, Telegram/dev alerts;
- контролировать payload и приватность;
- отключать/включать уведомления пользователям.

## MVP Push Gateway

Минимальные функции:

1. Endpoint приёма push от Synapse:

```text
POST /_matrix/push/v1/notify
```

2. Проверка входящего payload.
3. Извлечение event/user/room/pusher данных.
4. Отправка уведомления в FCM.
5. Логи отправки.
6. Healthcheck endpoint:

```text
GET /health
```

7. Конфигурация через `.env`.
8. Отдельный контейнер в `docker-compose.yml`.

## Предварительные домены

Рекомендуемый домен:

```text
push.stackworks.ru
```

Альтернатива внутри API:

```text
api-chat.stackworks.ru/push
```

На MVP лучше отдельный поддомен `push.stackworks.ru`, чтобы не мешать будущему backend API.

## Требования к Android-клиенту

В `SWChat-App` нужно:

- проверить наличие `google-services.json` под package `ru.stackworks.pulse`;
- проверить Firebase project;
- включить FCM token registration;
- убедиться, что `pushNotificationsAppId = ru.stackworks.pulse`;
- настроить pusher URL на Pulse Push Gateway;
- проверить уведомления на debug APK;
- проверить уведомления на release APK.

## Безопасность

Push Gateway не должен раскрывать текст сообщений без необходимости.

На MVP можно отправлять:

```text
Новое сообщение
```

или:

```text
Новое сообщение в Pulse
```

Без тела сообщения, пока не будет понятна политика приватности и E2EE.

## Следующий шаг

1. Проверить Android/Firebase config.
2. Создать каркас `push-gateway` в серверном репозитории.
3. Добавить сервис в `docker-compose.yml`.
4. Добавить `.env.example` переменные.
5. Настроить Synapse pusher/client pusher registration.
6. Проверить push на тестовом аккаунте.
