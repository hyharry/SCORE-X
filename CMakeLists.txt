cmake_minimum_required(VERSION 3.16)

project(SCORE LANGUAGES C CXX)

# Compatibility-focused revival CMake setup for modern Linux toolchains.
# The original CMake file assumed manually edited absolute paths, Intel compiler,
# and a locally built static HDF5 tree.

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

option(SCORE_ENABLE_OPENMP "Enable OpenMP" ON)
option(SCORE_WARNINGS "Enable warning flags" ON)

find_package(MPI REQUIRED COMPONENTS CXX)
find_package(HDF5 REQUIRED COMPONENTS C HL)

if(SCORE_ENABLE_OPENMP)
  find_package(OpenMP)
endif()

set(SCORE_SOURCES
  src/thirdparty/lodepng.cpp
  src/SCORE_Random.cpp
  src/SCORE_Math.cpp
  src/SCORE_Io.cpp
  src/SCORE_PercAnalyzer.cpp
  src/SCORE_EBSDImporting.cpp
  src/SCORE_GridPartitioning.cpp
  src/SCORE_OrientationHdl.cpp
  src/SCORE_GrainBoundaryPhysics.cpp
  src/SCORE_RecoveryModels.cpp
  src/SCORE_NucleationModels.cpp
  src/SCORE_GeneralPhysics.cpp
  src/SCORE_JunctionHdl.cpp
  src/SCORE_StructureSynthesis.cpp
  src/SCORE_GrowthMachine.cpp
  src/SCORE_OnTheFlyCharacterization.cpp
  src/SCORE_Io_HDF5.cpp
  src/SCORE_Io_Characterization.cpp
  src/SCORE_SolitaryUnitAveraging.cpp
  src/SCORE_Kernel.cpp
  src/SCORE_Main.cpp
)

add_executable(score ${SCORE_SOURCES})

target_include_directories(score
  PRIVATE
    src
    src/thirdparty
    ${MPI_CXX_INCLUDE_DIRS}
    ${HDF5_INCLUDE_DIRS}
)

target_link_libraries(score
  PRIVATE
    MPI::MPI_CXX
    ${HDF5_LIBRARIES}
)

if(SCORE_ENABLE_OPENMP AND OpenMP_CXX_FOUND)
  target_link_libraries(score PRIVATE OpenMP::OpenMP_CXX)
endif()

if(SCORE_WARNINGS)
  target_compile_options(score PRIVATE
    -Wall
    -Wextra
    -Wno-unused-parameter
    -Wno-unused-variable
    -Wno-unused-function
    -Wno-sign-compare
    -Wno-reorder
  )
endif()

message(STATUS "MPI CXX compiler: ${MPI_CXX_COMPILER}")
message(STATUS "HDF5 include dirs: ${HDF5_INCLUDE_DIRS}")
