#
# FindLibR.cmake
#
# Copyright (C) 2009-11 by RStudio, Inc.
#
# This program is licensed to you under the terms of version 3 of the
# GNU Affero General Public License. This program is distributed WITHOUT
# ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING THOSE OF NON-INFRINGEMENT,
# MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. Please refer to the
# AGPL (http://www.gnu.org/licenses/agpl-3.0.txt) for more details.
#
#

# LIBR_FOUND
# LIBR_HOME
# LIBR_INCLUDE_DIRS
# LIBR_DOC_DIR
# LIBR_LIBRARIES

# detection for OSX (look for R framework)
if(APPLE)

   find_library(LIBR_LIBRARIES R)

   if(LIBR_LIBRARIES MATCHES ".*\\.framework")
      set(LIBR_HOME "${LIBR_LIBRARIES}/Resources" CACHE PATH "R home directory")
      set(LIBR_INCLUDE_DIRS "${LIBR_HOME}/include" CACHE PATH "R include directory")
      set(LIBR_DOC_DIR "${LIBR_HOME}/doc" CACHE PATH "R doc directory")
      set(LIBR_EXECUTABLE "${LIBR_HOME}/R" CACHE PATH "R executable")
   else()
      get_filename_component(_LIBR_LIBRARIES "${LIBR_LIBRARIES}" REALPATH)
      get_filename_component(_LIBR_LIBRARIES_DIR "${_LIBR_LIBRARIES}" DIRECTORY)
      set(LIBR_EXECUTABLE "${_LIBR_LIBRARIES_DIR}/../bin/R")
      execute_process(
         COMMAND ${LIBR_EXECUTABLE} "--slave" "--vanilla" "-e" "cat(R.home())"
                   OUTPUT_VARIABLE LIBR_HOME
      )
      set(LIBR_HOME ${LIBR_HOME} CACHE PATH "R home directory")
      set(LIBR_INCLUDE_DIRS "${LIBR_HOME}/include" CACHE PATH "R include directory")
      set(LIBR_DOC_DIR "${LIBR_HOME}/doc" CACHE PATH "R doc directory")
      set(LIBR_LIB_DIR "${LIBR_HOME}/lib" CACHE PATH "R lib directory")
   endif()

# detection for UNIX & Win32
else()

   # Find R executable and paths (UNIX)
   if(UNIX)

      # find executable
      find_program(LIBR_EXECUTABLE R)
      if(LIBR_EXECUTABLE-NOTFOUND)
         message(STATUS "Unable to locate R executable")
      endif()

      # ask R for the home path
      if(NOT LIBR_HOME)
         execute_process(
            COMMAND ${LIBR_EXECUTABLE} "--slave" "--vanilla" "-e" "cat(R.home())"
                      OUTPUT_VARIABLE LIBR_HOME
         )
         if(LIBR_HOME)
           set(LIBR_HOME ${LIBR_HOME} CACHE PATH "R home directory")
         endif()
      endif()

      # ask R for the include dir
      if(NOT LIBR_INCLUDE_DIRS)
         execute_process(
            COMMAND ${LIBR_EXECUTABLE} "--slave" "--no-save" "-e" "cat(R.home('include'))"
            OUTPUT_VARIABLE LIBR_INCLUDE_DIRS
         )
         if(LIBR_INCLUDE_DIRS)
           set(LIBR_INCLUDE_DIRS ${LIBR_INCLUDE_DIRS} CACHE PATH "R include directory")
         endif()
      endif()

      # ask R for the doc dir
      if(NOT LIBR_DOC_DIR)
         execute_process(
            COMMAND ${LIBR_EXECUTABLE} "--slave" "--no-save" "-e" "cat(R.home('doc'))"
            OUTPUT_VARIABLE LIBR_DOC_DIR
         )
         if(LIBR_DOC_DIR)
           set(LIBR_DOC_DIR ${LIBR_DOC_DIR} CACHE PATH "R doc directory")
         endif()
      endif()

      # ask R for the lib dir
      if(NOT LIBR_LIB_DIR)
         execute_process(
            COMMAND ${LIBR_EXECUTABLE} "--slave" "--no-save" "-e" "cat(R.home('lib'))"
            OUTPUT_VARIABLE LIBR_LIB_DIR
         )
      endif()

   # Find R executable and paths (Win32)
   else()

      # find the home path
      if(NOT LIBR_HOME)

         # read home from the registry
         get_filename_component(LIBR_HOME
            "[HKEY_LOCAL_MACHINE\\SOFTWARE\\R-core\\R;InstallPath]"
            ABSOLUTE CACHE)

         # print message if not found
         if(NOT LIBR_HOME)
            message(STATUS "Unable to locate R home (not written to registry)")
         endif()

      endif()

      # set other R paths based on home path
      set(LIBR_INCLUDE_DIRS "${LIBR_HOME}/include" CACHE PATH "R include directory")
      set(LIBR_DOC_DIR "${LIBR_HOME}/doc" CACHE PATH "R doc directory")

      # set library hint path based on whether  we are doing a special session 64 build
      if(LIBR_FIND_WINDOWS_64BIT)
         set(LIBRARY_ARCH_HINT_PATH "${LIBR_HOME}/bin/x64")
      else()
         set(LIBRARY_ARCH_HINT_PATH "${LIBR_HOME}/bin/i386")
      endif()

   endif()

   # look for the R executable
   find_program(LIBR_EXECUTABLE R
                HINTS ${LIBRARY_ARCH_HINT_PATH} ${LIBR_HOME}/bin)
   if(LIBR_EXECUTABLE-NOTFOUND)
      message(STATUS "Unable to locate R executable")
   endif()

   # look for the core R library
   find_library(LIBR_CORE_LIBRARY NAMES R
                HINTS ${LIBR_LIB_DIR} ${LIBRARY_ARCH_HINT_PATH} ${LIBR_HOME}/bin)
   if(LIBR_CORE_LIBRARY)
      set(LIBR_LIBRARIES ${LIBR_CORE_LIBRARY})
   else()
      message(STATUS "Could not find libR shared library.")
   endif()

   if(WIN32)
      # look for lapack
      find_library(LIBR_LAPACK_LIBRARY NAMES Rlapack
                   HINTS ${LIBR_LIB_DIR} ${LIBRARY_ARCH_HINT_PATH} ${LIBR_HOME}/bin)
      if(LIBR_LAPACK_LIBRARY)
         set(LIBR_LIBRARIES ${LIBR_LIBRARIES} ${LIBR_LAPACK_LIBRARY})
         if(UNIX)
            set(LIBR_LIBRARIES ${LIBR_LIBRARIES} gfortran)
         endif()
      endif()

      # look for blas
      find_library(LIBR_BLAS_LIBRARY NAMES Rblas
                   HINTS ${LIBR_LIB_DIR} ${LIBRARY_ARCH_HINT_PATH} ${LIBR_HOME}/bin)
      if(LIBR_BLAS_LIBRARY)
         set(LIBR_LIBRARIES ${LIBR_LIBRARIES} ${LIBR_BLAS_LIBRARY})
      endif()

      # look for rgraphapp
      find_library(LIBR_GRAPHAPP_LIBRARY NAMES Rgraphapp
                   HINTS ${LIBR_LIB_DIR} ${LIBRARY_ARCH_HINT_PATH} ${LIBR_HOME}/bin)
      if(LIBR_GRAPHAPP_LIBRARY)
         set(LIBR_LIBRARIES ${LIBR_LIBRARIES} ${LIBR_GRAPHAPP_LIBRARY})
      endif()
   endif()

   # cache LIBR_LIBRARIES
   if(LIBR_LIBRARIES)
      set(LIBR_LIBRARIES ${LIBR_LIBRARIES} CACHE PATH "R runtime libraries")
   endif()

endif()

# define find requirements
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(LibR DEFAULT_MSG
   LIBR_HOME
   LIBR_EXECUTABLE
   LIBR_INCLUDE_DIRS
   LIBR_LIBRARIES
   LIBR_DOC_DIR
)

if(LIBR_FOUND)
   message(STATUS "Found R: ${LIBR_HOME}")
endif()

# mark low-level variables from FIND_* calls as advanced
mark_as_advanced(
   LIBR_CORE_LIBRARY
   LIBR_LAPACK_LIBRARY
   LIBR_BLAS_LIBRARY
)
