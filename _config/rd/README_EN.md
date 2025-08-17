<div align="center">

# QL7 Bank Server + API

![QL7 Logo](data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLWdpdGh1Yi1pY29uIGx1Y2lkZS1naXRodWIiPjxwYXRoIGQ9Ik0xNSAyMnYtNGE0LjggNC44IDAgMCAwLTEtMy41YzMgMCA2LTIgNi01LjUuMDgtMS4yNS0uMjctMi40OC0xLTMuNS4yOC0xLjE1LjI4LTIuMzUgMC0zLjUgMCAwLTEgMC0zIDEuNS0yLjY0LS41LTUuMzYtLjUtOCAwQzYgMiA1IDIgNSAyYy0uMyAxLjE1LS4zIDIuMzUgMCAzLjVBNS40MDMgNS40MDMgMCAwIDAgNCA5YzAgMy41IDMgNS41IDYgNS41LS4zOS40OS0uNjggMS4wNS0uODUgMS42NS0uMTcuNi0uMjIgMS4yMy0uMTUgMS44NXY0Ii8+PHBhdGggZD0iTTkgMThjLTQuNTEgMi01LTItNy0yIi8+PC9zdmc+)
![версия](https://img.shields.io/badge/version-1.5.4-blue)
![лицензия](https://img.shields.io/badge/license-MIT-green)
![статус](https://img.shields.io/badge/status-in%20developement-yellow)
![тесты](https://img.shields.io/badge/tests-85%25-success)
![размер](https://img.shields.io/badge/Disk%20usage-240KB-informational)
![QL7 Logo](data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHdpZHRoPSIyNCIgaGVpZ2h0PSIyNCIgdmlld0JveD0iMCAwIDI0IDI0IiBmaWxsPSJub25lIiBzdHJva2U9ImN1cnJlbnRDb2xvciIgc3Ryb2tlLXdpZHRoPSIyIiBzdHJva2UtbGluZWNhcD0icm91bmQiIHN0cm9rZS1saW5lam9pbj0icm91bmQiIGNsYXNzPSJsdWNpZGUgbHVjaWRlLXNwYXJrbGVzLWljb24gbHVjaWRlLXNwYXJrbGVzIj48cGF0aCBkPSJNMTEuMDE3IDIuODE0YTEgMSAwIDAgMSAxLjk2NiAwbDEuMDUxIDUuNTU4YTIgMiAwIDAgMCAxLjU5NCAxLjU5NGw1LjU1OCAxLjA1MWExIDEgMCAwIDEgMCAxLjk2NmwtNS41NTggMS4wNTFhMiAyIDAgMCAwLTEuNTk0IDEuNTk0bC0xLjA1MSA1LjU1OGExIDEgMCAwIDEtMS45NjYgMGwtMS4wNTEtNS41NThhMiAyIDAgMCAwLTEuNTk0LTEuNTk0bC01LjU1OC0xLjA1MWExIDEgMCAwIDEgMC0xLjk2Nmw1LjU1OC0xLjA1MWEyIDIgMCAwIDAgMS41OTQtMS41OTR6Ii8+PHBhdGggZD0iTTIwIDJ2NCIvPjxwYXRoIGQ9Ik0yMiA0aC00Ii8+PGNpcmNsZSBjeD0iNCIgY3k9IjIwIiByPSIyIi8+PC9zdmc+)
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
