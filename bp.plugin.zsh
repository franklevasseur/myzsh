# botpress
bot="$HOME/Documents/botpress-root/"
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
    if [[ $1 = "core" || $1 = "studio" || $1 = "admin" || $1 = "shared" ]]
    then
        yarn cmd build:$1
    elif [[ $1 != "" ]]
    then
    	yarn cmd build:modules --m $1
    else
        yarn build
    fi
}

yp() {
    if [[ $1 != "" ]]
    then
    	yarn cmd package:modules --m $1
    else
        yarn cmd package
    fi
}

ys() {
    if [[ $1 = "l" ]]
    then
        yarn start lang --dim=300
    elif [[ $1 = "stan" ]]
    then
    	ys nlu --languageURL=http://localhost:3100 --ducklingURL=http://localhost:8000 --modelCacheSize=1gb --body-size=900kb --silent
    else
        yarn start $@
    fi
}

yt() {
    yarn test $@
}

y() {
	yarn $@
}

duck() {
	duckDir="${bot}duckling/"
	if [ -d $duckDir ]   # For file "if [ -f /home/rama/file ]"
	then
		(cd $duckDir && stack exec duckling-example-exe)
	else
	    echo "${duckDir} directory does not exist"
	fi
}

redis() {
    docker run -it --rm --name docker-redis redis
}

bpconf() {
    if [[ $1 = "global" || $# -eq 0 ]]
    then
        echo "$(pwd)/out/bp/data/global/botpress.config.json"
    elif [[ $1 = "zsh" ]]
    then
        echo "$HOME/.oh-my-zsh/custom/plugins/bp/bp.plugin.zsh"
    else
        filename=$1
        echo "$(pwd)/out/bp/data/global/config/${filename}.json"
    fi
}

bitf() {
    if [[ $1 = "ls" || $# -eq 0 ]]
    then
        (cd $bot && cd bitfan-client && ys ls)
    else
        echo "command $1 not supported"
    fi
}