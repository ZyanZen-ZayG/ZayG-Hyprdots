#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# hyprsimple shell init (added by terminal.sh)
source ~/.local/bin/bashrc.sh
export PATH="$HOME/.local/bin:$PATH"

# Anime Girl Logo Randomizer
fastfetch() {
    local cols=$(tput cols)
    local img=$(find ~/.config/fastfetch/images -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" \) 2>/dev/null | shuf -n 1)

    # If the window is too small, don't show the logo
    if [ "$cols" -lt 60 ]; then
        command fastfetch --logo none "$@"
        
    # If the window is medium-sized, use a smaller logo (width 20)
    elif [ "$cols" -lt 110 ]; then
        if [[ -n "$img" ]]; then
            command fastfetch --logo "$img" --logo-width 20 "$@"
        else
            command fastfetch "$@"
        fi
        
    # If the window is large, use a bigger logo (width 35)
    else
        if [[ -n "$img" ]]; then
            command fastfetch --logo "$img" --logo-width 35 "$@"
        else
            command fastfetch "$@"
        fi
    fi
}

# Auto run fastfetch when opening terminal
case $- in
  *i*) command -v fastfetch >/dev/null 2>&1 && fastfetch ;;
esac
