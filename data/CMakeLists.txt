### CMakeLists automatically created with AutoVala
### Do not edit

EXECUTE_PROCESS( COMMAND glib-compile-resources --sourcedir=${CMAKE_CURRENT_SOURCE_DIR} --generate-source --target=${CMAKE_CURRENT_BINARY_DIR}/extras.gresource.xml.c ${CMAKE_CURRENT_SOURCE_DIR}/extras.gresource.xml)
EXECUTE_PROCESS( COMMAND glib-compile-resources --sourcedir=${CMAKE_CURRENT_SOURCE_DIR} --generate-header --target=${CMAKE_CURRENT_BINARY_DIR}/extras.gresource.xml.h ${CMAKE_CURRENT_SOURCE_DIR}/extras.gresource.xml)
ADD_CUSTOM_COMMAND (
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/extras.gresource.xml.c
	DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/extras.gresource.xml ${CMAKE_CURRENT_SOURCE_DIR}/pixmaps/horizontal.svg ${CMAKE_CURRENT_SOURCE_DIR}/pixmaps/vertical.svg ${CMAKE_CURRENT_SOURCE_DIR}/interface/properties.ui
	COMMAND glib-compile-resources --sourcedir=${CMAKE_CURRENT_SOURCE_DIR} --generate-source --target=${CMAKE_CURRENT_BINARY_DIR}/extras.gresource.xml.c ${CMAKE_CURRENT_SOURCE_DIR}/extras.gresource.xml

	COMMAND glib-compile-resources --sourcedir=${CMAKE_CURRENT_SOURCE_DIR} --generate-header --target=${CMAKE_CURRENT_BINARY_DIR}/extras.gresource.xml.h ${CMAKE_CURRENT_SOURCE_DIR}/extras.gresource.xml
)

add_custom_target(extras_gresource_xml DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/extras.gresource.xml.c)
SET (extras_gresource_xml_C_FILE ${CMAKE_CURRENT_BINARY_DIR}/extras.gresource.xml.c PARENT_SCOPE)
SET (extras_gresource_xml_H_FILE ${CMAKE_CURRENT_BINARY_DIR}/extras.gresource.xml.h PARENT_SCOPE)
install(PROGRAMS ${CMAKE_CURRENT_SOURCE_DIR}/terminus_showhide DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/terminus.desktop DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/applications/ )
if( NOT ( ${CMAKE_INSTALL_PREFIX} MATCHES "^/home/" ) )
	install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/terminus_autorun.desktop DESTINATION /etc/xdg/autostart/ )
else()
	MESSAGE(STATUS "[33mAutostart file data/terminus_autorun.desktop will not be installed. You must create your own .desktop file and put it at ~/.config/autostart[39m")
endif()
include(GSettings)
add_schema(org.rastersoft.terminus.gschema.xml)
