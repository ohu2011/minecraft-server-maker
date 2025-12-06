#!/bin/bash
max_ram=4

if [ "$1" = "create" ]; then
    mkdir server
    cd server
    if dpkg -l | grep -q "^ii  jq"; then
        echo "jq is installed"
    else
        echo "jq is not install"
        echo "Do you want install jq?[y,n]"
        read ask
        if [ "$ask" = "y" ]; then 
            echo "install jq ..."
            sudo apt install jq
        fi
    fi
    if [ ! -e "paper.jar" ]; then
    #istall papermc
        shift 1
        echo "version"
        read v
        version=$(curl -s "https://qing762.is-a.dev/api/papermc/versions/$v" | jq -r '.url')
        wget -O paper.jar "$version"
        echo "paper installed"
        echo "./server.sh run pls started"
    else
        echo "you already installed serve\nDo you like create new server?[y,n]"
        read ask2
        if [ "$ask2" = "y" ]; then
            cd ..
            rm -rf server
            exit 0
        fi
    fi
fi
if [ "$1" = "run" ]; then
    cd server
    java -Xms1G -Xmx"$max_ram"G -jar paper.jar nogui
    sed -i 's/eula=false/eula=true/g' eula.txt
fi