####################
### 0. Constants ###
####################

code="$HOME/Documents/code"
myzsh=${0:a}

#############################
### 1. Basic Unix / Utils ###
#############################

alias rmlines="tr -d '\n'" # removes new lines from string
alias trimQuotes="sed -e 's/^.//' -e 's/.$//'" # removes first and last characters from string

allow() {
    xattr -rd com.apple.quarantine $1
    chmod +x $1
}

getpid() {
    echo $(ps -a -o 'pid,command' | grep "^$1") # only on mac
}

getport() {
    echo $(lsof -t -i :$1)
}

killpid() {
    kill -9 $1
}

killport() {
    port=$1
    pid=$(getport $port)
    
    if [[ -z $pid ]]
    then
        echo "No process running on port $1"
        return
    fi
    
    kill -9 $pid
}

unalias gup # oh-my-zsh

gitmessage() {
    if [[ -z $1 ]]
    then
        message="update"
    else
        message=$1
    fi
    echo $message
}

# git update (add, commit, push)
gup() {
    message=$(gitmessage $1)
    git add --all && git commit -m $message && ggp # oh-my-zsh
}

# git partial update (commit, push)
-gup() {
    message=$(gitmessage $1)
    git commit -m $message && ggp # oh-my-zsh
}

# git partial update (add, commit)
gup-() {
    message=$(gitmessage $1)
    git add --all && git commit -m $message
}

############################
### 2. Node / NPM / Yarn ###
############################

alias tsn="ts-node --transpile-only"

alias y="yarn"
alias yb="yarn build"
alias ys="yarn start"
alias yt="yarn test"
alias yp="yarn package"
alias yw="yarn workspace"
alias yws="yarn workspaces run"

p() { if [[ -z $1 ]]; then; pnpm install; else; pnpm $@; fi; }
alias px="pnpm dlx"
alias pb="pnpm build"
alias pw="pnpm -r --stream --workspace-concurrency=1"

nodexe() { node -e "console.log($1)"; }

###################
### 3. Services ###
###################

docker_duckling() {
    docker run -it --rm -p 8000:8000 --name duckling rasa/duckling
}

docker_redis() {
    docker run -it --rm -p 6379:6379 --name redis redis
}

docker_pg() {
    docker run -it --rm -p 5432:5432 -e POSTGRES_PASSWORD='postgres' -e POSTGRES_USER='postgres' --name postgres postgres
}

docker_minio() {
    datadir=$1
    docker run -it --rm -p 9000:9000 -p 9001:9001 --name minio minio/minio server $datadir --console-address ":9001"
}

docker_openapi() {
    docker run -it --rm -p 8080:8080 --name openapi botpress/openapi-generator-online
}

docker_jump() {
    container_id=$1
    docker exec -it $container_id bash
}

#################
### 4. Python ###
#################

alias mkvenv="python -m venv .venv"

# venv check out
venvco() {
    if [[ -z $1 ]] then venvname='.venv' else venvname=$1 fi
    source "$venvname/bin/activate"
}

rmvenv() {
    if [[ -z $1 ]] then venvname='.venv' else venvname=$1 fi
    rm -rf $venvname
}
