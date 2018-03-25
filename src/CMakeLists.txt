### CMakeLists automatically created with AutoVala
### Do not edit

set (DATADIR "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_DATAROOTDIR}")
set (PKGDATADIR "${DATADIR}/terminus")
set (GETTEXT_PACKAGE "terminus")
set (RELEASE_NAME "terminus")
set (CMAKE_C_FLAGS "")
set (PREFIX ${CMAKE_INSTALL_PREFIX})
set (VERSION "0.11.0")
set (TESTSRCDIR "${CMAKE_SOURCE_DIR}")
set (DOLLAR "$")

configure_file (${CMAKE_SOURCE_DIR}/src/Config.vala.base ${CMAKE_BINARY_DIR}/src/Config.vala)
add_definitions(-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\")
set (VERSION "0.11.0")
add_definitions (${DEPS_CFLAGS})
link_libraries ( ${DEPS_LIBRARIES} )
link_directories ( ${DEPS_LIBRARY_DIRS} )
find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.30" MINIMUM)
include (ValaPrecompile)

set (VALA_PACKAGES ${VALA_PACKAGES} posix)
set (VALA_PACKAGES ${VALA_PACKAGES} gdk-3.0)
set (VALA_PACKAGES ${VALA_PACKAGES} gtk+-3.0)
set (VALA_PACKAGES ${VALA_PACKAGES} gee-0.8)
set (VALA_PACKAGES ${VALA_PACKAGES} gio-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} glib-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} gobject-2.0)
set (VALA_PACKAGES ${VALA_PACKAGES} keybinder-3.0)
set (VALA_PACKAGES ${VALA_PACKAGES} vte-2.91)

set (APP_SOURCES ${APP_SOURCES} ${CMAKE_CURRENT_BINARY_DIR}/Config.vala)
set (APP_SOURCES ${APP_SOURCES} PanedPercentage.vala)
set (APP_SOURCES ${APP_SOURCES} base.vala)
set (APP_SOURCES ${APP_SOURCES} bindkeys.vala)
set (APP_SOURCES ${APP_SOURCES} container.vala)
set (APP_SOURCES ${APP_SOURCES} notetab.vala)
set (APP_SOURCES ${APP_SOURCES} settings.vala)
set (APP_SOURCES ${APP_SOURCES} terminal.vala)
set (APP_SOURCES ${APP_SOURCES} terminus.vala)
set (APP_SOURCES ${APP_SOURCES} window.vala)

set (CUSTOM_VAPIS_LIST ${CUSTOM_VAPIS_LIST} ${CMAKE_SOURCE_DIR}/src/checkwayland.vapi)

if (GTK_3_20)
	set (COMPILE_OPTIONS ${COMPILE_OPTIONS} -D GTK_3_20)
	set (CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DGTK_3_20 " )
	set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DGTK_3_20 " )
endif ()
set (COMPILE_OPTIONS ${COMPILE_OPTIONS} --vapidir=${CMAKE_SOURCE_DIR}/src/vapidir )

if ((${CMAKE_BUILD_TYPE} STREQUAL "Debug") OR (${CMAKE_BUILD_TYPE} STREQUAL "RelWithDebInfo"))
	set(COMPILE_OPTIONS ${COMPILE_OPTIONS} "-g")
endif()

set (COMPILE_OPTIONS ${COMPILE_OPTIONS} --gresources=${CMAKE_SOURCE_DIR}/data/extras.gresource.xml )

vala_precompile(VALA_C terminus
	${APP_SOURCES}
PACKAGES
	${VALA_PACKAGES}
CUSTOM_VAPIS
	${CUSTOM_VAPIS_LIST}
OPTIONS
	${COMPILE_OPTIONS}
)

set (VALA_C ${VALA_C} checkwayland.c)

SET (VALA_C ${VALA_C} ${extras_gresource_xml_C_FILE})
add_executable(terminus ${VALA_C})
set ( terminus_DEPENDENCIES ${terminus_DEPENDENCIES} extras_gresource_xml )
add_dependencies( terminus ${terminus_DEPENDENCIES} )


install(TARGETS
	terminus
RUNTIME DESTINATION
	${CMAKE_INSTALL_BINDIR}
)
if(HAVE_VALADOC)
	valadoc(terminus
		${CMAKE_BINARY_DIR}/valadoc/terminus
		${APP_SOURCES}
	PACKAGES
		${VALA_PACKAGES}
	CUSTOM_VAPIS
		${CUSTOM_VAPIS_LIST}
	)
	install(DIRECTORY
		${CMAKE_BINARY_DIR}/valadoc
	DESTINATION
		${CMAKE_INSTALL_DATAROOTDIR}/doc/terminus
	)
endif()
