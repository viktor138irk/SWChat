# SWChat

SWChat — self-hosted Android/Web мессенджер на базе Matrix для экосистемы StackWorks.

Проект строится как собственная платформа связи:
- Matrix Core на отдельном сервере;
- PostgreSQL;
- официальный Matrix/Element-клиент для первого тестирования;
- будущий web-клиент;
- будущий Android-клиент;
- будущая админ-панель;
- безопасная архитектура без вмешательства в существующий production.

## Текущая стратегия

Сначала поднимаем и проверяем серверное ядро через официальные Matrix-клиенты.

Порядок:

1. Поднять SWChat Core на отдельном сервере.
2. Проверить Matrix/Synapse локально.
3. Настроить публичный домен `matrix.stackworks.ru`.
4. Проверить работу через официальные клиенты Matrix/Element.
5. Только после стабильной проверки начинать разработку собственного Android/Web-клиента.

Это нужно, чтобы не путать проблемы сервера с проблемами будущего собственного UI.

## Архитектура

SWChat работает по split-server архитектуре.

### Новый сервер: SWChat Core

На новом сервере размещаются:
- Matrix Synapse;
- PostgreSQL;
- media storage;
- будущий TURN/STUN;
- будущий backend API;
- backups;
- diagnostics.

Рекомендуемые домены:

```text
matrix.stackworks.ru      -> новый SWChat Core сервер
turn.stackworks.ru        -> новый SWChat Core сервер, позже
api-chat.stackworks.ru    -> новый SWChat Core сервер, позже
```

### Старый сервер с FastPanel

Старый сервер с FastPanel используется только для будущего frontend/web-клиента.

На нём остаются отдельно:
- ArtistFlow;
- widget.stackworks.ru;
- текущие сайты StackWorks/FastPanel.

SWChat installer не меняет FastPanel, не меняет vhost, не меняет SSL и не трогает существующие сайты.

Будущий frontend-домен:

```text
chat.stackworks.ru
```

## Что нельзя трогать

Защищённые production-активы:
- `artistflow.ru`;
- `widget.stackworks.ru`;
- текущие сайты FastPanel;
- настройки FastPanel без отдельной явной команды.

`widget.stackworks.ru` на текущем этапе никак не связан с Matrix/SWChat. Новый виджет SWChat не планируется.

## Установка SWChat Core

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

## Структура проекта

```text
.sw                    главный журнал проекта
docker-compose.yml     Matrix/PostgreSQL stack
scripts/install.sh     автоустановщик Core-сервера
scripts/healthcheck.sh диагностика
docs/                  документация
VERSION                версия проекта
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

Версия: `0.1.0`

Сейчас идёт этап запуска SWChat Core на отдельном сервере и тестирования через официальные Matrix-клиенты.
