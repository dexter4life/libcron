cmake_minimum_required(VERSION 3.6)

project(top)

option(LIBCRON_BUILD_TESTS "Build tests" ON)

add_subdirectory(libcron)

if(LIBCRON_BUILD_TESTS)
    add_subdirectory(test)
    add_dependencies(cron_test libcron)
endif()

install(TARGETS libcron DESTINATION lib)
install(DIRECTORY libcron/include/libcron DESTINATION include)

