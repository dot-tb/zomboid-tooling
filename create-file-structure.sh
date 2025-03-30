#!/bin/sh

MOVE_TO=$(dirname $(realpath -s "$0"))

cd "${MOVE_TO}/.."
PROJECT_NAME=${PWD##*/}
PROJECT_NAME_PASCAL_CASE=$(echo "$PROJECT_NAME" | sed -E 's/[^-]+/\L\u&/g' | sed -e 's/-//g')
PROJECT_NAME_READABLE=$(echo "$PROJECT_NAME_PASCAL_CASE" | sed -E 's/[A-Z]/ &/g' | xargs)
PROJECT_NAME_PREFIXED="Delran${PROJECT_NAME_PASCAL_CASE}"

MOD_FOLDER="Contents/mods/$PROJECT_NAME_PREFIXED"
MOD_FOLDER_B42="$MOD_FOLDER/42"
COMMON_FOLDER="$MOD_FOLDER/common"
LUA_FOLDER="$MOD_FOLDER_B42/media/lua"
LUA_FOLDER_CLIENT="$LUA_FOLDER/client"
LUA_FOLDER_SERVER="$LUA_FOLDER/server"
LUA_FOLDER_SHARED="$LUA_FOLDER/shared"

CODE_WORKSPACE_FILE="${PROJECT_NAME}.code-workspace"

[[ -f "workshop.txt" || -f "$CODE_WORKSPACE_FILE" ]] && echo "Workspace files already exists, the script will exit and not override anything" && exit

mkdir -p "$LUA_FOLDER_CLIENT"
mkdir -p "$COMMON_FOLDER"
touch "$LUA_FOLDER_CLIENT/${PROJECT_NAME_PREFIXED}_Main.lua"
touch "$COMMON_FOLDER/.gitkeep"

cat > "$CODE_WORKSPACE_FILE"  << EOL
{
    "folders": [
        {
            "path": "."
        }
    ]
}
EOL

cat > workshop.txt << EOL
version=1
title=$PROJECT_NAME_READABLE
description=
tags=Build 42
visibility=public
EOL

cat > "${MOD_FOLDER_B42}/mod.info" << EOL
name=$PROJECT_NAME_READABLE
id=$PROJECT_NAME_PREFIXED
modversion=1
author=Delran
description=
poster=poster.png
icon=poster.png
versionMin=42.0.0
EOL
