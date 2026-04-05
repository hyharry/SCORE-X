# SCORE
MPI-parallelized cellular automaton ensemble model for the simulation of primary recrystallization phenomena in 3D

## Revival note (2026-04)

This fork contains a compatibility-oriented CMake refresh for modern Linux systems.
See `docs/REVIVAL_NOTES.md` for build assumptions, what changed, verification commands, and remaining blockers.

### Building without system HDF5 packages (user-space)

If HDF5 development headers/libraries are missing on your host, build a local copy in this project:

```bash
./scripts/build_local_hdf5.sh
cmake -S . -B build/revival -DSCORE_HDF5_ROOT=$PWD/.deps/hdf5
cmake --build build/revival -j
```

`SCORE_HDF5_ROOT` is optional if `.deps/hdf5` exists; CMake will auto-detect that local prefix.

### Minimal runtime smoke test (current revival status)

A parser-compatible sample input for smoke checks is provided at:

- `example/smoke/SCORE.Smoke.uds`

Run:

```bash
mpiexec -n 1 ./build/revival/score 42 example/smoke/SCORE.Smoke.uds
```

Expected current behavior (2026-04 revival snapshot): the binary passes startup and parameter initialization, enters the simulation loop, then crashes with a segmentation fault after the first reported step. This still validates a non-trivial runtime path beyond build/link.

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
