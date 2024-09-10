if(ROBOTICS_ENABLE_CODECOVERAGE)
  include(CTest)

  if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    # * Use opencppcoverage
    add_test(
      NAME code-coverage
      COMMAND opencppcoverage --sources=Robotics\\src --recursive --modules Robotics.dll --excluded_sources build --export_type html --export_type cobertura:coverage.xml -- $<TARGET_FILE:Robotics-test>
      CONFIGURATIONS Debug
      WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
  else()
    # * Use gcov

    # * Threshold for passing code-coverage (% lines covered).
    set(ROBOTICS_CODE_COVERAGE_THRESHOLD 100)

    if(NOT ROBOTICS_GCOV_EXE)
      if(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        set(ROBOTICS_GCOV_EXE "llvm-cov gcov")
      else()
        set(ROBOTICS_GCOV_EXE "gcov")
      endif()
    endif()

    add_test(
      NAME code-coverage
      COMMAND gcovr --gcov-executable ${ROBOTICS_GCOV_EXE} --exclude build --exclude-directories "(.+/)?test$" --exclude-directories "(.+/)?bench$" --html-details ${CMAKE_CURRENT_BINARY_DIR}/coverage.html --cobertura ${CMAKE_CURRENT_BINARY_DIR}/coverage.xml --html-theme blue --fail-under-line ${ROBOTICS_CODE_COVERAGE_THRESHOLD} ${CMAKE_CURRENT_BINARY_DIR}
      CONFIGURATIONS Debug
      WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
    )
  endif()

  # * Requires all the correctness tests to be run.
  set_tests_properties(
    code-coverage
    PROPERTIES FIXTURES_REQUIRED ${ROBOTICS_CORRECTNESS_TESTS_FIXTURE}
  )
endif()
