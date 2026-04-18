####################
### 0. Constants ###
####################

code="$HOME/Documents/code"
myzsh=${0:a}

#############################
### 1. Basic Unix / Utils ###
#############################

getport() {
    if [[ -z $1 ]] then
        echo "Please provide a port"
        return
    fi
    port=$1
    echo $(lsof -t -i :$port)
}

killport() {
    if [[ -z $1 ]] then
        echo "Please provide a port"
        return
    fi

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

docker_redis() {
    docker run -it --rm -p 6379:6379 --name redis redis
}

docker_pg() {
    docker run -it --rm -p 5432:5432 -e POSTGRES_PASSWORD='postgres' -e POSTGRES_USER='postgres' --name postgres postgres
}

docker_jump() {
    if [[ -z $1 ]] then
        echo "Please provide a container id"
        return
    fi
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


#######################
### 5. Git / Github ###
#######################

unalias gcm # oh-my-zsh / git checkout $(git_main_branch)
unalias gca # oh-my-zsh / git commit --verbose --all

# git update (add, commit, push)
gup() {
    if [[ -z $1 ]]
    then
        message="update"
    else
        message=$1
    fi
    git add --all && git commit -m $message && ggp # oh-my-zsh
}

# git force push
gfp() {
    branch=$(git branch --show-current)
    git push origin $branch --force
}

# git force update (add, commit amend, force push)
gfu() {
    git add --all && git commit --amend --no-edit && gfp
}

# git commit amend
gca() {
  git commit --amend --no-edit
}

# git commit message
gcm() {
  if [[ -z $1 ]]
  then
      git commit -m "update"
      return
  fi
  git commit -m "$1"
}

# advanced git checkout
gxo() {
  if [[ -z $1 ]]
  then
      echo "Please provide a branch name"
      return
  fi

  target_branch=$1

  if git show-ref --quiet refs/heads/$target_branch; then
    gco $target_branch
    ggl
    return
  fi
  
  git fetch origin $target_branch
  git checkout $target_branch
  ggl
}
