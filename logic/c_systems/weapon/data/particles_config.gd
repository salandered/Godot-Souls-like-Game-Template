class_name ParticlesConfig
extends RefCountedLogger


var amount: int
var lifetime: float
##


var _min_max_amount: IMinMax = IMinMax.new(1, 200)
var _min_max_lifetime: FMinMax = FMinMax.new(0.1, 1000.0)


const DEF_AMOUNT: int = 10
const DEF_LIFETIME: float = 3.0


func _init(
	amount_: int = DEF_AMOUNT,
	lifetime_: float = DEF_LIFETIME,
):
	self.amount = amount_
	self.lifetime = lifetime_
	
	_validate()


func _validate() -> void:
	_min_max_amount.clamp(amount, true, "amount")
	_min_max_lifetime.clamp(lifetime, true, "lifetime")


func set_up_particles(particles: GPUParticles3D) -> GPUParticles3D:
	if not particles:
		return null
		
	particles.amount = amount
	particles.lifetime = lifetime
	
	return particles
