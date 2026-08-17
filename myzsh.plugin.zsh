####################
### 0. Constants ###
####################

zshrc="$HOME/.zshrc"
code="$HOME/Documents/code"
myzsh=${0:a}

#############################
### 1. Basic Unix / Utils ###
#############################

alias resrc="source $zshrc"
alias proton="pass-cli"

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
    pids=$(getport $port)

    if [[ -z $pids ]]
    then
        echo "No process running on port $1"
        return
    fi

    for pid in ${=pids}
    do
        kill -9 $pid
    done
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

runredis() {
    docker run -it --rm -p 6379:6379 --name redis redis
}

runpg() {
    docker run -it --rm -p 5432:5432 -e POSTGRES_PASSWORD='postgres' -e POSTGRES_USER='postgres' --name postgres postgres
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

#######################
### 6. AI Harnesses ###
#######################

alias cdx="caffeinate codex"
alias clc="caffeinate claude --permission-mode auto"

TIGHT_LOOP_PROMPT="
The person you work for is a highly skilled software developer and is extremely picky about his code. This document refers to him as \"the dev\".

The dev likes to feel in control and to be involved, engaged and consulted in the development process.

Never run a mutating git command; the dev prefers handling source control himself. Readonly commands like git status or git log are fine.

When editing code, take into account that the dev probably has updated the code manually since the last time you saw it. If this happens and you experience a conflict, there's no need to tell the dev about it; just read the latest version of the code and continue working on it.

Don't worry about architecture unless told otherwise. If you're asked about a feature or bug fix, be as straight-forward as possible. Big modules, functions and classes are fine. The dev will either refactor the code himself or ask you to do it explicitly.

When in doubt, ask the dev for clarification.
"

LOOSE_LOOP_PROMPT="
The person you work for is a highly skilled software developer, but he's not always available to provide guidance. He accepts that sometimes, the code may not be exactly how he would have written it, as long as it is correct and maintainable. This document refers to him as \"the dev\".

Never run a mutating git command; the dev prefers handling source control himself. Readonly commands like git status or git log are fine.

The dev trusts you to make a reasonable call and to deliver a solution that is clean, well architected, and maintainable. If you are unsure about a technical decision, make the best choice you can and continue working. The dev will review your work and provide feedback later.

You may ask the dev about product decisions, but never stop work to ask about a technical decision.
"

# claude tight loop
clight() {
    caffeinate claude \
        --permission-mode auto \
        --model sonnet \
        --effort medium \
        --append-system-prompt "$TIGHT_LOOP_PROMPT" \
        "$@"
}

# claude loose loop
cloose() {
    caffeinate claude \
        --permission-mode auto \
        --model opus \
        --effort high \
        --append-system-prompt "$LOOSE_LOOP_PROMPT" \
        "$@"
}