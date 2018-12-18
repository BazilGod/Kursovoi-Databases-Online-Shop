CREATE TABLE client(
id NUMBER(38,0) NOT NULL,
name VARCHAR2(40) NOT NULL,
surname VARCHAR2(40) NOT NULL,
sex CHAR(2) NOT NULL,
email VARCHAR2(100) UNIQUE,
password VARCHAR2(60) NOT NULL,
status CHAR(10) DEFAULT 'SUSPENDED',
registration_date DATE DEFAULT SYSDATE
);
ALTER TABLE client add CONSTRAINT client_pk PRIMARY KEY (id);
ALTER TABLE client add CONSTRAINT email_unique UNIQUE (email) ;
ALTER TABLE client add CONSTRAINT client_sex_check CHECK (sex IN ('Ì', 'Æ'));
ALTER TABLE client add CONSTRAINT client_status_check CHECK (status IN ('ACTIVE', 'INIACTIVE', 'SUSPENDED'));
CREATE SEQUENCE client_sq start WITH 1 increment by 1 order nocache;
select * from all_constraints where owner='ADMIN' ;


CREATE TABLE product(
id NUMBER(38,0) NOT NULL,
name VARCHAR2(200) NOT NULL,
description VARCHAR2(1000) NOT NULL,
amount NUMBER(4,0) NOT NULL,
price NUMBER(12,2) NOT NULL,
discount NUMBER(4,2) DEFAULT 0,
status char(10) DEFAULT 'ACTIVE',
img BFILE,
iblob BLOB,
iclob CLOB
);
ALTER TABLE product add CONSTRAINT product_pk PRIMARY KEY(id);
ALTER TABLE product add CONSTRAINT status_check CHECK (status IN ('ACTIVE', 'INACTIVE'));
CREATE SEQUENCE product_sq start WITH 1 increment by 1 order  nocache;



CREATE TABLE basket(
id NUMBER(38,0) NOT NULL,
client_id NUMBER(38,0) NOT NULL,
product_id NUMBER(38,0) NOT NULL,
amount  NUMBER(4) NOT NULL,
created DATE DEFAULT SYSDATE
);

ALTER TABLE basket add CONSTRAINT basket_fk  FOREIGN KEY (client_id) REFERENCES client(id);
ALTER TABLE basket add CONSTRAINT basket_fk2  FOREIGN KEY (product_id) REFERENCES product(id) ;
ALTER TABLE basket add CONSTRAINT basket_pk PRIMARY KEY (id);
CREATE SEQUENCE basket_sq start WITH 1 increment by 1 order  nocache;


CREATE TABLE orders(
id NUMBER(38,0) NOT NULL,
client_id NUMBER(38,0) NOT NULL,
credit_cart char(2) NOT NULL,
total NUMBER(12,2) NOT NULL,
created DATE  DEFAULT SYSDATE 
);
ALTER TABLE orders add CONSTRAINT order_pk PRIMARY KEY(id);
ALTER TABLE orders add CONSTRAINT order_fk  FOREIGN KEY (client_id) REFERENCES client(id);
ALTER TABLE orders add CONSTRAINT credit_cart_check CHECK (credit_cart IN ('V', 'B', 'M'));
CREATE SEQUENCE orders_sq start with 1 increment by 1 order  nocache;

CREATE TABLE order_detail(
id NUMBER(38,0) NOT NULL,
order_id NUMBER(38,0) NOT NULL,
product_id NUMBER(38,0) NOT NULL,
amount NUMBER(4,0) NOT NULL,
total NUMBER(12, 2) NOT NULL
);
ALTER TABLE order_detail add CONSTRAINT order_detail_fk   FOREIGN KEY (order_id) REFERENCES orders(id);
ALTER TABLE order_detail add CONSTRAINT order_detail_fk2  FOREIGN KEY (product_id) REFERENCES product(id);
ALTER TABLE order_detail add CONSTRAINT order_detail_pk PRIMARY KEY (id);
CREATE SEQUENCE order_detail_sq start WITH 1 increment by 1 order  nocache;


drop SEQUENCE order_detail_sq;
drop SEQUENCE orders_sq;
drop SEQUENCE product_sq;
drop SEQUENCE client_sq;
drop SEQUENCE basket_sq;
drop table client;
drop table product;
drop table orders;
drop table order_detail;
drop table basket;
