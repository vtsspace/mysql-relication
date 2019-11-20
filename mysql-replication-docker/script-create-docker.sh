##### Run MySQL Docker in Window

# create master
docker run -d --name mysql_01 -e MYSQL_ROOT_PASSWORD=password -v "$(pwd)/config/mysql-master:/etc/mysql/conf.d/" -v "$(pwd)/data/mysql-master:/var/lib/mysql/" mysql
# create slave
docker run -d --name mysql_02 -e MYSQL_ROOT_PASSWORD=password -v "$(pwd)/config/mysql-slave-01:/etc/mysql/conf.d/" -v "$(pwd)/data/mysql-slave-01:/var/lib/mysql/" mysql
docker run -d --name mysql_03 -e MYSQL_ROOT_PASSWORD=password -v "$(pwd)/config/mysql-slave-02:/etc/mysql/conf.d/" -v "$(pwd)/data/mysql-slave-02:/var/lib/mysql/" mysql

