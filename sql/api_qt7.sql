-- Создание базы данных QL7_Bank
CREATE DATABASE IF NOT EXISTS QL7_Bank;
USE QL7_Bank;

-- Таблица пользователей
CREATE TABLE IF NOT EXISTS users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(20),
    full_name VARCHAR(100),
    date_of_birth DATE,
    registration_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    last_login DATETIME,
    is_active BOOLEAN DEFAULT TRUE,
    is_admin BOOLEAN DEFAULT FALSE
);

-- Таблица счетов
CREATE TABLE IF NOT EXISTS accounts (
    account_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    account_number VARCHAR(20) NOT NULL UNIQUE,
    account_type ENUM('checking', 'savings', 'credit', 'investment') NOT NULL,
    currency VARCHAR(3) DEFAULT 'RUB',
    balance DECIMAL(15, 2) DEFAULT 0.00,
    opened_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'frozen', 'closed') DEFAULT 'active',
    interest_rate DECIMAL(5, 2) DEFAULT 0.00,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Таблица транзакций
CREATE TABLE IF NOT EXISTS transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    amount DECIMAL(15, 2) NOT NULL,
    transaction_type ENUM('deposit', 'withdrawal', 'transfer', 'payment') NOT NULL,
    description VARCHAR(255),
    transaction_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status ENUM('pending', 'completed', 'failed', 'reversed') DEFAULT 'completed',
    recipient_account VARCHAR(20),
    reference_number VARCHAR(50),
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE
);

-- Таблица карт
CREATE TABLE IF NOT EXISTS cards (
    card_id INT AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    card_number VARCHAR(16) NOT NULL UNIQUE,
    card_holder VARCHAR(100) NOT NULL,
    expiry_date DATE NOT NULL,
    cvv VARCHAR(3) NOT NULL,
    card_type ENUM('debit', 'credit') NOT NULL,
    status ENUM('active', 'blocked', 'expired') DEFAULT 'active',
    daily_limit DECIMAL(15, 2),
    issued_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (account_id) REFERENCES accounts(account_id) ON DELETE CASCADE
);

-- Таблица API ключей
CREATE TABLE IF NOT EXISTS api_keys (
    key_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    api_key VARCHAR(64) NOT NULL UNIQUE,
    secret_key VARCHAR(64) NOT NULL,
    created_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATETIME,
    is_active BOOLEAN DEFAULT TRUE,
    permissions TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Таблица логов API запросов
CREATE TABLE IF NOT EXISTS api_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    api_key VARCHAR(64),
    endpoint VARCHAR(100) NOT NULL,
    request_method VARCHAR(10) NOT NULL,
    request_params TEXT,
    response_code INT NOT NULL,
    response_time INT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(45)
);

-- Создание индексов для улучшения производительности
CREATE INDEX idx_accounts_user_id ON accounts(user_id);
CREATE INDEX idx_transactions_account_id ON transactions(account_id);
CREATE INDEX idx_transactions_date ON transactions(transaction_date);
CREATE INDEX idx_cards_account_id ON cards(account_id);
CREATE INDEX idx_api_keys_user_id ON api_keys(user_id);
CREATE INDEX idx_api_logs_timestamp ON api_logs(timestamp);