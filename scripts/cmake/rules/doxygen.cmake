# * Doxygen is used to generate API documentation, if present on the system.

if(ROBOTICS_ENABLE_DOC)
  include(FindDoxygen)
  set(DOXYGEN_GENERATE_HTML YES)
  set(DOXYGEN_GENERATE_MAN NO)
  set(DOXYGEN_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/doc)
  set(DOXYGEN_WARN_AS_ERROR YES)
  set(DOXYGEN_QUIET YES)
  set(DOXYGEN_EXCLUDE_PATTERNS *.c*)
  doxygen_add_docs(doc
    src
    ALL
  )
endif()
