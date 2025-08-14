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

dnf module disable nodejs -y &>>$LOGPATH
validate $? "Disabling deafult nodejs"

dnf module enable nodejs:20 -y &>>$LOGPATH
validate $? "Enabling nodejs version 20"

dnf install nodejs -y &>>$LOGPATH
validate $? "starting nodejs"

id expense &>>$LOGPATH
if [ $? -eq 0 ]
then
echo "expense user already exists"
else
useradd expense &>>$LOGPATH
validate $? "creating expense user"
fi

rm -rf /app &>>$LOGPATH
curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>$LOGPATH
validate $? "Downloading backend code to /tmp"

mkdir -p /app &>>$LOGPATH
cd /app &>>$LOGPATH
unzip /tmp/backend.zip &>>$LOGPATH
validate $? "Unzipping backend code to /app"

npm install &>>$LOGPATH
validate $? "installing node js dependencies"

cp /home/ec2-user/shell-expense/backend.service /etc/systemd/system/backend.service &>>$LOGPATH
validate $? "copyinh backend service file to systemd"

systemctl daemon-reload &>>$LOGPATH
validate $? "reloading daemon"

mysql -h db.gurudathbn.site -uroot -p$mysql_root_password < /app/schema/backend.sql &>>$LOGPATH
validate $? "loading data to mysql"

systemctl start backend &>>$LOGPATH
validate $? "Starting backend"

