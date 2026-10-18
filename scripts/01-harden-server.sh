#!/usr/bin/env bash
# Запуск от root ОДИН раз на чистом Ubuntu 22.04+. Перед запуском положите свой публичный ключ в PUBKEY.
set -euo pipefail
USER_NAME=agent
PUBKEY="${PUBKEY:?export PUBKEY='ssh-ed25519 AAAA...'}"

apt-get update && apt-get -y upgrade
adduser --disabled-password --gecos "" "$USER_NAME"
usermod -aG sudo "$USER_NAME"
install -d -m 700 -o "$USER_NAME" -g "$USER_NAME" /home/$USER_NAME/.ssh
echo "$PUBKEY" > /home/$USER_NAME/.ssh/authorized_keys
chown "$USER_NAME:$USER_NAME" /home/$USER_NAME/.ssh/authorized_keys
chmod 600 /home/$USER_NAME/.ssh/authorized_keys

# вход только по ключу, без root
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
systemctl restart ssh

# firewall: входящий только SSH
apt-get -y install ufw
ufw default deny incoming; ufw default allow outgoing
ufw allow OpenSSH; ufw --force enable
echo "Готово. Проверьте вход: ssh $USER_NAME@<ip> в НОВОМ окне, прежде чем закрывать root-сессию."
