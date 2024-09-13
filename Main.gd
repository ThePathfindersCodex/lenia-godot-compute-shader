extends Node2D

func update_lenia_config_UI():
	%labelTimeScale.text=str(%ComputeLeniaGrid.frequency_scale)
	%labelGrowthCenter.text=str(%ComputeLeniaGrid.growth_m)
	%labelGrowthWidth.text=str(%ComputeLeniaGrid.growth_s)
	%labelKernelRadius.text=str(%ComputeLeniaGrid.k_radius)
	%labelKernelAmp.text=str(%ComputeLeniaGrid.amplitudes)
	
	%HSTimeScale.set_value_no_signal(%ComputeLeniaGrid.frequency_scale)
	%HSGrowthCenter.set_value_no_signal(%ComputeLeniaGrid.growth_m)
	%HSGrowthWidth.set_value_no_signal(%ComputeLeniaGrid.growth_s)
	%HSKernelRadius.set_value_no_signal(%ComputeLeniaGrid.k_radius)

func _ready():
	%ComputeLeniaGrid.config_changed.connect(update_lenia_config_UI)
	update_lenia_config_UI()
	
func _process(_delta):
	# Start or Stop button?
	if %ComputeLeniaGrid.sim_run_state==%ComputeLeniaGrid.RUN_STATES.RUNNING:
		%ButtonStartStop.text = "Stop"
	else:
		%ButtonStartStop.text = "Start"
	
	# Display cell value at mouse cursor in main grid
	var mp = get_local_mouse_position()
	if mp.x >=0 and mp.x <=%ComputeLeniaGrid.grid_width-1:
		if mp.y >=0 and mp.y <=%ComputeLeniaGrid.grid_width-1:
			var output_bytes :PackedFloat32Array= %ComputeLeniaGrid.rd.buffer_get_data(%ComputeLeniaGrid.buffer).to_float32_array()
			var point_value :float=output_bytes[mp.x + mp.y * %ComputeLeniaGrid.grid_width]
			var strOutput = str(mp) + " == " + str(point_value)
			%labelMouseOverPixel.text = strOutput
	
func run():
	%ComputeLeniaGrid.sim_run_state=%ComputeLeniaGrid.RUN_STATES.RUNNING
	
func stop():
	%ComputeLeniaGrid.sim_run_state=%ComputeLeniaGrid.RUN_STATES.PAUSED

func run_once_preview():
	%ComputeLeniaGrid.sim_run_state=%ComputeLeniaGrid.RUN_STATES.PREVIEWING

func run_once_step():
	%ComputeLeniaGrid.sim_run_state=%ComputeLeniaGrid.RUN_STATES.STEPPING

func maybe_run_once_preview():
	if %ComputeLeniaGrid.sim_run_state==%ComputeLeniaGrid.RUN_STATES.PAUSED:
		run_once_preview()
	
func _on_button_start_stop_pressed():
	if %ComputeLeniaGrid.sim_run_state==%ComputeLeniaGrid.RUN_STATES.RUNNING:
		stop()
	else:
		run()
	
func _on_button_step_pressed():
	run_once_step()
	
func _on_button_restart_pressed():
	%ComputeLeniaGrid.reset_playfield(true,%lockPlayfield.button_pressed,%lockKernel.button_pressed,%lockConfig.button_pressed)
	maybe_run_once_preview()

func _on_opt_preloads_item_selected(index):
	%ComputeLeniaGrid.playfield_type=index
	%ComputeLeniaGrid.reset_playfield(true,%lockPlayfield.button_pressed,%lockKernel.button_pressed,%lockConfig.button_pressed)
	update_lenia_config_UI()
	maybe_run_once_preview()
	
func _on_opt_colors_item_selected(index):
	%ComputeLeniaGrid.color_scheme=index
	maybe_run_once_preview()
	
func _on_hs_kernel_radius_value_changed(value):
	%ComputeLeniaGrid.k_radius=value
	update_lenia_config_UI()
	maybe_run_once_preview()
	
func _on_hs_time_scale_value_changed(value):
	%ComputeLeniaGrid.frequency_scale=value
	update_lenia_config_UI()
	maybe_run_once_preview()
	
func _on_hs_growth_center_value_changed(value):
	%ComputeLeniaGrid.growth_m=value
	update_lenia_config_UI()
	maybe_run_once_preview()
	
func _on_hs_growth_width_value_changed(value):
	%ComputeLeniaGrid.growth_s=value
	update_lenia_config_UI()
	maybe_run_once_preview()
	

	

