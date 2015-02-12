DECLARE PARAMETER target_apoapsis.
DECLARE PARAMETER target_heading.
SET countdown TO 3.

// In case script is aborted
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

// Ascent parameters
LOCK current_pitch TO -2.727316445e-8 * airspeed ^ 3 + 9.1373501e-5 * airspeed ^ 2 - 1.383155463e-1 * airspeed + 92.45551211.

// Countdown
CLEARSCREEN.
PRINT "Launch for " + (round(target_apoapsis) / 1000) + "km altitude orbit.".
PRINT "Heading for " + target_heading.
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

// Auto-Stage once
WHEN stage:liquidfuel < 0.001 THEN {
	STAGE.
}.

// Roll program and gravity turn
WAIT 4.
PRINT "Roll Program".
LOCK steering TO heading(target_heading, 89.5).

// Gravity turn
WAIT UNTIL airspeed > 75.
PRINT "Gravity Turn".
LOCK steering TO heading(target_heading, 85).
WAIT UNTIL airspeed > 130.
LOCK steering TO heading(target_heading, current_pitch).

// Complete gravity turn
WHEN current_pitch < 2 OR altitude > 36000 THEN {
	PRINT "Gravity Turn Complete".
	UNLOCK current_pitch.
	LOCK steering TO heading(target_heading, 0).
}.

// Throttle Down
WAIT UNTIL apoapsis >= target_apoapsis * 0.95.
PRINT "Throttle Down".
LOCK throttle TO 0.1.

// MECO
WAIT UNTIL apoapsis >= target_apoapsis.
PRINT "Main Engine Cutoff".
LOCK throttle TO 0.

// Adjustments post MECO
UNTIL altitude > body:atm:height {
	IF apoapsis < target_apoapsis * 0.999 {
		LOCK throttle TO 0.1.
		WAIT UNTIL apoapsis >= target_apoapsis.
		LOCK throttle TO 0.
	}.
}.

// Launch complete
UNLOCK ALL.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
PRINT "LAUNCH COMPLETE".