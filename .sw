# SWMessenger — журнал проекта

Дата старта: 2026-05-08
Репозиторий: https://github.com/viktor138irk/WSMessenger
Проект: собственный мессенджер Android/Web на базе Matrix-сервера.

## Главное правило проекта

Не ломать существующие проекты на сервере, особенно ArtistFlow.

ArtistFlow должен оставаться нетронутым:
- не менять vhost/config домена artistflow.ru;
- не перезаписывать общий nginx.conf FastPanel;
- не ставить новый Nginx поверх FastPanel;
- не трогать MySQL/БД ArtistFlow;
- не занимать порты FastPanel и текущих сайтов;
- перед изменениями nginx/FastPanel делать backup конфигов.

## Принятая архитектура

SWMessenger разворачивается отдельно от FastPanel-сайтов и ArtistFlow.

Базовая схема:
- FastPanel/Nginx — только reverse proxy и SSL-витрина;
- Matrix Synapse — отдельный сервис на 127.0.0.1:8008;
- PostgreSQL — отдельная база для Matrix/SWMessenger;
- backend/админка SWMessenger — отдельный локальный сервис;
- web/widget/client — можно выкладывать в вручную указанный webroot;
- Android-приложение — отдельный клиент Matrix, позже брендированный под SWMessenger/StackWorks.

## Предварительные домены

Домены можно менять в установщике, но рекомендуемая схема такая:

- messenger.stackworks.ru или chat.stackworks.ru — web-клиент/панель;
- matrix.stackworks.ru — Matrix API reverse proxy на Synapse;
- widget.stackworks.ru — webroot или proxy для встраиваемого виджета;
- admin-messenger.stackworks.ru — админ-панель;
- turn.stackworks.ru — TURN/STUN для звонков, если потребуется.

## Предварительные директории

Рекомендуемая структура на сервере:

- /opt/swmessenger/source — исходники GitHub;
- /opt/swmessenger/app — backend/админка;
- /opt/swmessenger/matrix — Matrix/Synapse;
- /opt/swmessenger/widget — виджет;
- /opt/swmessenger/element — web-клиент, если используем Element/Web;
- /opt/swmessenger/backups — резервные копии;
- /var/www/swmessenger/public — webroot для статики/виджета/фронта.

## Принцип установки рядом с FastPanel

Можно вручную указать webroot, как в проекте с виджетом.

Файлы фронта/виджета можно тянуть в webroot:

```bash
cd /opt/swmessenger/source
rsync -a --delete public/ /var/www/swmessenger/public/
```

Сервисы не кладём в webroot:
- Synapse работает сервисом и слушает 127.0.0.1:8008;
- backend работает сервисом и слушает локальный порт;
- PostgreSQL работает локально;
- наружу выпускаем только через FastPanel/Nginx proxy.

## FastPanel proxy-логика

Пример:

- matrix.example.ru -> proxy_pass http://127.0.0.1:8008;
- chat.example.ru -> proxy_pass http://127.0.0.1:3000;
- admin.example.ru -> proxy_pass http://127.0.0.1:3100;
- widget.example.ru -> webroot /var/www/swmessenger/public/widget или proxy.

## Что понадобится

Сервер:
- Ubuntu;
- FastPanel уже может быть установлен;
- Docker Compose или systemd-сервисы;
- PostgreSQL;
- Matrix Synapse;
- coturn для звонков;
- Nginx/FastPanel reverse proxy;
- SSL Let’s Encrypt.

Клиенты:
- Android-клиент на базе Matrix SDK / форка Element;
- web-клиент, желательно сначала Element Web или собственный легкий клиент;
- встраиваемый widget для сайтов.

## MVP проекта

Первая рабочая цель:
1. Подготовить базовый репозиторий.
2. Добавить installer/config wizard.
3. Поднять Matrix Synapse локально.
4. Добавить FastPanel proxy-инструкции.
5. Добавить webroot deploy для виджета/фронта.
6. Добавить healthcheck.
7. Добавить backup перед изменениями.
8. Подготовить Android-план.

Минимальные функции:
- регистрация/вход;
- личные сообщения;
- групповые комнаты;
- отправка файлов/изображений;
- виджет сайта;
- операторы/админы;
- безопасная установка рядом с FastPanel;
- журнал состояния проекта в этом файле .sw.

## Правила ведения проекта

1. Каждый заметный шаг записывать в этот файл .sw.
2. Новые версии фиксировать в VERSION и changelog, когда появятся файлы проекта.
3. Не плодить мусорные директории.
4. Все сервисы SWMessenger держать отдельно от ArtistFlow.
5. Не вносить изменения в существующие домены без явной команды.
6. Для FastPanel давать точные proxy-конфиги, но не затирать чужие.
7. Перед потенциально опасными действиями добавлять backup-скрипт.

## Текущий статус

2026-05-08:
- Репозиторий viktor138irk/WSMessenger подключён.
- Репозиторий был пустой.
- Создан первый файл .sw с архитектурой, правилами безопасности и планом MVP.

## Следующий шаг

Создать базовую структуру проекта:
- README.md;
- VERSION;
- docs/FASTPANEL_PROXY.md;
- docs/ARCHITECTURE.md;
- scripts/install.sh;
- scripts/healthcheck.sh;
- docker-compose.yml для Synapse/PostgreSQL/coturn;
- public/widget/ минимальная заготовка виджета;
- .gitignore.
