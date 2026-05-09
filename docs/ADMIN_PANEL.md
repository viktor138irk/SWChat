# Pulse Admin Panel

Дата: 2026-05-09
Репозиторий: viktor138irk/SWChat
Связанный клиент: viktor138irk/SWChat-App

## Цель

Pulse Admin Panel — собственная серверная админка StackWorks поверх Matrix/Synapse.

Задача:
- не зависеть полностью от стандартной Synapse Admin UI;
- скрыть Matrix-сложность;
- получить нормальную Telegram-like админку для Pulse.

## Архитектура

```text
Pulse Admin Panel
    ↓
Pulse Backend API
    ↓
Synapse Admin API
    ↓
PostgreSQL / Matrix
```

## Рекомендуемый стек

### Backend

- PHP 8.3
- Laravel или собственный lightweight backend
- Redis позже
- PostgreSQL/MySQL для служебных данных Pulse

### Frontend

- Blade + Alpine.js
или
- Vue/Nuxt позже

На MVP лучше:

```text
PHP + Blade + Alpine.js
```

Потому что:
- быстрее;
- проще деплой;
- проще поддержка;
- меньше зависимостей.

## Домен

```text
admin-chat.stackworks.ru
```

## Авторизация

Только через отдельный Pulse Admin login.

Не использовать Matrix user login напрямую как web-session.

Нужно:
- отдельная таблица admin users;
- роли;
- audit log;
- IP logging;
- rate limits.

## Роли

### Super Admin

Полный доступ.

### Moderator

Может:
- блокировать пользователей;
- смотреть жалобы;
- модерировать комнаты.

Не может:
- менять серверные настройки;
- удалять админов.

### Support

Может:
- смотреть профили;
- помогать с аккаунтами;
- сбрасывать пароли.

## MVP функции

### Пользователи

- список пользователей;
- поиск по username/display name;
- просмотр профиля;
- блокировка;
- разблокировка;
- reset password;
- forced logout;
- просмотр устройств.

### Чаты

- список комнат;
- просмотр участников;
- просмотр статистики;
- room moderation;
- room lock.

### Жалобы

- user reports;
- media reports;
- spam detection позже.

### Система

- состояние Synapse;
- PostgreSQL status;
- Docker status;
- диск;
- RAM;
- push gateway status.

## Будущие функции

- телефонная регистрация;
- server-side key backup;
- media moderation AI;
- антиспам;
- analytics;
- графики активности;
- invite system;
- платные функции;
- verified accounts.

## Важное правило

Админка должна быть отдельным модулем.

Нельзя:
- править production Synapse руками;
- использовать raw admin endpoints без backend validation;
- хранить admin secrets в клиенте.

## Следующий шаг

1. Создать backend skeleton.
2. Добавить `/api/admin/*`.
3. Подключить Synapse Admin API.
4. Сделать login screen.
5. Сделать dashboard.
6. Сделать users table.
7. Сделать roles.
