# User can now choose the path to python
# Checks if the PYTHON environment variable is set or if the PYTHON variable
# is passed to cmake using:
#  >> cmake -D PYTHON=/path/to/python
# If these options are not found, then use the default "python"
IF (DEFINED ENV{PYTHON})
  SET (PYTHON "$ENV{PYTHON}")
ELSE ()
  if (NOT DEFINED PYTHON)
    SET (PYTHON "python")
  ENDIF()
ENDIF()
MESSAGE(STATUS "Using PYTHON=${PYTHON}")
