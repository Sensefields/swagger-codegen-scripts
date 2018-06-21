#bin/bash
set -x
PYTHON_CONF_FILE=python-conf.json
JS_CONF_FILE=javascript-conf.json
VERSION=$1

echo $VERSION
if [ -z "$VERSION" ]; then
    echo "VERSION is empty"
    exit 1
fi

PYTHON_CONF="{\"packageName\" : \"fastrackapipythoncli\",\"projectName\" : \"fastrackapipythoncli\",\"packageVersion\": \"${VERSION}\"}"
JS_CONF="{\"projectVersion\" :  \"${VERSION}\"}"

echo $PYTHON_CONF > $PYTHON_CONF_FILE
echo $JS_CONF > $JS_CONF_FILE

#Set swagger codegen location
swagger_coden="java -jar /home/gal/workspace/swagger-codegen/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar"
# Clean the previous build
cur_dir=`pwd`
#rm -rf build/*
$swagger_coden generate -i fastrackapi-swagger.yaml -l python -o build/fastrackapipythoncli -c $PYTHON_CONF_FILE
$swagger_coden generate -i fastrackapi-swagger.yaml -l javascript -o build/fastrackapijscli -c $JS_CONF_FILE

# Python after-build steps:
cp fabfile.py build/fastrackapipythoncli
cd build/fastrackapipythoncli
# Upload the current build to pip repo
fab publish
cd $cur_dir


# JS after-build steps:
# Link the JS
cd build/fastrackapijscli
sudo npm link
