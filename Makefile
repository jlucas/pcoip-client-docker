.PHONY: build-nvidia build up down restart sh clean

NVIDIA_DRIVER_VERSION = $(shell awk '/NVRM/ {print $$8}'  /proc/driver/nvidia/version)

build-nvidia:
	sudo env NVIDIA_ENABLED=1 NVIDIA_DRIVER_VERSION=$(NVIDIA_DRIVER_VERSION) docker-compose build

build:
	sudo docker-compose build

up:
	test -S /tmp/pulseaudio.socket || pactl load-module module-native-protocol-unix socket=/tmp/pulseaudio.socket
	sudo docker-compose up -d

down:
	sudo docker-compose down

restart:
	sudo docker-compose restart

sh:
	sudo docker exec -it pcoip-client-docker_pcoip_appliance_1 /bin/bash

clean:
	sudo docker rmi pcoip_appliance
