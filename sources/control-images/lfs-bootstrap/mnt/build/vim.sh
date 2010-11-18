#!/bin/sh

sed -i '$a #define SYS_VIMRC_FILE "/etc/vimrc"' src/feature.h &&

./configure --prefix=/usr --enable-multibyte &&
make -j $CPUS || exit 1

if [ ! -z "$CHECK" ]
then
  make test || exit 1
fi

make install &&
ln -s vim /usr/bin/vi || exit 1
for i in /usr/share/man/man1/vim.l /usr/share/man/*/man1/vim.l
do
  ln -sf vim.1 $(dirname $i)/vi.l || exit 1
done

cat > /etc/vimrc << "EOF"
set nocompatible
set backspace=2
syntax on
if (&term == "iterm") || (&term == "putty")
  set background=dark
endif
EOF
