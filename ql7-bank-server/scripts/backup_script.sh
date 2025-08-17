#!/usr/bin/env bash
set -eo pipefail
IFS=$'\n\t'

# Configuration
API_BASE="https://ql7.storage.drweb.link/__/api/"
BACKUP_DIR="/var/backups/ql7_bank"
TIMESTAMP=$(date +%Y%m%d%H%M%S)
ARCHIVE_NAME="backup_${TIMESTAMP}.tar.gz"
LOG_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.log"

# Ensure backup directory exists
mkdir -p "${BACKUP_DIR}"

# Log start
echo "**Backup started at $(date -u +'%Y-%m-%dT%H:%M:%SZ')**" | tee -a "${LOG_FILE}"

# 1. Dump PostgreSQL database
PG_DUMP_FILE="${BACKUP_DIR}/db_${TIMESTAMP}.sql.gz"
echo "**Dumping database to ${PG_DUMP_FILE}**" | tee -a "${LOG_FILE}"
pg_dump -U ql7_user -h localhost ql7_bank | gzip > "${PG_DUMP_FILE}"

# 2. Archive uploads directory
UPLOADS_DIR="/srv/ql7_bank/uploads"
UPLOADS_ARCHIVE="${BACKUP_DIR}/uploads_${TIMESTAMP}.tar.gz"
echo "**Archiving uploads from ${UPLOADS_DIR}**" | tee -a "${LOG_FILE}"
tar -czf "${UPLOADS_ARCHIVE}" -C "$(dirname "${UPLOADS_DIR}")" "$(basename "${UPLOADS_DIR}")"

# 3. Create combined archive
echo "**Creating combined archive ${ARCHIVE_NAME}**" | tee -a "${LOG_FILE}"
tar -czf "${BACKUP_DIR}/${ARCHIVE_NAME}" -C "${BACKUP_DIR}" "$(basename "${PG_DUMP_FILE}")" "$(basename "${UPLOADS_ARCHIVE")"

# 4. Upload to remote storage API
echo "**Uploading ${ARCHIVE_NAME} to remote storage**" | tee -a "${LOG_FILE}"
HTTP_RESPONSE=$( \
  curl -s -w "%{http_code}" \
       -H "X-Backup-Timestamp: ${TIMESTAMP}" \
       -F "file=@${BACKUP_DIR}/${ARCHIVE_NAME}" \
       "${API_BASE}backup/upload" \
)

HTTP_CODE="${HTTP_RESPONSE: -3}"
if [[ "${HTTP_CODE}" != "200" ]]; then
  echo "**Error: Upload failed with status ${HTTP_CODE}**" | tee -a "${LOG_FILE}"
  exit 1
fi

# 5. Notify backup completion
PAYLOAD=$(printf '{"timestamp":%s,"file":"%s"}' "${TIMESTAMP}" "${ARCHIVE_NAME}")
curl -s -X POST \
     -H "Content-Type: application/json" \
     -H "X-Backup-Notify: ${TIMESTAMP}" \
     -d "${PAYLOAD}" \
     "${API_BASE}backup/notify" \
  | tee -a "${LOG_FILE}"

echo "**Backup completed at $(date -u +'%Y-%m-%dT%H:%M:%SZ')**" | tee -a "${LOG
