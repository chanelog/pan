#!/bin/bash
# ════════════════════════════════════════════════════════════
#   MAX PANEL — Premium VPS Tunneling Panel
#   Creator : MAX Team  |  v1.9-fixed
#   Ketik   : menu-max  untuk membuka panel
#   Support : Debian (all) & Ubuntu (all)
# ════════════════════════════════════════════════════════════

check_root() {
    [[ $EUID -ne 0 ]] && { echo -e "\n\033[1;31m  ✘  Jalankan sebagai root!\033[0m\n"; exit 1; }
}

check_os() {
    [[ ! -f /etc/os-release ]] && { echo -e "\n\033[1;31m  ✘  OS tidak dikenali!\033[0m\n"; exit 1; }
    source /etc/os-release 2>/dev/null
    local os_name os_like
    os_name=$(echo "${ID}" | tr '[:upper:]' '[:lower:]')
    os_like=$(echo "${ID_LIKE:-}" | tr '[:upper:]' '[:lower:]')
    if [[ "$os_name" != "debian" && "$os_name" != "ubuntu" ]] \
       && [[ "$os_like" != *"debian"* && "$os_like" != *"ubuntu"* ]]; then
        echo -e "\033[1;31m  ✘  Hanya Debian & Ubuntu yang didukung!\033[0m"; exit 1
    fi
    OS_NAME="${PRETTY_NAME:-$ID $VERSION_ID}"; OS_ID="$os_name"
    export OS_NAME OS_ID
}

# ════════════════════════════════════════════════════════════
#  KONSTANTA & PATH
# ════════════════════════════════════════════════════════════
DIR="/etc/maxpanel"; LOGDIR="/var/log/maxpanel"; BACKUPDIR="/root/maxpanel-backup"
THEMEF="$DIR/theme.conf";   DOMF="$DIR/domain.conf";  BOTF="$DIR/bot.conf"
STRF="$DIR/store.conf";     MLDB="$DIR/maxlogin.db";   LIMITF="$DIR/limit.conf"
VERSIONF="$DIR/version.txt"
SSH_DB="$DIR/ssh-users.db";        VMESS_DB="$DIR/vmess-users.db"
VLESS_DB="$DIR/vless-users.db";    TROJAN_DB="$DIR/trojan-users.db"
TROJANGO_DB="$DIR/trojango-users.db"; OVPN_DB="$DIR/openvpn-users.db"
WG_DB="$DIR/wireguard-users.db";   HY_DB="$DIR/hysteria-users.db"
SS_DB="$DIR/ss-users.db"
XRAY_CFG="/etc/xray/config.json";  XRAY_BIN="/usr/local/bin/xray"
XRAY_CRT="/etc/xray/xray.crt";     XRAY_KEY="/etc/xray/xray.key"
XRAY_LOG="/var/log/xray/access.log"
TROJANGO_DIR="/etc/trojan-go";      TROJANGO_CFG="$TROJANGO_DIR/config.json"
TROJANGO_BIN="/usr/local/bin/trojan-go"
HY_DIR="/etc/hysteria";             HY_CFG="$HY_DIR/config.yaml"
HY_BIN="/usr/local/bin/hysteria"
WG_DIR="/etc/wireguard";            WG_CFG="$WG_DIR/wg0.conf"
WG_CLIENT_DIR="$DIR/wg-clients"
# FIX: WS_DIR konsisten, WS_BIN di dalam WS_DIR
WS_DIR="/etc/maxpanel/ws";          WS_BIN="$WS_DIR/ws-proxy.py"
BIN_REPO="https://raw.githubusercontent.com/chanelog/bin/main"
XRAY_URL="${BIN_REPO}/Xray-linux-64.zip"
XRAY_URL_ARM="${BIN_REPO}/Xray-linux-arm64-v8a.zip"
TROJAN_GO_URL="${BIN_REPO}/trojan-go-linux-amd64.zip"
ACME_URL="${BIN_REPO}/acme.sh"
JQ_URL="${BIN_REPO}/jq-linux-amd64"
HYSTERIA_URL="https://github.com/apernet/hysteria/releases/latest/download/hysteria-linux-amd64"
NGINX_URL="${BIN_REPO}/nginx-1.28.0.tar.gz"
DROPBEAR_URL="${BIN_REPO}/dropbear-master.zip"
STUNNEL_URL="${BIN_REPO}/stunnel-master.zip"
WS_TUNNEL_URL="${BIN_REPO}/ws_tunnel.py"
WS_SSH_SERVER_URL="${BIN_REPO}/ws-ssh-server.py"
SCRIPT_VERSION="2.5"
SCRIPT_URL="https://raw.githubusercontent.com/chanelog/pan/main/setup-max.sh"
VERSION_URL="https://raw.githubusercontent.com/chanelog/pan/main/version-max.txt"

# ════════════════════════════════════════════════════════════
#  TEMA — 15 PREMIUM
# ════════════════════════════════════════════════════════════
load_theme() {
    local theme=1
    [[ -f "$THEMEF" ]] && theme=$(cat "$THEMEF" 2>/dev/null)
    case "$theme" in
        2)  A1='\033[38;5;51m';  A2='\033[1;36m';     A3='\033[0;36m'
            A4='\033[38;5;123m'; AL='\033[38;5;87m';  AT='\033[1;37m'; THEME_NAME="ARCTIC CYAN" ;;
        3)  A1='\033[38;5;46m';  A2='\033[1;32m';     A3='\033[38;5;40m'
            A4='\033[38;5;118m'; AL='\033[38;5;82m';  AT='\033[1;37m'; THEME_NAME="MATRIX GREEN" ;;
        4)  A1='\033[38;5;220m'; A2='\033[38;5;226m'; A3='\033[38;5;214m'
            A4='\033[38;5;208m'; AL='\033[38;5;228m'; AT='\033[1;37m'; THEME_NAME="ROYAL GOLD" ;;
        5)  A1='\033[38;5;196m'; A2='\033[1;31m';     A3='\033[38;5;203m'
            A4='\033[38;5;197m'; AL='\033[38;5;204m'; AT='\033[1;37m'; THEME_NAME="CRIMSON RED" ;;
        6)  A1='\033[38;5;213m'; A2='\033[38;5;218m'; A3='\033[38;5;219m'
            A4='\033[38;5;211m'; AL='\033[38;5;225m'; AT='\033[1;37m'; THEME_NAME="SAKURA PINK" ;;
        7)  A1='\033[1;37m';     A2='\033[1;37m';     A3='\033[38;5;51m'
            A4='\033[1;33m';     AL='\033[38;5;196m'; AT='\033[1;37m'; THEME_NAME="RAINBOW" ;;
        8)  A1='\033[38;5;27m';  A2='\033[38;5;33m';  A3='\033[38;5;39m'
            A4='\033[38;5;45m';  AL='\033[38;5;81m';  AT='\033[1;37m'; THEME_NAME="OCEAN BLUE" ;;
        9)  A1='\033[38;5;202m'; A2='\033[38;5;208m'; A3='\033[38;5;214m'
            A4='\033[38;5;220m'; AL='\033[38;5;215m'; AT='\033[1;37m'; THEME_NAME="SUNSET ORANGE" ;;
        10) A1='\033[38;5;239m'; A2='\033[38;5;245m'; A3='\033[38;5;250m'
            A4='\033[38;5;153m'; AL='\033[38;5;189m'; AT='\033[1;37m'; THEME_NAME="MIDNIGHT" ;;
        11) A1='\033[38;5;35m';  A2='\033[38;5;41m';  A3='\033[38;5;48m'
            A4='\033[38;5;85m';  AL='\033[38;5;121m'; AT='\033[1;37m'; THEME_NAME="EMERALD" ;;
        12) A1='\033[38;5;99m';  A2='\033[38;5;105m'; A3='\033[38;5;111m'
            A4='\033[38;5;183m'; AL='\033[38;5;189m'; AT='\033[1;37m'; THEME_NAME="LAVENDER" ;;
        13) A1='\033[38;5;210m'; A2='\033[38;5;216m'; A3='\033[38;5;222m'
            A4='\033[38;5;217m'; AL='\033[38;5;224m'; AT='\033[1;37m'; THEME_NAME="ROSE GOLD" ;;
        14) A1='\033[38;5;195m'; A2='\033[38;5;231m'; A3='\033[38;5;159m'
            A4='\033[38;5;123m'; AL='\033[38;5;255m'; AT='\033[38;5;231m'; THEME_NAME="ICE WHITE" ;;
        15) A1='\033[38;5;129m'; A2='\033[38;5;135m'; A3='\033[38;5;141m'
            A4='\033[38;5;201m'; AL='\033[38;5;171m'; AT='\033[1;37m'; THEME_NAME="NEON PURPLE" ;;
        *)  A1='\033[38;5;135m'; A2='\033[1;35m';     A3='\033[38;5;141m'
            A4='\033[1;33m';     AL='\033[38;5;141m'; AT='\033[38;5;231m'; THEME_NAME="VIOLET" ;;
    esac
    NC='\033[0m'; BLD='\033[1m'; DIM='\033[2m'; IT='\033[3m'
    W='\033[1;37m'; LG='\033[1;32m'; LR='\033[1;31m'; LC='\033[1;36m'; Y='\033[1;33m'
    export A1 A2 A3 A4 AL AT NC BLD DIM IT W LG LR LC Y THEME_NAME
}

# ════════════════════════════════════════════════════════════
#  UTILS
# ════════════════════════════════════════════════════════════
_DASH="───────────────────────────────────────────────────────────────"
ok()    { echo -e "  ${A2}✔${NC}  $*"; }
inf()   { echo -e "  ${A3}➜${NC}  $*"; }
warn()  { echo -e "  ${A4}⚠${NC}  $*"; }
err()   { echo -e "  \033[1;31m✘${NC}  $*"; }
pause() { echo ""; echo -ne "  ${DIM}╰─ [ Enter ] kembali ke menu...${NC}"; read -r; }
_top()  { echo -e "  ${A1}${_DASH}${NC}"; }
_bot()  { echo -e "  ${A1}${_DASH}${NC}"; }
_sep()  { echo -e "  ${A1}${_DASH}${NC}"; }
_btn()  { printf "  %b\n" "$1"; }

_apply_block() {
    local marker="$1" file="$2"
    [[ -z "$marker" || -z "$file" ]] && return 1
    [[ ! -f "$file" ]] && { mkdir -p "$(dirname "$file")"; : > "$file"; }
    sed -i "/^# >>> MAXPANEL-${marker} >>>$/,/^# <<< MAXPANEL-${marker} <<<$/d" "$file" 2>/dev/null
    { echo ""; echo "# >>> MAXPANEL-${marker} >>>"; cat; echo "# <<< MAXPANEL-${marker} <<<"; } >> "$file"
}

get_ip() {
    local ip
    for src in "curl -s4 --max-time 5 ifconfig.me" "curl -s4 --max-time 5 icanhazip.com" "curl -s4 --max-time 5 api.ipify.org"; do
        ip=$(eval "$src" 2>/dev/null | tr -d '[:space:]')
        [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] && { echo "$ip"; return; }
    done
    hostname -I 2>/dev/null | awk '{print $1}'
}
get_domain() { [[ -f "$DOMF" ]] && cat "$DOMF" 2>/dev/null || get_ip; }
get_iface()  { ip -4 route ls 2>/dev/null | awk '/default/ {print $5; exit}'; }
rand_pass()  { tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12; }
rand_uuid()  {
    if command -v uuidgen &>/dev/null; then uuidgen
    elif [[ -r /proc/sys/kernel/random/uuid ]]; then cat /proc/sys/kernel/random/uuid
    else python3 -c "import uuid;print(uuid.uuid4())" 2>/dev/null; fi
}
mk_exp()      { TZ="Asia/Jakarta" date -d "+${1:-30} days" +"%Y-%m-%d"; }
days_left()   {
    local exp_ts now_ts
    exp_ts=$(TZ="Asia/Jakarta" date -d "${1} 23:59:59" +%s 2>/dev/null || echo 0)
    now_ts=$(TZ="Asia/Jakarta" date +%s)
    local d=$(( (exp_ts - now_ts) / 86400 )); [[ $d -lt 0 ]] && d=0; echo "$d"
}
is_expired()  { [[ "$(TZ="Asia/Jakarta" date +%Y-%m-%d)" > "$1" ]]; }
verify_binary() {
    local sz; sz=$(stat -c%s "$1" 2>/dev/null || echo 0)
    [[ ! -f "$1" || "$sz" -lt "${2:-100000}" ]] && return 1; return 0
}
dl() {
    local url="$1" out="$2"
    wget --tries=3 --timeout=30 -q -O "$out" "$url" 2>/dev/null && [[ -s "$out" ]] && return 0
    rm -f "$out" 2>/dev/null
    curl -fsSL --retry 3 --max-time 30 -o "$out" "$url" 2>/dev/null && [[ -s "$out" ]] && return 0
    rm -f "$out" 2>/dev/null; return 1
}
is_up()     { systemctl is-active --quiet "$1" 2>/dev/null; }
svc_badge() { is_up "$1" && printf '%b' "${LG}●${NC}" || printf '%b' "${LR}●${NC}"; }

total_users_all() {
    local t=0 f cnt
    for f in "$SSH_DB" "$VMESS_DB" "$VLESS_DB" "$TROJAN_DB" "$TROJANGO_DB" \
             "$OVPN_DB" "$WG_DB" "$HY_DB" "$SS_DB"; do
        [[ -f "$f" ]] && { cnt=$(grep -c '' "$f" 2>/dev/null); [[ "$cnt" =~ ^[0-9]+$ ]] && t=$((t+cnt)); }
    done; echo "$t"
}
exp_users_all() {
    local t=0 f td; td=$(TZ="Asia/Jakarta" date +%Y-%m-%d)
    for f in "$SSH_DB" "$VMESS_DB" "$VLESS_DB" "$TROJAN_DB" "$TROJANGO_DB" \
             "$OVPN_DB" "$WG_DB" "$HY_DB" "$SS_DB"; do
        [[ -f "$f" ]] && t=$((t + $(awk -F'|' -v d="$td" '$3<d{c++}END{print c+0}' "$f" 2>/dev/null)))
    done; echo "$t"
}

get_maxlogin() { grep "^${1}|" "$MLDB" 2>/dev/null | cut -d'|' -f2 | head -1; }
set_maxlogin() { mkdir -p "$DIR"; touch "$MLDB"; sed -i "/^${1}|/d" "$MLDB" 2>/dev/null; echo "${1}|${2}" >> "$MLDB"; }
del_maxlogin() { sed -i "/^${1}|/d" "$MLDB" 2>/dev/null; }

_tg_send() {
    [[ ! -f "$BOTF" ]] && return
    source "$BOTF" 2>/dev/null
    [[ -n "${BOT_TOKEN:-}" && -n "${CHAT_ID:-}" ]] && \
        curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
            -d "chat_id=${CHAT_ID}" -d "text=${1}" -d "parse_mode=HTML" &>/dev/null
}

# ════════════════════════════════════════════════════════════
#  BANNER / LOGO
# ════════════════════════════════════════════════════════════
draw_logo() {
    local cur_theme L1 L2 L3 L4 L5
    cur_theme=$(cat "$THEMEF" 2>/dev/null || echo 1)
    if [[ "$cur_theme" == "7" ]]; then
        L1='\033[38;5;196m'; L2='\033[38;5;214m'; L3='\033[38;5;226m'
        L4='\033[38;5;82m';  L5='\033[38;5;51m'
    else L1="$AL"; L2="$AL"; L3="$A3"; L4="$AL"; L5="$A3"; fi
    echo ""
    echo -e "  ${A1}${_DASH}${NC}"
    echo -e "  ${L1}${BLD}  ███╗   ███╗ █████╗ ██╗  ██╗    ██████╗  █████╗ ███╗   ██╗ ${NC}"
    echo -e "  ${L2}${BLD}  ████╗ ████║██╔══██╗╚██╗██╔╝    ██╔══██╗██╔══██╗████╗  ██║ ${NC}"
    echo -e "  ${L3}${BLD}  ██╔████╔██║███████║ ╚███╔╝     ██████╔╝███████║██╔██╗ ██║ ${NC}"
    echo -e "  ${L4}${BLD}  ██║╚██╔╝██║██╔══██║ ██╔██╗     ██╔═══╝ ██╔══██║██║╚██╗██║ ${NC}"
    echo -e "  ${L5}${BLD}  ██║ ╚═╝ ██║██║  ██║██╔╝ ██╗    ██║     ██║  ██║██║ ╚████║ ${NC}"
    echo -e "  ${DIM}  ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝ ${NC}"
    echo -e "  ${A1}${_DASH}${NC}"
    echo -e "  ${A4}             ✦  * MAX PREMIUM TUNNELING PANEL *  ✦      ${NC}"
    echo -e "  ${DIM}       +---------------- ${A2}[ ALL-IN-ONE ]${DIM} ---------------+  ${NC}"
    echo -e "  ${A1}${_DASH}${NC}"
}

# ════════════════════════════════════════════════════════════
#  INFO VPS
#  FIX: Service badge 2 baris — Nginx & WS-SSH tampil sejajar SSH & Xray
# ════════════════════════════════════════════════════════════
draw_vps() {
    local ip domain ram_u ram_t cpu du dt du_pct os hn total expc now_time now_date
    ip=$(get_ip); domain=$(get_domain)
    ram_u=$(free -m 2>/dev/null | awk '/^Mem/{print $3}')
    ram_t=$(free -m 2>/dev/null | awk '/^Mem/{print $2}')
    cpu=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{printf "%.1f",$2}' || echo "0.0")
    du=$(df -h / 2>/dev/null | awk 'NR==2{print $3}'); dt=$(df -h / 2>/dev/null | awk 'NR==2{print $2}')
    du_pct=$(df / 2>/dev/null | awk 'NR==2{print $5}' | tr -d '%')
    os=$(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || echo "Linux"); hn=$(hostname)
    total=$(total_users_all); expc=$(exp_users_all)
    now_time=$(TZ="Asia/Jakarta" date "+%H:%M"); now_date=$(TZ="Asia/Jakarta" date "+%d/%m/%Y")
    local ram_pct=0
    [[ "$ram_t" -gt 0 ]] 2>/dev/null && ram_pct=$(( ram_u * 100 / ram_t ))
    local brand="MAX PANEL"
    [[ -f "$STRF" ]] && { source "$STRF" 2>/dev/null; brand="${BRAND:-MAX PANEL}"; }
    local tema_display
    if [[ "${THEME_NAME:-}" == "RAINBOW" ]]; then
        tema_display="\033[38;5;196mR\033[38;5;208mA\033[38;5;226mI\033[38;5;82mN\033[38;5;51mB\033[38;5;171mO\033[38;5;213mW\033[0m"
    else tema_display="${AL}${THEME_NAME}${NC}"; fi

    echo ""
    echo -e "  ${A1}${_DASH}${NC}"
    echo -e "  ${A4}◈${NC} ${BLD}${A4}INFO VPS${NC}  ${DIM}${now_time}  │  ${now_date}${NC}"
    echo -e "  ${A1}${_DASH}${NC}"
    local os_short domain_short
    os_short=$(echo "$os" | cut -c1-14); domain_short=$(echo "$domain" | cut -c1-18)
    _btn "  ${DIM}HOST    ${NC}${A1}│${NC} ${A3}$(printf '%-16s' "$hn")${NC}  ${DIM}OS    ${NC}${A1}│${NC} ${W}${os_short}${NC}"
    echo -e "  ${A1}${_DASH}${NC}"
    _btn "  ${DIM}IP ADDR ${NC}${A1}│${NC} ${A3}$(printf '%-16s' "$ip")${NC}  ${DIM}DOMAIN  ${NC}${A1}│${NC} ${W}${domain_short}${NC}"
    echo -e "  ${A1}${_DASH}${NC}"
    _btn "  ${DIM}USER    ${NC}${A1}│${NC} ${Y}$(printf '%-16s' "$total")${NC}  ${DIM}BRAND   ${NC}${A1}│${NC} ${A4}${brand}${NC}"
    echo -e "  ${A1}${_DASH}${NC}"

    _mini_bar() {
        local pct=${1:-0} filled empty color bar="" i
        filled=$(( pct * 10 / 100 )); [[ $filled -gt 10 ]] && filled=10; empty=$(( 10 - filled ))
        if [[ $pct -ge 80 ]]; then color="$LR"; elif [[ $pct -ge 60 ]]; then color="$Y"; else color="$LG"; fi
        for ((i=0;i<filled;i++)); do bar+="█"; done
        for ((i=0;i<empty;i++)); do bar+="░"; done
        printf "${color}%s${NC}" "$bar"
    }

    local cpu_pct=${cpu%.*}; [[ -z "$cpu_pct" || "$cpu_pct" == "?" ]] && cpu_pct=0
    local cpu_col ram_col dsk_col dsk_pct=${du_pct:-0}
    [[ $cpu_pct -ge 80 ]] && cpu_col="$LR" || { [[ $cpu_pct -ge 60 ]] && cpu_col="$Y" || cpu_col="$LG"; }
    [[ $ram_pct -ge 80 ]] && ram_col="$LR" || { [[ $ram_pct -ge 60 ]] && ram_col="$Y" || ram_col="$A3"; }
    [[ $dsk_pct -ge 80 ]] && dsk_col="$LR" || { [[ $dsk_pct -ge 60 ]] && dsk_col="$Y" || dsk_col="$Y"; }
    local cpu_bar ram_bar disk_bar
    cpu_bar=$(_mini_bar "$cpu_pct"); ram_bar=$(_mini_bar "$ram_pct"); disk_bar=$(_mini_bar "$dsk_pct")

    _btn "  ${DIM}CPU${NC} ${cpu_col}${cpu}%${NC}  ${cpu_bar}  ${A1}│${NC}  ${DIM}RAM${NC} ${ram_col}${ram_u}/${ram_t}MB${NC}  ${ram_bar}"
    echo -e "  ${A1}${_DASH}${NC}"
    _btn "  ${DIM}DISK${NC} ${dsk_col}${du}/${dt}${NC}  ${disk_bar}"
    echo -e "  ${A1}${_DASH}${NC}"

    # ── FIX: 2 baris badge — Nginx & WS-SSH tampil sejajar SSH dan Xray ──
    local ssh_b dr_b stun_b ngx_b ws_b xray_b tgo_b hy_b ovpn_b wg_b
    ssh_b=$(svc_badge ssh); dr_b=$(svc_badge dropbear); stun_b=$(svc_badge stunnel4)
    ngx_b=$(svc_badge nginx)           # FIX: Nginx badge
    ws_b=$(svc_badge ws-ssh-proxy)     # FIX: WS-SSH badge (nama service konsisten)
    xray_b=$(svc_badge xray); tgo_b=$(svc_badge trojan-go); hy_b=$(svc_badge hysteria-server)
    ovpn_b=$(svc_badge openvpn); wg_b=$(svc_badge "wg-quick@wg0")

    # Baris 1: SSH | Dropbear | Stunnel | Nginx | WS-SSH
    _btn "  ${DIM}SSH${NC}${ssh_b}  ${DIM}DR${NC}${dr_b}  ${DIM}STN${NC}${stun_b}  ${DIM}NGX${NC}${ngx_b}  ${DIM}WS${NC}${ws_b}"
    # Baris 2: Xray | Trojan-Go | Hysteria | OpenVPN | WireGuard
    _btn "  ${DIM}XRY${NC}${xray_b}  ${DIM}TGO${NC}${tgo_b}  ${DIM}HY${NC}${hy_b}  ${DIM}OVPN${NC}${ovpn_b}  ${DIM}WG${NC}${wg_b}"

    echo -e "  ${A1}${_DASH}${NC}"
    _btn "  ${DIM}AKUN${NC} ${A3}${total}${NC}  ${A1}│${NC}  ${DIM}EXP${NC} ${LR}${expc}${NC}  ${A1}│${NC}  ${DIM}TEMA${NC}  ${tema_display}"
    echo -e "  ${A1}${_DASH}${NC}"
    echo ""
}

show_header() { clear; load_theme; draw_logo; draw_vps; }

# ════════════════════════════════════════════════════════════
#  ACCOUNT BOX — SSH (FIX: tampilkan info Nginx & WS-SSH)
# ════════════════════════════════════════════════════════════
show_box_ssh() {
    local u="$1" p="$2" exp="$3" maxl="${4:-2}"
    local ip dom; ip=$(get_ip); dom=$(get_domain)
    local brand="MAX PANEL"
    [[ -f "$STRF" ]] && { source "$STRF" 2>/dev/null; brand="${BRAND:-MAX PANEL}"; }
    echo ""
    echo -e "  ${LG}✅ Akun SSH/OpenSSH — ${brand}${NC}"
    echo -e "  ${A1}┌─────────────────────────────────────────────────────────${NC}"
    printf  "  ${A1}│${NC} 👤 ${DIM}Username${NC} : ${BLD}${W}%s${NC}\n" "$u"
    printf  "  ${A1}│${NC} 🔑 ${DIM}Password${NC} : ${BLD}${A3}%s${NC}\n" "$p"
    echo -e "  ${A1}├─────────────────────────────────────────────────────────${NC}"
    printf  "  ${A1}│${NC} 🖥  ${DIM}IP Publik${NC} : ${LG}%s${NC}\n" "$ip"
    printf  "  ${A1}│${NC} 🌐 ${DIM}Host     ${NC} : ${W}%s${NC}\n" "$dom"
    printf  "  ${A1}│${NC} 🔌 ${DIM}Port SSH ${NC}: ${Y}22${NC}\n"
    printf  "  ${A1}│${NC} 🔌 ${DIM}Dropbear ${NC}: ${Y}109, 143${NC}\n"
    printf  "  ${A1}│${NC} 🔒 ${DIM}Stunnel  ${NC}: ${Y}445 (→DB:109)  777 (→SSH:22)${NC}\n"
    echo -e "  ${A1}├── ${LG}Nginx (aktif sebagai reverse-proxy)${NC} ${A1}──────────────${NC}"
    printf  "  ${A1}│${NC} 🌐 ${DIM}HTTP     ${NC}: ${Y}ws://%s:80/ws-ssh${NC}\n" "$dom"
    printf  "  ${A1}│${NC} 🔒 ${DIM}HTTPS    ${NC}: ${Y}wss://%s:443/ws-ssh${NC}\n" "$dom"
    printf  "  ${A1}│${NC} 🔒 ${DIM}Alt-TLS  ${NC}: ${Y}wss://%s:8443/ws-ssh${NC}\n" "$dom"
    printf  "  ${A1}│${NC} 📡 ${DIM}OpenVPN  ${NC}: ${Y}TCP 1194 / UDP 2200${NC}\n"
    echo -e "  ${A1}├─────────────────────────────────────────────────────────${NC}"
    printf  "  ${A1}│${NC} 🔒 ${DIM}MaxLogin${NC} : ${Y}%s device${NC}\n" "$maxl"
    printf  "  ${A1}│${NC} 📅 ${DIM}Expired ${NC} : ${Y}%s${NC}\n" "$exp"
    echo -e "  ${A1}└─────────────────────────────────────────────────────────${NC}"
    echo ""
    _show_ssh_payload "$u" "$p" "$ip" "$dom"
}

_show_ssh_payload() {
    local u="$1" p="$2" ip="$3" dom="$4"
    echo -e "  ${A4}╔══════════════════════════════════════════════════════════${NC}"
    echo -e "  ${A4}║${NC}  ${BLD}📦 PAYLOAD SSH WEBSOCKET${NC}"
    echo -e "  ${A4}╠══════════════════════════════════════════════════════════${NC}"
    echo ""
    echo -e "  ${Y}▸ Payload 1 — WS HTTP via Nginx port 80${NC}"
    echo -e "  ${A1}┌──────────────────────────────────────────${NC}"
    echo -e "  ${A1}│${NC} ${BLD}Server   :${NC} ${W}${dom}${NC}  ${BLD}Port:${NC} ${Y}80${NC}"
    echo -e "  ${A1}│${NC} ${BLD}Username :${NC} ${W}${u}${NC}  ${BLD}Password:${NC} ${W}${p}${NC}"
    echo -e "  ${A1}│${NC} ${BLD}Path WS  :${NC} ${Y}/ws-ssh${NC}"
    echo -e "  ${A1}│${NC} ${BLD}Payload  :${NC}"
    echo -e "  ${A1}│${NC}   ${LG}GET / HTTP/1.1[crlf]Host: ${dom}[crlf]${NC}"
    echo -e "  ${A1}│${NC}   ${LG}Upgrade: websocket[crlf]Connection: Upgrade[crlf][crlf]${NC}"
    echo -e "  ${A1}└──────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${Y}▸ Payload 2 — WS TLS via Nginx port 443${NC}"
    echo -e "  ${A1}┌──────────────────────────────────────────${NC}"
    echo -e "  ${A1}│${NC} ${BLD}Server   :${NC} ${W}${dom}${NC}  ${BLD}Port:${NC} ${Y}443${NC}  ${BLD}SSL:${NC} ${LG}ON${NC}"
    echo -e "  ${A1}│${NC} ${BLD}Username :${NC} ${W}${u}${NC}  ${BLD}Password:${NC} ${W}${p}${NC}"
    echo -e "  ${A1}│${NC} ${BLD}Path WS  :${NC} ${Y}/ws-ssh${NC}  ${BLD}SNI:${NC} ${Y}${dom}${NC}"
    echo -e "  ${A1}│${NC} ${BLD}Payload  :${NC}"
    echo -e "  ${A1}│${NC}   ${LG}GET / HTTP/1.1[crlf]Host: ${dom}[crlf]${NC}"
    echo -e "  ${A1}│${NC}   ${LG}Upgrade: websocket[crlf]Connection: Upgrade[crlf][crlf]${NC}"
    echo -e "  ${A1}└──────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${Y}▸ Payload 3 — Stunnel SSL (445 → Dropbear / 777 → SSH)${NC}"
    echo -e "  ${A1}┌──────────────────────────────────────────${NC}"
    echo -e "  ${A1}│${NC} ${BLD}Server:${NC} ${W}${dom}${NC}  ${DIM}(IP: ${ip})${NC}"
    echo -e "  ${A1}│${NC} ${BLD}Port 445${NC} → Dropbear:109  |  ${BLD}Port 777${NC} → SSH:22"
    echo -e "  ${A1}│${NC} ${BLD}Username :${NC} ${W}${u}${NC}  ${BLD}Password:${NC} ${W}${p}${NC}"
    echo -e "  ${A1}│${NC} ${BLD}Mode     :${NC} ${Y}SSL Tunnel${NC}  ${DIM}(tanpa payload)${NC}"
    echo -e "  ${A1}└──────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${Y}▸ Payload 4 — HTTP Proxy CONNECT${NC}"
    echo -e "  ${A1}┌──────────────────────────────────────────${NC}"
    echo -e "  ${A1}│${NC} ${BLD}Server:${NC} ${W}${dom}${NC}  ${BLD}Port:${NC} ${Y}80${NC}"
    echo -e "  ${A1}│${NC} ${BLD}Payload  :${NC}"
    echo -e "  ${A1}│${NC}   ${LG}CONNECT [host_port] HTTP/1.1[crlf]${NC}"
    echo -e "  ${A1}│${NC}   ${LG}Host: ${dom}[crlf]Upgrade: websocket[crlf][crlf]${NC}"
    echo -e "  ${A1}└──────────────────────────────────────────${NC}"
    echo ""
    echo -e "  ${A4}╚══════════════════════════════════════════════════════════${NC}"
    echo ""
}

show_box_xray() {
    local proto="$1" u="$2" id="$3" exp="$4" maxl="${5:-2}"
    local ip dom; ip=$(get_ip); dom=$(get_domain)
    local brand="MAX PANEL"
    [[ -f "$STRF" ]] && { source "$STRF" 2>/dev/null; brand="${BRAND:-MAX PANEL}"; }
    echo ""
    echo -e "  ${LG}✅ Akun ${proto} — ${brand}${NC}"
    echo -e "  ${A1}┌─────────────────────────────────────────────────────────${NC}"
    printf  "  ${A1}│${NC} 👤 ${DIM}Remark   ${NC}: ${BLD}${W}%s${NC}\n" "$u"
    case "$proto" in
        VMess|VLess) printf "  ${A1}│${NC} 🔑 ${DIM}UUID     ${NC}: ${A3}%s${NC}\n" "$id" ;;
        *)           printf "  ${A1}│${NC} 🔑 ${DIM}Password ${NC}: ${A3}%s${NC}\n" "$id" ;;
    esac
    echo -e "  ${A1}├─────────────────────────────────────────────────────────${NC}"
    printf  "  ${A1}│${NC} 🌐 ${DIM}Host     ${NC}: ${W}%s${NC}\n" "$dom"
    printf  "  ${A1}│${NC} 🖥  ${DIM}IP       ${NC}: ${LG}%s${NC}\n" "$ip"
    echo -e "  ${A1}├── ${LG}via Nginx (aktif sebagai TLS terminator)${NC} ${A1}──────────${NC}"
    case "$proto" in
        VMess)
            printf "  ${A1}│${NC} 🔌 ${DIM}WS HTTP  ${NC}: ${Y}80  /vmess${NC}\n"
            printf "  ${A1}│${NC} 🔌 ${DIM}WS TLS   ${NC}: ${Y}443 /vmess${NC}" ;;
        VLess)
            printf "  ${A1}│${NC} 🔌 ${DIM}WS HTTP  ${NC}: ${Y}80  /vless${NC}\n"
            printf "  ${A1}│${NC} 🔌 ${DIM}WS TLS   ${NC}: ${Y}443 /vless${NC}\n"
            printf "  ${A1}│${NC} 🔌 ${DIM}gRPC TLS ${NC}: ${Y}443/8443 svc:vless-grpc${NC}" ;;
        Trojan)
            printf "  ${A1}│${NC} 🔌 ${DIM}WS TLS   ${NC}: ${Y}443 /trojan-ws${NC}\n"
            printf "  ${A1}│${NC} 🔌 ${DIM}gRPC TLS ${NC}: ${Y}443/8443 svc:trojan-grpc${NC}" ;;
    esac
    echo ""
    echo -e "  ${A1}├─────────────────────────────────────────────────────────${NC}"
    printf  "  ${A1}│${NC} 🔒 ${DIM}MaxLogin${NC} : ${Y}%s device${NC}\n" "$maxl"
    printf  "  ${A1}│${NC} 📅 ${DIM}Expired ${NC} : ${Y}%s${NC}\n" "$exp"
    echo -e "  ${A1}└─────────────────────────────────────────────────────────${NC}"
    echo ""
}

_show_xray_config() {
    local proto="$1" u="$2" uuid_or_pass="$3" dom="$4"
    echo ""
    echo -e "  ${A4}╔══════════════════════════════════════════════════════════${NC}"
    echo -e "  ${A4}║${NC}  ${BLD}📋 CONFIG XRAY CLIENT — ${proto}${NC}"
    echo -e "  ${A4}╚══════════════════════════════════════════════════════════${NC}"
    echo ""
    case "$proto" in
    VMess)
        echo -e "  ${Y}▸ VMess WS TLS (443)${NC}"
        printf '{"v":"2","ps":"%s-TLS","add":"%s","port":"443","id":"%s","aid":"0","net":"ws","type":"none","host":"%s","path":"/vmess","tls":"tls","sni":"%s"}\n' \
            "$u" "$dom" "$uuid_or_pass" "$dom" "$dom"
        echo ""
        echo -e "  ${Y}▸ VMess WS HTTP (80)${NC}"
        printf '{"v":"2","ps":"%s-HTTP","add":"%s","port":"80","id":"%s","aid":"0","net":"ws","type":"none","host":"%s","path":"/vmess","tls":"none"}\n' \
            "$u" "$dom" "$uuid_or_pass" "$dom" ;;
    VLess)
        echo -e "  ${Y}▸ VLess WS TLS (443)${NC}"
        echo "vless://${uuid_or_pass}@${dom}:443?path=/vless&security=tls&encryption=none&host=${dom}&type=ws&sni=${dom}#${u}-TLS"
        echo ""
        echo -e "  ${Y}▸ VLess gRPC TLS (443)${NC}"
        echo "vless://${uuid_or_pass}@${dom}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${dom}#${u}-gRPC" ;;
    Trojan)
        echo -e "  ${Y}▸ Trojan WS TLS (443)${NC}"
        echo "trojan://${uuid_or_pass}@${dom}:443?path=/trojan-ws&security=tls&host=${dom}&type=ws&sni=${dom}#${u}-WS"
        echo ""
        echo -e "  ${Y}▸ Trojan gRPC TLS (443)${NC}"
        echo "trojan://${uuid_or_pass}@${dom}:443?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=${dom}#${u}-gRPC" ;;
    esac
    echo ""
    echo -e "  ${DIM}💡 Salin ke v2rayN / NekoBox / Hiddify / Clash${NC}"
    echo -e "  ${A4}══════════════════════════════════════════════════════════${NC}"
    echo ""
}
# ════════════════════════════════════════════════════════════
#  INSTALLER — Dependencies
# ════════════════════════════════════════════════════════════
install_deps() {
    inf "Update apt & install dependensi inti..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq 2>/dev/null || true
    apt-get install -y -qq \
        wget curl jq unzip zip tar net-tools openvpn easy-rsa \
        vnstat htop iftop bmon screen tmux cron rsyslog uuid-runtime sudo lsb-release \
        fail2ban git build-essential libssl-dev python3 python3-pip dnsutils socat \
        figlet wireguard wireguard-tools resolvconf qrencode bc \
        iptables iptables-persistent netfilter-persistent ca-certificates \
        gnupg2 lsof psmisc openssl python3-websockify 2>/dev/null || true
    apt-get install -y -qq jq 2>/dev/null || true
    ok "Dependensi terpasang"
}

# ════════════════════════════════════════════════════════════
#  INSTALLER — Download semua bin dari chanelog/bin
# ════════════════════════════════════════════════════════════
install_all_bins() {
    inf "Download binary dari ${W}chanelog/bin${NC}..."
    local tmp; tmp=$(mktemp -d)
    local ok_count=0 fail_count=0 arch; arch=$(uname -m)

    _dl_bin() {
        local url="$1" dest="$2" min="${3:-100000}" label="${4:-$(basename "$dest")}"
        inf "  ↓ $label"
        if dl "$url" "$dest" && chmod +x "$dest" && verify_binary "$dest" "$min"; then
            ok "    ✓ $label"; ok_count=$((ok_count+1)); return 0
        else
            warn "    ✗ Gagal $label"; rm -f "$dest" 2>/dev/null; fail_count=$((fail_count+1)); return 1
        fi
    }

    _dl_zip() {
        local url="$1" zname="$2" bin_in_zip="$3" dest="$4" min="${5:-500000}" label="${6:-$(basename "$dest")}"
        inf "  ↓ $label (zip)"
        if dl "$url" "$tmp/$zname"; then
            unzip -qo "$tmp/$zname" -d "$tmp/${zname%.zip}" 2>/dev/null
            local found; found=$(find "$tmp/${zname%.zip}" -type f -name "$bin_in_zip" 2>/dev/null | head -1)
            if [[ -n "$found" ]] && verify_binary "$found" "$min"; then
                install -m755 "$found" "$dest"; ok "    ✓ $label"; ok_count=$((ok_count+1)); return 0
            fi
        fi
        warn "    ✗ Gagal $label"; fail_count=$((fail_count+1)); return 1
    }

    echo -e "  ${A4}◈ Repo: ${W}${BIN_REPO}${NC}"; echo -e "  ${A1}${_DASH}${NC}"

    [[ ! -x "$XRAY_BIN" ]] && {
        case "$arch" in
            aarch64|arm64) _dl_zip "$XRAY_URL_ARM" "Xray-linux-arm64-v8a.zip" "xray" "$XRAY_BIN" 1000000 "Xray (arm64)" ;;
            *)             _dl_zip "$XRAY_URL"     "Xray-linux-64.zip"        "xray" "$XRAY_BIN" 1000000 "Xray (amd64)" ;;
        esac
    } || ok "  ✓ Xray ada — skip"

    [[ ! -x "$TROJANGO_BIN" ]] && { mkdir -p "$TROJANGO_DIR"
        _dl_zip "$TROJAN_GO_URL" "trojan-go-linux-amd64.zip" "trojan-go" "$TROJANGO_BIN" 1000000 "Trojan-Go"
    } || ok "  ✓ Trojan-Go ada — skip"


    command -v jq &>/dev/null || _dl_bin "$JQ_URL" "/usr/local/bin/jq" 500000 "jq"


    local ACME_BIN="$HOME/.acme.sh/acme.sh"
    if [[ ! -x "$ACME_BIN" ]]; then
        inf "  ↓ acme.sh"
        local ta; ta=$(mktemp)
        if dl "$ACME_URL" "$ta"; then
            chmod +x "$ta"; bash "$ta" --install --home "$HOME/.acme.sh" --noprofile &>/dev/null
            rm -f "$ta"
            [[ -x "$ACME_BIN" ]] && { ok "    ✓ acme.sh"; ok_count=$((ok_count+1)); } \
                                  || { warn "    ✗ acme.sh gagal"; fail_count=$((fail_count+1)); }
        else warn "    ✗ Gagal download acme.sh"; fail_count=$((fail_count+1)); fi
    else ok "  ✓ acme.sh ada — skip"; fi

    rm -rf "$tmp"
    echo -e "  ${A1}${_DASH}${NC}"
    echo -e "  ${BLD}Selesai${NC}: ${LG}${ok_count} berhasil${NC}, ${Y}${fail_count} gagal${NC}"
    echo ""
}

# ════════════════════════════════════════════════════════════
#  INSTALLER — SSH + Dropbear + Stunnel
#  FIX: Dropbear -R flag (auto-generate key), service tidak crash
# ════════════════════════════════════════════════════════════
install_ssh() {
    inf "Konfigurasi OpenSSH (port 22)..."
    if ! grep -qE '^Port[[:space:]]+22$' /etc/ssh/sshd_config 2>/dev/null; then
        sed -i 's/^#\?Port .*/Port 22/' /etc/ssh/sshd_config 2>/dev/null
        grep -qE '^Port[[:space:]]+22$' /etc/ssh/sshd_config 2>/dev/null || echo "Port 22" >> /etc/ssh/sshd_config
    fi
    sed -i '/^Port[[:space:]]\+80$/d;/^Port[[:space:]]\+443$/d' /etc/ssh/sshd_config 2>/dev/null
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config 2>/dev/null
    sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config 2>/dev/null
    systemctl restart ssh 2>/dev/null || systemctl restart sshd 2>/dev/null
    ok "OpenSSH siap: port 22"

    inf "Install Dropbear (port 109, 143)..."
    local db_tmp; db_tmp=$(mktemp -d); local db_ok=0
    if dl "$DROPBEAR_URL" "$db_tmp/dropbear-master.zip"; then
        unzip -qo "$db_tmp/dropbear-master.zip" -d "$db_tmp/dropbear" 2>/dev/null
        local db_bin; db_bin=$(find "$db_tmp/dropbear" -type f -name "dropbear" ! -name "*.c" ! -name "*.h" 2>/dev/null | head -1)
        if [[ -n "$db_bin" ]] && verify_binary "$db_bin" 100000; then
            install -m755 "$db_bin" /usr/sbin/dropbear
            local dbk; dbk=$(find "$db_tmp/dropbear" -type f -name "dropbearkey" ! -name "*.c" 2>/dev/null | head -1)
            [[ -n "$dbk" ]] && install -m755 "$dbk" /usr/bin/dropbearkey
            db_ok=1
        fi
    fi
    rm -rf "$db_tmp"
    [[ "$db_ok" == "0" ]] && apt-get install -y -qq dropbear 2>/dev/null || true

    # Generate host keys (aman jika sudah ada)
    mkdir -p /etc/dropbear
    [[ ! -f /etc/dropbear/dropbear_rsa_host_key   ]] && dropbearkey -t rsa   -f /etc/dropbear/dropbear_rsa_host_key   &>/dev/null || true
    [[ ! -f /etc/dropbear/dropbear_ecdsa_host_key ]] && dropbearkey -t ecdsa -f /etc/dropbear/dropbear_ecdsa_host_key &>/dev/null || true
    [[ ! -f /etc/dropbear/dropbear_ed25519_host_key ]] && dropbearkey -t ed25519 -f /etc/dropbear/dropbear_ed25519_host_key &>/dev/null || true

    grep -qx '/bin/false'        /etc/shells 2>/dev/null || echo '/bin/false'        >> /etc/shells
    grep -qx '/usr/sbin/nologin' /etc/shells 2>/dev/null || echo '/usr/sbin/nologin' >> /etc/shells

    # FIX: ExecStart pakai -R (auto-gen key jika belum ada) — tidak crash
    if [[ ! -f /lib/systemd/system/dropbear.service ]] && [[ ! -f /etc/systemd/system/dropbear.service ]]; then
        cat > /etc/systemd/system/dropbear.service <<'DBSVC'
[Unit]
Description=MAX Panel — Dropbear SSH
After=network.target

[Service]
Type=forking
ExecStart=/usr/sbin/dropbear -p 109 -p 143 -W 65536 -R
ExecReload=/bin/kill -HUP $MAINPID
KillMode=process
Restart=on-failure
RestartSec=3

[Install]
WantedBy=multi-user.target
DBSVC
        systemctl daemon-reload 2>/dev/null
    else
        if [[ -f /etc/default/dropbear ]]; then
            sed -i 's/^NO_START=.*/NO_START=0/' /etc/default/dropbear
            sed -i '/^#\?DROPBEAR_PORT=/d;/^#\?DROPBEAR_EXTRA_ARGS=/d' /etc/default/dropbear
            echo 'DROPBEAR_PORT=109' >> /etc/default/dropbear
            echo 'DROPBEAR_EXTRA_ARGS="-p 143 -R"' >> /etc/default/dropbear
        fi
    fi
    systemctl enable dropbear &>/dev/null; systemctl restart dropbear 2>/dev/null
    ok "Dropbear siap: 109, 143"

    inf "Install Stunnel (445 → DB:109 / 777 → SSH:22)..."
    local st_tmp; st_tmp=$(mktemp -d); local st_ok=0
    if dl "$STUNNEL_URL" "$st_tmp/stunnel-master.zip"; then
        unzip -qo "$st_tmp/stunnel-master.zip" -d "$st_tmp/stunnel" 2>/dev/null
        local st_bin; st_bin=$(find "$st_tmp/stunnel" -type f -name "stunnel" ! -name "*.c" ! -name "*.h" 2>/dev/null | head -1)
        if [[ -n "$st_bin" ]] && verify_binary "$st_bin" 100000; then
            install -m755 "$st_bin" /usr/bin/stunnel4
            [[ ! -e /usr/bin/stunnel ]] && ln -sf /usr/bin/stunnel4 /usr/bin/stunnel
            st_ok=1
        fi
    fi
    rm -rf "$st_tmp"
    [[ "$st_ok" == "0" ]] && apt-get install -y -qq stunnel4 2>/dev/null || true

    id stunnel4 &>/dev/null || useradd -r -s /bin/false stunnel4 2>/dev/null || true
    mkdir -p /etc/stunnel /var/run/stunnel4
    chown stunnel4:stunnel4 /var/run/stunnel4 2>/dev/null || true

    local dom; dom=$(get_domain)
    if [[ -s "/etc/ssl/maxpanel/${dom}/key.pem" && -s "/etc/ssl/maxpanel/${dom}/fullchain.pem" ]]; then
        cat "/etc/ssl/maxpanel/${dom}/key.pem" "/etc/ssl/maxpanel/${dom}/fullchain.pem" > /etc/stunnel/stunnel.pem
        ok "Stunnel: SSL acme.sh"
    elif [[ -s /etc/xray/xray.key && -s /etc/xray/xray.crt ]]; then
        cat /etc/xray/xray.key /etc/xray/xray.crt > /etc/stunnel/stunnel.pem
        ok "Stunnel: SSL dari xray"
    else
        openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 \
            -subj "/C=ID/O=MAX/CN=${dom}" \
            -keyout /etc/stunnel/key.pem -out /etc/stunnel/cert.pem &>/dev/null
        cat /etc/stunnel/key.pem /etc/stunnel/cert.pem > /etc/stunnel/stunnel.pem
        chmod 600 /etc/stunnel/key.pem
        warn "Stunnel: SSL self-signed"
    fi
    chmod 600 /etc/stunnel/stunnel.pem

    cat > /etc/stunnel/stunnel.conf <<'STUN'
cert = /etc/stunnel/stunnel.pem
pid = /var/run/stunnel4/stunnel.pid
client = no
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1

[dropbear-ssl-445]
accept = 445
connect = 127.0.0.1:109

[openssh-ssl-777]
accept = 777
connect = 127.0.0.1:22
STUN

    if [[ ! -f /lib/systemd/system/stunnel4.service ]] && [[ ! -f /etc/systemd/system/stunnel4.service ]]; then
        cat > /etc/systemd/system/stunnel4.service <<'STSVC'
[Unit]
Description=MAX Panel — Stunnel SSL
After=network.target

[Service]
Type=forking
PIDFile=/var/run/stunnel4/stunnel.pid
ExecStart=/usr/bin/stunnel4 /etc/stunnel/stunnel.conf
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure

[Install]
WantedBy=multi-user.target
STSVC
        systemctl daemon-reload 2>/dev/null
    else
        sed -i 's/^ENABLED=.*/ENABLED=1/' /etc/default/stunnel4 2>/dev/null
        [[ -f /etc/default/stunnel4 ]] || echo "ENABLED=1" > /etc/default/stunnel4
    fi
    systemctl enable stunnel4 &>/dev/null
    pkill -9 stunnel4 2>/dev/null; rm -f /var/run/stunnel4/stunnel.pid; sleep 1
    systemctl restart stunnel4 2>/dev/null
    ok "Stunnel siap: 445 (→DB:109), 777 (→SSH:22)"
}

# ════════════════════════════════════════════════════════════
#  INSTALLER — Xray-core
# ════════════════════════════════════════════════════════════
install_xray() {
    inf "Install Xray-core..."
    mkdir -p /etc/xray /var/log/xray; touch "$XRAY_LOG" /var/log/xray/error.log
    if [[ ! -x "$XRAY_BIN" ]] || ! "$XRAY_BIN" version &>/dev/null; then
        local tmp; tmp=$(mktemp -d)
        local arch; arch=$(uname -m)
        local url; case "$arch" in aarch64|arm64) url="$XRAY_URL_ARM" ;; *) url="$XRAY_URL" ;; esac
        if dl "$url" "$tmp/xray.zip"; then
            unzip -qo "$tmp/xray.zip" -d "$tmp" 2>/dev/null
            if [[ -f "$tmp/xray" ]] && verify_binary "$tmp/xray" 1000000; then
                install -m755 "$tmp/xray" "$XRAY_BIN"; ok "Xray-core terpasang"
            else err "Binary Xray rusak"; rm -rf "$tmp"; return 1; fi
        else err "Gagal download Xray-core"; rm -rf "$tmp"; return 1; fi
        rm -rf "$tmp"
    else ok "Xray-core ada — skip"; fi

    if [[ ! -s "$XRAY_CRT" ]]; then
        local dom; dom=$(get_domain)
        openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
            -subj "/CN=${dom}" -keyout "$XRAY_KEY" -out "$XRAY_CRT" &>/dev/null
        chmod 644 "$XRAY_CRT"; chmod 600 "$XRAY_KEY"
    fi

    cat > "$XRAY_CFG" <<'XCFG'
{
  "log": {"loglevel":"warning","access":"/var/log/xray/access.log","error":"/var/log/xray/error.log"},
  "inbounds": [
    {"port":10001,"listen":"127.0.0.1","protocol":"vmess",
     "settings":{"clients":[]},"streamSettings":{"network":"ws","wsSettings":{"path":"/vmess"}},
     "sniffing":{"enabled":true,"destOverride":["http","tls"]},"tag":"vmess-ws"},
    {"port":10002,"listen":"127.0.0.1","protocol":"vless",
     "settings":{"clients":[],"decryption":"none"},"streamSettings":{"network":"ws","wsSettings":{"path":"/vless"}},
     "sniffing":{"enabled":true,"destOverride":["http","tls"]},"tag":"vless-ws"},
    {"port":10003,"listen":"127.0.0.1","protocol":"trojan",
     "settings":{"clients":[]},"streamSettings":{"network":"ws","wsSettings":{"path":"/trojan-ws"}},"tag":"trojan-ws"},
    {"port":10004,"listen":"127.0.0.1","protocol":"vless",
     "settings":{"clients":[],"decryption":"none"},"streamSettings":{"network":"grpc","grpcSettings":{"serviceName":"vless-grpc"}},"tag":"vless-grpc"},
    {"port":10005,"listen":"127.0.0.1","protocol":"trojan",
     "settings":{"clients":[]},"streamSettings":{"network":"grpc","grpcSettings":{"serviceName":"trojan-grpc"}},"tag":"trojan-grpc"},
    {"port":8388,"protocol":"shadowsocks","settings":{"clients":[],"network":"tcp,udp"},"tag":"ss-2022"}
  ],
  "outbounds":[{"protocol":"freedom","tag":"direct"},{"protocol":"blackhole","tag":"blocked"}]
}
XCFG

    cat > /etc/systemd/system/xray.service <<XEOF
[Unit]
Description=Xray Service
After=network.target nss-lookup.target

[Service]
User=root
ExecStart=$XRAY_BIN run -c $XRAY_CFG
Restart=on-failure
RestartSec=3
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
XEOF
    systemctl daemon-reload; systemctl enable xray &>/dev/null; systemctl restart xray 2>/dev/null; sleep 1
    is_up xray && ok "Xray-core aktif" || warn "Xray belum aktif — cek: journalctl -u xray -n 20"
}

# ════════════════════════════════════════════════════════════
#  INSTALLER — Trojan-Go
# ════════════════════════════════════════════════════════════
install_trojan_go() {
    inf "Install Trojan-Go..."; mkdir -p "$TROJANGO_DIR"
    if [[ ! -x "$TROJANGO_BIN" ]]; then
        local tmp; tmp=$(mktemp -d)
        if dl "$TROJAN_GO_URL" "$tmp/trojan-go.zip"; then
            unzip -qo "$tmp/trojan-go.zip" -d "$tmp" 2>/dev/null
            if [[ -f "$tmp/trojan-go" ]] && verify_binary "$tmp/trojan-go" 1000000; then
                install -m755 "$tmp/trojan-go" "$TROJANGO_BIN"; ok "Trojan-Go terpasang"
            else err "Binary Trojan-Go rusak"; rm -rf "$tmp"; return 1; fi
        else err "Gagal download Trojan-Go"; rm -rf "$tmp"; return 1; fi
        rm -rf "$tmp"
    else ok "Trojan-Go ada — skip"; fi

    if [[ ! -s "$TROJANGO_DIR/server.crt" ]]; then
        local dom; dom=$(get_domain)
        openssl req -x509 -nodes -newkey rsa:2048 -days 365 -subj "/CN=${dom}" \
            -keyout "$TROJANGO_DIR/server.key" -out "$TROJANGO_DIR/server.crt" &>/dev/null
        chmod 644 "$TROJANGO_DIR/server.crt"; chmod 600 "$TROJANGO_DIR/server.key"
    fi

    cat > "$TROJANGO_CFG" <<'TGCFG'
{"run_type":"server","local_addr":"0.0.0.0","local_port":2087,
 "remote_addr":"127.0.0.1","remote_port":80,"password":[],
 "ssl":{"cert":"/etc/trojan-go/server.crt","key":"/etc/trojan-go/server.key","sni":"","alpn":["http/1.1"]},
 "websocket":{"enabled":true,"path":"/trojan-go","host":""},"router":{"enabled":false}}
TGCFG
    cat > /etc/systemd/system/trojan-go.service <<TGEOF
[Unit]
Description=Trojan-Go Server
After=network.target
[Service]
Type=simple
User=root
ExecStart=$TROJANGO_BIN -config $TROJANGO_CFG
Restart=on-failure
RestartSec=3
LimitNOFILE=1048576
[Install]
WantedBy=multi-user.target
TGEOF
    systemctl daemon-reload; systemctl enable trojan-go &>/dev/null; systemctl restart trojan-go 2>/dev/null
    is_up trojan-go && ok "Trojan-Go aktif (port 2087)" || warn "Trojan-Go gagal start"
}

# ════════════════════════════════════════════════════════════
#  INSTALLER — Hysteria 2
# ════════════════════════════════════════════════════════════
install_hysteria() {
    inf "Install Hysteria 2..."; mkdir -p "$HY_DIR"
    if [[ ! -x "$HY_BIN" ]]; then
        local tmp; tmp=$(mktemp -d)
        if dl "$HYSTERIA_URL" "$tmp/hysteria" && verify_binary "$tmp/hysteria" 1000000; then
            install -m755 "$tmp/hysteria" "$HY_BIN"; ok "Hysteria 2 terpasang"
        else err "Gagal download/verify Hysteria"; rm -rf "$tmp"; return 1; fi
        rm -rf "$tmp"
    else ok "Hysteria ada — skip"; fi

    if [[ ! -s "$HY_DIR/server.crt" ]]; then
        local dom; dom=$(get_domain)
        openssl req -x509 -nodes -newkey rsa:2048 -days 365 -subj "/CN=${dom}" \
            -keyout "$HY_DIR/server.key" -out "$HY_DIR/server.crt" &>/dev/null
        chmod 644 "$HY_DIR/server.crt"; chmod 600 "$HY_DIR/server.key"
    fi

    cat > "$HY_CFG" <<'HYCFG'
listen: :36712
tls:
  cert: /etc/hysteria/server.crt
  key:  /etc/hysteria/server.key
auth:
  type: userpass
  userpass:
    maxpanel: "maxpanel2024"
masquerade:
  type: proxy
  proxy:
    url: https://bing.com
    rewriteHost: true
quic:
  initStreamReceiveWindow:   8388608
  maxStreamReceiveWindow:    8388608
  initConnReceiveWindow:    20971520
  maxConnReceiveWindow:     20971520
HYCFG
    cat > /etc/systemd/system/hysteria-server.service <<HYEOF
[Unit]
Description=Hysteria 2 Server
After=network.target
[Service]
Type=simple
User=root
ExecStart=$HY_BIN server -c $HY_CFG
Restart=on-failure
RestartSec=3
LimitNOFILE=1048576
[Install]
WantedBy=multi-user.target
HYEOF
    local IFACE; IFACE=$(get_iface)
    iptables -I INPUT -p udp --dport 36712 -j ACCEPT 2>/dev/null
    iptables -I INPUT -p udp --dport 5300  -j ACCEPT 2>/dev/null
    while iptables -t nat -D PREROUTING -i "$IFACE" -p udp --dport 6000:19999 -j DNAT --to-destination :36712 2>/dev/null; do :; done
    iptables -t nat -A PREROUTING -i "$IFACE" -p udp --dport 6000:19999 -j DNAT --to-destination :36712 2>/dev/null
    netfilter-persistent save &>/dev/null
    systemctl daemon-reload; systemctl enable hysteria-server &>/dev/null; systemctl restart hysteria-server 2>/dev/null
    is_up hysteria-server && ok "Hysteria 2 aktif (UDP 36712)" || warn "Hysteria belum aktif"
}



# ════════════════════════════════════════════════════════════
#  INSTALLER — OpenVPN (FIX: data-ciphers untuk OpenVPN 2.5+)
# ════════════════════════════════════════════════════════════
install_openvpn() {
    inf "Install OpenVPN (TCP 1194 + UDP 2200)..."
    command -v openvpn &>/dev/null || apt-get install -y -qq openvpn easy-rsa &>/dev/null
    mkdir -p /etc/openvpn/server /etc/openvpn/easy-rsa /etc/openvpn/client
    if [[ ! -s /etc/openvpn/server/ca.crt ]]; then
        local ER=/etc/openvpn/easy-rsa
        [[ -d /usr/share/easy-rsa ]] && cp -r /usr/share/easy-rsa/* "$ER/" 2>/dev/null
        cd "$ER" || return 1
        export EASYRSA_BATCH=1 EASYRSA_REQ_CN="MAX-CA"
        ./easyrsa init-pki &>/dev/null; ./easyrsa --batch build-ca nopass &>/dev/null
        ./easyrsa --batch gen-req server nopass &>/dev/null; ./easyrsa --batch sign-req server server &>/dev/null
        ./easyrsa gen-dh &>/dev/null; openvpn --genkey secret /etc/openvpn/server/ta.key &>/dev/null
        cp "$ER/pki/ca.crt"           /etc/openvpn/server/ca.crt
        cp "$ER/pki/issued/server.crt" /etc/openvpn/server/server.crt
        cp "$ER/pki/private/server.key" /etc/openvpn/server/server.key
        cp "$ER/pki/dh.pem"           /etc/openvpn/server/dh.pem
        chmod 600 /etc/openvpn/server/server.key /etc/openvpn/server/ta.key 2>/dev/null
        chmod 644 /etc/openvpn/server/ca.crt /etc/openvpn/server/server.crt /etc/openvpn/server/dh.pem 2>/dev/null
        chmod 600 "$ER/pki/private/ca.key" "$ER/pki/private/server.key" 2>/dev/null
        chmod -R go-rwx "$ER/pki/private" 2>/dev/null
        cd - >/dev/null || true; ok "OpenVPN PKI dibuat"
    else ok "OpenVPN PKI ada — skip"; fi

    local IFACE; IFACE=$(get_iface)
    for proto_port in "tcp:1194:tun:10.200.0.0" "udp:2200:tun1:10.201.0.0"; do
        local proto port dev subnet
        IFS=: read -r proto port dev subnet <<< "$proto_port"
        cat > "/etc/openvpn/server/${proto}.conf" <<OVPNCFG
port ${port}
proto ${proto}
dev ${dev}
ca   /etc/openvpn/server/ca.crt
cert /etc/openvpn/server/server.crt
key  /etc/openvpn/server/server.key
dh   /etc/openvpn/server/dh.pem
tls-auth /etc/openvpn/server/ta.key 0
server ${subnet} 255.255.255.0
ifconfig-pool-persist /etc/openvpn/server/ipp-${proto}.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 1.1.1.1"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 120
data-ciphers AES-256-GCM:AES-128-GCM:AES-128-CBC
data-ciphers-fallback AES-128-CBC
auth SHA256
user nobody
group nogroup
persist-key
persist-tun
status /var/log/openvpn-${proto}-status.log
log    /var/log/openvpn-${proto}.log
verb 3
plugin /usr/lib/openvpn/openvpn-plugin-auth-pam.so login
duplicate-cn
script-security 3
client-cert-not-required
username-as-common-name
OVPNCFG
    done

    _apply_block "OPENVPN-FORWARD" /etc/sysctl.conf <<'SC'
net.ipv4.ip_forward=1
SC
    sysctl -p &>/dev/null
    iptables -t nat -C POSTROUTING -s 10.200.0.0/24 -o "$IFACE" -j MASQUERADE 2>/dev/null \
        || iptables -t nat -A POSTROUTING -s 10.200.0.0/24 -o "$IFACE" -j MASQUERADE
    iptables -t nat -C POSTROUTING -s 10.201.0.0/24 -o "$IFACE" -j MASQUERADE 2>/dev/null \
        || iptables -t nat -A POSTROUTING -s 10.201.0.0/24 -o "$IFACE" -j MASQUERADE
    netfilter-persistent save &>/dev/null
    systemctl enable openvpn-server@tcp openvpn-server@udp &>/dev/null
    systemctl restart openvpn-server@tcp 2>/dev/null; systemctl restart openvpn-server@udp 2>/dev/null
    ok "OpenVPN siap: TCP 1194 + UDP 2200"
}

# ════════════════════════════════════════════════════════════
#  INSTALLER — WireGuard (FIX: WG_CFG selalu 600)
# ════════════════════════════════════════════════════════════
install_wireguard() {
    inf "Install WireGuard (UDP 51820)..."
    command -v wg &>/dev/null || apt-get install -y -qq wireguard wireguard-tools &>/dev/null
    mkdir -p "$WG_DIR" "$WG_CLIENT_DIR"; chmod 700 "$WG_DIR"
    if [[ ! -s "$WG_DIR/server_private.key" ]]; then
        local privk pubk; privk=$(wg genkey); pubk=$(echo "$privk" | wg pubkey)
        ( umask 077; echo "$privk" > "$WG_DIR/server_private.key" )
        echo "$pubk" > "$WG_DIR/server_public.key"
        chmod 600 "$WG_DIR/server_private.key"; chmod 644 "$WG_DIR/server_public.key"
    fi
    local IFACE SPRIV; IFACE=$(get_iface); SPRIV=$(cat "$WG_DIR/server_private.key")
    ( umask 077; cat > "$WG_CFG" <<WGCFG
[Interface]
Address = 10.66.66.1/24
ListenPort = 51820
PrivateKey = $SPRIV
SaveConfig = false
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o $IFACE -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o $IFACE -j MASQUERADE
WGCFG
)
    _apply_block "WG-FORWARD" /etc/sysctl.conf <<'SC'
net.ipv4.ip_forward=1
SC
    sysctl -p &>/dev/null
    systemctl enable wg-quick@wg0 &>/dev/null; systemctl restart wg-quick@wg0 2>/dev/null
    is_up "wg-quick@wg0" && ok "WireGuard aktif (UDP 51820)" || warn "WireGuard belum aktif"
}



# ════════════════════════════════════════════════════════════
#  INSTALLER — WebSocket SSH Proxy
#  FIX: path pakai $WS_DIR, nama service konsisten "ws-ssh-proxy",
#       tidak ada duplikat unit, fallback inline yang benar
# ════════════════════════════════════════════════════════════
install_ws_ssh_proxy() {
    inf "Install WebSocket SSH Proxy..."
    mkdir -p "$WS_DIR"; chmod 700 "$WS_DIR"
    local ws_ok=0

    # Download dari chanelog/bin
    if dl "$WS_SSH_SERVER_URL" "$WS_DIR/ws-ssh-server.py" && \
       dl "$WS_TUNNEL_URL"     "$WS_DIR/ws_tunnel.py"; then
        chmod +x "$WS_DIR/ws-ssh-server.py" "$WS_DIR/ws_tunnel.py"
        ok "WS proxy dari chanelog/bin"; ws_ok=1
    else
        warn "Gagal chanelog/bin — pakai fallback inline"
    fi

    # Fallback inline jika download gagal
    if [[ "$ws_ok" == "0" ]]; then
        cat > "$WS_BIN" <<'WSPY'
#!/usr/bin/env python3
# MAX WS SSH Proxy — fallback inline — forward WS → SSH:22
import socket, threading, sys, signal

LISTEN_HOST = '127.0.0.1'
LISTEN_PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8880
TARGET_HOST, TARGET_PORT = '127.0.0.1', 22
RESPONSE = b'HTTP/1.1 200 Connection Established\r\nProxy-Agent: MAX-WS\r\n\r\n'
BUFLEN = 65536

def relay(src, dst):
    try:
        while True:
            data = src.recv(BUFLEN)
            if not data: break
            dst.sendall(data)
    except: pass

def handle(c):
    try:
        req = c.recv(BUFLEN)
        if req: c.sendall(RESPONSE)
        s = socket.create_connection((TARGET_HOST, TARGET_PORT), timeout=10)
        threading.Thread(target=relay, args=(c, s), daemon=True).start()
        relay(s, c)
    except: pass
    finally:
        try: c.close()
        except: pass

def main():
    srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    srv.bind((LISTEN_HOST, LISTEN_PORT)); srv.listen(128)
    print(f"[*] WS SSH Proxy {LISTEN_HOST}:{LISTEN_PORT} → SSH:22")
    while True:
        try:
            c, _ = srv.accept()
            threading.Thread(target=handle, args=(c,), daemon=True).start()
        except: pass

signal.signal(signal.SIGTERM, lambda *a: sys.exit(0))
if __name__ == '__main__': main()
WSPY
        chmod +x "$WS_BIN"
        ok "WS SSH Proxy fallback terpasang: $WS_BIN"
    fi

    # Tentukan ExecStart — prioritas chanelog/bin
    local exec_start
    if [[ -x "$WS_DIR/ws-ssh-server.py" ]]; then
        exec_start="/usr/bin/python3 ${WS_DIR}/ws-ssh-server.py"
    else
        exec_start="/usr/bin/python3 ${WS_BIN} 8880"
    fi

    # FIX: satu unit bernama ws-ssh-proxy (konsisten di seluruh script)
    cat > /etc/systemd/system/ws-ssh-proxy.service <<WSSVC
[Unit]
Description=MAX PANEL — WebSocket SSH Proxy (:8880 → SSH:22)
After=network.target sshd.service
Wants=network-online.target

[Service]
Type=simple
User=root
ExecStart=${exec_start}
Restart=on-failure
RestartSec=5
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
WSSVC

    systemctl daemon-reload 2>/dev/null
    systemctl enable ws-ssh-proxy 2>/dev/null
    systemctl restart ws-ssh-proxy 2>/dev/null; sleep 1
    if is_up ws-ssh-proxy; then
        ok "WS SSH Proxy aktif (127.0.0.1:8880)"
        ok "Route: Nginx /ws-ssh → :8880 → SSH:22"
    else
        warn "ws-ssh-proxy belum aktif — cek: journalctl -u ws-ssh-proxy -n 20"
    fi
}
# ════════════════════════════════════════════════════════════
#  INSTALLER — Nginx reverse-proxy
# ════════════════════════════════════════════════════════════
install_nginx() {
    inf "Install Nginx + reverse-proxy..."
    if ! command -v nginx &>/dev/null; then
        local tmp; tmp=$(mktemp -d)
        apt-get install -y -qq build-essential libpcre3 libpcre3-dev \
            zlib1g zlib1g-dev libssl-dev 2>/dev/null || true
        if dl "$NGINX_URL" "$tmp/nginx.tar.gz"; then
            tar -xzf "$tmp/nginx.tar.gz" -C "$tmp" 2>/dev/null
            local src; src=$(find "$tmp" -maxdepth 1 -type d -name "nginx-*" | head -1)
            if [[ -n "$src" ]]; then
                cd "$src"
                ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx \
                    --conf-path=/etc/nginx/nginx.conf \
                    --error-log-path=/var/log/nginx/error.log \
                    --http-log-path=/var/log/nginx/access.log \
                    --pid-path=/var/run/nginx.pid \
                    --http-client-body-temp-path=/var/cache/nginx/client_temp \
                    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
                    --with-http_ssl_module --with-http_v2_module \
                    --with-http_realip_module --with-http_stub_status_module \
                    --with-http_gzip_static_module \
                    --with-stream --with-stream_ssl_module --with-threads --with-pcre \
                    &>/dev/null && make -j"$(nproc)" &>/dev/null && make install &>/dev/null
                cd - &>/dev/null || true
                command -v nginx &>/dev/null && ok "Nginx dikompile dari chanelog/bin" \
                    || { warn "Kompile gagal — fallback apt"; apt-get install -y -qq nginx 2>/dev/null || true; }
            else
                warn "Source tidak ditemukan — fallback apt"
                apt-get install -y -qq nginx 2>/dev/null || true
            fi
        else
            warn "Download gagal — fallback apt"
            apt-get install -y -qq nginx 2>/dev/null || true
        fi
        rm -rf "$tmp"
        mkdir -p /var/cache/nginx/client_temp /var/cache/nginx/proxy_temp /var/log/nginx
        if [[ ! -f /etc/systemd/system/nginx.service ]] && [[ ! -f /lib/systemd/system/nginx.service ]]; then
            cat > /etc/systemd/system/nginx.service <<'NGSVC'
[Unit]
Description=MAX Panel — Nginx
After=network.target
[Service]
Type=forking
PIDFile=/var/run/nginx.pid
ExecStartPre=/usr/sbin/nginx -t -q
ExecStart=/usr/sbin/nginx
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
PrivateTmp=true
[Install]
WantedBy=multi-user.target
NGSVC
            systemctl daemon-reload 2>/dev/null
        fi
    else
        ok "Nginx ada — skip"
    fi

    mkdir -p /etc/nginx/conf.d
    local dom; dom=$(get_domain)
    rm -f /etc/nginx/sites-enabled/default 2>/dev/null

    cat > /etc/nginx/conf.d/maxpanel.conf <<NGX
# MAX PANEL — Xray + WS-SSH reverse-proxy (Nginx)
map \$http_upgrade \$connection_upgrade { default upgrade; '' close; }

# ── HTTP 80 ──────────────────────────────────────────────────
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    server_name ${dom} _;
    root /var/www/html;

    # SSH over WebSocket (Nginx → ws-ssh-proxy:8880 → SSH:22)
    location = /ws-ssh {
        proxy_pass http://127.0.0.1:8880;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host;
        proxy_read_timeout 7200s;
        proxy_buffering off;
        proxy_redirect off;
    }
    location = /vmess {
        if (\$http_upgrade != "websocket") { return 404; }
        proxy_pass http://127.0.0.1:10001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host;
        proxy_read_timeout 300s;
    }
    location = /vless {
        if (\$http_upgrade != "websocket") { return 404; }
        proxy_pass http://127.0.0.1:10002;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host;
        proxy_read_timeout 300s;
    }
    location = /trojan-ws {
        if (\$http_upgrade != "websocket") { return 404; }
        proxy_pass http://127.0.0.1:10003;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host;
        proxy_read_timeout 300s;
    }
    location / { return 200 'MAX PANEL\n'; add_header Content-Type text/plain; }
}

# ── TLS 443 ──────────────────────────────────────────────────
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name ${dom} _;
    ssl_certificate     /etc/xray/xray.crt;
    ssl_certificate_key /etc/xray/xray.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    location = /ws-ssh {
        proxy_pass http://127.0.0.1:8880;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host;
        proxy_read_timeout 7200s;
        proxy_buffering off;
        proxy_redirect off;
    }
    location ^~ /vless-grpc  { grpc_pass grpc://127.0.0.1:10004; grpc_set_header Host \$host; client_max_body_size 0; }
    location ^~ /trojan-grpc { grpc_pass grpc://127.0.0.1:10005; grpc_set_header Host \$host; client_max_body_size 0; }
    location = /vmess {
        proxy_pass http://127.0.0.1:10001; proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host; proxy_read_timeout 300s;
    }
    location = /vless {
        proxy_pass http://127.0.0.1:10002; proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host; proxy_read_timeout 300s;
    }
    location = /trojan-ws {
        proxy_pass http://127.0.0.1:10003; proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection \$connection_upgrade;
        proxy_set_header Host \$host; proxy_read_timeout 300s;
    }
    location / { return 200 'MAX PANEL\n'; add_header Content-Type text/plain; }
}

# ── Alt-TLS 8443 ─────────────────────────────────────────────
server {
    listen 8443 ssl http2;
    listen [::]:8443 ssl http2;
    server_name ${dom} _;
    ssl_certificate     /etc/xray/xray.crt;
    ssl_certificate_key /etc/xray/xray.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    location = /ws-ssh    { proxy_pass http://127.0.0.1:8880;  proxy_http_version 1.1; proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection \$connection_upgrade; proxy_set_header Host \$host; proxy_buffering off; proxy_read_timeout 7200s; }
    location ^~ /vless-grpc  { grpc_pass grpc://127.0.0.1:10004; grpc_set_header Host \$host; client_max_body_size 0; }
    location ^~ /trojan-grpc { grpc_pass grpc://127.0.0.1:10005; grpc_set_header Host \$host; client_max_body_size 0; }
    location = /vmess     { proxy_pass http://127.0.0.1:10001; proxy_http_version 1.1; proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection \$connection_upgrade; proxy_set_header Host \$host; }
    location = /vless     { proxy_pass http://127.0.0.1:10002; proxy_http_version 1.1; proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection \$connection_upgrade; proxy_set_header Host \$host; }
    location = /trojan-ws { proxy_pass http://127.0.0.1:10003; proxy_http_version 1.1; proxy_set_header Upgrade \$http_upgrade; proxy_set_header Connection \$connection_upgrade; proxy_set_header Host \$host; }
    location / { return 200 'MAX PANEL\n'; add_header Content-Type text/plain; }
}
NGX

    if nginx -t &>/dev/null; then
        systemctl enable nginx &>/dev/null; systemctl restart nginx 2>/dev/null
        is_up nginx && ok "Nginx aktif (80 HTTP + 443/8443 TLS)" || warn "Nginx belum aktif"
        ok "Routes: /ws-ssh /vmess /vless /trojan-ws + gRPC /vless-grpc /trojan-grpc"
    else
        err "Konfigurasi Nginx INVALID — cek: nginx -t"
        nginx -t 2>&1 | tail -5 | while read -r ln; do warn "  $ln"; done
    fi
}



# ════════════════════════════════════════════════════════════
#  ACME.SH — SSL dari Let's Encrypt
#  FIX: $myip dideklarasikan sebelum dipakai di error message
# ════════════════════════════════════════════════════════════
setup_acme_ssl() {
    local domain="$1"
    [[ -z "$domain" ]] && { err "Domain kosong"; return 1; }
    local myip; myip=$(get_ip)   # FIX: deklarasikan lebih awal
    local ACME_DIR="$HOME/.acme.sh" ACME_BIN="$HOME/.acme.sh/acme.sh"
    local CERT_DIR="/etc/ssl/maxpanel/${domain}"
    mkdir -p "$CERT_DIR"

    if [[ ! -x "$ACME_BIN" ]]; then
        inf "Download acme.sh..."
        local ta; ta=$(mktemp)
        dl "$ACME_URL" "$ta" || { err "Gagal download acme.sh"; rm -f "$ta"; return 1; }
        chmod +x "$ta"; bash "$ta" --install --home "$ACME_DIR" --noprofile 2>/dev/null; rm -f "$ta"
        [[ -x "$ACME_BIN" ]] || { err "acme.sh gagal install"; return 1; }
        ok "acme.sh terinstall"
    else ok "acme.sh ada — skip"; fi

    "$ACME_BIN" --set-default-ca --server letsencrypt 2>/dev/null
    inf "Issue SSL: ${W}${domain}${NC} (webroot via Nginx)..."
    mkdir -p /var/www/html/.well-known/acme-challenge
    systemctl start nginx 2>/dev/null; sleep 2

    "$ACME_BIN" --issue -d "$domain" -w /var/www/html --force 2>&1 | \
        grep -E "(success|error|Domain)" | while read -r ln; do inf "  $ln"; done

    local issue_ok=0 ACME_CERT_DIR=""
    for cdir in "${ACME_DIR}/${domain}_ecc" "${ACME_DIR}/${domain}"; do
        if [[ -f "${cdir}/${domain}.cer" ]] || [[ -f "${cdir}/${domain}.crt" ]]; then
            issue_ok=1; ACME_CERT_DIR="$cdir"; break
        fi
    done

    if [[ "$issue_ok" == "0" ]]; then
        err "Gagal issue SSL untuk ${domain}!"
        err "  Pastikan DNS sudah pointing ke ${myip} dan port 80 terbuka"
        warn "Fallback ke self-signed SSL"
        gen_selfsigned_ssl; return 1
    fi
    ok "SSL issued via Let's Encrypt"

    # Copy cert
    cp "${ACME_CERT_DIR}/${domain}.cer" "$CERT_DIR/cert.pem" 2>/dev/null || \
    cp "${ACME_CERT_DIR}/${domain}.crt" "$CERT_DIR/cert.pem" 2>/dev/null
    cp "${ACME_CERT_DIR}/${domain}.key" "$CERT_DIR/key.pem"
    if [[ -f "${ACME_CERT_DIR}/fullchain.cer" ]]; then
        cp "${ACME_CERT_DIR}/fullchain.cer" "$CERT_DIR/fullchain.pem"
    else
        cat "$CERT_DIR/cert.pem" "${ACME_CERT_DIR}/ca.cer" > "$CERT_DIR/fullchain.pem"
    fi
    chmod 600 "$CERT_DIR/key.pem"; chmod 644 "$CERT_DIR/cert.pem" "$CERT_DIR/fullchain.pem"

    "$ACME_BIN" --install-cert -d "$domain" \
        --cert-file      "$CERT_DIR/cert.pem" \
        --key-file       "$CERT_DIR/key.pem" \
        --fullchain-file "$CERT_DIR/fullchain.pem" \
        --reloadcmd      "systemctl reload nginx 2>/dev/null; systemctl restart xray 2>/dev/null" \
        2>/dev/null

    # Deploy ke semua service
    mkdir -p /etc/xray /etc/hysteria /etc/trojan-go /etc/stunnel
    cp -f "$CERT_DIR/fullchain.pem" /etc/xray/xray.crt;       chmod 644 /etc/xray/xray.crt
    cp -f "$CERT_DIR/key.pem"       /etc/xray/xray.key;       chmod 600 /etc/xray/xray.key
    cp -f "$CERT_DIR/fullchain.pem" /etc/hysteria/server.crt;  chmod 644 /etc/hysteria/server.crt
    cp -f "$CERT_DIR/key.pem"       /etc/hysteria/server.key;  chmod 600 /etc/hysteria/server.key
    cp -f "$CERT_DIR/fullchain.pem" /etc/trojan-go/server.crt; chmod 644 /etc/trojan-go/server.crt
    cp -f "$CERT_DIR/key.pem"       /etc/trojan-go/server.key; chmod 600 /etc/trojan-go/server.key
    cat "$CERT_DIR/key.pem" "$CERT_DIR/fullchain.pem" > /etc/stunnel/stunnel.pem; chmod 600 /etc/stunnel/stunnel.pem

    local renew_hook="cp -f ${CERT_DIR}/fullchain.pem /etc/xray/xray.crt; cp -f ${CERT_DIR}/key.pem /etc/xray/xray.key; \
cp -f ${CERT_DIR}/fullchain.pem /etc/hysteria/server.crt; cp -f ${CERT_DIR}/key.pem /etc/hysteria/server.key; \
cp -f ${CERT_DIR}/fullchain.pem /etc/trojan-go/server.crt; cp -f ${CERT_DIR}/key.pem /etc/trojan-go/server.key; \
cat ${CERT_DIR}/key.pem ${CERT_DIR}/fullchain.pem > /etc/stunnel/stunnel.pem; \
systemctl reload nginx 2>/dev/null; systemctl restart xray stunnel4 trojan-go hysteria-server 2>/dev/null"
    echo "0 3 * * * root ${ACME_BIN} --renew -d ${domain} --force 2>/dev/null && ${renew_hook}" \
        > /etc/cron.d/maxpanel-ssl-renew
    chmod 644 /etc/cron.d/maxpanel-ssl-renew
    systemctl restart stunnel4 xray trojan-go hysteria-server 2>/dev/null
    ok "SSL terpasang! Auto-renew: /etc/cron.d/maxpanel-ssl-renew"
    return 0
}

gen_selfsigned_ssl() {
    local dom; dom=$(get_domain)
    mkdir -p /etc/xray /etc/hysteria /etc/trojan-go
    if [[ ! -s /etc/xray/xray.crt ]]; then
        openssl req -x509 -nodes -newkey rsa:2048 -days 365 -subj "/CN=${dom}" \
            -keyout /etc/xray/xray.key -out /etc/xray/xray.crt &>/dev/null
        chmod 644 /etc/xray/xray.crt; chmod 600 /etc/xray/xray.key
    fi
    cp -f /etc/xray/xray.crt /etc/hysteria/server.crt;  cp -f /etc/xray/xray.key /etc/hysteria/server.key
    cp -f /etc/xray/xray.crt /etc/trojan-go/server.crt; cp -f /etc/xray/xray.key /etc/trojan-go/server.key
    chmod 644 /etc/hysteria/server.crt /etc/trojan-go/server.crt 2>/dev/null
    chmod 600 /etc/hysteria/server.key /etc/trojan-go/server.key 2>/dev/null
    ok "SSL self-signed siap (CN=${dom})"
}

validate_domain_pointing() {
    local domain="$1" myip; myip=$(get_ip)
    local resolved; resolved=$(getent hosts "$domain" 2>/dev/null | awk '{print $1}' | head -1)
    [[ -z "$resolved" ]] && resolved=$(dig +short "$domain" 2>/dev/null | grep -E '^[0-9]+\.' | head -1)
    if [[ "$resolved" == "$myip" ]]; then ok "Domain ${W}${domain}${NC} → ${LG}${myip}${NC} ✓"; return 0
    else warn "Domain resolve ke: ${Y}${resolved:-?}${NC} (server: ${Y}${myip}${NC})"; return 1; fi
}

enable_bbr_silent() {
    modprobe tcp_bbr 2>/dev/null
    _apply_block "BBR-MODULE" /etc/modules-load.d/maxpanel.conf <<'B'
tcp_bbr
B
    sysctl -w net.core.default_qdisc=fq &>/dev/null
    sysctl -w net.ipv4.tcp_congestion_control=bbr &>/dev/null
    _apply_block "BBR-SYSCTL" /etc/sysctl.conf <<'B'
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.ip_forward=1
B
    sysctl -p &>/dev/null
}

# ════════════════════════════════════════════════════════════
#  MASTER INSTALLER — 16 step (FIX: step counter benar, OHP masuk step 16)
# ════════════════════════════════════════════════════════════
do_install_all() {
    show_header
    _top; _btn "  ${IT}${AL}🚀  INSTALL MAX PANEL — Premium Tunneling${NC}"; _bot; echo ""
    trap 'err "Instalasi gagal: ${CURRENT_STEP:-unknown}"; trap - ERR; return 1' ERR
    local sip; sip=$(get_ip)
    echo -e "\n  ${A1}${_DASH}${NC}\n  ${A4}◈${NC} ${BLD}KONFIGURASI AWAL${NC}\n  ${A1}${_DASH}${NC}"
    echo -e "  ${DIM}IP server: ${W}${sip}${NC}\n  ${DIM}Pastikan domain sudah pointing ke IP ini.${NC}\n  ${A1}${_DASH}${NC}\n"

    local inp_domain=""
    while true; do
        echo -ne "  ${A3}Domain${NC} (wajib, contoh: vpn.example.com): "; read -r inp_domain
        inp_domain="${inp_domain// /}"
        [[ -z "$inp_domain" ]] && { err "Domain WAJIB diisi!"; echo ""; continue; }
        [[ ! "$inp_domain" =~ ^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)+$ ]] \
            && { err "Format domain tidak valid"; echo ""; continue; }
        inf "Memeriksa DNS: ${inp_domain} ..."
        if validate_domain_pointing "$inp_domain"; then ok "Domain valid ✓"; break; else
            echo ""; echo -ne "  Lanjutkan dengan ${W}${inp_domain}${NC}? [y/N]: "; read -r ans
            [[ "${ans,,}" == "y" ]] && { warn "Lanjut — SSL mungkin gagal jika DNS belum propagasi"; break; }
            echo ""
        fi
    done

    echo ""
    echo -ne "  ${A3}Nama Brand${NC}          : "; read -r inp_brand; [[ -z "$inp_brand" ]] && inp_brand="MAX PANEL"
    echo -ne "  ${A3}Admin Telegram${NC}      : "; read -r inp_tg;    [[ -z "$inp_tg"    ]] && inp_tg="-"

    mkdir -p "$DIR" "$LOGDIR"
    echo "$inp_domain" > "$DOMF"
    printf "BRAND=%q\nADMIN_TG=%q\n" "$inp_brand" "$inp_tg" > "$STRF"
    [[ ! -f "$THEMEF" ]] && echo "1" > "$THEMEF"
    echo "$SCRIPT_VERSION" > "$VERSIONF"
    for f in "$MLDB" "$SSH_DB" "$VMESS_DB" "$VLESS_DB" "$TROJAN_DB" \
             "$TROJANGO_DB" "$OVPN_DB" "$WG_DB" "$HY_DB" "$SS_DB"; do
        touch "$f"
    done

    echo -e "\n  ${A1}${_DASH}${NC}"; inf "Mulai instalasi → 16 langkah..."; echo -e "  ${A1}${_DASH}${NC}\n"

    _step() { CURRENT_STEP="$2"; echo -e "\n  ${A4}[${1}/16]${NC} ${BLD}${AL}${2}${NC}"; echo -e "  ${A1}${_DASH}${NC}"; }

    # ── Tahap 1: Fondasi sistem ───────────────────────────────────────
    _step  1 "Cek root & OS";                        check_root; check_os; ok "OS: $OS_NAME"
    _step  2 "Update apt + install dependencies";    install_deps
    _step  3 "Setup direktori panel";                mkdir -p "$DIR" "$LOGDIR" "$BACKUPDIR"; ok "Direktori siap"
    _step  4 "Download semua binary (chanelog/bin)"; install_all_bins

    # ── Tahap 2: SSH layer (belum butuh SSL) ─────────────────────────
    _step  5 "OpenSSH + Dropbear + Stunnel";         install_ssh

    # ── Tahap 3: Nginx + WS Proxy SEBELUM issue SSL ──────────────────
    # Nginx harus running dulu agar acme.sh webroot validation berhasil
    _step  6 "WebSocket SSH Proxy (ws-ssh-proxy)";  install_ws_ssh_proxy
    _step  7 "Nginx reverse-proxy (80/443/8443)";   install_nginx

    # ── Tahap 4: SSL via acme.sh (Nginx sudah running di port 80) ────
    _step  8 "SSL Let's Encrypt → ${inp_domain}"; setup_acme_ssl "$inp_domain" || gen_selfsigned_ssl

    # ── Tahap 5: Xray & protokol yang perlu cert ─────────────────────
    _step  9 "Xray-core (VMess/VLess/Trojan/SS)";  install_xray
    _step 10 "Trojan-Go (port 2087)";              install_trojan_go
    _step 11 "Hysteria 2 (UDP 36712)";             install_hysteria

    # ── Tahap 6: Protokol independen ────────────────────────────────
    _step 12 "OpenVPN (TCP 1194 + UDP 2200)";      install_openvpn
    _step 13 "WireGuard (UDP 51820)";              install_wireguard

    # ── Tahap 7: Reload semua service pakai cert final ───────────────
    _step 14 "Reload semua service dengan cert terbaru"
    systemctl reload nginx 2>/dev/null
    systemctl restart xray trojan-go hysteria-server stunnel4 2>/dev/null
    ok "Nginx + Xray + Trojan-Go + Hysteria + Stunnel reload"

    # ── Tahap 8: Finalisasi ──────────────────────────────────────────
    _step 15 "Cron jobs";                           install_cron_jobs
    _step 16 "BBR + kernel tuning"
    enable_bbr_silent
    sysctl -w net.core.rmem_max=16777216 &>/dev/null
    sysctl -w net.core.wmem_max=16777216 &>/dev/null
    ok "BBR aktif, buffer tuned"

    trap - ERR
    sysctl -w net.core.rmem_max=16777216 &>/dev/null
    sysctl -w net.core.wmem_max=16777216 &>/dev/null
    setup_menu_cmd; install_ssh_splash
    echo "$SCRIPT_VERSION" > "$VERSIONF"

    local ssl_type="acme.sh (Let's Encrypt)"
    [[ ! -f "/etc/ssl/maxpanel/${inp_domain}/cert.pem" ]] && ssl_type="Self-Signed (fallback)"

    echo ""; echo -e "  ${A1}${_DASH}${NC}"
    echo -e "  ${LG}${BLD}  ✦  MAX PANEL BERHASIL DIINSTALL!${NC}"; echo -e "  ${A1}${_DASH}${NC}"
    printf  "  ${DIM} Domain  :${NC}  ${W}%s${NC}\n" "$inp_domain"
    printf  "  ${DIM} SSL     :${NC}  ${LG}%s${NC}\n" "$ssl_type"
    printf  "  ${DIM} Brand   :${NC}  ${AL}%s${NC}\n" "$inp_brand"
    printf  "  ${DIM} Versi   :${NC}  ${Y}%s${NC}\n"  "$SCRIPT_VERSION"
    echo -e "  ${A1}${_DASH}${NC}"
    echo -e "  ${BLD}${A4}Protokol & Port${NC}"; echo -e "  ${A1}${_DASH}${NC}"
    printf  "  ${A3}•${NC} SSH/Dropbear    : ${Y}22 / 109,143${NC}\n"
    printf  "  ${A3}•${NC} Stunnel SSL     : ${Y}445 (→DB) / 777 (→SSH)${NC}\n"
    printf  "  ${A3}•${NC} Nginx HTTP      : ${Y}80${NC}  → /vmess /vless /trojan-ws /ws-ssh\n"
    printf  "  ${A3}•${NC} Nginx TLS       : ${Y}443 / 8443${NC}  → + gRPC /vless-grpc /trojan-grpc\n"
    printf  "  ${A3}•${NC} WS-SSH (HTTP)   : ${Y}ws://%s/ws-ssh${NC}\n"  "$inp_domain"
    printf  "  ${A3}•${NC} WS-SSH (TLS)    : ${Y}wss://%s/ws-ssh${NC}\n" "$inp_domain"
    printf  "  ${A3}•${NC} Xray VMess/VLess/Trojan/SS via Nginx\n"
    printf  "  ${A3}•${NC} Trojan-Go       : ${Y}2087${NC}\n"
    printf  "  ${A3}•${NC} OpenVPN         : ${Y}TCP 1194 / UDP 2200${NC}\n"
    printf  "  ${A3}•${NC} Hysteria 2      : ${Y}UDP 36712${NC}\n"
    printf  "  ${A3}•${NC} WireGuard       : ${Y}UDP 51820${NC}\n"
    echo -e "  ${A1}${_DASH}${NC}"
    echo -e "\n  ${DIM}Ketik ${A1}menu-max${NC}${DIM} untuk membuka panel.${NC}\n"
    _tg_send "🎉 <b>MAX PANEL v${SCRIPT_VERSION} terpasang</b>
🌐 Domain : <code>${inp_domain}</code>  🔒 SSL: <code>${ssl_type}</code>
🖥 IP     : <code>${sip}</code>"
    pause
}

# ════════════════════════════════════════════════════════════
#  USER MANAGEMENT — SSH
#  FIX: clean_expired pakai tmpfile (hindari race condition)
# ════════════════════════════════════════════════════════════
ssh_add() {
    show_header; _top; _btn "  ${IT}${AL}➕  TAMBAH AKUN SSH${NC}"; _bot; echo ""
    echo -ne "  ${A3}Username${NC}              : "; read -r u
    [[ -z "$u" ]] && { err "Username kosong!"; pause; return; }
    id "$u" &>/dev/null && { err "User sistem '$u' sudah ada!"; pause; return; }
    grep -q "^${u}|" "$SSH_DB" 2>/dev/null && { err "Username sudah terdaftar!"; pause; return; }
    echo -ne "  ${A3}Password${NC} [auto]      : "; read -r p; [[ -z "$p" ]] && p=$(rand_pass)
    echo -ne "  ${A3}Masa aktif (hari)${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30
    echo -ne "  ${A3}Max Login Device${NC} [2]  : "; read -r ml; [[ ! "$ml" =~ ^[0-9]+$ ]] && ml=2
    local exp; exp=$(mk_exp "$d")
    useradd -e "$exp" -s /bin/false -M "$u" 2>/dev/null
    echo -e "${p}\n${p}" | passwd "$u" &>/dev/null
    echo "${u}|${p}|${exp}|${ml}" >> "$SSH_DB"; set_maxlogin "$u" "$ml"
    show_box_ssh "$u" "$p" "$exp" "$ml"
    _tg_send "✅ <b>SSH Baru</b>
👤 <code>${u}</code>  🔑 <code>${p}</code>  📅 ${exp}  🔒 ${ml}x"
    pause
}

ssh_trial() {
    show_header; _top; _btn "  ${IT}${AL}🎁  SSH TRIAL (1 jam)${NC}"; _bot; echo ""
    local u="trial$(date +%s | tail -c 6)" p; p=$(rand_pass)
    useradd -s /bin/false -M "$u" 2>/dev/null
    echo -e "${p}\n${p}" | passwd "$u" &>/dev/null
    chage -E "$(date -d '+1 day' +%Y-%m-%d)" "$u" 2>/dev/null
    echo "${u}|${p}|TRIAL-$(date +%s)|1" >> "$SSH_DB"; set_maxlogin "$u" "1"
    if command -v at &>/dev/null; then
        echo "/usr/sbin/userdel -r ${u}; sed -i '/^${u}|/d' ${SSH_DB}" | at now + 1 hour 2>/dev/null
    else
        local cid="trial-$(date +%s)-${u}" t; t=$(TZ="Asia/Jakarta" date -d "+1 hour" "+%M %H %d %m")
        echo "$t * root /usr/sbin/userdel -r ${u}; sed -i '/^${u}|/d' ${SSH_DB}; rm -f /etc/cron.d/${cid}" \
            > "/etc/cron.d/${cid}"
    fi
    show_box_ssh "$u" "$p" "Trial 1 jam" "1"; pause
}

ssh_del() {
    show_header; _top; _btn "  ${IT}${AL}🗑   HAPUS AKUN SSH${NC}"; _bot; echo ""
    ssh_list_compact; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r u
    [[ -z "$u" ]] && { err "Kosong!"; pause; return; }
    grep -q "^${u}|" "$SSH_DB" 2>/dev/null || { err "User tidak ada!"; pause; return; }
    userdel -r "$u" 2>/dev/null; sed -i "/^${u}|/d" "$SSH_DB"; del_maxlogin "$u"
    ok "User ${W}${u}${NC} dihapus"
    _tg_send "🗑 SSH deleted: <code>${u}</code>"; pause
}

ssh_renew() {
    show_header; _top; _btn "  ${IT}${AL}🔁  PERPANJANG SSH${NC}"; _bot; echo ""
    ssh_list_compact; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r u; [[ -z "$u" ]] && { pause; return; }
    grep -q "^${u}|" "$SSH_DB" 2>/dev/null || { err "User tidak ada!"; pause; return; }
    echo -ne "  ${A3}Tambah hari${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30
    local cur new; cur=$(grep "^${u}|" "$SSH_DB" | cut -d'|' -f3 | head -1)
    new=$(TZ="Asia/Jakarta" date -d "${cur} +${d} days" +"%Y-%m-%d" 2>/dev/null || mk_exp "$d")
    sed -i "s|^\(${u}|[^|]*|\)[^|]*|\1${new}|" "$SSH_DB"; chage -E "$new" "$u" 2>/dev/null
    ok "Diperpanjang → ${Y}${new}${NC}"; pause
}

ssh_list() {
    show_header; _top; _btn "  ${IT}${AL}📋  LIST AKUN SSH${NC}"; _bot; echo ""
    [[ ! -s "$SSH_DB" ]] && { warn "Belum ada akun SSH."; pause; return; }
    printf "  ${BLD}${A3}%-3s %-15s %-12s %-12s %-5s${NC}\n" "No" "Username" "Password" "Expired" "ML"
    _sep
    local i=0
    while IFS='|' read -r u p e ml; do
        i=$((i+1)); local left col; left=$(days_left "$e")
        if is_expired "$e"; then col="$LR"; left="EXP"; elif [[ "$left" -le 3 ]]; then col="$Y"; else col="$LG"; fi
        printf "  %-3s ${W}%-15s${NC} ${A3}%-12s${NC} ${col}%-12s${NC} ${Y}%-5s${NC}\n" "$i." "$u" "$p" "$e" "$ml"
    done < "$SSH_DB"; _sep; pause
}

ssh_list_compact() {
    [[ ! -s "$SSH_DB" ]] && { warn "Belum ada akun."; return; }
    printf "  ${DIM}%-3s %-15s %-12s %-12s${NC}\n" "No" "Username" "Pass" "Expired"
    local i=0
    while IFS='|' read -r u p e _; do
        i=$((i+1)); printf "  %-3s ${W}%-15s${NC} ${A3}%-12s${NC} ${Y}%-12s${NC}\n" "$i." "$u" "$p" "$e"
    done < "$SSH_DB"
}

ssh_online() {
    show_header; _top; _btn "  ${IT}${AL}🔍  SSH ONLINE${NC}"; _bot; echo ""
    local list; list=$(ps -eo user,cmd --no-headers 2>/dev/null | grep 'sshd:' | grep -v root | awk '{print $1}' | sort -u)
    [[ -z "$list" ]] && { warn "Tidak ada user online."; pause; return; }
    printf "  ${BLD}${A3}%-3s %-15s %-10s${NC}\n" "No" "Username" "Sesi"; _sep
    local i=0
    while read -r u; do
        i=$((i+1))
        local cnt; cnt=$(ps -eo user,cmd --no-headers 2>/dev/null | grep "sshd: ${u}@" | grep -c -v grep || echo 0)
        printf "  %-3s ${W}%-15s${NC} ${LG}%s sesi${NC}\n" "$i." "$u" "$cnt"
    done <<< "$list"; _sep; pause
}

# FIX: ssh_clean_expired — pakai tmpfile
ssh_clean_expired() {
    show_header; _top; _btn "  ${IT}${AL}🧹  HAPUS SSH EXPIRED${NC}"; _bot; echo ""
    [[ ! -s "$SSH_DB" ]] && { warn "DB kosong."; pause; return; }
    local td; td=$(TZ="Asia/Jakarta" date +%Y-%m-%d); local count=0 tmp; tmp=$(mktemp)
    while IFS='|' read -r u p e ml; do
        if [[ -n "$e" && "$td" > "$e" ]]; then
            userdel -r "$u" 2>/dev/null; del_maxlogin "$u"
            ok "Deleted: ${W}${u}${NC} (exp ${e})"; count=$((count+1))
        else echo "${u}|${p}|${e}|${ml}" >> "$tmp"; fi
    done < "$SSH_DB"; mv "$tmp" "$SSH_DB"
    [[ "$count" == "0" ]] && inf "Tidak ada user expired."; pause
}

# ════════════════════════════════════════════════════════════
#  USER MANAGEMENT — Xray
#  FIX: _xray_sync_clients — SS multi-user & handle field kosong
# ════════════════════════════════════════════════════════════
_xray_reload() { systemctl restart xray 2>/dev/null; sleep 0.5; }

_xray_sync_clients() {
    python3 - <<'PYSYNC' 2>/dev/null
import json, os
CFG = "/etc/xray/config.json"
DIR = "/etc/maxpanel"

def load_db(path):
    rows = []
    try:
        with open(path) as f:
            for line in f:
                line = line.strip()
                if line:
                    rows.append(line.split('|'))
    except: pass
    return rows

try:
    with open(CFG) as f: cfg = json.load(f)
except Exception as e: print(f"ERROR: {e}"); exit(1)

inbounds = cfg.get('inbounds', [])

def set_clients(tag, clients):
    for ib in inbounds:
        if ib.get('tag') == tag:
            ib.setdefault('settings', {})['clients'] = clients

vmess = [{"id": r[1], "alterId": 0, "email": r[0]} for r in load_db(f"{DIR}/vmess-users.db") if len(r)>=2]
set_clients("vmess-ws", vmess)

vless = [{"id": r[1], "encryption": "none", "flow": "", "email": r[0]} for r in load_db(f"{DIR}/vless-users.db") if len(r)>=2]
set_clients("vless-ws",   vless)
set_clients("vless-grpc", vless)

trojan = [{"password": r[1], "email": r[0]} for r in load_db(f"{DIR}/trojan-users.db") if len(r)>=2]
set_clients("trojan-ws",   trojan)
set_clients("trojan-grpc", trojan)

# FIX: SS multi-user — clients list, hapus field password lama
ss = [{"password": r[1], "method": "aes-128-gcm", "email": r[0]} for r in load_db(f"{DIR}/ss-users.db") if len(r)>=2]
for ib in inbounds:
    if ib.get('tag') == 'ss-2022':
        ib.setdefault('settings', {})
        ib['settings']['clients'] = ss
        ib['settings'].pop('password', None)  # hapus field password lama

with open(CFG, 'w') as f: json.dump(cfg, f, indent=2)
print("Xray config synced")
PYSYNC
    _xray_reload
}

# ── VMess ──────────────────────────────────────────────────
vmess_add() {
    show_header; _top; _btn "  ${IT}${AL}➕  TAMBAH VMESS${NC}"; _bot; echo ""
    echo -ne "  ${A3}Username/Remark${NC}      : "; read -r u
    [[ -z "$u" ]] && { err "Kosong!"; pause; return; }
    grep -q "^${u}|" "$VMESS_DB" 2>/dev/null && { err "User sudah ada!"; pause; return; }
    echo -ne "  ${A3}Masa aktif (hari)${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30
    echo -ne "  ${A3}Max Login Device${NC} [2]  : "; read -r ml; [[ ! "$ml" =~ ^[0-9]+$ ]] && ml=2
    local uuid exp; uuid=$(rand_uuid); exp=$(mk_exp "$d")
    echo "${u}|${uuid}|${exp}|${ml}" >> "$VMESS_DB"; set_maxlogin "$u" "$ml"; _xray_sync_clients
    show_box_xray "VMess" "$u" "$uuid" "$exp" "$ml"
    local dom; dom=$(get_domain)
    local vt; vt=$(printf '%s' "{\"v\":\"2\",\"ps\":\"${u}-TLS\",\"add\":\"${dom}\",\"port\":\"443\",\"id\":\"${uuid}\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${dom}\",\"path\":\"/vmess\",\"tls\":\"tls\",\"sni\":\"${dom}\"}" | base64 -w0)
    local vh; vh=$(printf '%s' "{\"v\":\"2\",\"ps\":\"${u}-HTTP\",\"add\":\"${dom}\",\"port\":\"80\",\"id\":\"${uuid}\",\"aid\":\"0\",\"net\":\"ws\",\"type\":\"none\",\"host\":\"${dom}\",\"path\":\"/vmess\",\"tls\":\"none\"}" | base64 -w0)
    echo -e "  ${DIM}🔗 TLS :${NC}"; echo -e "  ${LG}vmess://${vt}${NC}"; echo ""
    echo -e "  ${DIM}🔗 HTTP:${NC}"; echo -e "  ${LG}vmess://${vh}${NC}"; echo ""
    _show_xray_config "VMess" "$u" "$uuid" "$dom"
    _tg_send "✅ <b>VMess Baru</b> 👤 <code>${u}</code>  🔑 <code>${uuid}</code>  📅 ${exp}"; pause
}

vmess_trial() {
    show_header; _top; _btn "  ${IT}${AL}🎁  VMESS TRIAL${NC}"; _bot; echo ""
    local u="trial-vmess-$(date +%s | tail -c 5)" uuid; uuid=$(rand_uuid)
    echo "${u}|${uuid}|$(mk_exp 1)|1" >> "$VMESS_DB"; set_maxlogin "$u" "1"; _xray_sync_clients
    show_box_xray "VMess" "$u" "$uuid" "Trial 1 jam" "1"
    local cid="trial-vmess-$(date +%s)" t; t=$(TZ="Asia/Jakarta" date -d "+1 hour" "+%M %H %d %m")
    echo "$t * root sed -i '/^${u}|/d' ${VMESS_DB}; sed -i '/^${u}|/d' ${MLDB}; /usr/local/bin/max-menu --sync-xray; rm -f /etc/cron.d/${cid}" > "/etc/cron.d/${cid}"
    pause
}

vmess_del() {
    show_header; _top; _btn "  ${IT}${AL}🗑   HAPUS VMESS${NC}"; _bot; echo ""
    xray_list_compact "$VMESS_DB" "VMess"; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r u; [[ -z "$u" ]] && { pause; return; }
    grep -q "^${u}|" "$VMESS_DB" || { err "Tidak ada!"; pause; return; }
    sed -i "/^${u}|/d" "$VMESS_DB"; del_maxlogin "$u"; _xray_sync_clients
    ok "VMess ${W}${u}${NC} dihapus"; _tg_send "🗑 VMess deleted: <code>${u}</code>"; pause
}

vmess_renew() {
    show_header; _top; _btn "  ${IT}${AL}🔁  PERPANJANG VMESS${NC}"; _bot; echo ""
    xray_list_compact "$VMESS_DB" "VMess"; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r u; [[ -z "$u" ]] && { pause; return; }
    grep -q "^${u}|" "$VMESS_DB" || { err "Tidak ada!"; pause; return; }
    echo -ne "  ${A3}Tambah hari${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30
    local cur new; cur=$(grep "^${u}|" "$VMESS_DB" | cut -d'|' -f3)
    new=$(TZ="Asia/Jakarta" date -d "${cur} +${d} days" +"%Y-%m-%d" 2>/dev/null || mk_exp "$d")
    sed -i "s|^\(${u}|[^|]*|\)[^|]*|\1${new}|" "$VMESS_DB"; ok "VMess → ${Y}${new}${NC}"; pause
}

vmess_list() { show_header; _top; _btn "  ${IT}${AL}📋  LIST VMESS${NC}"; _bot; echo ""; xray_list_pretty "$VMESS_DB" "VMess" "UUID"; pause; }

# ── VLess ──────────────────────────────────────────────────
vless_add() {
    show_header; _top; _btn "  ${IT}${AL}➕  TAMBAH VLESS${NC}"; _bot; echo ""
    echo -ne "  ${A3}Username/Remark${NC}      : "; read -r u; [[ -z "$u" ]] && { pause; return; }
    grep -q "^${u}|" "$VLESS_DB" 2>/dev/null && { err "User sudah ada!"; pause; return; }
    echo -ne "  ${A3}Masa aktif (hari)${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30
    echo -ne "  ${A3}Max Login Device${NC} [2]  : "; read -r ml; [[ ! "$ml" =~ ^[0-9]+$ ]] && ml=2
    local uuid exp; uuid=$(rand_uuid); exp=$(mk_exp "$d")
    echo "${u}|${uuid}|${exp}|${ml}" >> "$VLESS_DB"; set_maxlogin "$u" "$ml"; _xray_sync_clients
    show_box_xray "VLess" "$u" "$uuid" "$exp" "$ml"
    local dom; dom=$(get_domain)
    echo -e "  ${DIM}🔗 WS TLS :${NC}"; echo -e "  ${LG}vless://${uuid}@${dom}:443?path=/vless&security=tls&encryption=none&host=${dom}&type=ws&sni=${dom}#${u}-TLS${NC}"; echo ""
    echo -e "  ${DIM}🔗 WS HTTP:${NC}"; echo -e "  ${LG}vless://${uuid}@${dom}:80?path=/vless&encryption=none&host=${dom}&type=ws#${u}-HTTP${NC}"; echo ""
    echo -e "  ${DIM}🔗 gRPC   :${NC}"; echo -e "  ${LG}vless://${uuid}@${dom}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vless-grpc&sni=${dom}#${u}-gRPC${NC}"; echo ""
    _show_xray_config "VLess" "$u" "$uuid" "$dom"
    _tg_send "✅ <b>VLess Baru</b> 👤 <code>${u}</code>  🔑 <code>${uuid}</code>  📅 ${exp}"; pause
}

vless_trial() {
    show_header; _top; _btn "  ${IT}${AL}🎁  VLESS TRIAL${NC}"; _bot; echo ""
    local u="trial-vless-$(date +%s | tail -c 5)" uuid; uuid=$(rand_uuid)
    echo "${u}|${uuid}|$(mk_exp 1)|1" >> "$VLESS_DB"; set_maxlogin "$u" "1"; _xray_sync_clients
    show_box_xray "VLess" "$u" "$uuid" "Trial 1 jam" "1"
    local cid="trial-vless-$(date +%s)" t; t=$(TZ="Asia/Jakarta" date -d "+1 hour" "+%M %H %d %m")
    echo "$t * root sed -i '/^${u}|/d' ${VLESS_DB}; /usr/local/bin/max-menu --sync-xray; rm -f /etc/cron.d/${cid}" > "/etc/cron.d/${cid}"
    pause
}

vless_del()   {
    show_header; _top; _btn "  ${IT}${AL}🗑   HAPUS VLESS${NC}"; _bot; echo ""; xray_list_compact "$VLESS_DB" "VLess"; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r u; grep -q "^${u}|" "$VLESS_DB" || { err "Tidak ada!"; pause; return; }
    sed -i "/^${u}|/d" "$VLESS_DB"; del_maxlogin "$u"; _xray_sync_clients; ok "VLess ${W}${u}${NC} dihapus"; pause
}
vless_renew() {
    show_header; _top; _btn "  ${IT}${AL}🔁  PERPANJANG VLESS${NC}"; _bot; echo ""; xray_list_compact "$VLESS_DB" "VLess"; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r u; grep -q "^${u}|" "$VLESS_DB" || { err "Tidak ada!"; pause; return; }
    echo -ne "  ${A3}Tambah hari${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30
    local cur new; cur=$(grep "^${u}|" "$VLESS_DB" | cut -d'|' -f3)
    new=$(TZ="Asia/Jakarta" date -d "${cur} +${d} days" +"%Y-%m-%d" 2>/dev/null || mk_exp "$d")
    sed -i "s|^\(${u}|[^|]*|\)[^|]*|\1${new}|" "$VLESS_DB"; ok "→ ${Y}${new}${NC}"; pause
}
vless_list()  { show_header; _top; _btn "  ${IT}${AL}📋  LIST VLESS${NC}"; _bot; echo ""; xray_list_pretty "$VLESS_DB" "VLess" "UUID"; pause; }

# ── Trojan (Xray) ─────────────────────────────────────────
trojan_add() {
    show_header; _top; _btn "  ${IT}${AL}➕  TAMBAH TROJAN${NC}"; _bot; echo ""
    echo -ne "  ${A3}Username/Remark${NC}      : "; read -r u; [[ -z "$u" ]] && { pause; return; }
    grep -q "^${u}|" "$TROJAN_DB" 2>/dev/null && { err "User sudah ada!"; pause; return; }
    echo -ne "  ${A3}Password${NC} [auto]      : "; read -r p; [[ -z "$p" ]] && p=$(rand_pass)
    echo -ne "  ${A3}Masa aktif (hari)${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30
    echo -ne "  ${A3}Max Login Device${NC} [2]  : "; read -r ml; [[ ! "$ml" =~ ^[0-9]+$ ]] && ml=2
    local exp; exp=$(mk_exp "$d")
    echo "${u}|${p}|${exp}|${ml}" >> "$TROJAN_DB"; set_maxlogin "$u" "$ml"; _xray_sync_clients
    show_box_xray "Trojan" "$u" "$p" "$exp" "$ml"
    local dom; dom=$(get_domain)
    echo -e "  ${DIM}🔗 WS TLS  :${NC}"; echo -e "  ${LG}trojan://${p}@${dom}:443?path=/trojan-ws&security=tls&host=${dom}&type=ws&sni=${dom}#${u}-WS${NC}"; echo ""
    echo -e "  ${DIM}🔗 gRPC TLS:${NC}"; echo -e "  ${LG}trojan://${p}@${dom}:443?mode=gun&security=tls&type=grpc&serviceName=trojan-grpc&sni=${dom}#${u}-gRPC${NC}"; echo ""
    _show_xray_config "Trojan" "$u" "$p" "$dom"
    _tg_send "✅ <b>Trojan Baru</b> 👤 <code>${u}</code>  🔑 <code>${p}</code>  📅 ${exp}"; pause
}
trojan_trial() {
    show_header; _top; _btn "  ${IT}${AL}🎁  TROJAN TRIAL${NC}"; _bot; echo ""
    local u="trial-trojan-$(date +%s | tail -c 5)" p; p=$(rand_pass)
    echo "${u}|${p}|$(mk_exp 1)|1" >> "$TROJAN_DB"; set_maxlogin "$u" "1"; _xray_sync_clients
    show_box_xray "Trojan" "$u" "$p" "Trial 1 jam" "1"
    local cid="trial-trojan-$(date +%s)" t; t=$(TZ="Asia/Jakarta" date -d "+1 hour" "+%M %H %d %m")
    echo "$t * root sed -i '/^${u}|/d' ${TROJAN_DB}; /usr/local/bin/max-menu --sync-xray; rm -f /etc/cron.d/${cid}" > "/etc/cron.d/${cid}"
    pause
}
trojan_del()   {
    show_header; _top; _btn "  ${IT}${AL}🗑   HAPUS TROJAN${NC}"; _bot; echo ""; xray_list_compact "$TROJAN_DB" "Trojan"; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r u; grep -q "^${u}|" "$TROJAN_DB" || { err "Tidak ada!"; pause; return; }
    sed -i "/^${u}|/d" "$TROJAN_DB"; del_maxlogin "$u"; _xray_sync_clients; ok "Trojan ${W}${u}${NC} dihapus"; pause
}
trojan_renew() {
    show_header; _top; _btn "  ${IT}${AL}🔁  PERPANJANG TROJAN${NC}"; _bot; echo ""; xray_list_compact "$TROJAN_DB" "Trojan"; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r u; grep -q "^${u}|" "$TROJAN_DB" || { err "Tidak ada!"; pause; return; }
    echo -ne "  ${A3}Tambah hari${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30
    local cur new; cur=$(grep "^${u}|" "$TROJAN_DB" | cut -d'|' -f3)
    new=$(TZ="Asia/Jakarta" date -d "${cur} +${d} days" +"%Y-%m-%d" 2>/dev/null || mk_exp "$d")
    sed -i "s|^\(${u}|[^|]*|\)[^|]*|\1${new}|" "$TROJAN_DB"; ok "→ ${Y}${new}${NC}"; pause
}
trojan_list()  { show_header; _top; _btn "  ${IT}${AL}📋  LIST TROJAN${NC}"; _bot; echo ""; xray_list_pretty "$TROJAN_DB" "Trojan" "Password"; pause; }

# ── Shadowsocks ────────────────────────────────────────────
ss_add() {
    show_header; _top; _btn "  ${IT}${AL}➕  TAMBAH SHADOWSOCKS${NC}"; _bot; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r u; [[ -z "$u" ]] && { pause; return; }
    grep -q "^${u}|" "$SS_DB" 2>/dev/null && { err "User sudah ada!"; pause; return; }
    echo -ne "  ${A3}Password${NC} [auto]: "; read -r p; [[ -z "$p" ]] && p=$(rand_pass)
    echo -ne "  ${A3}Masa aktif (hari)${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30
    echo -ne "  ${A3}Max Login${NC} [2]        : "; read -r ml; [[ ! "$ml" =~ ^[0-9]+$ ]] && ml=2
    local exp; exp=$(mk_exp "$d")
    echo "${u}|${p}|${exp}|${ml}" >> "$SS_DB"; set_maxlogin "$u" "$ml"; _xray_sync_clients
    show_box_xray "Shadowsocks" "$u" "$p" "$exp" "$ml"
    local link; link=$(printf '%s' "aes-128-gcm:${p}@$(get_domain):8388" | base64 -w0)
    echo -e "  ${DIM}🔗 SS Link:${NC}"; echo -e "  ${LG}ss://${link}#${u}${NC}"; echo ""; pause
}
ss_del()  {
    show_header; _top; _btn "  ${IT}${AL}🗑   HAPUS SS${NC}"; _bot; echo ""; xray_list_compact "$SS_DB" "SS"; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r u; grep -q "^${u}|" "$SS_DB" || { err "Tidak ada!"; pause; return; }
    sed -i "/^${u}|/d" "$SS_DB"; del_maxlogin "$u"; _xray_sync_clients; ok "SS ${W}${u}${NC} dihapus"; pause
}
ss_list() { show_header; _top; _btn "  ${IT}${AL}📋  LIST SS${NC}"; _bot; echo ""; xray_list_pretty "$SS_DB" "Shadowsocks" "Password"; pause; }

# ── Xray helper list ──────────────────────────────────────
xray_list_pretty() {
    local db="$1" label="$2" col2="$3"
    [[ ! -s "$db" ]] && { warn "Belum ada akun ${label}."; return; }
    printf "  ${BLD}${A3}%-3s %-15s %-36s %-12s %-3s${NC}\n" "No" "User" "$col2" "Expired" "ML"; _sep
    local i=0
    while IFS='|' read -r u key e ml; do
        i=$((i+1)); local col
        if is_expired "$e"; then col="$LR"; elif [[ "$(days_left "$e")" -le 3 ]]; then col="$Y"; else col="$LG"; fi
        printf "  %-3s ${W}%-15s${NC} ${A3}%-36s${NC} ${col}%-12s${NC} ${Y}%-3s${NC}\n" "$i." "$u" "$key" "$e" "$ml"
    done < "$db"; _sep
}
xray_list_compact() {
    local db="$1" label="$2"
    [[ ! -s "$db" ]] && { warn "Belum ada akun ${label}."; return; }
    printf "  ${DIM}%-3s %-15s %-12s${NC}\n" "No" "Username" "Expired"
    local i=0
    while IFS='|' read -r u _ e _; do
        i=$((i+1)); printf "  %-3s ${W}%-15s${NC} ${Y}%-12s${NC}\n" "$i." "$u" "$e"
    done < "$db"
}
xray_online() {
    show_header; _top; _btn "  ${IT}${AL}🔍  XRAY ONLINE${NC}"; _bot; echo ""
    [[ ! -s "$XRAY_LOG" ]] && { warn "Log Xray kosong."; pause; return; }
    local since; since=$(date -d '5 min ago' '+%Y/%m/%d %H:%M:%S' 2>/dev/null)
    inf "5 menit terakhir:"
    awk -v s="$since" '$0>=s && /email:/ {for(i=1;i<=NF;i++) if($i=="email:") print $(i+1)}' "$XRAY_LOG" \
        | sort | uniq -c | sort -rn | head -50 \
        | awk -v W="$W" -v G="$LG" -v N="$NC" '{printf "  %s%-3d%s  %s%-30s%s\n",G,$1,N,W,$2,N}'
    echo ""; pause
}
# FIX: xray_clean_expired — pakai tmpfile
xray_clean_expired() {
    show_header; _top; _btn "  ${IT}${AL}🧹  HAPUS XRAY EXPIRED${NC}"; _bot; echo ""
    local td; td=$(TZ="Asia/Jakarta" date +%Y-%m-%d); local count=0 f
    for f in "$VMESS_DB" "$VLESS_DB" "$TROJAN_DB" "$SS_DB"; do
        [[ -s "$f" ]] || continue
        local tmp; tmp=$(mktemp)
        while IFS='|' read -r u key e ml; do
            if [[ -n "$e" && "$td" > "$e" ]]; then
                del_maxlogin "$u"; ok "Hapus: ${W}${u}${NC}"; count=$((count+1))
            else echo "${u}|${key}|${e}|${ml}" >> "$tmp"; fi
        done < "$f"; mv "$tmp" "$f"
    done
    _xray_sync_clients; [[ "$count" == "0" ]] && inf "Tidak ada expired."; pause
}

# ════════════════════════════════════════════════════════════
#  USER MANAGEMENT — Trojan-Go, Hysteria, OpenVPN, WireGuard, SlowDNS
# ════════════════════════════════════════════════════════════
_trojango_sync() {
    [[ ! -f "$TROJANGO_CFG" ]] && return
    python3 - <<'PY' 2>/dev/null
import json, os
CFG="/etc/trojan-go/config.json"; DB="/etc/maxpanel/trojango-users.db"
try:
    with open(CFG) as f: c=json.load(f)
except: c={}
pws=[]
try:
    with open(DB) as f:
        for l in f:
            p=l.strip().split("|")
            if len(p)>=2: pws.append(p[1])
except: pass
c['password']=pws
with open(CFG,'w') as f: json.dump(c,f,indent=2)
PY
    systemctl restart trojan-go 2>/dev/null
}

tgo_add() {
    show_header; _top; _btn "  ${IT}${AL}➕  TAMBAH TROJAN-GO${NC}"; _bot; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r u; [[ -z "$u" ]] && { pause; return; }
    grep -q "^${u}|" "$TROJANGO_DB" 2>/dev/null && { err "User sudah ada!"; pause; return; }
    echo -ne "  ${A3}Password${NC} [auto]: "; read -r p; [[ -z "$p" ]] && p=$(rand_pass)
    echo -ne "  ${A3}Masa aktif (hari)${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30
    echo -ne "  ${A3}Max Login${NC} [2]        : "; read -r ml; [[ ! "$ml" =~ ^[0-9]+$ ]] && ml=2
    local exp; exp=$(mk_exp "$d"); echo "${u}|${p}|${exp}|${ml}" >> "$TROJANGO_DB"
    set_maxlogin "$u" "$ml"; _trojango_sync
    local dom; dom=$(get_domain)
    echo -e "\n  ${LG}✅ Akun Trojan-Go${NC}"
    echo -e "  ${A1}┌─────────────────────────────────────────────────────────${NC}"
    printf  "  ${A1}│${NC} 👤 %-12s: ${W}%s${NC}\n🔑 %-12s: ${A3}%s${NC}\n🌐 %-12s: ${W}%s${NC}\n🔌 Port 2087  📅 Expired: ${Y}%s${NC}\n" \
        "Username" "$u" "Password" "$p" "Host" "$dom" "$exp"
    echo -e "  ${A1}└─────────────────────────────────────────────────────────${NC}"
    echo -e "  ${DIM}🔗 Link:${NC}"; echo -e "  ${LG}trojan-go://${p}@${dom}:2087?sni=${dom}&type=ws&path=%2Ftrojan-go#${u}${NC}"; echo ""
    _tg_send "✅ <b>Trojan-Go</b> 👤 <code>${u}</code>  🔑 <code>${p}</code>"; pause
}
tgo_trial() {
    show_header; _top; _btn "  ${IT}${AL}🎁  TGO TRIAL${NC}"; _bot; echo ""
    local u="trial-tgo-$(date +%s | tail -c 5)" p; p=$(rand_pass)
    echo "${u}|${p}|$(mk_exp 1)|1" >> "$TROJANGO_DB"; set_maxlogin "$u" "1"; _trojango_sync
    ok "Trial: ${W}${u}${NC} / ${A3}${p}${NC}"
    local cid="trial-tgo-$(date +%s)" t; t=$(TZ="Asia/Jakarta" date -d "+1 hour" "+%M %H %d %m")
    echo "$t * root sed -i '/^${u}|/d' ${TROJANGO_DB}; systemctl restart trojan-go; rm -f /etc/cron.d/${cid}" > "/etc/cron.d/${cid}"
    pause
}
tgo_del()   { show_header; _top; _btn "  ${IT}${AL}🗑   HAPUS TGO${NC}"; _bot; echo ""; xray_list_compact "$TROJANGO_DB" "Trojan-Go"; echo ""; echo -ne "  ${A3}Username${NC}: "; read -r u; grep -q "^${u}|" "$TROJANGO_DB" || { err "Tidak ada!"; pause; return; }; sed -i "/^${u}|/d" "$TROJANGO_DB"; del_maxlogin "$u"; _trojango_sync; ok "TGO ${W}${u}${NC} dihapus"; pause; }
tgo_renew() { show_header; _top; _btn "  ${IT}${AL}🔁  PERPANJANG TGO${NC}"; _bot; echo ""; xray_list_compact "$TROJANGO_DB" "Trojan-Go"; echo ""; echo -ne "  ${A3}Username${NC}: "; read -r u; grep -q "^${u}|" "$TROJANGO_DB" || { err "Tidak ada!"; pause; return; }; echo -ne "  ${A3}Tambah hari${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30; local cur new; cur=$(grep "^${u}|" "$TROJANGO_DB" | cut -d'|' -f3); new=$(TZ="Asia/Jakarta" date -d "${cur} +${d} days" +"%Y-%m-%d" 2>/dev/null || mk_exp "$d"); sed -i "s|^\(${u}|[^|]*|\)[^|]*|\1${new}|" "$TROJANGO_DB"; ok "→ ${Y}${new}${NC}"; pause; }
tgo_list()  { show_header; _top; _btn "  ${IT}${AL}📋  LIST TGO${NC}"; _bot; echo ""; xray_list_pretty "$TROJANGO_DB" "Trojan-Go" "Password"; pause; }

_hy_sync() {
    [[ ! -f "$HY_CFG" ]] && return
    python3 - <<'PY' 2>/dev/null
import os,re
CFG="/etc/hysteria/config.yaml"; DB="/etc/maxpanel/hysteria-users.db"
up={}
try:
    with open(DB) as f:
        for l in f:
            p=l.strip().split("|")
            if len(p)>=2: up[p[0]]=p[1]
except: pass
try:
    with open(CFG) as f: content=f.read()
except: content=""
content=re.sub(r'(?ms)^auth:.*?(?=^\S|\Z)','',content,flags=re.M).rstrip()
ul="\n".join(f'    {k}: "{v}"' for k,v in up.items())
content+=f"\nauth:\n  type: userpass\n  userpass:\n{ul}\n"
with open(CFG,'w') as f: f.write(content)
PY
    systemctl restart hysteria-server 2>/dev/null
}

hy_add() {
    show_header; _top; _btn "  ${IT}${AL}➕  TAMBAH HYSTERIA 2${NC}"; _bot; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r u; [[ -z "$u" ]] && { pause; return; }
    grep -q "^${u}|" "$HY_DB" 2>/dev/null && { err "User sudah ada!"; pause; return; }
    echo -ne "  ${A3}Password${NC} [auto]: "; read -r p; [[ -z "$p" ]] && p=$(rand_pass)
    echo -ne "  ${A3}Masa aktif (hari)${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30
    echo -ne "  ${A3}Max Login${NC} [2]        : "; read -r ml; [[ ! "$ml" =~ ^[0-9]+$ ]] && ml=2
    local exp; exp=$(mk_exp "$d"); echo "${u}|${p}|${exp}|${ml}" >> "$HY_DB"; set_maxlogin "$u" "$ml"; _hy_sync
    local dom; dom=$(get_domain)
    echo -e "\n  ${LG}✅ Akun Hysteria 2${NC}"
    echo -e "  ${A1}┌─────────────────────────────────────────────────────────${NC}"
    printf  "  ${A1}│${NC} 👤 %-12s: ${W}%s${NC}\n  ${A1}│${NC} 🔑 %-12s: ${A3}%s${NC}\n  ${A1}│${NC} 🌐 %-12s: ${W}%s${NC}\n  ${A1}│${NC} 🔌 %-12s: ${Y}36712 (UDP)${NC}\n  ${A1}│${NC} 📅 %-12s: ${Y}%s${NC}\n" \
        "Username" "$u" "Password" "$p" "Host" "$dom" "Port" "Expired" "$exp"
    echo -e "  ${A1}└─────────────────────────────────────────────────────────${NC}"
    echo -e "  ${DIM}🔗 Link:${NC}"; echo -e "  ${LG}hy2://${u}:${p}@${dom}:36712?insecure=1&sni=${dom}#${u}${NC}"; echo ""
    _tg_send "✅ <b>Hysteria Baru</b> 👤 <code>${u}</code>  🔑 <code>${p}</code>"; pause
}
hy_trial()  { show_header; _top; _btn "  ${IT}${AL}🎁  HY TRIAL${NC}"; _bot; echo ""; local u="trial-hy-$(date +%s | tail -c 5)" p; p=$(rand_pass); echo "${u}|${p}|$(mk_exp 1)|1" >> "$HY_DB"; set_maxlogin "$u" "1"; _hy_sync; ok "Trial: ${W}${u}${NC} / ${A3}${p}${NC}"; local cid="trial-hy-$(date +%s)" t; t=$(TZ="Asia/Jakarta" date -d "+1 hour" "+%M %H %d %m"); echo "$t * root sed -i '/^${u}|/d' ${HY_DB}; systemctl restart hysteria-server; rm -f /etc/cron.d/${cid}" > "/etc/cron.d/${cid}"; pause; }
hy_del()    { show_header; _top; _btn "  ${IT}${AL}🗑   HAPUS HY${NC}"; _bot; echo ""; xray_list_compact "$HY_DB" "Hysteria"; echo ""; echo -ne "  ${A3}Username${NC}: "; read -r u; grep -q "^${u}|" "$HY_DB" || { err "Tidak ada!"; pause; return; }; sed -i "/^${u}|/d" "$HY_DB"; del_maxlogin "$u"; _hy_sync; ok "HY ${W}${u}${NC} dihapus"; pause; }
hy_renew()  { show_header; _top; _btn "  ${IT}${AL}🔁  PERPANJANG HY${NC}"; _bot; echo ""; xray_list_compact "$HY_DB" "Hysteria"; echo ""; echo -ne "  ${A3}Username${NC}: "; read -r u; grep -q "^${u}|" "$HY_DB" || { err "Tidak ada!"; pause; return; }; echo -ne "  ${A3}Tambah hari${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30; local cur new; cur=$(grep "^${u}|" "$HY_DB" | cut -d'|' -f3); new=$(TZ="Asia/Jakarta" date -d "${cur} +${d} days" +"%Y-%m-%d" 2>/dev/null || mk_exp "$d"); sed -i "s|^\(${u}|[^|]*|\)[^|]*|\1${new}|" "$HY_DB"; ok "→ ${Y}${new}${NC}"; pause; }
hy_list()   { show_header; _top; _btn "  ${IT}${AL}📋  LIST HY${NC}"; _bot; echo ""; xray_list_pretty "$HY_DB" "Hysteria" "Password"; pause; }

# FIX: _make_ovpn_client pakai data-ciphers (OpenVPN 2.5+)
_make_ovpn_client() {
    local user="$1" srv="$2" port="$3" proto="$4"
    local ca; ca=$(cat /etc/openvpn/server/ca.crt 2>/dev/null)
    local ta; ta=$(cat /etc/openvpn/server/ta.key 2>/dev/null)
    cat <<OVPNCLI
client
dev tun
proto ${proto}
remote ${srv} ${port}
resolv-retry infinite
nobind
persist-key
persist-tun
remote-cert-tls server
data-ciphers AES-256-GCM:AES-128-GCM:AES-128-CBC
data-ciphers-fallback AES-128-CBC
auth SHA256
auth-user-pass
auth-nocache
verb 3
<ca>
${ca}
</ca>
<tls-auth>
${ta}
</tls-auth>
key-direction 1
OVPNCLI
}

ovpn_add() {
    show_header; _top; _btn "  ${IT}${AL}➕  TAMBAH OPENVPN${NC}"; _bot; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r u; [[ -z "$u" ]] && { pause; return; }
    grep -q "^${u}|" "$OVPN_DB" 2>/dev/null && { err "User sudah ada!"; pause; return; }
    id "$u" &>/dev/null && { err "User sistem sudah ada!"; pause; return; }
    echo -ne "  ${A3}Password${NC} [auto]: "; read -r p; [[ -z "$p" ]] && p=$(rand_pass)
    echo -ne "  ${A3}Masa aktif (hari)${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30
    echo -ne "  ${A3}Max Login${NC} [2]        : "; read -r ml; [[ ! "$ml" =~ ^[0-9]+$ ]] && ml=2
    local exp; exp=$(mk_exp "$d")
    useradd -e "$exp" -s /bin/false -M "$u" 2>/dev/null; echo -e "${p}\n${p}" | passwd "$u" &>/dev/null
    echo "${u}|${p}|${exp}|${ml}" >> "$OVPN_DB"; set_maxlogin "$u" "$ml"
    local ip; ip=$(get_ip); mkdir -p "/etc/openvpn/client/${u}"
    _make_ovpn_client "$u" "$ip" "1194" "tcp" > "/etc/openvpn/client/${u}/${u}-tcp.ovpn"
    _make_ovpn_client "$u" "$ip" "2200" "udp" > "/etc/openvpn/client/${u}/${u}-udp.ovpn"
    echo -e "\n  ${LG}✅ Akun OpenVPN${NC}"
    printf  "  User: ${W}%s${NC}  Pass: ${A3}%s${NC}  TCP:${Y}1194${NC}  UDP:${Y}2200${NC}  Exp: ${Y}%s${NC}\n" "$u" "$p" "$exp"
    printf  "  Config: ${W}/etc/openvpn/client/%s/${NC}\n" "$u"; echo ""
    _tg_send "✅ <b>OpenVPN</b> 👤 <code>${u}</code>  🔑 <code>${p}</code>"; pause
}
ovpn_trial() { show_header; _top; _btn "  ${IT}${AL}🎁  OVPN TRIAL${NC}"; _bot; echo ""; local u="trial-ovpn-$(date +%s | tail -c 5)" p; p=$(rand_pass); useradd -s /bin/false -M "$u" 2>/dev/null; echo -e "${p}\n${p}" | passwd "$u" &>/dev/null; chage -E "$(date -d '+1 day' +%Y-%m-%d)" "$u" 2>/dev/null; echo "${u}|${p}|TRIAL|1" >> "$OVPN_DB"; set_maxlogin "$u" "1"; ok "Trial: ${W}${u}${NC} / ${A3}${p}${NC}"; local cid="trial-ovpn-$(date +%s)" t; t=$(TZ="Asia/Jakarta" date -d "+1 hour" "+%M %H %d %m"); echo "$t * root userdel -r ${u}; sed -i '/^${u}|/d' ${OVPN_DB}; rm -f /etc/cron.d/${cid}" > "/etc/cron.d/${cid}"; pause; }
ovpn_del()   { show_header; _top; _btn "  ${IT}${AL}🗑   HAPUS OVPN${NC}"; _bot; echo ""; xray_list_compact "$OVPN_DB" "OpenVPN"; echo ""; echo -ne "  ${A3}Username${NC}: "; read -r u; grep -q "^${u}|" "$OVPN_DB" || { err "Tidak ada!"; pause; return; }; userdel -r "$u" 2>/dev/null; sed -i "/^${u}|/d" "$OVPN_DB"; del_maxlogin "$u"; rm -rf "/etc/openvpn/client/${u}" 2>/dev/null; ok "OVPN ${W}${u}${NC} dihapus"; pause; }
ovpn_renew() { show_header; _top; _btn "  ${IT}${AL}🔁  PERPANJANG OVPN${NC}"; _bot; echo ""; xray_list_compact "$OVPN_DB" "OpenVPN"; echo ""; echo -ne "  ${A3}Username${NC}: "; read -r u; grep -q "^${u}|" "$OVPN_DB" || { err "Tidak ada!"; pause; return; }; echo -ne "  ${A3}Tambah hari${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30; local cur new; cur=$(grep "^${u}|" "$OVPN_DB" | cut -d'|' -f3); new=$(TZ="Asia/Jakarta" date -d "${cur} +${d} days" +"%Y-%m-%d" 2>/dev/null || mk_exp "$d"); sed -i "s|^\(${u}|[^|]*|\)[^|]*|\1${new}|" "$OVPN_DB"; chage -E "$new" "$u" 2>/dev/null; ok "→ ${Y}${new}${NC}"; pause; }
ovpn_list()  { show_header; _top; _btn "  ${IT}${AL}📋  LIST OVPN${NC}"; _bot; echo ""; xray_list_pretty "$OVPN_DB" "OpenVPN" "Password"; pause; }
ovpn_online(){ show_header; _top; _btn "  ${IT}${AL}🔍  OVPN ONLINE${NC}"; _bot; echo ""; for st in /var/log/openvpn-tcp-status.log /var/log/openvpn-udp-status.log; do [[ -f "$st" ]] || continue; echo -e "  ${DIM}$(basename $st)${NC}"; awk -F',' '/^CLIENT_LIST/{print $2,$3}' "$st" 2>/dev/null | while read -r u v; do printf "  ${W}%-15s${NC} ${A3}%s${NC}\n" "$u" "$v"; done; echo ""; done; pause; }

# ── WireGuard ─────────────────────────────────────────────
# FIX: chmod 600 pada WG_CFG setelah setiap append peer
wg_next_ip() {
    local used last; used=$(awk -F'|' '{print $4}' "$WG_DB" 2>/dev/null | sort -t. -k4 -n | tail -1)
    [[ -n "$used" ]] && last=$(echo "$used" | awk -F'.' '{print $4}') && echo "10.66.66.$((last+1))" || echo "10.66.66.2"
}
wg_add() {
    show_header; _top; _btn "  ${IT}${AL}➕  TAMBAH PEER WG${NC}"; _bot; echo ""
    echo -ne "  ${A3}Username/Remark${NC}: "; read -r u; [[ -z "$u" ]] && { pause; return; }
    grep -q "^${u}|" "$WG_DB" 2>/dev/null && { err "User sudah ada!"; pause; return; }
    echo -ne "  ${A3}Masa aktif (hari)${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30
    echo -ne "  ${A3}Max Login${NC} [2]        : "; read -r ml; [[ ! "$ml" =~ ^[0-9]+$ ]] && ml=2
    local privk pubk psk ip exp spub
    privk=$(wg genkey); pubk=$(echo "$privk" | wg pubkey); psk=$(wg genpsk)
    ip=$(wg_next_ip); exp=$(mk_exp "$d"); spub=$(cat "$WG_DIR/server_public.key")
    { echo ""; echo "# BEGIN ${u}"; echo "[Peer]"; echo "PublicKey = ${pubk}"; echo "PresharedKey = ${psk}"; echo "AllowedIPs = ${ip}/32"; echo "# END ${u}"; } >> "$WG_CFG"
    chmod 600 "$WG_CFG"  # FIX
    wg syncconf wg0 <(wg-quick strip wg0) 2>/dev/null || systemctl restart wg-quick@wg0
    echo "${u}|${pubk}|${privk}|${ip}|${exp}|${ml}" >> "$WG_DB"; set_maxlogin "$u" "$ml"
    mkdir -p "$WG_CLIENT_DIR"; chmod 700 "$WG_CLIENT_DIR"
    local cfile="$WG_CLIENT_DIR/${u}.conf" srv; srv=$(get_domain)
    ( umask 077; cat > "$cfile" <<WGCLI
[Interface]
PrivateKey = ${privk}
Address = ${ip}/24
DNS = 1.1.1.1, 8.8.8.8
[Peer]
PublicKey = ${spub}
PresharedKey = ${psk}
Endpoint = ${srv}:51820
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
WGCLI
)
    echo -e "\n  ${LG}✅ Peer WireGuard${NC}"
    printf  "  ${W}%s${NC} — IP: ${A3}%s${NC} — Exp: ${Y}%s${NC} — Config: %s\n" "$u" "$ip" "$exp" "$cfile"
    command -v qrencode &>/dev/null && { echo -e "\n  ${DIM}QR Code:${NC}"; qrencode -t ANSIUTF8 < "$cfile"; }; echo ""
    _tg_send "✅ <b>WireGuard</b> 👤 <code>${u}</code>  📡 <code>${ip}</code>"; pause
}
wg_del()   {
    show_header; _top; _btn "  ${IT}${AL}🗑   HAPUS PEER WG${NC}"; _bot; echo ""
    [[ ! -s "$WG_DB" ]] && { warn "Belum ada peer."; pause; return; }
    awk -F'|' '{printf "  %-15s  %-15s  %s\n",$1,$4,$5}' "$WG_DB"; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r u
    grep -q "^${u}|" "$WG_DB" || { err "Tidak ada!"; pause; return; }
    sed -i "/^# BEGIN ${u}$/,/^# END ${u}$/d" "$WG_CFG"; chmod 600 "$WG_CFG"  # FIX
    wg syncconf wg0 <(wg-quick strip wg0) 2>/dev/null || systemctl restart wg-quick@wg0
    sed -i "/^${u}|/d" "$WG_DB"; del_maxlogin "$u"; rm -f "$WG_CLIENT_DIR/${u}.conf" 2>/dev/null
    ok "Peer WG ${W}${u}${NC} dihapus"; pause
}
wg_renew() { show_header; _top; _btn "  ${IT}${AL}🔁  PERPANJANG WG${NC}"; _bot; echo ""; [[ ! -s "$WG_DB" ]] && { warn "Belum ada peer."; pause; return; }; awk -F'|' '{printf "  %-15s  %-15s  %s\n",$1,$4,$5}' "$WG_DB"; echo ""; echo -ne "  ${A3}Username${NC}: "; read -r u; grep -q "^${u}|" "$WG_DB" || { err "Tidak ada!"; pause; return; }; echo -ne "  ${A3}Tambah hari${NC} [30]: "; read -r d; [[ ! "$d" =~ ^[0-9]+$ ]] && d=30; local cur new; cur=$(grep "^${u}|" "$WG_DB" | awk -F'|' '{print $5}'); new=$(TZ="Asia/Jakarta" date -d "${cur} +${d} days" +"%Y-%m-%d" 2>/dev/null || mk_exp "$d"); sed -i "s|^\(${u}|[^|]*|[^|]*|[^|]*|\)[^|]*|\1${new}|" "$WG_DB"; ok "→ ${Y}${new}${NC}"; pause; }
wg_list()  { show_header; _top; _btn "  ${IT}${AL}📋  LIST WG${NC}"; _bot; echo ""; [[ ! -s "$WG_DB" ]] && { warn "Belum ada."; pause; return; }; printf "  ${BLD}${A3}%-3s %-15s %-15s %-12s${NC}\n" "No" "User" "IP" "Expired"; _sep; local i=0; while IFS='|' read -r u _ _ ip e _; do i=$((i+1)); local col; is_expired "$e" && col="$LR" || { [[ "$(days_left "$e")" -le 3 ]] && col="$Y" || col="$LG"; }; printf "  %-3s ${W}%-15s${NC} ${A3}%-15s${NC} ${col}%-12s${NC}\n" "$i." "$u" "$ip" "$e"; done < "$WG_DB"; _sep; pause; }
wg_online(){ show_header; _top; _btn "  ${IT}${AL}🔍  WG ONLINE${NC}"; _bot; echo ""; command -v wg &>/dev/null || { warn "WG tidak terinstall."; pause; return; }; wg show wg0 2>/dev/null; pause; }



# ════════════════════════════════════════════════════════════
#  MAXLOGIN ENFORCER
# ════════════════════════════════════════════════════════════
check_maxlogin_all() {
    [[ ! -f "$MLDB" ]] && return
    while IFS='|' read -r uname maxdev; do
        [[ -z "$uname" || -z "$maxdev" ]] && continue
        local active; active=$(ps -eo user,cmd --no-headers 2>/dev/null \
            | awk -v u="$uname" '$2=="sshd:" && $3~("^" u "@") {c++} END{print c+0}')
        if [[ "$active" -gt "$maxdev" ]]; then
            local pids; mapfile -t pids < <(ps -eo pid,cmd --no-headers 2>/dev/null \
                | awk -v u="$uname" '$2=="sshd:" && $3~("^" u "@") {print $1}')
            local extra=$((active-maxdev)) i=0 pid
            for pid in "${pids[@]}"; do
                [[ "$i" -ge "$extra" ]] && break
                [[ "$pid" =~ ^[0-9]+$ ]] && kill -9 "$pid" 2>/dev/null && i=$((i+1))
            done
            _tg_send "🚫 <b>MaxLogin SSH</b>: <code>${uname}</code> melebihi ${maxdev}"
        fi
    done < "$MLDB"

    [[ -s "$XRAY_LOG" ]] && {
        local since; since=$(date -d '2 min ago' '+%Y/%m/%d %H:%M:%S' 2>/dev/null)
        declare -A xc user_ips
        while IFS= read -r line; do
            local email ip
            email=$(echo "$line" | grep -oE 'email: [^ ]+' | awk '{print $2}')
            ip=$(echo "$line" | grep -oE 'from [^ ]+' | awk '{print $2}' | cut -d: -f1)
            [[ -n "$email" && -n "$ip" ]] && xc["${email}|${ip}"]=1
        done < <(awk -v s="$since" '$0>=s' "$XRAY_LOG" 2>/dev/null)
        for key in "${!xc[@]}"; do
            local u="${key%%|*}"; user_ips[$u]=$(( ${user_ips[$u]:-0}+1 ))
        done
        for u in "${!user_ips[@]}"; do
            local cnt=${user_ips[$u]} ml; ml=$(get_maxlogin "$u"); [[ -z "$ml" ]] && continue
            if [[ "$cnt" -gt "$ml" ]]; then
                for db in "$VMESS_DB" "$VLESS_DB" "$TROJAN_DB" "$SS_DB"; do sed -i "/^${u}|/d" "$db" 2>/dev/null; done
                _xray_sync_clients; _tg_send "🚫 <b>MaxLogin Xray</b>: <code>${u}</code>"
            fi
        done
    }
}

# ════════════════════════════════════════════════════════════
#  CRON JOBS
# ════════════════════════════════════════════════════════════
install_cron_jobs() {
    inf "Setup cron jobs..."; mkdir -p /etc/cron.d /var/log/maxpanel
    cat > /etc/cron.d/maxpanel-expired  <<'C1'
5 0 * * * root /usr/local/bin/max-menu --clean-expired >> /var/log/maxpanel/expired.log 2>&1
C1
    cat > /etc/cron.d/maxpanel-maxlogin <<'C2'
* * * * * root /usr/local/bin/max-menu --check-maxlogin >> /var/log/maxpanel/maxlogin.log 2>&1
C2
    cat > /etc/cron.d/maxpanel-backup   <<'C3'
30 3 * * 0 root /usr/local/bin/max-menu --auto-backup >> /var/log/maxpanel/backup.log 2>&1
C3
    cat > /etc/cron.d/maxpanel-update   <<'C4'
17 4 * * * root /usr/local/bin/max-menu --check-update >> /var/log/maxpanel/update.log 2>&1
C4
    chmod 0644 /etc/cron.d/maxpanel-*
    systemctl restart cron 2>/dev/null || service cron restart 2>/dev/null
    ok "Cron jobs aktif"
}

# FIX: do_clean_expired_all — pakai tmpfile untuk semua DB
do_clean_expired_all() {
    local td count=0; td=$(TZ="Asia/Jakarta" date +%Y-%m-%d)
    for db in "$SSH_DB" "$OVPN_DB"; do
        [[ -s "$db" ]] || continue
        local tmp; tmp=$(mktemp)
        while IFS='|' read -r u p e ml; do
            if [[ -n "$e" && "$td" > "$e" ]]; then
                userdel -r "$u" 2>/dev/null; del_maxlogin "$u"; count=$((count+1))
                echo "[$(date)] expired: $u from $(basename "$db")"
            else echo "${u}|${p}|${e}|${ml}" >> "$tmp"; fi
        done < "$db"; mv "$tmp" "$db"
    done
    for db in "$VMESS_DB" "$VLESS_DB" "$TROJAN_DB" "$SS_DB" "$TROJANGO_DB" "$HY_DB"; do
        [[ -s "$db" ]] || continue
        local tmp; tmp=$(mktemp)
        while IFS='|' read -r u key e ml; do
            if [[ -n "$e" && "$td" > "$e" ]]; then
                del_maxlogin "$u"; count=$((count+1)); echo "[$(date)] expired: $u"
            else echo "${u}|${key}|${e}|${ml}" >> "$tmp"; fi
        done < "$db"; mv "$tmp" "$db"
    done
    [[ -s "$WG_DB" ]] && {
        local tmp; tmp=$(mktemp)
        while IFS='|' read -r u pub priv ip e ml; do
            if [[ -n "$e" && "$td" > "$e" ]]; then
                sed -i "/^# BEGIN ${u}$/,/^# END ${u}$/d" "$WG_CFG"; chmod 600 "$WG_CFG"
                del_maxlogin "$u"; rm -f "$WG_CLIENT_DIR/${u}.conf"; count=$((count+1))
            else echo "${u}|${pub}|${priv}|${ip}|${e}|${ml}" >> "$tmp"; fi
        done < "$WG_DB"; mv "$tmp" "$WG_DB"
        wg syncconf wg0 <(wg-quick strip wg0) 2>/dev/null || true
    }
    _xray_sync_clients 2>/dev/null; _trojango_sync 2>/dev/null; _hy_sync 2>/dev/null
    echo "[$(date)] Total expired: $count"
}

# ════════════════════════════════════════════════════════════
#  SYSTEM TOOLS
# ════════════════════════════════════════════════════════════
tool_bbr() {
    show_header; _top; _btn "  ${IT}${AL}🚀  BBR Toggle${NC}"; _bot; echo ""
    echo -e "  Congestion: ${W}$(sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null)${NC}  Qdisc: ${W}$(sysctl -n net.core.default_qdisc 2>/dev/null)${NC}\n"
    echo -e "  ${A2}[1]${NC} Aktifkan BBR+FQ  ${A2}[2]${NC} Kembali ke cubic  ${LR}[0]${NC} Batal"; echo ""
    echo -ne "  ${A1}›${NC} "; read -r ch
    case $ch in 1) enable_bbr_silent; ok "BBR+FQ aktif" ;; 2) sysctl -w net.ipv4.tcp_congestion_control=cubic &>/dev/null; ok "Kembali cubic" ;; esac; pause
}
tool_ipv6() {
    show_header; _top; _btn "  ${IT}${AL}🛑  IPv6 Toggle${NC}"; _bot; echo ""
    local cur; cur=$(sysctl -n net.ipv6.conf.all.disable_ipv6 2>/dev/null || echo 0)
    [[ "$cur" == "1" ]] && echo -e "  IPv6: ${LR}DISABLED${NC}" || echo -e "  IPv6: ${LG}ENABLED${NC}"; echo ""
    echo -e "  ${A2}[1]${NC} Disable  ${A2}[2]${NC} Enable  ${LR}[0]${NC} Batal"; echo ""
    echo -ne "  ${A1}›${NC} "; read -r ch
    case $ch in
        1) _apply_block "IPV6-DISABLE" /etc/sysctl.conf <<'V6'
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
V6
           sysctl -p &>/dev/null; ok "IPv6 disabled" ;;
        2) sed -i '/^# >>> MAXPANEL-IPV6-DISABLE >>>$/,/^# <<< MAXPANEL-IPV6-DISABLE <<<$/d' /etc/sysctl.conf 2>/dev/null
           sed -i '/disable_ipv6/d' /etc/sysctl.conf; sysctl -w net.ipv6.conf.all.disable_ipv6=0 &>/dev/null; ok "IPv6 enabled" ;;
    esac; pause
}
tool_speedtest() { show_header; _top; _btn "  ${IT}${AL}🚀  SPEEDTEST${NC}"; _bot; echo ""; command -v speedtest-cli &>/dev/null || apt-get install -y -qq speedtest-cli &>/dev/null; command -v speedtest-cli &>/dev/null && speedtest-cli --simple || err "speedtest-cli tidak tersedia"; pause; }
tool_sysinfo() {
    show_header; _top; _btn "  ${IT}${AL}ℹ️   SYSTEM INFO${NC}"; _bot; echo ""
    local hn ip os krn up ram_t ram_u cpu cpus disk_t disk_u isp
    hn=$(hostname); ip=$(get_ip); os=$(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME"); krn=$(uname -r)
    up=$(uptime -p 2>/dev/null); ram_t=$(free -h | awk '/^Mem/{print $2}'); ram_u=$(free -h | awk '/^Mem/{print $3}')
    cpus=$(nproc 2>/dev/null); cpu=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | sed 's/^ //')
    disk_t=$(df -h / | awk 'NR==2{print $2}'); disk_u=$(df -h / | awk 'NR==2{print $3}')
    isp=$(curl -s --max-time 5 https://ipinfo.io/org 2>/dev/null || echo "N/A")
    echo -e "  ${DIM}Hostname :${NC} ${W}${hn}${NC}\n  ${DIM}OS       :${NC} ${W}${os}${NC}\n  ${DIM}Kernel   :${NC} ${W}${krn}${NC}"
    echo -e "  ${DIM}Uptime   :${NC} ${W}${up}${NC}\n  ${DIM}CPU      :${NC} ${W}${cpu} (${cpus} cores)${NC}"
    echo -e "  ${DIM}RAM      :${NC} ${A3}${ram_u}/${ram_t}${NC}\n  ${DIM}Disk /   :${NC} ${A3}${disk_u}/${disk_t}${NC}"
    echo -e "  ${DIM}IP Publik:${NC} ${LG}${ip}${NC}\n  ${DIM}ISP/Org  :${NC} ${Y}${isp}${NC}"; pause
}
tool_reboot_sched() {
    show_header; _top; _btn "  ${IT}${AL}♻️   AUTO-REBOOT${NC}"; _bot; echo ""
    [[ -f /etc/cron.d/maxpanel-reboot ]] && echo -e "  Schedule: ${A3}$(awk '!/^#/{print $1,$2;exit}' /etc/cron.d/maxpanel-reboot)${NC}" || echo -e "  ${LR}Belum di-set${NC}"; echo ""
    echo -e "  ${A2}[1]${NC} Set jadwal  ${A2}[2]${NC} Hapus jadwal  ${LR}[0]${NC} Batal"; echo ""
    echo -ne "  ${A1}›${NC} "; read -r ch
    case $ch in
        1) echo -ne "  Jam (0-23) [4]: "; read -r h; [[ ! "$h" =~ ^[0-9]+$ ]] && h=4
           echo "0 ${h} * * * root /sbin/reboot" > /etc/cron.d/maxpanel-reboot; ok "Set jam ${h}:00" ;;
        2) rm -f /etc/cron.d/maxpanel-reboot; ok "Jadwal dihapus" ;;
    esac; pause
}
tool_bandwidth() { show_header; _top; _btn "  ${IT}${AL}📊  BANDWIDTH${NC}"; _bot; echo ""; command -v vnstat &>/dev/null || apt-get install -y -qq vnstat &>/dev/null; vnstat; pause; }

# FIX: tool_restart_all — pakai ws-ssh-proxy (bukan ws-max-8880)
tool_restart_all() {
    show_header; _top; _btn "  ${IT}${AL}🔄  RESTART SEMUA SERVICE${NC}"; _bot; echo ""
    local svcs=(ssh sshd dropbear stunnel4 xray trojan-go hysteria-server \
                openvpn-server@tcp openvpn-server@udp wg-quick@wg0 nginx \
                ws-ssh-proxy)
    for s in "${svcs[@]}"; do
        if systemctl list-unit-files 2>/dev/null | grep -q "^${s}"; then
            systemctl restart "$s" 2>/dev/null && ok "$s" || warn "$s gagal"
        fi
    done; pause
}

# FIX: tool_check_service — pakai ws-ssh-proxy, tambah nginx di list
tool_check_service() {
    show_header; _top; _btn "  ${IT}${AL}🔍  STATUS SERVICE${NC}"; _bot; echo ""
    local svcs=(ssh dropbear stunnel4 nginx ws-ssh-proxy xray trojan-go \
                hysteria-server openvpn-server@tcp openvpn-server@udp \
                wg-quick@wg0 cron)
    printf "  ${BLD}${A3}%-28s %s${NC}\n" "SERVICE" "STATUS"; _sep
    for s in "${svcs[@]}"; do
        local stat
        if is_up "$s"; then stat="${LG}● running${NC}"
        elif systemctl list-unit-files 2>/dev/null | grep -q "^${s}"; then stat="${LR}● stopped${NC}"
        else stat="${DIM}— not installed${NC}"; fi
        printf "  %-28s %b\n" "$s" "$stat"
    done; _sep; pause
}

tool_cleaner() {
    show_header; _top; _btn "  ${IT}${AL}🧽  CLEANER${NC}"; _bot; echo ""
    journalctl --vacuum-time=3d &>/dev/null
    find /var/log -type f \( -name '*.log' -mtime +7 -o -name '*.gz' \) -delete 2>/dev/null
    find /tmp -mindepth 1 -mtime +3 -delete 2>/dev/null
    apt-get clean -qq &>/dev/null; ok "Cleaner selesai."; pause
}

tool_set_banner() {
    show_header; _top; _btn "  ${IT}${AL}🎨  BANNER MOTD${NC}"; _bot; echo ""
    echo -e "  ${A2}[1]${NC} Edit /etc/issue.net  ${A2}[2]${NC} Generate figlet  ${A2}[3]${NC} Reset  ${LR}[0]${NC} Batal"; echo ""
    echo -ne "  ${A1}›${NC} "; read -r ch
    case $ch in
        1) ${EDITOR:-nano} /etc/issue.net ;;
        2) echo -ne "  Teks [MAX PANEL]: "; read -r t; [[ -z "$t" ]] && t="MAX PANEL"
           command -v figlet &>/dev/null && figlet -f standard "$t" > /etc/issue.net || echo "$t" > /etc/issue.net
           ok "Banner di-generate" ;;
        3) echo "Welcome to MAX PANEL VPS" > /etc/issue.net; ok "Reset" ;;
    esac; pause
}

tool_set_limit() {
    show_header; _top; _btn "  ${IT}${AL}🚦  LIMIT TOTAL USER${NC}"; _bot; echo ""
    echo -e "  Limit: ${W}$(cat "$LIMITF" 2>/dev/null || echo unlimited)${NC}  User aktif: ${A3}$(total_users_all)${NC}\n"
    echo -ne "  Limit baru (0=unlimited): "; read -r v
    [[ ! "$v" =~ ^[0-9]+$ ]] && { err "Bukan angka"; pause; return; }
    [[ "$v" == "0" ]] && { rm -f "$LIMITF"; ok "Unlimited"; } || { echo "$v" > "$LIMITF"; ok "Limit: ${W}${v}${NC}"; }
    pause
}

# ════════════════════════════════════════════════════════════
#  BACKUP & RESTORE
# ════════════════════════════════════════════════════════════
do_backup() {
    show_header; _top; _btn "  ${IT}${AL}💾  BACKUP${NC}"; _bot; echo ""
    mkdir -p "$BACKUPDIR"
    local out="$BACKUPDIR/max-backup-$(date +%Y-%m-%d_%H%M%S).tar.gz"
    local files=(); for f in "$DIR" /etc/xray /etc/trojan-go /etc/hysteria /etc/wireguard /etc/openvpn /etc/stunnel /etc/ssh/sshd_config /etc/nginx/conf.d; do [[ -e "$f" ]] && files+=("$f"); done
    tar -czPf "$out" "${files[@]}" 2>/dev/null && ok "Backup: ${W}$(basename "$out")${NC} ($(du -sh "$out" | cut -f1))" || err "Backup gagal!"
    _tg_send "💾 <b>Backup</b>: <code>$(basename "$out")</code>"; pause
}

do_restore() {
    show_header; _top; _btn "  ${IT}${AL}♻️   RESTORE${NC}"; _bot; echo ""
    [[ -z "$(ls -A "$BACKUPDIR" 2>/dev/null)" ]] && { warn "Belum ada backup."; pause; return; }
    local files=() i=1
    while IFS= read -r f; do files+=("$f"); printf "  ${A2}[%d]${NC} %s ($(du -sh "$f" | cut -f1))\n" "$i" "$(basename "$f")"; i=$((i+1)); done \
        < <(ls -1t "$BACKUPDIR"/*.tar.gz 2>/dev/null)
    echo ""; echo -ne "  Nomor backup: "; read -r n
    [[ ! "$n" =~ ^[0-9]+$ || $n -lt 1 || $n -gt ${#files[@]} ]] && { err "Nomor tidak valid"; pause; return; }
    warn "Restore akan menimpa konfigurasi saat ini!"; echo -ne "  Ketik ${LR}YES${NC} untuk konfirmasi: "; read -r cf
    [[ "$cf" != "YES" ]] && { inf "Dibatalkan."; pause; return; }
    tar -xzPf "${files[$((n-1))]}" -C / && ok "Restore selesai" || err "Restore gagal!"
    systemctl daemon-reload; pause
}

# ════════════════════════════════════════════════════════════
#  UPDATE
# ════════════════════════════════════════════════════════════
cek_update() {
    show_header; _top; _btn "  ${IT}${AL}🔄  CEK UPDATE${NC}"; _bot; echo ""
    printf "  Versi sekarang: ${W}%s${NC}\n" "$SCRIPT_VERSION"
    local remote; remote=$(curl -s --max-time 15 "$VERSION_URL" 2>/dev/null | tr -d '[:space:]')
    [[ -z "$remote" ]] && remote=$(wget -qO- --timeout=15 "$VERSION_URL" 2>/dev/null | tr -d '[:space:]')
    [[ -z "$remote" ]] && { err "Gagal cek versi remote."; pause; return; }
    printf "  Versi remote  : ${LG}%s${NC}\n\n" "$remote"
    if [[ "$remote" == "$SCRIPT_VERSION" ]]; then ok "Sudah versi terbaru."; pause; return; fi
    echo -e "  ${A4}⚡ Update: ${Y}${SCRIPT_VERSION}${NC} → ${LG}${remote}${NC}"
    echo -ne "  Update sekarang? [y/N]: "; read -r y
    [[ "${y,,}" != "y" ]] && { inf "Dibatalkan"; pause; return; }
    local tmp; tmp=$(mktemp /tmp/max-update-XXXXXX.sh)
    if dl "$SCRIPT_URL" "$tmp" && bash -n "$tmp"; then
        install -m755 "$tmp" /usr/local/bin/max-menu
        ln -sf /usr/local/bin/max-menu /usr/local/bin/menu-max
        ok "Update sukses!"; rm -f "$tmp"; pause; exec bash /usr/local/bin/max-menu
    else err "Download/validasi gagal"; rm -f "$tmp"; pause; fi
}

check_update_silent() {
    local remote; remote=$(curl -s --max-time 10 "$VERSION_URL" 2>/dev/null | tr -d '[:space:]')
    [[ -n "$remote" && "$remote" != "$SCRIPT_VERSION" ]] && \
        _tg_send "🔔 <b>Update Available</b>: <code>${SCRIPT_VERSION}</code> → <code>${remote}</code>"
}

# ════════════════════════════════════════════════════════════
#  DOMAIN + SSL
# ════════════════════════════════════════════════════════════
domain_set() {
    show_header; _top; _btn "  ${IT}${AL}🌐  SET DOMAIN${NC}"; _bot; echo ""
    local cur ip; cur=$(get_domain); ip=$(get_ip)
    echo -e "  Domain saat ini: ${W}${cur}${NC}  IP: ${A3}${ip}${NC}\n  ${DIM}Pastikan A-record → ${ip}${NC}\n"
    echo -ne "  Domain baru (kosong = pakai IP): "; read -r d
    if [[ -z "$d" ]]; then echo "$ip" > "$DOMF"; ok "Set ke IP publik"
    else echo "$d" > "$DOMF"; ok "Domain: ${W}${d}${NC}"
         echo -ne "  Issue SSL sekarang? [y/N]: "; read -r y; [[ "${y,,}" == "y" ]] && domain_issue_ssl; fi
    pause
}

domain_issue_ssl() {
    show_header; _top; _btn "  ${IT}${AL}🔐  ISSUE SSL${NC}"; _bot; echo ""
    local dom; dom=$(get_domain)
    [[ "$dom" =~ ^[0-9.]+$ ]] && { err "Domain belum di-set"; pause; return; }
    setup_acme_ssl "$dom"; pause
}

# ════════════════════════════════════════════════════════════
#  TELEGRAM BOT
# ════════════════════════════════════════════════════════════
tg_setup() {
    show_header; _top; _btn "  ${IT}${AL}🤖  SETUP TELEGRAM BOT${NC}"; _bot; echo ""
    [[ -f "$BOTF" ]] && { source "$BOTF" 2>/dev/null; echo -e "  Bot: ${LG}@${BOT_NAME:-?}${NC}  ChatID: ${W}${CHAT_ID:-?}${NC}\n"; }
    echo -ne "  Bot Token: "; read -r tok; [[ -z "$tok" ]] && { warn "Dibatalkan"; pause; return; }
    echo -ne "  Chat ID  : "; read -r cid; [[ -z "$cid" ]] && { warn "Dibatalkan"; pause; return; }
    local name; name=$(curl -s --max-time 10 "https://api.telegram.org/bot${tok}/getMe" | grep -oE '"username":"[^"]*"' | head -1 | cut -d\" -f4)
    [[ -z "$name" ]] && { err "Bot token tidak valid!"; pause; return; }
    printf "BOT_TOKEN=%q\nCHAT_ID=%q\nBOT_NAME=%q\n" "$tok" "$cid" "$name" > "$BOTF"; chmod 600 "$BOTF"
    ok "Bot @${name} tersimpan"
    curl -s "https://api.telegram.org/bot${tok}/sendMessage" -d "chat_id=${cid}" -d "text=✅ MAX PANEL terhubung!" &>/dev/null; pause
}

tg_test() {
    show_header; _top; _btn "  ${IT}${AL}📡  TES BOT${NC}"; _bot; echo ""
    [[ ! -f "$BOTF" ]] && { warn "Bot belum di-setup"; pause; return; }
    _tg_send "🟢 Tes MAX PANEL — $(date '+%d/%m/%Y %H:%M:%S')"; ok "Tes terkirim."; pause
}

store_setup() {
    show_header; _top; _btn "  ${IT}${AL}🛒  SET BRAND${NC}"; _bot; echo ""
    [[ -f "$STRF" ]] && { source "$STRF" 2>/dev/null; echo -e "  Brand: ${AL}${BRAND:-MAX PANEL}${NC}  TG: ${W}${ADMIN_TG:--}${NC}\n"; }
    echo -ne "  Nama Brand [MAX PANEL]: "; read -r b; [[ -z "$b" ]] && b="MAX PANEL"
    echo -ne "  Admin Telegram        : "; read -r tg; [[ -z "$tg" ]] && tg="-"
    echo -ne "  Admin WhatsApp        : "; read -r wa; [[ -z "$wa" ]] && wa="-"
    printf "BRAND=%q\nADMIN_TG=%q\nADMIN_WA=%q\n" "$b" "$tg" "$wa" > "$STRF"
    ok "Brand tersimpan: ${AL}${b}${NC}"; pause
}

# ════════════════════════════════════════════════════════════
#  MENU TEMA
# ════════════════════════════════════════════════════════════
menu_tema() {
    while true; do
        clear; load_theme; local cur; cur=$(cat "$THEMEF" 2>/dev/null || echo 1)
        echo ""; echo -e "  ${A1}${_DASH}${NC}"; echo -e "  ${IT}${AL}  🎨  PILIH TEMA — 15 Premium${NC}"; echo -e "  ${A1}${_DASH}${NC}"; echo ""
        _tr() {
            local n="$1" i="$2" name="$3" c1="$4" c2="$5" c3="$6"
            local m="  "; [[ "$cur" == "$n" ]] && m="\033[1;32m▶\033[0m "
            printf "  %b%s  \033[2m[%2s]\033[0m  %b%-16s\033[0m  %b██\033[0m%b██\033[0m%b██\033[0m\n" "$m" "$i" "$n" "$c1" "$name" "$c1" "$c2" "$c3"
        }
        _tr  1 "💜" "VIOLET"        '\033[38;5;135m' '\033[38;5;141m' '\033[1;35m'
        _tr  2 "🩵" "ARCTIC CYAN"   '\033[38;5;51m'  '\033[38;5;87m'  '\033[1;36m'
        _tr  3 "💚" "MATRIX GREEN"  '\033[38;5;46m'  '\033[38;5;82m'  '\033[38;5;40m'
        _tr  4 "💛" "ROYAL GOLD"    '\033[38;5;220m' '\033[38;5;226m' '\033[38;5;214m'
        _tr  5 "❤️ " "CRIMSON RED"   '\033[38;5;196m' '\033[38;5;203m' '\033[38;5;204m'
        _tr  6 "🩷" "SAKURA PINK"   '\033[38;5;213m' '\033[38;5;219m' '\033[38;5;218m'
        _tr  7 "🌈" "RAINBOW"       '\033[38;5;196m' '\033[38;5;82m'  '\033[38;5;51m'
        _tr  8 "🌊" "OCEAN BLUE"    '\033[38;5;27m'  '\033[38;5;33m'  '\033[38;5;45m'
        _tr  9 "🌅" "SUNSET ORANGE" '\033[38;5;202m' '\033[38;5;208m' '\033[38;5;214m'
        _tr 10 "🌑" "MIDNIGHT"      '\033[38;5;239m' '\033[38;5;245m' '\033[38;5;153m'
        _tr 11 "💎" "EMERALD"       '\033[38;5;35m'  '\033[38;5;41m'  '\033[38;5;85m'
        _tr 12 "🫧" "LAVENDER"      '\033[38;5;99m'  '\033[38;5;105m' '\033[38;5;183m'
        _tr 13 "🌸" "ROSE GOLD"     '\033[38;5;210m' '\033[38;5;216m' '\033[38;5;222m'
        _tr 14 "🧊" "ICE WHITE"     '\033[38;5;195m' '\033[38;5;231m' '\033[38;5;159m'
        _tr 15 "⚡" "NEON PURPLE"   '\033[38;5;129m' '\033[38;5;135m' '\033[38;5;201m'
        echo ""; echo -e "  ${A1}${_DASH}${NC}"; echo -e "  Tema aktif: ${AL}${THEME_NAME}${NC}"; echo -e "  ${LR}[0]${NC} Kembali"; echo ""
        echo -ne "  ${A1}›${NC} [0-15]: "; read -r ch
        case $ch in
            [1-9]|1[0-5]) echo "$ch" > "$THEMEF"; load_theme; ok "Tema ${AT}${THEME_NAME}${NC} aktif!"; sleep 0.8 ;;
            0) break ;;
            *) warn "Pilihan tidak valid"; sleep 0.5 ;;
        esac
    done
}

# ════════════════════════════════════════════════════════════
#  MENUS
# ════════════════════════════════════════════════════════════
menu_ssh()      { while true; do show_header; _top; _btn "  ${IT}${AL}🛡   SSH / OPENSSH / DROPBEAR / STUNNEL${NC}"; _sep; _btn "  ${A2}[1]${NC} ➕ Buat Akun  ${A2}[2]${NC} 🎁 Trial"; _sep; _btn "  ${A2}[3]${NC} 🗑  Hapus  ${A2}[4]${NC} 🔁 Perpanjang  ${A2}[5]${NC} 📋 List"; _sep; _btn "  ${A2}[6]${NC} 🔍 Online  ${A2}[7]${NC} 🧹 Hapus Expired  ${LR}[0]${NC} ◀ Kembali"; _bot; echo ""; echo -ne "  ${A1}›${NC} "; read -r ch; case $ch in 1) ssh_add;; 2) ssh_trial;; 3) ssh_del;; 4) ssh_renew;; 5) ssh_list;; 6) ssh_online;; 7) ssh_clean_expired;; 0) break;; *) warn "Tidak valid"; sleep 1;; esac; done; }
menu_openvpn()  { while true; do show_header; _top; _btn "  ${IT}${AL}🛡   OPENVPN — TCP 1194 + UDP 2200${NC}"; _sep; _btn "  ${A2}[1]${NC} ➕ Buat  ${A2}[2]${NC} 🎁 Trial  ${A2}[3]${NC} 🗑  Hapus  ${A2}[4]${NC} 🔁 Perpanjang"; _sep; _btn "  ${A2}[5]${NC} 📋 List  ${A2}[6]${NC} 🔍 Online  ${LR}[0]${NC} ◀ Kembali"; _bot; echo ""; echo -ne "  ${A1}›${NC} "; read -r ch; case $ch in 1) ovpn_add;; 2) ovpn_trial;; 3) ovpn_del;; 4) ovpn_renew;; 5) ovpn_list;; 6) ovpn_online;; 0) break;; *) warn "Tidak valid"; sleep 1;; esac; done; }
menu_trojan_go(){ while true; do show_header; _top; _btn "  ${IT}${AL}⚡  TROJAN-GO — port 2087${NC}"; _sep; _btn "  ${A2}[1]${NC} ➕ Buat  ${A2}[2]${NC} 🎁 Trial  ${A2}[3]${NC} 🗑  Hapus  ${A2}[4]${NC} 🔁 Perpanjang  ${A2}[5]${NC} 📋 List  ${LR}[0]${NC} ◀"; _bot; echo ""; echo -ne "  ${A1}›${NC} "; read -r ch; case $ch in 1) tgo_add;; 2) tgo_trial;; 3) tgo_del;; 4) tgo_renew;; 5) tgo_list;; 0) break;; *) warn "Tidak valid"; sleep 1;; esac; done; }
menu_wireguard(){ while true; do show_header; _top; _btn "  ${IT}${AL}🌐  WIREGUARD — UDP 51820${NC}"; _sep; _btn "  ${A2}[1]${NC} ➕ Tambah  ${A2}[2]${NC} 🗑  Hapus  ${A2}[3]${NC} 🔁 Perpanjang  ${A2}[4]${NC} 📋 List  ${A2}[5]${NC} 🔍 Online  ${LR}[0]${NC} ◀"; _bot; echo ""; echo -ne "  ${A1}›${NC} "; read -r ch; case $ch in 1) wg_add;; 2) wg_del;; 3) wg_renew;; 4) wg_list;; 5) wg_online;; 0) break;; *) warn "Tidak valid"; sleep 1;; esac; done; }
menu_hysteria() { while true; do show_header; _top; _btn "  ${IT}${AL}⚡  HYSTERIA 2 — UDP 36712${NC}"; _sep; _btn "  ${A2}[1]${NC} ➕ Buat  ${A2}[2]${NC} 🎁 Trial  ${A2}[3]${NC} 🗑  Hapus  ${A2}[4]${NC} 🔁 Perpanjang  ${A2}[5]${NC} 📋 List  ${LR}[0]${NC} ◀"; _bot; echo ""; echo -ne "  ${A1}›${NC} "; read -r ch; case $ch in 1) hy_add;; 2) hy_trial;; 3) hy_del;; 4) hy_renew;; 5) hy_list;; 0) break;; *) warn "Tidak valid"; sleep 1;; esac; done; }


menu_vmess()    { while true; do show_header; _top; _btn "  ${IT}${AL}🟣  VMESS — /vmess via Nginx 80/443${NC}"; _sep; _btn "  ${A2}[1]${NC} ➕ Buat  ${A2}[2]${NC} 🎁 Trial  ${A2}[3]${NC} 🗑  Hapus  ${A2}[4]${NC} 🔁 Perpanjang  ${A2}[5]${NC} 📋 List  ${LR}[0]${NC} ◀"; _bot; echo ""; echo -ne "  ${A1}›${NC} "; read -r ch; case $ch in 1) vmess_add;; 2) vmess_trial;; 3) vmess_del;; 4) vmess_renew;; 5) vmess_list;; 0) break;; *) warn "Tidak valid"; sleep 1;; esac; done; }
menu_vless()    { while true; do show_header; _top; _btn "  ${IT}${AL}🔵  VLESS — /vless via Nginx + gRPC${NC}"; _sep; _btn "  ${A2}[1]${NC} ➕ Buat  ${A2}[2]${NC} 🎁 Trial  ${A2}[3]${NC} 🗑  Hapus  ${A2}[4]${NC} 🔁 Perpanjang  ${A2}[5]${NC} 📋 List  ${LR}[0]${NC} ◀"; _bot; echo ""; echo -ne "  ${A1}›${NC} "; read -r ch; case $ch in 1) vless_add;; 2) vless_trial;; 3) vless_del;; 4) vless_renew;; 5) vless_list;; 0) break;; *) warn "Tidak valid"; sleep 1;; esac; done; }
menu_trojan()   { while true; do show_header; _top; _btn "  ${IT}${AL}🔴  TROJAN — /trojan-ws via Nginx + gRPC${NC}"; _sep; _btn "  ${A2}[1]${NC} ➕ Buat  ${A2}[2]${NC} 🎁 Trial  ${A2}[3]${NC} 🗑  Hapus  ${A2}[4]${NC} 🔁 Perpanjang  ${A2}[5]${NC} 📋 List  ${LR}[0]${NC} ◀"; _bot; echo ""; echo -ne "  ${A1}›${NC} "; read -r ch; case $ch in 1) trojan_add;; 2) trojan_trial;; 3) trojan_del;; 4) trojan_renew;; 5) trojan_list;; 0) break;; *) warn "Tidak valid"; sleep 1;; esac; done; }
menu_ss()       { while true; do show_header; _top; _btn "  ${IT}${AL}🟢  SHADOWSOCKS — port 8388${NC}"; _sep; _btn "  ${A2}[1]${NC} ➕ Buat  ${A2}[2]${NC} 🗑  Hapus  ${A2}[3]${NC} 📋 List  ${LR}[0]${NC} ◀"; _bot; echo ""; echo -ne "  ${A1}›${NC} "; read -r ch; case $ch in 1) ss_add;; 2) ss_del;; 3) ss_list;; 0) break;; *) warn "Tidak valid"; sleep 1;; esac; done; }

menu_xray() {
    while true; do
        show_header; _top; _btn "  ${IT}${AL}🛡   XRAY-CORE — VMess / VLess / Trojan / SS${NC}"
        _sep; _btn "  ${A2}[1]${NC} 🟣 VMess  ${A2}[2]${NC} 🔵 VLess  ${A2}[3]${NC} 🔴 Trojan  ${A2}[4]${NC} 🟢 Shadowsocks"
        _sep; _btn "  ${A2}[5]${NC} 🔍 Online  ${A2}[6]${NC} 🧹 Hapus Expired  ${A2}[7]${NC} 🔄 Sync Config  ${LR}[0]${NC} ◀"
        _bot; echo ""; echo -ne "  ${A1}›${NC} "; read -r ch
        case $ch in 1) menu_vmess;; 2) menu_vless;; 3) menu_trojan;; 4) menu_ss;; 5) xray_online;; 6) xray_clean_expired;; 7) _xray_sync_clients; ok "Synced"; sleep 1;; 0) break;; *) warn "Tidak valid"; sleep 1;; esac
    done
}

menu_system() {
    while true; do
        show_header; _top; _btn "  ${IT}${AL}⚙️   SYSTEM TOOLS${NC}"
        _sep; _btn "  ${A2}[1]${NC} 🚀 BBR  ${A2}[2]${NC} 🛑 IPv6  ${A2}[3]${NC} 📡 Speedtest  ${A2}[4]${NC} ℹ️  Info"
        _sep; _btn "  ${A2}[5]${NC} ♻️  Reboot  ${A2}[6]${NC} 📊 Bandwidth  ${A2}[7]${NC} 🔄 Restart All  ${A2}[8]${NC} 🔍 Status"
        _sep; _btn "  ${A2}[9]${NC} 🧽 Cleaner  ${A2}[A]${NC} 🎨 Banner  ${A2}[B]${NC} 🚦 Limit User  ${LR}[0]${NC} ◀"
        _bot; echo ""; echo -ne "  ${A1}›${NC} "; read -r ch
        case ${ch,,} in 1) tool_bbr;; 2) tool_ipv6;; 3) tool_speedtest;; 4) tool_sysinfo;; 5) tool_reboot_sched;; 6) tool_bandwidth;; 7) tool_restart_all;; 8) tool_check_service;; 9) tool_cleaner;; a) tool_set_banner;; b) tool_set_limit;; 0) break;; *) warn "Tidak valid"; sleep 1;; esac
    done
}

menu_backup() {
    while true; do
        show_header; _top; _btn "  ${IT}${AL}💾  BACKUP & RESTORE${NC}"
        _sep; _btn "  ${A2}[1]${NC} 💾 Backup  ${A2}[2]${NC} ♻️  Restore  ${A2}[3]${NC} 📋 List Backup  ${A2}[4]${NC} 🗑  Hapus Lama  ${LR}[0]${NC} ◀"
        _bot; echo ""; echo -ne "  ${A1}›${NC} "; read -r ch
        case $ch in
            1) do_backup;; 2) do_restore;;
            3) show_header; _top; _btn "  ${IT}${AL}📋  LIST BACKUP${NC}"; _bot; ls -lh "$BACKUPDIR" 2>/dev/null | awk 'NR>1{printf "  %s  %s\n",$9,$5}' || warn "Belum ada"; pause;;
            4) find "$BACKUPDIR" -name 'max-backup-*.tar.gz' -mtime +30 -delete -print 2>/dev/null; ok "Backup > 30 hari dihapus"; pause;;
            0) break;; *) warn "Tidak valid"; sleep 1;;
        esac
    done
}

menu_settings() {
    while true; do
        show_header; _top; _btn "  ${IT}${AL}⚙️   PENGATURAN PANEL${NC}"
        _sep; _btn "  ${A2}[1]${NC} 🌐 Set Domain  ${A2}[2]${NC} 🔐 Issue SSL  ${A2}[3]${NC} 🤖 Bot Telegram"
        _sep; _btn "  ${A2}[4]${NC} 📡 Tes Bot  ${A2}[5]${NC} 🛒 Set Brand  ${A2}[6]${NC} 🎨 Banner  ${LR}[0]${NC} ◀"
        _bot; echo ""; echo -ne "  ${A1}›${NC} "; read -r ch
        case $ch in 1) domain_set;; 2) domain_issue_ssl;; 3) tg_setup;; 4) tg_test;; 5) store_setup;; 6) tool_set_banner;; 0) break;; *) warn "Tidak valid"; sleep 1;; esac
    done
}

menu_about() {
    show_header; _top; _btn "  ${IT}${AL}ℹ️   TENTANG MAX PANEL${NC}"; _bot; echo ""
    cat <<'ABOUT'
  MAX PANEL — Premium VPS Tunneling v1.9-fixed
  Repo: https://github.com/chanelog/max

  Protokol: SSH 22 | Dropbear 109,143 | Stunnel 445,777
  Nginx: 80/443/8443 (WS-SSH + Xray proxy)
  WS-SSH: ws://<domain>/ws-ssh → SSH:22
  Xray: vmess/vless/trojan via Nginx | SS:8388
  Trojan-Go: 2087 | Hysteria2: UDP 36712
  OpenVPN: TCP 1194 + UDP 2200
  WireGuard: UDP 51820

  Ketik: menu-max
ABOUT
    echo ""; pause
}

# ════════════════════════════════════════════════════════════
#  UNINSTALL
# ════════════════════════════════════════════════════════════
do_uninstall() {
    show_header; _top; _btn "  ${IT}${LR}🗑   UNINSTALL MAX PANEL${NC}"; _bot; echo ""
    warn "Aksi ini menghapus SEMUA data MAX PANEL!"; echo ""
    echo -ne "  Ketik ${LR}UNINSTALL${NC} untuk konfirmasi: "; read -r cf
    [[ "$cf" != "UNINSTALL" ]] && { inf "Dibatalkan"; pause; return; }
    for s in xray trojan-go hysteria-server wg-quick@wg0 stunnel4 dropbear \
             openvpn-server@tcp openvpn-server@udp ws-ssh-proxy nginx; do
        systemctl stop "$s" 2>/dev/null; systemctl disable "$s" 2>/dev/null
    done
    rm -rf /etc/xray /etc/trojan-go /etc/hysteria "$WS_DIR"
    rm -f "$XRAY_BIN" "$TROJANGO_BIN" "$HY_BIN"
    rm -f /etc/systemd/system/xray.service /etc/systemd/system/trojan-go.service \
          /etc/systemd/system/hysteria-server.service \
          /etc/systemd/system/ws-ssh-proxy.service /etc/cron.d/maxpanel-*
    rm -f /usr/local/bin/menu-max /usr/local/bin/max-menu
    sed -i '/# MAX-PANEL-SPLASH/d;/max-panel-splash/d;/alias menu-max=/d;/alias max-menu=/d' /root/.bashrc 2>/dev/null
    for db in "$SSH_DB" "$OVPN_DB"; do
        [[ -s "$db" ]] && while IFS='|' read -r u _ _ _; do userdel -r "$u" 2>/dev/null; done < "$db"
    done
    rm -rf "$DIR" "$LOGDIR"
    systemctl daemon-reload
    ok "MAX PANEL berhasil di-uninstall."; pause; exit 0
}

# ════════════════════════════════════════════════════════════
#  SETUP COMMAND & SPLASH
# ════════════════════════════════════════════════════════════
setup_menu_cmd() {
    cp "$0" /usr/local/bin/max-menu 2>/dev/null; chmod +x /usr/local/bin/max-menu 2>/dev/null
    ln -sf /usr/local/bin/max-menu /usr/local/bin/menu-max 2>/dev/null
    sed -i '/alias menu-max=/d;/alias max-menu=/d' ~/.bashrc 2>/dev/null
    echo "alias menu-max='bash /usr/local/bin/max-menu'" >> ~/.bashrc
    echo "alias max-menu='bash /usr/local/bin/max-menu'"  >> ~/.bashrc
    cat > /etc/profile.d/max-panel.sh <<'P'
alias menu-max='bash /usr/local/bin/max-menu'
alias max-menu='bash /usr/local/bin/max-menu'
P
    chmod +x /etc/profile.d/max-panel.sh 2>/dev/null
}

install_ssh_splash() {
    cat > /etc/max-panel-splash.sh <<'SPLASH'
#!/bin/bash
THEMEF="/etc/maxpanel/theme.conf"
NC='\033[0m'; BLD='\033[1m'; DIM='\033[2m'
cur=$(cat "$THEMEF" 2>/dev/null || echo 1)
[[ "$cur" == "7" ]] && L1='\033[38;5;196m' || L1='\033[38;5;135m'
DASH="───────────────────────────────────────────────────────────────"
clear; echo ""
echo -e "  ${L1}${DASH}${NC}"
echo -e "  ${L1}${BLD}  ███╗   ███╗  █████╗  ██╗  ██╗     ██████╗   █████╗  ███╗   ██╗ ${NC}"
echo -e "  ${L1}${BLD}  ████╗ ████║ ██╔══██╗ ╚██╗██╔╝     ██╔══██╗ ██╔══██╗ ████╗  ██║ ${NC}"
echo -e "  ${L1}${BLD}  ██╔████╔██║ ███████║  ╚███╔╝      ██████╔╝ ███████║ ██╔██╗ ██║ ${NC}"
echo -e "  ${L1}${BLD}  ██║╚██╔╝██║ ██╔══██║  ██╔██╗      ██╔═══╝  ██╔══██║ ██║╚██╗██║ ${NC}"
echo -e "  ${L1}${BLD}  ██║ ╚═╝ ██║ ██║  ██║ ██╔╝ ██╗     ██║      ██║  ██║ ██║ ╚████║ ${NC}"
echo -e "  ${DIM}  ╚═╝     ╚═╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝     ╚═╝      ╚═╝  ╚═╝ ╚═╝  ╚═══╝ ${NC}"
echo -e "  ${L1}${DASH}${NC}"
echo -e "  ${DIM}       ✦  MAX PREMIUM TUNNELING PANEL  ✦      ${NC}"
echo ""
echo -e "       \033[38;5;141m${BLD}type ${NC}\033[1;37mmenu-max${NC}\033[38;5;141m to continue${NC}"
echo ""
SPLASH
    chmod +x /etc/max-panel-splash.sh
    sed -i '/# MAX-PANEL-SPLASH/d;/max-panel-splash/d' /root/.bashrc 2>/dev/null
    echo '# MAX-PANEL-SPLASH' >> /root/.bashrc
    echo 'bash /etc/max-panel-splash.sh' >> /root/.bashrc
}

# ════════════════════════════════════════════════════════════
#  MAIN MENU
# ════════════════════════════════════════════════════════════
main_menu() {
    while true; do
        show_header
        echo -e "  ${A1}${_DASH}${NC}"
        echo -e "  ${A1}       +------------ ${BLD}${AL}MAX PANEL MAIN MENU${NC} ${A1}------------+${NC}"
        echo -e "  ${A1}${_DASH}${NC}"; echo ""
        _r2() { echo -e "  ${1}${3}${NC}  ${A1}│${NC}  ${2}${4}${NC}"; }
        _r2 "${A2}" "${A2}" "[1]  🛡  SSH / OpenSSH + WS-SSH " "[2]  🔐  OpenVPN"
        echo -e "  ${A1}${_DASH}${NC}"
        _r2 "${A2}" "${A2}" "[3]  🟣  Xray VMess/VLess/Trojan" "[4]  ⚡  Trojan-Go"
        echo -e "  ${A1}${_DASH}${NC}"
        _r2 "${A2}" "${A2}" "[5]  🌐  WireGuard              " "[6]  💨  Hysteria 2"
        echo -e "  ${A1}${_DASH}${NC}"
        _r2 "${A2}" "${A2}" "[7]  ⚙   System Tools           " "[8]  💾  Backup & Restore"
        echo -e "  ${A1}${_DASH}${NC}"
        _r2 "${A2}" "${A2}" "[9]  🎨  Tema                   " "[10] ⚙️  Pengaturan"
        echo -e "  ${A1}${_DASH}${NC}"
        _r2 "${A2}" "${A4}" "[11] 🔄  Update Script          " "[12] ℹ️  About"
        echo -e "  ${A1}${_DASH}${NC}"
        _r2 "${A4}" "${LR}" "[13] 🚀  Install Ulang          " "[E]  🗑  Uninstall"
        echo -e "  ${A1}${_DASH}${NC}"
        _r2 "${LR}" "${NC}" "[X]  ✗   Keluar                 " ""
        echo -e "  ${A1}${_DASH}${NC}"
        echo -e "  ${DIM}                ✦  MAX PANEL v${SCRIPT_VERSION}  ✦                ${NC}"; echo ""
        echo -ne "  ${A1}›${NC} Pilih menu: "; read -r ch
        case ${ch,,} in
            1)  menu_ssh ;;       2)  menu_openvpn ;;    3)  menu_xray ;;
            4)  menu_trojan_go ;; 5)  menu_wireguard ;;  6)  menu_hysteria ;;
            7)  menu_system ;;    8)  menu_backup ;;      9)  menu_tema ;;
            10) menu_settings ;;  11) cek_update ;;      12) menu_about ;;
            13) do_install_all ;;
            e)  do_uninstall ;;
            x|0) echo -e "\n  ${IT}${AL}Sampai jumpa! — MAX PANEL${NC}\n"; exit 0 ;;
            *) warn "Pilihan tidak valid!"; sleep 1 ;;
        esac
    done
}

# ════════════════════════════════════════════════════════════
#  CLI FLAGS (untuk cron)
# ════════════════════════════════════════════════════════════
handle_cli_flags() {
    case "${1:-}" in
        --check-maxlogin) check_root; mkdir -p "$DIR"; check_maxlogin_all; exit 0 ;;
        --clean-expired)  check_root; do_clean_expired_all; exit 0 ;;
        --sync-xray)      check_root; _xray_sync_clients; exit 0 ;;
        --auto-backup)
            check_root; mkdir -p "$BACKUPDIR"
            local out="$BACKUPDIR/max-backup-$(date +%Y-%m-%d_%H%M%S).tar.gz"
            tar -czPf "$out" "$DIR" /etc/xray /etc/trojan-go /etc/hysteria \
                /etc/wireguard /etc/openvpn /etc/stunnel 2>/dev/null
            ls -1t "$BACKUPDIR"/max-backup-*.tar.gz 2>/dev/null | tail -n +11 | xargs -r rm -f
            echo "[$(date)] backup: $out"; exit 0 ;;
        --check-update) check_update_silent; exit 0 ;;
        --version|-v)   echo "MAX PANEL v${SCRIPT_VERSION}"; exit 0 ;;
        --help|-h)
            cat <<'HELP'
MAX PANEL — Usage:
  setup-max.sh               → Install + menu
  setup-max.sh --version     → Versi
  setup-max.sh --check-maxlogin  → Enforcer maxlogin (cron)
  setup-max.sh --clean-expired   → Hapus user expired (cron)
  setup-max.sh --auto-backup     → Backup data (cron)
  setup-max.sh --check-update    → Cek versi remote
  setup-max.sh --sync-xray       → Sync Xray config dari DB
  menu-max                   → Buka panel
HELP
            exit 0 ;;
    esac
}

# ════════════════════════════════════════════════════════════
#  MAIN ENTRYPOINT
# ════════════════════════════════════════════════════════════
handle_cli_flags "$@"
check_root; check_os
mkdir -p "$DIR" "$LOGDIR" "$BACKUPDIR"
load_theme
for f in "$MLDB" "$SSH_DB" "$VMESS_DB" "$VLESS_DB" "$TROJAN_DB" \
         "$TROJANGO_DB" "$OVPN_DB" "$WG_DB" "$HY_DB" "$SS_DB"; do
    [[ ! -f "$f" ]] && touch "$f"
done

NEED_INSTALL=0
[[ ! -x "$XRAY_BIN" || ! -f "$VERSIONF" ]] && NEED_INSTALL=1

if [[ "$NEED_INSTALL" == "1" && ! -x /usr/local/bin/max-menu ]]; then
    do_install_all; main_menu; exit 0
fi

[[ ! -x /usr/local/bin/max-menu ]] && setup_menu_cmd 2>/dev/null
[[ ! -f /etc/max-panel-splash.sh ]] && install_ssh_splash 2>/dev/null

main_menu
exit 0
