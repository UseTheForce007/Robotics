# * Get current folder basename to use as the output target name.

find_package(Eigen3 REQUIRED)
find_package(Python3 COMPONENTS Interpreter Development NumPy REQUIRED)
set(myTargetName "Robotics-dwa")

add_executable(

    ${myTargetName}
    dwa_local.cpp
    dynamic_window_approach.cpp
)

set_target_properties(
    ${myTargetName}
    PROPERTIES
    C_STANDARD 17
    CXX_STANDARD 23
    CXX_EXTENSIONS OFF
    CXX_STANDARD_REQUIRED ON
    CXX_SCAN_FOR_MODULES OFF
    CXX_VISIBILITY_PRESET hidden
    C_VISIBILITY_PRESET hidden
    EXPORT_COMPILE_COMMANDS ${ROBOTICS_EXPORT_COMPILE_COMMANDS}
    CXX_CLANG_TIDY "${ROBOTICS_CLANG_TIDY}"
    C_CLANG_TIDY "${ROBOTICS_CLANG_TIDY}"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
    INTERPROCEDURAL_OPTIMIZATION_RELEASE ON
    INTERPROCEDURAL_OPTIMIZATION_DIST ON
    LINK_OPTIONS "${ROBOTICS_LINKER_FLAGS}"
    VISIBILITY_INLINES_HIDDEN ON
    PUBLIC_HEADER ${ROBOTICS_EXPORT_HEADER_DIR}/Robotics.hpp
    DEFINE_SYMBOL "ROBOTICS_EXPORT_API"
)

target_compile_definitions(
    ${myTargetName}
    PRIVATE
    ROBOTICS_PROJECT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}
    ROBOTICS_PROJECT_VERSION_MINOR=${PROJECT_VERSION_MINOR}
    ROBOTICS_PROJECT_VERSION_PATCH=${PROJECT_VERSION_PATCH}
    ROBOTICS_GIT_COMMIT_HASH=${ROBOTICS_GIT_COMMIT_HASH}
)

target_compile_options(
    ${myTargetName}
    PRIVATE
    $<$<COMPILE_LANGUAGE:CXX>:${ROBOTICS_CXX_FLAGS}>
    $<$<COMPILE_LANGUAGE:C>:${ROBOTICS_C_FLAGS}>
)

target_include_directories(${myTargetName} PUBLIC include ${EIGEN3_INCLUDE_DIR} ${Python3_INCLUDE_DIRS} ${Python3_NumPy_INCLUDE_DIRS} ~/ros2_ws/extern/matplotlib-cpp)
target_link_libraries(${myTargetName} PRIVATE Eigen3::Eigen ${Python3_LIBRARIES})
install(
    TARGETS ${myTargetName}
    RUNTIME DESTINATION bin
    PUBLIC_HEADER DESTINATION include
)

# add_pch(${myTargetName})