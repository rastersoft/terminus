Name: terminus
Version: 0.11.0
Release: 1
License: Unknown/not set
Summary: A new terminal for XWindows

BuildRequires: gcc
BuildRequires: gcc-c++
BuildRequires: vala
BuildRequires: glibc-headers
BuildRequires: atk-devel
BuildRequires: cairo-devel
BuildRequires: gtk3-devel
BuildRequires: gdk-pixbuf2-devel
BuildRequires: libgee-devel
BuildRequires: glib2-devel
BuildRequires: keybinder3-devel
BuildRequires: pango-devel
BuildRequires: vte291-devel
BuildRequires: libX11-devel
BuildRequires: cmake
BuildRequires: gettext
BuildRequires: pkgconfig
BuildRequires: make
BuildRequires: intltool

Requires: atk
Requires: glib2
Requires: cairo
Requires: gtk3
Requires: pango
Requires: gdk-pixbuf2
Requires: cairo-gobject
Requires: libgee
Requires: keybinder3
Requires: vte291
Requires: zlib
Requires: gnutls
Requires: libX11

%description
A new terminal for XWindows
.

%files
*

%build
mkdir -p ${RPM_BUILD_DIR}
cd ${RPM_BUILD_DIR}; cmake -DCMAKE_INSTALL_PREFIX=/usr -DGSETTINGS_COMPILE=OFF -DICON_UPDATE=OFF ../..
make -C ${RPM_BUILD_DIR}

%install
make install -C ${RPM_BUILD_DIR} DESTDIR=%{buildroot}

%post
glib-compile-schemas /usr/share/glib-2.0/schemas

%postun
glib-compile-schemas /usr/share/glib-2.0/schemas

%clean
rm -rf %{buildroot}

