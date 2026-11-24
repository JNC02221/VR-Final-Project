extends Node3D

var xr_interface: XRInterface
var xr_interface1: OpenXRInterface

@export var scene_gravity := 9.8

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized successfully")

		# Turn off v-sync!
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Change our main viewport to output to the HMD
		get_viewport().use_xr = true
	else:
		print("OpenXR not initialized, please check if your headset is connecte")
	
	PhysicsServer3D.area_set_param(
		get_viewport().find_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, scene_gravity)
