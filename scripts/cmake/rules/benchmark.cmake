# if(ROBOTICS_ENABLE_TESTS)
# include(CTest)

# add_test(
# NAME benchmark
# COMMAND $<TARGET_FILE:Robotics-bench>
# CONFIGURATIONS Release
# WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
# )

# # * Requires all the correctness tests to be run.
# set_tests_properties(
# benchmark
# PROPERTIES FIXTURES_REQUIRED ${ROBOTICS_CORRECTNESS_TESTS_FIXTURE}
# )
# endif()
