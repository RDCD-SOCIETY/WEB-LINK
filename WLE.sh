#!/usr/bin/env bash

# ==========================================
# RDCS - READ DRAGON CYBER SECURITY
# PAGE LINK EXTRACTOR
# ==========================================

APP_NAME="RDCS"
API="https://api.hackertarget.com/pagelinks/"
FB_PAGE="https://www.facebook.com/RDCSSOCIETY"

# Colors
red="\e[31m"
green="\e[32m"
yellow="\e[33m"
blue="\e[34m"
cyan="\e[36m"
white="\e[37m"
bold="\e[1m"
reset="\e[0m"

# ==========================================
# REQUIREMENTS
# ==========================================

for pkg in curl; do
    if ! command -v "$pkg" >/dev/null 2>&1; then
        echo -e "${yellow}Installing $pkg...${reset}"

        if command -v pkg >/dev/null 2>&1; then
            pkg install "$pkg" -y
        elif command -v apt >/dev/null 2>&1; then
            apt install "$pkg" -y
        fi
    fi
done

# ==========================================
# INTERNET CHECK
# ==========================================

internet_check() {
    if ! curl -Is --connect-timeout 5 https://google.com >/dev/null 2>&1; then
        echo -e "${red}[!] Internet connection unavailable.${reset}"
        exit 1
    fi
}

# ==========================================
# FACEBOOK PAGE AUTO OPEN
# ==========================================

open_facebook() {

    echo -e "${cyan}[+] Opening RDCS Facebook Page...${reset}"

    if command -v termux-open-url >/dev/null 2>&1; then
        termux-open-url "$FB_PAGE" >/dev/null 2>&1

    elif command -v am >/dev/null 2>&1; then
        am start \
        -a android.intent.action.VIEW \
        -d "$FB_PAGE" >/dev/null 2>&1

    else
        echo -e "${yellow}[!] Browser opening command unavailable.${reset}"
    fi

}

# ==========================================
# BANNER
# ==========================================

banner() {

    clear

    echo -e "${red}${bold}"
    echo '██████╗ ██████╗  ██████╗███████╗'
    echo '██╔══██╗██╔══██╗██╔════╝██╔════╝'
    echo '██████╔╝██║  ██║██║     ███████╗'
    echo '██╔══██╗██║  ██║██║     ╚════██║'
    echo '██║  ██║██████╔╝╚██████╗███████║'
    echo '╚═╝  ╚═╝╚═════╝  ╚═════╝╚══════╝'
    echo -e "${reset}"

    echo -e "${cyan}       READ DRAGON CYBER SECURITY${reset}"
    echo -e "${yellow}       PAGE LINK EXTRACTOR${reset}"
    echo -e "${blue}       ============================${reset}"
    echo

}

# ==========================================
# MAIN MENU
# ==========================================

main() {

    banner

    echo -e " ${bold}${yellow}[01]${reset} ${white}Page Link Extractor${reset}"
    echo
    echo -e " ${bold}${red}[q]${reset} ${white}Exit${reset}"
    echo

    read -r -p "$(echo -e "${cyan}RDCS Choose Option: ${reset}")" opt

    case "$opt" in

        1|01)
            PageLink
            ;;

        q|Q)
            terminate
            ;;

        *)
            echo -e "${red}[!] Invalid option.${reset}"
            sleep 1
            main
            ;;

    esac

}

# ==========================================
# BACK / EXIT
# ==========================================

exitorback() {

    echo
    echo -e "${bold}${cyan}[b] Back     [q] Exit${reset}"
    echo -e "${yellow}Example: example.com or www.example.com${reset}"
    echo

}

# ==========================================
# PAGE LINK EXTRACTOR
# ==========================================

PageLink() {

    while true; do

        clear
        banner
        exitorback

        read -r -p "$(echo -e "${cyan}Enter Website Domain: ${reset}")" target

        case "$target" in

            b|B)
                main
                return
                ;;

            q|Q)
                terminate
                ;;

            "")
                echo -e "${red}[!] Please enter a domain.${reset}"
                sleep 1
                continue
                ;;

        esac

        # Add HTTPS if missing
        if [[ ! "$target" =~ ^https?:// ]]; then
            target="https://$target"
        fi

        echo
        echo -e "${yellow}[+] Target: ${target}${reset}"
        echo -e "${yellow}[+] Extracting page links...${reset}"
        echo

        response=$(curl -fsS \
            --connect-timeout 10 \
            --max-time 60 \
            --get \
            --data-urlencode "q=${target}" \
            "$API" 2>&1)

        if [[ $? -eq 0 && -n "$response" ]]; then

            echo -e "${green}========== EXTRACTED LINKS ==========${reset}"
            echo
            printf '%s\n' "$response"
            echo
            echo -e "${green}=====================================${reset}"

        else

            echo -e "${red}[!] Unable to retrieve page links.${reset}"
            echo -e "${yellow}${response}${reset}"

        fi

        echo
        read -r -p "$(echo -e "${cyan}Press Enter to continue...${reset}")" _

    done

}

# ==========================================
# EXIT
# ==========================================

terminate() {

    echo
    echo -e "${red}${bold}Thanks for using RDCS!${reset}"
    echo -e "${cyan}READ DRAGON CYBER SECURITY${reset}"

    exit 0

}

# ==========================================
# CTRL + C
# ==========================================

trap 'echo -e "\n${red}[!] RDCS Exiting...${reset}"; exit 0' INT
trap 'echo -e "\n${red}[!] RDCS Exiting...${reset}"; exit 0' TSTP

# ==========================================
# START
# ==========================================

internet_check
open_facebook
main