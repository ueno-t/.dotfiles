#!/bin/bash
set -e
DOTPATH=~/.dotfiles
TARBALL="https://github.com/ueno-t/.dotfiles/archive/master.tar.gz"

has() {
  type "$1" > /dev/null 2>&1
}

usage () {
  name=`basename $0`
  cat <<EOF
Usage:
  $name [command]
Commands:
  all
  devcontainer
  rootless
EOF
  exit 1
}

all() {
  download
  deploy
  initialize
  zsh
  tpm
  wslconf
  docker
  chsh
}

devcontainer() {
  zsh
  copyrc
}

download() {
  if has "curl"; then
    curl -L $TARBALL
  elif has "wget"; then
    wget -O - $TARBALL
  fi | tar xzv
  mv -f .dotfiles-master $DOTPATH
}

deploy() {
  cd $DOTPATH
  if [ $? -ne 0 ]; then
    die "not found: $DOTPATH"
  fi

  for f in .??*
  do
    [ "$f" = ".git" ] && continue
    [ "$f" = ".gitignore" ] && continue

    ln -snfv "$DOTPATH/$f" "$HOME/$f"
  done
}

initialize() {
  # base
  sudo apt install -y git zsh vim tmux universal-ctags curl keychain
  # locale
  sudo sed -i '/# ja_JP.UTF-8/s/^.\{2\}//' /etc/locale.gen
  sudo locale-gen
  # ping
  sudo chmod u+s /bin/ping
}

zsh() {
  # zsh
  git clone --depth 1 https://github.com/zsh-users/zsh-completions $HOME/.zsh/plugins/completions
  git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions $HOME/.zsh/plugins/autosuggestions
}

copyrc() {
  # wget
  wget https://raw.githubusercontent.com/ueno-t/.dotfiles/refs/heads/master/.zshrc -O ~/.zshrc
  wget https://raw.githubusercontent.com/ueno-t/.dotfiles/refs/heads/master/.dircolors -O ~/.dircolors
}

chsh() {
  # chsh
  chsh -s $(which zsh)
}

tpm() {
  # tpm
  git clone --depth 1 https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
}

docker() {
  # add docker apt repository
  sudo apt update && sudo apt dist-upgrade
  sudo apt install -y ca-certificates curl gnupg lsb-release
  curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
  echo   "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  # install ce package
  sudo apt update
  sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
  # modify for debian
  sudo touch /etc/fstab
  # sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
}

rootless() {
  sudo systemctl disable --now docker.service docker.socket
  sudo apt -y install uidmap dbus-user-session
  curl -fsSL https://get.docker.com/rootless | sh
  export PATH=/home/$(whoami)/bin:$PATH
  export DOCKER_HOST=unix:///run/user/1000/docker.sock
  systemctl --user restart docker
  systemctl --user enable docker
}

wslconf() {
  sudo sh -c "cat > /etc/wsl.conf" <<EOF
[boot]
systemd=true
[network]
generateResolvConf=false
EOF

  sudo sh -c "cat > /etc/resolv.conf" <<EOF
nameserver 1.1.1.1
EOF
}

command=$1
[ $# -gt 0 ] && shift

case $command in
  all)          all          ;;
  decvontainer) devcontainer ;;
  rootless)     rootless     ;;
  *)            usage        ;;
esac

exit 0
