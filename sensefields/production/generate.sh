#bin/bash
set -x
PYTHON_CONF_FILE=python-conf.json
JS_CONF_FILE=javascript-conf.json
JAVA_CONF_FILE=java-conf.json
VERSION=$1
FILE=$2

echo $VERSION
if [ -z "$VERSION" ]; then
    echo "VERSION is empty"
    exit 1
fi

echo $FILE
if [ -z "$FILE" ]; then
    echo "FILE is empty"
    exit 1
fi



PYTHON_CONF="{\"packageName\" : \"productionapipythoncli\",\"projectName\" : \"productionapipythoncli\",\"packageVersion\": \"${VERSION}\"}"
JS_CONF="{\"projectVersion\" :  \"${VERSION}\"}"
JAVA_CONF="{\"groupId\" :  \"com.sensefields.production\", \"artifactId\" :  \"productionapijavacli\", \"artifactVersion\" :  \"${VERSION}\",\"library\" :  \"okhttp-gson\", \"invokerPackage\":\"com.sensefields.production\",\"apiPackage\": \"com.sensefields.production.api\", \"modelPackage\": \"com.sensefields.production.model\"}"

echo $PYTHON_CONF > $PYTHON_CONF_FILE
echo $JS_CONF > $JS_CONF_FILE
echo $JAVA_CONF > $JAVA_CONF_FILE

#Set swagger codegen location
swagger_coden="java -jar /home/gal/workspace/swagger-codegen/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar"
# Clean the previous build
cur_dir=`pwd`
#rm -rf build/*
$swagger_coden generate -i $FILE -l python -o build/productionapipythoncli -c $PYTHON_CONF_FILE
$swagger_coden generate -i $FILE -l javascript -o build/productionapijscli -c $JS_CONF_FILE
$swagger_coden generate -i $FILE -l java -o build/productionapijavacli -c $JAVA_CONF_FILE

# Python after-build steps:

cp fabfile.py build/productionapipythoncli
cd build/productionapipythoncli
# Upload the current build to pip repo
fab publish
cd $cur_dir



# JS after-build steps:
# Link the JS
cd build/productionapijscli
sudo npm link

