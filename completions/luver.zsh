#compdef luaver

_luaver_download() {
  if (( $+commands[curl] )); then
    curl -fsSL "$1"
  elif (( $+commands[wget] )); then
    wget -qO- "$1"
  fi
}

_luaver() {
  local context state state_descr line
  typeset -A opt_args

  _arguments -C \
    '1: :->command' \
    '2: :->subcommand'

  case $state in
    (command)
      local -a commands
      commands=(
        $(luaver help | awk '/^   / { print $2 }')
      )
      _describe 'command' commands
      ;;

    (subcommand)
      case $words[2] in
        (install)
          if (( ! $+_luaver_lua_versions )); then
            _luaver_lua_versions=($(_luaver_download 'https://www.lua.org/ftp/' | sed -n -e 's/.*lua\-\(5\.[0-9]\.[0-9]\)\.tar\.gz.*/\1/gp'))
          fi
          _describe 'lua-version' _luaver_lua_versions
          ;;
        (install-luajit)
          if (( ! $+_luaver_luajit_versions )); then
            _luaver_luajit_versions=($(_luaver_download "https://api.github.com/repos/LuaJIT/LuaJIT/tags" |
              jq -r '.[].name' |
              sed 's/^v//' |
              sort -t . -k 1,1nr -k 2,2nr -k 3,3nr))
          fi
          _describe 'luajit-version' _luaver_luajit_versions
          ;;
        (install-luarocks)
          if (( ! $+_luaver_luarocks_versions )); then
            _luaver_luarocks_versions=($(_luaver_download https://api.github.com/repos/luarocks/luarocks/tags |
              jq -r '.[].name' |
              sed 's/^v//' |
              sort -t . -k 1,1nr -k 2,2nr -k 3,3nr))
          fi
          _describe 'luarocks-version' _luaver_luarocks_versions
          ;;
        (use|set-default|uninstall)
          _describe 'installed-lua-versions' "$(luaver list | grep '[0-9].[0-9].[0-9]' | tr - ' ')"
          ;;
        (use-luajit|set-default-luajit|uninstall-luajit)
          _describe 'installed-luajit-versions' "$(luaver list-luajit | grep '[0-9].[0-9].[0-9]' | tr - ' ')"
          ;;
        (use-luarocks|set-default-luarocks|uninstall-luarocks)
          _describe 'installed-luarocks-versions' "$(luaver list-luarocks | grep '[0-9].[0-9].[0-9]' | tr - ' ')"
          ;;
      esac
      ;;
  esac
}

_luaver "$@"