project(gstreamer_tests)

cmake_minimum_required(VERSION 3.10)

add_executable(helloworld-gstreamer
               helloworld-gstreamer.cpp)

find_package(PkgConfig REQUIRED)
pkg_check_modules(GSTREAMER
               REQUIRED
               gstreamer-1.0
               )

target_link_libraries(helloworld-gstreamer ${GSTREAMER_LIBRARIES})
target_include_directories(helloworld-gstreamer PRIVATE ${GSTREAMER_INCLUDE_DIRS})
