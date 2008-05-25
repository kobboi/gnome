# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/gnome-extra/gnome-screensaver/gnome-screensaver-2.22.2.ebuild,v 1.1 2008/04/10 23:29:16 eva Exp $

inherit eutils gnome2

DESCRIPTION="Replaces xscreensaver, integrating with the desktop."
HOMEPAGE="http://live.gnome.org/GnomeScreensaver"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~hppa ~ia64 ~ppc ~ppc64 ~sparc ~x86 ~x86-fbsd"
KERNEL_IUSE="kernel_linux"
IUSE="debug doc libnotify opengl pam $KERNEL_IUSE"

RDEPEND=">=x11-libs/gtk+-2.11.5
		 >=dev-libs/dbus-glib-0.71
		 >=gnome-base/gconf-2.6.1
		 >=gnome-base/gnome-desktop-2.23.2
		 >=gnome-base/gnome-menus-2.12
		 >=gnome-base/libglade-2.5.0
		 >=dev-libs/glib-2.15
		 >=gnome-base/libgnomekbd-0.1
		 x11-libs/libXrandr
		 x11-libs/libXxf86vm
		 x11-libs/libXxf86misc
		 x11-libs/libXScrnSaver
		 libnotify? ( x11-libs/libnotify )
		 opengl? ( virtual/opengl )
		 pam? ( virtual/pam )
		 !pam? ( kernel_linux? ( sys-apps/shadow ) )"
DEPEND="${RDEPEND}
		>=dev-util/pkgconfig-0.9
		>=dev-util/intltool-0.35
		doc? (
				app-text/xmlto
				~app-text/docbook-xml-dtd-4.1.2
				~app-text/docbook-xml-dtd-4.4.0
			 )"

DOCS="AUTHORS ChangeLog HACKING NEWS README TODO"

pkg_setup() {
	G2CONF="${G2CONF}
			$(use_enable doc dockbook-docs)
			$(use_enable debug)
			$(use_with libnotify)
			$(use_with opengl libgl)
			$(use_enable pam)
			--enable-locking
			--with-xf86gamma-ext
			--with-kbd-layout-indicator
			--with-gdm-config=/usr/share/gdm/defaults.conf
			--with-xscreensaverdir=/usr/share/xscreensaver/config
			--with-xscreensaverhackdir=/usr/lib/misc/xscreensaver"
}

src_install() {
	gnome2_src_install

	# Install the conversion script in the documentation
	dodoc "${S}/data/migrate-xscreensaver-config.sh"
	dodoc "${S}/data/xscreensaver-config.xsl"

	# Conversion information
	sed -e "s:\${PF}:${PF}:" \
		< "${FILESDIR}/xss-conversion-2.txt" > "${S}/xss-conversion.txt"

	dodoc "${S}/xss-conversion.txt"

	# Non PAM users will need this suid to read the password hashes.
	# OpenPAM users will probably need this too when
	# http://bugzilla.gnome.org/show_bug.cgi?id=370847
	# is fixed.
	if ! use pam ; then
		fperms u+s /usr/libexec/gnome-screensaver-dialog
	fi
}

pkg_postinst() {
	gnome2_pkg_postinst

	if has_version x11-misc/xscreensaver ; then
		ewarn "You have xscreensaver installed, you probably want to disable it."
		ewarn "To prevent a duplicate screensaver entry in the menu, you need to"
		ewarn "build xscreensaver with -gnome in the USE flags."
		ewarn "echo \"x11-misc/xscreensaver -gnome\" >> /etc/portage/package.use"

		echo
	fi

	elog "Information for converting screensavers is located in "
	elog "/usr/share/doc/${PF}/xss-conversion.txt.${PORTAGE_COMPRESS}"
}
