project('terminus',['c','vala'])

GTK_3_20 = (get_option('GTK_3_20') != '')

add_global_arguments('-DGETTEXT_PACKAGE="terminus"',language: 'c')

gdk_3_0_dep = dependency('gdk-3.0')
gtk_3_0_dep = dependency('gtk+-3.0')
gee_0_8_dep = dependency('gee-0.8')
gio_2_0_dep = dependency('gio-2.0')
glib_2_0_dep = dependency('glib-2.0')
gobject_2_0_dep = dependency('gobject-2.0')
keybinder_3_0_dep = dependency('keybinder-3.0')
vte_2_91_dep = dependency('vte-2.91')

subdir('po')
cfg_dbus_data = configuration_data()
cfg_dbus_data.set ('DBUS_PREFIX',get_option('prefix'))
meson.add_install_script(join_paths(meson.current_source_dir(),'meson_scripts','install_data.sh'),join_paths(get_option('prefix'),'share/gnome-shell/extensions/showTerminusQuakeWindow@rastersoft.com'),join_paths(meson.current_source_dir(),'terminus_gnome_shell','extension.js'))

meson.add_install_script(join_paths(meson.current_source_dir(),'meson_scripts','install_data.sh'),join_paths(get_option('prefix'),'share/gnome-shell/extensions/showTerminusQuakeWindow@rastersoft.com'),join_paths(meson.current_source_dir(),'terminus_gnome_shell','metadata.json'))

extras_gresource_xml_generator = generator(find_program('glib-compile-resources'), arguments: [ '--sourcedir=@SOURCE_DIR@/data' , '--generate-source', '--target=@BUILD_DIR@/extras.gresource.xml.c', '@INPUT@'], output: '@PLAINNAME@.c')

extras_gresource_xml_file_c = extras_gresource_xml_generator.process(['data/extras.gresource.xml'])

meson.add_install_script(join_paths(meson.current_source_dir(),'meson_scripts','install_data.sh'),join_paths(get_option('prefix'),get_option('datadir'),'terminus'),join_paths(meson.current_source_dir(),'data/local','','*'))

meson.add_install_script(join_paths(meson.current_source_dir(),'meson_scripts','install_data.sh'),join_paths(get_option('prefix'),get_option('datadir'),'doc','terminus'),join_paths(meson.current_source_dir(),'doc','','*'))

installfile_1 = files('data/terminus_showhide')
install_data(installfile_1, install_dir: get_option('bindir'))
install_data('data/terminus.desktop',install_dir:join_paths(get_option('prefix'),get_option('datadir'),'applications'))
if (get_option('prefix').startswith('/home/'))
	message('[33mAutostart file data/terminus_autorun.desktop will not be installed. You must create your own .desktop file and put it at ~/.config/autostart[39m')
else
	install_data('data/terminus_autorun.desktop',install_dir: '/etc/xdg/autostart')
endif
dbus_cfg_com_rastersoft_terminus_service_base = configure_file(input: 'data/dbus/com.rastersoft.terminus.service.base',output: 'com.rastersoft.terminus.service', configuration: cfg_dbus_data)
install_data(dbus_cfg_com_rastersoft_terminus_service_base,install_dir: join_paths(get_option('prefix'),get_option('datadir'),'dbus-1','services'))
install_data('data/org.rastersoft.terminus.gschema.xml', install_dir: join_paths(get_option('prefix'),get_option('datadir'), 'glib-2.0', 'schemas'))
meson.add_install_script('meson_scripts/install_schemas.py')
install_data('data/icons/terminus.svg',install_dir: join_paths(get_option('prefix'),get_option('datadir'),'icons','hicolor/scalable/apps'))
subdir('src')
