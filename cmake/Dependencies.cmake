IF(${CONDOR})
  include_directories(SYSTEM ${AVHOME}/utils/caffe-64/include)
ENDIF()
# This list is required for static linking and exported to CaffeConfig.cmake
set(Caffe_LINKER_LIBS "")

# ---[ Boost
find_package(Boost 1.46 REQUIRED COMPONENTS system thread filesystem)
include_directories(SYSTEM ${Boost_INCLUDE_DIR})
list(APPEND Caffe_LINKER_LIBS ${Boost_LIBRARIES})

# ---[ Threads
find_package(Threads REQUIRED)
list(APPEND Caffe_LINKER_LIBS ${CMAKE_THREAD_LIBS_INIT})

# ---[ Google-glog
IF(${CONDOR})
  list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/caffe-64/lib/libglog.so)
ELSE()
  include("cmake/External/glog.cmake")
  include_directories(SYSTEM ${GLOG_INCLUDE_DIRS})
  list(APPEND Caffe_LINKER_LIBS ${GLOG_LIBRARIES})
ENDIF()

# ---[ Google-gflags
IF(${CONDOR})
  list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/caffe-64/lib/libgflags.so)
ELSE()
  MESSAGE(FATAL_ERROR ${CONDOR})
  include("cmake/External/gflags.cmake")
  include_directories(SYSTEM ${GFLAGS_INCLUDE_DIRS})
  list(APPEND Caffe_LINKER_LIBS ${GFLAGS_LIBRARIES})
ENDIF()

# ---[ Google-protobuf
include(cmake/ProtoBuf.cmake)

# ---[ HDF5
IF(${CONDOR})
  include_directories(SYSTEM ${AVHOME}/utils/caffe-64/include/hdf5)
  list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/caffe-64/lib/libsz.so)
  list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/caffe-64/lib/libaec.so.0)
  list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/caffe-64/lib/libhdf5_cpp.so)
  list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/caffe-64/lib/libhdf5_hl.so)
ELSE()
  find_package(HDF5 COMPONENTS HL REQUIRED)
  include_directories(SYSTEM ${HDF5_INCLUDE_DIRS} ${HDF5_HL_INCLUDE_DIR})
  list(APPEND Caffe_LINKER_LIBS ${HDF5_LIBRARIES})
ENDIF()

# ---[ LMDB
if(USE_LMDB)
  IF(${CONDOR})
    list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/caffe-64/lib/liblmdb.so)
  ELSE()
    find_package(LMDB REQUIRED)
    include_directories(SYSTEM ${LMDB_INCLUDE_DIR})
    list(APPEND Caffe_LINKER_LIBS ${LMDB_LIBRARIES})
  ENDIF()
  add_definitions(-DUSE_LMDB)
  if(ALLOW_LMDB_NOLOCK)
    add_definitions(-DALLOW_LMDB_NOLOCK)
  endif()
endif()

# ---[ LevelDB
if(USE_LEVELDB)
  IF(${CONDOR})
    list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/caffe-64/lib/libleveldb.so)
  ELSE()
    find_package(LevelDB REQUIRED)
    include_directories(SYSTEM ${LevelDB_INCLUDE})
    list(APPEND Caffe_LINKER_LIBS ${LevelDB_LIBRARIES})
  ENDIF()
  add_definitions(-DUSE_LEVELDB)
endif()

# ---[ Snappy
if(USE_LEVELDB)
  IF(${CONDOR})
    list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/caffe-64/lib/libsnappy.so)
  ELSE()
    find_package(Snappy REQUIRED)
    include_directories(SYSTEM ${Snappy_INCLUDE_DIR})
    list(APPEND Caffe_LINKER_LIBS ${Snappy_LIBRARIES})
  ENDIF()
endif()

# ---[ CUDA
include(cmake/Cuda.cmake)
if(NOT HAVE_CUDA)
  if(CPU_ONLY)
    message(STATUS "-- CUDA is disabled. Building without it...")
  else()
    message(WARNING "-- CUDA is not detected by cmake. Building without it...")
  endif()

  # TODO: remove this not cross platform define in future. Use caffe_config.h instead.
  add_definitions(-DCPU_ONLY)
endif()

# ---[ OpenCV
if(USE_OPENCV)
  IF(${CONDOR})
    SET(OpenCV_INCLUDE_DIRS ${AVHOME}/utils/opencv2-64/include)
    list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/opencv2-64/lib/libopencv_core.so)
    list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/opencv2-64/lib/libopencv_highgui.so)
    list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/opencv2-64/lib/libopencv_imgproc.so)
    # this doesn't seem to exist
    # list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/opencv2-64/lib/libopencv_imgcodecs.so)
    list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/opencv2-64/lib/libopencv_core.so)
  ELSE()
    find_package(OpenCV QUIET COMPONENTS core highgui imgproc imgcodecs)
    if(NOT OpenCV_FOUND) # if not OpenCV 3.x, then imgcodecs are not found
      find_package(OpenCV REQUIRED COMPONENTS core highgui imgproc)
    endif()
    list(APPEND Caffe_LINKER_LIBS ${OpenCV_LIBS})
    message(STATUS "OpenCV found (${OpenCV_CONFIG_PATH})")
  ENDIF()
  include_directories(SYSTEM ${OpenCV_INCLUDE_DIRS})
  add_definitions(-DUSE_OPENCV)
endif()

# ---[ BLAS
if(NOT APPLE)
  IF(${CONDOR})
    include_directories(SYSTEM ${AVHOME}/utils/caffe-64/include/openblas)
    list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/caffe-64/lib/libblas.so)
    list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/caffe-64/lib/libcblas.so)
    list(APPEND Caffe_LINKER_LIBS ${AVHOME}/utils/caffe-64/lib/libatlas.so)
  ELSE()
    set(BLAS "Atlas" CACHE STRING "Selected BLAS library")
    set_property(CACHE BLAS PROPERTY STRINGS "Atlas;Open;MKL")

    if(BLAS STREQUAL "Atlas" OR BLAS STREQUAL "atlas")
      find_package(Atlas REQUIRED)
      include_directories(SYSTEM ${Atlas_INCLUDE_DIR})
      list(APPEND Caffe_LINKER_LIBS ${Atlas_LIBRARIES})
    elseif(BLAS STREQUAL "Open" OR BLAS STREQUAL "open")
      find_package(OpenBLAS REQUIRED)
      include_directories(SYSTEM ${OpenBLAS_INCLUDE_DIR})
      list(APPEND Caffe_LINKER_LIBS ${OpenBLAS_LIB})
    elseif(BLAS STREQUAL "MKL" OR BLAS STREQUAL "mkl")
      find_package(MKL REQUIRED)
      include_directories(SYSTEM ${MKL_INCLUDE_DIR})
      list(APPEND Caffe_LINKER_LIBS ${MKL_LIBRARIES})
      add_definitions(-DUSE_MKL)
    endif()
  ENDIF()
elseif(APPLE)
  find_package(vecLib REQUIRED)
  include_directories(SYSTEM ${vecLib_INCLUDE_DIR})
  list(APPEND Caffe_LINKER_LIBS ${vecLib_LINKER_LIBS})
endif()

# ---[ Python
if(BUILD_python)
  if(NOT "${python_version}" VERSION_LESS "3.0.0")
    # use python3
    find_package(PythonInterp 3.0)
    find_package(PythonLibs 3.0)
    find_package(NumPy 1.7.1)
    # Find the matching boost python implementation
    set(version ${PYTHONLIBS_VERSION_STRING})
    
    STRING( REGEX REPLACE "[^0-9]" "" boost_py_version ${version} )
    find_package(Boost 1.46 COMPONENTS "python-py${boost_py_version}")
    set(Boost_PYTHON_FOUND ${Boost_PYTHON-PY${boost_py_version}_FOUND})
    
    while(NOT "${version}" STREQUAL "" AND NOT Boost_PYTHON_FOUND)
      STRING( REGEX REPLACE "([0-9.]+).[0-9]+" "\\1" version ${version} )
      
      STRING( REGEX REPLACE "[^0-9]" "" boost_py_version ${version} )
      find_package(Boost 1.46 COMPONENTS "python-py${boost_py_version}")
      set(Boost_PYTHON_FOUND ${Boost_PYTHON-PY${boost_py_version}_FOUND})
      
      STRING( REGEX MATCHALL "([0-9.]+).[0-9]+" has_more_version ${version} )
      if("${has_more_version}" STREQUAL "")
        break()
      endif()
    endwhile()
    if(NOT Boost_PYTHON_FOUND)
      find_package(Boost 1.46 COMPONENTS python)
    endif()
  else()
    # disable Python 3 search
    find_package(PythonInterp 2.7)
    find_package(PythonLibs 2.7)
    find_package(NumPy 1.7.1)
    find_package(Boost 1.46 COMPONENTS python)
  endif()
  if(PYTHONLIBS_FOUND AND NUMPY_FOUND AND Boost_PYTHON_FOUND)
    set(HAVE_PYTHON TRUE)
    if(BUILD_python_layer)
      add_definitions(-DWITH_PYTHON_LAYER)
      include_directories(SYSTEM ${PYTHON_INCLUDE_DIRS} ${NUMPY_INCLUDE_DIR} ${Boost_INCLUDE_DIRS})
      list(APPEND Caffe_LINKER_LIBS ${PYTHON_LIBRARIES} ${Boost_LIBRARIES})
    endif()
  endif()
endif()

# ---[ Matlab
if(BUILD_matlab)
  find_package(MatlabMex)
  if(MATLABMEX_FOUND)
    set(HAVE_MATLAB TRUE)
  endif()

  # sudo apt-get install liboctave-dev
  find_program(Octave_compiler NAMES mkoctfile DOC "Octave C++ compiler")

  if(HAVE_MATLAB AND Octave_compiler)
    set(Matlab_build_mex_using "Matlab" CACHE STRING "Select Matlab or Octave if both detected")
    set_property(CACHE Matlab_build_mex_using PROPERTY STRINGS "Matlab;Octave")
  endif()
endif()

# ---[ Doxygen
if(BUILD_docs)
  find_package(Doxygen)
endif()
