JWT: {
    SECRET: process.env.JWT_SECRET || '',
    EXPIRES_IN: process.env.JWT_EXPIRES_IN || '24h',
    ALGORITHM: process.env.JWT_ALGORITHM || 'HS256'
  },