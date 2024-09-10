# * Add compiler flags first.
include(${CMAKE_CURRENT_LIST_DIR}/project/global.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/project/compiler.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/project/git-hash.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/project/pch.cmake)

include(${CMAKE_CURRENT_LIST_DIR}/rules/compile-commands.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/rules/coverage.cmake)

# include(${CMAKE_CURRENT_LIST_DIR}/rules/doxygen.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/rules/benchmark.cmake)

# * Turn off checks for 3p.
include(FetchContent)
include(ExternalProject)
include(${CMAKE_CURRENT_LIST_DIR}/3p/googletest.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/3p/googlebenchmark.cmake)
