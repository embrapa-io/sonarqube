#!/bin/sh

set -xe

apt update -y && apt upgrade -y && apt dist-upgrade -y && apt autoremove -y && apt autoclean -y

type docker > /dev/null 2>&1 || { echo >&2 "Command 'docker' has not found! Aborting."; exit 1; }

docker compose pull

docker compose stop

docker compose up --force-recreate --build --remove-orphans --wait
