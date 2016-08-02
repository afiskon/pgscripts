#!/bin/sh

ssh freebsd-kvm sudo date `date "+%Y%m%d%H%M.%S"`

rsync -e ssh --progress \
  --exclude '*.swp' \
  --exclude 'tags' \
  --exclude '.git' \
  -zutr /home/eax/work/postgrespro/postgresql-src freebsd-kvm:
