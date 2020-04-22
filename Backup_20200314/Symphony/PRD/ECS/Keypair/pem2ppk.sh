#! /bin/bash

## pem to ppk: puttygen pemKey.pem -o ppkKey.ppk -O private
## ppk to pem: puttygen ppkkey.ppk -O private-openssh -o pemkey.pem

WARN="\e[93mWarning:\e[39m"
INFO="\e[96mINFO:\e[39m"
SUCCESS="\e[92mSuccess.\e[39m"
FAILED="\e[91mFailed.\e[39m"

_exit () {
  [ $? -ne 0 ] && exit 1
}

_status () {
  if [ $? -eq 0 ]
  then
    echo -e $SUCCESS
    return 0
  else
    echo -e $FAILED
    return 1
  fi
}

_file_validate () {
  [ -f $1 ] && retrun 0 || return 1
}

PEM_FILE=$1
PEM_FILE_PREFIX=`echo $PEM_FILE |awk -F. '{print $1}'`
PEM_FILE_SUFIX=`echo $PEM_FILE |awk -F. '{print $2}'`

echo -e "$INFO Validating PEM RSA Private key ... \c"
FILE_INFO=`file $PEM_FILE |awk -F: '{print $2}'`
[ " PEM RSA private key" == "$FILE_INFO" ]
_status
_exit

echo -e "$INFO Converting PEM to PPK ... \c"
puttygen $PEM_FILE -o $PEM_FILE_PREFIX.ppk -O private >/dev/null 2>&1
_status
_exit

chmod 400 $PEM_FILE_PREFIX.ppk
