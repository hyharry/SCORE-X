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
MAJOR_MINOR="$(cut -d. -f1,2 <<<"${VERSION}")"
MAJOR_MINOR_UNDERSCORE="${MAJOR_MINOR//./_}"
VERSION_UNDERSCORE="${VERSION//./_}"
URL="https://support.hdfgroup.org/releases/hdf5/v${MAJOR_MINOR_UNDERSCORE}/v${VERSION_UNDERSCORE}/downloads/${TARBALL}"

for cmd in curl cmake tar; do
  if ! command -v "${cmd}" >/dev/null 2>&1; then
    echo "[hdf5] Missing required command: ${cmd}" >&2
    exit 1
  fi
done

mkdir -p "${SRC_DIR}"

# Reconfigure cleanly when a previous build directory was created for another version.
if [[ -f "${BUILD_DIR}/CMakeCache.txt" ]] && ! grep -q "hdf5-${VERSION}" "${BUILD_DIR}/CMakeCache.txt"; then
  echo "[hdf5] Detected stale build directory, removing ${BUILD_DIR}"
  rm -rf "${BUILD_DIR}"
fi
mkdir -p "${BUILD_DIR}"

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

if command -v nproc >/dev/null 2>&1; then
  JOBS="$(nproc)"
elif command -v getconf >/dev/null 2>&1; then
  JOBS="$(getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)"
else
  JOBS=1
fi

echo "[hdf5] Building and installing to ${PREFIX} (jobs=${JOBS})"
cmake --build "${BUILD_DIR}" -j"${JOBS}"
cmake --install "${BUILD_DIR}"

echo "[hdf5] Done. Configure SCORE with:"
echo "  cmake -S . -B build/revival -DSCORE_HDF5_ROOT=${PREFIX}"
