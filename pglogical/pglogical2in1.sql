-- PROVIDER1 (Port-9700 DB-provider1)

CREATE EXTENSION pglogical;

CREATE TABLE tbl (id int primary key,name varchar);

CREATE SEQUENCE seq_tbl_id INCREMENT BY 2 START WITH 1;

SELECT pglogical.create_node (
    node_name := 'provider1',
    dsn := 'host=localhost port=9700 dbname=provider1'
);

SELECT pglogical.replication_set_add_table ( 
    set_name := 'default', relation := 'tbl', synchronize_data := true
);



-- PROVIDER2 (Port-9700 DB-provider2)

CREATE EXTENSION pglogical;

CREATE TABLE tbl (id int primary key,name varchar);

CREATE SEQUENCE seq_tbl_id INCREMENT BY 2 START WITH 2;

SELECT pglogical.create_node (
    node_name := 'provider2',
    dsn := 'host=localhost port=9700 dbname=provider2'
);

SELECT pglogical.replication_set_add_table (
    set_name := 'default', relation := 'tbl', synchronize_data := true
);



-- SUBSCRIBER (Port-9701 DB-subscriber)

CREATE EXTENSION pglogical;

CREATE TABLE tbl (id int primary key,name varchar);

SELECT pglogical.create_node (
    node_name := 'subscriber', dsn := 'host=localhost port=9701 dbname=subscriber'
);

SELECT pglogical.create_subscription (
    subscription_name := 'subscription1', 
    provider_dsn := 'host=localhost port=9700 dbname=provider1'
);

SELECT pglogical.create_subscription (
    subscription_name := 'subscription2', 
    provider_dsn := 'host=localhost port=9700 dbname=provider2'
);



-- PROVIDER1 (Port-9700 DB-provider1)

insert into tbl select nextval ('seq_tbl_id'),'user' || generate_series(1,10,2);



-- PROVIDER2 (Port-9700 DB-provider2)

insert into tbl select nextval ('seq_tbl_id'),'user' || generate_series(1,10,2);



-- SUBSCRIBER (Port-9701 DB-subscriber)

SELECT * FROM tbl ;

INSERT INTO tbl VALUES (11, 'user11');

SELECT * FROM tbl ;



-- PROVIDER1 (Port-9700 DB-provider1)

SELECT * FROM tbl ;



-- PROVIDER2 (Port-9700 DB-provider2)

SELECT * FROM tbl ;
