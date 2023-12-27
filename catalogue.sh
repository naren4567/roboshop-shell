#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

MONGODB_HOST=mongodb.dodevops.cloud
TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "scripted started executing at $TIMESTAMP" &>> $LOGFILE
VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R  failed $N"
    else 
        echo -e "$2 ... $G sucess $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: PLEASE RUN THIS SCRIPT WITH ROOT ACCESS"
    exit 1
else
    echo "your root user"
fi

dnf module disable nodejs -y

VALIDATE $? "disabling current nodejs" &>> $LOGFILE

dnf module enable nodejs:18 -y
VALIDATE $? "ENABLING   nodejs18" &>> $LOGFILE

dnf install nodejs -y
VALIDATE $? "INSTALLING nodejs18" &>> $LOGFILE
useradd roboshop
VALIDATE $? "CREATING ROBOSHOP USER " &>> $LOGFILE
mkdir /app
VALIDATE $? "CREATING app directory " &>> $LOGFILE

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip
VALIDATE $? "downloasing catalouge app " &>> $LOGFILE
cd /app 
unzip /tmp/catalogue.zip
VALIDATE $? "unzipping catalouge app " &>> $LOGFILE
npm install 
VALIDATE $? "installing dependices" &>> $LOGFILE

cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service

VALIDATE $? "copying catalouge service file" &>> $LOGFILE

systemctl daemon-reload
VALIDATE $? "catalouge daemon relode file " &>> $LOGFILE

systemctl enable catalogue
VALIDATE $? "enabling catalouge file " &>> $LOGFILE

systemctl start catalogue &>> $LOGFILE
VALIDATE $? "starting catalouge file " &>> $LOGFILE

cp /home/centos/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongodb repo" &>> $LOGFILE


dnf install mongodb-org-shell -y
VALIDATE $? "installing mongodb client " &>> $LOGFILE

mongo --host $MONGODB-HOST </app/schema/catalogue.js

VALIDATE $? "loading catalogue into MONGODB" &>> $LOGFILE
