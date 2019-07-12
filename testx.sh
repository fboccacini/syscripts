#!/bin/bash

HBA=$(sudo -u postgres psql -t -P format=unaligned -c 'show hba_file' 2> /dev/null)
echo $HBA

read -s WER 
echo $WER
