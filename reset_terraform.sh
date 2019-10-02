#!/bin/bash
# A simple script that when ran in a specific directory, will remove all traces of a `terraform init`
usage="$(basename "$0") [-h] -- A simple script that deletes all traces of a terraform init.

How to use:
  1. cd into the directory that has your terraform deployment
  2. Run this script in that directory
  3. When prompted, confirm your actions, which will then carry out the deed.

where:
    -h  shows how to use this script"
while getopts ':hs:' option; do
    case "$option" in
      h)  echo "$usage"
          exit
          ;;
      :)  printf "missing arguments for -%s\n" "$OPTARG" >&2
          echo "$usage" >&2
          exit 1
          ;;
      \?) printf "illegal option: -%s\n" "$OPTARG" >&2
          echo "$usage" >&2
          exit 1
          ;;
    esac
done
shift $((OPTIND - 1))

echo "WARNING! You are about to reset your entire Terraform configuration! There is NO undo for this. Are you SURE you want to do this? Only `yes` will be accepted."

read userInput
echo

if [ '$userInput' = 'yes']; then
  rm ./terraform.tfstate
  rm ./terraform.tf.state.backup
  rm -rf ./.terraform/
  echo "Removed terraform states and folder!"
  echo "Now reinitializing terraform"
  terraform init
  echo "Restart complete!"
else
  echo "Exiting script"
fi
