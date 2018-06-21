from __future__ import with_statement
from fabric.api import local, cd, env, run, put
from fabric.contrib.console import confirm

env.hosts = ['pypi.sensefields.com']
env.user = 'ubuntu'
env.key_filename = '/home/gal/.ssh/supportcallhome.pem'
pypi_dir = "/pypi/packages"
remote_dir = "/home/{}/{}".format(env.user, pypi_dir)


def wheel():
    local("python setup.py bdist_wheel --universal")


def upload(file):
    current_directory = local("pwd", capture=True)
    file = current_directory + "/dist/" + file
    put(file, remote_dir)
    print "Uploaded %s " % file


def publish():
    wheel()
    with cd("dist"):
        dist_file = local("ls -t dist/ | awk '{print $1; exit}'", capture=True)
        pkg_name = dist_file.split("-")[0]
    last_pkg_pypi = run("ls -t %s| grep \"%s\" | awk '{print ""$1;exit}'" % (
        remote_dir, pkg_name))

    if dist_file == last_pkg_pypi:
        if confirm("Do you want to upgrade current version?"):
            upload(dist_file)
    else:
        upload(dist_file)

    clean_project()


def clean_project():
    local("rm -rf build/ dist/")
