#!/bin/bash

REPO_PATH=$(cd $(dirname "${BASH_SOURCE[0]}") && cd .. && pwd -P)
PROGRAM=$(basename "${BASH_SOURCE[0]}")
PARAMS=
SUDO=
if [[ $EUID -ne 0 ]]; then
    SUDO="sudo"
fi

if [[ "$(cat /etc/issue 2> /dev/null)" =~ Ubuntu ]]; then
	RIME_CFG_PATH="$HOME/.config/ibus/rime"
	INSTALL_CMD="$SUDO apt-get update; $SUDO apt-get install -qy ibus-rime"
	RIME_BIN="/usr/lib/ibus-rime/ibus-engine-rime"

elif [[ "$(cat /etc/issue 2> /dev/null)" =~ Debian ]]; then
	RIME_CFG_PATH="$HOME/.config/ibus/rime"
	INSTALL_CMD="$SUDO apt-get update; $SUDO apt-get install -qy ibus-rime"
	RIME_BIN="/usr/lib/ibus-rime/ibus-engine-rime"

elif [[ "$OSTYPE" =~ ^darwin ]]; then
	RIME_CFG_PATH="$HOME/Library/Rime"
	RIME_BIN="/Library/Input Methods/Squirrel.app/Contents/MacOS/Squirrel"
	INSTALL_CMD="brew cask install squirrel"

else
	echo "Unsupported OS"
	exit 1

fi

HELP_MSG="
Usage: ${PROGRAM} [-ciuh] install Open Xiami configuration for RIME framework

Options
  -c, --clean     - Remove Build folder in $RIME_CFG_PATH
  -i, --install   - Install everything, including:
                    * main application by homebrew cask
                    * dependencies (luna-pinyan, terra-pinyin, bopomofo) by plum
                    * configuration files to $RIME_CFG_PATH
  -u, --uninstal  - Remove relative files under $RIME_CFG_PATH
  -h, --help      - This message
"

if [[ ! -e "$REPO_PATH/plum/rime-install" ]]; then
	echo "(GIT) [submodule] plum"
	cd "$REPO_PATH"
	git submodule init
	git submodule update
fi

function log_copy()
{
	echo "(COPY) $(basename $1) -> $2"
	cp -r "$@"
}

function log_remove()
{
	echo "(DEL) $@"
	rm -r "$@"
}

function log_move()
{
	echo "(MOVE) $@"
	mv "$@"
}

function log_link()
{
	echo "(LN) $@"
	ln "$@"
}

function log_yaml()
{
	echo "(YAML) $@"
	python3 "$REPO_PATH/tools/mod_yaml.py" "$@"
}

function rime_install()
{
	"$REPO_PATH/plum/rime-install" $PARAMS
}

function install()
{
	mkdir -p "$RIME_CFG_PATH"

	if [[ ! -e "$RIME_BIN" ]]; then
		echo "(INSTALL) Rime"
		eval "$INSTALL_CMD"
	fi

	echo "(INSTALL) dependencies"
	"$REPO_PATH/plum/rime-install" luna-pinyin terra-pinyin bopomofo

	for cfgfile in "$REPO_PATH/src/"{*.yaml,*.lua,opencc}; do
		log_copy $cfgfile "$RIME_CFG_PATH"
	done

	if [[ ! -e "$RIME_CFG_PATH/default.custom.yaml" ]]; then
		log_copy "$REPO_PATH/src/default.custom.in" "$RIME_CFG_PATH/default.custom.yaml"
	else
		log_yaml -a -i "$RIME_CFG_PATH/default.custom.yaml" patch/schema_list schema liur
	fi
}

function uninstall()
{
	for cfgfile in "$REPO_PATH/src/"{*.yaml,*.lua,opencc}; do
		if [[ -e "$RIME_CFG_PATH/$(basename $cfgfile)" ]]; then
			log_remove "$RIME_CFG_PATH/$(basename $cfgfile)"
		fi
	done

	if [[ -e "$RIME_CFG_PATH/default.custom.yaml" ]]; then
		log_yaml -d -i "$RIME_CFG_PATH/default.custom.yaml" patch/schema_list schema liur
	fi
}

function clean()
{
	if [[ -e "$RIME_CFG_PATH/build" ]]; then
		log_remove "$RIME_CFG_PATH/build"
	fi
}

if [[ $# -eq 0 ]]
then
	echo "$HELP_MSG"
	exit 1
fi

while (( "$#" )); do
	case "$1" in
		-c|--clean)
			clean
			shift
			;;
		-i|--install)
			clean
			install
			shift
			;;
		-u|--uninstall)
			clean
			uninstall
			shift
			;;
		-h|--help)
			echo "$HELP_MSG"
			exit 1
			;;
		-*)
			echo "Unknown flag $1"
			echo "$HELP_MSG"
			shift
			;;
		*)
			PARAMS="$PARAMS $1"
			shift
			;;
	esac
done
