cmake_minimum_required(VERSION 3.28)
project(Robotics
    VERSION 1.0
    DESCRIPTION "Robotics algorithms for path planning and control"
    LANGUAGES CXX)
set(
    CMAKE_CONFIGURATION_TYPES "Debug;Release;Dist"
    CACHE STRING "Allowed project configurations" FORCE
)

# * List of project options.
option(COMPUTERVISION_ENABLE_WARNINGS "Enable warnings during compilation." OFF)

option(COMPUTERVISION_USE_LIBCXX "Build with LLVM's libc++." OFF)

option(COMPUTERVISION_ENABLE_TESTS "Enable tests." OFF)

option(COMPUTERVISION_ENABLE_SANITIZERS "Enable sanitizers in debug config." OFF)
option(COMPUTERVISION_EXPORT_COMPILE_COMMANDS "Enable compile_commands.json generation." ON)

set(
    CMAKE_CONFIGURATION_TYPES "Debug;Release;Dist"
    CACHE STRING "Allowed project configurations" FORCE
)

# * Load project configuration.
include(${CMAKE_CURRENT_SOURCE_DIR}/scripts/cmake/config.cmake)

add_subdirectory(src)

if(COMPUTERVISION_ENABLE_TESTS)
    add_subdirectory(test)

    # add_subdirectory(bench)
endif()
