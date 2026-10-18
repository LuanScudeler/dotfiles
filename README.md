# .files

My personal dotfiles for **Linux/Ubuntu (including WSL)**. Take anything you
want, but at your own risk.

Adapted from [webpro/dotfiles](https://github.com/webpro/dotfiles) (originally
macOS-first) into an Ubuntu-only setup built around the Makefile, Homebrew
(Linuxbrew), and [stow](https://www.gnu.org/software/stow/).

## Highlights

- Minimal effort to install everything, using a [Makefile](./Makefile)
- Built around Homebrew (Linuxbrew), Node.js (via [mise](https://mise.jdx.dev)), and GNU utils
- Fast and colored prompt
- Well-organized and easy to customize
- Symlinks [runcom](./runcom) and [config](./config) files using stow
- Install and runcom setup tested on Ubuntu in
  [a GitHub Action](./.github/workflows/dotfiles-installation.yml)

## Packages Overview

- [Homebrew](https://brew.sh) (packages: [Brewfile](./install/Brewfile))
- [mise](https://mise.jdx.dev) manages Node.js LTS, with per-project versions
  via `.mise.toml` / `.tool-versions`
- [Node.js LTS + npm globals](https://nodejs.org/en/download/) (packages: [npmfile](./install/npmfile), installed through mise)
- Java ([OpenJDK 25 LTS](https://openjdk.org/)) and [.NET](https://dotnet.microsoft.com/) (SDK) via Homebrew
- Latest Git, Bash, Python, GNU coreutils, curl, Ruby
- Editor: VS Code (`EDITOR`, `VISUAL` and Git `core.editor`)

## Prerequisites

The privileged steps require `sudo`, so run them yourself (the Makefile keeps
them in a separate `prereqs` target). `make` is required to run the Makefile:

```sh
sudo apt-get update
sudo apt-get install -y build-essential procps curl file git make
```

## Installation

Either install this repo with a single command (clones to `~/.dotfiles`):

```bash
bash -c "`curl -fsSL https://raw.githubusercontent.com/LuanScudeler/dotfiles/main/remote-install.sh`"
```

Or clone manually into the desired location:

```bash
git clone https://github.com/LuanScudeler/dotfiles.git ~/.dotfiles
```

Then install packages and symlink the dotfiles:

```bash
cd ~/.dotfiles
make prereqs   # privileged (sudo): apt prerequisites
make           # Homebrew bundle, Node packages, stow linking
```

Running `make` is idempotent. The installation process is tested on Ubuntu in
[this GitHub Action](./.github/workflows/dotfiles-installation.yml).

To undo the linking:

```bash
make unlink
```

## Post-Installation

1. Authenticate GitHub CLI (used as the Git credential helper):

```sh
gh auth login
```

2. Set your Git identity in [config/git/config](./config/git/config).

3. Populate this file with anything you need sourced in each shell:

```sh
mkdir -p $DOTFILES_DIR/local
touch $DOTFILES_DIR/local/.profile
touch $DOTFILES_DIR/local/.env
```

## The `dot` command

```
$ dot help
Usage: dot <command>

Commands:
   clean            Clean up caches (brew, gem)
   edit             Open dotfiles in IDE ($VISUAL)
   help             This help message
   test             Run tests
   update           Update packages and pkg managers (brew, pip3, npm, gems)
```

## Node.js (mise)

Node.js LTS is installed and selected by [mise](https://mise.jdx.dev) (see the
`node-packages` target in the [Makefile](./Makefile)). Global npm packages from
[install/npmfile](./install/npmfile) are installed through the mise-selected
Node.

- Global default: `mise use -g node@lts` (recorded in `~/.config/mise/config.toml`)
- Per project: add a `.mise.toml` or `.tool-versions`; mise switches versions on
  `cd` and installs missing ones automatically

```sh
cd my-project
mise use node@20   # writes .mise.toml
node --version
```

mise is activated in [runcom/.bash_profile](./runcom/.bash_profile) (after the
dotfiles are sourced, so its `PROMPT_COMMAND` hook survives `.prompt`). For
non-interactive use, call tools through `mise exec -- <command>`.

## WSL notes

- `bin/pbcopy` and `bin/pbpaste` bridge the Windows clipboard (via `clip.exe`
  and PowerShell), so configs that use `pbcopy` (`.fzf`, tmux) work unchanged.
- `bin/open` opens files/URLs with Windows (`wslview` if available, otherwise
  `explorer.exe`).
- Homebrew lives at `/home/linuxbrew/.linuxbrew` and is put on `PATH` by
  [system/linux/.path](./system/linux/.path).

## Customize

To customize the dotfiles to your liking, fork it and be the king of your
castle: https://www.webpro.nl/articles/getting-started-with-dotfiles

## Credits

Many thanks to the [dotfiles community](https://dotfiles.github.io) and to
[webpro](https://github.com/webpro) for the original repo.
