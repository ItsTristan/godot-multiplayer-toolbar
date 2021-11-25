tool
extends EditorPlugin


var multistart_button :Button
var multistop_button :Button

var active_pids := []


func _enter_tree():
	var dir = get_script().get_path().get_base_dir()
	
	multistart_button = Button.new()
	multistop_button = Button.new()
	
	# Start button
	var multistart_event := InputEventKey.new()
	var multistart_shortcut := ShortCut.new()
	multistart_event.scancode = OS.find_scancode_from_string("F5")
	multistart_event.shift = true
	multistart_event.alt = true
	multistart_shortcut.shortcut = multistart_event
	
	multistart_button.icon = load(dir.plus_file("PlayPlus.svg"))
	multistart_button.flat = true
	multistart_button.shortcut = multistart_shortcut
	multistart_button.hint_tooltip = "Add Window"
	
	# Stop button
	var multistop_event := InputEventKey.new()
	var multistop_shortcut := ShortCut.new()
	multistop_event.scancode = OS.find_scancode_from_string("F8")
	multistop_event.shift = true
	multistop_event.alt = true
	multistop_shortcut.shortcut = multistop_event
	multistop_button.hint_tooltip = "Stop All"
	
	multistop_button.icon = load(dir.plus_file("StopPlus.svg"))
	multistop_button.flat = true
	multistop_button.shortcut = multistop_shortcut
	
	# Add to the toolbar
	multistart_button.connect("pressed", self, "start_multiplayer")
	multistop_button.connect("pressed", self, "stop_multiplayer")
	
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, multistart_button)
	add_control_to_container(EditorPlugin.CONTAINER_TOOLBAR, multistop_button)


func _exit_tree():
	multistart_button.queue_free()
	multistop_button.queue_free()
	
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, multistart_button)
	remove_control_from_container(EditorPlugin.CONTAINER_TOOLBAR, multistop_button)
	
	multistart_button = null
	multistop_button = null


func start_multiplayer():
	if !get_editor_interface().is_playing_scene():
		# Open the main game process
		get_editor_interface().play_main_scene()
	else:
		# Open a new process
		var idx := active_pids.size()
		
		var x_lim :int = OS.get_screen_size().x / ProjectSettings.get_setting("display/window/size/width")
		var y_lim :int = OS.get_screen_size().y / ProjectSettings.get_setting("display/window/size/height")
		var w_lim :int = x_lim * y_lim
		
		var pos_idx :int = idx % w_lim
		var offset_idx := int(idx / w_lim)
		var window_pos := Vector2(offset_idx * 16, offset_idx * 16)
		
		window_pos.x += (pos_idx % x_lim) * ProjectSettings.get_setting("display/window/size/width")
		window_pos.y += (pos_idx / x_lim) * ProjectSettings.get_setting("display/window/size/height")
		
		var window_pos_str = "%s,%s" % [window_pos.x, window_pos.y]
		var pid :int = OS.execute(OS.get_executable_path(), ["--path", ".", "--position", window_pos_str, "--mp-instance=%d" % (idx+1)], false)
		active_pids.append(pid)


func stop_multiplayer():
	# Close any running processes
	for pid in active_pids:
		if OS.get_name() == "Windows":
			var output := []
			OS.execute("tasklist", ["/FI", "PID eq %d" % pid], true, output)
			if output[0].split("\n").size() > 1:
				OS.kill(pid)
		else:
			var exit_code := OS.execute("ps", ["-p", pid], true)
			if exit_code == 0 or exit_code == 127:
				OS.kill(pid)
	
	get_editor_interface().stop_playing_scene()
	
	active_pids.clear()
