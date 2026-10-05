#!/bin/sh

export XDG_CURRENT_DESKTOP=i3
export XDG_SESSION_DESKTOP=i3
export DESKTOP_SESSION=i3

dbus-update-activation-environment --systemd \
    DISPLAY \
    XAUTHORITY \
    XDG_CURRENT_DESKTOP \
    XDG_SESSION_DESKTOP \
    DESKTOP_SESSION

systemctl --user import-environment \
    DISPLAY \
    XAUTHORITY \
    XDG_CURRENT_DESKTOP \
    XDG_SESSION_DESKTOP \
    DESKTOP_SESSION

xfsettingsd &
xfce4-power-manager &
xfce4-notifyd &
mate-polkit &
thunar --daemon &

exec i3
