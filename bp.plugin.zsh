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

htmlize() {
    script="
    const readline = require('readline')
    const Convert = require('ansi-to-html')
    const child_process = require('child_process')

    const convert = new Convert({ bg: 'black', newline: true, escapeXML: true })

    console.log(process.argv)
    const argv = process.argv.slice(1)
    if (argv.length < 1) {
      console.log(\"The program's entry point must be the first positional param.\")
      process.exit(1)
    }
    const programPath = argv[0]
    console.log('About to run program: ' + programPath)

    const p = child_process.spawn('node', [programPath, ...argv.slice(1)], {
      env: {
        ...process.env,
        FORCE_COLOR: 1
      }
    })

    var rl = readline.createInterface({
      input: p.stdout,
      output: process.stdout,
      terminal: false
    })

    console.log('<pre style=\"background:black; width: fit-content;\">')
    rl.on('line', (line) => {
      const str = convert.toHtml(line)
      console.log(str)
    }).on('close', () => {
      console.log('</pre>')
      process.exit(0)
    })"
    node -e $script $@
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