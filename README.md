# Godot Multiplayer Toolbar

This plugin adds 2 toolbar buttons for launching multiple instances of a game in the Godot Engine.

* The new play icon (![Play+](PlayPlus.svg)) will run a new instance of the game, including the main instance.
* The new stop icon (![Stop+](StopPlus.svg)) will close all spawned instances of the game, including the main instance.

When an instance is spawned, the instance number will be passed in as the [command line argument](https://docs.godotengine.org/en/stable/classes/class_os.html#class-os-method-get-cmdline-args) `--mp-instance=##`, where ## is the spawned instance number. Note that, for technical reasons, the main instance will not have this argument passed in. However, it is treated by the plugin as instance 0.

The following code can be used to get the spawned instance number (including instance 0). This can be useful for debugging.

```swift
func get_mp_instance_id():
	for arg in OS.get_cmdline_args():
		if arg.begins_with("--mp-instance="):
			var vals = arg.split("=")
			return int(vals[1])
	return 0
```

You must press the Stop All button to reset the instance id numbers.

## Installation

See [https://docs.godotengine.org/en/stable/tutorials/plugins/editor/installing_plugins.html]() for instructions for installing a plugin in Godot.
