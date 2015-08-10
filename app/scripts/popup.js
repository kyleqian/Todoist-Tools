// Generated by CoffeeScript 1.9.3
(function() {
  (function($) {
    return document.addEventListener("DOMContentLoaded", function() {
      return $(".submitButton").click(function() {
        var text;
        text = $(".inputText").val();
        return chrome.tabs.query({
          active: true,
          lastFocusedWindow: true
        }, function(tabs) {
          return chrome.tabs.sendMessage(tabs[0].id, {
            text: text
          });
        });
      });
    });
  })(jQuery);

}).call(this);