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
				delete syncParams.resource_types
				delete syncParams.seq_no
				delete syncParams.seq_no_global
				syncParams.commands = JSON.stringify([
					{
						type: "item_add",
						temp_id: "0",
						uuid: "b28eea80-3e29-11e5-b970-0800200c9a66",
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
					window.alert "SUCCESS!"
		return false # to prevent default action