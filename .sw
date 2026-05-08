# SWChat — журнал проекта

Дата старта: 2026-05-08
Репозиторий: https://github.com/viktor138irk/SWChat
Рабочее имя продукта: SWChat
Проект: собственный мессенджер Android/Web на базе Matrix-сервера.

## Главное правило проекта

Не ломать существующие проекты на сервере.

Защищённые production-активы:
- ArtistFlow / artistflow.ru;
- основной виджет StackWorks / https://widget.stackworks.ru/;
- текущие сайты и домены FastPanel.

## Клиентские репозитории

Клиентское приложение вынесено отдельно от Core:
- Core/backend/docs: https://github.com/viktor138irk/SWChat
- App/client: https://github.com/viktor138irk/SWChat-App

SWChat-App создан как отдельный репозиторий для Flutter/FluffyChat клиента.
FluffyChat импортирован в SWChat-App.
Найден pubspec.yaml upstream FluffyChat: name fluffychat, version 2.6.0+3553, Flutter/Dart SDK >=3.11.1 <4.0.0.

## Текущая архитектура установки

Принято решение ставить SWChat Core на отдельный новый сервер.

Разделение:
- новый сервер: Matrix Synapse, PostgreSQL, TURN/STUN, backend, media storage, backups;
- FastPanel-сервер: домены, frontend/web-client, публичная витрина и reverse proxy, без размещения PostgreSQL/TURN и без вмешательства в чужие production-проекты.

## Стратегия тестирования

Сначала SWChat Core тестируется через официальные Matrix-клиенты.
Свой клиент не писать, пока не подтверждено, что серверная часть работает стабильно через официальные клиенты.

## Жёсткое правило про FastPanel

Самостоятельно не трогать всё, что касается FastPanel.

Запрещено без отдельной явной команды пользователя:
- менять настройки FastPanel;
- менять vhost/config доменов FastPanel;
- применять proxy-настройки в FastPanel;
- перезаписывать nginx-конфиги, которыми управляет FastPanel;
- перезапускать/переустанавливать FastPanel;
- ставить новый Nginx поверх FastPanel;
- менять SSL-сертификаты через FastPanel;
- менять webroot существующих сайтов;
- трогать production-домены.

Разрешено:
- готовить инструкции;
- готовить шаблоны proxy-конфигов;
- готовить безопасные команды проверки;
- готовить backup-скрипты;
- описывать, что пользователь может сделать вручную в FastPanel.

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

## Защищённые проекты

widget.stackworks.ru — отдельный действующий production-проект StackWorks.
ArtistFlow должен оставаться нетронутым.

Запрещено без отдельной явной команды:
- менять vhost/config домена widget.stackworks.ru;
- менять webroot виджета;
- затирать файлы виджета;
- менять SSL и настройки домена;
- интегрировать виджет с Matrix;
- создавать новый параллельный виджет для SWChat;
- менять vhost/config домена artistflow.ru;
- трогать MySQL/БД ArtistFlow.

## Принятая архитектура SWChat

SWChat Core разворачивается на отдельном сервере.

Базовая схема:
- Matrix Synapse — отдельный сервис на приватном IP:8008;
- PostgreSQL — отдельная база для Matrix/SWChat;
- backend/админка SWChat — отдельный локальный сервис;
- web-client — на FastPanel-сервере в будущем;
- Android-приложение — отдельный клиент Matrix, позже брендированный под SWChat/StackWorks;
- FastPanel/Nginx reverse proxy — основной публичный HTTPS слой для SWChat.

## Основная публичная схема

Выбрана архитектура:
FastPanel reverse proxy → SWChat Core.

Поток трафика:
- пользователь → FastPanel/Nginx;
- FastPanel SSL/proxy → Core-сервер Matrix Synapse;
- Synapse работает на Core через приватную сеть между серверами.

## UX-решение собственного клиента

В собственном приложении SWChat комнатная структура Matrix должна быть скрыта от пользователя.

Пользовательский интерфейс должен выглядеть как привычный Telegram-like мессенджер:
- список чатов;
- личные диалоги;
- групповые чаты;
- контакты;
- поиск людей;
- кнопка «Написать»;
- привычные аватарки, статусы, индикаторы прочтения и вложения;
- быстрый сайдбар/нижняя навигация;
- закреплённые чаты;
- архив;
- поиск по сообщениям;
- медиа/файлы внутри профиля чата.

Правило UX:
- основной ориентир интерфейса — Telegram;
- не использовать слово «комната» в пользовательском интерфейсе SWChat;
- использовать «чат», «диалог», «группа», «канал»;
- Matrix room показывать как обычный чат;
- создание direct room автоматизировать при первом сообщении контакту;
- групповой room показывать как групповую беседу;
- технические Matrix-настройки прятать в расширенные/админские разделы.

## Приватная сеть между серверами

FastPanel proxy сервер и SWChat Core объединены в локальную сеть.

Текущие private IP:
- FastPanel proxy: 192.168.0.221;
- SWChat Matrix/Core: 192.168.0.141.

Рекомендованная схема:
- FastPanel proxy имеет public IP;
- Core-сервер использует private IP 192.168.0.141;
- proxy_pass идёт на http://192.168.0.141:8008;
- прямой доступ к Core:8008 из интернета закрыт;
- доступ к Core:8008 разрешён только с 192.168.0.221.

## DNS и wildcard-поддомены

Если домен stackworks.ru и все его поддомены уже направлены wildcard-записью на FastPanel-сервер, отдельную DNS A-запись для matrix.stackworks.ru можно не создавать.

Достаточно:
- убедиться, что *.stackworks.ru указывает на публичный IP FastPanel;
- создать отдельный сайт matrix.stackworks.ru внутри FastPanel;
- выпустить SSL для matrix.stackworks.ru;
- настроить для этого сайта reverse proxy на http://192.168.0.141:8008.

## Домены проекта

Рекомендуемая безопасная схема:
- matrix.stackworks.ru — Matrix API / Synapse через FastPanel reverse proxy;
- turn.stackworks.ru — TURN/STUN, новый SWChat Core сервер;
- api-chat.stackworks.ru — backend API, новый SWChat Core сервер, если понадобится;
- chat.stackworks.ru или messenger.stackworks.ru — web-клиент на FastPanel-сервере;
- widget.stackworks.ru — отдельный production-виджет StackWorks, не часть Matrix/SWChat на текущем этапе.

## Предварительные директории Core-сервера

- /opt/swchat/source — исходники GitHub;
- /opt/swchat/app — backend/админка;
- /opt/swchat/matrix — Matrix/Synapse;
- /opt/swchat/data — данные контейнеров;
- /opt/swchat/backups — резервные копии;
- /opt/swchat/logs — логи.

## MVP проекта

Минимальные функции:
- регистрация/вход;
- личные сообщения;
- групповые чаты;
- отправка файлов/изображений;
- операторы/админы;
- Telegram-like интерфейс без показа Matrix-комнат;
- безопасная установка рядом с production, но на отдельном сервере;
- журнал состояния проекта в этом файле .sw.

## Правила ведения проекта

1. Каждый заметный шаг записывать в этот файл .sw.
2. Новые версии фиксировать в VERSION и changelog.
3. Не плодить мусорные директории.
4. Все сервисы SWChat держать отдельно от ArtistFlow и widget.stackworks.ru.
5. Не вносить изменения в существующие домены без явной команды.
6. Для FastPanel давать точные proxy-конфиги, но не затирать чужие.
7. Перед потенциально опасными действиями добавлять backup-скрипт.
8. Любые действия с widget.stackworks.ru только после отдельной явной команды.
9. Ведение .sw обязательно на протяжении всего проекта.
10. Всё, что касается текущего production FastPanel, не трогать самостоятельно: только инструкции/шаблоны до отдельной команды пользователя.
11. Собственный клиент SWChat начинать только после успешного тестирования Core через официальные Matrix-клиенты.
12. В собственном клиенте SWChat скрывать Matrix-комнаты и показывать пользователю обычные чаты/диалоги/группы.
13. Основной визуальный и UX-ориентир будущего клиента — Telegram.

## Текущий статус

2026-05-08:
- Репозиторий переименован в viktor138irk/SWChat.
- Создан файл .sw.
- Созданы VERSION, README.md и базовый docker-compose.yml.
- Созданы docs/ARCHITECTURE.md и docs/FASTPANEL_PROXY.md.
- Созданы scripts/healthcheck.sh и scripts/install.sh.
- Подготовлен автоустановщик.
- Зафиксировано пользовательское имя продукта: SWChat.
- Принято решение ставить SWChat Core на отдельный сервер.
- Старый FastPanel-сервер использовать только для frontend/web-client в будущем.
- Принято решение сначала тестировать SWChat Core официальными Matrix-клиентами, затем писать собственный клиент.
- Исправлен docker-compose.yml: контейнеры переименованы в swchat-*, убран obsolete version, добавлены переменные .env.
- Исправлена PostgreSQL locale для Synapse: добавлены POSTGRES_INITDB_ARGS с locale C.
- Исправлена проблема compose down без env: POSTGRES_PASSWORD получил безопасный fallback.
- SWChat Core успешно поднялся на новом сервере: swchat-synapse healthy, swchat-postgres up.
- Локальный Matrix endpoint успешно отвечает: curl http://127.0.0.1:8008/_matrix/client/versions вернул HTTP 200 OK и JSON версий Matrix API.

2026-05-09:
- Версия проекта повышена до 0.1.1.
- В docker-compose.yml добавлен отдельный контейнер swchat-caddy.
- Создан deploy/caddy/Caddyfile.
- Обновлён scripts/healthcheck.sh.
- Принято финальное решение использовать схему FastPanel reverse proxy → SWChat Core.
- Создан docs/FASTPANEL_REVERSE_PROXY.md.
- Создан docs/PRIVATE_NETWORK_BETWEEN_SERVERS.md.
- Уточнены реальные private IP: FastPanel proxy 192.168.0.221, Matrix/Core 192.168.0.141.
- Проверено с FastPanel proxy: curl http://192.168.0.141:8008/_matrix/client/versions успешно вернул JSON Matrix API.
- Проверено: https://matrix.stackworks.ru/_matrix/client/versions через FastPanel reverse proxy успешно вернул Matrix API JSON.
- Публичный HTTPS endpoint Matrix через FastPanel работает.
- Проверено: registration_shared_secret присутствует в /opt/swchat/data/synapse/homeserver.yaml.
- Зафиксировано: bootstrap-регистрация администратора через register_new_matrix_user разрешена.
- При входе в Element пойман M_LIMIT_EXCEEDED после нескольких попыток авторизации.
- Принято UX-решение: SWChat делать максимально в стиле Telegram.
- Репозиторий клиентского приложения подтверждён: https://github.com/viktor138irk/SWChat-App.
- FluffyChat импортирован в SWChat-App.
- Проверен pubspec.yaml FluffyChat в SWChat-App.

## Текущий этап установки

SWChat Core локально работает на новом отдельном сервере.

Публичный HTTPS endpoint через FastPanel reverse proxy работает:
- https://matrix.stackworks.ru/_matrix/client/versions возвращает Matrix API JSON.

Клиентский репозиторий SWChat-App содержит импортированный FluffyChat и готов к первичной сборке.

## Следующий шаг

Следующий этап:
- собрать SWChat-App локально: flutter pub get, flutter run или flutter build apk;
- затем начать ребрендинг: название SWChat, package id, default homeserver matrix.stackworks.ru, логотипы и Telegram-like UX;
- проверить вход через Element по homeserver https://matrix.stackworks.ru;
- закрыть прямой доступ к Core:8008 из интернета и разрешить только 192.168.0.221;
- проверить создание комнаты, отправку сообщений и файлов;
- после стабильного теста начать проектирование собственного web/android клиента с Telegram-like UX обычных чатов, а не Matrix-комнат.
