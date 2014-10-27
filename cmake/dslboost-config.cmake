
SET(BOOST_ROOT "/usr/")

FIND_PACKAGE(Boost 1.55.0 REQUIRED)
# @@@ unfortunately the above only produces a fatal error the first time.  Boost_FOUND is still set to true even if the installed version is too old.  This is then stored in the cmake cache and the test below will pass.
IF(Boost_FOUND)
  message(STATUS "Detected Boost ${Boost_VERSION}")
  SET(Boost_LIBRARY_DIRS "/usr/lib/x86_64-linux-gnu/")
  INCLUDE_DIRECTORIES(${Boost_INCLUDE_DIR})
  LINK_DIRECTORIES(${Boost_LIBRARY_DIRS})
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -DBOOST_LOG_DYN_LINK")
  message(STATUS "BOOST INCLUDE: ${Boost_INCLUDE_DIR}")
  message(STATUS "BOOST LIB:     ${Boost_LIBRARY_DIRS}")
ELSE()
  message(FATAL_ERROR "This library requires Boost at least version 1.55.0.  dslmeta/scripts/boost-1.55/ contains scripts to compile and install boost-1.55 from source to /opt/boost-1.55.")
ENDIF()
