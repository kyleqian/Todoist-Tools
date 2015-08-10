# Content script
do ($=jQuery) ->
	if not settings of window
		window.alert "ERROR! Must set settings.js -- see README"
		throw "ERROR! Must set settings.js -- see README"
	# jQuery.hotkeys.options.filterInputAcceptingElements = false
	# jQuery.hotkeys.options.filterContentEditable = false
	# jQuery.hotkeys.options.filterContentEditable = false

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

	# saves URL to Indox as "Today"
	$(window).bind "keydown", settings.saveToProjectBind, (e) ->
		activeURL = window.location.href # URL of current window
		saveItemToProject(activeURL, settings.projectName, "today")
		return false # to prevent default action

	# saves string as an item to a project with specified due date
	saveItemToProject = (item, projectName, date) ->
		$.getJSON syncURL, getParams, (response) ->
			# what to do with these seq_no?
			# getParams.seq_no = response.seq_no
			# getParams.seq_no_global = response.seq_no_global
			project = null
			for p in response.Projects
				if p.name == projectName
					project = p
					break
			if project
				uuid = (S4() + S4() + "-" + S4() + "-4" + S4().substr(0,3) + "-" + S4() + "-" + S4() + S4() + S4()).toLowerCase()
				setParams.commands = JSON.stringify([
					{
						type: "item_add",
						uuid: uuid,
						temp_id: uuid,
						args: {
							project_id: project.id,
							content: item,
							date_string: date
						}
					}
				])
				$.getJSON syncURL, setParams, (response) ->
					for k,v of response.SyncStatus
						console.log v
						if "error_tag" in v
							window.alert "Error!"
							return
					# defaultParams.seq_no = response.seq_no
					# defaultParams.seq_no_global = response.seq_no_global
					window.alert "Added link to \"#{settings.projectName}\""

	# hacky
	S4 = () ->
		return (((1+Math.random())*0x10000)|0).toString(16).substring(1)