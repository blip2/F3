// F3 - Caching Script Init
// Credits: Please see the F3 online manual (http://www.ferstaberinde.com/f3/en/)
// ====================================================================================

// Check whether the paramater is defined - if not, just exit
if (isNil "f_param_caching") exitWith {};

// ====================================================================================

// Wait 30 seconds into the mission to give AI and players time to settle
waitUntil {time > 30};

// ====================================================================================

// Player and the headless client's (if present) groups are always excluded from being cached
if (!isDedicated && !(group player getVariable [["f_cacheExcl", false])) then {
        group player setVariable ["f_cacheExcl", true, true];
};

// ====================================================================================

// Rest of the Script is only run server-side
if !(isServer) exitWith {};

// ====================================================================================

// Make sure script is only run once
if (missionNameSpace getVariable ["f_cInit", false]) exitWith {};
f_cInit = true;

// Wait for the BIS functions to initialize
waituntil {!isnil "bis_fnc_init"};

// ====================================================================================

// All groups with playable units or only one unit are set to be ignored as well
{
	if ({_x in playableUnits} count units _x > 0 || (count units _x == 1)) then {_x setVariable ["f_cacheExcl",true,true];};
} forEach allGroups;

// Define parameters
_range = f_param_caching;	// The range outside of which to cache units
_sleep = 5; // The time to sleep between checking

[_range, _sleep] spawn f_fnc_cTracker;

// Start the debug tracker
if (f_var_debugMode == 1) then {
	player globalchat format ["f_fnc_cInit DBG: Starting to track groups, range, sleep",[count allGroups,_range,_sleep];

	[_sleep] spawn {

	// Giving the tracker a head start
	sleep (_this select 0 * 1.1);

		while {true} do {
			_str1 = "f_fnc_cache DBG:<br/>";
			_str2 = format["Total groups: %1<br/>",count allGroups];
			_str3 = format ["Cached groups:%1<br/>",{_x getvariable "f_cached"} count allGroups];
			_str4 = format ["Activated groups:%1<br/>",{!(_x getvariable "f_cached")} count allGroups];
			_str5 = format ["Excluded groups:%1<br/>",{(_x getvariable "f_cacheExcl")} count allGroups];

			hintsilent parseText (_str1+_str2+_str3+_str4+_str5);
			diag_log (_str1+_str2+_str3+_str4+_str5);

			sleep (_this select 0);
		};
	};
};


true