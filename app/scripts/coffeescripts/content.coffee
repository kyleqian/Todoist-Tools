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
			chrome.storage.sync.get {inboxId: ""}, (object) ->
				if chrome.runtime.lastError
					window.alert "getStorage ERROR! => #{chrome.runtime.lastError}"
				else if object.inboxId != ""
					addItemToProject(item, object.inboxId, projectName, date)
				else
					$.getJSON syncURL, getParams, (response) ->
						project = null
						for p in response.Projects
							if p.name == projectName
								project = p
								break
						if project
							chrome.storage.sync.set {inboxId: project.id}
							addItemToProject(item, project.id, projectName, date)
		else
			$.getJSON syncURL, getParams, (response) ->
				project = null
				for p in response.Projects
					if p.name == projectName
						project = p
						break
				if project
					addItemToProject(item, project.id, projectName, date)

	addItemToProject = (item, projectId, projectName, date) ->
		uuid = (S4() + S4() + "-" + S4() + "-4" + S4().substr(0,3) + "-" + S4() + "-" + S4() + S4() + S4()).toLowerCase()
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
				if "error_tag" in v
					window.alert "Error!"
					return
			window.alert "Added task to \"#{projectName}\""


	# hacky
	S4 = () ->
		return (((1+Math.random())*0x10000)|0).toString(16).substring(1)