create or replace directory DATA as 'D:\03-12-2018-last\DATA';
DROP DIRECTORY DATA;
GRANT READ, WRITE ON DIRECTORY DATA TO admin;
SELECT * FROM all_directories;