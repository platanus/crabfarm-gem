if(!window.crabfarm) {

	var syntaxHighlight = function(json) {
		if (typeof json != 'string') {
			json = JSON.stringify(json, undefined, 4);
		}

		json = json.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
		return json.replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, function (match) {
			var cls = 'number';
			if (/^"/.test(match)) {
				if (/:$/.test(match)) {
					cls = 'key';
				} else {
					cls = 'string';
				}
			} else if (/true|false/.test(match)) {
				cls = 'boolean';
			} else if (/null/.test(match)) {
				cls = 'null';
			}
			return '<span class="' + cls + '">' + match + '</span>';
		});
	};

	var buildResultDialog = function(_styleClass, _title, _content) {
		var overlay = jQuerySG('<div>')
			.addClass('selectorgadget_ignore')
			.addClass('crabfarm_overlay');

		var dialog = jQuerySG('<div>')
			.addClass('crabfarm_dialog')
			.addClass(_styleClass);

		var button = jQuerySG('<a href="javascript:void(0);">')
			.addClass('crabfarm_dialog_close')
			.text('x');

		var removeOverlay = function() {
			overlay.remove();
			window.crabfarm.showSelectorGadget();
		};

		overlay.bind("click", removeOverlay);
		button.bind("click", removeOverlay);

		var content = jQuerySG('<div>')
			.addClass('crabfarm_dialog_content')
			.append(_content);

		dialog.append(button);
		dialog.append(jQuerySG('<h1>').text(_title));
		dialog.append(content);
		overlay.append(dialog);

		jQuerySG('body').append(overlay);
	};

	window.crabfarm = {
		showResults: function(_data) {
			_data = JSON.parse(_data);

			buildResultDialog(
				'crabfarm_dialog_success',
				'Navigation completed!',
				jQuerySG('<pre>').html(syntaxHighlight(_data))
			);
		},

		showError: function(_error, _trace) {
			buildResultDialog(
				'crabfarm_dialog_error',
				'Navigation error!',
				jQuerySG('<pre>').text(_trace)
			);
		},

		showSelectorGadget: function() {
			var gadget = new SelectorGadget();
			gadget.makeInterface();
			gadget.clearEverything();
			gadget.setMode('interactive');
		}
	};
}