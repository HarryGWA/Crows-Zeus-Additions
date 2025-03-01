/*/////////////////////////////////////////////////
Author: Crowdedlight, johnb43

File: fn_zeusRegister.sqf
Parameters: none
Return: none

Using the same setup method as JShock in JSHK contamination mod.

*///////////////////////////////////////////////

// check for CBA and ZEN
if !(isClass (configFile >> "CfgPatches" >> "cba_main")) exitWith {
    diag_log text "[Crows Zeus Additions]: CBA not detected.";
};

if !(isClass (configFile >> "CfgPatches" >> "zen_custom_modules")) exitWith {
    diag_log text "[Crows Zeus Additions]: ZEN not detected.";
};

// don't load for HC / Server
if (!hasInterface || is3DEN) exitWith {};

// public global var
crowsZA_animalFollowList = [];
publicVariable "crowsZA_animalFollowList";

crowsZA_common_selectPositionActive = false;

// save ace loaded variable as public var. So context menu check just needs to check var
crowsZA_common_aceModLoaded = isClass (configFile >> "CfgPatches" >> "ace_main");
crowsZA_common_jshkModLoaded = isClass (configFile >> "CfgPatches" >> "JSHK_contam");
crowsZA_common_amfHelicoptersLoaded = isClass (configfile >> "CfgPatches" >> "AMF_Heli_Transport_01");
crowsZA_common_rhsLoaded = isClass (configfile >> "CfgPatches" >> "rhs_main");
crowsZA_common_sogLoaded = isClass (configfile >> "CfgMods" >> "vn");

// return the modules to load
private _moduleList = [
    ["Remove Trees",{_this call crowsZA_fnc_removeTreesZeus}, "\CrowsZA\data\axe.paa"],
    ["Restore Trees",{_this call crowsZA_fnc_restoreTreesZeus}, "\CrowsZA\data\tree.paa"],
    ["Follow Unit With Animal",{_this call crowsZA_fnc_animalFollowZeus}, "\CrowsZA\data\sheep.paa"],
    ["Delete All Follow Animals",{_this call crowsZA_fnc_deleteAllAnimalFollow}, "\CrowsZA\data\sheep.paa"],
    ["Scatter Teleport",{_this call crowsZA_fnc_scatterTeleportZeus}, "\CrowsZA\data\tp.paa"],
    ["Spawn Arsenal",{_this call crowsZA_fnc_spawnArsenal}, "\a3\ui_f\data\logos\a_64_ca.paa"],
    ["Set Numberplate",{_this call crowsZA_fnc_setNumberplate}, "\CrowsZA\data\numberplate.paa"],
    ["Delete ALL dead",{_this call crowsZA_fnc_deleteAllDead}, "\CrowsZA\data\cleanup.paa"],
    ["Set Colour",{_this call crowsZA_fnc_setColour}, "\CrowsZA\data\paint.paa"],
    ["Teleport To Squadmember",{_this call crowsZA_fnc_teleportToSquadMember}, "\CrowsZA\data\tpToSquad.paa"],
    ["DrawBuild",{_this call crowsZA_fnc_drawBuildZeus}, "\CrowsZA\data\drawbuild.paa"],
    ["Fire Support",{_this call crowsZA_fnc_fireSupport}, "\x\zen\addons\modules\ui\target_ca.paa"],
    ["Resupply Player Loadouts",{_this call crowsZA_fnc_resupplyPlayerLoadouts}, "\CrowsZA\data\resupplyplayerloadout.paa"],
    ["Remove Radio/Bino",{_this call crowsZA_fnc_removeRadioBino}, "\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\call_ca.paa"],
    ["Spawn IED Clutter",{_this call crowsZA_fnc_spawnIEDClutterZeus}, "\a3\ui_f\data\igui\cfg\simpletasks\types\destroy_ca.paa"],
    ["Strip Explosives",{_this call crowsZA_fnc_stripExplosivesZeus}, "\a3\ui_f\data\igui\cfg\simpletasks\types\destroy_ca.paa"],
    ["Surrender Chance",{_this call crowsZA_fnc_surrenderChanceZeus}, "\a3\ui_f\data\igui\cfg\holdactions\holdAction_secure_ca.paa"],
    ["Set Teleport to Squadmember",{_this call crowsZA_fnc_setTeleportToSquadMemberZeus}, "\CrowsZA\data\tpToSquad.paa"]
];

// check if ace is loaded
if (crowsZA_common_aceModLoaded) then {
    _moduleList append [
        ["ACE Add Damage to Unit",{_this call crowsZA_fnc_aceDamageToUnit}, "\CrowsZA\data\sword.paa"],
        ["Mass-Unconscious Toggle",{_this call crowsZA_fnc_massUnconscious}, "\z\ace\addons\zeus\UI\Icon_Module_Zeus_Unconscious_ca.paa"],
        ["Capture Player",{_this call crowsZA_fnc_capturePlayer}, "\z\ace\addons\captives\UI\captive_ca.paa"],
        ["Mass-Surrender Toggle",{_this call crowsZA_fnc_massSurrender}, "\z\ace\addons\captives\UI\Surrender_ca.paa"],
        ["Set Supply Vehicle",{_this call crowsZA_fnc_setSupplyVehicle}, "\CrowsZA\data\rearmvehicle.paa"]
    ];
};

// check if tfar is loaded
if (isClass (configFile >> "CfgPatches" >> "task_force_radio")) then {
    _moduleList append [
        ["Set TFAR Vehicle Radio Side",{_this call crowsZA_fnc_tfarSetVehicleSide}, "\a3\Ui_f\data\GUI\Cfg\CommunicationMenu\call_ca.paa"]
    ];
};

// registering ZEN custom modules
{
    [
        "Crows Zeus Modules", (_x select 0), (_x select 1), (_x select 2)
    ] call zen_custom_modules_fnc_register;
} forEach _moduleList;

// launch custom "handlers" for ace and display the ping box, when opened curator display for the first time
["zen_curatorDisplayLoaded", {
    // remove event immediately
    [_thisType, _thisId] call CBA_fnc_removeEventHandler;

    call crowsZA_fnc_enablePingBoxHUD;

    if (crowsZA_common_aceModLoaded) then {
        call crowsZA_fnc_activateZeusTextDisplay;
    };
}] call CBA_fnc_addEventHandlerArgs;



private _contextActionList = [
    // Action name, Display name, Icon and Icon colour, code, Condition to show, arguments, dynamic children, modifier functions
    [
        ["camera_center_unit","Camera Center Unit","\CrowsZA\data\camera.paa", {_hoveredEntity call crowsZA_fnc_centerZeusViewUnit}, {!isNull _hoveredEntity && (typeName _hoveredEntity) isNotEqualTo "GROUP"}] call zen_context_menu_fnc_createAction,
        [],
        0
    ],
    [
        ["teleport_to_squadmate","Teleport To Squadmate","\CrowsZA\data\tpToSquad.paa", {[[],_hoveredEntity] call crowsZA_fnc_teleportToSquadMember}, {!isNull _hoveredEntity && [_hoveredEntity] call crowsZA_fnc_isAliveManUnit && (count units group leader _hoveredEntity) > 1}] call zen_context_menu_fnc_createAction,
        [],
        6
    ],
    [
        ["paste_loadout_to_inventory","Paste Loadout","\CrowsZA\data\paste.paa", {_hoveredEntity call crowsZA_fnc_contextPasteLoadout}, {!isNil "zen_context_actions_loadout" && !isNull _hoveredEntity}] call zen_context_menu_fnc_createAction,
        ["Inventory"],
        0
    ],
    [
        ["loadout_viewer","View","\a3\Ui_F_Curator\Data\RscCommon\RscAttributeInventory\filter_0_ca.paa", {_hoveredEntity call crowsZA_fnc_loadoutViewer}, {[_hoveredEntity] call crowsZA_fnc_isAliveManUnit}] call zen_context_menu_fnc_createAction,
        ["Loadout"],
        0
    ],
    [
        ["radius_heal","Radius Heal","\CrowsZA\data\radiusheal.paa", {[_position] call crowsZA_fnc_radiusHealDialog}, {true}, [], {[
            [["radius_heal_10","10m","\CrowsZA\data\radiusheal.paa", {[_position, 10] call crowsZA_fnc_radiusHeal}] call zen_context_menu_fnc_createAction, [], 10],
            [["radius_heal_50","50m","\CrowsZA\data\radiusheal.paa", {[_position, 50] call crowsZA_fnc_radiusHeal}] call zen_context_menu_fnc_createAction, [], 10],
            [["radius_heal_100","100m","\CrowsZA\data\radiusheal.paa", {[_position, 100] call crowsZA_fnc_radiusHeal}] call zen_context_menu_fnc_createAction, [], 10],
            [["radius_heal_150","150m","\CrowsZA\data\radiusheal.paa", {[_position, 150] call crowsZA_fnc_radiusHeal}] call zen_context_menu_fnc_createAction, [], 10]
        ]}] call zen_context_menu_fnc_createAction,
        ["HealUnits"],
        0
    ],
    [
        ["jshk_heal","JSHK Heal","\z\ace\addons\medical_gui\ui\cross.paa", {_hoveredEntity call crowsZA_fnc_jshkHeal}, {[_hoveredEntity] call crowsZA_fnc_isAliveManUnit && crowsZA_common_aceModLoaded && crowsZA_common_jshkModLoaded && (_hoveredEntity getVariable ["ACE_isUnconscious", false]) == true}] call zen_context_menu_fnc_createAction,
        ["HealUnits"],
        0
    ],
    [
        ["toggle_pathing","Toggle Pathing","\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", {}, {true}, [], {[
            [["toggle_pathing_radius","Radius","\CrowsZA\data\radiusheal.paa", {}, {true}, [], {[
                [["toggle_pathing_radius_10","10m","\CrowsZA\data\radiusheal.paa", { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 10]; [_units, 2] call crowsZA_fnc_togglePathing }, {true}, [], {[
                    [["toggle_pathing_unit_off","Off",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0.5,0,0,1]], { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 10]; [_units, 0] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_unit_on","On","\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 10]; [_units, 1] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_unit_toggle","Toggle",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0,0.3,0.6,1]], { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 10]; [_units, 2] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10]
                ]}] call zen_context_menu_fnc_createAction, [], 10],
                [["toggle_pathing_radius_50","50m","\CrowsZA\data\radiusheal.paa", { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 50]; [_units, 2] call crowsZA_fnc_togglePathing }, {true}, [], {[
                    [["toggle_pathing_unit_off","Off",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0.5,0,0,1]], { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 50]; [_units, 0] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_unit_on","On","\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 50]; [_units, 1] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_unit_toggle","Toggle",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0,0.3,0.6,1]], { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 50]; [_units, 2] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10]
                ]}] call zen_context_menu_fnc_createAction, [], 10],
                [["toggle_pathing_radius_100","100m","\CrowsZA\data\radiusheal.paa", { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 100]; [_units, 2] call crowsZA_fnc_togglePathing}, {true}, [], {[
                    [["toggle_pathing_unit_off","Off",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0.5,0,0,1]], { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 100]; [_units, 0] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_unit_on","On","\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 100]; [_units, 1] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_unit_toggle","Toggle",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0,0.3,0.6,1]], { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 100]; [_units, 2] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10]
                ]}] call zen_context_menu_fnc_createAction, [], 10],
                [["toggle_pathing_radius_200","200m","\CrowsZA\data\radiusheal.paa", { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 200]; [_units, 2] call crowsZA_fnc_togglePathing }, {true}, [], {[
                    [["toggle_pathing_unit_off","Off",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0.5,0,0,1]], { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 200]; [_units, 0] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_unit_on","On","\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 200]; [_units, 1] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_unit_toggle","Toggle",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0,0.3,0.6,1]], { private _units = (ASLToAGL _position) nearEntities [["Man", "LandVehicle"], 200]; [_units, 2] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10]
                ]}] call zen_context_menu_fnc_createAction, [], 10]
            ]}] call zen_context_menu_fnc_createAction, [], 10],

            [["toggle_pathing_unit","Unit","\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", { [[_hoveredEntity], 2] call crowsZA_fnc_togglePathing }, {((typeName _hoveredEntity) isEqualTo "OBJECT") && {(group _hoveredEntity) isNotEqualTo grpNull}}, [], {[
                [["toggle_pathing_unit_off","Off",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0.5,0,0,1]], { [[_hoveredEntity], 0] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10],
                [["toggle_pathing_unit_on","On","\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", { [[_hoveredEntity], 1] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10],
                [["toggle_pathing_unit_toggle","Toggle",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0,0.3,0.6,1]], { [[_hoveredEntity], 2] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10]
            ]}] call zen_context_menu_fnc_createAction, [], 10],

            [["toggle_pathing_unit","Group","\A3\ui_f\data\map\markers\nato\o_unknown.paa", { [units _hoveredEntity, 2] call crowsZA_fnc_togglePathing }, {(typeName _hoveredEntity) isEqualTo "GROUP" || {((typeName _hoveredEntity) isEqualTo "OBJECT") && {(group _hoveredEntity) isNotEqualTo grpNull}}}, [], {[
                [["toggle_pathing_group_off","Off",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0.5,0,0,1]], { [units _hoveredEntity, 0] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10],
                [["toggle_pathing_group_on","On","\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", { [units _hoveredEntity, 1] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10],
                [["toggle_pathing_group_toggle","Toggle",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0,0.3,0.6,1]], { [units _hoveredEntity, 2] call crowsZA_fnc_togglePathing }] call zen_context_menu_fnc_createAction, [], 10]
            ]}] call zen_context_menu_fnc_createAction, [], 10],

            [["toggle_pathing_side","Side","\A3\ui_f\data\map\markers\nato\b_unknown.paa", {}, {true}, [], {[
                [["toggle_pathing_blufor","BLUFOR",["\A3\ui_f\data\map\markers\nato\b_unknown.paa", [0,0.3,0.6,1]], {[units west, 2] call crowsZA_fnc_togglePathing}, {true}, [], {[
                    [["toggle_pathing_b_off","Off",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0.5,0,0,1]], {[units west, 0] call crowsZA_fnc_togglePathing}] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_b_on","On","\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", {[units west, 1] call crowsZA_fnc_togglePathing}] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_b_toggle","Toggle",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0,0.3,0.6,1]], {[units west, 2] call crowsZA_fnc_togglePathing}] call zen_context_menu_fnc_createAction, [], 10]
                ]}] call zen_context_menu_fnc_createAction, [], 10],
                
                [["toggle_pathing_opfor","OPFOR",["\A3\ui_f\data\map\markers\nato\o_unknown.paa", [0.5,0,0,1]], {[units east, 2] call crowsZA_fnc_togglePathing}, {true}, [], {[
                    [["toggle_pathing_o_off","Off",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0.5,0,0,1]], {[units east, 0] call crowsZA_fnc_togglePathing}] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_o_on","On","\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", {[units east, 1] call crowsZA_fnc_togglePathing}] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_o_toggle","Toggle",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0,0.3,0.6,1]], {[units east, 2] call crowsZA_fnc_togglePathing}] call zen_context_menu_fnc_createAction, [], 10]
                ]}] call zen_context_menu_fnc_createAction, [], 10],

                [["toggle_pathing_indfor","INDFOR",["\A3\ui_f\data\map\markers\nato\n_unknown.paa", [0,0.5,0,1]], {[units independent, 2] call crowsZA_fnc_togglePathing}, {true}, [], {[
                    [["toggle_pathing_i_off","Off",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0.5,0,0,1]], {[units independent, 0] call crowsZA_fnc_togglePathing}] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_i_on","On","\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", {[units independent, 1] call crowsZA_fnc_togglePathing}] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_i_toggle","Toggle",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0,0.3,0.6,1]], {[units independent, 2] call crowsZA_fnc_togglePathing}] call zen_context_menu_fnc_createAction, [], 10]
                ]}] call zen_context_menu_fnc_createAction, [], 10],

                [["toggle_pathing_civ","CIV",["\A3\ui_f\data\map\markers\nato\c_unknown.paa", [0.4,0,0.5,1]], {[units civilian, 2] call crowsZA_fnc_togglePathing}, {true}, [], {[
                    [["toggle_pathing_c_off","Off",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0.5,0,0,1]], {[units civilian, 0] call crowsZA_fnc_togglePathing}] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_c_on","On","\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", {[units civilian, 1] call crowsZA_fnc_togglePathing}] call zen_context_menu_fnc_createAction, [], 10],
                    [["toggle_pathing_c_toggle","Toggle",["\a3\ui_f\data\IGUI\Cfg\simpleTasks\types\walk_ca.paa", [0,0.3,0.6,1]], {[units civilian, 2] call crowsZA_fnc_togglePathing}] call zen_context_menu_fnc_createAction, [], 10]
                ]}] call zen_context_menu_fnc_createAction, [], 10]
            ]}] call zen_context_menu_fnc_createAction, [], 10]
        ]}] call zen_context_menu_fnc_createAction,
        [],
        0
    ]
];

// register context actions
{
    [
        // action, parent path, priority
        (_x select 0), (_x select 1), (_x select 2)
    ] call zen_context_menu_fnc_addAction;
} forEach _contextActionList;

// register zeus RC eventhandlers
["zen_remoteControlStarted", crowsZA_fnc_eventZeusStartRC] call CBA_fnc_addEventHandler;
["zen_remoteControlStopped", crowsZA_fnc_eventZeusStopRC] call CBA_fnc_addEventHandler;

diag_log text "[Crows Zeus Additions]: Zeus initialization complete. Zeus Enhanced detected.";
