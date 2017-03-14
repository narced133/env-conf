#!/usr/bin/env bash
set -eux

BACKUP_NAME=`date -u +'app-list-backup.%Y-%m-%dT%H%M%SZ.txt'`
BACKUP_PATH="{{ backup_dir }}/$BACKUP_NAME"
API_UPLOAD_URL="https://api-content.dropbox.com/2/files/upload"
export HOME="{{ home_dir }}"

# Dump lists to a file in the backup dir
date -u +'App list backup at %Y-%m-%dT%H%M%SZ' > $BACKUP_PATH

echo -e "\n=== /Applications ===" >> $BACKUP_PATH
ls /Applications >> $BACKUP_PATH

echo -e "\n=== {{ home_dir }}/Applications ===" >> $BACKUP_PATH
ls "{{ home_dir }}/Applications/" >> $BACKUP_PATH

echo -e "\n=== brew list ===" >> $BACKUP_PATH
sudo -u "{{user}}" /usr/local/bin/brew list >> $BACKUP_PATH

echo -e "\n=== brew info ===" >> $BACKUP_PATH
sudo -u "{{user}}" /usr/local/bin/brew info --json=v1 --installed | python -m json.tool >> $BACKUP_PATH

# Upload to Dropbox
/usr/bin/curl "$API_UPLOAD_URL" \
    --upload-file "$BACKUP_PATH" \
    --globoff \
    --include \
    --silent \
    --request POST \
    --header "Authorization: Bearer {{ dropbox_access_token }}" \
    --header "Dropbox-API-Arg: {\"path\": \"/$BACKUP_NAME\"}" \
    --header "Content-Type: application/octet-stream"
