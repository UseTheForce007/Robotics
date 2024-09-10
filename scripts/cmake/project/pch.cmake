# * Function to add PCH for a target.
function(add_pch target)
  if(ROBOTICS_USE_PCH)
    target_precompile_headers(
      ${target}
      PRIVATE
      $<$<COMPILE_LANGUAGE:C>:${CMAKE_CURRENT_SOURCE_DIR}/pch.h>
      $<$<COMPILE_LANGUAGE:CXX>:${CMAKE_CURRENT_SOURCE_DIR}/pch.hpp>
    )

    if(ROBOTICS_CLANG_TIDY)
      # * CMake's clang-tidy integration cannot handle PCH. So we filter it out.
      # * There is no elegant way of finding the CXX file that CMake auto-generates for the PCH.
      file(GLOB_RECURSE PCH_FILES CONFIGURE_DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/${target}.dir/*.c*)
      set_source_files_properties(${PCH_FILES} PROPERTIES SKIP_LINTING ON)
    endif()
  endif(ROBOTICS_USE_PCH)
endfunction()
