# SCORE
MPI-parallelized cellular automaton ensemble model for the simulation of primary recrystallization phenomena in 3D

## Revival note (2026-04)

This fork contains a compatibility-oriented CMake refresh for modern Linux systems.
See `docs/REVIVAL_NOTES.md` for build assumptions, what changed, verification commands, and remaining blockers.

### Building without system HDF5 packages (user-space)

If HDF5 development headers/libraries are missing on your host, build a local copy in this project:

```bash
./scripts/build_local_hdf5.sh            # default: 1.14.5
# ./scripts/build_local_hdf5.sh 1.14.4   # optional: pick another 1.14.x version
cmake -S . -B build/revival -DSCORE_HDF5_ROOT=$PWD/.deps/hdf5
cmake --build build/revival -j
```

Optional: register a CTest smoke test during configure:

```bash
cmake -S . -B build/revival -DSCORE_HDF5_ROOT=$PWD/.deps/hdf5 -DSCORE_ENABLE_SMOKE_TEST=ON
ctest --test-dir build/revival --output-on-failure
```

`SCORE_HDF5_ROOT` is optional if `.deps/hdf5` exists; CMake will auto-detect that local prefix.

### Minimal runtime smoke test (current revival status)

A parser-compatible sample input for smoke checks is provided at:

- `example/smoke/SCORE.Smoke.uds`

Run:

```bash
mpiexec -n 1 ./build/revival/score 42 example/smoke/SCORE.Smoke.uds
```

Current behavior (2026-04 revival snapshot): this smoke test now runs to completion without a crash (exit code 0), reaching `Simulation finished with some new insights into pRX, skal!`.

Why this is a reasonable legacy-faithful smoke input:
- it keeps the original legacy UDS block layout and keyword style used by SCORE (`RuntimeControl`, `SimulationOutput`, `EnsembleDefinition`, etc.),
- it is derived from the repository's own template input (`example/jmak/SCORE.Input.TemplateIron.uds`) but reduced to a small, fast domain,
- it exercises real simulation stepping and on-the-fly logging, not just parser startup.

A detailed documentation of the model and the program is available under:
http://score.readthedocs.org/en/master/

The authors of SCORE gratefully acknowledge the financial support from the Deutsche Forschungsgemeinschaft (DFG) within the "Reinhart Koselleck-Project" (GO 335/44-1) and the granting of computing time which was provided by the RWTH Aachen University JARAHPC research alliance (JARA0076).

The authors of SCORE gratefully acknowledge the financial support from the Max-Planck-Gesellschaft through the provisioning of computing time grants
in the frame of the BiGmax, the Max-Planck-Society's Research Network on Big-Data-Driven Materials Science.


Latest bugfixes:
- 2016/01/13: uncomment the line #define DEBUG in src/SCORE_Io.h when utilizing the GNU compiler
- 2019/02/23: we implemented a right-handed coordinate system and made modifications to use the code
for the following paper. Now it is required that the code gets linked to a static local installation of the
Hierarchical Data Format 5 (HDF5) library.
M. Diehl and M. Kuehbach, Coupled experimental-computational analysis of primary static recrystallization in low carbon steel",
Modelling and Simulation in Materials Science and Engineering, 28, 2020, http://doi.org/10.1088/1361-651X/ab51bd
Further details to this study and example input data are available here: http://www.zenodo.org/record/2540525
