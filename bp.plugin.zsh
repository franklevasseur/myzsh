# botpress
code="$HOME/Documents/code/"
bot="$HOME/Documents/botpress-root/"
bp_sql_uri="postgres://postgres:postgres@localhost:5432/botpress"
bp_cache="$HOME/Library/ApplicationSupport/botpress"
bp_zsh=${0:a}

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

yb() {
    yarn build $@
}

ys() {
    yarn start $@
}

yt() {
    yarn test $@
}

yp() {
    yarn package $@
}

y() {
	yarn $@
}

yw() {
	yarn workspace $@
}

yws() {
	yarn workspaces run $@
}

duck() {
    docker run -it --rm -p 8000:8000 --name duckling rasa/duckling
}

redis() {
    docker run -it --rm -p 6379:6379 --name redis redis
}

getport() {
    echo $(lsof -t -i:$1)
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

bpsql() {
    if [[ $# -eq 0 ]]
    then
        psql $bp_sql_uri
    else
        query=$1
        psql $bp_sql_uri -c $1
    fi
}