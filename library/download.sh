#!/bin/bash
[ -z $VER ] && echo "$0 is a helper file" && exit 1

download_packages() {
  [ -n "$FORK" ] && [ -n "$PACKAGES" ] && echo -ne "  \E[33mPackages ${PACKAGES[@]}\E[0m\n"
  [ -z "$URL" ] && return 0

  local FILENAME="$(basename $URL)"
  local FILEPATH="$DIR_CODE/$FILENAME"

  download_checksum $FILEPATH $SHA1 && return 0

  [ -z "$FORK" ] && tput sc
  [ -z "$FORK" ] && echo -ne "  \E[33mDownloading $CONFIG from $URL\E[0m"
  wget  --quiet -t 2 -T 20 -O "$FILEPATH" "$URL" > /dev/null || (rm -f "$FILEPATH"; return 500)
  [ -z "$FORK" ] && tput rc
  [ -z "$FORK" ] && tput ed

  download_checksum $FILEPATH $SHA1 && return 0

  echo -ne "  \E[1;31mFAILED VERIFICATION\E[0m - $FILEPATH\n" && exit 1
}

download_checksum() {
  [ ! -f "$1" ] && return 1

  local FILENAME="$(basename $1)"

  [ -z "$2" ] && echo -ne "  \E[1;31mCHECKSUM UNAVAILABLE\E[0;34m - $FILENAME\E[0m\n" && return 0
  [ -z "$(which sha1sum)" ] && echo -ne "  \E[1;31mCHECKSUM UNVERIFIED\E[0;34m - $FILENAME\E[0m - Install sha1sum to verify\n" $BASH_SOURCE

  local SUM="$(sha1sum "$1"  2>/dev/null | sed 's/\s.*$//')"

  [ x"$SUM" == x"$2" ] && echo -ne "  \E[1;32mDOWNLOAD VERIFIED\E[0;34m - $FILENAME\E[0m\n" && return 0

  rm -f $1

  return 1
}

