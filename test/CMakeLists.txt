cmake_minimum_required(VERSION 3.6)
project(cron_test)

set(CMAKE_CXX_STANDARD 17)

# Deactivate Iterator-Debugging on Windows
option(LIBCRON_DEACTIVATE_ITERATOR_DEBUGGING "Build with iterator-debugging (MSVC only)." OFF)

if( MSVC )
        set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /W4")
        
	if (LIBCRON_DEACTIVATE_ITERATOR_DEBUGGING)
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -D_HAS_ITERATOR_DEBUGGING=0")
	endif()
else()
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -Wpedantic")
endif()

find_package(Catch2 3 CONFIG REQUIRED)

include_directories(
        ${CMAKE_CURRENT_LIST_DIR}/..
)

add_executable(
        ${PROJECT_NAME}
        CronDataTest.cpp
        CronRandomizationTest.cpp
	CronScheduleTest.cpp
	CronTest.cpp)

if(NOT MSVC)
	target_link_libraries(${PROJECT_NAME} libcron Catch2::Catch2WithMain pthread)

	# Assume a modern compiler supporting uncaught_exceptions()
	target_compile_definitions (${PROJECT_NAME} PRIVATE -DHAS_UNCAUGHT_EXCEPTIONS)
else()
	target_link_libraries(${PROJECT_NAME} libcron Catch2::Catch2WithMain)
endif()

set_target_properties(${PROJECT_NAME} PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/out"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/out"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/out")
