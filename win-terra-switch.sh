#!/bin/bash
# A REALLY dumb way to switch between terraform versions on Windows

## Global Variables
SCRIPT_MODE=""
MAIN_BINARY_PATH="$HOME/.bin"
UNUSED_BINARY_PATH="$MAIN_BINARY_PATH/terraform_archives"

check_os() {
    if [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]] ; then
        echo "windows_amd64"
    else
        echo "Why TF are u using this script go and use a symlink solution instead!"
        exit 0
    fi
}

# Takes in the version as a parameter
download_terraform_binary() {
    echo "Preparing to download terraform v${1}..."
    
    os=$(check_os)
    exit_code=$(curl -w '%{http_code}\n' -sLO "https://releases.hashicorp.com/terraform/${1}/terraform_${1}_${os}.zip")
    if [ "exit_code" != "200" ]; then
        echo "Whoops! The download failed! Passed in an invalid version, hm?"
        rm -f "terraform_${1}_${os}.zip"
        exit 1
    fi

    if [ -f "$MAIN_BINARY_PATH/terraform" ]; then
        echo "There seems to be an existing terraform version here! We'll move it to safekeeping in $UNUSED_BINARY_PATH."
        
        currVersion=$(terraform --version | sed -n 1p | cut -d 'v' -f 2)
        mv -f $MAIN_BINARY_PATH/terraform $UNUSED_BINARY_PATH/terraform_$currVersion.exe

        echo "Moved terraform v${currVersion} safely."
        echo
    fi
    
    unzip -q "terraform_${1}_${os}.zip"
    mv terraform $MAIN_BINARY_PATH/terraform
    rm -f "terraform_${1}_${os}.zip"

    echo "Downloaded terraform v${1} and placed it in $MAIN_BINARY_PATH. Feel free to start using it now!"
    echo "Just makes sure that $MAIN_BINARY_PATH is in your PATH variable!"

    if [ ! -d "$UNUSED_BINARY_PATH" ]; then
        echo "Hold up...First time using this script? Yeah we all been there. Hold on..."
        mkdir -p $UNUSED_BINARY_PATH
        cp $MAIN_BINARY_PATH/terraform $UNUSED_BINARY_PATH/terraform_${1}.exe
        echo
        echo "Just this time, we made a copy of the terraform binary you just downloaded at $UNUSED_BINARY_PATH." 
        echo "So that if you download another one after this, we'll make sure that this version won't get lost in the aether."
        echo
    fi
}

# takes in the version as a parameter
switch_terraform_binary() {
    if [ ! -f "$UNUSED_BINARY_PATH/terraform_${1}.exe" ]; then
        echo "Uh...this is awkward. There is no terraform_${1}.exe in $UNUSED_BINARY_PATH. Did you not download it yet?"
        echo "Maybe try downloading it via ./$(basename "$0") ${1} ?"
        exit 1
    fi
    
    # We first get the version of the one that is active and move it to the unused binary path
    currVersion=$(terraform --version | sed -n 1p | cut -d 'v' -f 2)
    mv -f $MAIN_BINARY_PATH/terraform $UNUSED_BINARY_PATH/terraform_$currVersion.exe

    # Then we move the one that has our specific version that we want to the main path
    mv -f $UNUSED_BINARY_PATH/terraform_${1}.exe $MAIN_BINARY_PATH/terraform.exe
    echo "Switched to Terraform v${1}!"
}

### Main
while getopts 'd:s:' option; do
    case "$option" in
        d)
            SCRIPT_MODE="DOWNLOAD"
            ARG=("$OPTARG")
            ;;
        s)
            SCRIPT_MODE="SWITCH"
            ARG=("$OPTARG")
            ;;
        \?) 
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if [ "$SCRIPT_MODE" == "DOWNLOAD" ]; then
    download_terraform_binary $ARG
elif [ "$SCRIPT_MODE" == "SWITCH" ]; then
    switch_terraform_binary $ARG
else
    echo "Sorry kid, I have NO idea what you're talking about."
fi 