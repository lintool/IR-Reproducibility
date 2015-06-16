#!/bin/bash

set -euf

curl -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" -k "http://download.oracle.com/otn-pub/java/jdk/8u45-b14/jdk-8u45-linux-x64.tar.gz"
tar -xf jdk-8u45-linux-x64.tar.gz
export JAVA_HOME=${PWD}/jdk1.8.0_45/
