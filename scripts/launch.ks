// Launch parameters
DECLARE PARAMETER target_apoapsis.
DECLARE PARAMETER target_heading.
//DECLARE PARAMETER do_circularization. // Disabled temporarily
SET do_circularization TO 0.

IF target_apoapsis = "LKO" {
	SET target_apoapsis TO 80000.
} ELSE IF target_apoapsis = "MKO" {
	SET target_apoapsis TO 250000.
} ELSE IF target_apoapsis = "GSO" OR target_apoapsis = "KSO" {
	SET target_apoapsis TO 2868750.73317.
}.

// Runs code for the launch
RUN launchBootstrap.