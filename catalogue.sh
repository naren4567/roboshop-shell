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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disabling current nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE
VALIDATE $? "ENABLING   nodejs18" 

dnf install nodejs -y &>> $LOGFILE
VALIDATE $? "INSTALLING nodejs18" 
useradd roboshop &>> $LOGFILE
VALIDATE $? "CREATING ROBOSHOP USER " 
mkdir /app &>> $LOGFILE
VALIDATE $? "CREATING app directory " 

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "downloasing catalouge app " 
cd /app 
unzip /tmp/catalogue.zip  &>> $LOGFILE
VALIDATE $? "unzipping catalouge app "
npm install  &>> $LOGFILE

VALIDATE $? "installing dependices" 
cp /home/centos/roboshop-shell/catalogue.service /etc/systemd/system/catalogue.service &>> $LOGFILE

VALIDATE $? "copying catalouge service file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalouge daemon relode file " 
systemctl enable catalogue  &>> $LOGFILE

VALIDATE $? "enabling catalouge file "
systemctl start catalogue &>> $LOGFILE
VALIDATE $? "starting catalouge file " 

cp /home/centos/roboshop-shell/mongodb.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "copying mongodb repo" &>> 


dnf install mongodb-org-shell -y &>> $LOGFILE
VALIDATE $? "installing mongodb client "  

mongo --host $MONGODB-HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "loading catalogue into MONGODB" 
