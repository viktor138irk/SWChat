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

## Текущая архитектура установки

Принято решение ставить SWChat Core на отдельный новый сервер.

Старый сервер с FastPanel используется только для будущего frontend/web-клиента, без размещения Matrix/PostgreSQL/TURN.

Разделение:
- новый сервер: Matrix Synapse, PostgreSQL, TURN/STUN, backend, media storage, backups;
- FastPanel-сервер: домены, frontend/web-client, публичная витрина и reverse proxy, без размещения PostgreSQL/TURN и без вмешательства в чужие production-проекты.

## Стратегия тестирования

Сначала SWChat Core тестируется через официальные Matrix-клиенты.

Порядок:
1. Поднять и проверить Matrix/Synapse на Core-сервере.
2. Проверить локальный Matrix endpoint.
3. Настроить публичный домен matrix.stackworks.ru.
4. Проверить вход, регистрацию, комнаты, сообщения и файлы через официальные клиенты Matrix/Element.
5. Только после успешного тестирования официальными клиентами начинать разработку собственного Android/Web-клиента SWChat.

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

Применение любых изменений в FastPanel — только после отдельной явной команды пользователя.

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

На текущем этапе SWChat НЕ связывается с widget.stackworks.ru и НЕ создаёт новый виджет.

Запрещено без отдельной явной команды:
- менять vhost/config домена widget.stackworks.ru;
- менять webroot виджета;
- затирать файлы виджета;
- менять SSL и настройки домена;
- интегрировать виджет с Matrix;
- создавать новый параллельный виджет для SWChat.

## Важно про ArtistFlow

ArtistFlow должен оставаться нетронутым:
- не менять vhost/config домена artistflow.ru;
- не перезаписывать общий nginx.conf FastPanel;
- не ставить новый Nginx поверх FastPanel;
- не трогать MySQL/БД ArtistFlow;
- не занимать порты FastPanel и текущих сайтов;
- перед изменениями nginx/FastPanel делать backup конфигов.

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

## Приватная сеть между серверами

Зафиксировано: FastPanel proxy сервер и SWChat Core объединены в локальную сеть.

Текущие private IP:
- FastPanel proxy: 192.168.0.221;
- SWChat Matrix/Core: 192.168.0.141.

Это предпочтительная production-схема.

Преимущества:
- Matrix port 8008 не публикуется в интернет;
- FastPanel proxy подключается к Synapse по private IP;
- снижается поверхность атаки;
- упрощается firewall;
- Core-сервер становится изолированным backend-узлом.

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

FastPanel/Nginx сам разрулит поддомены по vhost/server_name.

## Вариант с другим FastPanel-сервером

Можно разместить публичные домены SWChat на другом нашем сервере с FastPanel, если этот сервер не является текущим production-сервером ArtistFlow/widget.stackworks.ru.

Разрешённая роль такого FastPanel-сервера:
- держать DNS/домены и SSL для chat.stackworks.ru, messenger.stackworks.ru, matrix.stackworks.ru;
- размещать web-клиент SWChat;
- работать как reverse proxy до Core-сервера с Matrix Synapse;
- отдавать статическую витрину/лендинг/документацию SWChat.

Нежелательная роль FastPanel-сервера:
- размещать PostgreSQL Matrix;
- размещать TURN/STUN для звонков;
- хранить тяжёлые media/backups Matrix;
- смешивать Matrix Core с чужими production-проектами.

Предпочтительная схема:
- Core-сервер: Synapse, PostgreSQL, media, backups, TURN позже;
- отдельный FastPanel-сервер: домены, SSL, frontend и proxy;
- старый production FastPanel с ArtistFlow/widget.stackworks.ru не трогать.

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

## Что понадобится на новом Core-сервере

- Ubuntu 24.04 или Ubuntu 22.04;
- root-доступ;
- Docker Engine;
- Docker Compose plugin;
- PostgreSQL в контейнере;
- Matrix Synapse в контейнере;
- FastPanel reverse proxy на отдельном сервере;
- приватная сеть/VPN между серверами;
- coturn позже;
- отдельные DNS-записи на proxy FastPanel сервер или wildcard-запись *.stackworks.ru на него.

## MVP проекта

Первая рабочая цель:
1. Подготовить базовый репозиторий.
2. Поднять Matrix Synapse на отдельном Core-сервере.
3. Подключить PostgreSQL.
4. Проверить локальный Matrix endpoint.
5. Подготовить DNS/proxy инструкции без изменения production FastPanel.
6. Протестировать через официальные Matrix-клиенты.
7. Только после этого подготовить Android/Web-клиент SWChat.

Минимальные функции:
- регистрация/вход;
- личные сообщения;
- групповые комнаты;
- отправка файлов/изображений;
- операторы/админы;
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
- Зафиксировано, что widget.stackworks.ru — отдельный production-виджет StackWorks.
- Зафиксировано, что widget.stackworks.ru пока никак не связывается с Matrix/SWChat.
- Зафиксировано, что новый виджет SWChat не планируется.
- Зафиксировано постоянное правило: файл .sw ведётся всегда и обновляется после каждого значимого шага.
- Зафиксировано жёсткое правило: всё, что касается FastPanel, самостоятельно не трогать; только готовить инструкции и шаблоны до отдельной явной команды пользователя.

2026-05-09:
- Версия проекта повышена до 0.1.1.
- В docker-compose.yml добавлен отдельный контейнер swchat-caddy.
- Принято решение использовать Caddy как основной HTTPS reverse proxy для SWChat Core.
- Создан deploy/caddy/Caddyfile.
- HTTPS реализуется полностью на отдельном Core-сервере без участия FastPanel.
- Caddy проксирует HTTPS-трафик на локальный Matrix Synapse 127.0.0.1:8008.
- Добавлены постоянные директории хранения Caddy data/config/logs.
- Обновлён scripts/healthcheck.sh.
- Исправлено старое имя WSMessenger в healthcheck.
- Healthcheck теперь дополнительно проверяет 80/443 порты и локальный Matrix endpoint.
- Рассмотрен вариант размещения публичных доменов SWChat на другом нашем сервере с FastPanel.
- Зафиксировано: отдельный FastPanel-сервер можно использовать для доменов, SSL, web-клиента и reverse proxy до Core-сервера.
- Зафиксировано: Matrix Core, PostgreSQL, media storage, backups и TURN/STUN лучше держать на отдельном Core-сервере, а не внутри FastPanel.
- Зафиксировано: текущий production FastPanel с ArtistFlow/widget.stackworks.ru не трогать.
- Принято финальное решение использовать схему FastPanel reverse proxy → SWChat Core.
- Создан docs/FASTPANEL_REVERSE_PROXY.md.
- Зафиксирована схема ограничения доступа к Matrix port 8008 только с IP FastPanel proxy сервера.
- Зафиксировано: SSL и публичные домены обслуживаются FastPanel/Nginx.
- Зафиксировано: Synapse остаётся изолированным на Core-сервере.
- Зафиксировано: между FastPanel proxy и SWChat Core можно использовать приватную сеть/VPN.
- Создан docs/PRIVATE_NETWORK_BETWEEN_SERVERS.md.
- Зафиксировано: private network между серверами является предпочтительной production-схемой.
- Уточнены реальные private IP: FastPanel proxy 192.168.0.221, Matrix/Core 192.168.0.141.
- Зафиксировано: proxy_pass должен идти на http://192.168.0.141:8008.
- Зафиксировано: доступ к Core:8008 разрешать только с 192.168.0.221.
- Проверено с FastPanel proxy: curl http://192.168.0.141:8008/_matrix/client/versions успешно вернул JSON Matrix API.
- Зафиксировано: связка FastPanel proxy → Matrix/Core по локальной сети работает.
- Зафиксировано: если stackworks.ru и wildcard-поддомены уже направлены на FastPanel, matrix.stackworks.ru можно разрулить созданием отдельного сайта/vhost в FastPanel без отдельной DNS-записи.
- Проверено: https://matrix.stackworks.ru/_matrix/client/versions через FastPanel reverse proxy успешно вернул Matrix API JSON.
- Зафиксировано: публичный HTTPS endpoint Matrix через FastPanel работает.

## Текущий этап установки

SWChat Core локально работает на новом отдельном сервере.

Публичный HTTPS endpoint через FastPanel reverse proxy работает:
- https://matrix.stackworks.ru/_matrix/client/versions возвращает Matrix API JSON.

Текущий выбранный этап:
- отдельный FastPanel reverse proxy сервер с private IP 192.168.0.221;
- публичный SSL через FastPanel;
- приватная сеть между FastPanel и Core;
- Matrix Synapse на Core с private IP 192.168.0.141;
- локальный доступ FastPanel → Core:8008 подтверждён;
- публичный доступ Internet → FastPanel → Core подтверждён.

## Следующий шаг

Следующий этап:
- закрыть прямой доступ к Core:8008 из интернета и разрешить только 192.168.0.221;
- создать первого пользователя Matrix;
- проверить вход через официальный Element/Matrix клиент на homeserver https://matrix.stackworks.ru;
- проверить создание комнаты, отправку сообщений и файлов;
- только после этого готовить frontend и свой Android/Web-клиент.
