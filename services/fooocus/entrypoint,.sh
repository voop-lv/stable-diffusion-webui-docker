#!/bin/bash

python3 -m venv fooocus_env
source fooocus_env/bin/activate
pip install -r requirements_versions.txt

source fooocus_env/bin/activate
python entry_with_update.py ${CLI_ARGS}