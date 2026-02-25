class_name ShuffleBag
extends RefCountedLogger


## Usage: var my_bag = ra.Bag.new(["A", "B", "C"], true)
##        var next_item = my_bag.pick()


var _source_items: Array[Variant]
var _current_bag: Array[Variant] = []
var _last_picked: Variant = null
var _prevent_repeat: bool = false


func _init(items: Array, prevent_repeat_last: bool = false):
	_source_items = items.duplicate()
	_prevent_repeat = prevent_repeat_last
	
	if _prevent_repeat and _source_items.size() < 2:
		__log_warn_soft("prevent_repeat is true, but array size is < 2. Will work but repeats are inevitable.")
	
	__log_("initialized", "size:", _source_items.size(), "prevent_repeat:", _prevent_repeat)


## Pulls the next random item. Refills automatically.
func pick() -> Variant:
	if _source_items.is_empty():
		__log_warn_soft("pick() called on empty bag")
		return null

	if _current_bag.is_empty():
		_refill_and_shuffle()

	var item: Variant = _current_bag.pop_back()
	_last_picked = item
	
	if __LOG_B(): __log_("picked", item, "remaining:", _current_bag.size())
	return item


## Tries to pick specific index. If invalid, falls back to standard pick().
func pick_specific(idx: int) -> Variant:
	if idx >= 0 and idx < _source_items.size():
		var item: Variant = _source_items[idx]
		_last_picked = item
		if __LOG_B(): __log_("pick_specific success", "index:", idx, "item:", item)
		return item
	
	# If index is -1 (default) or out of bounds, we warn (if it looks like a mistake) and fallback
	if idx != -1:
		__log_warn_soft("pick_specific invalid index", str(idx), "falling back to pick()")
	else:
		if __LOG_B(): __log_("pick_specific called with -1", "falling back to pick()")
		
	return pick()


func get_bag_len() -> int:
	return len(_source_items)


func _refill_and_shuffle() -> void:
	if __LOG_B(): __log_("_refill_and_shuffle", "started...")
	_current_bag = _source_items.duplicate()
	_current_bag.shuffle()

	# Logic to prevent the new first item from matching the old last item
	# Only works if we have at least 2 items
	if _prevent_repeat and _source_items.size() > 1 and _last_picked != null:
		# if top of the new bag (going to be popped) is the same as the last picked ...
		if _current_bag.back() == _last_picked:
			# ...swap it with the first element (bottom of the bag)
			var first_item = _current_bag.pop_front()
			var last_item = _current_bag.pop_back()
			
			_current_bag.push_back(first_item)
			_current_bag.push_front(last_item)

			if __LOG_B(): __log_("_refill_and_shuffle", "prevent_repeat triggered", "swapped first/last items")


## __LOGS

func pp_name() -> String:
	return "👜" + super.pp_name()


func __LOG_B() -> bool:
	return false