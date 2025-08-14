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

dnf install nginx -y &>>$LOGPATH
validate $? "Installing nginx"

rm -rf /usr/share/nginx/html &>>$LOGPATH
curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGPATH
validate $? "Downloading frontend code"

mkdir /usr/share/nginx/html &>>$LOGPATH
cd /usr/share/nginx/html &>>$LOGPATH
unzip /tmp/frontend.zip &>>$LOGPATH
validate $? "unzipping frontend code"

cp /home/ec2-user/shell-expense/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGPATH
validate $? "copying expense conf file"

systemctl start nginx &>>$LOGPATH
validate $? "starting nginx"

systemctl enable nginx &>>$LOGPATH
validate $? "enabling nginx"






