# botpress
code="$HOME/Documents/code/"
bot="$HOME/Documents/botpress-root/"
bp_sql_uri="postgres://postgres:postgres@localhost:5432/botpress"
bp_cache="$HOME/Library/ApplicationSupport/botpress"

bot() {
    script="
        const cliSelect = require('cli-select')
        const fs = require('fs')
        const path = require('path')

        const bot = '$bot'

        const childDirs = fs.readdirSync(bot, { withFileTypes: true })
            .filter(dirent => dirent.isDirectory())
            .map(dirent => dirent.name)
            .filter(name => !name.startsWith('.'))

        cliSelect({ values: ['root', ...childDirs], outputStream: process.stderr }).then(x => {
                if (x.value === 'root') {
                    console.log(bot)
                    return
                }
                console.log(path.join(bot, x.value))
            }).catch(() => {
                console.log('.')
                return
            })
    "
    cd $(node -e $script)
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
	duckDir="${bot}duckling/"
	if [ -d $duckDir ]
	then
		(cd $duckDir && stack exec duckling-example-exe)
	else
	    echo "${duckDir} directory does not exist"
	fi
}

redis() {
    docker run -it --rm -p 6379:6379 --name docker-redis redis
}

bpconf() {
    if [[ $# -eq 0 ]]
    then
        echo "config file has moved a lot..."
    elif [[ $1 = "zsh" ]]
    then
        echo "$HOME/.oh-my-zsh/custom/plugins/bp/bp.plugin.zsh"
    else
        echo "\"$1\" no such config file..."
    fi
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