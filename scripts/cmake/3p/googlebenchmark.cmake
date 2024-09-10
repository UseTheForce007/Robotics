# * Sets Google Test usage.
if(ROBOTICS_ENABLE_TESTS)
  enable_testing()

  if(ROBOTICS_USE_LIBCXX)
    set(BENCHMARK_USE_LIBCXX ON)
  endif()

  set(BENCHMARK_ENABLE_TESTING OFF)
  set(DBENCHMARK_DOWNLOAD_DEPENDENCIES ON)
  FetchContent_Declare(
    googlebenchmark
    SYSTEM
    GIT_REPOSITORY https://github.com/google/benchmark.git
    GIT_TAG v1.8.3
    GIT_PROGRESS TRUE
    GIT_SHALLOW TRUE
    EXCLUDE_FROM_ALL
  )
  FetchContent_MakeAvailable(googlebenchmark)

  if(ROBOTICS_ENABLE_SANITIZERS)
    target_compile_options(
      benchmark
      PRIVATE
      $<$<CONFIG:DEBUG>:${ROBOTICS_ASAN_COMPILER_FLAG}>
    )
    target_compile_options(
      benchmark_main
      PRIVATE
      $<$<CONFIG:DEBUG>:${ROBOTICS_ASAN_COMPILER_FLAG}>
    )
  endif()
endif(ROBOTICS_ENABLE_TESTS)
