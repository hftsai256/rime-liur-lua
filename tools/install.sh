#!/bin/sh
PROGRAM="install.sh"
PLUM_URL="https://raw.githubusercontent.com/rime/plum/master/rime-install"
LIUR_CONF="https://raw.githubusercontent.com/hftsai256/rime-liur-lua/master/liur-lua-packages.conf"
FCITX_BREEZE="https://arch.mirror.constant.com/extra/os/x86_64/fcitx5-breeze-2.0.0-2-any.pkg.tar.zst"
TMPDIR="/tmp/liur"

HELP_MSG="
Install Liur-Lua on OpenXiami for RIME framework
Usage: ${PROGRAM} [-ih]

Options
  -i  Select IME frontend (supported options: fcitx5, fcitx5-flatpak, ibus).
      Will attempt to detect installed frontend if omitted.
  -h  This message
"

detect_im () {
        if which fcitx5 > /dev/null 2>&1; then
                IM=fcitx5-rime
                RIME_DIR=$HOME/.local/share/fcitx5/rime
                if [ ! -f /usr/lib/fcitx5/librime.so ]; then
                        echo detected fcitx5 but cannot find fcitx5-rime module 1>&2
                        exit 1
                fi

        elif flatpak list | grep -q org.fcitx.Fcitx5.Addon.Rime > /dev/null 2>&1; then
                IM=fcitx5-rime
                RIME_DIR=$HOME/.var/app/org.fcitx.Fcitx5/data/fcitx5/rime

        elif which ibus > /dev/null 2>&1; then
                IM=ibus-rime
                RIME_DIR=$HOME/.config/ibus/rime
                if [ ! -f /usr/lib/ibus-rime/ibus-engine-rime ]; then
                        echo detected ibus but cannot find ibus-rime module 1>&2
                        exit 1
                fi

        else
                echo no IME frontend detected, install fcitx5-rime or ibus-rime 1>&2
                exit 1

        fi
}

install_breeze_theme () {
        mkdir -p $TMPDIR
        mkdir -p "$RIME_DIR"/../themes
        curl -fsSL $FCITX_BREEZE | zstd -cd | tar -C $TMPDIR -xvf -
        mv $TMPDIR/usr/share/fcitx5/themes/* "$RIME_DIR"/../themes
}

install_with_plum () {
        mkdir -p $TMPDIR
        cd $TMPDIR || {
                echo cannot create temporary folder /tmp/liur >&2
                exit 1
        }
        curl -fsSL $PLUM_URL | rime_frontend=$IM rime_dir=$RIME_DIR bash -s -- $LIUR_CONF
}

cleanup () {
        rm -rf $TMPDIR
}

while getopts "i:h" arg; do
	case "$arg" in
		i)
                        case $OPTARG in
                                fcitx5 | fcitx5-rime)
                                        IM=fcitx5-rime
                                        RIME_DIR=$HOME/.local/share/fcitx5/rime
                                        ;;
                                fcitx5-flatpak)
                                        IM=fcitx-rime
                                        RIME_DIR=$HOME/.var/app/org.fcitx.Fcitx5/data/fcitx5/rime
                                        ;;
                                ibus | ibus-rime)
                                        IM=ibus-rime
                                        RIME_DIR=$HOME/.config/ibus/rime
                                        ;;
                                *)
                                        echo Invalid frontend "$OPTARG"
                                        echo available options: fcitx5, ibus
                                        exit 1
                                        ;;
                        esac
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


if [ -z "$IM" ]; then
        detect_im
fi

IM=${IM:-$(detect_im)}
echo detected IM: "$IM"
echo install path: "${RIME_DIR:-(default)}" 
printf "%s" "proceed? (y/N) "
read -r proceed

case "$proceed" in
        y|Y)
                install_with_plum

                if [ "$IM" = "fcitx-rime" ]; then
                        install_breeze_theme
                fi

                cleanup
                ;;
        *)
                exit 0
                ;;
esac
