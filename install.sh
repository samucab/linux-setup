#!/bin/bash

# Set up the script to exit on errors
set -e

# Load GNOME settings
# Use 'dconf dump / > gnome-settings.dconf' to save GNOME settings
echo "Loading GNOME Settings..."
sudo apt-get install -y dconf-cli
dconf load / < gnome-settings.dconf

#############################
### Software Installation ###
#############################

# Update Package Metadata
echo "Updating Package Metadata..."
sudo apt-get update

# Install Essential Packages
echo "Installing essential packages..."
sudo apt-get install -y wget gnupg gnupg2 lsb-release \
apt-transport-https ca-certificates libxss1

# Install Command Line Tools
echo "Installing command line tools..."
sudo apt-get install -y curl git unzip tree direnv dconf-cli
# Enable direnv hook in zsh to allow environment variables from .envrc files to be loaded in the future
if ! grep -q 'direnv hook zsh' ~/.zshrc; then
  echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
fi

# Install Essential Productivity Tools
echo "Installing Gnumeric..."
sudo apt-get install -y gnumeric gnome-disk-utility \
gnome-characters simple-scan

# Install Firefox
echo "Installing Firefox..."
sudo apt-get install -y firefox

# Install Simplenote
echo "Installing Simplenote..."
wget https://github.com/Automattic/simplenote-electron/releases/download/v2.22.2/Simplenote-linux-2.22.2-amd64.deb
sudo dpkg -i Simplenote-linux-2.22.2-amd64.deb
rm Simplenote-linux-2.22.2-amd64.deb

# Install VS Code
echo "Installing VS Code..."
wget https://vscode.download.prss.microsoft.com/dbazure/download/stable/f1a4fb101478ce6ec82fe9627c43efbf9e98c813/code_1.95.3-1731513102_amd64.deb
sudo dpkg -i code_1.95.3-1731513102_amd64.deb
rm code_1.95.3-1731513102_amd64.deb

# Install VS Code Extensions
echo "Installing VS Code Extensions..."
code --install-extension ms-toolsai.datawrangler
code --install-extension cweijan.vscode-database-client2
code --install-extension cweijan.dbclient-jdbc
code --install-extension ms-azuretools.vscode-docker
code --install-extension github.copilot
code --install-extension ms-toolsai.jupyter
code --install-extension ms-toolsai.vscode-jupyter-cell-tags
code --install-extension ms-toolsai.jupyter-keymap
code --install-extension ms-toolsai.jupyter-renderers
code --install-extension ms-toolsai.vscode-jupyter-slideshow
code --install-extension ms-python.vscode-pylance
code --install-extension ms-python.python
code --install-extension ms-python.debugpy
code --install-extension KevinRose.vsc-python-indent
code --install-extension mechatroner.rainbow-csv
code --install-extension adpyke.vscode-sql-formatter
code --install-extension emmanuelbeziat.vscode-great-icons

# Install QGIS
echo "Installing QGIS..."
sudo apt-get install -y qgis

# Install Google Earth
echo "Installing Google Earth..."
wget https://dl.google.com/dl/earth/client/current/google-earth-pro-stable_current_amd64.deb
sudo dpkg -i google-earth-pro-stable_current_amd64.deb
rm google-earth-pro-stable_current_amd64.deb

# Install GitHub CLI
(type -p wget >/dev/null) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt-get update \
	&& sudo apt-get install -y gh
gh --version

# Install GCloud CLI
echo "Installing GCloud CLI..."
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
sudo apt-get update
sudo apt-get install -y google-cloud-sdk
gcloud --version

# Install pyenv and its dependencies
echo "Installing pyenv..."
git clone https://github.com/pyenv/pyenv.git ~/.pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev \
xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev python3-dev

# Install Python 3.12.6 and virtualenv
echo "Installing Python 3.12.6..."
pyenv install 3.12.6
pyenv global 3.12.6
git clone https://github.com/pyenv/pyenv-virtualenv.git "$(pyenv root)/plugins/pyenv-virtualenv"
pyenv virtualenv 3.12.6 generic
pyenv global generic
pip install --upgrade pip
python --version

# Install Docker
echo "Installing Docker..."
sudo apt-get update
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo docker --version

# Build a PostGIS container for local development
echo "Building a PostGIS container..."
sudo docker pull postgis/postgis:16-3.5
sudo docker create \
    --name local-postgis \
    -e POSTGRES_USER=admin \
    -e POSTGRES_PASSWORD=admin \
    -e POSTGRES_DB=gisdb \
    -p 5432:5432 \
    postgis/postgis:16-3.5
echo "To start the PostGIS container, run 'docker start local-postgis'"
echo "Connection parameters: host=127.0.0.1 port=5432 user=admin password=admin dbname=gisdb" 

# Upgrade Installed Packages
echo "Upgrading installed packages..."
sudo apt-get upgrade

# Remove Unused Dependencies
echo "Removing unused dependencies..."
sudo apt-get autoremove

# Clean Cached Files
echo "Cleaning cached files..."
sudo apt-get clean

# Check for Broken Dependencies
echo "Checking for broken dependencies..."
sudo apt-get --fix-broken install

echo "Software installation completed!"

############################
### System Configuration ###
############################

# Backup and Symlink Functionality
backup() {
  target=$1
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mv "$target" "$target.backup"
    echo "-----> Moved your old $target config file to $target.backup"
  fi
}

symlink() {
  file=$1
  link=$2
  if [ ! -e "$link" ]; then
    ln -s "$file" "$link"
    echo "-----> Symlinking $link"
  fi
}

# Seed dotfiles
echo "Seeding dotfiles..."
for name in gitconfig rspec zprofile zshrc; do
  target="$HOME/.$name"
  backup "$target"
  symlink "$PWD/$name" "$target"
done

# Configure zsh
echo "Configuring oh-my-zsh..."
mkdir -p ~/.ssh
chmod 700 ~/.ssh
ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"
mkdir -p "$ZSH_PLUGINS_DIR"
cd "$ZSH_PLUGINS_DIR"
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting
fi
if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions
fi

# Configure VS Code
echo "Configuring VS Code..."
CODE_PATH="$HOME/.config/Code/User"
mkdir -p "$CODE_PATH"
for name in settings.json keybindings.json; do
  target="$CODE_PATH/$name"
  backup "$target"
  symlink "$PWD/$name" "$target"
done

echo "Setup completed!"
