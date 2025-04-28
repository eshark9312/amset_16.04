#!/bin/bash

## to extract the multipart tar file
cat miniconda* | tar -xvzf -

exit 0

## to zip into multipart files 
tar -czvf - Miniconda3.sh | split -b 50M - miniconda.tar.gz.part-
