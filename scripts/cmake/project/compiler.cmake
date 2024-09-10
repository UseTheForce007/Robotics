# * Identify ClangCL.
if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    if(CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
        set(ADD_CLANG_CL TRUE)
    else()
        set(ADD_WINDOWS_CLANG TRUE)
    endif()
endif()

if(CMAKE_CXX_COMPILER_ID MATCHES "MSVC" OR ADD_CLANG_CL)
    # * Warnings
    set(ADD_NO_WARN_FLAG /w)
    set(ADD_STANDARD_WARNINGS /W4 /WX)

    if(ADD_CLANG_CL)
        # * TODO: Enable sanitizers for clang-cl.
        set(ADD_CODE_COVERAGE_COMPILER_FLAG --coverage)
        set(ADD_CODE_COVERAGE_LINKER_FLAG clang_rt.profile-x86_64.lib)
    else()
        # * MSVC
        # * TODO: Enable code coverage for msvc.
        set(ADD_ASAN_COMPILER_FLAG /fsanitize=address)
        set(ADD_ASAN_LINKER_FLAG /fsanitize=address)

        # set(ADD_CODE_COVERAGE_COMPILER_FLAG --coverage)
        set(ADD_CODE_COVERAGE_LINKER_FLAG /PROFILE)
    endif()
else()
    # * Clang or GNU on either windows or unix.
    # * Warnings.
    set(ADD_NO_WARN_FLAG -w)
    set(ADD_STANDARD_WARNINGS -Werror -Wall -Wextra -Wpedantic)

    if(NOT WIN32)
        # * Clang/GNU on Unix.
        # * TODO: Enable sanitizers for clang on Windows. Can't be done yet for debug mode.
        # * https://github.com/google/sanitizers/wiki/AddressSanitizerWindowsPort#debugging
        set(ADD_ASAN_COMPILER_FLAG -fsanitize=address -fno-omit-frame-pointer -fsanitize=undefined)
        set(ADD_ASAN_LINKER_FLAG -fsanitize=address -fsanitize=undefined)
    endif()

    # * Code coverage.
    set(ADD_CODE_COVERAGE_COMPILER_FLAG --coverage)
    set(ADD_CODE_COVERAGE_LINKER_FLAG --coverage)

    # * Release flags.
    string(REPLACE "-O2" "-O3" CMAKE_CXX_FLAGS_RELEASE ${CMAKE_CXX_FLAGS_RELEASE})
    string(REPLACE "-O2" "-O3" CMAKE_C_FLAGS_RELEASE ${CMAKE_C_FLAGS_RELEASE})

    # * If we want to link with libc++.
    set(ADD_LIBCXX_COMPILER_FLAG -stdlib=libc++)
    set(ADD_LIBCXX_LINKER_FLAG -stdlib=libc++ -lc++ -lc++abi -lm)
endif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC" OR ADD_CLANG_CL)

if(APPLE AND CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    # * Cmake does not let GCC on MacOS generate PCH files properly.
    set(ADD_USE_PCH OFF CACHE BOOL "" FORCE)

    # * Asan not on mac aarch64 yet.
    set(ADD_ENABLE_SANITIZERS OFF)
endif()

# * Copy release settings into dist.
set(CMAKE_CXX_FLAGS_DIST ${CMAKE_CXX_FLAGS_RELEASE})
set(CMAKE_C_FLAGS_DIST ${CMAKE_C_FLAGS_RELEASE})
set(CMAKE_SHARED_LINKER_FLAGS_DIST ${CMAKE_SHARED_LINKER_FLAGS_RELEASE})
set(ADD_CLANG_TIDY $<IF:$<CONFIG:DIST>,,${ADD_CLANG_TIDY}>)

# * Set the warnings.
if(ADD_ENABLE_WARNINGS)
    set(ADD_CXX_FLAGS $<IF:$<CONFIG:DIST>,${ADD_NO_WARN_FLAG},${ADD_STANDARD_WARNINGS}>)
    set(ADD_C_FLAGS $<IF:$<CONFIG:DIST>,${ADD_NO_WARN_FLAG},${ADD_STANDARD_WARNINGS}>)
else()
    set(ADD_CXX_FLAGS ${ADD_NO_WARN_FLAG})
    set(ADD_C_FLAGS ${ADD_NO_WARN_FLAG})
endif(ADD_ENABLE_WARNINGS)

if(ADD_ENABLE_CODECOVERAGE)
    set(ADD_CXX_FLAGS ${ADD_CXX_FLAGS} $<$<CONFIG:DEBUG>:${ADD_CODE_COVERAGE_COMPILER_FLAG}>)
    set(ADD_C_FLAGS ${ADD_C_FLAGS} $<$<CONFIG:DEBUG>:${ADD_CODE_COVERAGE_COMPILER_FLAG}>)
    set(ADD_LINKER_FLAGS ${ADD_LINKER_FLAGS} $<$<CONFIG:DEBUG>:${ADD_CODE_COVERAGE_LINKER_FLAG}>)
endif()

if(ADD_ENABLE_SANITIZERS)
    set(ADD_CXX_FLAGS ${ADD_CXX_FLAGS} $<$<CONFIG:DEBUG>:${ADD_ASAN_COMPILER_FLAG}>)
    set(ADD_C_FLAGS ${ADD_C_FLAGS} $<$<CONFIG:DEBUG>:${ADD_ASAN_COMPILER_FLAG}>)
    set(ADD_LINKER_FLAGS ${ADD_LINKER_FLAGS} $<$<CONFIG:DEBUG>:${ADD_ASAN_LINKER_FLAG}>)
endif()

# * Some compilers use libcxx by default anyways.
if(ADD_USE_LIBCXX AND NOT APPLE AND NOT ADD_WINDOWS_CLANG)
    set(ADD_USE_LIBCXX ON CACHE BOOL "" FORCE)
else()
    set(ADD_USE_LIBCXX OFF CACHE BOOL "" FORCE)
endif()

if(ADD_USE_LIBCXX)
    set(ADD_CXX_FLAGS ${ADD_CXX_FLAGS} ${ADD_LIBCXX_COMPILER_FLAG})
    set(ADD_LINKER_FLAGS ${ADD_LINKER_FLAGS} ${ADD_LIBCXX_LINKER_FLAG})
endif()

if(APPLE AND CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    # * GCC on MacOS (arm64) does not support -fno-fat-lto-objects yet.
    # https://gitlab.kitware.com/cmake/cmake/-/issues/21696
    # https://stackoverflow.com/questions/70806677/why-does-cmake-set-no-fat-lto-objects-when-i-enable-lto-ipo
    set(CMAKE_C_COMPILE_OPTIONS_IPO "-flto=auto")

    # Linker errors with xcode 15.
    # https://forums.developer.apple.com/forums/thread/737707
    set(ADD_LINKER_FLAGS ${ADD_LINKER_FLAGS} -Wl,-ld_classic)
endif()
