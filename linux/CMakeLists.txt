cmake_minimum_required(VERSION 3.22)
project(invobharat LANGUAGES CXX)

# Standard Flutter Linux config ONLY
set(BINARY_NAME "invobharat")
set(APPLICATION_ID "com.example.invobharat")

cmake_policy(SET CMP0063 NEW)
set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Cross-compile support
if(FLUTTER_TARGET_PLATFORM_SYSROOT)
  set(CMAKE_SYSROOT ${FLUTTER_TARGET_PLATFORM_SYSROOT})
  set(CMAKE_FIND_ROOT_PATH ${CMAKE_SYSROOT})
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
endif()

if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
  set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Flutter build mode" FORCE)
  set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "Debug" "Profile" "Release")
endif()

function(APPLY_STANDARD_SETTINGS TARGET)
  target_compile_features(${TARGET} PUBLIC cxx_std_14)
  target_compile_options(${TARGET} PRIVATE -Wall -Werror)
  target_compile_options(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:-O3>")
  target_compile_definitions(${TARGET} PRIVATE "$<$<NOT:$<CONFIG:Debug>>:NDEBUG>")
endfunction()

set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

find_package(PkgConfig REQUIRED)
pkg_check_modules(GTK REQUIRED IMPORTED_TARGET gtk+-3.0)

add_subdirectory("runner")
add_dependencies(${BINARY_NAME} flutter_assemble)

include(flutter/generated_plugins.cmake)

set_target_properties(${BINARY_NAME}
  PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/intermediates_do_not_run"
)

set(BUNDLE_OUTPUT_DIR "${CMAKE_BINARY_DIR}/bundle")
set_target_properties(${BINARY_NAME}
  PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${BUNDLE_OUTPUT_DIR}"
)

add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
  "${FLUTTER_ASSETS_DIR}" "${BUNDLE_OUTPUT_DIR}/data/flutter_assets"
)

add_custom_command(TARGET ${BINARY_NAME} POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_directory
  "${FLUTTER_ICU_DATA_DIR}" "${BUNDLE_OUTPUT_DIR}/data"
)

install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "."
  COMPONENT Runtime)

install(DIRECTORY "${BUNDLE_OUTPUT_DIR}/data" DESTINATION "."
  COMPONENT Runtime)

if(BUILD_SHARED_LIBS)
  install(FILES "${FLUTTER_LIBRARY}" DESTINATION "."
    COMPONENT Runtime)
endif()
