class_name RegexFilter
extends RefCountedLogger

var _regex := RegEx.new()
var _cached_query: String = ""

var _info := ReUtils.RegexCompileInfo.new()

enum Result {
	PASS,
	NOT_PASS,
	ERROR
}

## checks if the text passes the filter query
func apply_filter(text: String, query: String) -> Result:
	if query != _cached_query:
		_update_cache(query)

	if query.is_empty():
		return Result.PASS

	# invalid regex
	if not _info.is_valid:
		return Result.ERROR

	# regex itself
	var search_result := _regex.search(text)

	if search_result == null:
		return Result.PASS if _info.is_inverted else Result.NOT_PASS
	else:
		return Result.NOT_PASS if _info.is_inverted else Result.PASS

func _update_cache(new_query: String) -> void:
	_cached_query = new_query
	
	# Store the whole info object
	_info = ReUtils.check_regex_compile(new_query)
	
	if _info.is_valid and not _info.pattern.is_empty():
		_regex.compile(_info.pattern)
