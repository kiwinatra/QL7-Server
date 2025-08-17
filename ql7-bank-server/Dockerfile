# Node.js API for QL7 Bank
FROM node:18-alpine

WORKDIR /app

# Install dependencies first for caching
COPY backend/package*.json ./
RUN npm install --production

# Copy application source
COPY backend/ .

# Environment variables
ENV NODE_ENV=production
ENV PORT=3000

# Expose API port
EXPOSE 3000

# Start the application
CMD ["node", "src/app.js"]