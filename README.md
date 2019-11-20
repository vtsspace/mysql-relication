# MySQL Replication

Build MySQL replication between master and slave. Use docker to build mysql host. Need Docker Engine installed on PC. Docker compose will get `mysql`
image from Docker Hub.

## Requirement

Installed:
- Window/ Linux OS.
- Docker Engine 

## Setup with Docker

You can install each MySQL host in servers (PS) together. So you need copy-paste code to run it.

[Setup with Docker](./mysql-replication-docker/README.md)

## Setup with Docker Compose

But if you run master-slave in 1 server (PS), you can use Docker Compose.

[Setup with Docker Compose](./mysql-replication-docker-compose/README.md)