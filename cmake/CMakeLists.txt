# This will install .cmake modules here into the library where cmake's
# find_package will look.
INSTALL(DIRECTORY ./
  DESTINATION lib/${CMAKE_PROJECT_NAME}
  FILES_MATCHING PATTERN "*.cmake")
