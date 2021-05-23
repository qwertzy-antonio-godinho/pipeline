#! /bin/bash

sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt clean
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"
sudo apt install -y apt-transport-https ca-certificates curl wget software-properties-common build-essential make git docker-ce python3 python3-venv python3-pip python-is-python3 libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm libncursesw5-dev xz-utils libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
wget https://github.com/nestybox/sysbox/releases/download/v0.3.0/sysbox-ce_0.3.0-0.ubuntu-focal_amd64.deb
sudo apt-get install ./sysbox-ce_0.3.0-0.ubuntu-focal_amd64.deb -y
sudo sh -c 'cat <<-EOF > "/etc/docker/daemon.json"
{
  "default-runtime": "sysbox-runc",
  "runtimes": {
     "sysbox-runc": {
        "path": "/usr/local/sbin/sysbox-runc"
     }
  }
}
EOF'
rm -rf ./sysbox-ce_0.3.0-0.ubuntu-focal_amd64.deb
sudo systemctl restart docker
printf 'export PATH="$HOME/.local/bin:$PATH"\n' >> ~/.bashrc
curl -L https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer | bash
printf 'export PYENV_ROOT="$HOME/.pyenv"\nexport PATH="$PYENV_ROOT/bin:$PATH"\neval "$(pyenv init --path)"\n' >> ~/.bashrc
python3 -m pip install --user pipx pipenv tox docker-compose
sudo usermod -aG docker ${USER}
exec $SHELL