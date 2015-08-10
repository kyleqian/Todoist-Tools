do ($=jQuery) ->
	document.addEventListener "DOMContentLoaded", ->
		$(".submitButton").click ->
			text = $(".inputText").val()
			chrome.tabs.query {active: true, lastFocusedWindow: true}, (tabs) ->
				# add callback/ERROR CHECK
				chrome.tabs.sendMessage tabs[0].id, {text: text}