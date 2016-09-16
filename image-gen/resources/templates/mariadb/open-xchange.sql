create database INSERT_CONF_DB_NAME_HERE;
grant all privileges on INSERT_CONF_DB_NAME_HERE.* to INSERT_DB_USER_HERE@'%' identified by 'INSERT_DB_PASSWORD_HERE';

create database INSERT_DATA_DB_NAME_HERE;
grant all privileges on INSERT_DATA_DB_NAME_HERE.* to INSERT_DB_USER_HERE@'%' identified by 'INSERT_DB_PASSWORD_HERE';

grant all privileges on INSERT_DATA_DB_NAME_HERE_5.* to INSERT_DB_USER_HERE@'%' identified by 'INSERT_DB_PASSWORD_HERE';
grant all privileges on INSERT_DATA_DB_NAME_HERE_6.* to INSERT_DB_USER_HERE@'%' identified by 'INSERT_DB_PASSWORD_HERE';