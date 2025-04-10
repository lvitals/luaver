#!/bin/fish

function __luaver_download
    if type -q curl
        curl -fsSL $argv
    else
        wget -qO- $argv
    end
end

function __luaver_list_versions
    luaver list | grep '[0-9]\.[0-9]\.[0-9]' | tr -d '-'
end

function __luaver_list_luajit_versions
    luaver list-luajit | grep '[0-9]\.[0-9]\.[0-9]' | tr -d '-'
end

function __luaver_list_luarocks_versions
    luaver list-luarocks | grep '[0-9]\.[0-9]\.[0-9]' | tr -d '-'
end

complete -c luaver -n '__fish_use_subcommand' -a 'help install install-luajit install-luarocks use set-default uninstall use-luajit set-default-luajit uninstall-luajit use-luarocks set-default-luarocks uninstall-luarocks'


# install
complete -c luaver -n '__fish_seen_subcommand_from install' -a "(
    __luaver_download https://www.lua.org/ftp/ | string match -r 'lua-(5\.[0-9]+\.[0-9]+)\.tar\.gz' | string replace -r 'lua-|\.tar\.gz' ''
)"

# install-luajit
complete -c luaver -n '__fish_seen_subcommand_from install-luajit' -a "(
    __luaver_download https://api.github.com/repos/LuaJIT/LuaJIT/tags |
    jq -r '.[].name' | string replace -r '^v' '' | sort -r
)"

# install-luarocks
complete -c luaver -n '__fish_seen_subcommand_from install-luarocks' -a "(
    __luaver_download https://api.github.com/repos/luarocks/luarocks/tags |
    jq -r '.[].name' | string replace -r '^v' '' | sort -r
)"

# use, set-default, uninstall (Lua)
complete -c luaver -n '__fish_seen_subcommand_from use set-default uninstall' -a "(__luaver_list_versions)"

# use-luajit, set-default-luajit, uninstall-luajit
complete -c luaver -n '__fish_seen_subcommand_from use-luajit set-default-luajit uninstall-luajit' -a "(__luaver_list_luajit_versions)"

# use-luarocks, set-default-luarocks, uninstall-luarocks
complete -c luaver -n '__fish_seen_subcommand_from use-luarocks set-default-luarocks uninstall-luarocks' -a "(__luaver_list_luarocks_versions)"
