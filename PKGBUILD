pkgname=terminus
pkgver=0.11.0
pkgrel=1
pkgdesc="A new terminal for XWindows
"
arch=('i686' 'x86_64')
depends=( 'atk' 'glib2' 'cairo' 'gtk3' 'pango' 'gdk-pixbuf2' 'libgee' 'libkeybinder3' 'vte3' 'zlib' 'gnutls' 'libx11' )
makedepends=( 'vala' 'glibc' 'atk' 'cairo' 'gtk3' 'gdk-pixbuf2' 'libgee' 'glib2' 'libkeybinder3' 'pango' 'vte3' 'libx11' 'cmake' 'gettext' 'pkg-config' 'gcc' 'make' 'intltool' )
build() {
	rm -rf ${startdir}/install
	mkdir ${startdir}/install
	cd ${startdir}/install
	cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_INSTALL_LIBDIR=/usr/lib
	make -j1
}

package() {
	cd ${startdir}/install
	make DESTDIR="$pkgdir/" install
}
