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

getport() {
    echo $(lsof -t -i :$1)
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

############################
### 2. Node / NPM / Yarn ###
############################

alias tsn="ts-node --transpile-only"

alias y="yarn"
alias yb="yarn build"
alias ys="yarn start"
alias yt="yarn test"
alias yp="yarn package"
alias yws="yarn workspaces run"

alias p= "pnpm"
alias pb="pnpm build"
alias ps="pnpm start"
alias pt="pnpm test"
alias pp="pnpm package"

###################
### 3. Services ###
###################

docker_duck() {
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

fetch_duck() {
    query=$1
    output=$(curl -s -XPOST https://duckling.botpress.io/parse --data "locale=en_GB&text=$query")
    echo $output | jq
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