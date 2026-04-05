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
   - supports a user-space HDF5 prefix via `SCORE_HDF5_ROOT`,
   - auto-detects a project-local `.deps/hdf5` prefix when present,
   - optionally enables OpenMP,
   - keeps warning flags modest and readable.
2. Added `scripts/build_local_hdf5.sh` to build/install HDF5 in user space (`.deps/hdf5`) without root access.
3. Added `.steps/` tracking folder and ignored it in `.gitignore`.
4. Added a short pointer and local-HDF5 build instructions in `README.md`.

## Verification performed (real commands)

Executed in project root:

```bash
./scripts/build_local_hdf5.sh
cmake -S . -B build/revival -DSCORE_HDF5_ROOT=$PWD/.deps/hdf5
cmake --build build/revival -j$(nproc)
```

Observed results:

- Local HDF5 (v1.14.5) was built and installed successfully into `.deps/hdf5` in user space.
- CMake configure succeeds and finds HDF5 from that local prefix:
  - `Found HDF5: hdf5-shared (found version "1.14.5") found components: C HL`
- Initial compile then exposed portability issues unrelated to dependency install:
  - GNU/Linux build failure from `__int64` type usage,
  - missing `<limits>` include where `std::numeric_limits` is used.
- Applied minimal compatibility fixes:
  - replaced `__int64` with `MPI_Offset` in MPI I/O code paths,
  - added `<limits>` include in `SCORE_SolitaryUnitAveraging.cpp`.
- Rebuild after these fixes completes successfully (`Built target score`).

## Current build/run status

- Source tree imports and configures cleanly on this host.
- User-space local HDF5 dependency strategy is working and reproducible.
- Full compile now succeeds with GCC/OpenMPI + local HDF5.
- Remaining output is warning-only (legacy code quality warnings), not build blockers.

## Remaining blockers / risks

### No immediate hard blocker

- There is no current configure/compile blocker in this environment after local HDF5 and portability fixes.

### Remaining risk

- Runtime behavior with real example datasets is not yet smoke-tested in this revival pass.
- A cleanup pass may eventually address warning noise (unused vars, narrowing, legacy asserts), but this is optional for functionality.

## Suggested next compatibility steps

1. Run a smoke test with one example input setup under `example/` to validate runtime behavior.
2. Optionally reduce warning noise in small, focused patches.
3. If parallel HDF5 I/O becomes a requirement later, add a parallel-HDF5 build option in `scripts/build_local_hdf5.sh` and validate against MPI-HDF5 APIs.
