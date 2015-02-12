RUN env.

IF kspscale = "J32" {
	SET scale_multiplier TO SQRT(3.2 / 2).
} ELSE {
	SET scale_multiplier TO 1.
}

RUN launchController.