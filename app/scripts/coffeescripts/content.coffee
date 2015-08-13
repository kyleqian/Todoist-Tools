# Content script
do ($=jQuery) ->
	if not settings of window
		window.alert "ERROR! Must set settings.js -- see README"
		throw "ERROR! Must set settings.js -- see README"

	settings = window.settings
	syncURL = "#{settings.apiBase}sync"
	getParams = {
		token: settings.apiKey,
		seq_no: 0,
		seq_no_global: 0,
		resource_types: JSON.stringify(["projects"])
	}
	setParams = {
		token: settings.apiKey
	}

	if !chrome.runtime.onMessage.hasListeners()
		chrome.runtime.onMessage.addListener (message, sender) ->
			# CHECK MESSAGE KEYS
			syncHandler(message.input)

	# saves URL to Indox as "Today"
	$(window).bind "keydown", settings.saveToProjectBind, (e) ->
		activeURL = window.location.href # URL of current window
		syncHandler(activeURL)
		return false # to prevent default action

	# saves string as an item to a project with specified due date
	syncHandler = (item=null, projectName="Inbox", date="today") ->
		return if not item or item == ""

		if projectName == "Inbox"
			chrome.storage.local.get {inboxId: ""}, (object) ->
				if chrome.runtime.lastError
					window.alert "getStorage ERROR! => #{chrome.runtime.lastError}"
				else if object.inboxId != ""
					addItemToProject(item, object.inboxId, projectName, date)
				else
					$.getJSON syncURL, getParams, (response) ->
						for p in response.Projects
							if p.name == projectName
								# DO THE CALLBACK ON FAILURE THING
								chrome.storage.local.set {inboxId: p.id}
								addItemToProject(item, p.id, projectName, date)
								break
		else
			$.getJSON syncURL, getParams, (response) ->
				for p in response.Projects
					if p.name == projectName
						addItemToProject(item, p.id, projectName, date)
						break

	addItemToProject = (item, projectId, projectName, date) ->
		uuid = generateUUID()
		setParams.commands = JSON.stringify([
			{
				type: "item_add",
				uuid: uuid,
				temp_id: uuid,
				args: {
					project_id: projectId,
					content: item,
					date_string: date
				}
			}
		])
		$.getJSON syncURL, setParams, (response) ->
			for k,v of response.SyncStatus
				if v != "ok"
					window.alert "Sync error!"
					return
			window.alert "Added task to \"#{projectName}\""

	generateUUID = () ->
		return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace /[xy]/g, (c) ->
			r = Math.random()*16|0
			v = if c == "x" then r else (r&0x3|0x8)
			return v.toString(16)