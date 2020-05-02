#!/bin/bash

set -e
set -o pipefail

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
G_REPO_ROOT="$SCRIPT_DIR"

help-msg () {
  msg-info "
    This script setups up your computer to run the tracker code.
  "
}

source "$G_REPO_ROOT/scripting_functions.sh"

get_os () {
  if uname -a | grep -q -i ubuntu; then
    echo "ubuntu"
  elif cat /etc/issue | grep -q -i ubuntu; then
    echo "ubuntu"
  else
    if [[ "$OSTYPE" == darwin* ]]; then
      echo "osx"
    else
      if [[ -f /etc/redhat-release ]]; then
        echo "redhat"
      else
        msg-error "Unknown OS" 1>&2;
        return 1
      fi
    fi
  fi
}
OSNAME=`get_os`

find_it_quick () {
  FILENAME="$1"
  shift
  while (( $# >= 1 )); do
    echo-err $1
    if [[ -d "$1" ]]; then
      REAL_SEARCHPATH=`realpath "$1"`
      FOUND_LIST=`find "$REAL_SEARCHPATH" -maxdepth 4 -name "$FILENAME"`
      if [[ "$FOUND_LIST" != "" ]]; then
        echo "$FOUND_LIST" | head -n 1
        return
      fi
    fi
    shift
  done
  return 1
}

setup_global_properties () {
  echo "
    G_HOME=$HOME
    G_REPO_ROOT=$G_REPO_ROOT

    G_SRC_ROOT=${G_REPO_ROOT}/tracker
    G_TEST_ROOT=${G_REPO_ROOT}/tracker/test

    G_PYTHON_EXE=$HOME/.virtualenvs/tracker/bin/python
    G_PYTHONPATH=${G_REPO_ROOT}/tracker

    G_SYNC_DIR=$HOME/sync
    G_DB_PATH=$HOME/sync/tracker.db
  " | sed -E 's/^ +//' | tee "$G_REPO_ROOT/tracker/config/global.properties"
}

command_exists () {
  if command -v "$1" &> /dev/null; then
    return 0;
  else
    return 1;
  fi
}

install_prereqs_ubuntu () {
  sudo apt install -y python3 python3-venv sqlite3
}

install_external_dependencies () {
  if [[ "$OSNAME" == "ubuntu" ]]; then
    log-8601 "Ubuntu detected, installing packages."
    install_prereqs_ubuntu
  else
    msg-error "Unknown OS"
    return 1
  fi
}

log-8601 "This script should help you get started with using this repo."
log-8601 "First, let's check all of our dependencies here."

install_external_dependencies

log-8601 "Checking python virtualenv"
mkdir -p "$HOME/.virtualenvs"
if ! [[ -d "$HOME/.virtualenvs/tracker" ]]; then
  msg-info "Sorry, just gotta make the virtualenv here"
  if command_exists python3.7 && python3.7 -m venv ~/.virtualenvs/tracker; then
    msg-success "Successfully created the python virtualenv"
  elif command_exists python3.6 && python3.6 -m venv ~/.virtualenvs/tracker; then
    msg-success "Successfully created the python virtualenv"
  elif python3 -m venv ~/.virtualenvs/tracker; then
    msg-success "Successfully created the python virtualenv"
  else
    msg-error "
      Failed to create the virtualenv, you must install python 3.6+, try:
        sudo apt install python3-venv
    "
    exit 1
  fi
fi

log-8601 "Checking activation script"
if ! [[ -f "$HOME/.virtualenvs/tracker/bin/activate" ]]; then
  msg-error "Missing activate script, issue with python virtualenv"
  exit 1
fi

log-8601 "Checking for PYTHONPATH export"
if grep "export PYTHONPATH='$G_REPO_ROOT/tracker'" "$HOME/.virtualenvs/tracker/bin/activate"; then
  msg-success "PYTHONPATH is set"
else
  msg-info "Adding PYTHONPATH"
  echo "
    export PYTHONPATH='$G_REPO_ROOT/tracker'
  " >> "$HOME/.virtualenvs/tracker/bin/activate"
fi

log-8601 "Sourcing python virtualenv"
. "$HOME/.virtualenvs/tracker/bin/activate"

log-8601 "Checking python dependencies"
pip install wheel

cd "$G_REPO_ROOT"
CURRENT_PACKAGES=`pip freeze`
REQUIREMENTS=`cat "$G_REPO_ROOT/requirements.txt"`
if [[ "$CURRENT_PACKAGES" != "$REQUIREMENTS" ]]; then
  log-8601 "Installing all dependencies"
  pip install -r "$G_REPO_ROOT/requirements.txt"
  if EXTRA_PACKAGES=`pip freeze | grep -v -f "$G_REPO_ROOT/requirements.txt"`; then
    log-8601 "Removing all non-dependencies"
    echo "$EXTRA_PACKAGES" | xargs pip uninstall -y
  fi
else
  msg-success "All required pip packages are installed"
fi

log-8601 "Lets make sure all of your templates are set up"
if ! [[ -f "$G_REPO_ROOT/tracker/config/global.properties" ]]; then
  setup_global_properties
else
  msg-success "You already have a global.properties file"
fi

source "$G_REPO_ROOT/tracker/config/global.properties"

#if ! [[ -f "$G_SYNC_DIR/tracker.db" ]]; then
#  log-8601 "Creating sqlite db"
#  alembic upgrade head
#else
#  log-8601 "Upgrading sqlite db if necessary"
#  alembic upgrade head
#fi

msg-success "You're all done!"
