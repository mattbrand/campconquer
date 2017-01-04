#!/usr/bin/env bash
set -e

function usage {
    echo "./deploy.sh [staging|prod]"
}

target=$1
if [[ -z "$target" ]]; then
    echo "You must specify the target!"
    usage
    exit
fi

case $target in
    prod|production)
        app="campconquer-prod"
        ;;
    staging)
        app="campconquer-staging"
        ;;
    * )
        echo "Invalid target '$target'!"
        usage
        exit
esac

remote=`git remote -v | grep ${app}.git | awk '{print $1}' | head -1`

if [[ -z "$remote" ]]; then
  echo "Could not find remote for app ${app}"
  exit 1
fi

if [[ -z `which heroku` ]]; then
 echo "Couldn't find 'heroku' app; please install heroku toolbelt"
 exit 1
fi

branch=`git status | head -1 | awk '{print $3}'`

read -n 1 -p "Deploy branch ${branch} to app ${app} (remote ${remote})? " answer
echo
case ${answer:0:1} in
    y|Y )
    ;;
    * )
        echo "Bye!"
        exit 1
    ;;
esac


echo ""
echo "Deploying ${branch} to ${app} (remote ${remote})"
git push ${remote} ${branch}:master

echo ""
echo "Migrating ${app} DB"
heroku run rake db:migrate --app ${app}

echo ""
echo "Seeding ${app} DB"
heroku run rake db:seed --app ${app}
