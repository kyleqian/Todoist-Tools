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
	defaultParams = {
		token: settings.apiKey,
		seq_no: 0,
		seq_no_global: 0,
		resource_types: JSON.stringify(["projects"])
	}

	# saves URL to a project with no due date
	$(window).bind "keydown", settings.saveToProjectBind, (e) ->
		activeURL = window.location.href
		syncParams = defaultParams
		$.getJSON syncURL, syncParams, (response) ->
			syncParams.seq_no = response.seq_no
			syncParams.seq_no_global = response.seq_no_global
			project = null
			for p in response.Projects
				if p.name == settings.projectName
					project = p
					break
			if project
				uuid = (S4() + S4() + "-" + S4() + "-4" + S4().substr(0,3) + "-" + S4() + "-" + S4() + S4() + S4()).toLowerCase()
				syncParams.commands = JSON.stringify([
					{
						type: "item_add",
						uuid: uuid,
						args: {
							project_id: project.id,
							content: activeURL,
							date_string: null
						}
					}
				])
				$.getJSON syncURL, syncParams, (response) ->
					syncParams.seq_no = response.seq_no
					syncParams.seq_no_global = response.seq_no_global
					window.alert "Added link to \"Ideas\""
		return false # to prevent default action

	S4 = () ->
		return (((1+Math.random())*0x10000)|0).toString(16).substring(1)