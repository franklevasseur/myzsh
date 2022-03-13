#############################
### 0. Botpress Constants ###
#############################

code="$HOME/Documents/code"
bot="$HOME/Documents/botpress-root"
bp_sql_uri="postgres://postgres:postgres@localhost:5433/botpress"
bp_cache="$HOME/Library/ApplicationSupport/botpress"
bp_zsh=${0:a}

#############################
### 1. Basic Unix / Utils ###
#############################

alias rmlines="tr -d '\n'" # removes new lines from string
alias trimQuotes="sed -e 's/^.//' -e 's/.$//'" # removes first and last characters from string

normalize() {
  patharg=$1
  nodejs_script="
        try {
          const path = require('path')
          const normalized = path.normalize('$patharg')
          console.log(normalized)
        } catch {}
      "
  node -e $nodejs_script
}

print_json() {
    if [[ $# -eq 1 ]]
    then
        content=$1
    elif [[ $# -eq 0 ]]
    then
        local in; read in
        content=$in
    else
        echo "print_json requires either stdin or argument"
        return
    fi

    escaped=$(echo "$content" | sed -e s/\'/\\\\\'/g)
    nodejs_script="
        const util = require('util');
        const raw = '$escaped'
        const parsed = JSON.parse(raw)
        console.log(util.inspect(parsed, { colors: true, depth: 10 }))
    "
    node -e $nodejs_script
}

query_json() {
    if [[ $# -eq 2 ]]
    then
        content=$1
        query=$2
    elif [[ $# -eq 1 ]]
    then
        query=$1
        local in; read in
        content=$in
    else
        echo "query_json either 1 or 2 arguments"
        return
    fi

    escaped=$(echo "$content" | sed -e s/\'/\\\\\'/g)
    nodejs_script="
        const raw = '$escaped'
        const query = '$query'
        const keys = query.split('.')
        const parsed = JSON.parse(raw)

        let tmp = parsed
        for (const k of keys) {
            tmp = tmp[k]
        }

        console.log(JSON.stringify(tmp))
    "
    node -e $nodejs_script
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

alias yb="yarn build"
alias ys="yarn start"
alias yt="yarn test"
alias yp="yarn package"
alias y="yarn"
alias yws="yarn workspaces run"
alias tsn="ts-node --transpile-only"

pkgname() {
  dir=$1
  package_json="package.json"
  fullpath=$(normalize "$dir/$package_json")
  if test -f $fullpath; then
      nodejs_script="
        try {
          const fileContent = require('fs').readFileSync('$fullpath');
          console.log(JSON.parse(fileContent).name)
        } catch {}
      "
      pkg_name=$(node -e "$nodejs_script")
      echo $pkg_name
  fi
}

yv() {
    raw=$(yarn -v)
    nodejs_script="
        const raw = '$raw'
        const [major, minor, patch] = raw.split('.')
        const majorNum = parseInt(major)
        if (majorNum > 1) { console.log('berry') }
        else if (majorNum === 1) { console.log('classic') }
    "
    node -e $nodejs_script
}

ywls() {
    yarn_release=$(yv)

    if [[ $yarn_release = 'berry' ]]
    then
        raw=$(yarn workspaces list --json | tr '\n' ';')
        nodejs_script="
            const raw = '$raw'
            const entries = raw.split(';').filter(x => x)
            console.log(entries.map(JSON.parse).map(x => x.name).join('\n'))
        "
        node -e $nodejs_script
        return
    fi

    if [[ $yarn_release = 'classic' ]]
    then
        raw=$(yarn workspaces info | sed '1,1d' | sed '$d' | tr -d '\n')
        nodejs_script="
            const raw = '$raw'
            const entries = Object.keys(JSON.parse(raw))
            console.log(entries.join('\n'))
        "
        node -e $nodejs_script
        return
    fi    
}

yw() {
    query=$1
    args=("${@: 2}")

    if [[ $# < 2 ]]
    then
        echo "yw requires 2 arguments"
        return
    fi

    target_workspaces=("${(@f)$(ywls | grep $query)}")
    n_targets=${#target_workspaces[@]}

    if [[ $n_targets > 1 ]]
    then
        echo "there is $n_targets ws targeted by your query"
        return
    fi

    target_ws=$target_workspaces[1]
    if [[ -z $target_ws ]]
    then
        echo "no ws targeted by your query"
        return
    fi

    echo "yarn workspace $target_ws $args"
    yarn workspace $target_ws $args
}

############################
### 3. Botpress Services ###
############################

docker_duck() {
    docker run -it --rm -p 8000:8000 --name duckling rasa/duckling
}

docker_redis() {
    docker run -it --rm -p 6379:6379 --name redis redis
}

docker_pg() {
    docker run -it --rm -p 5432:5432 -e POSTGRES_PASSWORD='postgres' -e POSTGRES_USER='postgres' --name postgres postgres
}

fetch_duck() {
    query=$1
    output=$(curl -XPOST https://duckling.botpress.io/parse --data "locale=en_GB&text=$query")
    print_json $output
}

bpsql() {
    if [[ $# -eq 0 ]]
    then
        psql $bp_sql_uri
    else
        query=$1
        psql $bp_sql_uri -c $1
    fi
}

##########################
### 4. AWS Credentials ###
##########################

aws_read_token() {
    aws_sso_cache_file=$1
    echo $(cat $aws_sso_cache_file | query_json 'accessToken' | trimQuotes)
}

aws_ls_accounts() {
    access_token=$1
    aws sso list-accounts --access-token $access_token | rmlines | query_json "accountList"
}

aws_ls_roles() {
    access_token=$1
    account_id=$2
    aws sso list-account-roles --access-token $access_token --account-id $account_id | rmlines | query_json "roleList"
}

aws_get_creds() {
    access_token=$1
    account_id=$2
    role_name=$3
    aws sso get-role-credentials --access-token $access_token --account-id $account_id --role-name $role_name | rmlines | query_json "roleCredentials"
}

##########################
### 4. Others / Python ###
##########################

alias mkvenv3="python3 -m venv .venv"
alias mkvenv="python -m venv .venv"

# venv check out
venvco() {
    if [[ -z $1 ]] then venvname='.venv' else venvname=$1 fi
    source "$venvname/bin/activate"
}