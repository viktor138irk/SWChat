# WSMessenger

WSMessenger — собственный Android/Web мессенджер на базе Matrix.

Проект создаётся как независимая экосистема StackWorks:
- Android-приложение;
- web-клиент;
- Matrix homeserver;
- встраиваемый чат-виджет;
- админ-панель;
- операторские панели;
- self-hosted установка рядом с FastPanel.

## Главная цель

Создать современный self-hosted мессенджер с:
- собственным брендом;
- независимой инфраструктурой;
- Android-клиентом;
- web-клиентом;
- поддержкой виджета для сайтов;
- возможностью масштабирования;
- безопасной установкой рядом с существующими проектами.

## Базовая архитектура

- Matrix Synapse;
- PostgreSQL;
- coturn;
- FastPanel reverse proxy;
- Docker Compose;
- Android Matrix SDK;
- собственный backend/панель.

## Безопасность

WSMessenger никогда не должен ломать существующие проекты:
- ArtistFlow;
- сайты FastPanel;
- nginx-конфиги;
- существующие базы данных.

Все сервисы запускаются отдельно и наружу публикуются только через reverse proxy.

## Структура проекта

- docs/ — документация;
- scripts/ — installer/healthcheck;
- public/widget/ — web widget;
- docker-compose.yml — инфраструктура Matrix;
- .sw — главный журнал проекта.

## Текущий статус

Версия: 0.1.0

Подготовлен базовый фундамент проекта.
