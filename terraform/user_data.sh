#!/bin/bash
sudo cp /home/ubuntu/.ssh/authorized_keys /root/.ssh/authorized_keys
deluser --remove-home ubuntu
