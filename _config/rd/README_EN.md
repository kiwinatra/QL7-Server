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


![версия](https://img.shields.io/badge/version-1.5.4-blue)
![лицензия](https://img.shields.io/badge/license-MIT-green)
![статус](https://img.shields.io/badge/status-in%20developement-yellow)
![тесты](https://img.shields.io/badge/tests-85%25-success)
![размер](https://img.shields.io/badge/Disk%20usage-240KB-informational)

---
![Python](https://img.shields.io/badge/CSharp-3.10+-blue?logo=c#)
![Django](https://img.shields.io/badge/SQL-4.2-brightgreen?logo=sql)
![PostgreSQL](https://img.shields.io/badge/SW-15-informational?logo=swift)
</div>
<div align="center">

## System architecture

</div>

```mermaid
graph TD
    A[Mobile/PC app] --> B{API Gateway}
    B --> C[Authorization server]
    B --> D[Payment server]
    B --> E[Invest server]
    C --> F[(Users DB)]
    D --> G[(Transactions DB)]
    E --> H[(Analitics DB)]
    D --> I[Other crypto services]
    E --> J[Other API]
```

<div align="center">

## 🚀 How to set up
</div>

1. Install docker_rs:
```bash
docker run -d --name ql7-scanner \
  -e API_KEY=your-key \
  -v /path/to/code:/scann \
  ql7bank/scanner:latest
```

2. Set up integrations:
```mermaid
graph LR
    A[Analize] --> B[GitHub Actions]
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
