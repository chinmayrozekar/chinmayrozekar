# New Mac Setup

One-command replication of my MacBook dev environment. Built from a live audit
of my current machine (2026-07-16) — brew packages, npm globals, dotfiles,
Vim plugins, Terminal.app profile, Zellij keybinds, and VS Code extensions.

## Quick start (target: ~30 min)

```bash
git clone https://github.com/chinmayrozekar/chinmayrozekar.git
cd chinmayrozekar/new_mac_setup
chmod +x setup.sh
./setup.sh          # prompts before heavy installs
./setup.sh --all    # no prompts; also Docker Desktop, Flutter, MacTeX (~5 GB)
```

## What's in here

| Path | What it is |
|---|---|
| `setup.sh` | The installer — idempotent, safe to re-run |
| `dotfiles/zshrc` | Aliases (GNU ls, git shortcuts, `gcp`), prompt, fzf + zoxide integration |
| `dotfiles/vimrc` | Vim config + vim-plug plugin list (VimWiki, NERDTree, Goyo, easy-align…) |
| `dotfiles/tmux.conf` | tmux: vim-style pane nav, panes open in current dir |
| `dotfiles/gitconfig` | Git identity + delta as pager with line numbers |
| `terminal/Chinmay-Basic.terminal` | Terminal.app profile — Fira Code Nerd Font 14pt, option-as-meta, bell off |
| `zellij/config.kdl` | Zellij with fully custom keybinds (defaults cleared) |
| `vscode-extensions.txt` | All 48 VS Code extensions |
| `bin/focusradio` | Focus-music picker (mpv + yt-dlp) installed to `~/bin` |

## What gets installed

- **CLI:** coreutils (gls), bat, fd, ripgrep, fzf, tree, jq, zoxide, git, gh,
  git-delta, tmux, zellij, gnupg, gnu-typist, make
- **Languages:** Python 3.12/3.14 (+ uv), Node, Go, Rust (rustup), OpenJDK 17
- **AI:** Claude Code, Gemini CLI, opencode, ollama
- **Apps/casks:** Fira Code Nerd Font, VS Code; optional — Docker Desktop, Flutter, MacTeX
- **Media/docs:** mpv, yt-dlp, ffmpeg, poppler, ghostscript, tesseract
- **DB:** postgresql@16
- **npm globals:** pptxgenjs, sharp, react/react-dom/react-icons

## Manual steps after the script

1. Restart Terminal (new profile + `.zshrc` take effect)
2. `gh auth login`
3. `claude` → sign in
4. `ssh-keygen -t ed25519 -C "chinmay.rozekar@gmail.com"` → add to GitHub
5. `ollama pull <model>` for any local models
6. Full Xcode from the App Store (script only installs Command Line Tools)

## Notes

- Existing dotfiles are backed up as `*.backup.<timestamp>` before overwrite.
- The script is idempotent — re-running skips anything already installed.
- Vim plugins install headlessly via `vim +PlugInstall`; first interactive
  launch may take a second while plugins finish syncing.
