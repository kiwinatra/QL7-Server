// Database configuration for QL7 Bank
const { Pool } = require('pg');
const dotenv = require('dotenv');

dotenv.config();

// Database connection pool configuration
const pool = new Pool({
  user: process.env.DB_USER || 'ql7_admin',
  host: process.env.DB_HOST || 'localhost',
  database: process.env.DB_NAME || 'ql7_bank',
  password: process.env.DB_PASSWORD || '',
  port: process.env.DB_PORT || 5432,
  max: 20, // max number of clients in the pool
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
  ssl: process.env.NODE_ENV === 'production' 
    ? { rejectUnauthorized: false } 
    : false
});

// Test database connection
pool.connect((err, client, release) => {
  if (err) {
    console.error('Error acquiring client', err.stack);
    process.exit(1);
  }
  client.query('SELECT NOW()', (err, result) => {
    release();
    if (err) {
      console.error('Error executing query', err.stack);
      return;
    }
    console.log('Database connected at:', result.rows[0].now);
  });
});

// Export query method for use in models
module.exports = {
  query: (text, params) => pool.query(text, params),
  getClient: () => pool.connect(),
  end: () => pool.end()
};