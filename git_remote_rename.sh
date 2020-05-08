#!/bin/bash
# A simple script that updates the remote to the passed in username

usage="$(basename "$0") -o -n [-h] -- A simple script that auto replaces the git username in a remote url with the new one specified

Flags:
    -o:     Old git username (REQUIRE)
    -n:     New git username (REQUIRE)
    -h:     Displays this help page

How to use:
  1. cd into a git directory
  2. Run this script in that directory, passing necessary flags

where:
    -h  shows how to use this script
"

while getopts 'n:o:h' option; do
    case "$option" in
        o)
            OLD_NAME=("$OPTARG")
            ;;
        n)
            NEW_NAME=("$OPTARG")
            ;;
        h)  
            echo "$usage"
            exit
            ;;
        \?) 
            printf "illegal option: -%s\n" "$OPTARG" >&2
            echo "$usage" >&2
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

if [ [ -z "${OLD_NAME}" ] || [ -z "${NEW_NAME}" ] ]; then
    echo "We need to have all req flags filled!"
    exit
fi


######## Main

echo "Before:"
origURL=$(git config --get remote.origin.url)
git remote -v

if [[ "${origURL}" == *"github.com:${OLD_NAME}/"* ]]; then
    echo "Found old name!"
else
    echo "Old name is not used, so we gucci!"
    rm rename.sh
    exit
fi

echo "Modifying remote to use new name..."
cat << EOF > ./temp.txt
$(git config --get remote.origin.url)
EOF
sed -i -e "s/${OLD_NAME}/${NEW_NAME}/g" temp.txt
newURL=$(cat ./temp.txt)

git remote set-url origin ${newURL}

echo
echo "After:"
git remote -v
git ls-remote

echo
echo "Cleanup"
rm temp.txt && rm temp.txt-e && rm rename.sh