#!/data/data/com.termux/files/usr/bin/bash
# ╔══════════════════════════════════════════════════════════════╗
# ║           flandre-install  •  GitHub Tool Installer          ║
# ║                    github.com/flandreiii                     ║
# ╚══════════════════════════════════════════════════════════════╝

# ── Colors ────────────────────────────────────────────────────
R='\033[0;31m'   # red
G='\033[0;32m'   # green
Y='\033[1;33m'   # yellow
B='\033[0;34m'   # blue
C='\033[0;36m'   # cyan
M='\033[0;35m'   # magenta
W='\033[1;37m'   # white bold
D='\033[2;37m'   # dim
NC='\033[0m'     # reset
BLD='\033[1m'

# ── Config ────────────────────────────────────────────────────
GITHUB_USER="flandreiii"
INSTALL_DIR="$HOME/tools"

# ── Helpers ───────────────────────────────────────────────────
banner() {
  clear
  echo -e "${C}"
  echo '  ███████╗██╗      █████╗ ███╗   ██╗██████╗ ██████╗ ███████╗██╗██╗██╗'
  echo '  ██╔════╝██║     ██╔══██╗████╗  ██║██╔══██╗██╔══██╗██╔════╝██║██║██║'
  echo '  █████╗  ██║     ███████║██╔██╗ ██║██║  ██║██████╔╝█████╗  ██║██║██║'
  echo '  ██╔══╝  ██║     ██╔══██║██║╚██╗██║██║  ██║██╔══██╗██╔══╝  ██║██║██║'
  echo '  ██║     ███████╗██║  ██║██║ ╚████║██████╔╝██║  ██║███████╗██║██║██║'
  echo '  ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝╚═╝╚═╝'
  echo -e "${NC}"
  echo -e "  ${D}╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌${NC}"
  echo -e "  ${W}GitHub Tool Installer${NC}  ${D}•${NC}  ${C}@${GITHUB_USER}${NC}"
  echo -e "  ${D}╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌${NC}"
  echo
}

log_ok()   { echo -e "  ${G}✔${NC}  $1"; }
log_info() { echo -e "  ${C}•${NC}  $1"; }
log_warn() { echo -e "  ${Y}!${NC}  $1"; }
log_err()  { echo -e "  ${R}✘${NC}  $1"; }
log_step() { echo -e "\n  ${M}▸${NC}  ${W}$1${NC}"; }

spinner() {
  local pid=$1 msg=$2
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r  ${C}${frames[$i]}${NC}  ${D}%s${NC}" "$msg"
    i=$(( (i+1) % ${#frames[@]} ))
    sleep 0.08
  done
  printf "\r\033[K"
}

# ── Dependency check ──────────────────────────────────────────
check_deps() {
  log_step "Checking dependencies"
  local missing=()
  for cmd in curl git jq; do
    if command -v "$cmd" &>/dev/null; then
      log_ok "$cmd found"
    else
      log_warn "$cmd not found — will install"
      missing+=("$cmd")
    fi
  done

  if [ ${#missing[@]} -gt 0 ]; then
    echo
    log_info "Installing: ${missing[*]}"
    pkg install -y "${missing[@]}" > $TMPDIR/pkg_install.log 2>&1 &
    spinner $! "Installing packages via pkg..."
    wait $!
    if [ $? -eq 0 ]; then
      log_ok "Packages installed successfully"
    else
      log_err "Package install failed. Check $TMPDIR/pkg_install.log"
      exit 1
    fi
  fi
}

# ── Fetch repos ───────────────────────────────────────────────
fetch_repos() {
  log_step "Fetching repositories from GitHub"

  local page=1
  local all_json="[]"

  while true; do
    local url="https://api.github.com/users/${GITHUB_USER}/repos?per_page=30&sort=updated&page=${page}"
    printf "  ${C}⠿${NC}  ${D}Fetching page ${page}...${NC}"
    local page_json
    page_json=$(curl -s "$url")
    printf "\r\033[K"

    # Check for API error
    local resp_type
    resp_type=$(echo "$page_json" | jq -r 'type' 2>/dev/null)
    if [ "$resp_type" != "array" ]; then
      local msg
      msg=$(echo "$page_json" | jq -r '.message // "Unknown error"' 2>/dev/null)
      log_err "GitHub API error: $msg"
      log_err "Response: $(echo "$page_json" | head -c 200)"
      exit 1
    fi

    # Count items on this page
    local count
    count=$(echo "$page_json" | jq 'length')

    # Merge into all_json
    all_json=$(printf '%s\n%s' "$all_json" "$page_json" | jq -s '.[0] + .[1]')

    # If fewer than 30 results, this is the last page
    if [ "$count" -lt 30 ]; then
      break
    fi

    (( page++ ))
  done

  REPO_JSON="$all_json"

  mapfile -t REPO_NAMES < <(echo "$REPO_JSON" | jq -r '.[].name')
  mapfile -t REPO_URLS  < <(echo "$REPO_JSON" | jq -r '.[].clone_url')
  mapfile -t REPO_DESCS < <(echo "$REPO_JSON" | jq -r '.[].description // "No description"')
  mapfile -t REPO_LANGS < <(echo "$REPO_JSON" | jq -r '.[].language // "—"')
  mapfile -t REPO_STARS < <(echo "$REPO_JSON" | jq -r '.[].stargazers_count')
  TOTAL=${#REPO_NAMES[@]}

  if [ "$TOTAL" -eq 0 ]; then
    log_err "No public repositories found for @${GITHUB_USER}"
    exit 1
  fi

  log_ok "Found ${W}${TOTAL}${NC} public repositories"
}

# ── Interactive menu ──────────────────────────────────────────
show_menu() {
  log_step "Select repositories to install"
  echo -e "  ${D}[space] toggle  •  [a] all  •  [n] none  •  [enter] confirm${NC}\n"

  declare -gA SELECTED
  for i in "${!REPO_NAMES[@]}"; do SELECTED[$i]=0; done

  local cursor=0
  local page_size=10

  # Hide cursor
  tput civis

  render_list() {
    local start=$(( cursor / page_size * page_size ))
    local end=$(( start + page_size - 1 ))
    [ $end -ge $TOTAL ] && end=$(( TOTAL - 1 ))

    tput cup 0 0
    # Clear area
    for i in $(seq 0 $(( page_size + 4 ))); do
      printf "\033[K\n"
    done
    tput cup 0 0

    local page_num=$(( cursor / page_size + 1 ))
    local total_pages=$(( (TOTAL + page_size - 1) / page_size ))
    echo -e "  ${D}Page ${page_num}/${total_pages}  (${TOTAL} repos total)${NC}\n"

    for i in $(seq $start $end); do
      local name="${REPO_NAMES[$i]}"
      local lang="${REPO_LANGS[$i]}"
      local stars="${REPO_STARS[$i]}"
      local desc="${REPO_DESCS[$i]}"
      # Truncate desc
      [ ${#desc} -gt 42 ] && desc="${desc:0:42}…"

      local sel_mark="${D}○${NC}"
      local name_color="${D}"
      [ "${SELECTED[$i]}" -eq 1 ] && sel_mark="${G}●${NC}" && name_color="${W}"

      local cursor_mark="  "
      [ $i -eq $cursor ] && cursor_mark="${C}▶${NC}"

      printf "  %b %b %b%-26s${NC}  ${D}%-14s${NC}  ${Y}★%-3s${NC}  ${D}%s${NC}\n" \
        "$cursor_mark" "$sel_mark" "$name_color" "$name" "$lang" "$stars" "$desc"
    done

    local sel_count=0
    for i in "${!SELECTED[@]}"; do [ "${SELECTED[$i]}" -eq 1 ] && (( sel_count++ )); done
    echo
    echo -e "  ${D}────────────────────────────────────────────────────────${NC}"
    echo -e "  ${W}${sel_count}${NC}${D} selected  •  ↑↓ navigate  •  space toggle  •  a all  •  n none  •  enter install${NC}"
  }

  # Save screen position
  local orig_rows
  orig_rows=$(tput lines)

  # Use a full-screen approach: move to top, print list
  clear

  while true; do
    render_list

    # Read key
    IFS= read -r -s -n1 key
    case "$key" in
      $'\x1b')
        IFS= read -r -s -n1 -t 0.1 k2
        IFS= read -r -s -n1 -t 0.1 k3
        case "$k3" in
          'A') # up
            [ $cursor -gt 0 ] && (( cursor-- ))
            # Page boundary
            if [ $(( cursor % page_size )) -eq $(( page_size - 1 )) ]; then
              clear
            fi
            ;;
          'B') # down
            [ $cursor -lt $(( TOTAL - 1 )) ] && (( cursor++ ))
            if [ $(( cursor % page_size )) -eq 0 ]; then
              clear
            fi
            ;;
        esac
        ;;
      ' ') # toggle
        if [ "${SELECTED[$cursor]}" -eq 1 ]; then
          SELECTED[$cursor]=0
        else
          SELECTED[$cursor]=1
        fi
        ;;
      'a'|'A') for i in "${!REPO_NAMES[@]}"; do SELECTED[$i]=1; done; clear ;;
      'n'|'N') for i in "${!REPO_NAMES[@]}"; do SELECTED[$i]=0; done; clear ;;
      $'\x0a'|$'\x0d'|'') # enter
        tput cnorm
        break
        ;;
      'q'|'Q')
        tput cnorm
        echo -e "\n  ${Y}Aborted.${NC}\n"
        exit 0
        ;;
    esac
  done
}

# ── Install selected repos ────────────────────────────────────
install_repos() {
  banner
  log_step "Installing selected repositories"

  mkdir -p "$INSTALL_DIR"

  local installed=0 skipped=0 failed=0
  local results=()

  for i in "${!REPO_NAMES[@]}"; do
    [ "${SELECTED[$i]}" -ne 1 ] && continue

    local name="${REPO_NAMES[$i]}"
    local url="${REPO_URLS[$i]}"
    local dest="${INSTALL_DIR}/${name}"

    echo -e "\n  ${D}╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌${NC}"
    echo -e "  ${C}▸${NC}  ${W}${name}${NC}"

    if [ -d "$dest" ]; then
      log_warn "Already exists — pulling latest changes"
      ( cd "$dest" && git pull --ff-only > $TMPDIR/git_pull.log 2>&1 ) &
      spinner $! "git pull ${name}..."
      wait $!
      if [ $? -eq 0 ]; then
        log_ok "Updated"
        results+=("${G}↑ updated${NC}  ${name}")
        (( installed++ ))
      else
        log_warn "Pull failed (may have local changes)"
        results+=("${Y}~ skipped${NC}  ${name}")
        (( skipped++ ))
      fi
    else
      git clone --depth=1 "$url" "$dest" > $TMPDIR/git_clone.log 2>&1 &
      spinner $! "Cloning ${name}..."
      wait $!
      if [ $? -eq 0 ]; then
        log_ok "Cloned → ${dest}"
        # Run auto-setup if present
        auto_setup "$dest" "$name"
        results+=("${G}✔ cloned${NC}   ${name}")
        (( installed++ ))
      else
        log_err "Clone failed"
        results+=("${R}✘ failed${NC}   ${name}")
        (( failed++ ))
      fi
    fi
  done

  # Summary
  echo
  echo -e "  ${D}════════════════════════════════════════════${NC}"
  log_step "Summary"
  for r in "${results[@]}"; do
    echo -e "  ${r}"
  done
  echo
  echo -e "  ${G}${installed} installed/updated${NC}  ${Y}${skipped} skipped${NC}  ${R}${failed} failed${NC}"
  echo -e "  ${D}Install directory: ${INSTALL_DIR}${NC}"
  echo
}

# ── Auto setup detector ───────────────────────────────────────
auto_setup() {
  local dir=$1 name=$2

  # package.json → npm install
  if [ -f "${dir}/package.json" ]; then
    log_info "Detected Node.js project → running npm install"
    ( cd "$dir" && npm install --silent > $TMPDIR/npm_install.log 2>&1 ) &
    spinner $! "npm install (${name})..."
    wait $! && log_ok "npm install done" || log_warn "npm install had errors"

  # requirements.txt → pip install
  elif [ -f "${dir}/requirements.txt" ]; then
    log_info "Detected Python project → running pip install"
    ( cd "$dir" && pip install -r requirements.txt -q > $TMPDIR/pip_install.log 2>&1 ) &
    spinner $! "pip install (${name})..."
    wait $! && log_ok "pip install done" || log_warn "pip install had errors"

  # Makefile → make
  elif [ -f "${dir}/Makefile" ]; then
    log_info "Detected Makefile → running make"
    ( cd "$dir" && make -s > $TMPDIR/make.log 2>&1 ) &
    spinner $! "make (${name})..."
    wait $! && log_ok "make done" || log_warn "make had errors"

  # install.sh
  elif [ -f "${dir}/install.sh" ]; then
    log_info "Detected install.sh → running it"
    ( cd "$dir" && bash install.sh > $TMPDIR/install_sh.log 2>&1 ) &
    spinner $! "install.sh (${name})..."
    wait $! && log_ok "install.sh done" || log_warn "install.sh had errors"
  fi
}

# ── Entry point ───────────────────────────────────────────────
main() {
  banner
  check_deps
  fetch_repos
  show_menu

  # Count selections
  local sel=0
  for i in "${!SELECTED[@]}"; do [ "${SELECTED[$i]}" -eq 1 ] && (( sel++ )); done

  if [ "$sel" -eq 0 ]; then
    echo -e "\n  ${Y}No repositories selected. Exiting.${NC}\n"
    exit 0
  fi

  echo -e "\n  ${W}${sel}${NC} repositories selected. ${D}Proceed? [y/N]${NC} "
  read -r -s -n1 confirm
  echo
  if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
    echo -e "  ${Y}Aborted.${NC}\n"
    exit 0
  fi

  install_repos
}

main "$@"
