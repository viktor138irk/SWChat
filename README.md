# Pulse / SWChat

Pulse — self-hosted Android/Web мессенджер на базе Matrix для экосистемы StackWorks.

Техническое имя репозитория пока остаётся SWChat. Пользовательский бренд продукта — `Pulse by StackWorks`.

Проект строится как собственная платформа связи:
- Matrix Core на отдельном сервере;
- PostgreSQL;
- FastPanel reverse proxy как публичный HTTPS слой;
- официальный Matrix/Element-клиент для первого тестирования;
- будущий web-клиент;
- будущий Android-клиент;
- будущая админ-панель;
- безопасная архитектура без вмешательства в существующий production.

## Текущая стратегия

Сначала поднимаем и проверяем серверное ядро через официальные Matrix-клиенты.

Порядок:

1. Поднять Pulse/SWChat Core на отдельном сервере.
2. Проверить Matrix/Synapse локально.
3. Настроить публичный домен `matrix.stackworks.ru` через FastPanel reverse proxy.
4. Проверить работу через официальные клиенты Matrix/Element.
5. Только после стабильной проверки продолжать глубокий ребрендинг собственного Android/Web-клиента.

Это нужно, чтобы не путать проблемы сервера с проблемами будущего собственного UI.

## Архитектура

Pulse/SWChat работает по split-server архитектуре.

### Новый сервер: Core

На новом сервере размещаются:
- Matrix Synapse;
- PostgreSQL;
- media storage;
- будущий TURN/STUN;
- будущий backend API;
- backups;
- diagnostics.

Текущие private IP:

```text
FastPanel proxy: 192.168.0.221
Matrix/Core:     192.168.0.141
```

Рекомендуемые домены:

```text
matrix.stackworks.ru      -> Matrix API / Synapse через FastPanel reverse proxy
turn.stackworks.ru        -> новый Core сервер, позже
api-chat.stackworks.ru    -> будущий backend API
admin-chat.stackworks.ru  -> будущая Pulse Admin Panel
chat.stackworks.ru        -> будущий web-клиент
```

### Старый сервер с FastPanel

Старый сервер с FastPanel используется как публичный HTTPS/reverse proxy слой и для будущего frontend/web-клиента.

На нём остаются отдельно:
- ArtistFlow;
- widget.stackworks.ru;
- текущие сайты StackWorks/FastPanel.

Installer не меняет FastPanel, не меняет vhost, не меняет SSL и не трогает существующие сайты.

## Что нельзя трогать

Защищённые production-активы:
- `artistflow.ru`;
- `widget.stackworks.ru`;
- текущие сайты FastPanel;
- настройки FastPanel без отдельной явной команды.

`widget.stackworks.ru` на текущем этапе никак не связан с Matrix/Pulse. Новый виджет Pulse не планируется.

## Установка Core

На новом сервере Ubuntu:

```bash
sudo mkdir -p /opt/swchat
sudo git clone https://github.com/viktor138irk/SWChat.git /opt/swchat/source
cd /opt/swchat/source
sudo SERVER_NAME=matrix.stackworks.ru bash scripts/install.sh
```

Installer:
- создаёт структуру `/opt/swchat`;
- устанавливает Docker, если он отсутствует;
- создаёт `.env`;
- генерирует Synapse config;
- настраивает PostgreSQL для Synapse;
- запускает контейнеры;
- не трогает FastPanel.

## Настройка private reverse proxy

По умолчанию Matrix endpoint слушает только localhost:

```text
MATRIX_BIND_HOST=127.0.0.1
```

Для схемы FastPanel reverse proxy → Core нужно на Core-сервере в `/opt/swchat/.env` указать private IP Core:

```text
MATRIX_BIND_HOST=192.168.0.141
```

Затем перезапустить stack:

```bash
cd /opt/swchat/source
sudo docker compose --env-file /opt/swchat/.env up -d
```

И закрыть прямой публичный доступ к Matrix, разрешив порт 8008 только FastPanel proxy:

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

## Проверка после установки

```bash
sudo bash /opt/swchat/source/scripts/healthcheck.sh
curl http://127.0.0.1:8008/_matrix/client/versions
```

Ожидаемый результат `curl` — JSON с версиями Matrix API.

## Тестирование официальными клиентами

До разработки собственного клиента проверяем сервер через:
- Element Web;
- Element Desktop;
- Element Android;
- любые совместимые Matrix-клиенты.

Проверяем:
- регистрацию/логин;
- личные сообщения;
- комнаты;
- отправку файлов;
- стабильность Synapse;
- работу публичного домена.

## Android-клиент

Клиентский репозиторий:

```text
https://github.com/viktor138irk/SWChat-App
```

Важное правило staged-ребрендинга:
- пользовательские тексты и UI можно переводить на Pulse;
- `pubspec.yaml name` пока должен оставаться `fluffychat`, пока импорты используют `package:fluffychat/...`;
- Android applicationId сейчас принят как `ru.stackworks.swchat`;
- массовая миграция Dart package/imports — отдельный этап.

## Структура проекта

```text
.sw                              главный журнал проекта
docker-compose.yml               Matrix/PostgreSQL stack
scripts/install.sh               автоустановщик Core-сервера
scripts/healthcheck.sh           диагностика
scripts/firewall_private_proxy.sh безопасное ограничение 8008 под FastPanel proxy
docs/                            документация
VERSION                          версия проекта
```

## Правило `.sw`

Файл `.sw` — главный журнал проекта.

В него обязательно записываются:
- архитектурные решения;
- изменения версий;
- текущий статус;
- следующий шаг;
- ошибки и исправления;
- запреты и защищённые production-активы.

Новый диалог по проекту начинается с чтения `.sw`.

## Текущий статус

Версия: `0.1.2`

Core работает на отдельном сервере, публичный HTTPS endpoint `https://matrix.stackworks.ru/_matrix/client/versions` уже был проверен через FastPanel reverse proxy. Текущий этап — закрепление private proxy/firewall схемы и staged-ребрендинг Android-клиента в Pulse без поломки FluffyChat imports.
