FIND_PACKAGE(Boost 1.55.0 REQUIRED)
# @@@ unfortunately the above only produces a fatal error the first time.  Boost_FOUND is still set to true even if the installed version is too old.  This is then stored in the cmake cache and the test below will pass.
IF(Boost_FOUND)
  message(STATUS "Detected Boost ${Boost_VERSION}")
ELSE()
  message(FATAL_ERROR "This library requires Boost at least version 1.55.0.  dslmeta/scripts/boost-1.55/ contains scripts to compile and install boost-1.55 from source to /opt/boost-1.55.")
ENDIF()
