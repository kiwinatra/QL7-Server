import axios from"axios";class User{constructor(t,s,r,e,c,a){this.userID=t,this.username=s,this.email=r,this.phone=e,this.fullName=c,this.isAdmin=a}}class Account{constructor(t,s,r,e,c,a){this.accountID=t,this.userID=s,this.accountNumber=r,this.accountType=e,this.balance=c,this.currency=a}}class Transaction{constructor(t,s,r,e,c,a){this.transactionID=t,this.accountID=s,this.amount=r,this.transactionType=e,this.description=c,this.transactionDate=a}}class Card{constructor(t,s,r,e,c,a){this.cardID=t,this.accountID=s,this.cardNumber=r,this.cardHolder=e,this.expiryDate=c,this.cardType=a}}class APIKey{constructor(t,s,r,e){this.keyID=t,this.apiKey=s,this.secretKey=r,this.isActive=e}}class QL7APIError extends Error{constructor(t){super(t),this.name="QL7APIError"}}class QL7APIClient{constructor(t,s){this.baseURL="https://qt7.storage.drweb.link/__/api",this.apiKey=t,this.secretKey=s}async getUser(t){const s=`/users/${t}`;return this.performRequest(s,"GET")}async getUserAccounts(t){const s=`/users/${t}/accounts`;return this.performRequest(s,"GET")}async createAccount(t,s,r){const e={user_id:t,account_type:s,currency:r};return this.performRequest("/accounts","POST",e)}async getTransactions(t,s=null,r=null){let e=`/accounts/${t}/transactions`;return s&&r&&(e+=`?from=${s.toISOString()}&to=${r.toISOString()}`),this.performRequest(e,"GET")}async performRequest(t,s,r=null){try{return(await axios({method:s,url:`${this.baseURL}${t}`,data:r,headers:{Authorization:`Bearer ${this.apiKey}`,"Content-Type":"application/json"}})).data}catch(t){throw new QL7APIError(t.response?t.response.data:t.message)}}}
import{v4 as uuidv4}from"uuid";class Account{static schema="accounts";constructor(t=null,e,c,i,s,u,r){this.id=t||uuidv4(),this.accountNumber=e,this.balance=c,this.currency=i,this.type=s,this.status=u,this.userID=r,this.createdAt=new Date,this.updatedAt=new Date}}const AccountType={CHECKING:"checking",SAVINGS:"savings",CREDIT:"credit",DEPOSIT:"deposit",INVESTMENT:"investment"},AccountStatus={ACTIVE:"active",FROZEN:"frozen",CLOSED:"closed",RESTRICTED:"restricted"};class AccountMigration{async prepare(t){await t.schema(Account.schema).id().field("account_number","string",{required:!0}).field("balance","double",{required:!0}).field("currency","string",{required:!0}).field("type","string",{required:!0}).field("status","string",{required:!0}).field("user_id","uuid",{required:!0,references:{table:"users",column:"id"}}).field("created_at","datetime").field("updated_at","datetime").unique("account_number").create()}async revert(t){await t.schema(Account.schema).delete()}}class AccountCreate{constructor(t,e){this.type=t,this.currency=e}}class AccountPublic{constructor(t,e,c,i,s,u,r){this.id=t,this.accountNumber=e,this.balance=c,this.currency=i,this.type=s,this.status=u,this.createdAt=r}}Account.prototype.toPublic=function(){return new AccountPublic(this.id,this.accountNumber,this.balance,this.currency,this.type,this.status,this.createdAt)},Account.findByAccountNumber=async function(t,e){return await e.query(Account.schema).filter("account_number",t).first()},Account.getUserAccounts=async function(t,e){return await e.query(Account.schema).filter("user_id",t).all()};
import{v4 as uuidv4}from"uuid";class Transaction{static schema="transactions";constructor(t=null,e,a,s,n=TransactionStatus.pending,r=null,c,i){this.id=t||uuidv4(),this.amount=e,this.currency=a,this.type=s,this.status=n,this.description=r,this.senderAccountID=c,this.receiverAccountID=i,this.createdAt=new Date,this.processedAt=null}static async createTransfer(t,e,a,s,n=null,r){const c=new Transaction(null,t,e,TransactionType.transfer,TransactionStatus.pending,n,a.id,s.id);return await r.transaction((async e=>{await c.create(e),a.balance-=t,s.balance+=t,await a.save(e),await s.save(e),c.status=TransactionStatus.completed,c.processedAt=new Date,await c.save(e)})),c}static async getAccountTransactions(t,e){return await Transaction.query(e).orWhere("sender_account_id",t).orWhere("receiver_account_id",t).orderBy("created_at","desc").fetchAll()}}const TransactionType={transfer:"transfer",deposit:"deposit",withdrawal:"withdrawal",payment:"payment",fee:"fee",interest:"interest"},TransactionStatus={pending:"pending",completed:"completed",failed:"failed",cancelled:"cancelled",reversed:"reversed"};class TransactionMigration{async prepare(t){await t.schema.createTable(Transaction.schema,(t=>{t.uuid("id").primary(),t.double("amount").notNullable(),t.string("currency").notNullable(),t.string("type").notNullable(),t.string("status").notNullable(),t.string("description"),t.uuid("sender_account_id").notNullable().references("accounts.id"),t.uuid("receiver_account_id").notNullable().references("accounts.id"),t.datetime("created_at"),t.datetime("processed_at")}))}async revert(t){await t.schema.dropTable(Transaction.schema)}}class TransactionCreate{constructor(t,e,a,s=null,n){this.amount=t,this.currency=e,this.type=a,this.description=s,this.receiverAccountNumber=n}}class TransactionPublic{constructor(t,e,a,s,n,r,c,i,o,u){this.id=t,this.amount=e,this.currency=a,this.type=s,this.status=n,this.description=r,this.senderAccountNumber=c,this.receiverAccountNumber=i,this.createdAt=o,this.processedAt=u}static fromTransaction(t,e,a){return new TransactionPublic(t.id,t.amount,t.currency,t.type,t.status,t.description,e,a,t.createdAt,t.processedAt)}}
import express from 'express';
import jwt from 'jsonwebtoken';

const apiBaseURL = "https://ql7.storage.drweb.link/__/";
const publicRoutes = ["/auth/login", "/auth/register", "/health"];

const authMiddleware = async (req, res, next) => {
    if (publicRoutes.includes(req.path)) {
        return next();
    }

    const authHeader = req.headers['authorization'];
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ reason: "Требуется авторизация: Bearer <token>" });
    }

    const token = authHeader.split(' ')[1];
    const isValid = await validateToken(token, req);
    if (!isValid) {
        return res.status(401).json({ reason: "Недействительный токен" });
    }

    const user = await fetchUserData(token, req);
    req.user = user; 
    next();
};

const validateToken = async (token, req) => {
    const response = await fetch(apiBaseURL, {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json'
        }
    });

    if (response.status !== 200) {
        return false;
    }

    const data = await response.json();
    return data.isValid;
};

const fetchUserData = async (token, req) => {
    const userInfoURL = "https:";
    const response = await fetch(userInfoURL, {
        method: 'GET',
        headers: {
            'Authorization': `Bearer ${token}`
        }
    });

    if (response.status !== 200) {
        throw new Error("Не удалось получить данные пользователя");
    }

    return await response.json();
};

class AuthenticatedUser {
    constructor(id, email, roles, accounts) {
        this.id = id;
        this.email = email;
        this.roles = roles;
        this.accounts = accounts;
    }

    get isAdmin() {
        return this.roles.includes(UserRole.admin);
    }
}

const UserRole = {
    user: 'user',
    admin: 'admin',
    support: 'support'
};

const app = express();

app.get("/accounts", authMiddleware, async (req, res) => {
    const user = req.user;
    const accounts = await Account.query().filter(account => account.userID === user.id).all();
    res.json(accounts);
});

app.post("/admin/accounts", authMiddleware, async (req, res) => {
    const admin = req.user;
    if (!admin.isAdmin) {
        return res.status(403).json({ reason: "Недостаточно прав" });
    }
    res.status(201).send();
});