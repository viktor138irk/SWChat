# SWChat Core — серверный журнал проекта

Дата старта: 2026-05-08
Дата обновления: 2026-05-09
Репозиторий Core/backend/docs: https://github.com/viktor138irk/SWChat
Репозиторий Android/client: https://github.com/viktor138irk/SWChat-App
Публичное имя продукта: Pulse
Техническое имя серверного проекта: SWChat Core
Брендовая формула: Pulse by StackWorks
Проект: серверная часть собственного мессенджера Android/Web на базе Matrix/Synapse.

---

## Разделение журналов

С 2026-05-09 разработка ведётся как единый комбайн Pulse/SWChat в одном рабочем чате, но журналы разделены по репозиториям.

- `viktor138irk/SWChat/.sw` — только сервер, Core, Synapse, PostgreSQL, reverse proxy, firewall, домены, backend/API/admin.
- `viktor138irk/SWChat-App/.sw` — Android/Flutter-клиент, FluffyChat, UI/UX Pulse, package/applicationId, APK, локализации, иконки, deep links.

Правило: в серверный `.sw` не заносить клиентские детали SWChat-App/Pulse UI, кроме ссылок на клиентский репозиторий и общей схемы интеграции.

---

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

---

## Постоянное правило ведения .sw

Файл `.sw` является главным журналом соответствующего репозитория и ведётся постоянно.

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

В новом диалоге продолжение серверной части начинается с чтения `viktor138irk/SWChat/.sw`.
Для Android-клиента начинать с чтения `viktor138irk/SWChat-App/.sw`.

---

## Решение по названию

2026-05-09 зафиксировано публичное имя продукта:

```text
Pulse
```

Брендовая формула:

```text
Pulse by StackWorks
```

Важно: технические репозитории остаются прежними:
- Core/backend/docs: `viktor138irk/SWChat`;
- Android/client: `viktor138irk/SWChat-App`.

Серверные директории `/opt/swchat/*` пока не переименовывать без отдельного этапа server rename.

---

## Принятая серверная архитектура

Core разворачивается на отдельном сервере.

Базовая схема:
- Matrix Synapse — отдельный сервис на приватном IP:8008;
- PostgreSQL — отдельная база для Matrix/Pulse;
- backend/API Pulse — отдельный локальный сервис в будущем;
- админка Pulse — отдельный защищённый модуль поверх Synapse Admin API в будущем;
- web-client — на FastPanel-сервере в будущем;
- Android-приложение — отдельный клиент из репозитория `SWChat-App`;
- FastPanel/Nginx reverse proxy — основной публичный HTTPS слой.

Основная публичная схема:

```text
пользователь → FastPanel/Nginx HTTPS → Core-сервер Matrix Synapse по private IP
```

Принято решение использовать:

```text
FastPanel reverse proxy → Core
```

---

## Приватная сеть между серверами

FastPanel proxy сервер и Core объединены в локальную сеть.

Текущие private IP:
- FastPanel proxy: `192.168.0.221`;
- Matrix/Core: `192.168.0.141`.

Рекомендованная схема:
- FastPanel proxy имеет public IP;
- Core-сервер использует private IP `192.168.0.141`;
- `proxy_pass` идёт на `http://192.168.0.141:8008`;
- прямой доступ к Core:8008 из интернета закрыт;
- доступ к Core:8008 разрешён только с `192.168.0.221`.

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

---

## DNS и wildcard-поддомены

Если домен `stackworks.ru` и все его поддомены уже направлены wildcard-записью на FastPanel-сервер, отдельную DNS A-запись для `matrix.stackworks.ru` можно не создавать.

Достаточно:
- убедиться, что `*.stackworks.ru` указывает на публичный IP FastPanel;
- создать отдельный сайт `matrix.stackworks.ru` внутри FastPanel;
- выпустить SSL для `matrix.stackworks.ru`;
- настроить для этого сайта reverse proxy на `http://192.168.0.141:8008`.

---

## Домены проекта

Рекомендуемая безопасная схема:
- `matrix.stackworks.ru` — Matrix API / Synapse через FastPanel reverse proxy;
- `turn.stackworks.ru` — TURN/STUN, новый Core сервер;
- `api-chat.stackworks.ru` — backend API, новый Core сервер, если понадобится;
- `admin-chat.stackworks.ru` — будущая Pulse Admin Panel;
- `chat.stackworks.ru` или `messenger.stackworks.ru` — web-клиент на FastPanel-сервере;
- `widget.stackworks.ru` — отдельный production-виджет StackWorks, не часть Matrix/Pulse на текущем этапе.

---

## Предварительные директории Core-сервера

- `/opt/swchat/source` — исходники GitHub;
- `/opt/swchat/app` — backend/API/админка;
- `/opt/swchat/matrix` — Matrix/Synapse;
- `/opt/swchat/data` — данные контейнеров;
- `/opt/swchat/backups` — резервные копии;
- `/opt/swchat/logs` — логи.

До отдельного этапа server rename директории `/opt/swchat/*` не менять.

---

## MVP серверной части

Минимальные серверные функции:
- стабильный Matrix/Synapse homeserver;
- PostgreSQL для Synapse;
- публичный HTTPS endpoint через FastPanel reverse proxy;
- закрытый прямой доступ к Core:8008 из интернета;
- регистрация пользователей через controlled registration или будущий backend;
- интеграция Android-клиента с `https://matrix.stackworks.ru`;
- личные сообщения;
- групповые чаты;
- отправка файлов/изображений;
- backend/API для профилей, поиска людей и регистрации;
- админка управления пользователями;
- диагностика состояния Synapse/PostgreSQL/proxy;
- журнал состояния проекта в этом файле `.sw`.

---

## Регистрация и поиск людей — серверная схема

Пользовательский UX реализуется в клиенте, но сервер должен обеспечить нормальную механику:

- backend создаёт Matrix-пользователя через Synapse Admin/Register API;
- backend хранит публичный профиль Pulse: display_name, username, phone/email optional, avatar, статус;
- поиск людей лучше делать через свой backend/index, а не напрямую через сырой Matrix room/user lookup;
- Matrix user_id и домен остаются внутренней технической деталью;
- direct room создаётся автоматически клиентом/серверной логикой при первом сообщении контакту.

---

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

---

## Стратегия тестирования Core

Сначала Core тестируется через официальные Matrix-клиенты.
Собственный клиент развивается отдельно в `SWChat-App`, но сервер должен оставаться проверяемым через стандартные Matrix endpoint.

Проверять:
- регистрацию/логин;
- личные сообщения;
- групповые чаты;
- отправку файлов;
- стабильность Synapse;
- работу публичного домена;
- доступность `/_matrix/client/versions`;
- firewall-ограничение прямого доступа к 8008;
- совместимость с Android-клиентом Pulse.

---

## Правила ведения серверного проекта

1. Каждый заметный серверный шаг записывать в этот файл `.sw`.
2. Новые версии фиксировать в `VERSION` и changelog/журнале.
3. Не плодить мусорные директории.
4. Все сервисы Pulse держать отдельно от ArtistFlow и widget.stackworks.ru.
5. Не вносить изменения в существующие домены без явной команды.
6. Для FastPanel давать точные proxy-конфиги, но не затирать чужие.
7. Перед потенциально опасными действиями добавлять backup/firewall-скрипт.
8. Любые действия с widget.stackworks.ru только после отдельной явной команды.
9. Ведение `.sw` обязательно на протяжении всего проекта.
10. Всё, что касается текущего production FastPanel, не трогать самостоятельно: только инструкции/шаблоны до отдельной команды пользователя.
11. Клиентские Android/Flutter задачи записывать в `viktor138irk/SWChat-App/.sw`, а не в серверный журнал.
12. Серверный журнал хранит только интеграционные требования к клиенту: endpoint, API, регистрация, поиск, push/backend, admin.
13. Публичный бренд продукта — Pulse, но серверный технический проект остаётся SWChat Core до отдельной миграции.

---

## История разработки

### 2026-05-08

- Репозиторий переименован в `viktor138irk/SWChat`.
- Создан файл `.sw`.
- Созданы `VERSION`, `README.md` и базовый `docker-compose.yml`.
- Созданы `docs/ARCHITECTURE.md` и `docs/FASTPANEL_PROXY.md`.
- Созданы `scripts/healthcheck.sh` и `scripts/install.sh`.
- Подготовлен автоустановщик.
- Принято решение ставить Core на отдельный сервер.
- Старый FastPanel-сервер использовать только для frontend/web-client в будущем.
- Принято решение сначала тестировать Core официальными Matrix-клиентами.
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
- Зафиксирована необходимость Admin Panel для управления пользователями и модерации.
- Принято требование: регистрация прямо из приложения и поиск людей без необходимости вводить Matrix-домен.
- Зафиксировано публичное имя продукта: Pulse.

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

### 2026-05-09 — разделение журналов

- Серверный `.sw` очищен от подробной клиентской информации SWChat-App/Pulse UI.
- Клиентская информация теперь должна храниться в `viktor138irk/SWChat-App/.sw`.
- В серверном `.sw` оставлены только Core/Synapse/PostgreSQL/proxy/firewall/backend/admin и интеграционные требования к клиенту.
- Зафиксировано правило: разработка идёт в одном чате как единый комбайн, но журналы ведутся отдельно по репозиториям.

---

## Текущий этап установки

Core локально работает на новом отдельном сервере.

Публичный HTTPS endpoint через FastPanel reverse proxy ранее был проверен и работал:

```text
https://matrix.stackworks.ru/_matrix/client/versions
```

В Core-репозитории подготовлен безопасный механизм для private proxy bind и firewall-ограничения порта 8008.

Клиентский Android-проект и его текущие задачи ведутся отдельно в:

```text
https://github.com/viktor138irk/SWChat-App/.sw
```

---

## Следующий шаг Core

Следующий серверный этап:
- на Core-сервере проверить `.env`;
- выставить `MATRIX_BIND_HOST=192.168.0.141`, если FastPanel reverse proxy ходит к Core по private IP;
- выполнить `sudo docker compose --env-file /opt/swchat/.env up -d`;
- выполнить `sudo bash /opt/swchat/source/scripts/healthcheck.sh`;
- с FastPanel proxy проверить `curl http://192.168.0.141:8008/_matrix/client/versions`;
- применить firewall-ограничение: `sudo FASTPANEL_PROXY_IP=192.168.0.221 MATRIX_PORT=8008 bash /opt/swchat/source/scripts/firewall_private_proxy.sh`;
- ещё раз проверить `https://matrix.stackworks.ru/_matrix/client/versions`;
- начать проектирование backend/API для регистрации, профилей и поиска людей;
- отдельным этапом поднять готовую Synapse Admin UI или начать Pulse Admin Panel.
