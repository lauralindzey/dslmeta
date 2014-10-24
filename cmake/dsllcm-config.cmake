# Set destination for all generated code.
set (LCM_DEST ${PROJECT_SOURCE_DIR}/gen/lcm)

# Find lcm.jar.
find_package(Java REQUIRED)
execute_process(COMMAND pkg-config --variable=classpath lcm-java OUTPUT_VARIABLE LCM_JAR_FILE)
message(STATUS "LCM_JAR_FILE: ${LCM_JAR_FILE}")
if(LCM_JAR_FILE STREQUAL "")
  message(FATAL_ERROR "Please install lcm 1.1.2")
endif(LCM_JAR_FILE STREQUAL "")
string(STRIP ${LCM_JAR_FILE} LCM_JAR_FILE)

