cmake_minimum_required(VERSION 3.13)
project(runner LANGUAGES CXX)

# Define the application target. To change its name, change BINARY_NAME in the
# top-level CMakeLists.txt, not the value here, or `flutter run` will no longer
# work.
#
# Any new source files that you add to the application should be added here.
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)

# Apply the standard set of build settings. This can be removed for applications
# that need different build settings.
apply_standard_settings(${BINARY_NAME})

# Add preprocessor definitions for the application ID.
add_definitions(-DAPPLICATION_ID="${APPLICATION_ID}")

# Add dependency libraries. Add any application-specific dependencies here.
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)

target_include_directories(${BINARY_NAME} PRIVATE "${CMAKE_SOURCE_DIR}")

add_dependencies(${BINARY_NAME} flutter_assemble)

include(../flutter/generated_plugins.cmake)

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
