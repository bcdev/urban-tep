#!/bin/sh

CATALINA_HOME=/opt/tomcat
SERVICE_NAME=bc-tomcat
RUN_AS=tomcat

sudo service bc-tomcat stop
sudo -u $RUN_AS mkdir -p $CATALINA_HOME/conf/utep
sudo -u $RUN_AS cp utep-wps.properties $CATALINA_HOME/conf/utep
sudo -u $RUN_AS cp *.jar $CATALINA_HOME/webapps/bc-wps/WEB-INF/lib
sudo -u $RUN_AS ln -sf /home/hans/utep_input $CATALINA_HOME/webapps/bc-wps/utep_input
sudo service bc-tomcat start
