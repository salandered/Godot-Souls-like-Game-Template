@tool
extends Control

@export var audio_bus_name := "MusicAnalyzer"

@export_range(1, 128) var bars_count := 32
@export_exp_easing("inout") var motion_smoothing := 0.025
@export_range(0.1, 1.0) var bar_width_ratio := 0.8 # Replaces separation/thickness
@export var colors: Gradient = null

var MAX_HZ := 16000.0
var MIN_HZ := 20.0
var MIN_DB := 60.0
var spectrum: AudioEffectSpectrumAnalyzerInstance = null

var smoothed_energy: Array[float] = []
var color_offset := 0.0

func _ready():
	smoothed_energy.resize(bars_count)
	smoothed_energy.fill(0.0)
	spectrum = _get_spectrum_instance()

func _process(delta):
	if not spectrum:
		# Try to grab it again if it failed in ready (e.g. bus layout loaded late)
		spectrum = _get_spectrum_instance()
		return

	if smoothed_energy.size() != bars_count:
		smoothed_energy.resize(bars_count)
		smoothed_energy.fill(0.0)

	_process_audio_data(delta)
	queue_redraw()

func _draw():
	if not spectrum: return

	var total_w = size.x
	var total_h = size.y
	var bar_w_step = total_w / float(bars_count)
	var actual_bar_w = bar_w_step * bar_width_ratio
	var margin = (bar_w_step - actual_bar_w) / 2.0

	for i in range(bars_count):
		var energy = smoothed_energy[i]
		var height = energy * total_h
		
		# Create rect: X flows left-to-right, Y is bottom-aligned
		var r = Rect2(
			i * bar_w_step + margin,
			total_h - height,
			actual_bar_w,
			height
		)
		
		var c := Color.HOT_PINK
		if colors:
			c = colors.sample(float(i) / float(bars_count))
			c.s = clamp(c.s - energy * 0.3, 0, 1.0)
		
		draw_rect(r, c)

func _process_audio_data(delta: float):
	var prev_hz = MIN_HZ
	var sum = 0.0
	
	for i in range(bars_count):
		var ih = i + 1
		var hz: float = log_freq(ih / float(bars_count), MIN_HZ, MAX_HZ)
		
		var magnitude: float = spectrum.get_magnitude_for_frequency_range(prev_hz, hz, AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_AVERAGE).length()
		var energy: float = clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		
		# Smooth the movement
		var e: float = lerp(smoothed_energy[i], energy, clampf(delta / motion_smoothing if motion_smoothing else 1.0, 0, 1))
		smoothed_energy[i] = e
		sum += e
		
		prev_hz = hz
	
	# Animate color offset

# --- Helpers ---

func _get_spectrum_instance() -> AudioEffectSpectrumAnalyzerInstance:
	var bus_idx = AudioServer.get_bus_index(audio_bus_name)
	if bus_idx == -1: return null
	
	# Search for the effect safely without external utils
	for i in AudioServer.get_bus_effect_count(bus_idx):
		if AudioServer.get_bus_effect(bus_idx, i) is AudioEffectSpectrumAnalyzer:
			return AudioServer.get_bus_effect_instance(bus_idx, i)
	return null

func log10(val: float) -> float:
	return log(val) / 2.302585

func log_freq(pos: float, min_hz: float, max_hz: float) -> float:
	return pow(10, log10(min_hz) + (log10(max_hz) - log10(min_hz)) * pos)