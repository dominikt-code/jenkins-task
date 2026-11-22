#!/bin/bash
dnf install -y docker
systemctl enable --now docker
docker run -d --name jenkins -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home jenkins/jenkins:lts