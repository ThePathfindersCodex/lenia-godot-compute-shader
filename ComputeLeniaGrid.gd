extends TextureRect

# GODOT LENIA
#	Extensions to base compute shader example found here: https://github.com/Ludmuterol/lenia_godot
#	- 4 Panel Display with various Preload Playfields like Orbiums, Spinners, and Random fields - using Custom Resources
#	- Simulation Run States
#	- Configurable Shader Parameters using UI Control Panel
#	- Configurable Kernel Size (with optional multi-ring support) - only 1 kernel for now tho

# SIM CONTROLS
enum RUN_STATES {
	PAUSED,
	RUNNING,
	PREVIEWING,
	STEPPING
}
var sim_run_state:RUN_STATES=RUN_STATES.STEPPING
var playfield_type:int=1
@export var playfield_res :LeniaPlayfield
const playfield_res_list = [
	preload("res://playfields/0_random.tres"),
	preload("res://playfields/1_orb.tres"),
	preload("res://playfields/2_shimmer.tres"),
	preload("res://playfields/3_chain.tres"),
	preload("res://playfields/4_star.tres"),
	preload("res://playfields/5_orb2.tres"),
	preload("res://playfields/6_spinner.tres"),
	preload("res://playfields/7_shifter.tres"),
	preload("res://playfields/8_conway.tres"),
	preload("res://playfields/9_orb3.tres"),
	preload("res://playfields/10_hex_rotate.tres"),
	preload("res://playfields/11_big_spinner.tres"),
	preload("res://playfields/12_wow.tres")
]
signal config_changed() # emitted when main parameters are changed so UI can update

# PRIMARY RENDERING VARS
var rd := RenderingServer.create_local_rendering_device()
var shader
var pipeline
var uniform_set
var uniform
var uniform2
var uniform3
var uniform4
var uniform5
var output_tex_uniform
var weighted_sum_tex_uniform
var growth_tex_uniform

# DATA BUFFERS
var buffer # main field in buffer
var buffer2 # next field out buffer
var buffer3 # kernel buffer
var buffer4 # weighted sum buffer
var buffer5 # growth buffer

# IMAGE TEXTURES
var output_tex := RID() # main field texture
var weighted_sum_tex := RID() # weighted sum field texture
var growth_tex := RID() # growth field texture
var fmt := RDTextureFormat.new() # shared format
var view := RDTextureView.new() # shared view

# PUSH CONSTANT VALUES FOR COMPUTE SHADER
var frequency :float=1.0/100
@export var frequency_scale := 100.0: 
	set(value):
		frequency_scale = value
		frequency = 1.0/value
@export var growth_m := 0.15
@export var growth_s := 0.015
@export var color_scheme :int= 4 # currently supports 0 to 4

# GRID AND KERNEL SETTINGS
const grid_width = 400 # grid_size = grid_width * grid_width
var amplitudes = [1.0]
var k_size = (2 * 13) + 1 # k_size = (2 * k_radius) + 1
@export var k_radius :int= 13: 
	set(value):
		k_radius = value
		k_size = (2 * k_radius) + 1
		
		# create/recreate buffer
		var kernel_bytes = generate_kernel()
		buffer3 = rd.storage_buffer_create(kernel_bytes.size(), kernel_bytes)
		
		# add/readd uniform
		uniform3 = RDUniform.new()
		uniform3.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
		uniform3.binding = 3
		uniform3.add_id(buffer3)

		# maybe update uniform_set with new kernel uniform
		if uniform: # throws warning if this is first time so we check uniform1 exists - TODO: is better way?
			uniform_set = rd.uniform_set_create([uniform, output_tex_uniform, uniform2, uniform3, uniform4, uniform5,weighted_sum_tex_uniform,growth_tex_uniform], shader, 0)

func generate_kernel():
	# init
	var kernel = PackedFloat32Array()
	for i in range(k_size * k_size):
		kernel.push_back(1)
		
	# Calculate equally spaced ring boundaries
	var num_rings = len(amplitudes)  # the number of rings
	var ring_intervals = []
	for i in range(num_rings + 1):
		ring_intervals.append(float(i) / float(num_rings))
	
	# Place the bell-shaped rings 
	for i in range(k_size):
		for j in range(k_size):
			var tmp = sqrt((float(i) - float(k_radius)) ** 2 + (float(j) - float(k_radius)) ** 2) / k_radius
			# Loop through each ring and assign values
			for ring in range(num_rings):
				if tmp >= ring_intervals[ring] and tmp < ring_intervals[ring + 1]:
					# Normalize `tmp` within the current ring's interval
					var normalized_tmp = (tmp - ring_intervals[ring]) / (ring_intervals[ring + 1] - ring_intervals[ring])
					kernel[i + j * k_size] = amplitudes[ring] * Utility.bell(normalized_tmp, 0.5 , 0.15)
					break  # break after finding the right ring
				else:
					kernel[i + j * k_size] = 0  # Outside all rings
	
	# draw image before normalize
	var kernelimg = Image.create_from_data(k_size, k_size, false, Image.FORMAT_RF, kernel.to_byte_array())
	var kerneltexture = ImageTexture.create_from_image(kernelimg)
	%ComputeKernelGrid.texture = kerneltexture
	
	# normalize
	var kernel_sum = 0
	for i in kernel.size():
		kernel_sum += kernel[i]	
	for i in kernel.size():
		kernel[i] /= kernel_sum

	# return bytes
	var kernel_bytes :PackedByteArray = PackedInt32Array([k_size]).to_byte_array()
	kernel_bytes.append_array(kernel.to_byte_array())
	return kernel_bytes

func reset_playfield(forceUpdateBuffer=false,lockPlayfield=false,lockKernel=false,lockConfig=false):
	var playfield
	var randFlag = false
	
	if (playfield_type==0):
		randFlag = true
	
	playfield_res = playfield_res_list[playfield_type]
	playfield = load_playfield(lockPlayfield,lockKernel,lockConfig,randFlag)
	
	if forceUpdateBuffer:
		rd.buffer_update(buffer, 0, playfield.size(), playfield)
		
	return playfield

func load_playfield(lockPlayfield=false,lockKernel=false,lockConfig=false,isRandom=false):
	var arr :PackedFloat32Array = PackedFloat32Array()
	var input_bytes :PackedByteArray = PackedByteArray()
	
	# is kernel locked? if not, use values from playfield resource
	if (!lockKernel):
		amplitudes = playfield_res.amplitudes
		k_radius = playfield_res.k_radius
		
	# is config locked? if not, use values from playfield resource
	if (!lockConfig):
		frequency_scale = playfield_res.frequency_scale
		growth_m = playfield_res.growth_m
		growth_s = playfield_res.growth_s
		
	# notify UI that values changed
	if (!lockKernel || !lockConfig):
		config_changed.emit()
	
	# do not change playfield if locked
	if (lockPlayfield):
		return rd.buffer_get_data(buffer) # buffer
	
	# is this random playfield?
	if (isRandom):
		for i in range(grid_width * grid_width):
			arr.push_back(randf())
		input_bytes = PackedInt32Array([grid_width]).to_byte_array()
		input_bytes.append_array(arr.to_byte_array())
		return input_bytes
	
	# not random, so get the non-random pattern from resource
	var pattern = playfield_res.pattern
	
	# init
	for i in range(grid_width * grid_width):
		arr.push_back(0)
		
	# center-ish in grid of size grid_width
	var pattern_width = 25 # TODO: good for most patterns - could check width and height to get exact sizes
	var offset = Utility.calculate_offset(grid_width, pattern_width)
	
	# row based placement
	for i in range(pattern.size()):
		for j in range(pattern[i].size()):
			arr[(i+offset.x) + (j+offset.y) * grid_width] = pattern[i][j]
			
	input_bytes = PackedInt32Array([grid_width]).to_byte_array()
	input_bytes.append_array(arr.to_byte_array())
	return input_bytes

func _ready():
	randomize()
	
	# load and begin compiling compute shader
	var shader_file := load("res://compute_lenia.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(shader)
	
	# kernel buffer
	var kernel_bytes = generate_kernel()
	buffer3 = rd.storage_buffer_create(kernel_bytes.size(), kernel_bytes)
	
	# main input and output buffer
	var playfield = reset_playfield()
	buffer = rd.storage_buffer_create(playfield.size(), playfield)
	buffer2 = rd.storage_buffer_create(playfield.size(), playfield)
	
	# storage buffers for Weighted Neighbor Sums and Growth values
	buffer4 = rd.storage_buffer_create(playfield.size(), playfield)  # weighted_sum_buffer
	buffer5 = rd.storage_buffer_create(playfield.size(), playfield)  # growth_buffer
	
	# generate output texture format - relies on constant grid_width for now
	fmt = RDTextureFormat.new()
	fmt.width = grid_width
	fmt.height = grid_width
	fmt.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT \
					| RenderingDevice.TEXTURE_USAGE_STORAGE_BIT \
					| RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	view = RDTextureView.new()
	
	# main grid ImageTexture
	var output_image := Image.create(grid_width, grid_width, false, Image.FORMAT_RGBAF)
	var image_texture = ImageTexture.create_from_image(output_image)
	texture = image_texture
	output_tex = rd.texture_create(fmt, view, [output_image.get_data()])

	# weighted sums ImageTexture
	var weighted_sum_image := Image.create(grid_width, grid_width, false, Image.FORMAT_RGBAF)
	weighted_sum_tex = ImageTexture.create_from_image(weighted_sum_image)
	var output_image2 := Image.create(grid_width, grid_width, false, Image.FORMAT_RGBAF)
	var image_texture2 = ImageTexture.create_from_image(output_image2)
	%ComputeWeightSumGrid.texture = image_texture2
	weighted_sum_tex = rd.texture_create(fmt, view, [output_image2.get_data()])
	
	# growth ImageTexture
	var growth_image := Image.create(grid_width, grid_width, false, Image.FORMAT_RGBAF)
	growth_tex = ImageTexture.create_from_image(growth_image)
	var output_image3 := Image.create(grid_width, grid_width, false, Image.FORMAT_RGBAF)
	var image_texture3 = ImageTexture.create_from_image(output_image3)
	%ComputeGrowthGrid.texture = image_texture3
	growth_tex = rd.texture_create(fmt, view, [output_image3.get_data()])

	# Create uniforms to assign the buffers to the rendering device
	uniform = RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0 
	uniform.add_id(buffer)
	
	output_tex_uniform = RDUniform.new()
	output_tex_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	output_tex_uniform.binding = 1
	output_tex_uniform.add_id(output_tex)
	
	uniform2 = RDUniform.new()
	uniform2.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform2.binding = 2 
	uniform2.add_id(buffer2)
	
	uniform3 = RDUniform.new()
	uniform3.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform3.binding = 3
	uniform3.add_id(buffer3)
	
	uniform4 = RDUniform.new()
	uniform4.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform4.binding = 4
	uniform4.add_id(buffer4)

	uniform5 = RDUniform.new()
	uniform5.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform5.binding = 5
	uniform5.add_id(buffer5)
	
	weighted_sum_tex_uniform = RDUniform.new()
	weighted_sum_tex_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	weighted_sum_tex_uniform.binding = 6
	weighted_sum_tex_uniform.add_id(weighted_sum_tex)
	
	growth_tex_uniform = RDUniform.new()
	growth_tex_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	growth_tex_uniform.binding = 7
	growth_tex_uniform.add_id(growth_tex)
	
	# Create uniform set
	uniform_set = rd.uniform_set_create([uniform, output_tex_uniform, uniform2, uniform3, uniform4, uniform5,weighted_sum_tex_uniform,growth_tex_uniform], shader, 0)

func _process(_delta):
	if sim_run_state!=RUN_STATES.PAUSED:
		
		# start compute list
		var compute_list := rd.compute_list_begin()
		rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
		rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)

		# shader PUSH CONSTANT params
		var params :PackedFloat32Array= [frequency, growth_m, growth_s, float(color_scheme)] # TODO review: always sending floats to make packing easier? also need to verify multiple of 4 like 16 bytes?
		var params_bytes :PackedByteArray = PackedInt32Array([]).to_byte_array()
		params_bytes.append_array(params.to_byte_array())
		rd.compute_list_set_push_constant(compute_list,params_bytes,params_bytes.size())

		# finish list and proceed to compute
		rd.compute_list_dispatch(compute_list, int(grid_width / 16.0), int(grid_width / 16.0), 1)
		rd.compute_list_end()
		rd.submit()
		rd.sync()

		# Retrieve the output buffer data, and maybe swap to the next grid in the sim 
		var output_bytes := rd.buffer_get_data(buffer2)
		if(sim_run_state!=RUN_STATES.PREVIEWING):
			rd.buffer_update(buffer, 0, output_bytes.size(), output_bytes) # SWAP GRID TO NEXT GRID
			
		# and set main image
		var byte_data : PackedByteArray = rd.texture_get_data(output_tex, 0)
		var image := Image.create_from_data(grid_width, grid_width, false, Image.FORMAT_RGBAF, byte_data)
		texture.update(image)

		# Retrieve the weighted sum buffer data and set that image
		#var weighted_sum_output_bytes := rd.buffer_get_data(buffer4)
		var weighted_sum_byte_data : PackedByteArray = rd.texture_get_data(weighted_sum_tex, 0)
		var weighted_sum_image := Image.create_from_data(grid_width, grid_width, false, Image.FORMAT_RGBAF, weighted_sum_byte_data)
		%ComputeWeightSumGrid.texture.update(weighted_sum_image)

		# Retrieve the growth buffer data and set that image
		#var growth_bytes_output_bytes := rd.buffer_get_data(buffer5)
		var growth_bytes_byte_data : PackedByteArray = rd.texture_get_data(growth_tex, 0)
		var growth_bytes_image := Image.create_from_data(grid_width, grid_width, false, Image.FORMAT_RGBAF, growth_bytes_byte_data)
		%ComputeGrowthGrid.texture.update(growth_bytes_image)
	
	# stop sim if we were only previewing next grid or making one single step in the sim
	if(sim_run_state==RUN_STATES.PREVIEWING||sim_run_state==RUN_STATES.STEPPING):
		sim_run_state=RUN_STATES.PAUSED
