# SWChat — сброс пароля администратора Matrix

Если пароль администратора забыт, не нужно полностью удалять Matrix.

## Вариант 1 — создать нового администратора

На Core-сервере выполнить:

```bash
docker exec -it swchat-synapse register_new_matrix_user \
  -c /data/homeserver.yaml \
  -u swroot \
  -p 'NewStrongPass123!' \
  -a \
  http://localhost:8008
```

После этого войти в Element:

```text
Homeserver: https://matrix.stackworks.ru
Login: swroot
Password: NewStrongPass123!
```

## Вариант 2 — полный сброс Matrix

Полный сброс удалит:
- пользователей;
- комнаты;
- сообщения;
- media;
- PostgreSQL данные Synapse.

Команды:

```bash
cd /opt/swchat/source

docker compose --env-file /opt/swchat/.env down

mkdir -p /opt/swchat/backups/reset-before-$(date +%F_%H-%M-%S)
cp -a /opt/swchat/data/synapse /opt/swchat/backups/reset-before-$(date +%F_%H-%M-%S)/synapse 2>/dev/null || true
cp -a /opt/swchat/data/postgres /opt/swchat/backups/reset-before-$(date +%F_%H-%M-%S)/postgres 2>/dev/null || true

rm -rf /opt/swchat/data/synapse
rm -rf /opt/swchat/data/postgres

bash /opt/swchat/source/scripts/install.sh
```

После полного сброса заново создать первого администратора.

## Рекомендация

Сначала использовать вариант 1 — создать нового администратора. Полный сброс делать только если база тестовая и данных не жалко.
