# botpress
bot="$HOME/Documents/botpress-root/"
bot() {
    cd $bot 
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
    	ys nlu --languageURL=http://localhost:3100 --ducklingURL=http://localhost:8000 --modelCacheSize=1gb --body-size=900kb
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