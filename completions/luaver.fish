#compdef luaver

function __luaver_download
    if command -q curl
        curl -fsSL $argv[1]
    else if command -q wget
        wget -qO- $argv[1]
    end
end

function __luaver_complete
    set -l cmd (commandline -opc)
    set -l current_token (commandline -ct)

    if test (count $cmd) -eq 1
        # Complete main commands
        luaver help | awk '/^   / { print $2 }' | tr -d ' '
        return
    end

    switch $cmd[2]
        case install
            if not set -q __luaver_lua_versions
                set -g __luaver_lua_versions (__luaver_download 'https://www.lua.org/ftp/' | sed -n -e 's/.*lua\-\(5\.[0-9]\.[0-9]\)\.tar\.gz.*/\1/gp')
            end
            printf "%s\n" $__luaver_lua_versions

        case install-luajit
            if not set -q __luaver_luajit_versions
                set -g __luaver_luajit_versions (__luaver_download 'https://api.github.com/repos/LuaJIT/LuaJIT/tags' | 
                    jq -r '.[].name' |
                    sed 's/^v//' |
                    sort -t . -k 1,1nr -k 2,2nr -k 3,3nr)
            end
            printf "%s\n" $__luaver_luajit_versions

        case install-luarocks
            if not set -q __luaver_luarocks_versions
                set -g __luaver_luarocks_versions (__luaver_download 'https://api.github.com/repos/luarocks/luarocks/tags' |
                    jq -r '.[].name' |
                    sed 's/^v//' |
                    sort -t . -k 1,1nr -k 2,2nr -k 3,3nr)
            end
            printf "%s\n" $__luaver_luarocks_versions

        case use set-default uninstall
            luaver list | grep '[0-9].[0-9].[0-9]' | tr - ' '

        case use-luajit set-default-luajit uninstall-luajit
            luaver list-luajit | grep '[0-9].[0-9].[0-9]' | tr - ' '

        case use-luarocks set-default-luarocks uninstall-luarocks
            luaver list-luarocks | grep '[0-9].[0-9].[0-9]' | tr - ' '
    end
end

complete -c luaver -f -a "(__luaver_complete)"