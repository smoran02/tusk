#!/bin/sh
# From https://askubuntu.com/questions/35956/how-to-determine-the-size-of-a-package-while-using-apt-prior-to-downloading
# Doesn't handle dependencies
packages=$*
apt-cache --no-all-versions show $packages | 
    awk '$1 == "Package:" { p = $2 }
         $1 == "Size:"    { printf("%10d KB %s\n", $2 / 1024, p) }'
