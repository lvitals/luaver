#!/bin/zsh

_luaver_download()
{
    if curl -V >/dev/null 2>&1
    then
        curl -fsSL "$1"
    else
        wget -qO- "$1"
    fi
}

_luaver() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local opts=()
    
    case $COMP_CWORD in
        1)
            # Get commands from luaver help output
            opts=($(luaver help 2>/dev/null | awk '/^   / { print $2 }'))
            ;;
        2)
            case "${COMP_WORDS[COMP_CWORD-1]}" in
                install)
                    if [[ -z "${_luaver_lua_versions[*]}" ]]; then
                        _luaver_lua_versions=($(_luaver_download 'https://www.lua.org/ftp/' 2>/dev/null | 
                            sed -n -e 's/.*lua\-\(5\.[0-9]\.[0-9]\)\.tar\.gz.*/\1/p' | sort -V))
                    fi
                    opts=("${_luaver_lua_versions[@]}")
                    ;;
                
                install-luajit)
                    if [[ -z "${_luaver_luajit_versions[*]}" ]]; then
                        _luaver_luajit_versions=($(_luaver_download 'https://api.github.com/repos/LuaJIT/LuaJIT/tags' 2>/dev/null |
                            jq -r '.[].name' 2>/dev/null | sed 's/^v//' | sort -V))
                    fi
                    opts=("${_luaver_luajit_versions[@]}")
                    ;;
                
                install-luarocks)
                    if [[ -z "${_luaver_luarocks_versions[*]}" ]]; then
                        _luaver_luarocks_versions=($(_luaver_download 'https://api.github.com/repos/luarocks/luarocks/tags' 2>/dev/null |
                            jq -r '.[].name' 2>/dev/null | sed 's/^v//' | sort -V))
                    fi
                    opts=("${_luaver_luarocks_versions[@]}")
                    ;;
                
                use|set-default|uninstall)
                    opts=($(luaver list 2>/dev/null | grep -E '[0-9]+\.[0-9]+\.[0-9]+' | tr -d '-'))
                    ;;
                
                use-luajit|set-default-luajit|uninstall-luajit)
                    opts=($(luaver list-luajit 2>/dev/null | grep -E '[0-9]+\.[0-9]+\.[0-9]+' | tr -d '-'))
                    ;;
                
                use-luarocks|set-default-luarocks|uninstall-luarocks)
                    opts=($(luaver list-luarocks 2>/dev/null | grep -E '[0-9]+\.[0-9]+\.[0-9]+' | tr -d '-'))
                    ;;
            esac
            ;;
    esac

    COMPREPLY=($(compgen -W "${opts[*]}" -- "$cur"))
}

# Only register completion for luaver (remove other commands unless needed)
complete -F _luaver luaver