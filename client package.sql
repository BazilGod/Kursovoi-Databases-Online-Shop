
CREATE OR REPLACE PACKAGE PKG_EXCEPTION IS

 EMAIL_NOT_FOUND      	EXCEPTION;
 EMAIL_FOUND         	EXCEPTION;
 CLIENT_FOUND     		EXCEPTION;
 CLIENT_NOT_FOUND    	EXCEPTION;
 PRODUCT_FOUND      	EXCEPTION;
 PRODUCT_NOT_FOUND   	EXCEPTION;
 BASKET_FOUND       		EXCEPTION;
 BASKET_NOT_FOUND    	EXCEPTION;  
 ORDERS_credit_cart_NOT_FOUND  	EXCEPTION;
 BASKET_0_product        EXCEPTION;        
 INBASKET_0_product        EXCEPTION;   
Add_unnormal_amout        EXCEPTION;  
  BASKET_toomany_product  EXCEPTION;
  Product_0_product        EXCEPTION;
END PKG_EXCEPTION;

CREATE OR REPLACE PACKAGE pkgclient IS
FUNCTION logging(in_email in client.email%type,in_password in client.password%type ) RETURN client.id%type;
PROCEDURE pl(in_txt IN varchar2);
 FUNCTION identificador_existe(in_table_name IN VARCHAR2, in_column_name IN VARCHAR2,  in_int IN NUMBER, in_string IN VARCHAR2) RETURN BOOLEAN;
 PROCEDURE add_client(in_name in client.name%type, in_surname in client.surname%type,
                                        in_sex in client.sex%type, in_email in client.email%type, in_password in client.password%type
                                        );
PROCEDURE exit;
PROCEDURE add_basket(
    in_product_id  IN basket.product_id%TYPE,
    in_amount     IN basket.amount%TYPE
);
PROCEDURE watch_basket;
PROCEDURE creat_orders( in_credit_cart in   orders.credit_cart%TYPE);
PROCEDURE watch_orders;
PROCEDURE clear_all_basket;
PROCEDURE clear_choosen_products(in_id IN product.id%TYPE,in_amount IN product.amount%TYPE);
end pkgclient;


CREATE OR REPLACE PACKAGE body pkgclient IS
real_id client.id%type;

FUNCTION logging(in_email in client.email%type,in_password in client.password%type ) RETURN client.id%type IS
Begin
Select id into real_id 
From client
Where email=in_email and password=in_password;
return real_id;
EXCEPTION 
    WHEN NO_DATA_FOUND THEN 
DBMS_OUTPUT.PUT_LINE('Не найдено');
return NULL;
 WHEN OTHERS THEN
 DBMS_OUTPUT.PUT_LINE('Не найдено');
 return NULL;
end;

PROCEDURE exit is
begin
if real_id IS NOT NULL then real_id:=NULL;
else DBMS_OUTPUT.PUT_LINE('Вы не произвели аутентификацию');
end if;
end;

PROCEDURE pl(in_txt IN varchar2) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE(in_txt);
END ;

FUNCTION identificador_existe(in_table_name IN VARCHAR2, in_column_name IN VARCHAR2,  in_int IN NUMBER, in_string IN VARCHAR2) RETURN BOOLEAN IS
    v_sql       VARCHAR2(100);
    v_id        number(38);
    existe_int  BOOLEAN := FALSE;
BEGIN
        v_sql := 'SELECT id INTO :v_id FROM ' || in_table_name || ' WHERE ' || in_column_name || ' = ';
       IF  in_int IS NOT NULL THEN
            v_sql := v_sql || in_int;
       ELSE
            v_sql := v_sql || '''' ||  in_string || ''''; 
       END IF;
       
      -- pl(v_sql);
       EXECUTE IMMEDIATE v_sql INTO v_id;
       
       RETURN TRUE;
       
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
       WHEN OTHERS THEN 
        RAISE_APPLICATION_ERROR(-20500, 'Не удалось запросить идентификатор в таблице. ' || in_table_name ||  ' ' || sqlerrm );
    
END;



PROCEDURE add_client(in_name in client.name%type, in_surname in client.surname%type,
                                        in_sex in client.sex%type, in_email in client.email%type, in_password in client.password%type
                                         )IS

v_email_existe CLIENT.EMAIL%TYPE;
v_row_count NUMBER(1) := 0;

BEGIN
       IF IDENTIFICADOR_EXISTE('CLIENT', 'EMAIL', NULL, in_email) = TRUE THEN
        RAISE PKG_EXCEPTION.EMAIL_FOUND;
       END IF;
    
        INSERT INTO client(id, name, surname, sex,email, password) 
        VALUES (client_sq.nextval, in_name, in_surname, in_sex, in_email, in_password);    
        
        COMMIT;
    
    EXCEPTION
    WHEN PKG_EXCEPTION.EMAIL_FOUND THEN
      RAISE_APPLICATION_ERROR(-20302, 'Введенная почта уже существует');
     WHEN OTHERS THEN

        RAISE_APPLICATION_ERROR(-20500, 'Извините, произошла ошибка регистрации пользователя' || sqlerrm);
      
END;
---------------------------------------------------------------------------------------------------------------------------------
PROCEDURE add_basket(
in_product_id  IN basket.product_id%TYPE,
in_amount     IN basket.amount%TYPE
) IS

CURSOR c_consult_product IS
SELECT id, amount, status FROM product WHERE id = in_product_id;


rec_c_p c_consult_product%ROWTYPE;    

v_amount_basket basket.amount%TYPE;

BEGIN
    IF IDENTIFICADOR_EXISTE('CLIENT', 'id', real_id , null) = FALSE THEN
        RAISE PKG_EXCEPTION.CLIENT_NOT_FOUND;
    END IF;
    
   OPEN c_consult_product;
         LOOP
            FETCH c_consult_product INTO rec_c_p;
            EXIT WHEN c_consult_product%NOTFOUND;
          END LOOP;
   CLOSE c_consult_product;
   
     IF rec_c_p.id IS NULL THEN
      RAISE PKG_EXCEPTION.product_NOT_FOUND;
   END IF;
   
    BEGIN
      SELECT amount INTO v_amount_basket FROM basket
      WHERE product_id = in_product_id AND client_id = real_id ;   
      EXCEPTION
      WHEN NO_DATA_FOUND THEN
            v_amount_basket := 0;
    END;
    
     IF in_amount=0
    then  RAISE  PKG_EXCEPTION.BASKET_0_product; 
    end if;
    
    IF in_amount > rec_c_p.amount
    then  RAISE  PKG_EXCEPTION.BASKET_toomany_product; 
    end if;
    
    IF v_amount_basket > 0 THEN 
      
      IF in_amount > 0 THEN 
        UPDATE basket SET amount =  amount + in_amount
        WHERE client_id = real_id  AND product_id = in_product_id;
      ELSE 
          DELETE FROM basket WHERE product_id = in_product_id AND client_id = real_id ;
      END IF;
      
    ELSE 
    
      INSERT INTO basket (id, client_id, product_id, amount, created) 
      VALUES 
      (basket_sq.NEXTVAL, real_id , in_product_id, in_amount, SYSDATE);
      
    END IF;
   
    COMMIT;
   
    EXCEPTION
    WHEN PKG_EXCEPTION.CLIENT_NOT_FOUND THEN
    
      RAISE_APPLICATION_ERROR(-20404, 'Выбранный клиент не существует');
    WHEN PKG_EXCEPTION.product_NOT_FOUND THEN
  
        RAISE_APPLICATION_ERROR(-20404, 'Выбранный продукт не существует');
       
        WHEN PKG_EXCEPTION.BASKET_0_product then
        RAISE_APPLICATION_ERROR(-20490, 'Выберите количество товара');
        
          WHEN PKG_EXCEPTION.BASKET_toomany_product then
        RAISE_APPLICATION_ERROR(-20490, 'Вы выбрали слишком большое количество товара');        
        
    WHEN OTHERS THEN 
      
      RAISE_APPLICATION_ERROR(-20500, 'Ошибка добавления продукта в корзину покупок ' || SQLERRM);
      
END;
-------------------------------------------------------------------------------------------------------------------------------
PROCEDURE watch_basket IS

CURSOR c_client IS
SELECT name, surname, email, (CASE sex when 'M' THEN 'Мужчина' else 'Женщина' END) sex FROM client 
WHERE id = real_id ;

rec_c_client c_client%ROWTYPE;

CURSOR c_product_client IS
SELECT p.name, p.description, p.price, p.discount, 
p.amount p_amount, c.created, c.amount c_amount 
FROM product p INNER JOIN basket c 
ON p.id = c.product_id 
WHERE c.client_id = real_id  FOR UPDATE;

rec_c_p_c  c_product_client%ROWTYPE;

v_subtotal number(12,2) := 0;
v_total    number(12,2) := 0;
t number:=0;
begin
      
      IF IDENTIFICADOR_EXISTE('client', 'id', real_id , null) = FALSE THEN
        RAISE PKG_EXCEPTION.CLIENT_NOT_FOUND;
      END IF;
      
   
      
        OPEN c_client;
          LOOP
                FETCH c_client into rec_c_client;
                EXIT WHEN c_client%NOTFOUND;
          END LOOP;
        CLOSE c_client;
        
           Select count(id)  into t from  basket where client_id=real_id;
      if  t=0 then  RAISE PKG_EXCEPTION.INBASKET_0_product ;
      end if;
        
        pl('----------Данные клиента-----------');
        pl('Номер: ' || rec_c_client.name || ', ' || rec_c_client.surname || '. | Пол:' || rec_c_client.sex);
        pl('');
        
        
        pl('----------Данные вашей корзины-----------');
        
        OPEN c_product_client;
            LOOP
                  FETCH c_product_client into rec_c_p_c;
                  EXIT WHEN c_product_client%NOTFOUND;
                  pl('Описание : ' ||  rec_c_p_c.description      || ' Цена: ' || rec_c_p_c.price           || ' Количество ' ||   rec_c_p_c.c_amount ||
                  'Скидка: '  || rec_c_p_c.discount ||  TO_CHAR('%')
                      || ' Итого: ' || (rec_c_p_c.price * rec_c_p_c.c_amount-((rec_c_p_c.price * rec_c_p_c.c_amount*(rec_c_p_c.discount/100)))));
                    v_subtotal := to_char(v_subtotal +( rec_c_p_c.price * rec_c_p_c.c_amount-((rec_c_p_c.price * rec_c_p_c.c_amount*(rec_c_p_c.discount/100)))),'9999999999D99');
                  
            END LOOP;
        CLOSE c_product_client;
        pl('Всего для оплаты: '|| to_char(v_subtotal, '9999999999D99') );
        
        COMMIT;
        
        EXCEPTION 
        WHEN PKG_EXCEPTION.CLIENT_NOT_FOUND THEN
         
            RAISE_APPLICATION_ERROR(-20404, 'Выбранный клиент не существует');
           
             WHEN PKG_EXCEPTION.INBASKET_0_product then
        RAISE_APPLICATION_ERROR(-20490, 'Сначала добавьте продукт в корзину');
            
        WHEN OTHERS THEN
         
            RAISE_APPLICATION_ERROR(-20500, 'Ошибка при получении списка продуктов ' ||  SQLERRM);
end;
--------------------------------------------------------------------------------------------------------------------------------
PROCEDURE creat_orders( in_credit_cart in orders.credit_cart%TYPE) IS
CURSOR c_consultr_lista_product IS 
SELECT cl.id client_id, pr.id product_id, pr.price, pr.discount,cr.amount  c_amount ,

CASE WHEN pr.amount < cr.amount THEN pr.amount 
 ELSE cr.amount END amount_solicitada 
FROM  client cl INNER JOIN basket cr  ON  cl.id = cr.client_id 
INNER JOIN product pr                ON pr.id = cr.product_id 
WHERE cr.client_id = real_id  
FOR UPDATE OF  cr.id, pr.id
;

rec_c_c_l_p c_consultr_lista_product%ROWTYPE;

TYPE t_lista_credit_cart IS VARRAY(4) OF CHAR(2);
t_tipo_credit_cart t_lista_credit_cart := t_lista_credit_cart('V', 'B', 'M');
v_tipo_credit_cart CHAR(2);



v_subtotal  orders.total%TYPE := 0;
v_total     orders.total%TYPE;
v_orders_id  orders.id%TYPE;

begin
       
        FOR i IN 1..t_tipo_credit_cart.COUNT LOOP
          IF t_tipo_credit_cart(i) = in_credit_cart THEN
              v_tipo_credit_cart := t_tipo_credit_cart(i);
          END IF;
        END LOOP;
      
      IF v_tipo_credit_cart IS NULL THEN
         RAISE PKG_EXCEPTION.orders_credit_cart_NOT_FOUND;
      END IF;
     
    
    SELECT orders_sq.nextval INTO v_orders_id FROM dual;
     OPEN c_consultr_lista_product;
        LOOP
              FETCH c_consultr_lista_product INTO rec_c_c_l_p;
              EXIT WHEN c_consultr_lista_product%NOTFOUND;
              v_subtotal := v_subtotal +( rec_c_c_l_p.price * rec_c_c_l_p.c_amount-((rec_c_c_l_p.price * rec_c_c_l_p.c_amount*(rec_c_c_l_p.discount/100)))); 
        END LOOP;      
     CLOSE c_consultr_lista_product;
    
    v_total := v_subtotal;
    

    INSERT INTO orders (id, client_id, credit_cart, total, created) VALUES 
    (v_orders_id, real_id , in_credit_cart, v_total, SYSDATE);
    
    OPEN c_consultr_lista_product;
        LOOP
        FETCH c_consultr_lista_product INTO rec_c_c_l_p;
        if rec_c_c_l_p.amount_solicitada=0 then raise PKG_EXCEPTION.Product_0_product;
     end if;
              EXIT WHEN c_consultr_lista_product%NOTFOUND;
    INSERT INTO order_detail (id, order_id, product_id, amount, total) VALUES
             (order_detail_sq.nextval, v_orders_id, rec_c_c_l_p.product_id, rec_c_c_l_p.amount_solicitada, (rec_c_c_l_p.price * rec_c_c_l_p.amount_solicitada-(rec_c_c_l_p.price * rec_c_c_l_p.amount_solicitada*(rec_c_c_l_p.discount/100))));
     
      END LOOP;      
     CLOSE c_consultr_lista_product;
  
    DELETE FROM basket WHERE client_id = real_id ;

      
    COMMIT;
    
    EXCEPTION
     WHEN PKG_EXCEPTION.Product_0_product THEN
        RAISE_APPLICATION_ERROR(-20444, 'Продукт закончился');
    WHEN PKG_EXCEPTION.orders_credit_cart_NOT_FOUND THEN

        RAISE_APPLICATION_ERROR(-20404, 'Выбранная кредитная карта недействительна');
     WHEN OTHERS THEN
 
        RAISE_APPLICATION_ERROR(-20500, 'Ошибка обработки заказа ' || SQLERRM);
END;
------------------------------------------------------------------------------------------------------------------------------------------------------
PROCEDURE watch_orders IS

TYPE record_1 is RECORD(
id        client.id%TYPE,
name    client.name%TYPE,
surname  client.surname%TYPE
);


TYPE record_2 is RECORD(
id        orders.id%TYPE,
credit_cart       orders.credit_cart%type, 
total     orders.total%TYPE,
created     orders.created%TYPE
);


TYPE record_3 is RECORD(
name    product.name%TYPE,
price    product.price%TYPE,
amount  order_detail.amount%TYPE,
total     order_detail.total%TYPE
);


TYPE type_table_1 IS TABLE OF record_3 INDEX BY BINARY_INTEGER;

TYPE record_4 IS RECORD(
orders record_2, 
detalle_orders type_table_1
);

TYPE type_table_2 IS TABLE OF record_4 INDEX BY BINARY_INTEGER;



TYPE record_principal IS RECORD(
client     record_1, 
orderses     type_table_2
);

coleccion_orderses_client record_principal;


--Конкретный клиент

CURSOR c_buscar_client is 
SELECT id, name, surname FROM client WHERE id = real_id ;


CURSOR c_buscar_orderses_client (v_client_id in orders.client_id%TYPE) is 
SELECT id, credit_cart, total, created FROM orders 
WHERE client_id = v_client_id
order by orders.id DESC;

TYPE type_table_3 IS TABLE OF c_buscar_orderses_client%ROWTYPE INDEX BY BINARY_INTEGER;
coleccion_orderses type_table_3;


CURSOR c_buscar_detalle_orderses (v_orders_id order_detail.order_id%TYPE) is 
SELECT p.name, p.price, od.amount, od.total FROM 
order_detail od INNER JOIN  product p ON 
od.product_id= p.id WHERE od.order_id = v_orders_id;

BEGIN   
    IF real_id IS NOT NULL THEN 
             OPEN c_buscar_client;
             
                FETCH c_buscar_client  INTO coleccion_orderses_client.client;
           
             CLOSE c_buscar_client;
                        
          
            OPEN c_buscar_orderses_client(coleccion_orderses_client.client.id);
              
                  FETCH c_buscar_orderses_client BULK COLLECT INTO coleccion_orderses;
                 
            CLOSE c_buscar_orderses_client;
         
            FOR i IN 1..coleccion_orderses.count LOOP
                  coleccion_orderses_client.orderses(i).orders := coleccion_orderses(i);
                  OPEN c_buscar_detalle_orderses(coleccion_orderses_client.orderses(i).orders.id);
                        FETCH c_buscar_detalle_orderses BULK COLLECT INTO coleccion_orderses_client.orderses(i).detalle_orders;
                  CLOSE c_buscar_detalle_orderses;
            END LOOP;
            
            
   
            pl('------------Отчет о заказах---------');
            pl('');
            
            pl('-----------------');
            pl('Персональная информация');
            pl('-----------------');
            pl('');
            pl('Имя: ' || coleccion_orderses_client.client.name || ', ' || coleccion_orderses_client.client.surname);
            pl('');
            FOR i IN 1..coleccion_orderses_client.orderses.count LOOP
                pl('Заказ номер: '       || lpad(coleccion_orderses_client.orderses(i).orders.id, 38, 0));
                pl('Тип оплаты: '   || coleccion_orderses_client.orderses(i).orders.credit_cart);
                pl('Всего для оплаты: '  || coleccion_orderses_client.orderses(i).orders.total);
                pl('Дата: '          || coleccion_orderses_client.orderses(i).orders.created);
                pl('');
                
                pl('---------------------');
                pl('Приобретенные продукты');
                pl('---------------------');
                
                pl('');
                FOR j IN 1..coleccion_orderses_client.orderses(i).detalle_orders.COUNT LOOP
                    pl('Название: '   || coleccion_orderses_client.orderses(i).detalle_orders(j).name);
                    pl('Количество '  || coleccion_orderses_client.orderses(i).detalle_orders(j).amount);
                    pl('Итого: '    || coleccion_orderses_client.orderses(i).detalle_orders(j).total);
                    pl('');
                END LOOP;
                pl('');
                pl('------------------------------');
                pl('            Конец              ');
                pl('------------------------------');
                pl('');
            END LOOP;        
    END IF;
    
    COMMIT;
    
    EXCEPTION
    WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20500, 'Произошла ошибка при создании отчета о заказе ' || SQLERRM);
      
end;
-------------------------------------------------------------------------------------------------------------------------------
PROCEDURE clear_all_basket is
Begin
    delete from basket where client_id=real_id;
    commit;
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
RAISE_APPLICATION_ERROR(-20540, 'Клиент не найден. ' || sqlerrm );
       WHEN OTHERS THEN 
        RAISE_APPLICATION_ERROR(-20500, 'Не удалось запросить идентификатор в таблице. ' || sqlerrm );
    
end;
-------------------------------------------------------------------------------------------------------------------------------
PROCEDURE clear_choosen_products(in_id IN product.id%TYPE,in_amount IN product.amount%TYPE) is
a product.amount%TYPE;
Begin
select amount into a from basket where client_id=real_id and product_id=in_id;
IF in_amount>a then RAISE PKG_EXCEPTION.CLIENT_NOT_FOUND;
else
    update basket set amount=amount-in_amount where client_id=real_id and product_id=in_id;
    commit;
    end if;
       EXCEPTION
       WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20541, 'Такой товар не лежит в корзине. ' || sqlerrm );
       WHEN OTHERS THEN 
        RAISE_APPLICATION_ERROR(-20500, 'Не удалось запросить идентификатор в таблице. '  || sqlerrm );
    
end;
-------------------------------------------------------------------------------------------------------------------------------


end pkgclient;


