# dotfiles

## Usage:
- sudo apt update && sudo apt upgrade -y && sudo apt install -y wget
- bash -c "$(wget -O - https://raw.github.com/ueno-t/.dotfiles/master/install.sh)" -s all
- sudo cp -r /mnt/c/Users/%HOMEPATH%/.ssh ~/ && sudo chown -R \$(whoami):\$(whoami) ~/.ssh
- chsh -s $(which zsh)
