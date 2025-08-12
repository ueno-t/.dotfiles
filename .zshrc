# environment
umask 022
export LANG=ja_JP.UTF-8

# binding
bindkey -e

# colors
autoload -Uz colors && colors

# dir colors
eval $(dircolors $HOME/.dircolors)

# history
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000

# separating
autoload -Uz select-word-style && select-word-style default
zstyle ':zle:*' word-chars " /=;@:{},|"
zstyle ':zle:*' word-style unspecified

# completion
fpath=(~/.zsh/plugins/completions/src $fpath)
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin
zstyle ':completion:*:processes' command 'ps x -o pid,s,args'

# autosuggestions
source ~/.zsh/plugins/autosuggestions/zsh-autosuggestions.zsh

# prompt
ARROW_RIGHT=$'\ue0b0'
TIME_BG="31"    && TIME_FG="253"
USER_BG="242"   && USER_FG="253"
HOST_BG="239"   && HOST_FG="253"
PWD_BG="31"     && PWD_FG="253"
PROMPT_BG="237" && PROMPT_FG="253"

PROMPT_TIME="%K{$TIME_BG}%F{$TIME_FG} %* %K{$USER_BG}%F{$TIME_BG}$ARROW_RIGHT"
PROMPT_USER="%K{$USER_BG}%F{$USER_FG} %n %K{$HOST_BG}%F{$USER_BG}$ARROW_RIGHT"
PROMPT_HOST="%K{$HOST_BG}%F{$HOST_FG} %m %K{$PWD_BG}%F{$HOST_BG}$ARROW_RIGHT"
PROMPT_PWD="%K{$PWD_BG}%F{$PWD_FG} %~ %k%F{$PWD_BG}$ARROW_RIGHT"
PROMPT_PROMPT="%K{$PROMPT_BG}%F{$PROMPT_FG} %# %k%F{$PROMPT_BG}$ARROW_RIGHT%f"

PROMPT="$PROMPT_TIME$PROMPT_USER$PROMPT_HOST$PROMPT_PWD
$PROMPT_PROMPT "

# vcs_info
autoload -Uz vcs_info
autoload -Uz add-zsh-hook

ARROW_LEFT=$'\ue0b2'
VCS_BG="148"       && VCS_FG="236"
VCS_DIRTY_BG="166" && VCS_DIRTY_FG="253"
PROMPT_VCS="%F{$VCS_BG}$ARROW_LEFT%K{$VCS_BG}%F{$VCS_FG} %c%u[%b]"
PROMPT_VCS_DIRTY="%F{$VCS_DIRTY_BG}$ARROW_LEFT%K{$VCS_DIRTY_BG}%F{$VCS_DIRTY_FG} [%b|%a]"

zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr "+"
zstyle ':vcs_info:git:*' unstagedstr "!"
zstyle ':vcs_info:*' formats "$PROMPT_VCS"
zstyle ':vcs_info:*' actionformats "$PROMPT_VCS_DIRTY"

function _update_vcs_info_msg() {
    LANG=en_US.UTF-8 vcs_info
    RPROMPT="${vcs_info_msg_0_}"
}
add-zsh-hook precmd _update_vcs_info_msg

# options
setopt print_eight_bit
setopt no_beep
setopt no_flow_control
setopt interactive_comments
setopt auto_cd
setopt auto_pushd
setopt pushd_ignore_dups
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
setopt extended_glob

# alias
alias la='ls -a'
alias ll='ls -l'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias mkdir='mkdir -p'
alias sudo='sudo '
alias -g L='| less'
alias -g G='| grep'

# copy clip by C
# mollifier delta blog : http://mollifier.hatenablog.com/entry/20100317/p1
if which pbcopy >/dev/null 2>&1 ; then
    # Mac
    alias -g C='| pbcopy'
elif which xsel >/dev/null 2>&1 ; then
    # Linux
    alias -g C='| xsel --input --clipboard'
elif which putclip >/dev/null 2>&1 ; then
    # Cygwin
    alias -g C='| putclip'
fi

# os setting
case ${OSTYPE} in
    darwin*)
        # for mac
        export CLICOLOR=1
        alias ls='ls -G -F'
        ;;
    linux*)
        # for linux
        alias ls='ls -F --color=auto'
        ;;
esac

# load local setting
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
