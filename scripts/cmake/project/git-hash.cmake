# * Obtain git hash quietly.
execute_process(
  COMMAND git log -1 --format=%h
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  ERROR_QUIET
  OUTPUT_VARIABLE ROBOTICS_GIT_COMMIT_HASH
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

# * Just in case we are not in a git repo (or git doesn't exist).
if(ROBOTICS_GIT_COMMIT_HASH STREQUAL "")
  set(ROBOTICS_GIT_COMMIT_HASH "0x00")
endif(ROBOTICS_GIT_COMMIT_HASH STREQUAL "")
