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
  download
  deploy
  init
  docker
EOF
  exit 1
}

all() {
  download
  deploy
  initialize
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
  sudo apt install -y git zsh vim tmux universal-ctags curl
  # tpm
  git clone https://github.com/tmux-plugins/tpm $HOME/.tmux/plugins/tpm
  # ping
  sudo chmod u+s /bin/ping
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
  sudo update-alternatives --set iptables /usr/sbin/iptables-legacy
  # add docker group
  sudo usermod -aG docker $(whoami)
  # register docker service to windows startup
  schtasks.exe /create /tn DockerStart /sc onlogon /tr "'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' -Command \"wsl -d Debian -u root -- service docker start\""
}
command=$1
[ $# -gt 0 ] && shift

case $command in
  all)
    all
    ;;
  download)
    download
    ;;
  deploy)
    deploy
    ;;
  init)
    initialize
    ;;
  docker)
    docker
    ;;
  *)
    usage
    ;;
esac

exit 0
