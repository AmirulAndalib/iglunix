#!/bin/sh
export MAKEFLAGS="-j6"
export CC=clang
export CXX=clang++

. ./build.sh
dir=$(pwd)
stat out > /dev/null && rm -rf out
mkdir out

function do_fetch() {
	mkdir -p src
	cd src
	srcdir=$(pwd) fetch
}

stat src > /dev/null 2>/dev/null || do_fetch
srcdir=$(pwd)/src

cd $srcdir

build
cd $srcdir

echo "
. $dir/build.sh
mkdir -p $dir/out/$pkgname
pkgdir=$dir/out/$pkgname package


mkdir -p $dir/out/$pkgname/usr/share/lazypkg

cat > $dir/out/$pkgname/usr/share/lazypkg/$pkgname << EOF
[pkg]
name=$pkgname
ver=$pkgver

[license]
EOF

chmod 644 $dir/out/$pkgname/usr/share/lazypkg/$pkgname
cd $srcdir
license >> $dir/out/$pkgname/usr/share/lazypkg/$pkgname

echo >> $dir/out/$pkgname/usr/share/lazypkg/$pkgname
echo [fs] >> $dir/out/$pkgname/usr/share/lazypkg/$pkgname

cd $dir/out/$pkgname/
find * >> $dir/out/$pkgname/usr/share/lazypkg/$pkgname

cd $dir/out/$pkgname
tar -cf ../$pkgname.$pkgver.tar.xz *

echo $ext | tr ':' '\n' | while read e; do
	echo \$e

    cd $srcdir
    mkdir -p $dir/out/$pkgname-\$e
    pkgdir=$dir/out/$pkgname-\$e

    package_\$(echo \$e | tr '-' '_')

    mkdir -p $dir/out/$pkgname-\$e/usr/share/lazypkg

    cat > $dir/out/$pkgname-\$e/usr/share/lazypkg/$pkgname-\$e << EOF
[pkg]
name=$pkgname-\$e
ver=$pkgver

[license]
EOF

    chmod 644 $dir/out/$pkgname-\$e/usr/share/lazypkg/$pkgname-\$e
    cd $srcdir
    license >> $dir/out/$pkgname-\$e/usr/share/lazypkg/$pkgname-\$e

    echo >> $dir/out/$pkgname-\$e/usr/share/lazypkg/$pkgname-\$e
    echo [fs] >> $dir/out/$pkgname-\$e/usr/share/lazypkg/$pkgname-\$e

    cd $dir/out/$pkgname-\$e

    find * >> $dir/out/$pkgname-\$e/usr/share/lazypkg/$pkgname-\$e

    cd $dir/out/$pkgname-\$e
    tar -cf ../$pkgname-\$e.$pkgver.tar.xz *

done


" | sh
cd $dir