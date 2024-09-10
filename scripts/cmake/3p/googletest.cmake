# * Sets Google Test usage.
if(ROBOTICS_ENABLE_TESTS)
  enable_testing()

  set(BUILD_GMOCK OFF CACHE BOOL "" FORCE)
  set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)

  FetchContent_Declare(
    googletest
    SYSTEM
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG main
    GIT_PROGRESS TRUE
    GIT_SHALLOW TRUE
    EXCLUDE_FROM_ALL
  )
  FetchContent_MakeAvailable(googletest)

  # * Windows requires ASAN to be linked with all objects.
  if(ROBOTICS_ENABLE_SANITIZERS)
    target_compile_options(
      gtest
      PRIVATE
      $<$<CONFIG:DEBUG>:${ROBOTICS_ASAN_COMPILER_FLAG}>
    )
    target_compile_options(
      gtest_main
      PRIVATE
      $<$<CONFIG:DEBUG>:${ROBOTICS_ASAN_COMPILER_FLAG}>
    )
  endif()

  # * Windows requires ASAN to be linked with all objects.
  if(ROBOTICS_USE_LIBCXX)
    target_compile_options(
      gtest
      PRIVATE
      ${ROBOTICS_LIBCXX_COMPILER_FLAG}
    )
    target_compile_options(
      gtest_main
      PRIVATE
      ${ROBOTICS_LIBCXX_COMPILER_FLAG}
    )
  endif()

  include(GoogleTest)
endif(ROBOTICS_ENABLE_TESTS)
