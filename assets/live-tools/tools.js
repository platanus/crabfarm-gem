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

	var formatDialogContent = function(_content, _contentType) {
		if(_contentType == 'json') {
			_content = JSON.parse(_content);
			return jQuerySG('<pre>').html(syntaxHighlight(_content));
		} else {
			return jQuerySG('<pre>').text(_content);
		}
	};

	window.crabfarm = {
		showDialog: function(_type, _title, _subtitle, _content, _contentType) {

			var overlay = jQuerySG('<div>')
				.addClass('selectorgadget_ignore')
				.addClass('crabfarm_overlay');

			var dialog = jQuerySG('<div>')
				.addClass('crabfarm_dialog')
				.addClass('crabfarm_dialog_' + _type);

			var container = jQuerySG('<div>')
				.addClass('crabfarm_dialog_container');

			var button = jQuerySG('<a href="javascript:void(0);">')
				.addClass('crabfarm_dialog_close')
				.text('x');

			var removeOverlay = function() {
				overlay.remove();
			};

			overlay.bind("click", removeOverlay);
			button.bind("click", removeOverlay);

			container.append(jQuerySG('<h1>').text(_title));
			if(_subtitle) container.append(jQuerySG('<h3>').text(_subtitle));
			if(_content) {
				var inner = formatDialogContent(_content, _contentType);

				var content = jQuerySG('<div>')
					.addClass('crabfarm_dialog_content')
					.append(inner);

				container.append(content);
			}

			dialog.append(button);
			dialog.append(container);
			overlay.append(dialog);

			jQuerySG('body').append(overlay);
		},

		showSelectorGadget: function() {
			var gadget = new SelectorGadget();
			gadget.makeInterface();
			gadget.clearEverything();
			gadget.setMode('interactive');
		}
	};
}