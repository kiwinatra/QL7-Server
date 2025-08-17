<div align="center">

# QL7 Bank Server + API
<h2 align="center">🌍 Language / Язык</h2>  
<p align="center">  
  <a href="https://github.com/kiwinatra/QL7-Server/blob/main/_config/rd/README_EN.md" style="text-decoration: none;">  
    <img src="https://flagicons.lipis.dev/flags/4x3/gb.svg" alt="English" width="30" height="20" style="vertical-align: middle;">  
    <span style="font-size: 1.1em; margin-left: 5px; vertical-align: middle;"><strong>English</strong></span>  
  </a>  
  <span style="margin: 0 10px; color: #ccc;">|</span>  
  <a href="https://github.com/kiwinatra/QL7-Server/blob/main/README.md" style="text-decoration: none;">  
    <img src="https://flagicons.lipis.dev/flags/4x3/ru.svg" alt="Русский" width="30" height="20" style="vertical-align: middle;">  
    <span style="font-size: 1.1em; margin-left: 5px; vertical-align: middle;"><strong>Русский</strong></span>  
  </a>  
</p>  

![версия](https://img.shields.io/badge/версия-1.5.4-blue)
![лицензия](https://img.shields.io/badge/лицензия-MIT-green)
![статус](https://img.shields.io/badge/статус-в%20разработке-yellow)
![тесты](https://img.shields.io/badge/тесты-85%25-success)
![размер](https://img.shields.io/badge/размер-240KB-informational)

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

