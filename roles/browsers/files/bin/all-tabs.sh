#!/usr/bin/bash

bt activate $(bt list | float fzf | awk '{print $1}')
