#!/bin/sh

{ # ensure the whole script is loaded

set -eu

print_bold()
{
    tput bold; echo "${1}"; tput sgr0
}

download_file()
{
    if 'curl' -V >/dev/null 2>&1
    then 'curl' -fsSL "${1}"
    else 'wget' -qO- "${1}"
    fi
}

# install_file baseurl file
install_file()
{
    if [ -e "${2}" ]
    then
        cp "${2}" "${LUAVER_DIR}/${2}"
    else
        download_file "${1}/${2}" >"${LUAVER_DIR}/${2}"
    fi
}


## Option parsing
LUAVER_DIR=~/.luaver
REVISION=master
SHELL_PATH="$SHELL"
SHELL_TYPE=$(basename "$SHELL_PATH")

while getopts hr:s: OPT
do
    case "$OPT" in
        r ) REVISION="${OPTARG}" ;;
        h )
            echo "Usage: ${0} [-r REVISION]"
            echo "  -r  luaver reversion [${REVISION}]"
            exit 0
            ;;
    esac
done

print_bold "Installing luaver..."

## Download script
URL="https://raw.githubusercontent.com/lvitals/luaver/${REVISION}"

mkdir -p "${LUAVER_DIR}/completions"

install_file "${URL}" "luaver"
chmod a+x "${LUAVER_DIR}/luaver"

install_file "${URL}" "completions/luaver.bash" || rm "${LUAVER_DIR}/completions/luaver.bash"
install_file "${URL}" "completions/luaver.zsh" || rm "${LUAVER_DIR}/completions/luaver.zsh"
install_file "${URL}" "completions/luaver.fish" || rm "${LUAVER_DIR}/completions/luaver.fish"

## Set up profile
APPEND_COMMON="[ -s ~/.luaver/luaver ] && . ~/.luaver/luaver"

APPEND_BASH="${APPEND_COMMON}
[ -s ~/.luaver/completions/luaver.bash ] && . ~/.luaver/completions/luaver.bash"

APPEND_ZSH="${APPEND_COMMON}
[ -s ~/.luaver/completions/luaver.zsh ] && . ~/.luaver/completions/luaver.zsh"


case "${SHELL_TYPE}" in
    bash ) APPEND="${APPEND_BASH}" ;;
    zsh ) APPEND="${APPEND_ZSH}" ;;
    fish )
        mkdir -p ~/.config/fish/functions

        cp "${LUAVER_DIR}/completions/luaver.fish" ~/.config/fish/functions/luaver.fish

        FISH_CONFIG=~/.config/fish/config.fish
        mkdir -p "$(dirname "$FISH_CONFIG")"
        touch "$FISH_CONFIG"

        if ! grep -qF 'set -gx PATH ~/.luaver $PATH' "$FISH_CONFIG"; then
            printf "\n%s\n\n" 'set -gx PATH ~/.luaver $PATH' >> "$FISH_CONFIG"
        fi
        ;;
    * ) APPEND="${APPEND_COMMON}"
esac

if [ "$SHELL_TYPE" = "fish" ]; then
    print_bold "To use luaver, you must restart the shell or execute 'source ~/.config/fish/config.fish'"
elif [ -f ~/."${SHELL_TYPE}"rc ]; then
    grep -qF "${APPEND}" ~/."${SHELL_TYPE}"rc || printf "\n%s\n\n" "${APPEND}" >>~/."${SHELL_TYPE}"rc

    print_bold "Appending the following lines at the end of ~/.${SHELL_TYPE}rc if lines not exists:"
    printf "\n%s\n\n" "${APPEND}"
    print_bold "To use luaver, you must restart the shell or execute '. ~/.${SHELL_TYPE}rc'"
else
    print_bold "Add the following lines at the end of your profile (~/.bashrc, ~/.zshrc, etc):"
    printf "\n%s\n\n" "${APPEND}"
    print_bold "To use luaver, you must restart the shell or execute the above lines"
fi

print_bold "luaver was successfully installed!"

}