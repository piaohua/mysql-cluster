#!/bin/bash

set -e

pull() {
    docker pull mysql/mysql-cluster:8.0.17
}

start() {
    # network
    docker network create cluster --subnet=192.168.0.0/16
    # management node
    docker run -d --net=cluster --name=management1 --ip=192.168.0.2 mysql/mysql-cluster:8.0.17 ndb_mgmd
    # two data node
    docker run -d --net=cluster --name=ndb1 --ip=192.168.0.3 mysql/mysql-cluster:8.0.17 ndbd
    docker run -d --net=cluster --name=ndb2 --ip=192.168.0.4 mysql/mysql-cluster:8.0.17 ndbd
    # server node
    docker run -d --net=cluster --name=mysql1 --ip=192.168.0.10 -e MYSQL_RANDOM_ROOT_PASSWORD=true mysql/mysql-cluster:8.0.17 mysqld
    # change password
    #docker logs mysql1 2>&1 | grep PASSWORD
    #docker exec -it mysql1 mysql -uroot -p
    #ALTER USER 'root'@'localhost' IDENTIFIED BY 'MyNewPass';
    # verify
    #docker run -it --net=cluster mysql/mysql-cluster ndb_mgm

    #docker run -it -v "${PWD}/cnf/my.cnf":/etc/my.cnf -v "${PWD}/cnf/mysql-cluster.cnf":/etc/mysql-cluster.cnf --net=mysql-cluster_mysql_cluster_net mysql/mysql-cluster:8.0.17 ndb_mgm
    # 查看集群信息
    # ndb_mgm> show
    # 查看集群内存使用情况
    # ndb_mgm> all report memoryusage;

}

memory() {
    # 查看集群内存使用情况
    docker run -it -v "${PWD}/cnf/my.cnf":/etc/my.cnf -v "${PWD}/cnf/mysql-cluster.cnf":/etc/mysql-cluster.cnf --net=mysql-cluster_mysql_cluster_net mysql/mysql-cluster:8.0.17 ndb_mgm -e 'all report memoryusage'
}

show() {
    # 查看集群信息
    docker run -it -v "${PWD}/cnf/my.cnf":/etc/my.cnf -v "${PWD}/cnf/mysql-cluster.cnf":/etc/mysql-cluster.cnf --net=mysql-cluster_mysql_cluster_net mysql/mysql-cluster:8.0.17 ndb_mgm -e 'show'
}

stop() {
    # 关闭集群
    docker run -it -v "${PWD}/cnf/my.cnf":/etc/my.cnf -v "${PWD}/cnf/mysql-cluster.cnf":/etc/mysql-cluster.cnf --net=mysql-cluster_mysql_cluster_net mysql/mysql-cluster:8.0.17 ndb_mgm -e 'shutdown'
}

console() {
    docker exec -it mysql2 mysql -uroot -p
    #mysql> create table test(id int(10) not null, name varchar(50) not null, primary key (id)) engine=ndbcluster;
    #mysql> insert into test values(1, '111');

    #docker exec -it mysql1 mysql -uroot -p
    #mysql> select * from test;
}

up() {
    docker-compose -f docker-compose.yml up -d
}

ps() {
    docker-compose ps
}

down() {
    docker-compose down
}

case $1 in
    start)
        start;;
    stop)
        stop;;
    pull)
        pull;;
    up)
        up;;
    ps)
        ps;;
    down)
        down;;
    show)
        show;;
    memory)
        memory;;
    console)
        console;;
    *)
        echo "./run.sh pull|start|stop|console|up"
esac
