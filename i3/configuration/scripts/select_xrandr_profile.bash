#!/bin/bash

CHOICE=$(autorandr --list | dmenu -i -p "Choisir un profil d'affichage:")

if [ -n "$CHOICE" ]; then
    autorandr --load "$CHOICE"
fi
