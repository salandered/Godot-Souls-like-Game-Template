class_name MathUtil


const INV_LOG_10 := 1.0 / log(10)


static func fpow2(number: float) -> float:
	return number * number

static func ipow2(number: int) -> int:
	return number * number


## base-10 logarithm of x
static func log10(x: float) -> float:
	return log(x) * INV_LOG_10


## log interpolation
## Maps a normalized value t (0-1) to the range [a, b] logarithmically.
static func lerp_log(a: float, b: float, weight: float) -> float:
	return a * pow(b / a, weight)


# ease-in-out S-curve
# takes a linear progress value (0 to 1) and returns a smoothed value (0 to 1)
static func ease_in_out(x: float) -> float:
	x = clampf(x, 0.0, 1.0)
	return 0.5 * (1.0 - cos(x * PI))