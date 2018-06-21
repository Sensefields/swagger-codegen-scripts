"""Script to generate the client code"""
import argparse
import json
from fabric.operations import local
from fabric.context_managers import lcd

# Define in a constant the swagger codegen cli
SWAGGER = "java -jar /home/gal/workspace/swagger-codegen/modules/swagger-codegen-cli/target/swagger-codegen-cli.jar"

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Script to generate the client code')
    parser.add_argument('version', help="Version")
    parser.add_argument('swagger_file', help="Swagger file")

    args = parser.parse_args()
    version = args.version
    swagger_file = args.swagger_file

    configurations = {
        'python-flask': {'conf_file': 'python-server-conf.json',
                         'conf': {
                             'packageName': 'callhome_flask',
                             'packageVersion': version,
                             'supportPython2': True
                         },
                         'output': 'build/callhome-flash-server'},
    }

    for language, config in configurations.iteritems():
        config_file_path = config['conf_file']
        language_config = config['conf']
        output_folder = config['output']
        with open(config_file_path, 'w') as language_config_file:
            language_config_file.writelines(json.dumps(language_config))

        cmd = "%s generate -i %s -l %s -o %s -c %s" % (SWAGGER, swagger_file, language, output_folder, config_file_path)
        local(cmd)
