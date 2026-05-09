# Pulse — журнал проекта

Дата старта: 2026-05-08
Репозиторий Core/backend/docs: https://github.com/viktor138irk/SWChat
Репозиторий App/client: https://github.com/viktor138irk/SWChat-App
Рабочее имя продукта: Pulse
Прежнее рабочее имя: SWChat
Брендовая формула: Pulse by StackWorks
Проект: собственный мессенджер Android/Web на базе Matrix-сервера.

## Главное правило проекта

Не ломать существующие проекты на сервере.

Защищённые production-активы:
- ArtistFlow / artistflow.ru;
- основной виджет StackWorks / https://widget.stackworks.ru/;
- текущие сайты и домены FastPanel.

Запрещено без отдельной явной команды пользователя:
- менять настройки FastPanel;
- менять vhost/config доменов FastPanel;
- применять proxy-настройки в FastPanel;
- перезаписывать nginx-конфиги, которыми управляет FastPanel;
- перезапускать/переустанавливать FastPanel;
- ставить новый Nginx поверх FastPanel;
- менять SSL-сертификаты через FastPanel;
- менять webroot существующих сайтов;
- трогать production-домены;
- менять vhost/config домена widget.stackworks.ru;
- менять webroot виджета;
- затирать файлы виджета;
- интегрировать widget.stackworks.ru с Matrix;
- создавать новый параллельный виджет для Pulse;
- менять vhost/config домена artistflow.ru;
- трогать MySQL/БД ArtistFlow.

Разрешено:
- готовить инструкции;
- готовить шаблоны proxy-конфигов;
- готовить безопасные команды проверки;
- готовить backup/firewall-скрипты;
- описывать, что пользователь может сделать вручную в FastPanel.

## Постоянное правило ведения .sw

Файл `.sw` является главным журналом проекта и ведётся постоянно.

Обязательно записывать в `.sw`:
- каждый значимый шаг разработки;
- архитектурные решения;
- запреты и ограничения;
- защищённые домены и сервисы;
- изменения версий;
- что было создано или изменено;
- текущий статус;
- следующий шаг;
- важные ошибки и выводы после исправлений.

В новом диалоге продолжение проекта начинается с чтения `.sw`.

## Решение по названию

2026-05-09 зафиксировано новое рабочее имя пользовательского продукта:

```text
Pulse
```

Брендовая формула:

```text
Pulse by StackWorks
```

Важно: репозитории пока остаются прежними:
- Core/backend/docs: https://github.com/viktor138irk/SWChat
- App/client: https://github.com/viktor138irk/SWChat-App

Технические имена пакетов не переименовывать без отдельного этапа миграции:
- Dart package name в `pubspec.yaml` пока должен оставаться `fluffychat`, пока все импорты используют `package:fluffychat/...`;
- Android applicationId пока: `ru.stackworks.swchat`;
- Android namespace пока: `ru.stackworks.swchat`;
- рабочий Android entrypoint может временно оставаться на legacy package, если это нужно для стабильного запуска.

## Карта ребрендинга

Места, которые надо учитывать при ребрендинге Pulse/SWChat/другого будущего имени:

```text
pubspec.yaml
README.md
lib/config/app_config.dart
lib/config/setting_keys.dart
lib/config/routes.dart
lib/pages/intro/intro_page.dart
lib/pages/intro/intro_page_presenter.dart
lib/pages/login/login_view.dart
lib/pages/sign_in/sign_in_page.dart
lib/pages/chat_list/client_chooser_button.dart
lib/utils/platform_infos.dart
lib/utils/sign_in_flows/check_homeserver.dart
android/app/build.gradle.kts
android/app/src/main/AndroidManifest.xml
android/app/src/main/kotlin/chat/fluffy/fluffychat/MainActivity.kt
lib/l10n/intl_ru.arb
lib/l10n/intl_en.arb
assets/logo.png
assets/info-logo.png
assets/banner_transparent.png
```

Особо опасные места:

```text
pubspec.yaml name
Dart package imports package:fluffychat/...
Android applicationId
Android namespace
MainActivity package
AndroidManifest activity name
deep links
auth callback scheme
defaultHomeserver
presetHomeserver
applicationName
pushNotificationsAppId
pushNotificationsChannelId
support/donation links
About dialog legalese
login routes
add account routes
```

Правило ребрендинга:
- сначала менять пользовательский UI/тексты/логотипы;
- затем Android applicationId/namespace только с проверкой MainActivity;
- Dart package name и массовые импорты менять только отдельным этапом автоматической миграции;
- не менять `pubspec.yaml name` на новое имя, пока все импорты не переведены с `package:fluffychat/...`.

## Принятая архитектура

Core разворачивается на отдельном сервере.

Базовая схема:
- Matrix Synapse — отдельный сервис на приватном IP:8008;
- PostgreSQL — отдельная база для Matrix/Pulse;
- backend/админка Pulse — отдельный локальный сервис;
- web-client — на FastPanel-сервере в будущем;
- Android-приложение — отдельный клиент Matrix, позже брендированный под Pulse/StackWorks;
- FastPanel/Nginx reverse proxy — основной публичный HTTPS слой.

Основная публичная схема:

```text
пользователь → FastPanel/Nginx HTTPS → Core-сервер Matrix Synapse по private IP
```

Принято решение использовать:

```text
FastPanel reverse proxy → Core
```

## Приватная сеть между серверами

FastPanel proxy сервер и Core объединены в локальную сеть.

Текущие private IP:
- FastPanel proxy: 192.168.0.221;
- Matrix/Core: 192.168.0.141.

Рекомендованная схема:
- FastPanel proxy имеет public IP;
- Core-сервер использует private IP 192.168.0.141;
- proxy_pass идёт на `http://192.168.0.141:8008`;
- прямой доступ к Core:8008 из интернета закрыт;
- доступ к Core:8008 разрешён только с 192.168.0.221.

В docker-compose с версии 0.1.2 порт Synapse настраивается через `.env`:

```text
MATRIX_BIND_HOST=127.0.0.1
```

Для private proxy схемы надо ставить:

```text
MATRIX_BIND_HOST=192.168.0.141
```

После изменения `.env` перезапуск:

```bash
cd /opt/swchat/source
sudo docker compose --env-file /opt/swchat/.env up -d
```

Для ограничения прямого доступа использовать:

```bash
sudo FASTPANEL_PROXY_IP=192.168.0.221 MATRIX_PORT=8008 bash /opt/swchat/source/scripts/firewall_private_proxy.sh
```

Проверка с FastPanel proxy:

```bash
curl http://192.168.0.141:8008/_matrix/client/versions
```

Проверка публичного HTTPS endpoint:

```bash
curl https://matrix.stackworks.ru/_matrix/client/versions
```

## DNS и wildcard-поддомены

Если домен stackworks.ru и все его поддомены уже направлены wildcard-записью на FastPanel-сервер, отдельную DNS A-запись для matrix.stackworks.ru можно не создавать.

Достаточно:
- убедиться, что `*.stackworks.ru` указывает на публичный IP FastPanel;
- создать отдельный сайт `matrix.stackworks.ru` внутри FastPanel;
- выпустить SSL для `matrix.stackworks.ru`;
- настроить для этого сайта reverse proxy на `http://192.168.0.141:8008`.

## Домены проекта

Рекомендуемая безопасная схема:
- matrix.stackworks.ru — Matrix API / Synapse через FastPanel reverse proxy;
- turn.stackworks.ru — TURN/STUN, новый Core сервер;
- api-chat.stackworks.ru — backend API, новый Core сервер, если понадобится;
- admin-chat.stackworks.ru — будущая Pulse Admin Panel;
- chat.stackworks.ru или messenger.stackworks.ru — web-клиент на FastPanel-сервере;
- widget.stackworks.ru — отдельный production-виджет StackWorks, не часть Matrix/Pulse на текущем этапе.

## Предварительные директории Core-сервера

- /opt/swchat/source — исходники GitHub;
- /opt/swchat/app — backend/админка;
- /opt/swchat/matrix — Matrix/Synapse;
- /opt/swchat/data — данные контейнеров;
- /opt/swchat/backups — резервные копии;
- /opt/swchat/logs — логи.

До отдельного этапа server rename директории `/opt/swchat/*` не менять.

## MVP проекта

Минимальные функции:
- регистрация/вход;
- личные сообщения;
- групповые чаты;
- отправка файлов/изображений;
- операторы/админы;
- админка управления пользователями;
- регистрация из приложения;
- поиск людей без ввода Matrix-домена;
- Telegram-like интерфейс без показа Matrix-комнат;
- безопасная установка рядом с production, но на отдельном сервере;
- журнал состояния проекта в этом файле `.sw`.

## UX-решение собственного клиента

В собственном приложении Pulse комнатная структура Matrix должна быть скрыта от пользователя.

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
- не использовать слово «комната» в пользовательском интерфейсе Pulse;
- использовать «чат», «диалог», «группа», «канал»;
- Matrix room показывать как обычный чат;
- создание direct room автоматизировать при первом сообщении контакту;
- групповой room показывать как групповую беседу;
- технические Matrix-настройки прятать в расширенные/админские разделы.

## Регистрация и поиск людей

В будущем клиенте Pulse регистрация должна быть доступна прямо из приложения.

Пользовательский UX:
- регистрация через приложение без консольных команд;
- обычный логин/ник, без ручного ввода домена;
- приложение само формирует Matrix user_id вида `@username:matrix.stackworks.ru`;
- поиск людей по нику, имени, телефону или внутреннему Pulse ID;
- пользователь не должен вводить `@user:matrix.stackworks.ru` вручную;
- кнопка «Написать» должна автоматически создавать direct room;
- контакты и поиск должны выглядеть как в обычном Telegram-like мессенджере.

Техническая схема:
- включить controlled registration или сделать регистрацию через отдельный Pulse backend;
- backend создаёт Matrix-пользователя через Synapse Admin/Register API;
- backend хранит публичный профиль Pulse: display_name, username, phone/email optional, avatar, статус;
- поиск людей лучше делать через свой backend/index, а не напрямую через сырой Matrix room/user lookup;
- Matrix user_id и домен остаются внутренней технической деталью.

## Админка Pulse

Админка нужна обязательно и должна быть отдельным модулем поверх Matrix/Synapse Admin API.

Назначение админки:
- управление пользователями;
- создание/блокировка/разблокировка пользователей;
- сброс паролей;
- назначение и снятие admin-флага;
- просмотр профилей и устройств;
- управление чатами/группами;
- модерация жалоб;
- просмотр базовой статистики;
- настройки регистрации;
- настройки homeserver;
- управление TURN/STUN после добавления звонков;
- диагностика состояния Synapse/PostgreSQL/proxy.

## Стратегия тестирования

Сначала Core тестируется через официальные Matrix-клиенты.
Собственный клиент не писать, пока не подтверждено, что серверная часть работает стабильно через официальные клиенты.

Проверять:
- регистрацию/логин;
- личные сообщения;
- групповые чаты;
- отправку файлов;
- стабильность Synapse;
- работу публичного домена;
- Android-клиент на реальном телефоне.

## Клиентские репозитории

Клиентское приложение вынесено отдельно от Core:
- Core/backend/docs: https://github.com/viktor138irk/SWChat
- App/client: https://github.com/viktor138irk/SWChat-App

SWChat-App создан как отдельный репозиторий для Flutter/FluffyChat клиента.
FluffyChat импортирован в SWChat-App.
Найден pubspec.yaml upstream FluffyChat: name `fluffychat`, version `2.6.0+3553`, Flutter/Dart SDK `>=3.11.1 <4.0.0`.

Принятое текущее Android package/applicationId:

```text
ru.stackworks.swchat
```

До отдельного package migration не менять на Pulse автоматически, чтобы не сломать сборку и запуск.

## Правила ведения проекта

1. Каждый заметный шаг записывать в этот файл `.sw`.
2. Новые версии фиксировать в `VERSION` и changelog/журнале.
3. Не плодить мусорные директории.
4. Все сервисы Pulse держать отдельно от ArtistFlow и widget.stackworks.ru.
5. Не вносить изменения в существующие домены без явной команды.
6. Для FastPanel давать точные proxy-конфиги, но не затирать чужие.
7. Перед потенциально опасными действиями добавлять backup/firewall-скрипт.
8. Любые действия с widget.stackworks.ru только после отдельной явной команды.
9. Ведение `.sw` обязательно на протяжении всего проекта.
10. Всё, что касается текущего production FastPanel, не трогать самостоятельно: только инструкции/шаблоны до отдельной команды пользователя.
11. Собственный клиент Pulse начинать только после успешного тестирования Core через официальные Matrix-клиенты.
12. В собственном клиенте Pulse скрывать Matrix-комнаты и показывать пользователю обычные чаты/диалоги/группы.
13. Основной визуальный и UX-ориентир будущего клиента — Telegram.
14. Админку Pulse делать отдельным защищённым модулем поверх Synapse Admin API.
15. Текущий Android applicationId клиента: `ru.stackworks.swchat`.
16. Регистрация и поиск людей должны быть реализованы как обычный мессенджерный UX без ручного ввода Matrix user_id с доменом.
17. Бренд продукта зафиксирован как Pulse.
18. Brand/UI rename делать отдельно от технического Dart package rename.

## История разработки

### 2026-05-08

- Репозиторий переименован в `viktor138irk/SWChat`.
- Создан файл `.sw`.
- Созданы `VERSION`, `README.md` и базовый `docker-compose.yml`.
- Созданы `docs/ARCHITECTURE.md` и `docs/FASTPANEL_PROXY.md`.
- Созданы `scripts/healthcheck.sh` и `scripts/install.sh`.
- Подготовлен автоустановщик.
- Зафиксировано начальное пользовательское имя продукта: SWChat.
- Принято решение ставить Core на отдельный сервер.
- Старый FastPanel-сервер использовать только для frontend/web-client в будущем.
- Принято решение сначала тестировать Core официальными Matrix-клиентами, затем писать собственный клиент.
- Исправлен `docker-compose.yml`: контейнеры переименованы в `swchat-*`, убран obsolete `version`, добавлены переменные `.env`.
- Исправлена PostgreSQL locale для Synapse: добавлены `POSTGRES_INITDB_ARGS` с locale `C`.
- Исправлена проблема compose down без env: `POSTGRES_PASSWORD` получил безопасный fallback.
- Core успешно поднялся на новом сервере: `swchat-synapse healthy`, `swchat-postgres up`.
- Локальный Matrix endpoint успешно отвечает: `curl http://127.0.0.1:8008/_matrix/client/versions` вернул HTTP 200 OK и JSON версий Matrix API.

### 2026-05-09 — v0.1.1

- Версия проекта повышена до 0.1.1.
- В `docker-compose.yml` добавлен отдельный контейнер `swchat-caddy`.
- Создан `deploy/caddy/Caddyfile`.
- Обновлён `scripts/healthcheck.sh`.
- Принято финальное решение использовать схему FastPanel reverse proxy → Core.
- Создан `docs/FASTPANEL_REVERSE_PROXY.md`.
- Создан `docs/PRIVATE_NETWORK_BETWEEN_SERVERS.md`.
- Уточнены реальные private IP: FastPanel proxy `192.168.0.221`, Matrix/Core `192.168.0.141`.
- Проверено с FastPanel proxy: `curl http://192.168.0.141:8008/_matrix/client/versions` успешно вернул JSON Matrix API.
- Проверено: `https://matrix.stackworks.ru/_matrix/client/versions` через FastPanel reverse proxy успешно вернул Matrix API JSON.
- Публичный HTTPS endpoint Matrix через FastPanel работает.
- Проверено: `registration_shared_secret` присутствует в `/opt/swchat/data/synapse/homeserver.yaml`.
- Зафиксировано: bootstrap-регистрация администратора через `register_new_matrix_user` разрешена.
- При входе в Element пойман `M_LIMIT_EXCEEDED` после нескольких попыток авторизации.
- Принято UX-решение: клиент делать максимально в стиле Telegram.
- Репозиторий клиентского приложения подтверждён: https://github.com/viktor138irk/SWChat-App.
- FluffyChat импортирован в SWChat-App.
- Проверен `pubspec.yaml` FluffyChat в SWChat-App.
- Зафиксирована необходимость Admin Panel для управления пользователями и модерации.
- SWChat-App успешно собран и запущен на Android-телефоне Samsung SM S928B.
- Rust/rustup/cargo установлены на Windows для сборки `flutter_vodozemac/libvodozemac`.
- Ошибка `libvodozemac_bindings_dart.so` устранена после установки Rust.
- Авторизация в приложении SWChat-App/FluffyChat через homeserver `https://matrix.stackworks.ru` успешно прошла.
- Принят Android package/applicationId: `ru.stackworks.swchat`.
- Принято требование: регистрация прямо из приложения и поиск людей без необходимости вводить Matrix-домен.
- Начат первичный Android-ребрендинг SWChat-App.
- `build.gradle.kts` переведён с `chat.fluffy.fluffychat` на `ru.stackworks.swchat`.
- Android namespace изменён на `ru.stackworks.swchat`.
- `AndroidManifest.xml` обновлён: приложение переименовано в SWChat.
- Deep link scheme изменён с `im.fluffychat` на `swchat`.
- Auth callback scheme изменён с `im.fluffychat.auth` на `swchat.auth`.
- Выявлена ошибка: преждевременная смена `pubspec.yaml name` ломает импорты `package:fluffychat/...`.
- Зафиксировано правило: `pubspec.yaml name` оставлять `fluffychat` до отдельной массовой миграции импортов.
- Зафиксировано новое рабочее имя пользовательского продукта: Pulse.

### 2026-05-09 — v0.1.2

- Версия проекта повышена до 0.1.2.
- `VERSION` обновлён до `0.1.2`.
- `README.md` актуализирован под бренд Pulse, split-server архитектуру и private reverse proxy схему.
- В `docker-compose.yml` порт Synapse сделан настраиваемым через переменную `MATRIX_BIND_HOST`.
- По умолчанию Matrix endpoint остаётся безопасным localhost-only: `127.0.0.1:8008`.
- Для схемы FastPanel proxy → Core теперь можно указать `MATRIX_BIND_HOST=192.168.0.141` в `/opt/swchat/.env`.
- `scripts/install.sh` обновлён: добавлена переменная `MATRIX_BIND_HOST`, автоматическое добавление отсутствующей переменной в существующий `.env`, уточнены next steps.
- `scripts/healthcheck.sh` расширен: показывает `SERVER_NAME`, `MATRIX_BIND_HOST`, контейнеры компактной таблицей, проверяет local endpoint, private bound endpoint, публичный HTTPS endpoint и UFW status.
- Создан `scripts/firewall_private_proxy.sh`.
- `scripts/firewall_private_proxy.sh` разрешает доступ к Matrix 8008 только с FastPanel proxy IP и закрывает публичный прямой доступ к 8008.
- По умолчанию firewall-скрипт не меняет default policy UFW, чтобы не запереть сервер случайно; для чистого Core можно запускать с `APPLY_UFW_DEFAULTS=yes`.
- Зафиксировано правило: прямой доступ к Core:8008 из интернета должен быть закрыт, публичный вход только через `https://matrix.stackworks.ru`.
- Продолжается staged-ребрендинг: Core-документация уже говорит Pulse/SWChat, Android-клиент трогать отдельным этапом через SWChat-App.

## Текущий этап установки

Core локально работает на новом отдельном сервере.

Публичный HTTPS endpoint через FastPanel reverse proxy ранее был проверен и работал:

```text
https://matrix.stackworks.ru/_matrix/client/versions
```

Клиентский репозиторий SWChat-App содержит импортированный FluffyChat.

Android-клиент успешно запускается на Samsung SM S928B и авторизуется на нашем Matrix homeserver.

Идёт staged-ребрендинг пользовательского продукта в Pulse.

В Core-репозитории подготовлен безопасный механизм для private proxy bind и firewall-ограничения порта 8008.

## Следующий шаг

Следующий этап:
- на Core-сервере проверить `.env`, выставить `MATRIX_BIND_HOST=192.168.0.141`, если FastPanel reverse proxy ходит к Core по private IP;
- выполнить `sudo docker compose --env-file /opt/swchat/.env up -d`;
- выполнить `sudo bash /opt/swchat/source/scripts/healthcheck.sh`;
- с FastPanel proxy проверить `curl http://192.168.0.141:8008/_matrix/client/versions`;
- применить firewall-ограничение: `sudo FASTPANEL_PROXY_IP=192.168.0.221 MATRIX_PORT=8008 bash /opt/swchat/source/scripts/firewall_private_proxy.sh`;
- ещё раз проверить `https://matrix.stackworks.ru/_matrix/client/versions`;
- вернуть `pubspec.yaml name: fluffychat` в SWChat-App, если локально или в GitHub оно было изменено;
- провести UI-ребрендинг SWChat → Pulse в `app_config.dart`, `setting_keys.dart`, intro/login/about/menu;
- убрать FluffyChat branding из Flutter onboarding, настроек, push-диалогов и локализаций;
- внедрить default homeserver `matrix.stackworks.ru`;
- подготовить собственные логотипы/splash/icon pack Pulse;
- заложить регистрацию из приложения через backend или controlled Synapse registration;
- заложить поиск людей по нику/имени/телефону без ручного ввода Matrix user_id;
- проверить создание комнаты, отправку сообщений и файлов;
- отдельным этапом поднять готовую Synapse Admin UI или начать Pulse Admin Panel.
