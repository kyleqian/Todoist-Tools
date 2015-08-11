# Todoist-Tools
Toolset for Todoist

Copy the sample settings file and enter credentials/keys wherever needed:

	$ cp config/sample-settings.js config/settings.js

The hotkey bindings are set to fire even within input elements (while typing, etc). To toggle this feature, edit the following options in `/lib/jquery.hotkeys.js`:
	
	filterInputAcceptingElements: false
	filterTextInputs: false
	filterContentEditable: false

TODO: Switch to OAuth; UUID/temp_id fix; switch to chrome.commands; put all handlers in background.js