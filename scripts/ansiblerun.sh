#!/bin/bash
tag="ansible-torrelay"

rebuild=false
args=()
for arg in "$@"; do
    if [ "$arg" == "--rebuild" ]; then
        rebuild=true
    else
        args+=("$arg")
    fi
done

if $rebuild || !(docker image ls | grep -q $tag); then
    docker build --no-cache -t $tag -f ansible.Dockerfile .
fi

env_file=".env.local"
if [ ! -f $(pwd)/$env_file ]; then
    env_file=".env"
fi
export $(grep -v '^#' $env_file | xargs)

user=$(git config user.email)
user="${user%@*}"
user=$(echo "$user" | tr '[:upper:]' '[:lower:]')

if [ "$(uname)" == "Darwin" ]; then
    docker run -it --rm --network host -v $(pwd):/ansible:rw -v /run/host-services/ssh-auth.sock:/ssh-agent -e SSH_AUTH_SOCK="/ssh-agent" --env-file $env_file -v ~/.ssh:/tmp/.ssh:ro -e ANSIBLE_REMOTE_USER="${user}" $tag "${args[@]}"    
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    docker run -it --rm --network host -v $(pwd):/ansible:rw -v ${SSH_AUTH_SOCK}:${SSH_AUTH_SOCK} -e SSH_AUTH_SOCK=${SSH_AUTH_SOCK} --env-file $env_file -v ~/.ssh:/tmp/.ssh:ro -e ANSIBLE_REMOTE_USER="${user}" $tag "${args[@]}"
fi
