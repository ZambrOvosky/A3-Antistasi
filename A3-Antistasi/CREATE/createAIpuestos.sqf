if (!isServer and hasInterface) exitWith{};
private ["_marcador","_vehiculos","_grupos","_soldados","_posicion","_pos","_size","_frontera","_lado","_cfg","_esFIA","_garrison","_antena","_tam","_buildings","_mrk","_cuenta","_tipoGrupo","_grupo","_tipoUnit","_tipoVeh","_veh","_unit","_bandera","_caja","_roads","_mrkMar","_vehicle","_vehCrew","_grupoVeh","_dist","_road","_roadCon","_dirVeh","_bunker","_dir","_posF"];
_marcador = _this select 0;

_vehiculos = [];
_grupos = [];
_soldados = [];

_posicion = getMarkerPos (_marcador);
_pos = [];


_size = [_marcador] call sizeMarker;

_frontera = [_marcador] call isFrontline;
_lado = muyMalos;

_esFIA = false;
if (lados getVariable [_marcador,sideUnknown] == malos) then
	{
	_lado = malos;
	if ((random 10 >= tierWar) and !(_frontera) and !(_marcador in forcedSpawn)) then
		{
		_esFIA = true;
		};
	};

_antena = objNull;

if (_lado == malos) then
	{
	if (_marcador in puestos) then
		{
		_buildings = nearestObjects [_posicion,["Land_TTowerBig_1_F","Land_TTowerBig_2_F","Land_Communication_F"], _size];
		if (count _buildings > 0) then
			{
			_antena = _buildings select 0;
			};
		};
	};

_mrk = createMarkerLocal [format ["%1patrolarea", random 100], _posicion];
_mrk setMarkerShapeLocal "RECTANGLE";
_mrk setMarkerSizeLocal [(distanciaSPWN/2),(distanciaSPWN/2)];
_mrk setMarkerTypeLocal "hd_warning";
_mrk setMarkerColorLocal "ColorRed";
_mrk setMarkerBrushLocal "DiagGrid";
_ang = markerDir _marcador;
_mrk setMarkerDirLocal _ang;
if (!debug) then {_mrk setMarkerAlphaLocal 0};
_cuenta = 0;

while {(spawner getVariable _marcador !=2) and (_cuenta < 4)} do
	{
	_arrayGrupos = if (_lado == malos) then
		{
		if (!_esFIA) then {gruposNATOsmall} else {gruposFIASmall};
		}
	else
		{
		gruposCSATsmall
		};
	if ([_marcador,false] call fogCheck < 0.3) then {_arrayGrupos = _arrayGrupos - sniperGroups};
	_tipoGrupo = selectRandom _arrayGrupos;

	_grupo = [_posicion,_lado, _tipoGrupo] call spawnGroup;
	sleep 1;
	if ((random 10 < 2.5) and (not(_tipogrupo in sniperGroups))) then
		{
		_perro = _grupo createUnit ["Fin_random_F",_posicion,[],0,"FORM"];
		[_perro] spawn guardDog;
		sleep 1;
		};
	_nul = [leader _grupo, _mrk, "SAFE","SPAWNED", "RANDOM","NOVEH2"] execVM "scripts\UPSMON.sqf";
	_grupos pushBack _grupo;
	{[_x,_marcador] call NATOinit; _soldados pushBack _x} forEach units _grupo;
	sleep 1;
	_cuenta = _cuenta +1;
	};

if ((_frontera) and (spawner getVariable _marcador!=2) and (_marcador in puestos)) then
	{
	_grupo = createGroup _lado;
	_tipoUnit = if (_lado==malos) then {staticCrewmalos} else {staticCrewMuyMalos};
	_tipoVeh = if (_lado == malos) then {NATOMortar} else {CSATMortar};
	_pos = [_posicion] call mortarPos;
	_veh = _tipoVeh createVehicle _pos;
	_nul=[_veh] execVM "scripts\UPSMON\MON_artillery_add.sqf";
	_unit = _grupo createUnit [_tipoUnit, _posicion, [], 0, "NONE"];
	[_unit,_marcador] call NATOinit;
	_unit moveInGunner _veh;
	_soldados pushBack _unit;
	_vehiculos pushBack _veh;
	sleep 1;
	};

//_buildings = nearestObjects [_posicion, listMilBld, _size*1.5];
_buildings = nearestTerrainObjects [_posicion, ["House"], _size * 1.5, false];
if (count _buildings > 0) then
	{
	_grupo = createGroup _lado;
	_grupos pushBack _grupo;
	_tipoUnit = if (_lado==malos) then {staticCrewmalos} else {staticCrewMuyMalos};
	for "_i" from 0 to (count _buildings) - 1 do
		{
		if (spawner getVariable _marcador == 2) exitWith {};
		_building = _buildings select _i;
		_tipoB = typeOf _building;
		if ((_tipoB == "Land_HelipadSquare_F") and (!_frontera)) then
			{
			_tipoVeh = if (_lado == malos) then {vehNATOPatrolHeli} else {vehCSATPatrolHeli};
			_veh = createVehicle [_tipoVeh, position _building, [],0, "CAN_COLLIDE"];
			_veh setDir (getDir _building);
			_vehiculos pushBack _veh;
			}
		else
			{
			if 	((_tipoB == "Land_Cargo_HQ_V1_F") or (_tipoB == "Land_Cargo_HQ_V2_F") or (_tipoB == "Land_Cargo_HQ_V3_F")) then
				{
				_tipoVeh = if (_lado == malos) then {staticAAmalos} else {staticAAmuyMalos};
				_veh = createVehicle [_tipoVeh, (_building buildingPos 8), [],0, "CAN_COLLIDE"];
				_veh setPosATL [(getPos _building select 0),(getPos _building select 1),(getPosATL _veh select 2)];
				_veh setDir (getDir _building);
				_unit = _grupo createUnit [_tipoUnit, _posicion, [], 0, "NONE"];
				[_unit,_marcador] call NATOinit;
				_unit moveInGunner _veh;
				_soldados pushBack _unit;
				_vehiculos pushBack _veh;
				}
			else
				{
				if 	((_tipoB == "Land_Cargo_Patrol_V1_F") or (_tipoB == "Land_Cargo_Patrol_V2_F") or (_tipoB == "Land_Cargo_Patrol_V3_F")) then
					{
					_tipoVeh = if (_lado == malos) then {NATOMG} else {CSATMG};
					_veh = createVehicle [_tipoVeh, (_building buildingPos 1), [], 0, "CAN_COLLIDE"];
					_ang = (getDir _building) - 180;
					_pos = [getPosATL _veh, 2.5, _ang] call BIS_Fnc_relPos;
					_veh setPosATL _pos;
					_veh setDir (getDir _building) - 180;
					_unit = _grupo createUnit [_tipoUnit, _posicion, [], 0, "NONE"];
					[_unit,_marcador] call NATOinit;
					_unit moveInGunner _veh;
					_soldados pushBack _unit;
					_vehiculos pushBack _veh;
					}
				else
					{
					if 	(_tipoB in listbld) then
						{
						_tipoVeh = if (_lado == malos) then {NATOMG} else {CSATMG};
						_veh = createVehicle [_tipoVeh, (_building buildingPos 11), [], 0, "CAN_COLLIDE"];
						_unit = _grupo createUnit [_tipoUnit, _posicion, [], 0, "NONE"];
						[_unit,_marcador] call NATOinit;
						_unit moveInGunner _veh;
						_soldados pushBack _unit;
						_vehiculos pushBack _veh;
						sleep 0.5;
						_veh = createVehicle [_tipoVeh, (_building buildingPos 13), [], 0, "CAN_COLLIDE"];
						_unit = _grupo createUnit [_tipoUnit, _posicion, [], 0, "NONE"];
						[_unit,_marcador] call NATOinit;
						_unit moveInGunner _veh;
						_soldados pushBack _unit;
						_vehiculos pushBack _veh;
						};
					};
				};
			};
		};
	};

_tipoVeh = if (_lado == malos) then {NATOFlag} else {CSATFlag};
_bandera = createVehicle [_tipoVeh, _posicion, [],0, "CAN_COLLIDE"];
_bandera allowDamage false;
[_bandera,"take"] remoteExec ["flagaction",[buenos,civilian],_bandera];
_vehiculos pushBack _bandera;

_caja = objNull;
if (_lado == malos) then
	{
	_caja = "B_supplyCrate_F" createVehicle _posicion;
	_nul = [_caja] call NATOcrate;
	}
else
	{
	_caja = "O_supplyCrate_F" createVehicle _posicion;
	_nul = [_caja] call CSATcrate;
	};
_vehiculos pushBack _caja;
_caja call jn_fnc_logistics_addAction;
{_nul = [_x] call AIVEHinit;} forEach _vehiculos;
_roads = _posicion nearRoads _size;

if ((_marcador in puertos) and (spawner getVariable _marcador!=2)) then
	{
	_mrkMar = seaSpawn select {getMarkerPos _x inArea _marcador};
	_tipoVeh = if (_lado == malos) then {vehNATOBoat} else {vehCSATBoat};
	_pos = (getMarkerPos (_mrkMar select 0)) findEmptyPosition [0,20,_tipoVeh];
	_vehicle=[_pos, 0,_tipoVeh, _lado] call bis_fnc_spawnvehicle;
	_veh = _vehicle select 0;
	[_veh] call AIVEHinit;
	_vehCrew = _vehicle select 1;
	{[_x,_marcador] call NATOinit} forEach _vehCrew;
	_grupoVeh = _vehicle select 2;
	_soldados = _soldados + _vehCrew;
	_grupos pushBack _grupoVeh;
	_vehiculos pushBack _veh;
	sleep 1;
	}
else
	{
	if (_frontera) then
		{
		if (spawner getVariable _marcador!=2) then
			{
			if (count _roads != 0) then
				{
				_dist = 0;
				_road = objNull;
				{if ((position _x) distance _posicion > _dist) then {_road = _x;_dist = position _x distance _posicion}} forEach _roads;
				_roadscon = roadsConnectedto _road;
				_roadcon = objNull;
				{if ((position _x) distance _posicion > _dist) then {_roadcon = _x}} forEach _roadscon;
				_dirveh = [_roadcon, _road] call BIS_fnc_DirTo;
				if (!_esFIA) then
					{
					_grupo = createGroup _lado;
					_grupos pushBack _grupo;
					_pos = [getPos _road, 7, _dirveh + 270] call BIS_Fnc_relPos;
					_bunker = "Land_BagBunker_01_Small_green_F" createVehicle _pos;
					_vehiculos pushBack _bunker;
					_bunker setDir _dirveh;
					_pos = getPosATL _bunker;
					_tipoVeh = if (_lado==malos) then {staticATmalos} else {staticATmuyMalos};
					_veh = _tipoVeh createVehicle _posicion;
					_vehiculos pushBack _veh;
					_veh setPos _pos;
					_veh setDir _dirVeh + 180;
					_tipoUnit = if (_lado==malos) then {staticCrewmalos} else {staticCrewMuyMalos};
					_unit = _grupo createUnit [_tipoUnit, _posicion, [], 0, "NONE"];
					[_unit,_marcador] call NATOinit;
					[_veh] call AIVEHinit;
					_unit moveInGunner _veh;
					_soldados pushBack _unit;
					}
				else
					{
					_veh = vehFIAArmedCar createVehicle getPos _road;
					_veh setDir _dirveh + 90;
					_nul = [_veh] call AIVEHinit;
					_vehiculos pushBack _veh;
					sleep 1;
					_tipogrupo = selectRandom gruposFIAMid;
					_grupo = [_posicion, _lado, _tipoGrupo] call spawnGroup;
					_unit = _grupo createUnit [FIARifleman, _posicion, [], 0, "NONE"];
					_unit moveInGunner _veh;
					{_soldados pushBack _x; [_x,_marcador] call NATOinit} forEach units _grupo;
					};
				};
			};
		};
	};

if (count _roads != 0) then
	{
	_pos = _posicion findEmptyPosition [5,_size,"I_Truck_02_covered_F"];//donde pone 5 antes ponía 10
	if (count _pos > 0) then
		{
		_tipoVeh = if (_lado == malos) then {if (!_esFIA) then {vehNATOTrucks} else {[vehFIATruck]}} else {vehCSATTrucks};
		_veh = createVehicle [selectRandom _tipoVeh, _pos, [], 0, "NONE"];
		_veh setDir random 360;
		_vehiculos pushBack _veh;
		_nul = [_veh] call AIVEHinit;
		sleep 1;
		};
	};

_cuenta = 0;

if ((!isNull _antena) and (spawner getVariable _marcador!=2)) then
	{
	if ((typeOf _antena == "Land_TTowerBig_1_F") or (typeOf _antena == "Land_TTowerBig_2_F")) then
		{
		_grupo = createGroup _lado;
		_pos = getPosATL _antena;
		_dir = getDir _antena;
		_posF = _pos getPos [2,_dir];
		_posF set [2,23.1];
		if (typeOf _antena == "Land_TTowerBig_2_F") then
			{
			_posF = _pos getPos [1,_dir];
			_posF set [2,24.3];
			};
		_tipoUnit = if (_lado == malos) then {if (!_esFIA) then {NATOMarksman} else {FIAMarksman}} else {CSATMarksman};
		_unit = _grupo createUnit [_tipoUnit, _posicion, [], _dir, "NONE"];
		_unit setPosATL _posF;
		_unit forceSpeed 0;
		//_unit disableAI "MOVE";
		//_unit disableAI "AUTOTARGET";
		_unit setUnitPos "UP";
		[_unit,_marcador] call NATOinit;
		_soldados pushBack _unit;
		_grupos pushBack _grupo;
		};
	};

_garrison = garrison getVariable [_marcador,[]];
_tam = count _garrison;
_array = [];
_subArray = [];
_cuenta = 0;
for "_i" from 0 to (_tam - 1) do
	{
	_subArray pushBack (_garrison select _i);
	if ((_i == (_tam - 1)) or ((floor (_i/8)) == (_i/8))) then {_array pushBack _subArray; _subArray = []};
	};
for "_i" from 0 to (count _array - 1) do
	{
	_grupo = [_posicion,_lado, (_array select _i)] call spawnGroup;
	_grupos pushBack _grupo;
	if (_i == 0) then {_nul = [leader _grupo, _marcador, "SAFE", "RANDOMUP","SPAWNED", "NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf"} else {_nul = [leader _grupo, _marcador, "SAFE","SPAWNED", "RANDOM","NOVEH2", "NOFOLLOW"] execVM "scripts\UPSMON.sqf"};
	{[_x,_marcador] call NATOinit; _soldados pushBack _x; if ((typeOf _x) in squadLeaders) then {_grupo selectLeader _x}} forEach units _grupo;
	};


if (_marcador in puertos) then
	{
	_caja addItemCargo ["V_RebreatherIA",round random 5];
	_caja addItemCargo ["G_I_Diving",round random 5];
	};

waitUntil {sleep 1; (spawner getVariable _marcador == 2)};

deleteMarker _mrk;
//{if ((!alive _x) and (not(_x in destroyedBuildings))) then {destroyedBuildings = destroyedBuildings + [position _x]; publicVariableServer "destroyedBuildings"}} forEach _buildings;
{
if (alive _x) then
	{
	deleteVehicle _x
	};
} forEach _soldados;
//if (!isNull _periodista) then {deleteVehicle _periodista};
{deleteGroup _x} forEach _grupos;
{
if (!(_x in staticsToSave)) then
	{
	if ((!([distanciaSPWN-_size,1,_x,"GREENFORSpawn"] call distanceUnits))) then {deleteVehicle _x}
	};
} forEach _vehiculos;