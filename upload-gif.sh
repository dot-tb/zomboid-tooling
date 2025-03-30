#!/bin/sh
GIF_PATH="clickToWearPreview.gif"

[[ ! -f "workshop.txt" ]] && echo "Please run this script from the root folder of the mod" && exit

WORKSHOP_ID=$(cat workshop.txt | sed -nE 's/^id=//p')

[[ -z "$WORKSHOP_ID" ]] && echo "No workshop id found in workshop.txt" && exit

SteamChangePreview $GIF_PATH $WORKSHOP_ID 108600
