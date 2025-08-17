# QL7 Bank Server

### Project Structure
- `backend/` - Node.js API (accounts, transactions, auth)
- `analytics/` - Python scripts (fraud detection, reporting)
- `scripts/` - DB initialization & maintenance
- `docs/` - API documentation

### Quick Start
```bash
docker-compose up --build
```
API Endpoints
Method	Path	Description
POST	/api/auth/login	User authentication
GET	/api/accounts	Get all accounts
POST	/api/transactions	Create transaction

Environment Variables
DB_URL=mongodb://localhost:27017/ql7bank
