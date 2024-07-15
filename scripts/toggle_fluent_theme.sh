#!/bin/bash
current_theme_name=$(gsettings get org.gnome.desktop.interface gtk-theme)

# The returned string contains single quotes...
if [ "$current_theme_name" = "'FluentLight'" ];
then
    gsettings set org.gnome.desktop.interface gtk-theme 'FluentDark'
    gsettings set com.solus-project.budgie-panel dark-theme true
else
    gsettings set org.gnome.desktop.interface gtk-theme 'FluentLight'
    gsettings set com.solus-project.budgie-panel dark-theme false
fi