#!/bin/bash
[ -z $VER ] && echo "$0 is a helper file" && exit 1

hosttools_build() {
  [ "$BUILD_HOST" = "true" ] && return 0
  [ -z "$FORK" ] && echo -ne "  \E[33mBuilding host version of $CONFIG\E[0m"

  [ ! -f "$DIR_HOST/$CONFIG" ] && echo build_section $CONFIG
}

hosttools_path() {
  local i=0

  echo -n "$DIR_HOST"

  while [ -e "$DIR_HOST/$i" ]; do
    echo -n ":$DIR_HOST/$i"

    i=$[$i+1]
  done
}

hosttools_symlink() {
  rm -rf "$DIR_HOST/$TARGET*" 2>&1 >/dev/null

  # Create symlinks to the host toolchain.  We need a usable existing host
  # toolchain in order to build anything else (even a new host toolchain),
  # and we don't really want to have to care what the host type is, so
  # just use the toolchain that's already there.

  # This is a little more complicated than it needs to be, because the host
  # toolchain may be using ccache and/or distcc, which means we need every
  # instance of these tools that occurs in the $PATH, in order, each in its
  # own fallback directory.

  for x in ar as nm cc make ld gcc $HOST_EXTRA; do
    local i=0

    if [ ! -f "$DIR_HOST/$i/$x" ]; then
      # Loop through each instance, populating fallback directories.
      PATH="$SAVEPATH" "$DIR_HOST/which" -a "$x" | while read xx; do
        if [ ! -e "$DIR_HOST/$i/$x" ]; then
          mkdir -p "$DIR_HOST/$i" &&
          ln -sf "$xx" "$DIR_HOST/$i/$x" || show_error "unable to link $xx to $DIR_HOST/$i/$x" help
        fi

        i=$[$i+1]
      done

      if [ ! -f "$DIR_HOST/0/$x" ]; then
        show_error "Toolchain component missing: $x" help
      fi
    fi
  done

  # Workaround for a bug in Ubuntu 10.04 where gcc became a perl script calling
  # gcc.real.  Systems that aren't crazy don't need this.

  UBUNTU_GCC="$(PATH="$SAVEPATH" "$DIR_HOST/which" gcc.real)"
  [ -n "$UBUNTU_GCC" ] && ln -s "$UBUNTU_GCC" "$DIR_HOST/gcc.real" 2>/dev/null
}
