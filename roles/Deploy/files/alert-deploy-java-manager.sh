#!/bin/bash

VERSION=$1
PLATFORM=$2
MANAGER=$3

echo "Version: " $VERSION
echo "platform:" $PLATFORM
echo "Manager: " $MANAGER

rm -rf ./scripts
rm -rf ./deploy

#http://artifacts.sandbox.west.com/artifactory/libs-snapshot-local/com/tfcci/ucs/incoming-data-ws/${VERSION}-SNAPSHOT/incoming-data-ws-${VERSION}-SNAPSHOT.war

#http://artifacts.sandbox.west.com/artifactory/libs-snapshot-local/com/tfcci/ucs/incoming-data-ws/1.0.2-SNAPSHOT/incoming-data-ws-1.0.2-SNAPSHOT.war



#wget "http://artifacts.west.com/artifactory/libs-snapshot/com/tfcci/ucs/managers/${MANAGER}/${VERSION}/${MANAGER}-${VERSION}-bin.zip" -O $MANAGER-bin.zip

#wget "http://build.utilities.west.com:8081/nexus/service/local/artifact/maven/redirect?r=tfcc-internal-snapshots&g=com.tfcci.ucs&a=TFCCAlert&v=4.3.0-SNAPSHOT&e=deploymentScripts.tar.gz" -O deploymentScripts.gz

/usr/sfw/bin/wget  http://artifacts.west.com/artifactory/libs-snapshot/com/tfcci/ucs/TFCCAlert/${VERSION}/TFCCAlert-${VERSION}.deploymentScripts.tar.gz -O deploymentScripts.gz
/usr/sfw/bin/gtar -zxvf deploymentScripts.gz && chmod 755 deploymentScripts.gz


cd scripts/java-properties
./deploy-properties.sh tfccdply $PLATFORM > /tmp/vasu/t1.log

cd ../..
echo "Stopping Alarming"
./scripts/alarmd-control.sh tfccdply $PLATFORM SHUTDOWN  > /tmp/vasu/t2.log


echo "Deploying Java Managers"

#./scripts/mgr-deployment.sh -n -l $PLATFORM -f tfc-bureau-manager-bin.zip -i "ucs-wimp-mgr-1-svc.xml ucs-openmarket-mgr-1-svc.xml" -u tfccdply -r "wimp-mgr1 openmarket-mgr1"
ls -lrt
ls -lrt scripts/
ls scripts/mgr-deployment-art.sh
./scripts/mgr-deployment-art.sh -n -l $PLATFORM -u tfccdply -s 2 -p $MANAGER -m 2 -v ${VERSION} -r  > /tmp/vasu/t3.log


echo "Sleeping for 5 seconds, then checking on managers"
sleep 15
./scripts/mgr-service-setup.sh --user tfccdply --location $PLATFORM --mode QUERY_CHANGING  > /tmp/vasu/t4.log

echo "Clearing and Starting Alarming Back Up"
./scripts/alarmd-control.sh tfccdply BETA STARTUP  > /tmp/vasu/t5.log
