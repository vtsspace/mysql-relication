## show IDs of docker container.
docker ps

# == Step 1.
# Disable slave of 2 slaves.

## Acces Docker `mysql_slave_02`
docker exec -u root -it mysql_02 /bin/bash
mysql -uroot -ppassword -AN -e 'STOP SLAVE;'
mysql -uroot -ppassword -AN -e 'RESET SLAVE ALL;'
exit

## Acces Docker `mysql_slave_03`
docker exec -u root -it mysql_03 /bin/bash
mysql -uroot -ppassword -AN -e 'STOP SLAVE;'
mysql -uroot -ppassword -AN -e 'RESET SLAVE ALL;'
exit


# == Step 2
# Create account in master to replication
docker exec -u root -it mysql_01 /bin/bash
mysql -uroot -ppassword -AN -e "CREATE USER 'rep_user'@'%' IDENTIFIED WITH mysql_native_password BY 'password';"
mysql -uroot -ppassword -AN -e "GRANT REPLICATION SLAVE ON *.* TO 'rep_user'@'%';"
mysql -uroot -ppassword -AN -e 'flush privileges;'
exit


# == Step 3
# Get master's informations
docker exec -u root -it mysql_01 /bin/bash
mysql -uroot -ppassword -e 'show master status \G'
getent hosts
# we need 3 infor: Postion, File. Please note them to use for setting replication.
# File: mysql-bin.000003, Position: 833 -> 1081, IP: 172.17.0.2 - 30b6668d4366
exit


# == Step 4
# Get 2 slave informations
docker exec -u root -it mysql_02 /bin/bash
mysql -uroot -ppassword -e 'show master status \G'
#  File: mysql-bin.000003, Position: 155
exit
docker exec -u root -it mysql_03 /bin/bash
mysql -uroot -ppassword -e 'show master status \G'
# File: mysql-bin.000003, Position: 155
exit

# == Step 5
# Connect master and slave
docker exec -u root -it mysql_02 /bin/bash
mysql -uroot -ppassword -AN -e "CHANGE MASTER TO master_host='172.17.0.2', master_port=3306, master_user='rep_user', master_password='password', master_log_file='mysql-bin.000003', master_log_pos=833;"
mysql -uroot -ppassword -AN -e "start slave;"
mysql -uroot -ppassword -AN -e 'set GLOBAL max_connections=2000';
mysql -uroot -ppassword -e 'show slave status \G'
exit
docker exec -u root -it mysql_03 /bin/bash
mysql -uroot -ppassword -AN -e "CHANGE MASTER TO master_host='172.17.0.2', master_port=3306, master_user='rep_user', master_password='password', master_log_file='mysql-bin.000003', master_log_pos=833;"
mysql -uroot -ppassword -AN -e "start slave;"
mysql -uroot -ppassword -AN -e 'set GLOBAL max_connections=2000';
mysql -uroot -ppassword -e 'show slave status \G'
exit
