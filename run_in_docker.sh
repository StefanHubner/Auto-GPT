#!/bin/bash

docker compose run -v $PWD/workdir:/home/appuser/auto_gpt_workspace --rm auto-gpt --gpt3only
