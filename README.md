<div align="center">

# QL7 Bank Server + API

![QL7 Logo](data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLWdpdGh1Yi1pY29uIGx1Y2lkZS1naXRodWIiPjxwYXRoIGQ9Ik0xNSAyMnYtNGE0LjggNC44IDAgMCAwLTEtMy41YzMgMCA2LTIgNi01LjUuMDgtMS4yNS0uMjctMi40OC0xLTMuNS4yOC0xLjE1LjI4LTIuMzUgMC0zLjUgMCAwLTEgMC0zIDEuNS0yLjY0LS41LTUuMzYtLjUtOCAwQzYgMiA1IDIgNSAyYy0uMyAxLjE1LS4zIDIuMzUgMCAzLjVBNS40MDMgNS40MDMgMCAwIDAgNCA5YzAgMy41IDMgNS41IDYgNS41LS4zOS40OS0uNjggMS4wNS0uODUgMS42NS0uMTcuNi0uMjIgMS4yMy0uMTUgMS44NXY0Ii8+PHBhdGggZD0iTTkgMThjLTQuNTEgMi01LTItNy0yIi8+PC9zdmc+)
![версия](https://img.shields.io/badge/версия-1.5.4-blue)
![лицензия](https://img.shields.io/badge/лицензия-MIT-green)
![статус](https://img.shields.io/badge/статус-в%20разработке-yellow)
![тесты](https://img.shields.io/badge/тесты-85%25-success)
![размер](https://img.shields.io/badge/размер-240KB-informational)
![QL7 Logo](data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXNwYXJrbGVzLWljb24gbHVjaWRlLXNwYXJrbGVzIj48cGF0aCBkPSJNMTEuMDE3IDIuODE0YTEgMSAwIDAgMSAxLjk2NiAwbDEuMDUxIDUuNTU4YTIgMiAwIDAgMCAxLjU5NCAxLjU5NGw1LjU1OCAxLjA1MWExIDEgMCAwIDEgMCAxLjk2NmwtNS41NTggMS4wNTFhMiAyIDAgMCAwLTEuNTk0IDEuNTk0bC0xLjA1MSA1LjU1OGExIDEgMCAwIDEtMS45NjYgMGwtMS4wNTEtNS41NThhMiAyIDAgMCAwLTEuNTk0LTEuNTk0bC01LjU1OC0xLjA1MWExIDEgMCAwIDEgMC0xLjk2Nmw1LjU1OC0xLjA1MWEyIDIgMCAwIDAgMS41OTQtMS41OTR6Ii8+PHBhdGggZD0iTTIwIDJ2NCIvPjxwYXRoIGQ9Ik0yMiA0aC00Ii8+PGNpcmNsZSBjeD0iNCIgY3k9IjIwIiByPSIyIi8+PC9zdmc+)
---
![Python](https://img.shields.io/badge/CSharp-3.10+-blue?logo=c#)
![Django](https://img.shields.io/badge/SQL-4.2-brightgreen?logo=sql)
![PostgreSQL](https://img.shields.io/badge/SW-15-informational?logo=swift)
</div>
<div align="center">

## Архитектура системы

</div>

```mermaid
graph TD
    A[Мобильное приложение] --> B{API Gateway}
    B --> C[Сервис авторизации]
    B --> D[Платежный сервис]
    B --> E[Инвестиционный сервис]
    C --> F[(База данных пользователей)]
    D --> G[(Транзакционная БД)]
    E --> H[(Аналитическая БД)]
    D --> I[Внешние платежные системы]
    E --> J[Биржевые API]
```
<div align="center">

## 🔍 Многоуровневая система анализа

</div>

```mermaid
graph LR
    A[SW-файлы] --> B[Лексический анализ]
    B --> C[Синтаксический анализ]
    C --> D[Семантический анализ]
    D --> E[Отчет об уязвимостях]
    E --> F[(Блокировка угроз)]
    E --> G[(Уведомление Security Ops)]
```
<div align="center">

## 🛠 Технологический стек

</div>

| Компонент       | Технологии                     |
|----------------|-------------------------------|
| Бэкенд         | .NET 6, ASP.NET Core, EF Core |
| Фронтенд       | Tailwind CSS, Alpine.js       |
| Анализатор     | Roslyn, ANTLR, Regex          |
| Инфраструктура | Docker, Kubernetes, Azure     |
| Мониторинг     | Prometheus, Grafana           |

<div align="center">

## 🛡 Защитные механизмы

</div>

1. **Статический анализ кода** (SAST)
   - Поиск инъекций (SQL, OS, Template)
   - Обнаружение hardcoded credentials
   - Анализ зависимостей (SCA)

2. **Динамическая защита** (RASP)
   - Блокировка подозрительных запросов
   - Защита от перебора (rate limiting)
   - Контроль целостности кода

3. **Шифрование данных**
   ```mermaid
   graph LR
       A[Данные] --> B[AES-256]
       B --> C[Хранилище]
       C --> D[Токенизация]
       D --> E[Анонимизация]
   ```
<div align="center">

## 📊 Метрики безопасности
</div>

| Показатель               | Целевое значение |
|-------------------------|-----------------|
| Покрытие кода тестами   | ≥85%            |
| Время реагирования      | <15 мин         |
| False positive rate     | <5%             |
| Критические уязвимости  | 0               |

<div align="center">

## 🚀 Как внедрить
</div>

1. Установите агент анализатора:
```bash
docker run -d --name ql7-scanner \
  -e API_KEY=your-key \
  -v /path/to/code:/scann \
  ql7bank/scanner:latest
```

2. Настройте интеграции:
```mermaid
graph LR
    A[Анализатор] --> B[GitHub Actions]
    A --> C[GitLab CI]
    A --> D[Jenkins]
    A --> E[Azure DevOps]
```

3. Настройте оповещения:
```yaml
notifications:
  slack: security-alerts
  email: soc@company.com
  sms: +79001234567
```
