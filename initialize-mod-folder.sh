#!/bin/sh
PROJECT_NAME=${PWD##*/}
echo "Do you wish to initialize a Project zomboid mod in this folder ?"
echo "$PROJECT_NAME"

select strictreply in "Yes" "No"; do
    relaxedreply=${strictreply:-$REPLY}
    case $relaxedreply in
        Yes | yes | y ) break;;
        No  | no  | n ) exit;;
    esac
done

REPO_NAME_WORKSHOP=zomboid-${PROJECT_NAME}-workshop;
REPO_NAME_MOD=zomboid-${PROJECT_NAME}-mod;

gh repo create $REPO_NAME_WORKSHOP --public
gh repo clone $REPO_NAME_WORKSHOP .
#git init
#git remote add origin "https://github.com/dot-tb/zomboid-${PROJECT_NAME}.git"


PROJECT_NAME_PASCAL_CASE=$(echo "$PROJECT_NAME" | sed -E 's/[^-]+/\L\u&/g' | sed -e 's/-//g')
PROJECT_NAME_READABLE=$(echo "$PROJECT_NAME_PASCAL_CASE" | sed -E 's/[A-Z]/ &/g' | xargs)
PROJECT_NAME_PREFIXED="Delran${PROJECT_NAME_PASCAL_CASE}"

MOD_FOLDER="Contents/mods/${PROJECT_NAME_PREFIXED}42"
MOD_FOLDER_B41="Contents/mods/${PROJECT_NAME_PREFIXED}41"
MOD_FOLDER_B42="$MOD_FOLDER/42"
COMMON_FOLDER="$MOD_FOLDER/common"

LUA_FOLDER_B42="$MOD_FOLDER_B42/media/lua"
LUA_FOLDER_CLIENT_B42="$LUA_FOLDER_B42/client/${PROJECT_NAME_PREFIXED}"
LUA_FOLDER_SERVER_B42="${LUA_FOLDER_B42}/server/${PROJECT_NAME_PREFIXED}"
LUA_FOLDER_SHARED_B42="${LUA_FOLDER_B42}/shared/${PROJECT_NAME_PREFIXED}"

LUA_FOLDER_B41="$MOD_FOLDER_B41/media/lua"
LUA_FOLDER_CLIENT_B41="${LUA_FOLDER_B41}/client/${PROJECT_NAME_PREFIXED}"
LUA_FOLDER_SERVER_B41="${LUA_FOLDER_B41}/server/${PROJECT_NAME_PREFIXED}"
LUA_FOLDER_SHARED_B41="${LUA_FOLDER_B41}/shared/${PROJECT_NAME_PREFIXED}"

CODE_WORKSPACE_FILE="${PROJECT_NAME}.code-workspace"

[[ -f "workshop.txt" || -f "$CODE_WORKSPACE_FILE" ]] && echo "Workspace files already exists, the script will exit and not override anything" && exit

mkdir -p "$COMMON_FOLDER"

#mkdir -p "$LUA_FOLDER_CLIENT_B41"
#mkdir -p "$LUA_FOLDER_SERVER_B41"
#mkdir -p "$LUA_FOLDER_SHARED_B41"

mkdir -p "${MOD_FOLDER_B41}/media"
mkdir -p "${MOD_FOLDER_B42}/media"

#touch "$LUA_FOLDER_CLIENT_B41/${PROJECT_NAME_PREFIXED}_B41_Main.lua"

#git submodule add -b b41 "https://github.com/dot-tb/zomboid-delran-lib.git" "${LUA_FOLDER_SHARED_B41}/DelranLib"

mkdir -p "${MOD_FOLDER_B41}/.vscode"
mkdir -p "${MOD_FOLDER_B42}/.vscode"

touch "$COMMON_FOLDER/.gitkeep"

cat > "${MOD_FOLDER_B42}/.vscode/settings.json" << EOL
{
    "Lua.workspace.library": [
        "\${addons}/umbrella-unstable/module/library",
    ]
}
EOL

cat > "${MOD_FOLDER_B41}/.vscode/settings.json" << EOL
{
    "Lua.workspace.library": [
        "\${addons}/umbrella/module/library",
    ]
}
EOL


cat > "$CODE_WORKSPACE_FILE"  << EOL
{
    "folders": [
        {
            "name": "Workshop folder",
            "path": "."
        },
        {
            "name": "Build 41",
            "path": "${MOD_FOLDER_B41}"
        },
        {
            "name": "Build 42",
            "path": "${MOD_FOLDER_B42}"
        }
    ],
    "settings": {
        "explorer.excludeGitIgnore": false,
        "Lua.workspace.useGitIgnore": false,
        "search.useIgnoreFiles": false,
        "Lua.runtime.version": "Lua 5.1",
        "Lua.runtime.path": [
            "?.lua"
        ],
        "Lua.completion.requireSeparator": "/",
        "Lua.workspace.preloadFileSize": 800,
        "Lua.runtime.builtin": {
            "debug": "disable",
            "io": "disable",
            "package": "disable"
        },
        "Lua.workspace.checkThirdParty": false,
    }
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


cat > "${MOD_FOLDER_B41}/mod.info" << EOL
name=$PROJECT_NAME_READABLE B41
id=$PROJECT_NAME_PREFIXED
modversion=1
author=Delran
description=
poster=poster.png
icon=poster.png
versionMin=41.0.0
versionMin=41.78.0
EOL


# Create repo for mod source files
gh repo create $REPO_NAME_MOD --public

CURRENT_PATH=$PWD

cd /tmp && gh repo clone $REPO_NAME_MOD temp-repo && cd temp-repo

mkdir -p "client/${PROJECT_NAME_PREFIXED}"
mkdir -p "server/${PROJECT_NAME_PREFIXED}"
mkdir -p "shared/${PROJECT_NAME_PREFIXED}"
touch "client/${PROJECT_NAME_PREFIXED}/${PROJECT_NAME_PREFIXED}_Main.lua"
touch "server/${PROJECT_NAME_PREFIXED}/.gitkeep"

git submodule add -b main "https://github.com/dot-tb/zomboid-delran-lib.git" "shared/${PROJECT_NAME_PREFIXED}/DelranLib"

git add --all && git commit -m "Initial commit" && git push origin main 

git switch -c b41 
git submodule set-branch -b b41 "shared/${PROJECT_NAME_PREFIXED}/DelranLib" 
git submodule update --remote 
git commit -am "Set b41 DelranLib submodule to follow the b41 branch" 
git push origin b41

cd .. && rm -rfd temp-repo && cd $CURRENT_PATH

git submodule add -b main --name "${PROJECT_NAME}-b42" "https://github.com/dot-tb/$REPO_NAME_MOD" "$LUA_FOLDER_B42"
git submodule add -b b41 --name "${PROJECT_NAME}-b41" "https://github.com/dot-tb/$REPO_NAME_MOD" "$LUA_FOLDER_B41"

git submodule update --init --remote --recursive

git add --all
git commit -am "Initiali commit"
git push -u origin main
