#!/bin/bash
# Function export user privileges
# 5.7存在问题: show grants for 不会给出密码信息，必须用 show create user
# https://dev.mysql.com/doc/refman/5.7/en/show-grants.html


# 传入导出服务器及用户信息
export_db_ip=$1
export_db_port=$2
export_user=$3
export_user_passwd=$4

# 文件保存目录
path=`pwd`

source /etc/profile
 
pwd=password
expgrants()  
{  
  mysql -B -h $export_db_ip -P $export_db_port -u${export_user} -p${export_user_passwd} -N $@ -e "SELECT CONCAT(  'SHOW CREATE USER   ''', user, '''@''', host, ''';' ) AS query FROM mysql.user" | \
  mysql -h $export_db_ip -P $export_db_port -u${export_user} -p${export_user_passwd} -f  $@ | \
  sed 's#$#;#g;s/^\(CREATE USER for .*\)/-- \1 /;/--/{x;p;x;}' 
 
  mysql -B -h $export_db_ip -P $export_db_port -u${export_user} -p${export_user_passwd} -N $@ -e "SELECT CONCAT(  'SHOW GRANTS FOR ''', user, '''@''', host, ''';' ) AS query FROM mysql.user" | \
  mysql -h $export_db_ip -P $export_db_port -u${export_user} -p${export_user_passwd} -f  $@ | \
  sed 's/\(GRANT .*\)/\1;/;s/^\(Grants for .*\)/-- \1 /;/--/{x;p;x;}'   
}  
expgrants > $path/mysql_all_users_sql_5.7.sql


# 立即生效
echo "flush privileges;" >> $path/mysql_all_users_sql_5.7.sql