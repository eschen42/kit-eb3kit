#!/bin/bash
source /etc/bibbox/bibbox.cfg
if [[ "$1" = "" ]]; then
  echo "ERROR: No Instanc set to delete."
elif [[ "$1" = "*" ]]; then
  echo "ERROR: * Not allowed as parameter."
elif [[ "$1" = "/" ]]; then
  echo "ERROR: / Not allowed in the parameter String."
elif [[ "$1" = "\"" ]]; then
  echo "ERROR: / Not allowed in the parameter String."
elif [[ $# != 1 ]]; then
  echo "ERROR: Number of parameters not matching."
else
  rm -r "$bibboxdir/$bibboxinstancefolder/$1"
fi
