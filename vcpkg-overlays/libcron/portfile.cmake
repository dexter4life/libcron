vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_git(
    OUT_SOURCE_PATH SOURCE_PATH
    URL https://github.com/PerMalmberg/libcron.git
    REF ee34810b11bd23c8be637345532f91059b68b2d7
)

# Patch root CMakeLists.txt to make tests optional
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt"
    "add_subdirectory(libcron)
add_subdirectory(test)

add_dependencies(cron_test libcron)"
    "option(LIBCRON_BUILD_TESTS \"Build tests\" OFF)
add_subdirectory(libcron)
if(LIBCRON_BUILD_TESTS)
    add_subdirectory(test)
    add_dependencies(cron_test libcron)
endif()"
)

# Patch libcron/CMakeLists.txt to use vcpkg's date library
vcpkg_replace_string("${SOURCE_PATH}/libcron/CMakeLists.txt"
    "target_include_directories(\${PROJECT_NAME}
		PUBLIC \${CMAKE_CURRENT_LIST_DIR}/externals/date/include
		PUBLIC include)"
    "find_package(date CONFIG REQUIRED)
target_include_directories(\${PROJECT_NAME} PUBLIC include)
target_link_libraries(\${PROJECT_NAME} PUBLIC date::date)"
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBCRON_BUILD_TESTS=OFF
)

vcpkg_cmake_build()

# Manual installation - library is built to source dir's out folder
file(INSTALL "${SOURCE_PATH}/libcron/out/Release/liblibcron.a" DESTINATION "${CURRENT_PACKAGES_DIR}/lib" RENAME "libcron.a")
file(INSTALL "${SOURCE_PATH}/libcron/out/Debug/liblibcron.a" DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib" RENAME "libcron.a")

# Install headers
file(INSTALL "${SOURCE_PATH}/libcron/include/libcron" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Create CMake config files
file(WRITE "${CURRENT_PACKAGES_DIR}/share/libcron/libcron-config.cmake" [=[
include(CMakeFindDependencyMacro)
find_dependency(date CONFIG)

if(NOT TARGET libcron::libcron)
    add_library(libcron::libcron STATIC IMPORTED)
    
    get_filename_component(_LIBCRON_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../.." ABSOLUTE)
    
    set_target_properties(libcron::libcron PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES "${_LIBCRON_PREFIX}/include"
        INTERFACE_LINK_LIBRARIES "date::date"
    )
    
    if(EXISTS "${_LIBCRON_PREFIX}/lib/libcron.a")
        set_property(TARGET libcron::libcron APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
        set_target_properties(libcron::libcron PROPERTIES
            IMPORTED_LOCATION_RELEASE "${_LIBCRON_PREFIX}/lib/libcron.a"
            IMPORTED_LOCATION "${_LIBCRON_PREFIX}/lib/libcron.a"
        )
    endif()
    
    if(EXISTS "${_LIBCRON_PREFIX}/debug/lib/libcron.a")
        set_property(TARGET libcron::libcron APPEND PROPERTY IMPORTED_CONFIGURATIONS DEBUG)
        set_target_properties(libcron::libcron PROPERTIES
            IMPORTED_LOCATION_DEBUG "${_LIBCRON_PREFIX}/debug/lib/libcron.a"
        )
    endif()
    
    unset(_LIBCRON_PREFIX)
endif()
]=])

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
