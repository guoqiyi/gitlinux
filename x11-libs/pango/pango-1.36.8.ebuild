# Copyright 1999-2015 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/pango/pango-1.36.8.ebuild,v 1.11 2015/03/03 11:48:31 dlan Exp $

EAPI="5"
GCONF_DEBUG="yes"
GNOME2_LA_PUNT="yes"

inherit gnome2 multilib toolchain-funcs multilib-minimal

DESCRIPTION="Internationalized text layout and rendering library"
HOMEPAGE="http://www.pango.org/"

LICENSE="LGPL-2+ FTL"
SLOT="0"
KEYWORDS="alpha amd64 arm ~arm64 hppa ia64 ~mips ppc ppc64 ~s390 ~sh sparc x86 ~amd64-fbsd ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~arm-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~x64-solaris ~x86-solaris"

IUSE="gtk-doc +introspection usr-doc X"

RDEPEND="
	>=media-libs/harfbuzz-0.9.12:=[glib(+),truetype(+),${MULTILIB_USEDEP}]
	>=dev-libs/glib-2.34.3:2[${MULTILIB_USEDEP}]
	>=media-libs/fontconfig-2.10.92:1.0=[${MULTILIB_USEDEP}]
	>=media-libs/freetype-2.5.0.1:2=[${MULTILIB_USEDEP}]
	>=x11-libs/cairo-1.12.14-r4:=[X?,${MULTILIB_USEDEP}]
	introspection? ( >=dev-libs/gobject-introspection-0.9.5 )
	X? (
		>=x11-libs/libXrender-0.9.8[${MULTILIB_USEDEP}]
		>=x11-libs/libX11-1.6.2[${MULTILIB_USEDEP}]
		>=x11-libs/libXft-2.3.1-r1[${MULTILIB_USEDEP}]
	)
	abi_x86_32? (
		!<=app-emulation/emul-linux-x86-gtklibs-20131008-r3
		!app-emulation/emul-linux-x86-gtklibs[-abi_x86_32(-)]
	)
"
DEPEND="${RDEPEND}
	>=dev-util/gtk-doc-am-1.20
	virtual/pkgconfig
	X? ( >=x11-proto/xproto-7.0.24[${MULTILIB_USEDEP}] )
	!<=sys-devel/autoconf-2.63:2.5
"

MULTILIB_CHOST_TOOLS=(
	/usr/bin/pango-querymodules
)

multilib_src_configure() {
	tc-export CXX

	ECONF_SOURCE=${S} \
	gnome2_src_configure \
		--with-cairo \
		$(multilib_native_use_enable introspection) \
		$(use_with X xft) \
		"$(usex X --x-includes="${EPREFIX}/usr/include" "")" \
		"$(usex X --x-libraries="${EPREFIX}/usr/$(get_libdir)" "")"

	if multilib_is_native_abi; then
		ln -s "${S}"/docs/html docs/html || die
	fi
}

multilib_src_install() {
	gnome2_src_install
	use gtk-doc || rm -rf "${ED}"/usr/share/gtk-doc || die
	use usr-doc || rm -rf "${ED}"/usr/share/doc || die
}

multilib_src_install_all() {
	dodoc AUTHORS ChangeLog NEWS README THANKS

	if ! use usr-doc ; then
		rm -rf "${ED}"/usr/share/doc || die
	fi
}

pkg_postinst() {
	gnome2_pkg_postinst

	multilib_pkg_postinst() {
		einfo "Generating modules listing..."
		"${CHOST}-pango-querymodules" --update-cache

		# Remove old autogenerated file to prevent collisions with newer
		rm -f "${EROOT}/etc/pango/${CHOST}/pango.modules"
	}

	multilib_foreach_abi multilib_pkg_postinst
}
