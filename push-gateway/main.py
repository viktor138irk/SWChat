from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import firebase_admin
from firebase_admin import credentials, messaging
import os

app = FastAPI(title='Pulse Push Gateway')

firebase_path = os.getenv('FIREBASE_SERVICE_ACCOUNT', '/opt/swchat/push-gateway/firebase-service-account.json')

if not firebase_admin._apps:
    cred = credentials.Certificate(firebase_path)
    firebase_admin.initialize_app(cred)


@app.get('/health')
async def health():
    return {
        'status': 'ok',
        'service': 'pulse-push-gateway'
    }


@app.post('/_matrix/push/v1/notify')
async def notify(request: Request):
    body = await request.json()

    notifications = body.get('notification', {})
    devices = notifications.get('devices', [])

    sent = 0

    for device in devices:
        pushkey = device.get('pushkey')

        if not pushkey:
            continue

        message = messaging.Message(
            token=pushkey,
            notification=messaging.Notification(
                title='Pulse',
                body='Новое сообщение',
            ),
            data={
                'room_id': notifications.get('room_id', ''),
                'event_id': notifications.get('event_id', ''),
            }
        )

        try:
            messaging.send(message)
            sent += 1
        except Exception as e:
            print(f'[Pulse Push Gateway] Firebase send failed: {e}')

    return JSONResponse({
        'rejected': [],
        'sent': sent,
    })
