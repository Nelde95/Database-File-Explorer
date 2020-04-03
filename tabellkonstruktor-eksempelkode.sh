#!/bin/bash

# Dette skriptet lager en tabell med informasjon om filer i et filtre.
# (Thomas Nordli,januar 2020) 

#  - Roten til filtreet oppgis som miljøvraiabelen R, eller som
#    argument.  Dersom argumentet utelates brukes aktiv katalog som
#    rot.

if [ $# -gt 0  ]; then R=$1; fi
if [ "$R" = "" ]; then R=.;  fi
cd $R

# - find(1) brukes for å traversere treet.  Miljøvariabelen D styrer
#   hvor dypt find skal traversere filtreet

if [ "$D" != "" ]; then  D="-maxdepth $D"; fi

# - stat(1) brukes for å finne og skrive fil-info
# - xargs(1) brukes for å sende utskriften fra find(1) som 
#   argumenter til stat(1)

# Separator i utskriften kan angis med miljøvariabelen S
if [ "$S" =  "" ]; then  S=";"; fi

FORMATSTR="%a$S%D$S%F$S%g$S%G$S%h$S%i$S%m$S%n$S%o$S%s$S%u$S%U"

( find $R -print0 $D | xargs -0 stat -c $FORMATSTR ) 2> /dev/null

# Forklaring på formatstrengen, hentet fra stat(1):
#
#       %a     access rights in octal
#       %D     device number in hex
#       %F     file type
#       %g     group ID of owner
#       %G     group name of owner
#       %h     number of hard links
#       %i     inode number
#       %m     mount point
#       %n     file name
#       %o     optimal I/O transfer size hint
#       %s     total size, in bytes
#       %u     user ID of owner
#       %U     user name of owner
