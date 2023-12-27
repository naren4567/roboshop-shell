#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"
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

cp mongo.repo /etc/yum.repos.d/ &>> $LOGFILE

VALIDATE $? "Copied MongoDB Repo"

dnf install mongodb-org -y 

VALIDATE $? "installing mongodb"

systemctl enable mongod
VALIDATE $? "enabling mongodb"
systemctl start mongod
VALIDATE $? "started  mongodb"


