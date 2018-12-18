set timing on;
 declare
         cid          client.id%TYPE;         
       cname        client.name%TYPE;
       csurname     client.surname%TYPE;
       csex         client.sex%TYPE;
       cemail       client.email%TYPE;
       cpassword    client.password%TYPE;
       cstatus      client.status%TYPE;
       cregistration_date client.registration_date%TYPE;
begin
  for i in 1..100000 loop
   cname:=  DBMS_RANDOM.STRING ('x', DBMS_RANDOM.VALUE (7,10));
   csurname:=  DBMS_RANDOM.STRING ('x', DBMS_RANDOM.VALUE (7,10));
   csex:=  DBMS_RANDOM.STRING ('x', DBMS_RANDOM.VALUE (1,1));
   cemail:=  DBMS_RANDOM.STRING ('x', DBMS_RANDOM.VALUE (8,12));
   cpassword:=  DBMS_RANDOM.STRING ('x', DBMS_RANDOM.VALUE (7,10));
     cstatus:=  DBMS_RANDOM.STRING ('x', DBMS_RANDOM.VALUE (7,10));
     cregistration_date:=sysdate;
      insert into client (id,name,surname,sex,email,password,status,registration_date)
      values (client_sq.nextval,cname,csurname,csex,cemail,cpassword,cstatus,cregistration_date );
    end loop;
      commit;
end;

 set timing on;
select * from client
where (email LIKE '%9%'

or email LIKE '%l%'

or  email LIKE '%a%'
or email LIKE '%1%');

alter system flush shared_pool;
alter system flush buffer_cache;
