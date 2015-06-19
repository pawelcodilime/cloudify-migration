
# Common utility functions for migration scripts.
# Script requires four variables to be set to work properly:
#   OLD_CLI_PYTHON_VIRTENV
#   OLD_CLI_DIR
#   NEW_CLI_PYTHON_VIRTENV
#   NEW_CLI_DIR
#
# Recommended way of sourcing this script:
# BASE_DIR=$(dirname $(readlink -e $0))
# . $BASE_DIR/common.sh

SCRIPT_NAME=$0

function put_common_args_to_variables {
    # Directory of the virtualenv which is utilized by Cloudify CLI to manage the old manager
    OLD_CLI_PYTHON_VIRTENV=$(absolute_path $1)

    # Location of the .cloudify directory initialized by Cloudify CLI to manage the old manager
    OLD_CLI_DIR=$(absolute_path $2)

    # Directory of the virtualenv which is utilized by Cloudify CLI to manage the new manager
    NEW_CLI_PYTHON_VIRTENV=$(absolute_path $3)

    # Location of the .cloudify directory initialized by Cloudify CLI to manage the new manager
    NEW_CLI_DIR=$(absolute_path $4)
}

function error {
    echo "$1" 1>&2
    exit $2
}

function absolute_path {
    echo $(dirname $(readlink -e $1))/$(basename $1)
}

function activate_cli {
    # Deactivate any virtual env that is potentially activated
    if [[ $(type -t deactivate) == 'function' ]]; then
        deactivate
    fi
    # Change dir to a directory containing an appropriate .cloudify directory
    cd $1
    # Activate the desired virtual env
    . $2/bin/activate
}

function activate_old_cli {
    activate_cli $OLD_CLI_DIR $OLD_CLI_PYTHON_VIRTENV
}

function activate_new_cli {
    activate_cli $NEW_CLI_DIR $NEW_CLI_PYTHON_VIRTENV
}

# Usage:  download_from_manager where what
# To choose the manager, activate the appropriate CLI
function download_from_manager {
    python $BASE_DIR/scp.py $1 $2 download
}

# Usage:  upload_to_manager what where
# To choose the manager, activate the appropriate CLI
function upload_to_manager {
    python $BASE_DIR/scp.py $1 $2 upload
}

#$1 - script path
#$2 - runner name
function run_operation {
    upload_to_manager $1 /tmp/script.tar.gz
    upload_to_manager $BASE_DIR/runners/$2 /tmp/runner.sh
    cfy ssh -c '/tmp/runner.sh /tmp/script.tar.gz'
}

