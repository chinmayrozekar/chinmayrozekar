#!/bin/zsh

# ═══════════════════════════════════════════════════════════
#  New Mac Setup — Chinmay Rozekar
#  Replicates my personal MacBook environment on a fresh Mac.
#  Generated from a live audit of the source machine (2026-07-16).
#
#  Usage:
#    ./setup.sh          # core setup (~30 min)
#    ./setup.sh --all    # also install heavy casks without asking
#                        # (Docker Desktop, Flutter, MacTeX ~5GB)
# ═══════════════════════════════════════════════════════════

set -e

SCRIPT_DIR="${0:A:h}"
INSTALL_ALL=false
[[ "$1" == "--all" ]] && INSTALL_ALL=true

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()  { echo -e "${GREEN}✓${NC} $1"; }
info() { echo -e "${BLUE}→${NC} $1"; }
warn() { echo -e "${YELLOW}!${NC} $1"; }

ask() {
  $INSTALL_ALL && return 0
  read -q "REPLY?$1 [y/N] "; echo
  [[ "$REPLY" == "y" ]]
}

echo ""
echo "╔══════════════════════════════════════════╗"
echo "║      Chinmay's Mac Environment Setup     ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── 1. Xcode Command Line Tools ────────────────
info "Checking Xcode Command Line Tools..."
if ! xcode-select -p &>/dev/null; then
  xcode-select --install
  warn "Finish the CLT install dialog, then re-run this script."
  exit 1
else
  log "Xcode CLT present"
fi

# ── 2. Homebrew ────────────────────────────────
info "Checking Homebrew..."
if ! command -v brew &>/dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  log "Homebrew already installed"
fi

# ── 3. Brew formulae (CLI tools) ───────────────
info "Installing CLI tools..."
BREW_PACKAGES=(
  # shell & files
  coreutils        # GNU ls (gls) — my ls aliases depend on this
  bat fd ripgrep fzf tree jq zoxide
  # git
  git gh git-delta
  # multiplexers
  tmux zellij
  # languages & runtimes
  go node python@3.12 python@3.14 openjdk@17 tcl-tk
  # build
  make
  # data
  postgresql@16
  # docs / pdf
  poppler ghostscript tesseract
  # media (focusradio depends on mpv + yt-dlp)
  mpv yt-dlp ffmpeg
  # misc
  gnupg gnu-typist
)

for pkg in "${BREW_PACKAGES[@]}"; do
  if brew list "$pkg" &>/dev/null; then
    log "$pkg already installed"
  else
    brew install "$pkg" && log "$pkg installed"
  fi
done

# ── 4. Fonts & apps (casks) ────────────────────
info "Installing casks..."
brew list --cask font-fira-code-nerd-font &>/dev/null || \
  brew install --cask font-fira-code-nerd-font && log "Fira Code Nerd Font"

if ! command -v code &>/dev/null && ! [ -d "/Applications/Visual Studio Code.app" ]; then
  brew install --cask visual-studio-code && log "VS Code installed"
else
  log "VS Code already installed"
fi

# Heavy casks — prompt unless --all
if ! brew list --cask docker-desktop &>/dev/null; then
  ask "Install Docker Desktop?" && brew install --cask docker-desktop
fi
if ! brew list --cask flutter &>/dev/null && ! command -v flutter &>/dev/null; then
  ask "Install Flutter SDK?" && brew install --cask flutter
fi
if ! brew list --cask mactex &>/dev/null; then
  ask "Install MacTeX (~5 GB, needed for LaTeX/pdflatex)?" && brew install --cask mactex
fi

# ── 5. Rust ────────────────────────────────────
info "Checking Rust..."
if ! command -v rustc &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  log "Rust (stable) installed via rustup"
else
  log "Rust already installed ($(rustc --version))"
fi

# ── 6. Python tooling (uv) ─────────────────────
info "Checking uv..."
if ! command -v uv &>/dev/null && ! [ -x "$HOME/.local/bin/uv" ]; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
  log "uv installed"
else
  log "uv already installed"
fi

# ── 7. AI CLIs ─────────────────────────────────
info "Installing AI coding CLIs..."
if ! command -v claude &>/dev/null && ! [ -x "$HOME/.local/bin/claude" ]; then
  curl -fsSL https://claude.ai/install.sh | bash
  log "Claude Code installed"
else
  log "Claude Code already installed"
fi

NPM_GLOBALS=(
  @google/gemini-cli
  opencode-ai
  pptxgenjs
  sharp
  react react-dom react-icons
)
for pkg in "${NPM_GLOBALS[@]}"; do
  if npm ls -g "$pkg" &>/dev/null; then
    log "npm: $pkg already installed"
  else
    npm install -g "$pkg" && log "npm: $pkg installed"
  fi
done

if ! command -v ollama &>/dev/null; then
  brew install ollama && log "ollama installed"
else
  log "ollama already installed"
fi

# ── 8. Dotfiles ────────────────────────────────
info "Installing dotfiles (existing files backed up as *.backup)..."
typeset -A DOTFILES
DOTFILES=(
  zshrc     "$HOME/.zshrc"
  vimrc     "$HOME/.vimrc"
  tmux.conf "$HOME/.tmux.conf"
  gitconfig "$HOME/.gitconfig"
)
for src dest in "${(@kv)DOTFILES}"; do
  if [ -f "$dest" ] && ! diff -q "$SCRIPT_DIR/dotfiles/$src" "$dest" &>/dev/null; then
    cp "$dest" "$dest.backup.$(date +%Y%m%d%H%M%S)"
    warn "Backed up existing $dest"
  fi
  cp "$SCRIPT_DIR/dotfiles/$src" "$dest"
  log "$dest"
done

# ── 9. Vim: vim-plug + plugins ─────────────────
info "Setting up Vim..."
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
  curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  log "vim-plug installed"
else
  log "vim-plug already installed"
fi
vim -es -u "$HOME/.vimrc" -i NONE -c "PlugInstall --sync" -c "qa" || true
log "Vim plugins installed (Goyo, Limelight, VimWiki, NERDTree, DrawIt, AnsiEsc, code-dark, table-mode, easy-align)"

# ── 10. Zellij config ──────────────────────────
mkdir -p "$HOME/.config/zellij"
cp "$SCRIPT_DIR/zellij/config.kdl" "$HOME/.config/zellij/config.kdl"
log "Zellij config installed"

# ── 11. Terminal.app profile ───────────────────
info "Installing Terminal profile (Basic — Fira Code Nerd Font 14pt)..."
open "$SCRIPT_DIR/terminal/Chinmay-Basic.terminal"
sleep 1
defaults write com.apple.Terminal "Default Window Settings" -string "Basic"
defaults write com.apple.Terminal "Startup Window Settings" -string "Basic"
log "Terminal profile imported and set as default"

# ── 12. Personal scripts (~/bin) ───────────────
mkdir -p "$HOME/bin"
cp "$SCRIPT_DIR/bin/focusradio" "$HOME/bin/focusradio"
chmod +x "$HOME/bin/focusradio"
log "focusradio installed to ~/bin"

# ── 13. VS Code extensions ─────────────────────
if command -v code &>/dev/null; then
  info "Installing VS Code extensions..."
  while IFS= read -r ext; do
    [ -z "$ext" ] && continue
    code --install-extension "$ext" --force &>/dev/null && log "vscode: $ext"
  done < "$SCRIPT_DIR/vscode-extensions.txt"
else
  warn "VS Code 'code' CLI not found — open VS Code, run 'Shell Command: Install code command in PATH', then:"
  warn "  cat vscode-extensions.txt | xargs -L1 code --install-extension"
fi

# ── Done ───────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║              Setup Complete!             ║"
echo "╚══════════════════════════════════════════╝"
echo ""
echo "  Manual steps remaining:"
echo "  1. Restart Terminal (picks up profile + .zshrc)"
echo "  2. gh auth login              # GitHub CLI"
echo "  3. claude                     # sign in to Claude Code"
echo "  4. ssh-keygen -t ed25519      # new SSH key, add to GitHub"
echo "  5. ollama pull <model>        # pull models you need"
echo "  6. Xcode (full) from the App Store if needed"
echo ""
