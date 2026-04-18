extends Node

const DETAIL_URL = "https://n8n.digital-sovereignty.cc/webhook/detail/ec83c456-b372-4837-a413-b1783b5046c1"

func fetch(doctype: String, name: String, callback: Callable) -> void:
	print("[fetch] ", doctype, " — ", name)
	var hr = HTTPRequest.new()
	get_tree().root.add_child(hr)
	hr.request_completed.connect(func(result, code, _headers, body):
		var json = JSON.parse_string(body.get_string_from_utf8())
		hr.queue_free()
		if result == HTTPRequest.RESULT_SUCCESS and code == 200 and json:
			callback.call(json)
		else:
			print("[fetch] failed — ", code)
	)
	var headers = ["Content-Type: application/json"]
	var payload = JSON.stringify({"doctype": doctype, "name": name})
	hr.request(DETAIL_URL, headers, HTTPClient.METHOD_POST, payload)
