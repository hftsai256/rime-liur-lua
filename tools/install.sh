#!/bin/sh
PROGRAM="install.sh"
PLUM_URL="https://raw.githubusercontent.com/rime/plum/master/rime-install"
LIUR_CONF="https://raw.githubusercontent.com/hftsai256/rime-liur-lua/master/liur-lua-packages.conf"
FCITX_BREEZE="https://arch.mirror.constant.com/extra/os/x86_64/fcitx5-breeze-3.0.0-1-any.pkg.tar.zst"
TMPDIR="/tmp/liur"

USAGE=$(cat <<EOF
Install Liur-Lua on OpenXiami for RIME framework
Usage:
  ${PROGRAM} [options]

Options:
  -i  Specify IME frontend (supported options: fcitx5, fcitx5-nix, fcitx5-flatpak, ibus).
      Will attempt to detect installed frontend if omitted.
  -h  This message
EOF
)

detect_im () {
        if which fcitx5 > /dev/null 2>&1; then
                IM=fcitx5-rime
                RIME_DIR=$HOME/.local/share/fcitx5/rime
                if [ -f "$HOME"/.nix-profile/lib/fcitx5/librime.so ]; then
                        echo librime detected in nix profile
                        ASK_FCITX5_THEME=1
                elif [ -f /usr/lib/fcitx5/librime.so ]; then
                        echo librime detected in FHS
                else
                        echo cannot detect librime.so
                        exit 1
                fi

        elif flatpak list | grep -q org.fcitx.Fcitx5.Addon.Rime > /dev/null 2>&1; then
                IM=fcitx5-rime
                RIME_DIR=$HOME/.var/app/org.fcitx.Fcitx5/data/fcitx5/rime
                ASK_FCITX5_THEME=1
                ASK_FCITX5_FLATPAK_SYSTEMD=1

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

install_fcitx5_systemd () {
        service_dir=$HOME/.config/systemd/user
        service_file=fcitx5.service
        timer_file=fcitx5.timer

        echo install $service_file to "$service_dir"
        mkdir -p ~/.config/systemd/user
        cat <<EOF > "$service_dir"/$service_file 
[Unit]
Description=Flexible Input Method Framework
Conflicts=ibus.service

[Service]
ExecCondition=sh -c '! pgrep ibus'
ExecStart=flatpak run org.fcitx.Fcitx5
Environment=GTK_IM_MODULE=fcitx XMODIFIERS="@im=fcitx" QT_IM_MODULE=fcitx GLFW_IM_MODULE="ibus"

[Install]
Alias=input-method.service
EOF

        cat <<EOF > "$service_dir"/$timer_file
[Unit]
Description=timer for fcitx5 service

[Timer]
OnStartupSec=10sec

[Install]
WantedBy=graphical-session.target timers.target
EOF

        cat <<EOF
enabling fcitx5.timer, which will wait 30 seconds after graphical session is loaded,
and trigger flatpak fcitx5 if ibus is not detected.

to remove the installed systemd services, run:
$ systemctl --user disable fcitx5.timer
and remove both fcitx5.timer and fcitx5.service under $service_dir 
EOF

        systemctl --user enable --now fcitx5.timer
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
                                fcitx5)
                                        IM=fcitx5-rime
                                        RIME_DIR=$HOME/.local/share/fcitx5/rime
                                        ;;
                                fcitx5-nix)
                                        IM=fcitx5-rime
                                        RIME_DIR=$HOME/.local/share/fcitx5/rime
                                        ASK_FCITX5_THEME=1
                                        ;;
                                fcitx5-flatpak)
                                        IM=fcitx5-rime
                                        RIME_DIR=$HOME/.var/app/org.fcitx.Fcitx5/data/fcitx5/rime
                                        ASK_FCITX5_THEME=1
                                        ASK_FCITX5_FLATPAK_SYSTEMD=1
                                        ;;
                                ibus)
                                        IM=ibus-rime
                                        RIME_DIR=$HOME/.config/ibus/rime
                                        ;;
                                *)
                                        echo Invalid frontend "$OPTARG"
                                        echo available options: fcitx5, fcitx5-flatpak, ibus
                                        exit 1
                                        ;;
                        esac
			;;
		h)
			echo "$USAGE"
			exit 1
			;;
		*)
			echo "Unknown flag $1"
			echo "$USAGE"
			shift
			;;
	esac
done


if [ -z "$IM" ]; then
        detect_im
fi

IM=${IM:-$(detect_im)}
echo target IM frontend: "$IM"
echo install path: "${RIME_DIR:-(default)}" 
echo ask for fcitx5 theme: "$([ "$ASK_FCITX5_THEME" = 1 ] && echo yes || echo no)"
echo ask for fcitx5 systemd service: "$([ "$ASK_FCITX5_FLATPAK_SYSTEMD" = 1 ] && echo yes || echo no)"
printf "%s" "proceed? (y/N) "

read -r proceed
case "$proceed" in
        y|Y)
                install_with_plum

                if [ "$ASK_FCITX5_THEME" = 1 ]; then
                        printf "%s" "install KDE breeze theme? (y/N) "
                        read -r install_theme
                        case "$install_theme" in
                                y | Y)
                                        install_breeze_theme
                                        ;;
                                *)
                                        ;;
                        esac
                fi

                if [ "$ASK_FCITX5_FLATPAK_SYSTEMD" = 1 ]; then
                        printf "%s" "install user systemd service? (y/N) "
                        read -r install_systemd
                        case "$install_systemd" in
                                y | Y)
                                        install_fcitx5_systemd
                                        ;;
                                *)
                                        ;;
                        esac
                fi
                cleanup
                ;;
        *)
                exit 0
                ;;
esac
