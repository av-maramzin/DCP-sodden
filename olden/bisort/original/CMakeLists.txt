# cmake file

set(BMK_NAME "bisort")
string(TOLOWER ${BMK_NAME} BMK_NAME_LOWER)
set(BMK_PROJECT_NAME ${BMK_NAME_LOWER})

check_bmk_processing(hasSrcDir)

if(NOT ${hasSrcDir})
  message(STATUS "skipping project: ${BMK_PROJECT_NAME}") 
  return()
endif()

set(SOURCES
  args.c                                       
  bitonic.c)

add_prefix(SOURCES "${HARNESS_BMK_SOURCE_SUBDIR}/" "${SOURCES}")

list(APPEND SOURCES ${COMMON_SOURCES})
list(APPEND SOURCES ${COMMON_RAND_SOURCES})

set(TARGET_ORIGINAL ${BMK_PROJECT_NAME}_original)

add_executable(${TARGET_ORIGINAL} ${SOURCES})

target_include_directories(${TARGET_ORIGINAL} PUBLIC
  "${CMAKE_CURRENT_BINARY_DIR}")

target_include_directories(${TARGET_ORIGINAL} PUBLIC
  "${CMAKE_CURRENT_SOURCE_DIR}/${HARNESS_BMK_SOURCE_SUBDIR}/")

target_link_libraries(${TARGET_ORIGINAL} m)


# this property is required by our parasitic targets
set_target_properties(${TARGET_ORIGINAL} PROPERTIES LINKER_LANGUAGE C)

# this property is used internally by our harness 
# because benchmark names and their main targets have different names
set_target_properties(${TARGET_ORIGINAL} PROPERTIES BMK_NAME ${BMK_NAME})

#

if(LLVM_IR_UTIL_FOUND)
  foreach(FRAGMENT ${HARNESS_CMAKE_FRAGMENT_FILES})
    include(${FRAGMENT})
  endforeach()
endif()

