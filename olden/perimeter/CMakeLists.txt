# cmake file

set(BMK_NAME "perimeter")
string(TOLOWER ${BMK_NAME} BMK_NAME_LOWER)
set(BMK_PROJECT_NAME ${BMK_NAME_LOWER})

if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/original")
    add_subdirectory(original)
else()
  message(STATUS "skipping project: ${BMK_PROJECT_NAME}") 
  return()
endif()

if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/abstract")
    add_subdirectory(abstract)
endif()

if(IS_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/abstract_old")
    add_subdirectory(abstract_old)
endif()

# end
