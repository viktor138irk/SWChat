# SWMessenger — журнал проекта

Дата старта: 2026-05-08
Репозиторий: https://github.com/viktor138irk/WSMessenger
Проект: собственный мессенджер Android/Web на базе Matrix-сервера.

## Главное правило проекта

Не ломать существующие проекты на сервере.

Защищённые production-активы:
- ArtistFlow / artistflow.ru;
- основной виджет StackWorks / https://widget.stackworks.ru/;
- текущие сайты и домены FastPanel.

## Постоянное правило ведения .sw

Файл .sw является главным журналом проекта и ведётся постоянно.

Обязательно записывать в .sw:
- каждый значимый шаг разработки;
- архитектурные решения;
- запреты и ограничения;
- защищённые домены и сервисы;
- изменения версий;
- что было создано или изменено;
- текущий статус;
- следующий шаг;
- важные ошибки и выводы после исправлений.

В новом диалоге продолжение проекта начинается с чтения .sw.

## Важно про widget.stackworks.ru

widget.stackworks.ru — отдельный действующий production-проект StackWorks.

На текущем этапе SWMessenger НЕ связывается с widget.stackworks.ru и НЕ создаёт новый виджет.

Запрещено без отдельной явной команды:
- менять vhost/config домена widget.stackworks.ru;
- менять webroot виджета;
- затирать файлы виджета;
- менять SSL и настройки домена;
- интегрировать виджет с Matrix;
- создавать новый параллельный виджет для SWMessenger.

## Важно про ArtistFlow

ArtistFlow должен оставаться нетронутым:
- не менять vhost/config домена artistflow.ru;
- не перезаписывать общий nginx.conf FastPanel;
- не ставить новый Nginx поверх FastPanel;
- не трогать MySQL/БД ArtistFlow;
- не занимать порты FastPanel и текущих сайтов;
- перед изменениями nginx/FastPanel делать backup конфигов.

## Принятая архитектура SWMessenger

SWMessenger разворачивается отдельно от FastPanel-сайтов, ArtistFlow и widget.stackworks.ru.

Базовая схема:
- FastPanel/Nginx — reverse proxy и SSL-витрина;
- Matrix Synapse — отдельный сервис на 127.0.0.1:8008;
- PostgreSQL — отдельная база для Matrix/SWMessenger;
- backend/админка SWMessenger — отдельный локальный сервис;
- web-client — отдельный web-клиент мессенджера;
- Android-приложение — отдельный клиент Matrix, позже брендированный под SWMessenger/StackWorks.

## Домены проекта

Рекомендуемая безопасная схема:
- matrix.stackworks.ru — Matrix API / Synapse;
- chat.stackworks.ru или messenger.stackworks.ru — web-клиент;
- admin-messenger.stackworks.ru — админ-панель;
- turn.stackworks.ru — TURN/STUN для звонков, если потребуется;
- widget.stackworks.ru — отдельный production-виджет StackWorks, не часть Matrix/SWMessenger на текущем этапе.

## Предварительные директории

- /opt/swmessenger/source — исходники GitHub;
- /opt/swmessenger/app — backend/админка;
- /opt/swmessenger/matrix — Matrix/Synapse;
- /opt/swmessenger/element — web-клиент, если используем Element/Web;
- /opt/swmessenger/backups — резервные копии;
- /var/www/swmessenger/public — webroot для фронта, если нужен.

Запрещено автоматически использовать webroot widget.stackworks.ru.

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
- web-клиент, желательно сначала Element Web или собственный лёгкий клиент.

## MVP проекта

Первая рабочая цель:
1. Подготовить базовый репозиторий.
2. Добавить installer/config wizard.
3. Поднять Matrix Synapse локально.
4. Добавить FastPanel proxy-инструкции.
5. Добавить healthcheck.
6. Добавить backup перед изменениями.
7. Подготовить Android-план.

Минимальные функции:
- регистрация/вход;
- личные сообщения;
- групповые комнаты;
- отправка файлов/изображений;
- операторы/админы;
- безопасная установка рядом с FastPanel;
- журнал состояния проекта в этом файле .sw.

## Правила ведения проекта

1. Каждый заметный шаг записывать в этот файл .sw.
2. Новые версии фиксировать в VERSION и changelog.
3. Не плодить мусорные директории.
4. Все сервисы SWMessenger держать отдельно от ArtistFlow и widget.stackworks.ru.
5. Не вносить изменения в существующие домены без явной команды.
6. Для FastPanel давать точные proxy-конфиги, но не затирать чужие.
7. Перед потенциально опасными действиями добавлять backup-скрипт.
8. Любые действия с widget.stackworks.ru только после отдельной явной команды.
9. Ведение .sw обязательно на протяжении всего проекта.

## Текущий статус

2026-05-08:
- Репозиторий viktor138irk/WSMessenger подключён.
- Репозиторий был пустой.
- Создан первый файл .sw.
- Созданы VERSION, README.md и базовый docker-compose.yml.
- Зафиксировано, что widget.stackworks.ru — отдельный production-виджет StackWorks.
- Зафиксировано, что widget.stackworks.ru пока никак не связывается с Matrix/SWMessenger.
- Зафиксировано, что новый виджет SWMessenger не планируется.
- Зафиксировано постоянное правило: файл .sw ведётся всегда и обновляется после каждого значимого шага.

## Следующий шаг

Создать базовую структуру проекта:
- docs/FASTPANEL_PROXY.md;
- docs/ARCHITECTURE.md;
- scripts/install.sh;
- scripts/healthcheck.sh;
- .gitignore.
