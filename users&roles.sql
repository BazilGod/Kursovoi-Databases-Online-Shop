CREATE ROLE client;
GRANT CONNECT TO client;
GRANT EXECUTE ON admin.pkgclient TO client;
GRANT EXECUTE ON  admin.PKG_EXCEPTION  TO client;
CREATE USER client# IDENTIFIED BY client;
GRANT SELECT ON Product TO client;
GRANT client TO client#;

CREATE ROLE administrator;
GRANT CONNECT TO administrator;
GRANT EXECUTE ON admin.pkgadmin TO administrator;
GRANT EXECUTE ON  admin.PKG_EXCEPTION  TO administrator;
GRANT READ, WRITE ON DIRECTORY DATA TO administrator#;
GRANT SELECT ON Product TO administrator;
CREATE USER administrator# IDENTIFIED BY administrator;
GRANT administrator TO administrator#;
commit;



