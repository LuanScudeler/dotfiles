# If not running interactively, don't do anything

[ -z "$PS1" ] && return

# Resolve DOTFILES_DIR from the (possibly symlinked) runcom file
CURRENT_SCRIPT=${BASH_SOURCE[0]:-$0}

if SCRIPT_PATH=$(readlink -f "$CURRENT_SCRIPT" 2>/dev/null) && [ -n "$SCRIPT_PATH" ]; then
  DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_PATH")")"
elif [ -d "$HOME/.dotfiles" ]; then
  DOTFILES_DIR="$HOME/.dotfiles"
elif [ -d "$HOME/dotfiles" ]; then
  DOTFILES_DIR="$HOME/dotfiles"
else
  echo "Unable to find dotfiles, exiting."
  return
fi

# Make utilities available

PATH="$DOTFILES_DIR/bin:$PATH"

# Source the dotfiles (order matters)

[ -f "$DOTFILES_DIR/local/.profile" ] && . "$DOTFILES_DIR/local/.profile"
[ -f "$DOTFILES_DIR/local/.env" ] && . "$DOTFILES_DIR/local/.env"

for DOTFILE in "$DOTFILES_DIR"/system/.{function,function_*,path,env,alias,fzf,grep,prompt,completion,fix,pnpm,zoxide}; do
  . "$DOTFILE"
done

if is-ubuntu; then
  for DOTFILE in "$DOTFILES_DIR"/system/linux/.{env,alias,function}; do
    . "$DOTFILE"
  done
fi

# mise: language runtime version manager (Node, etc.). Activate last so its
# PROMPT_COMMAND hook is not clobbered by system/.prompt, which sets PROMPT_COMMAND.

if is-executable mise; then
  eval "$(mise activate bash)"
fi

# Set LSCOLORS

eval "$(dircolors -b "$DOTFILES_DIR"/system/.dir_colors)"

# Wrap up

unset CURRENT_SCRIPT SCRIPT_PATH DOTFILE

export DOTFILES_DIR
