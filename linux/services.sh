#!/bin/bash

# List of services to disable
services=("avahi-daemon" "cups" "bluetooth")

for service in "${services[@]}"; do
  sudo systemctl disable "$service"
  sudo systemctl stop "$service"
done

