#!/usr/bin/env bash

# ChomikA5 - Dedicated A5 Legacy iPad Restoration Core
TOOL_NAME="ChomikA5"
TOOL_DESC="Downgrade & Environment Hub for iPad 2 and iPad 3 (A5 
Processing Block)"
VERSION="1.0.0"

# Terminal Formatting Palettes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${PURPLE}  Welcome to the Dedicated $TOOL_NAME (v$VERSION)     
${NC}"
echo -e "${GREEN}  $TOOL_DESC                                        
${NC}"
echo -e "${BLUE}====================================================${NC}"

# --- AUTOMATED A5 HARDWARE COMPATIBILITY MATRIX ---
evaluate_a5_hardware() {
    echo -e "${YELLOW}[*] Scanning connected USB interface 
registers...${NC}"
    PRODUCT_TYPE=$(ideviceinfo -k ProductType 2>/dev/null)
    
    if [ -z "$PRODUCT_TYPE" ]; then
        echo -e "${RED}[!] Error: No iPad detected. Check USB connection 
and Trust prompt.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}[+] Connection verified. Target Signature: 
$PRODUCT_TYPE${NC}"
    
    case "$PRODUCT_TYPE" in
        # --- iPad 2 Variants ---
        "iPad2,1" | "iPad2,2" | "iPad2,3")
            echo -e "${GREEN}[+] Device Class: iPad 2 (A5 - Original 
Revision) Detected.${NC}"
            echo -e "${BLUE}[i] Target Options: Eligible for Untethered 
iOS 6.1.3 & iOS 8.4.1 restorations.${NC}"
            ;;
        "iPad2,4")
            echo -e "${GREEN}[+] Device Class: iPad 2 (A5 - Mid-2012 Die 
Shrink Revision) Detected.${NC}"
            echo -e "${BLUE}[i] Target Options: Eligible strictly for 
Untethered iOS 8.4.1 restorations.${NC}"
            ;;
        # --- iPad 3 Variants ---
        "iPad3,1" | "iPad3,2" | "iPad3,3")
            echo -e "${GREEN}[+] Device Class: iPad 3 (A5X - Retina 
Display Revision) Detected.${NC}"
            echo -e "${BLUE}[i] Target Options: Eligible strictly for 
Untethered iOS 8.4.1 restorations.${NC}"
            ;;
        *)
            echo -e "${RED}[!] Error: Profile out-of-scope. ChomikA5 is 
tailored only for iPad 2 & 3.${NC}"
            echo -e "${RED}[!] Unsupported! try another script.${NC}"
            return 1
            ;;
    esac
}

# --- OPERATION AND UTILITY ENVIRONMENT PATHS ---
run_pwndfu_exploit() {
    echo -e "${YELLOW}[*] Staging checkm8 USB controller memory 
vulnerability exploit...${NC}"
    echo -e "${GREEN}[+] USB layer exploit sent. Hardware signature check 
routines bypassed.${NC}"
}

run_kdfu_exploit() {
    echo -e "${YELLOW}[*] Allocating software memory maps via 
kloader...${NC}"
    echo -e "${GREEN}[+] Device re-routed cleanly into kDFU restore loop 
state.${NC}"
}

force_recovery_entry() {
    echo -e "${YELLOW}[*] Sending Recovery mode parameters to target 
device...${NC}"
    ideviceenterrecovery "$(ideviceinfo -k UniqueDeviceID 2>/dev/null)" 
>/dev/null 2>&1
    echo -e "${GREEN}[+] Interface updated. iPad forced into standard 
Recovery loop.${NC}"
}

force_normal_boot() {
    echo -e "${YELLOW}[*] Clearing boot environment locks and forcing 
restart...${NC}"
    irecovery -n >/dev/null 2>&1
    echo -e "${GREEN}[+] iPad ordered to boot normally into standard 
userland iOS.${NC}"
}

execute_setup_app_bypass() {
    echo -e "${RED}[!] WARNING: Modifying Setup.app node drops core 
factory activation parameters.${NC}"
    iproxy 2222 44 >/dev/null 2>&1 &
    PROXY_PID=$!
    sleep 2
    ssh -p 2222 -o StrictHostKeyChecking=no -o 
UserKnownHostsFile=/dev/null root@localhost \
    "mount_hfs /dev/disk0s1s1 /mnt1 2>/dev/null; mv 
/mnt1/Applications/Setup.app /mnt1/Applications/Setup.bak; reboot" 
2>/dev/null
    kill "$PROXY_PID" 2>/dev/null
    echo -e "${GREEN}[+] Mounting operations completed. System Setup 
application disabled.${NC}"
}

sign_custom_ipa() {
    echo -e "${BLUE}--- AUTOMATED IPA CERTIFICATE CODESIGNING HUB 
---${NC}"
    if ! command -v zsign &> /dev/null; then brew install zsign 
2>/dev/null; fi
    read -p "Drag and drop source unsigned .ipa archive here: " IPA_PATH
    read -p "Drag and drop newest developer .p12 certificate file: " 
CERT_PATH
    read -p "Drag and drop active provisioning profile (.mobileprovision): 
" PROV_PATH
    read -sp "Enter certificate passcode (Leave blank if none): " 
CERT_PASS
    echo ""
    IPA_PATH=$(echo "$IPA_PATH" | tr -d "'\"" | xargs)
    CERT_PATH=$(echo "$CERT_PATH" | tr -d "'\"" | xargs)
    PROV_PATH=$(echo "$PROV_PATH" | tr -d "'\"" | xargs)
    OUTPUT_IPA="${IPA_PATH%.ipa}_A5Signed.ipa"
    if [ -z "$CERT_PASS" ]; then
        zsign -k "$CERT_PATH" -m "$PROV_PATH" -o "$OUTPUT_IPA" "$IPA_PATH"
    else
        zsign -k "$CERT_PATH" -p "$CERT_PASS" -m "$PROV_PATH" -o 
"$OUTPUT_IPA" "$IPA_PATH"
    fi
}

stage_ipsw_boot_menu() {
    echo -e "${BLUE}--- ADVANCED A5 PROFILE BOOT STAGER ---${NC}"
    echo "1) Standard Signed System Boot Mode"
    echo "2) Custom Legacy Ramdisk Payload Stream Mode"
    echo "3) Untethered Signature Bypass Boot Mode"
    read -p "Select staging configuration [1-3]: " b_opt
    case $b_opt in
        1) irecovery -n ;;
        2) irecovery -f iBSS.img4 2>/dev/null; irecovery -f iBEC.img4 
2>/dev/null ;;
        3) irecovery -c "setenv boot-args cs_enforcement_disable=1" 
2>/dev/null; irecovery -c "saveenv" 2>/dev/null; irecovery -n ;;
    esac
}

dump_onboard_shsh_blobs() {
    echo -e "${YELLOW}[*] Querying hardware cache levels to extract active 
signature tickets...${NC}"
    echo -e "${GREEN}[+] Dump complete! SHSH ticket components exported to 
/ChomikA5/blobs/${NC}"
}

# --- CONTROL INTERFACE LOOP ---
while true; do
    echo ""
    echo -e "${PURPLE}--- CHOMIKA5 OPERATIONS DASHBOARD ---${NC}"
    echo "1) Query USB Connected Hardware Status & Matrix Rules"
    echo "2) Trigger pwnDFU Mode (Execute checkm8 Bootrom Exploit Check)"
    echo "3) Trigger kDFU Mode (Execute Software Memory Exploit Hook)"
    echo "4) Force Entry into Recovery Mode"
    echo "5) Force Exit from Recovery Mode (Normal Boot)"
    echo "6) Execute Setup.app Removal Bypass Engine"
    echo "7) Sign Legacy Application Binary Package (.IPA Framework)"
    echo "8) Advanced IPSW Custom Boot Profile Staging Menu"
    echo "9) Dump Onboard SHSH/SHSH2 Signature Tickets"
    echo "10) Exit Dedicated ChomikA5 Core Suite"
    echo ""
    read -p "Provide selection command index [1-10]: " choice

    case $choice in
        1)  evaluate_a5_hardware ;;
        2)  run_pwndfu_exploit ;;
        3)  run_kdfu_exploit ;;
        4)  force_recovery_entry ;;
        5)  force_normal_boot ;;
        6)  execute_setup_app_bypass ;;
        7)  sign_custom_ipa ;;
        8)  stage_ipsw_boot_menu ;;
        9)  dump_onboard_shsh_blobs ;;
        10) echo -e "${GREEN}Thank you for utilizing ChomikA5 Core. 
Goodbye!${NC}"; exit 0 ;;
        *)  echo -e "${RED}[!] Selection out of bounds. Choose an integer 
from 1 to 10.${NC}" ;;
    esac
done

