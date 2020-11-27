# botpress
bot="/home/francois/Documents/botpress-root/"
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
    else
        filename=$1
        echo "$(pwd)/out/bp/data/global/config/${filename}.json"
    fi
}