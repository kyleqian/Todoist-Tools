do ($=jQuery) ->
	document.addEventListener "DOMContentLoaded", ->
		input = $(".inputText")
		button = $(".submitButton")
		enterKey = 13
		
		button.click ->
			text = input.val()
			input.val("")
			sendInputToActiveContentScript(text)

		input.keypress (e) ->
			key = e.which
			if key is enterKey
				text = input.val()
				input.val("")
				sendInputToActiveContentScript(text)

		sendInputToActiveContentScript = (input) ->
			chrome.tabs.query {active: true, lastFocusedWindow: true}, (tabs) ->
				# add callback/ERROR CHECK
				chrome.tabs.sendMessage tabs[0].id, {input: input}