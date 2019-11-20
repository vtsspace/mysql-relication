# MySQL Replication Docker

We use docker to create 3 mysql host: 1 master, 2 slave. All dockers will be installed manual.

## Requirement

To start run MySQL replication by docker, we need install bellow items:

- Docker Engine
- Window/ Linux OS

## Install MySQL Host

Now we use Window OS so code block used `$(pwd)` as relative path. We will install 3 dockers.

```sh
docker run -d --name mysql_01 -e MYSQL_ROOT_PASSWORD=password -v "$(pwd)/config/mysql-master:/etc/mysql/conf.d/" -v "$(pwd)/data/mysql-master:/var/lib/mysql/" mysql
docker run -d --name mysql_02 -e MYSQL_ROOT_PASSWORD=password -v "$(pwd)/config/mysql-slave-01:/etc/mysql/conf.d/" -v "$(pwd)/data/mysql-slave-01:/var/lib/mysql/" mysql
docker run -d --name mysql_03 -e MYSQL_ROOT_PASSWORD=password -v "$(pwd)/config/mysql-slave-02:/etc/mysql/conf.d/" -v "$(pwd)/data/mysql-slave-02:/var/lib/mysql/" mysql
```

## Connecte Master & Slave

Now we 3 docker containers as each PC. We need know `ip` and account to use `sh`. Let see them when type:

```sh
docker ps
```

### Step 1:

Access 2 slave and reset slave.

```sh
docker exec -u root -it mysql_02 /bin/bash
mysql -uroot -ppassword -AN -e 'STOP SLAVE;'
mysql -uroot -ppassword -AN -e 'RESET SLAVE ALL;'
exit;
```

```sh
docker exec -u root -it mysql_03 /bin/bash
mysql -uroot -ppassword -AN -e 'STOP SLAVE;'
mysql -uroot -ppassword -AN -e 'RESET SLAVE ALL;'
exit
```

### Step 2:

Access **master** to create account and assigne it to replication.

```sh
docker exec -u root -it mysql_01 /bin/bash
mysql -uroot -ppassword -AN -e "CREATE USER 'rep_user'@'%' IDENTIFIED WITH mysql_native_password BY 'password';"
mysql -uroot -ppassword -AN -e "GRANT REPLICATION SLAVE ON *.* TO 'rep_user'@'%';"
mysql -uroot -ppassword -AN -e 'flush privileges;'
exit
```

### Step 3

Get master's informations

```sh
docker exec -u root -it mysql_01 /bin/bash
mysql -uroot -ppassword -e 'show master status \G'
getent hosts
exit
```

we need 3 infor: Postion, File. Please note them to use for setting replication.
File: mysql-bin.000003, Position: 833 -> 1081, IP: 172.17.0.2 - 30b6668d4366

# Step 4:

Get 2 slave informations

```sh
docker exec -u root -it mysql_02 /bin/bash
mysql -uroot -ppassword -e 'show master status \G'
exit
```

File: mysql-bin.000003, Position: 155

```sh
docker exec -u root -it mysql_03 /bin/bash
mysql -uroot -ppassword -e 'show master status \G'
exit
```

File: mysql-bin.000003, Position: 155

# Step 5:

Connect master and slave.

```sh
docker exec -u root -it mysql_02 /bin/bash
mysql -uroot -ppassword -AN -e "CHANGE MASTER TO master_host='172.17.0.2', master_port=3306, master_user='rep_user', master_password='password', master_log_file='mysql-bin.000003', master_log_pos=833;"
mysql -uroot -ppassword -AN -e "start slave;"
mysql -uroot -ppassword -AN -e 'set GLOBAL max_connections=2000';
mysql -uroot -ppassword -e 'show slave status \G'
exit
```

```sh
docker exec -u root -it mysql_03 /bin/bash
mysql -uroot -ppassword -AN -e "CHANGE MASTER TO master_host='172.17.0.2', master_port=3306, master_user='rep_user', master_password='password', master_log_file='mysql-bin.000003', master_log_pos=833;"
mysql -uroot -ppassword -AN -e "start slave;"
mysql -uroot -ppassword -AN -e 'set GLOBAL max_connections=2000';
mysql -uroot -ppassword -e 'show slave status \G'
exit
```
