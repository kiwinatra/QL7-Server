## P.S. все это не будет работать без разрешения на использования API на домен.



# Документация API
## Базовый URL
'https://ql7.storage.drweb.link/__/api'

## Аутентификация
### Все запросы должны содержать заголовки:

X-API-KEY: Ваш API ключ

X-API-TIMESTAMP: Текущий UNIX timestamp

X-API-SIGNATURE: Подпись запроса (HMAC-SHA256)

### Основные конечные точки
#### Пользователи

```bash
GET /users/{user_id} - Получить информацию о пользователе
```

### Счета

```bash
GET /users/{user_id}/accounts - Получить все счета пользователя
```
```bash
POST /accounts - Создать новый счет
```

```json
{
  "user_id": 123,
  "account_type": "checking",
  "currency": "RUB"
}
```
Транзакции

```bash GET /accounts/{account_id}/transactions - История транзакций

POST /transactions/transfer - Выполнить перевод```

```json
{
  "from_account_id": 456,
  "to_account_number": "7890123456",
  "amount": 1000.00,
  "description": "Оплата услуг"
}
```
Обработка ошибок
В случае ошибки API возвращает JSON с описанием:

```json
{
  "error": true,
  "message": "Описание ошибки",
  "code": "Код ошибки"
}
```