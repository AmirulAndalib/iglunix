pkgname=libinput
pkgver=1.22.1
deps="mtdev:libevdev"

fetch() {
	curl "https://gitlab.freedesktop.org/libinput/libinput/-/archive/1.22.1/libinput-$pkgver.tar.gz" -o $pkgname-$pkgver.tar.xz
	tar -xf $pkgname-$pkgver.tar.xz
	mkdir $pkgname-$pkgver/build
}

build() {
	cd $pkgname-$pkgver
	muon setup \
		-Dbuildtype=release \
		-Dprefix=/usr \
		-Dlibwacom=false \
		-Ddocumentation=false \
		-Ddebug-gui=false \
		-Dtests=false \
		build
	samu -C build
}

backup() {
	return
}

package() {
	cd $pkgname-$pkgver
	DESTDIR=$pkgdir muon -C build install
}

license() {
	cd $pkgname-$pkgver
#	cat LICENSE
	cat COPYING
}
