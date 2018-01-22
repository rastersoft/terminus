cfg_terminus = configuration_data()
cfg_terminus.set('DATADIR', join_paths(get_option('prefix'),get_option('datadir')))
cfg_terminus.set('PKGDATADIR', join_paths(get_option('prefix'),get_option('datadir'),'terminus'))
cfg_terminus.set('GETTEXT_PACKAGE', 'terminus')
cfg_terminus.set('RELEASE_NAME', 'terminus')
cfg_terminus.set('PREFIX', get_option('prefix'))
cfg_terminus.set('VERSION', '0.10.0')
cfg_terminus.set('TESTSRCDIR', meson.source_root())

cfgfile_2 = configure_file(input: 'Config.vala.base',output: 'Config.vala',configuration: cfg_terminus)

terminus_deps = [gdk_3_0_dep]
terminus_deps += [gtk_3_0_dep]
terminus_deps += [gee_0_8_dep]
terminus_deps += [gio_2_0_dep]
terminus_deps += [glib_2_0_dep]
terminus_deps += [gobject_2_0_dep]
terminus_deps += [keybinder_3_0_dep]
terminus_deps += [vte_2_91_dep]
terminus_sources = [cfgfile_2]
terminus_sources += ['PanedPercentage.vala']
terminus_sources += ['base.vala']
terminus_sources += ['bindkeys.vala']
terminus_sources += ['container.vala']
terminus_sources += ['notetab.vala']
terminus_sources += ['settings.vala']
terminus_sources += ['terminal.vala']
terminus_sources += ['terminus.vala']
terminus_sources += ['window.vala']
terminus_sources += ['checkwayland.c']
terminus_sources += [extras_gresource_xml_file_c]
terminus_sources += [join_paths(meson.source_root(),'checkwayland.vapi')]
terminus_vala_args = ['--pkg','posix']
terminus_vala_args += ['--vapidir='+join_paths(meson.source_root(),'src/vapidir')]
terminus_vala_args += ['--gresources='+join_paths(meson.source_root(),'data/extras.gresource.xml')]
terminus_c_args = []
if GTK_3_20
  terminus_vala_args += ['-D', 'GTK_3_20']
  terminus_c_args += ['-DGTK_3_20']
endif

executable('terminus',terminus_sources,dependencies: terminus_deps,vala_args: terminus_vala_args,c_args: terminus_c_args,install: true)

