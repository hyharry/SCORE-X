# SCORE revival notes (compatibility-first)

## What this project is

SCORE is a legacy MPI-parallelized cellular automaton codebase for 3D primary recrystallization simulation (materials science / microstructure evolution).

Upstream repository: <https://github.com/mkuehbach/SCORE>

## Original build assumptions discovered

From upstream `CMakeLists.txt` and comments:

- Build system expected **manual edits** before each build.
- Hardcoded absolute source path: `MYSRCPATH "/home/m.kuehbach/SCOREDiehl/src/"`.
- Default compiler selection was **Intel** (`EMPLOY_INTELCOMPILER ON`).
- GNU build path existed but was disabled by default.
- HDF5 was expected as a **manually built local static installation**, with hardcoded include/lib paths.
- MPI was required (`find_package(MPI REQUIRED)`).

## What was changed in this revival attempt

1. Replaced top-level `CMakeLists.txt` with a compatibility-focused version that:
   - uses in-tree `src/` files directly (no hardcoded absolute source path),
   - builds target `score`,
   - requires C/C++11 and modern CMake,
   - finds MPI via CMake (`find_package(MPI REQUIRED COMPONENTS CXX)`),
   - finds HDF5 via CMake (`find_package(HDF5 REQUIRED COMPONENTS C HL)`),
   - optionally enables OpenMP,
   - keeps warning flags modest and readable.
2. Added `.steps/` tracking folder and ignored it in `.gitignore`.
3. Added a short pointer in `README.md` to this revival status document.

## Verification performed (real commands)

Executed in project root:

```bash
git clone https://github.com/mkuehbach/SCORE.git re-score
cmake -S . -B build/revival
```

Observed results:

- `mpicxx` is present (`/usr/bin/mpicxx`, GCC 11.4 wrapper).
- CMake configure currently **fails** due to missing HDF5 development package/headers:
  - `Could NOT find HDF5 (missing: HDF5_LIBRARIES HDF5_INCLUDE_DIRS HDF5_HL_LIBRARIES C HL)`
- Runtime HDF5 libs are installed, but development package is not (`libhdf5-openmpi-dev` not installed).

## Current build/run status

- Source tree imported successfully.
- Build system modernization patch is in place.
- Full compile on this machine is currently **blocked** by missing HDF5 development dependencies.
- No claim of successful executable build is made.

## Remaining blockers / risks

### Immediate blocker

- Missing HDF5 development files (headers + dev CMake/pkg-config metadata), likely solved by installing:

```bash
sudo apt-get update
sudo apt-get install -y libhdf5-openmpi-dev
```

### Follow-up risk after dependency install

- Additional compile issues may appear due to code age and stricter modern compilers; these should be handled incrementally with minimal, focused patches.

## Suggested next compatibility steps

1. Install `libhdf5-openmpi-dev`.
2. Re-run:
   ```bash
   cmake -S . -B build/revival
   cmake --build build/revival -j
   ```
3. If compile errors surface, patch minimally (warnings/includes/API drift only), avoiding architectural rewrites.
4. Smoke-test with one of the provided example input setups and document expected/observed runtime behavior.
