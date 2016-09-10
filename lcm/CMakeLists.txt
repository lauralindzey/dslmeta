# Revision History
# 2013-12-15    mvj    Edited copy from dslcommon.
# 2014-01-24    MVJ    Added "common" temporarily to try out heartbeat.
# 2014-04-16    MVJ    Fixed to handle more than one level of 
#                      inter-package dependency.


# Packages.  Must be listed in dependency order.
set (LCM_PACKAGES
  "dslcommon"
  "dslprocess"
  "dsldevice"
  "ps8ch"
  "paro"
  "ini"
  "phins"
  "rdidvl"
  "ustrain"
  "battery"
  "umodem"
  "dsljoy"
  "bwls"
  "sbe49"
  "sparkfunimu"
  "wrapped"
  "gps"
  "gyro"
  "environment"
  "rov"
  "mx"
  "comms"
  "sitAware"
  "usbl"
  "bathysim"
  "xjoy"
  "apsmag"
  "valeport"
  "nav"
  "hydpress"
  "releaseboard"
  "oscompass"
  "acomms"
  "hotel"
  "jt"
  "sensors"
  "soln"
  "timing"
  "rostilt"
)

# Set destination for all generated code.
set (LCM_DEST ${PROJECT_SOURCE_DIR}/gen/lcm)

# Find lcm.jar.
find_package(Java REQUIRED)
execute_process(COMMAND pkg-config --variable=classpath lcm-java OUTPUT_VARIABLE LCM_JAR_FILE)
message(STATUS "LCM_JAR_FILE: ${LCM_JAR_FILE}")
if(LCM_JAR_FILE STREQUAL "")
  message(FATAL_ERROR "Please install lcm 1.0.0")
endif(LCM_JAR_FILE STREQUAL "")
string(STRIP ${LCM_JAR_FILE} LCM_JAR_FILE)

# Generate LCM headers, python, and java.
foreach (LCM_PKG ${LCM_PACKAGES})

  message ( STATUS "LCM_PKG: ${LCM_PKG}" )

  file (GLOB LCM_DEFS "${LCM_PKG}/*.lcm")

  set (LCM_TYPES_CXX  "")
  set (LCM_TYPES_PY "")
  set (LCM_TYPES_JAVA  "")
  set (LCM_TYPES_JAVACLASS "")
  foreach (LCM_DEF ${LCM_DEFS})

    GET_FILENAME_COMPONENT( LCM_TYPE ${LCM_DEF} NAME_WE )

    message ( STATUS "LCM_TYPE: ${LCM_TYPE}")

    add_custom_command(
      OUTPUT ${LCM_DEST}/${LCM_PKG}/${LCM_TYPE}.hpp
      COMMAND lcm-gen -x --lazy --cpp-hpath ${LCM_DEST} ${LCM_DEF}
      DEPENDS ${LCM_DEF}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      )
    add_custom_command(
      OUTPUT ${LCM_DEST}/${LCM_PKG}/${LCM_TYPE}.py
      COMMAND lcm-gen -p --lazy --ppath ${LCM_DEST} ${LCM_DEF}
      DEPENDS ${LCM_DEF}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      )
    add_custom_command(
      OUTPUT ${LCM_DEST}/${LCM_PKG}/${LCM_TYPE}.java
      COMMAND lcm-gen -j --lazy --jpath ${LCM_DEST} ${LCM_DEF}
      DEPENDS ${LCM_DEF}
      WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
      )

    # Packages must be listed in dependency order.  To enforce build
    # order assume that each package depends on all packages above it.
    # No harm done if not strictly true - this just sets build order.
    add_custom_command (
      OUTPUT ${LCM_DEST}/${LCM_PKG}/${LCM_TYPE}.class
      COMMAND javac -cp ${LCM_JAR_FILE}:../:. ${LCM_DEST}/${LCM_PKG}/${LCM_TYPE}.java
      DEPENDS ${LCM_DEST}/${LCM_PKG}/${LCM_TYPE}.java ${LCM_PKG_DEPENDS}
      WORKING_DIRECTORY ${LCM_DEST}/${LCM_PKG}
      COMMENT "Generating ${LCM_PKG} class file ${LCM_TYPE}.class for inclusion into ${LCM_PKG}.jar"
      )

    # Store lcm-gen output for further processing.
    SET (LCM_TYPES_CXX ${LCM_TYPES_CXX} ${LCM_DEST}/${LCM_PKG}/${LCM_TYPE}.hpp)
    SET (LCM_TYPES_PY ${LCM_TYPES_PY} ${LCM_DEST}/${LCM_PKG}/${LCM_TYPE}.py)
    SET (LCM_TYPES_JAVA ${LCM_TYPES_JAVA} ${LCM_DEST}/${LCM_PKG}/${LCM_TYPE}.java)
    SET (LCM_TYPES_JAVACLASS ${LCM_TYPES_JAVACLASS} ${LCM_DEST}/${LCM_PKG}/${LCM_TYPE}.class)

  endforeach()

  # Store processed packages to enforce build order via dependency.
  # Only needed to create .jar files, but these are needed for lcm-spy.
  SET (LCM_PKG_DEPENDS ${LCM_PKG_DEPENDS} ${LCM_PKG})
  message ("Next LCM package assumed to depend on: ${LCM_PKG_DEPENDS}")

  add_custom_target (
    ${LCM_PKG}.jar ALL
    COMMAND jar cf ${LCM_PKG}.jar ${LCM_PKG}
    DEPENDS ${LCM_TYPES_JAVACLASS}
    WORKING_DIRECTORY ${LCM_DEST}
    COMMENT "Generating ${LCM_PKG}.jar"
    )

  # The custom commands above specify how to generate each file.  Add
  # a custom target for each LCM package to actually generate the files
  # in the absence of other dependencies.
  add_custom_target (
    ${LCM_PKG} ALL
    DEPENDS ${LCM_TYPES_CXX} ${LCM_TYPES_PY} ${LCM_TYPES_JAVA}
    COMMENT "Generating LCM bindings for package ${LCM_PKG}."
    )

  # Clean up generated files on 'make clean'
  set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES ${LCM_DEST})

  # Install c++ headers.
  INSTALL(FILES ${LCM_TYPES_CXX}
    DESTINATION include/lib${CMAKE_PROJECT_NAME}/${LCM_PKG}/
    )

  # Install python bindings.
  execute_process( COMMAND ${PYTHON} -c "from distutils.sysconfig import get_python_lib; print get_python_lib(prefix='${CMAKE_INSTALL_PREFIX}')" OUTPUT_VARIABLE PYTHON_SITE_PACKAGES OUTPUT_STRIP_TRAILING_WHITESPACE )
  INSTALL(FILES ${LCM_TYPES_PY} ${LCM_DEST}/${LCM_PKG}/__init__.py
    DESTINATION ${PYTHON_SITE_PACKAGES}/${LCM_PKG}
    )

  # Install java bindings.
  INSTALL(FILES ${LCM_DEST}/${LCM_PKG}.jar
    DESTINATION share/java/
    )
endforeach ()
