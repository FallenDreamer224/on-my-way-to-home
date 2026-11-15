class_name EvaRangeProvider
extends RefCounted
## Future extension point only. No supplies, speed or return-time model exists yet.

func assess(_remaining_supplies: Dictionary, _estimated_return_seconds: float) -> EvaSafetyLimits:
	# A future implementation may propose limits. Never silently apply a proposal to
	# the astronaut alone: terrain, full-foot checks and companion routing must agree.
	return null
