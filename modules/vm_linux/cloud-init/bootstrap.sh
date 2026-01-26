#!/bin/bash
set -e
exec > /var/log/bootstrap.log 2>&1

echo "BOOTSTRAP STARTED $(date)" > /var/lib/bootstrap.done

source /etc/os-release

if command -v apt >/dev/null; then
  apt-get update
  apt-get install -y python3
  timedatectl set-timezone America/Sao_Paulo
elif command -v yum >/dev/null; then
  yum install -y python3
  timedatectl set-timezone America/Sao_Paulo
fi

echo "BOOTSTRAP FINISHED $(date)" >> /var/lib/bootstrap.done