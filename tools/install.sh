#!/bin/sh
PROGRAM="install.sh"
PLUM_URL="https://raw.githubusercontent.com/rime/plum/master/rime-install"
LIUR_CONF="https://raw.githubusercontent.com/hftsai256/rime-liur-lua/master/liur-lua-packages.conf"

HELP_MSG="
Install Liur-Lua on OpenXiami for RIME framework
Usage: ${PROGRAM} [-ih]

Options
  -i  Select IME frontend (supported options: fcitx5-rime, ibus-rime).
      Will attempt to detect installed frontend if omitted.
  -h  This message
"

detect_im () {
        if which fcitx5 > /dev/null 2>&1; then
                IM=fcitx5-rime
                if [ ! -f /usr/lib/fcitx5/librime.so ]; then
                        echo detected fcitx5 but cannot find fcitx5-rime module 1>&2
                        exit 1
                fi
        elif which ibus > /dev/null 2>&1; then
                IM=ibus-rime
                if [ ! -f /usr/lib/ibus-rime/ibus-engine-rime ]; then
                        echo detected ibus but cannot find ibus-rime module 1>&2
                        exit 1
                fi
        else
                echo no IME frontend detected, install fcitx5-rime or ibus-rime 1>&2
                exit 1
        fi

        echo $IM
}

while getopts "i:h" arg; do
	case "$arg" in
		i)
                        IM=$OPTARG
			;;
		h)
			echo "$HELP_MSG"
			exit 1
			;;
		*)
			echo "Unknown flag $1"
			echo "$HELP_MSG"
			shift
			;;
	esac
done


IM=${IM:-$(detect_im)}
echo Detected IM: "$IM"
printf "%s" "proceed? (y/N) "
read -r proceed

case "$proceed" in
        y|Y)
                curl -fsSL $PLUM_URL | rime_frontend=$IM bash -s -- $LIUR_CONF
                ;;
        *)
                exit 0
                ;;
esac
