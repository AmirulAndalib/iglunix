pkgver=1.2.5
pkgname=musl
subpkgs="musl musl-dev"
desc="C Standard Library"
mkdeps="bad:gmake"
bad="gmake"
ext="dev"

fetch() {
	curl "https://musl.libc.org/releases/$pkgname-$pkgver.tar.gz" -o $pkgname-$pkgver.tar.gz
	tar -xf $pkgname-$pkgver.tar.gz
	ln -s /usr/bin/cc $ARCH-linux-musl-cc
	cd $pkgname-$pkgver
}


if [ -z "$FOR_CROSS" ]; then
	PREFIX=/usr
else
	PREFIX=$FOR_CROSS_DIR
fi


build() {
	cd $pkgname-$pkgver


	CC=$(pwd)/../$ARCH-linux-musl-cc bad --gmake ./configure \
		--prefix=$PREFIX \
		--target=$TRIPLE \
		--disable-wrapper

	bad --gmake gmake
}

package() {
	cd $pkgname-$pkgver
	bad --gmake gmake DESTDIR=$pkgdir install
	rm $pkgdir/lib/ld-musl-$ARCH.so.1
	mv $pkgdir/$PREFIX/lib/libc.so $pkgdir/lib/ld-musl-$ARCH.so.1
	ln -sr $pkgdir/lib/ld-musl-$ARCH.so.1 $pkgdir/$PREFIX/lib/libc.so
	if [ -z "$FOR_CROSS" ]; then
		install -d $pkgdir/$PREFIX/bin
		ln -sr $pkgdir/lib/ld-musl-$ARCH.so.1 $pkgdir/$PREFIX/bin/ldd
	fi
}

musl() {
	shlibs=libc.so
	find lib usr/lib/libc.so
	find usr/bin
}

musl-dev() {
	find usr/include
	find usr/lib/*.a usr/lib/*.o
}

backup() {
	return
}

license() {
	cd $pkgname-$pkgver
	cat COPYRIGHT
}
