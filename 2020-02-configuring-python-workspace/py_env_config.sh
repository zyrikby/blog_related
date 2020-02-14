#!/bin/bash

PY3="3.8.1"
PY2="2.7.17"

PY3_TOOLS=( 'ansible' 'youtube-dl' 'scrapy')
PY2_TOOLS=( 'rename' )

# installing pyenv using pyenv-installer if it is not installed yet
type pyenv >/dev/null 2>&1
if [ $? -eq 1 ]; then
    echo "Cannot find pyenv tool. Installing it!"
    echo "Make sure all prerequisitues are met!"
    curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash
    echo '' >> ~/.bashrc
    echo 'export PATH="${HOME}/.pyenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
    
    export PATH="${HOME}/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
else
    echo "pyenv is found! Updating it!"
    pyenv update
fi

echo "Installing Python Interpreters..."
echo "Installing $PY3 ..."
pyenv install $PY3
echo "Installing $PY2 ..."
pyenv install $PY2


echo "Configuring global environments..."
pyenv virtualenv $PY3 jupyter
pyenv virtualenv $PY3 tools3
pyenv virtualenv $PY2 ipython2
pyenv virtualenv $PY2 tools2

echo "Configuring jupyter environment..."
pyenv activate jupyter
pip install --upgrade pip
pip install jupyter
pip install jupyterlab
python -m ipykernel install --user
pip install ipywidgets
jupyter nbextension enable --py widgetsnbextension --sys-prefix
pyenv deactivate

echo "Configuring ipython2 environment..."
pyenv activate ipython2
pip install --upgrade pip
pip install ipykernel
python -m ipykernel install --user
pyenv deactivate

echo "Installing Python 3 tools..."
pyenv activate tools3
pip install --upgrade pip
pip install ${PY3_TOOLS[@]}
pyenv deactivate

echo "Installing Python 2 tools..."
pyenv activate tools2
pip install --upgrade pip
pip install ${PY2_TOOLS[@]}
pyenv deactivate

echo "Setting pyenv global..."
pyenv global $PY3 $PY2 jupyter ipython2 tools3 tools2

echo "Updateing ipython startup scripts to include virtual environment packages..."
ipython profile create
curl -L http://hbn.link/hb-ipython-startup-script > ~/.ipython/profile_default/startup/00-venv-sitepackages.py

echo "Updating pip and installing virtualenv..."
pip install --upgrade pip
pip install virtualenv

echo "Done..."