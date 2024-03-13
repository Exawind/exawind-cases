# state file generated using paraview version 5.10.1

# uncomment the following three lines to ensure this script works in future versions
#import paraview
#paraview.compatibility.major = 5
#paraview.compatibility.minor = 10

#### import the simple module from the paraview
from paraview.simple import *
import glob
#### disable automatic camera reset on 'Show'
paraview.simple._DisableFirstRenderCameraReset()
import sys

mean_vel = float(sys.argv[1])
# ----------------------------------------------------------------
# setup views used in the visualization
# ----------------------------------------------------------------

# get the material library
materialLibrary1 = GetMaterialLibrary()

# Create a new 'Render View'
renderView1 = CreateView('RenderView')
renderView1.ViewSize = [1740, 927]
renderView1.AxesGrid = 'GridAxes3DActor'
renderView1.CenterOfRotation = [960.0, 11.995363974272887, 0.0]
renderView1.StereoType = 'Crystal Eyes'
renderView1.CameraPosition = [365.4048258117854, -4519.783631554194, 46.42516053980262]
renderView1.CameraFocalPoint = [-141.1487298918187, 5974.098424468341, -84.00479691681406]
renderView1.CameraViewUp = [0.0, 0.0, 1.0]
renderView1.CameraViewAngle = 2.9827586206896552
renderView1.CameraFocalDisk = 1.0
renderView1.CameraParallelScale = 2900.368707248313
renderView1.BackEnd = 'OSPRay raycaster'
renderView1.OSPRayMaterialLibrary = materialLibrary1

SetActiveView(None)

# ----------------------------------------------------------------
# setup view layouts
# ----------------------------------------------------------------

# create new layout object 'Layout #1'
layout1 = CreateLayout(name='Layout #1')
layout1.AssignView(0, renderView1)
layout1.SetSize(1740, 927)

# ----------------------------------------------------------------
# restore active view
SetActiveView(renderView1)
# ----------------------------------------------------------------

# ----------------------------------------------------------------
# setup the data processing pipelines
# ----------------------------------------------------------------

# create a new 'AMReX/BoxLib Grid Reader'
plt46080 = AMReXBoxLibGridReader(registrationName='plt46080', FileNames=['plt46080'])
plt46080.Level = 5
plt46080.CellArrayStatus = ['density', 'gpx', 'gpy', 'gpz', 'iblank_cell', 'mu_turb', 'p', 'q_criterion', 'sdr', 'tke', 'velocity_mueff', 'velocityx', 'velocityy', 'velocityz']

# create a new 'Cell Data to Point Data'
cellDatatoPointData1 = CellDatatoPointData(registrationName='CellDatatoPointData1', Input=plt46080)
cellDatatoPointData1.CellDataArraytoprocess = ['density', 'gpx', 'gpy', 'gpz', 'iblank_cell', 'mu_turb', 'p', 'q_criterion', 'sdr', 'tke', 'velocity_mueff', 'velocityx', 'velocityy', 'velocityz', 'vtkGhostType']

# create a new 'Slice'
slice1 = Slice(registrationName='Slice1', Input=cellDatatoPointData1)
slice1.SliceType = 'Plane'
slice1.HyperTreeGridSlicer = 'Plane'
slice1.Triangulatetheslice = 0
slice1.SliceOffsetValues = [0.0]

# init the 'Plane' selected for 'SliceType'
slice1.SliceType.Origin = [960.0, 0.0, 0.0]
slice1.SliceType.Normal = [0.0, 1.0, 0.0]

# init the 'Plane' selected for 'HyperTreeGridSlicer'
slice1.HyperTreeGridSlicer.Origin = [960.0, 0.0, 0.0]

# create a new 'IOSS Reader'
nalu_output_files = glob.glob('out01/*')
nrel5mwe720 = IOSSReader(registrationName='nrel5mw.e.720.*', FileName=nalu_output_files)

nrel5mwe720.ElementBlocks = []
nrel5mwe720.NodeBlockFields = ['mesh_displacement']
nrel5mwe720.ElementBlockFields = []
nrel5mwe720.SideSets = ['blade1', 'blade2', 'blade3']

# create a new 'Warp By Vector'
warpByVector1 = WarpByVector(registrationName='WarpByVector1', Input=nrel5mwe720)
warpByVector1.Vectors = ['POINTS', 'mesh_displacement']

# ----------------------------------------------------------------
# setup the visualization in view 'renderView1'
# ----------------------------------------------------------------

# show data from slice1
slice1Display = Show(slice1, renderView1, 'GeometryRepresentation')

# get color transfer function/color map for 'velocityx'
velocityxLUT = GetColorTransferFunction('velocityx')
velocityxLUT.RGBPoints = [4.120133053483306/10.0*mean_vel, 0.231373, 0.298039, 0.752941, 7.623561836431241/10.0*mean_vel, 0.865003, 0.865003, 0.865003, 11.126990619379177/10.0*mean_vel, 0.705882, 0.0156863, 0.14902]
velocityxLUT.ScalarRangeInitialized = 1.0

# trace defaults for the display properties.
slice1Display.Representation = 'Surface'
slice1Display.ColorArrayName = ['POINTS', 'velocityx']
slice1Display.LookupTable = velocityxLUT
slice1Display.Opacity = 0.69
slice1Display.SelectTCoordArray = 'None'
slice1Display.SelectNormalArray = 'None'
slice1Display.SelectTangentArray = 'None'
slice1Display.OSPRayScaleArray = 'density'
slice1Display.OSPRayScaleFunction = 'PiecewiseFunction'
slice1Display.SelectOrientationVectors = 'None'
slice1Display.ScaleFactor = 528.0
slice1Display.SelectScaleArray = 'None'
slice1Display.GlyphType = 'Arrow'
slice1Display.GlyphTableIndexArray = 'None'
slice1Display.GaussianRadius = 26.400000000000002
slice1Display.SetScaleArray = ['POINTS', 'density']
slice1Display.ScaleTransferFunction = 'PiecewiseFunction'
slice1Display.OpacityArray = ['POINTS', 'density']
slice1Display.OpacityTransferFunction = 'PiecewiseFunction'
slice1Display.DataAxesGrid = 'GridAxesRepresentation'
slice1Display.PolarAxes = 'PolarAxesRepresentation'

# init the 'PiecewiseFunction' selected for 'ScaleTransferFunction'
slice1Display.ScaleTransferFunction.Points = [1.225, 0.0, 0.5, 0.0, 1.225244164466858, 1.0, 0.5, 0.0]

# init the 'PiecewiseFunction' selected for 'OpacityTransferFunction'
slice1Display.OpacityTransferFunction.Points = [1.225, 0.0, 0.5, 0.0, 1.225244164466858, 1.0, 0.5, 0.0]

# show data from warpByVector1
warpByVector1Display = Show(warpByVector1, renderView1, 'UnstructuredGridRepresentation')

# get color transfer function/color map for 'vtkBlockColors'
vtkBlockColorsLUT = GetColorTransferFunction('vtkBlockColors')
vtkBlockColorsLUT.InterpretValuesAsCategories = 1
vtkBlockColorsLUT.AnnotationsInitialized = 1
vtkBlockColorsLUT.Annotations = ['0', '0', '1', '1', '2', '2', '3', '3', '4', '4', '5', '5', '6', '6', '7', '7', '8', '8', '9', '9', '10', '10', '11', '11']
vtkBlockColorsLUT.ActiveAnnotatedValues = ['3', '4', '5']
vtkBlockColorsLUT.IndexedColors = [1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.63, 0.63, 1.0, 0.67, 0.5, 0.33, 1.0, 0.5, 0.75, 0.53, 0.35, 0.7, 1.0, 0.75, 0.5]

# get opacity transfer function/opacity map for 'vtkBlockColors'
vtkBlockColorsPWF = GetOpacityTransferFunction('vtkBlockColors')

# trace defaults for the display properties.
warpByVector1Display.Representation = 'Surface'
warpByVector1Display.ColorArrayName = ['FIELD', 'vtkBlockColors']
warpByVector1Display.LookupTable = vtkBlockColorsLUT
warpByVector1Display.SelectTCoordArray = 'None'
warpByVector1Display.SelectNormalArray = 'None'
warpByVector1Display.SelectTangentArray = 'None'
warpByVector1Display.OSPRayScaleArray = 'ids'
warpByVector1Display.OSPRayScaleFunction = 'PiecewiseFunction'
warpByVector1Display.SelectOrientationVectors = 'None'
warpByVector1Display.ScaleFactor = 10.754198668197454
warpByVector1Display.SelectScaleArray = 'None'
warpByVector1Display.GlyphType = 'Arrow'
warpByVector1Display.GlyphTableIndexArray = 'None'
warpByVector1Display.GaussianRadius = 0.5377099334098726
warpByVector1Display.SetScaleArray = ['POINTS', 'ids']
warpByVector1Display.ScaleTransferFunction = 'PiecewiseFunction'
warpByVector1Display.OpacityArray = ['POINTS', 'ids']
warpByVector1Display.OpacityTransferFunction = 'PiecewiseFunction'
warpByVector1Display.DataAxesGrid = 'GridAxesRepresentation'
warpByVector1Display.PolarAxes = 'PolarAxesRepresentation'
warpByVector1Display.ScalarOpacityFunction = vtkBlockColorsPWF
warpByVector1Display.ScalarOpacityUnitDistance = 2.9371320391206934
warpByVector1Display.OpacityArrayName = ['POINTS', 'ids']

# init the 'PiecewiseFunction' selected for 'ScaleTransferFunction'
warpByVector1Display.ScaleTransferFunction.Points = [91569.0, 0.0, 0.5, 0.0, 12603500.0, 1.0, 0.5, 0.0]

# init the 'PiecewiseFunction' selected for 'OpacityTransferFunction'
warpByVector1Display.OpacityTransferFunction.Points = [91569.0, 0.0, 0.5, 0.0, 12603500.0, 1.0, 0.5, 0.0]

# setup the color legend parameters for each legend in this view

# get color legend/bar for velocityxLUT in view renderView1
velocityxLUTColorBar = GetScalarBar(velocityxLUT, renderView1)
velocityxLUTColorBar.Title = 'velocityx'
velocityxLUTColorBar.ComponentTitle = ''

# set color bar visibility
velocityxLUTColorBar.Visibility = 1

# show color legend
slice1Display.SetScalarBarVisibility(renderView1, True)

# ----------------------------------------------------------------
# setup color maps and opacity mapes used in the visualization
# note: the Get..() functions create a new object, if needed
# ----------------------------------------------------------------

# get opacity transfer function/opacity map for 'velocityx'
velocityxPWF = GetOpacityTransferFunction('velocityx')
velocityxPWF.Points = [4.120133053483306/10.0*mean_vel, 0.0, 0.5, 0.0, 11.126990619379177/10.0*mean_vel, 1.0, 0.5, 0.0]
velocityxPWF.ScalarRangeInitialized = 1

# ----------------------------------------------------------------
# restore active source
SetActiveSource(slice1)
# ----------------------------------------------------------------
SaveScreenshot('fsi_viz.png', renderView1, ImageResolution=[2387, 1444])
