#!/bin/bash

set -eux

SOURCE_DIR=$1

tar -xvzf $SOURCE_DIR/openmpi-4.0.2.tar.gz
mv openmpi-4.0.2/* .
