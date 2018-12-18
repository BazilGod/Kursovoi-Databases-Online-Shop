CREATE OR REPLACE TRIGGER processingOnOrder_detail
BEFORE INSERT ON order_detail
    FOR EACH ROW
DECLARE
prodQuant product.amount%TYPE;

Begin
 SELECT amount INTO prodQuant FROM product WHERE id = :NEW.product_id;
 IF  :NEW.amount > prodQuant THEN
        RAISE_APPLICATION_ERROR(-20001, 'QUANTITY NOT AVAILABLE');
    END IF;
    prodQuant := prodQuant - :NEW.amount;
    UPDATE product SET amount = prodQuant WHERE id = :NEW.product_id;
    IF prodQuant = 0  THEN
update product set status='INACTIVE' WHERE id = :NEW.product_id; 
  END IF;
    End;
  
  CREATE OR REPLACE TRIGGER processingOnOrder
    AFTER INSERT ON orders
    FOR EACH ROW 
   Begin
       Update client set status='ACTIVE' where id=:NEW.client_id;
       END;
   