#!/bin/bash

help="Usage: getDataset.sh [username] [LC8 | MER_FSG_1P | S2_L1C]"

if [ "$#" -eq 1 ]; then
    echo
    echo "Please enter the dataset name"
    echo
    echo $help 
    echo
    exit 0
elif [ "$#" -eq 0  ]; then
    echo
    echo "Please enter username and dataset name"
    echo
    echo $help
    echo
    exit 0
fi

wget -r --no-parent -nH --cut-dirs=2 --reject="index.html" --directory-prefix=/urbantep/eodata/ --user=$1 --ask-password "https://www.brockmann-consult.de/bc-wps/eodata/$2/"

if [ "$?" = "0" ]; then
    echo
    echo "dataset downloaded"
    echo
else
    echo
    echo "failed to download dataset"
    echo
fi
