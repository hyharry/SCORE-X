#!/usr/bin/env bash
set -euo pipefail

# Build a local, user-space HDF5 installation for SCORE.
# This avoids requiring root package installation.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEPS_DIR="${ROOT_DIR}/.deps"
SRC_DIR="${DEPS_DIR}/src"
BUILD_DIR="${DEPS_DIR}/build/hdf5"
VERSION="${1:-1.14.5}"
PREFIX="${DEPS_DIR}/hdf5"
TARBALL="hdf5-${VERSION}.tar.gz"
URL="https://support.hdfgroup.org/releases/hdf5/v1_14/v1_14_5/downloads/${TARBALL}"

mkdir -p "${SRC_DIR}" "${BUILD_DIR}"

if [[ ! -f "${SRC_DIR}/${TARBALL}" ]]; then
  echo "[hdf5] Downloading ${URL}"
  curl -fL "${URL}" -o "${SRC_DIR}/${TARBALL}"
fi

if [[ ! -d "${SRC_DIR}/hdf5-${VERSION}" ]]; then
  echo "[hdf5] Extracting ${TARBALL}"
  tar -xzf "${SRC_DIR}/${TARBALL}" -C "${SRC_DIR}"
fi

echo "[hdf5] Configuring local build"
cmake -S "${SRC_DIR}/hdf5-${VERSION}" -B "${BUILD_DIR}" \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX="${PREFIX}" \
  -DBUILD_TESTING=OFF \
  -DHDF5_BUILD_EXAMPLES=OFF \
  -DHDF5_BUILD_TOOLS=OFF \
  -DHDF5_BUILD_CPP_LIB=OFF \
  -DHDF5_BUILD_FORTRAN=OFF \
  -DHDF5_ENABLE_PARALLEL=OFF \
  -DHDF5_BUILD_HL_LIB=ON

echo "[hdf5] Building and installing to ${PREFIX}"
cmake --build "${BUILD_DIR}" -j"$(nproc)"
cmake --install "${BUILD_DIR}"

echo "[hdf5] Done. Configure SCORE with:"
echo "  cmake -S . -B build/revival -DSCORE_HDF5_ROOT=${PREFIX}"
