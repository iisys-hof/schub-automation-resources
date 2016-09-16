#!/bin/bash
source $1
heat stack-show $2 | grep output_value | awk '{print $4}' | sed -e "s/\"//g" -e "s/,//g"