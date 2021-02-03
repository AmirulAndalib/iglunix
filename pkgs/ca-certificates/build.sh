pkgname=ca-certificates
pkgver=202200601
pkgrel=2

fetch(){
        curl http://ftp.debian.org/debian/pool/main/c/ca-certificates/ca-certificates_20200601~deb10u2.tar.xz -o $pkgname-$pkgver.tar.gz
        tar -xf $pkgname-$pkgver.tar.gz
}


build() {
	cd work
	make
}

package() {
	mkdir build
	mkdir -p build/usr/bin
	mkdir -p build/usr/sbin
	mkdir -p build/etc/ssl/
	mkdir -p build/usr/share/ca-certificates
	
	make install DESTDIR="$pkgdir/build"

	(
		echo "# Automatically generated by ${pkgname}-${pkgver}-${pkgrel}"
		echo "# $(date -u)"
		echo "# Do not edit."
		cd "$pkgdir"/usr/share/ca-certificates
		find . -name '*.crt' | sort | cut -b3-
	) > "$pkgdir/build"/etc/ca-certificates.conf

	cat > "$pkgdir/build"/etc/ca-certificates/update.d/certhash <<-EOF
		#!/bin/sh
		exec /usr/bin/c_rehash /etc/ssl/certs
	EOF
	
	cat "$pkgdir/build"/usr/share/ca-certificates/mozilla/*.crt > $pkgdir/build/etc/ssl/cert.pem
	chmod +x "$pkgdir/build"/etc/ca-certificates/update.d/certhash
	mv -v ${pkgdir}/build/usr/sbin/* ${pkgdir}/build/usr/bin/
	rm -rf ${pkgdir}/build/usr/sbin
}