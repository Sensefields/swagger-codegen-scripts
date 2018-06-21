#bin/bash
set -x
PYTHON_CONF_FILE=python-conf.json
JS_CONF_FILE=javascript-conf.json
ANDROID_CONF_FILE=android-conf.json
VERSION=$1
FILENAME=$2

echo $VERSION
if [ -z "$VERSION" ]; then
    echo "VERSION is empty"
    exit 1
fi

echo $FILENAME
if [ -z "$FILENAME" ]; then
    echo "FILENAME is empty"
    exit 1
fi



PYTHON_CONF="{\"packageName\" : \"dssapipythoncli\",\"projectName\" : \"dssapipythoncli\",\"packageVersion\": \"${VERSION}\"}"
JS_CONF="{\"projectVersion\" :  \"${VERSION}\"}"
ANDROID_CONF="{\"groupId\" :  \"com.sensefields.dss\", \"artifactId\" :  \"dssapiandroidcli\", \"artifactVersion\" :  \"${VERSION}\",\"library\" :  \"okhttp-gson\", \"invokerPackage\":\"com.sensefields.dss\",\"apiPackage\": \"com.sensefields.dss.api\", \"modelPackage\": \"com.sensefields.dss.model\"}"

echo $PYTHON_CONF > $PYTHON_CONF_FILE
echo $JS_CONF > $JS_CONF_FILE
echo $ANDROID_CONF > $ANDROID_CONF_FILE

#Set swagger codegen location
swagger_coden="java -jar /home/gal/workspace/swagger-codegen/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar"
# Clean the previous build
cur_dir=`pwd`
#rm -rf build/*
$swagger_coden generate -i $FILENAME -l python -o build/dssapipythoncli -c $PYTHON_CONF_FILE
$swagger_coden generate -i $FILENAME -l javascript -o build/dssapijscli -c $JS_CONF_FILE
$swagger_coden generate -i $FILENAME -l java -o build/dssapiandroidcli -c $ANDROID_CONF_FILE

# Python after-build steps:
cp fabfile.py build/dssapipythoncli
cd build/dssapipythoncli
# Upload the current build to pip repo
fab publish
cd $cur_dir


# JS after-build steps:
# Link the JS
cd build/dssapijscli
sudo npm link
cd $cur_dir

cd build/dssapiandroidcli
mvn clean install
cd $cur_dir
