#!/usr/bin/zsh

[[ ! -f "workshop.txt" ]] && echo "Please run this script from the root folder of the mod" && exit

APP_ID=108600
WORKSHOP_ID=$(cat workshop.txt | grep '^id=' | sed 's/^id=//')

DESCRIPTION=$(cat workshop.txt | grep '^description=' | sed 's/^description=//')


cat << EOT > /tmp/template.vdf
"workshopitem"
{
    "appid" "$APP_ID"
    "publishedfileid" "$WORKSHOP_ID"
    "contentfolder" "$(cygpath -da $PWD)\\Contents"
    "description" "$DESCRIPTION"
}
EOT

steamcmd +login $(op read op://personal/steam/username) $(op read op://personal/steam/password) +workshop_build_item "$(cygpath -da /tmp/template.vdf)" +quit
