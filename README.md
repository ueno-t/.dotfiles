# dotfiles

## Usage:
- sudo apt update && sudo apt upgrade -y && sudo apt install -y wget
- bash -c "$(wget -O - https://raw.github.com/ueno-t/.dotfiles/master/install.sh)" -s all
- logout
- export WIN_USER
- export DOCKER_USER
- sudo cp -r /mnt/c/Users/${WIN_USER}/.ssh ~/ && sudo chown -R "$(whoami):$(whoami)" ~/.ssh && chmod 700 .ssh
- cat /mnt/c/Users/${WIN_USER}/.docker_token.txt | docker login -u ${DOCKER_USER} --password-stdin
- bash -c "$(wget -O - https://raw.github.com/ueno-t/.dotfiles/master/install.sh)" -s rootless
- cd ~/.dotfiles && git init && git remote add origin git@github.com:ueno-t/.dotfiles.git && git pull origin master
