To swap between the different beamdyn blades, simply replace line 78 in IEA-15-240-RWT_BeamDyn.dat:

"IEA-15-240-RWT_BeamDyn_blade.dat"    BldFile - Name of file containing properties for blade (quoted string)

"IEA-15-240-RWT_BeamDyn_blade_double_damping.dat"    BldFile - Name of file containing properties for blade (quoted string)

"IEA-15-240-RWT_BeamDyn_blade_tipmass.dat"    BldFile - Name of file containing properties for blade (quoted string)


Note: the tip mass was increased by about 10 kg, simply by multiplying the mass components of the mass matrix (see the beamdyn manual) by 3.0.