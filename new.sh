#!/bin/bash

create() {
    mkdir -p server
    cd server || exit

    # jq 설치 확인
    if dpkg -l | grep -q "^ii  jq"; then
        echo "jq is installed"
    else
        echo "jq is not installed"
        echo -n "Install jq? [y/n]: "
        read ask
        if [ "$ask" = "y" ]; then
            sudo apt install -y jq
        else
            echo "Cannot continue without jq."
            exit 1
        fi
    fi

    install
}

install() {
    echo "Minecraft Paper version?"
    read v

    # PaperMC API에서 다운로드 URL 가져오기
    version=$(curl -s "https://qing762.is-a.dev/api/papermc/versions/$v" | jq -r '.url')

    if [ -z "$version" ] || [ "$version" = "null" ]; then
        echo "Invalid version"
        exit 1
    fi

    echo "Downloading paper.jar..."
    wget -O paper.jar "$version"

    if [ ! -e "paper.jar" ]; then
        echo "paper.jar download failed"
        exit 1
    fi

    echo "paper.jar installed!"
    echo "Use: ./new.sh run"
}

run() {
    if [ ! -d server ]; then
        echo "server folder not found. Run: ./new.sh create"
        exit 1
    fi

    cd server || exit

    # 첫 실행 (eula 생성)
    java -Xms1G -Xmx"${max_ram}G" -jar paper.jar nogui

    # eula 자동 동의
    eula=$(grep "eula=" eula.txt 2>/dev/null)

    if [ "$eula" = "eula=false" ]; then
        sed -i 's/eula=false/eula=true/' eula.txt
        java -Xms1G -Xmx"${max_ram}G" -jar paper.jar nogui
    fi
}

main() {
    echo "arg1=[$1]"

    case "$1" in
        create)
            create
            ;;
        run)
            run
            ;;
        *)
            echo "Usage: ./new.sh {create|run}"
            ;;
    esac
}

main "$1"
