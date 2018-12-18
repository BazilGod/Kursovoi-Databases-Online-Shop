BEGIN
 DBMS_SCHEDULER.CREATE_JOB(
 JOB_NAME => 'clear_basket',
 JOB_TYPE => 'PLSQL_BLOCK',
 JOB_ACTION => 'delete from basket where created<sysdate - 1/12;',
 START_DATE => '11.12.2018 10:00:00',
 REPEAT_INTERVAL => 'FREQ=HOURLY; INTERVAL=2',
 ENABLED => TRUE);
 end;
 