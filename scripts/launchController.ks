SET countdown TO 3.
SET initial_twr TO 1.4.

// In case script is aborted
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

// Countdown
CLEARSCREEN.
PRINT "Launch for " + (round(target_apoapsis) / 1000) + "km altitude orbit.".
PRINT "Heading for " + target_heading.
SET max_throttle TO 1.
LOCK throttle TO 1.
LOCK steering TO heading(0, 90).
UNTIL countdown = 0 {
	PRINT countdown.
	SET countdown TO countdown - 1.
	WAIT 1.
}.

// Launch
PRINT "LAUNCH".
STAGE.

// Throttle settings
SET initial_throttle TO mass * 9.8 * initial_twr / maxthrust.
SET current_throttle TO initial_throttle.
LOCK max_throttle TO MIN(mass * 9.8 * 4.0 / maxthrust, 1).
LOCK throttle TO MIN(current_throttle, max_throttle).

// Auto-Stage once
WHEN stage:liquidfuel < 0.1 THEN {
	STAGE.
	SET current_throttle TO 1.
}.

// Roll program and gravity turn
//WAIT 4.
//PRINT "Roll Program".
//LOCK steering TO heading(target_heading, 89.5).

// Gravity turn parameters
//LOCK current_pitch TO MIN(MAX(1.316002341e-9 * airspeed ^ 3 + 1.673966174e-5 * airspeed ^ 2 - 8.742062075e-2 * airspeed + 91.65636466, 0), 85).

SET half_alt TO 16000.
SET max_alt TO 40000.
SET c_term TO half_alt ^ 2 / (half_alt - max_alt) ^ 2.
SET b_term TO (sqrt(c_term) - c_term) / half_alt.
LOCK current_pitch TO MIN(MAX(90 * ln(b_term * altitude + c_term) / ln(c_term), 0), 90).
//LOCK current_pitch TO MIN(MAX(-2.727316445e-8 * airspeed ^ 3 + 9.1373501e-5 * airspeed ^ 2 - 1.383155463e-1 * airspeed + 92.45551211, 0), 85).
//LOCK current_pitch TO MIN(MAX(-1.059604392e-12 * altitude ^ 3 + 1.197134568e-7 * altitude ^ 2 - 5.014873422e-3 * altitude + 89.92611987, 0), 85).

// Gravity turn
//WAIT UNTIL airspeed > 50.
WAIT 4.
PRINT "Gravity Turn and Roll Program".
LOCK steering TO heading(target_heading, current_pitch).

WHEN altitude > max_alt THEN {
	PRINT "Gravity Turn Complete".
	SET current_pitch TO 0.
}

// Throttle Down
WAIT UNTIL apoapsis >= target_apoapsis * 0.99.
PRINT "Throttle Down".
SET current_throttle TO 0.1.

// MECO
WAIT UNTIL apoapsis >= target_apoapsis.
PRINT "Main Engine Cutoff".
SET current_throttle TO 0.

// Adjustments post MECO
UNTIL altitude > body:atm:height {
	IF apoapsis < target_apoapsis * 0.999 {
		SET current_throttle TO 0.1.
		WAIT UNTIL apoapsis >= target_apoapsis.
		SET current_throttle TO 0.
	}.
}.

// Final Adjustment
IF apoapsis < target_apoapsis {
	SET current_throttle TO 0.05.
	WAIT UNTIL apoapsis >= target_apoapsis.
	SET current_throttle TO 0.
}.

// Circularization
IF do_circularization = 1 {
	SET deltaA TO maxthrust / mass.
	SET radiusAtAp TO body:radius + apoapsis.
	SET orbitalVelocity TO body:radius * sqrt(9.8 / radiusAtAp).
	SET apVelocity TO sqrt(body:mu * ((2 / radiusAtAp)-(1 / ship:obt:semimajoraxis))).
	SET deltaV TO (orbitalVelocity - apVelocity).
	SET timeToBurn TO deltaV / deltaA.
	SET circNode TO node(time:seconds + eta:apoapsis, 0, 0, deltaV).
	ADD circNode.
	LOCK steering TO circNode:burnvector.
	SET totalDeltaV TO circNode:burnvector:mag.
	WAIT UNTIL VECTORANGLE(ship:facing:vector, circNode:burnvector) < 1.
	SET warp TO 2.
	WAIT UNTIL circNode:eta < timeToBurn / 2 + 10.
	SET warp TO 0.
	WAIT UNTIL circNode:eta < timeToBurn / 2.
	PRINT "Circularization burn".
	SET current_throttle TO 1.
	WAIT UNTIL circNode:burnvector:mag < 5.
	SET current_throttle TO 0.05.
	WAIT UNTIL circNode:burnvector:mag <= 0.1.
	SET current_throttle TO 0.
}

// Launch complete
UNLOCK ALL.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS ON.
PRINT "LAUNCH COMPLETE".