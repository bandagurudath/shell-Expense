#!/bin/bash

USERID=$(id -u)
SCRIPTNAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGPATH=/tmp/$SCRIPTNAME-$TIMESTAMP.log

echo "Enter mysql_root_password"
read mysql_root_password

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

validate(){
    if [ $1 -eq 0 ]
    then
    echo -e "$2 .....$G SUCCESS $N"
    else
    echo -e "$2 .....$R FAILURE $N"
    fi
}

if [ $USERID -eq 0 ]
then
echo "Yor are a super user"
else
echo "This script must be run by Super User"
exit 1
fi

dnf install mysql-server -y &>>$LOGPATH
validate $? "Installing mysql-server"

systemctl start mysqld &>>$LOGPATH
validate $? "Starting mysqld service"

systemctl enable mysqld &>>$LOGPATH
validate $? "enabling mysqld service"

mysql -h db.gurudathbn.site -uroot -p$mysql_root_password -e 'show databases;' &>>$LOGPATH
if[ $? -eq 0 ]
then
echo "mysql_root_password is alreday set"
else
mysql_secure_installation --set-root-pass $mysql_root_password &>>$LOGPATH
validate $? "Setting mysql root password"
fi