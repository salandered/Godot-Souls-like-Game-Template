extends RefCounted
class_name PrintData


class LogData:
	var add_prefix_: String
	var text: String
	var info_indents: int

	func _init(add_prefix__: String, text_: String, info_indents_: int):
		self.add_prefix_ = add_prefix__
		self.text = text_
		self.info_indents = info_indents_


class PrintInstance:
	var print_bool: bool
	var const_prefix: String
	var const_indent: int
	var log_func: Callable

	func _init(print_bool_: bool, const_prefix_: String, const_indent_: int, log_func_: Callable) -> void:
		self.print_bool = print_bool_
		self.const_prefix = const_prefix_
		self.const_indent = const_indent_
		self.log_func = log_func_

	func call_log_func(log_data: LogData) -> void:
		log_func.call(log_data.add_prefix_, log_data.text, log_data.info_indents)