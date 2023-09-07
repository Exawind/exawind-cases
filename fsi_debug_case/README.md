This is a small, nalu-wind only, case that only requires one rank to run.
It is blade like cylinders in a laminar flow with open 
boundary conditions where the overset interface normally is.


It runs the problem in two configurations simultaneously:
using FSI and using mesh-motion.

The FSI case has pitch to make sure mesh deformation can happen
however as the simulations start they should be virtually the same.
This way we can test FSI against a similar code path to compare solver convergence
and results.

The output files can also be compared via exodiff for debugging purposes.

