"use strict";

var g_nClientPointCapMax = -1;
var g_nClientPointCapUsed = -1;
var g_nRewardLineTier1 = -1;
var g_nRewardLineTier2 = -1;
var g_nNumRewardRequests = 0;
var g_nBossEntIndex = -1;

// $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("AghsStatusScepterContainer").style["visibility"] = "collapse";
// $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("AghsStatusShard").style["visibility"] = "collapse";
$.GetContextPanel()
	.GetParent()
	.GetParent()
	.GetParent()
	.FindChildTraverse("AghsStatusScepterContainer")
	.GetParent().style["visibility"] = "collapse";

// var context = $.GetContextPanel()
// context.style['margin-top'] = '-110%';

// function showHud() {
// 	context.style['margin-top'] = '0%';
// }

// GameEvents.Subscribe( "selection_done", showHud );

function SetSpectatorChatText(data) {
	$("#SpectatorChat").text = $.Localize(data["name"]) + " says " + data["msg"];
	$.Msg(data["msg"]);
}
GameEvents.Subscribe("spectator_chat", SetSpectatorChatText);

$.GetContextPanel().SetDialogVariableInt("battle_points", 0);
$.GetContextPanel().SetDialogVariableInt("arcane_fragments", 0);

//-----------------------------------------------------------------------------------------
function intToARGB(i) {
	return (
		("00" + (i & 0xff).toString(16)).substr(-2) +
		("00" + ((i >> 8) & 0xff).toString(16)).substr(-2) +
		("00" + ((i >> 16) & 0xff).toString(16)).substr(-2) +
		("00" + ((i >> 24) & 0xff).toString(16)).substr(-2)
	);
}

//-----------------------------------------------------------------------------------------
$.Schedule(0.0, function () {
	// Startup code
	UpdateGlobalUIElements();

	var nPlayerID = Players.GetLocalPlayer();
	if (nPlayerID < 0 || nPlayerID > 3 || Players.IsLocalPlayerLiveSpectating() || Players.IsSpectator(nPlayerID)) {
		nPlayerID = 0;
	}

	var hMinimapInfo = CustomNetTables.GetTableValue("game_global", "minimap_info" + nPlayerID);
	if (hMinimapInfo != null) {
		OnHeroChangedRoom(hMinimapInfo);
	}
});

function OnGameGlobalChanged(table_name, key, data) {
	if (key == "ascension_level") {
		UpdateGlobalUIElements();
		return;
	}

	var nPlayerID = Players.GetLocalPlayer();
	if (nPlayerID < 0 || nPlayerID > 3 || Players.IsLocalPlayerLiveSpectating() || Players.IsSpectator(nPlayerID)) {
		nPlayerID = 0;
	}

	if (key == "minimap_info" + nPlayerID) {
		OnHeroChangedRoom(data);
	}
}

CustomNetTables.SubscribeNetTableListener("game_global", OnGameGlobalChanged);

//-----------------------------------------------------------------------------------------
function UpdateGlobalUIElements() {
	var AscensionLevel = CustomNetTables.GetTableValue("game_global", "ascension_level");
	var nAscensionLevel = AscensionLevel ? AscensionLevel["1"] : 0;
	$("#DifficultyContainer").SetDialogVariable(
		"difficulty_name",
		$.Localize("TI10_EventGame_AscensionName_" + nAscensionLevel),
	);
	$("#DifficultyContainer").SwitchClass("ascension_level", "AscensionLevel" + nAscensionLevel);
}

function OnHeroChangedRoom(data) {
	//$.Msg( "OnHeroChangedRoom" );
	$("#OverlayMap").fixedoffsetenabled = true;
	$("#OverlayMap").SetFixedOffset(data["x"], data["y"]);
	$("#OverlayMap").mapscale = data["scale"];
	$("#OverlayMap").SetFixedBackgroundTexturePosition(data["size"], data["x"], data["y"]);

	var szName = "materials/overviews/" + data["map_name"] + ".vtex";
	//$.Msg( "Setting map texture " + szName );
	$("#OverlayMap").maptexture = szName;
}

var g_szEncounterName = null;

function OnIntroduceEncounter(data) {
	if (data === null) return;

	g_szEncounterName = data.encounter_name;

	$("#RoomDiscoverPanel")
		.FindChildInLayoutFile("EncounterNameLabel")
		.SetDialogVariable("encounter_name", $.Localize(data.encounter_name));
	$("#RoomDiscoverPanel")
		.FindChildInLayoutFile("InProgressEncounterNameLabel")
		.SetDialogVariable("encounter_name", $.Localize(data.encounter_name));
	$("#RoomDiscoverPanel").SetHasClass("InProgress", false);
	$("#RoomDiscoverPanel").SetHasClass("Visible", true);
	$("#RoomDiscoverPanel").SetHasClass("HardRoom", data["hard_room"] == 1);
	$("#RoomDiscoverPanel").SwitchClass("DifficultyLevel", "Difficulty" + data["total_difficulty"]);
	$("#RoomDiscoverPanel").SwitchClass("EncounterName", data.encounter_name);
	$("#RoomDiscoverPanel").SwitchClass("RoomType", data.room_type);
	$("#RoomDiscoverPanel").SetDialogVariable("encounter_depth", Number(data.encounter_depth) - 1);

	var hAbilitiesContainer = $("#RoomDiscoverPanel").FindChildInLayoutFile("AscensionAbilitiesContainer");
	var hAbilitiesContainerInProgress = $("#RoomDiscoverPanel").FindChildInLayoutFile(
		"AscensionAbilitiesContainerInProgress",
	);
	hAbilitiesContainer.RemoveAndDeleteChildren();
	hAbilitiesContainerInProgress.RemoveAndDeleteChildren();
	var bHasAscensionAbilities = false;
	if (data["ascension_abilities"] != null) {
		for (var key of Object.keys(data["ascension_abilities"])) {
			var abilityName = data["ascension_abilities"][key];
			if (abilityName == null) continue;

			bHasAscensionAbilities = true;
			var hAbilityPanel = $.CreatePanel("Panel", hAbilitiesContainer, abilityName);
			hAbilityPanel.BLoadLayoutSnippet("AscensionAbilitySnippet");
			hAbilityPanel.SetDialogVariable("ability_name", $.Localize(abilityName));

			hAbilityPanel = $.CreatePanel("Panel", hAbilitiesContainerInProgress, abilityName);
			hAbilityPanel.BLoadLayoutSnippet("AscensionAbilitySnippet");
			hAbilityPanel.SetDialogVariable("ability_name", $.Localize(abilityName));
		}
	}

	$("#RoomDiscoverPanel").SetHasClass("HasAscensionAbilities", bHasAscensionAbilities);
	//Game.EmitSound( "RoomDiscover" );

	$.Schedule(8.0, EndEncounterIntroduction);
}

function EndEncounterIntroduction() {
	$("#RoomDiscoverPanel").SetHasClass("InProgress", true);
}

GameEvents.Subscribe("introduce_encounter", OnIntroduceEncounter);

function OnCompleteEncounter() {
	$("#RoomDiscoverPanel").SetHasClass("Visible", false);
	$("#RoomDiscoverPanel").SetHasClass("InProgress", false);
	$("#RoomDiscoverPanel").FindChildInLayoutFile("ObjectivesContainer").RemoveAndDeleteChildren();
}

GameEvents.Subscribe("complete_encounter", OnCompleteEncounter);

function OnEncounterUpdated() {
	var Depth = CustomNetTables.GetTableValue("encounter_state", "depth");
	var szCurrentDepth = Depth ? Depth["1"] : null;
	if (szCurrentDepth === null) return;

	var data = CustomNetTables.GetTableValue("encounter_state", szCurrentDepth);
	if (data == null) return;

	var ObjectivesContainer = $("#RoomDiscoverPanel").FindChildTraverse("ObjectivesContainer");
	for (var key of Object.keys(data["objectives"])) {
		var Objective = data["objectives"][key];
		if (Objective == null) continue;

		//$.Msg( "Found an objective" );
		var ObjectivePanel = ObjectivesContainer.FindChildTraverse(Objective["name"]);
		if (ObjectivePanel === null) {
			var nOrder = Objective["order"];
			var hBeforeChild = null;
			for (var nChild = 0; nChild < ObjectivesContainer.GetChildCount(); nChild++) {
				var hChild = ObjectivesContainer.GetChild(nChild);
				if (hChild == null) continue;

				if (hChild.GetAttributeInt("order", 0) >= nOrder) {
					hBeforeChild = hChild;
					break;
				}
			}

			//$.Msg( "Creating new snippet" );
			ObjectivePanel = $.CreatePanel("Panel", ObjectivesContainer, Objective["name"]);
			ObjectivePanel.BLoadLayoutSnippet("ObjectveSnippet_GoalValue");
			if (hBeforeChild != null) {
				ObjectivesContainer.MoveChildBefore(ObjectivePanel, hBeforeChild);
			}
			ObjectivePanel.SetAttributeInt("order", nOrder);
		}

		var szObjectiveLocString = Objective["name"];
		ObjectivePanel.SetDialogVariable("objective", $.Localize(szObjectiveLocString));

		var nValue = Objective["value"];
		ObjectivePanel.SetDialogVariableInt("value", nValue);

		var nGoal = Objective["goal"];
		ObjectivePanel.SetDialogVariableInt("goal", nGoal);

		ObjectivePanel.SetHasClass("Simple", nGoal == 0);
	}

	UpdateBonusRound();
}

CustomNetTables.SubscribeNetTableListener("encounter_state", OnEncounterUpdated);

function OnBossUpdated() {
	var CurrentBoss = CustomNetTables.GetTableValue("boss_net_table", "current_boss");

	if (CurrentBoss) {
		$("#BossHealthBarContainer").SetHasClass("Visible", CurrentBoss.active == true && g_bInBossCamera == false);
		g_nBossEntIndex = CurrentBoss.ent_index;

		$("#BossLabel").text = $.Localize(CurrentBoss.unit_name);

		$("#BossHealthBarContainer").SwitchClass("class", "Boss_" + CurrentBoss.unit_name);

		if (CurrentBoss.active) {
			//var flBossHP = CurrentBoss.hp;
			$("#BossProgressBar").value = CurrentBoss.hp;
			//BossThink();
		}
	}
}

CustomNetTables.SubscribeNetTableListener("boss_net_table", OnBossUpdated);

function OnBattleRoyaleDamageStarting() {
	$("#BattleRoyaleDamageStarting").AddClass("Visible");
	$("#BattleRoyaleDamageStarting").RemoveClass("Visible");
}

GameEvents.Subscribe("battle_royale_damage_starting", OnBattleRoyaleDamageStarting);

function OnGainedLife(data) {
	var heroImage = $("#1UpHeroIcon");
	var heroImageShadow = $("#1UpHeroIconOutline");
	var localPlayerInfo = Game.GetLocalPlayerInfo();
	var heroName = Players.GetPlayerSelectedHero(localPlayerInfo.player_id);
	var vAbsOrigin = Entities.GetAbsOrigin(localPlayerInfo.player_selected_hero_entity_index);
	var panel = $("#1UpPopup");

	var nX = Game.WorldToScreenX(vAbsOrigin[0], vAbsOrigin[1], vAbsOrigin[2]);
	var nY = Game.WorldToScreenY(vAbsOrigin[0], vAbsOrigin[1], vAbsOrigin[2]);
	panel.style.x = nX / panel.actualuiscale_x - panel.actuallayoutwidth / 2 + "px";
	panel.style.y = nY / panel.actualuiscale_y - 150 + "px";

	panel.SetHasClass("Play1Up", true);

	heroImage.heroname = heroName;
	heroImageShadow.heroname = heroName;
	Game.EmitSound("Dungeon.Plus1");
	$.Schedule(3.0, HideGainedLife);
}

// GameEvents.Subscribe( "gained_life", OnGainedLife );

function HideGainedLife() {
	var panel = $("#1UpPopup");
	panel.SetHasClass("Play1Up", false);
}

function OnLostLife(data) {
	var heroImage = $("#1UpHeroIcon");
	var heroImageShadow = $("#1UpHeroIconOutline");
	var localPlayerInfo = Game.GetLocalPlayerInfo();
	var heroName = Players.GetPlayerSelectedHero(localPlayerInfo.player_id);
	var vAbsOrigin = Entities.GetAbsOrigin(localPlayerInfo.player_selected_hero_entity_index);
	var panel = $("#1UpPopup");

	var nX = Game.WorldToScreenX(vAbsOrigin[0], vAbsOrigin[1], vAbsOrigin[2]);
	var nY = Game.WorldToScreenY(vAbsOrigin[0], vAbsOrigin[1], vAbsOrigin[2]);
	panel.style.x = nX / panel.actualuiscale_x - panel.actuallayoutwidth / 2 + "px";
	panel.style.y = nY / panel.actualuiscale_y - 150 + "px";

	panel.SetHasClass("Play1Up", true);
	panel.SetHasClass("LifeLost", true);

	heroImage.heroname = heroName;
	heroImageShadow.heroname = heroName;
	//Game.EmitSound( "Dungeon.Plus1" );
	$.Schedule(3.0, HideLostLife);
}

// GameEvents.Subscribe( "life_lost", OnLostLife );

function HideLostLife() {
	var panel = $("#1UpPopup");
	panel.SetHasClass("Play1Up", false);
	panel.SetHasClass("LifeLost", false);
}

function OnCurrencyUpdated() {
	var nPlayerID = Players.GetLocalPlayer();
	var nTeam = Players.GetTeam(nPlayerID);
	if (nTeam != DOTATeam_t.DOTA_TEAM_GOODGUYS && nTeam != DOTATeam_t.DOTA_TEAM_BADGUYS) return;

	var data = CustomNetTables.GetTableValue("currency_rewards", nPlayerID.toString());
	$("#EarnedPointsContainer").SetDialogVariableInt("battle_points", data["battle_points"]);
	// $("#EarnedPointsContainer").SetDialogVariableInt("arcane_fragments", data["arcane_fragments"]);
}

const local_fragments_hud = $("#LocalFragments");
function OnFragmentsUpdated(data) {
	local_fragments_hud.text = ParseBigNumber(data.coins);
}

GameEvents.Subscribe("battlepass_inventory:update_coins", OnFragmentsUpdated);
GameEvents.Subscribe("battlepass_inventory:update_player_info", OnFragmentsUpdated);
GameEvents.SendCustomGameEventToServer("battlepass_inventory:get_glory_info", {});

CustomNetTables.SubscribeNetTableListener("currency_rewards", OnCurrencyUpdated);

var g_bBonusActive = false;
var g_flBonusEndTime = -1;

function OnBonusStart(data) {
	var BonusPanel = $("#BonusPanel");
	var PlayerIDs = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS);

	for (var nPlayerID = 0; nPlayerID < PlayerIDs.length; nPlayerID++) {
		var HeroIcon = BonusPanel.FindChildTraverse("BonusPlayerIcon" + nPlayerID.toString());
		HeroIcon.heroname = Players.GetPlayerSelectedHero(nPlayerID);

		var colorInt = Players.GetPlayerColor(nPlayerID);
		var colorString = "#" + intToARGB(colorInt);

		var PlayerName = BonusPanel.FindChildTraverse("BonusPlayerName" + nPlayerID.toString());
		PlayerName.style.color = colorString;

		BonusPanel.SetDialogVariable("player_name_" + nPlayerID.toString(), Players.GetPlayerName(nPlayerID));
		BonusPanel.SetDialogVariableInt("bags_" + nPlayerID.toString(), 0);
	}

	g_flBonusEndTime = data["end_time"];
	BonusPanel.SetDialogVariableInt("time_left", Math.ceil(g_flBonusEndTime - Game.GetGameTime()));
	BonusPanel.SetDialogVariable("encounter_name", $.Localize(g_szEncounterName));
	BonusPanel.SetHasClass("FinalGoldVisible", false);
	BonusPanel.SetDialogVariableInt("total_gold", 0);
	BonusPanel.SetHasClass("Visible", true);

	g_bBonusActive = true;

	$.GetContextPanel().SetHasClass("BonusActive", g_bBonusActive);

	UpdateBonusRound();
}

GameEvents.Subscribe("bonus_start", OnBonusStart);

function UpdateBonusRound() {
	var BonusPanel = $("#BonusPanel");
	var data = CustomNetTables.GetTableValue("encounter_state", "bonus");
	if (data == null) return;

	var PlayerIDs = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS);
	for (var nPlayerID = 0; nPlayerID < PlayerIDs.length; nPlayerID++) {
		var playerData = data[nPlayerID];
		if (playerData == null) continue;

		BonusPanel.SetDialogVariableInt("bags_" + nPlayerID.toString(), playerData["bags"]);
	}

	BonusPanel.SetDialogVariableInt("time_left", Math.ceil(g_flBonusEndTime - Game.GetGameTime()));

	if (g_bBonusActive) {
		$.Schedule(Game.GetGameFrameTime(), UpdateBonusRound);
	}
}

function OnBonusComplete(data) {
	$.Schedule(10.0, FinishBonusRound);

	var nTotalGold = 0;

	var PlayerIDs = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS);
	for (var nPlayerID = 0; nPlayerID < PlayerIDs.length; nPlayerID++) {
		var playerData = data[nPlayerID];
		if (playerData == null) continue;

		nTotalGold = nTotalGold + playerData["bags"];
	}

	$("#BonusPanel").SetDialogVariableInt("total_gold", nTotalGold);
	$("#BonusPanel").SetHasClass("FinalGoldVisible", true);

	g_bBonusActive = false;
	$.GetContextPanel().SetHasClass("BonusActive", g_bBonusActive);

	if (!Players.IsSpectator(Players.GetLocalPlayer())) {
		var nPlayerHeroEntIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
		GameUI.SetCameraTarget(nPlayerHeroEntIndex);
		$.Schedule(Game.GetGameFrameTime(), FixCamera);
	}
}

function FinishBonusRound() {
	var BonusPanel = $("#BonusPanel");
	BonusPanel.SetHasClass("Visible", false);
	BonusPanel.SetDialogVariableInt("total_gold", 0);
	BonusPanel.SetHasClass("FinalGoldVisible", false);

	var PlayerIDs = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS);
	for (var nPlayerID = 0; nPlayerID < PlayerIDs.length; nPlayerID++) {
		BonusPanel.SetDialogVariableInt("bags_" + nPlayerID.toString(), 0);
	}
}

GameEvents.Subscribe("bonus_complete", OnBonusComplete);

function OnRoomDataUpdated() {
	var MazeMap = $("#MazeMap");
	for (var nActChild = 0; nActChild < MazeMap.GetChildCount(); nActChild++) {
		var ActContainer = MazeMap.GetChild(nActChild);
		if (ActContainer == null) continue;

		for (var nRoomChild = 0; nRoomChild < ActContainer.GetChildCount(); nRoomChild++) {
			var RoomPanel = ActContainer.GetChild(nRoomChild);
			if (RoomPanel == null) continue;

			var data = CustomNetTables.GetTableValue("room_data", RoomPanel.id);
			if (data == null) continue;

			if (RoomPanel.GetAttributeInt("loaded_snippet", 0) == 0) {
				RoomPanel.BLoadLayoutSnippet("MazeRoomSnippet");
				RoomPanel.SetAttributeInt("loaded_snippet", 1);
			}

			RoomPanel.SwitchClass("RewardClass", data["reward"]);
			RoomPanel.SetHasClass("RewardRoom", data["room_type"] == 6);
			RoomPanel.SetHasClass("BossRoom", data["room_type"] == 4);
			RoomPanel.SetHasClass("TransitionRoom", data["room_type"] == 5);
			RoomPanel.SetHasClass("Completed", data["completed"] == 1);
			RoomPanel.SetHasClass("Current", data["current_room"] == 1);

			if (data["map_name"] != null && (data["current_room"] == 1 || data["completed"] == 1)) {
				RoomPanel.AddClass(data["map_name"]);

				var szFileName = "s2r://materials/overviews/" + data["map_name"] + ".vtex";
				var szStyle = 'url( "' + szFileName + '" )';
				RoomPanel.style.backgroundImage = szStyle;
			}

			var szEntranceClass = "Entrance" + data["entrance_direction"];
			RoomPanel.SwitchClass("EntranceDirection", szEntranceClass);

			var szExitClass = "Exit" + data["exit_direction"];
			RoomPanel.SwitchClass("ExitDirection", szExitClass);
			if (data["current_room"] == 1 && !Players.IsSpectator(Players.GetLocalPlayer())) {
				RoomPanel.FindChildTraverse("PlayerLocator").heroname = Players.GetPlayerSelectedHero(
					Players.GetLocalPlayer(),
				);
			}
			RoomPanel.SetHasClass("Elite", data["elite"] > 0);
		}
	}
}

CustomNetTables.SubscribeNetTableListener("room_data", OnRoomDataUpdated);

function OnOpenMapButtonClicked() {
	$("#MazeMap").ToggleClass("MapOpen");
}

OnRoomDataUpdated();

var g_bInBossCamera = false;
var g_nBossCameraEntIndex = false;
var g_flCameraDesiredOffset = 128.0;
var g_flAdditionalCameraOffset = 0.0;
var g_flMaxLookDistance = 1134.0;
var g_flCameraYawSpeed = 0.05;
var g_flInitialYaw = 0;

function OnBossIntroBegin(data) {
	if (g_bInBossCamera === true) return;

	//Game.EmitSound( "Dungeon.Stinger02" );
	//Game.EmitSound( "Dungeon.BossBar" );

	g_bInBossCamera = true;

	g_flInitialYaw = GameUI.GetCameraYaw();

	GameUI.SetCameraPitchMin(data["camera_pitch"]);
	GameUI.SetCameraPitchMax(data["camera_pitch"]);
	GameUI.SetCameraDistance(data["camera_distance"]);
	GameUI.SetCameraLookAtPositionHeightOffset(data["camera_height"]);
	GameUI.SetCameraTarget(data["boss_ent_index"]);
	//GameUI.SetCameraYaw( data["camera_initial_yaw"] );

	g_flCameraYawSpeed = data["camera_yaw_rotate_speed"];
}

GameEvents.Subscribe("boss_intro_begin", OnBossIntroBegin);

function OnBossIntroEnd(data) {
	g_bInBossCamera = false;
	g_nBossCameraEntIndex = -1;

	GameUI.SetCameraPitchMin(38);
	GameUI.SetCameraPitchMax(60);
	GameUI.SetCameraDistance(1134.0);
	GameUI.SetCameraLookAtPositionHeightOffset(0);
	GameUI.SetCameraTarget(-1);
	GameUI.SetCameraYaw(g_flInitialYaw);

	if (!Players.IsSpectator(Players.GetLocalPlayer())) {
		var nPlayerHeroEntIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
		GameUI.SetCameraTarget(nPlayerHeroEntIndex);
		$.Schedule(Game.GetGameFrameTime(), FixCamera);
	}

	g_flCameraYawSpeed = 0.05;
}

function FixCamera() {
	GameUI.SetCameraTarget(-1);
}

GameEvents.Subscribe("boss_intro_end", OnBossIntroEnd);

function OnBossFightFinished(data) {
	//Game.EmitSound( "Dungeon.Stinger01" );
}

GameEvents.Subscribe("boss_fight_finished", OnBossFightFinished);

var g_vWorldHintLoc = null;

GameEvents.Subscribe("start_world_text_hint", StartWorldTextHint);
function StartWorldTextHint(event) {
	var vAbsOrigin = [event["location_x"], event["location_y"], event["location_z"]];
	var nX = Game.WorldToScreenX(vAbsOrigin[0], vAbsOrigin[1], vAbsOrigin[2]);
	var nY = Game.WorldToScreenY(vAbsOrigin[0], vAbsOrigin[1], vAbsOrigin[2]);

	g_vWorldHintLoc = vAbsOrigin;

	if (event["command"] >= 0) {
		$("#WorldHintPanel").SetDialogVariable(
			"keybind",
			"<panel class='" + Game.GetKeybindForCommand(event["command"]) + "'/>",
		);
		$("#WorldHintPanel").SetDialogVariable(
			"secondary_keybind",
			"<panel class='" + GetSecondaryKeybindForCommand(event["command"]) + "'/>",
		);
		$("#WorldHintPanel").SetDialogVariable(
			"alternate_keybind",
			"<panel class='" + GetAlternateKeybindForCommand(event["command"]) + "'/>",
		);
	}

	var szLocalizedName = $.Localize(event["hint_text"], $("#WorldHintPanel"));
	$("#WorldHintPanel").SetDialogVariable("world_hint_text", szLocalizedName);
	$("#WorldHintPanel").style.x =
		nX / $("#WorldHintPanel").actualuiscale_x - $("#WorldHintPanel").actuallayoutwidth / 2 + "px";
	$("#WorldHintPanel").style.y = nY / $("#WorldHintPanel").actualuiscale_y + 75 + "px";
	$("#WorldHintPanel").SetHasClass("HintVisible", true);
}

function GetSecondaryKeybindForCommand(nCommand) {
	switch (nCommand) {
		case DOTAKeybindCommand_t.DOTA_KEYBIND_HERO_ATTACK:
		case DOTAKeybindCommand_t.DOTA_KEYBIND_HERO_MOVE:
		case DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORYTP:
		case DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY1:
		case DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY2:
		case DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_PRIMARY3:
		case DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_SECONDARY1:
		case DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_SECONDARY2:
		case DOTAKeybindCommand_t.DOTA_KEYBIND_ABILITY_ULTIMATE:
		case DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY1:
		case DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY2:
		case DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY3:
		case DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY4:
		case DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY5:
		case DOTAKeybindCommand_t.DOTA_KEYBIND_INVENTORY6:
			return "MOUSE1";
	}

	return Game.GetKeybindForCommand(nCommand);
}

function GetAlternateKeybindForCommand(nCommand) {
	if (nCommand === DOTAKeybindCommand_t.DOTA_KEYBIND_HERO_MOVE) return "MOUSE2";

	return Game.GetKeybindForCommand(nCommand);
}

GameEvents.Subscribe("stop_world_text_hint", StopWorldTextHint);
function StopWorldTextHint(event) {
	g_vWorldHintLoc = null;
	$("#WorldHintPanel").SetHasClass("HintVisible", false);
}

GameEvents.Subscribe("begin_aghanim_victory", BeginAghanimVictory);
function BeginAghanimVictory(data) {
	g_bInBossCamera = true;

	GameUI.MoveCameraToEntity(data["ent_index"]);

	GameUI.SetCameraPitchMin(35);
	GameUI.SetCameraPitchMax(35);
	GameUI.SetCameraDistance(800);
	GameUI.SetCameraLookAtPositionHeightOffset(350);
	GameUI.SetCameraTarget(data["ent_index"]);

	var vAghanimAngles = Entities.GetAbsAngles(data["ent_index"]);
	GameUI.SetCameraYaw(vAghanimAngles[1] - 10 + 90);

	g_flCameraYawSpeed = 0.025;
}

(function HUDThink() {
	if (g_vWorldHintLoc !== null) {
		var nX = Game.WorldToScreenX(g_vWorldHintLoc[0], g_vWorldHintLoc[1], g_vWorldHintLoc[2]);
		var nY = Game.WorldToScreenY(g_vWorldHintLoc[0], g_vWorldHintLoc[1], g_vWorldHintLoc[2]);
		$("#WorldHintPanel").style.x =
			nX / $("#WorldHintPanel").actualuiscale_x - $("#WorldHintPanel").actuallayoutwidth / 2 + "px";
		$("#WorldHintPanel").style.y = nY / $("#WorldHintPanel").actualuiscale_y + 75 + "px";
	}

	// if ( g_bDialogActive )
	// {
	// 	AdvanceDialog();
	// }

	if (g_bInBossCamera) {
		GameUI.SetCameraYaw(GameUI.GetCameraYaw() + g_flCameraYawSpeed);
		//var vCameraLookAtPos = GameUI.GetCameraLookAtPosition();
		//GameUI.SetCameraPositionFromLateralLookAtPosition( vCameraLookAtPos[0], vCameraLookAtPos[1] );
	}

	$.Schedule(0.003, HUDThink);
})();

(function CenterCameraForLiveSpectator() {
	// Center the camera on the first goodguys hero
	// NOTE: At the point at which this is called, live spectators are still on team goodguys
	// and they are later switched to team spectator.
	// So what we'll do to be reasonable is just move any player who doesn't have a player hero ent index
	var nLocalPlayerHeroEntIndex = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());
	if (nLocalPlayerHeroEntIndex > 0 && Players.GetTeam(Players.GetLocalPlayer()) == 2) return;

	var bFound = false;
	var vecPlayers = Game.GetPlayerIDsOnTeam(DOTATeam_t.DOTA_TEAM_GOODGUYS);
	if (vecPlayers != null) {
		for (var szPlayerID in vecPlayers) {
			var nPlayerID = Number(szPlayerID);

			var playerHeroEntIndex = Players.GetPlayerHeroEntityIndex(nPlayerID);
			if (playerHeroEntIndex > 0) {
				GameUI.MoveCameraToEntity(playerHeroEntIndex);
				bFound = true;
				break;
			}
		}
	}

	if (bFound == false) {
		$.Schedule(0.003, CenterCameraForLiveSpectator);
	}
})();

//

const UpgradesWiki = $.GetContextPanel().FindChildInLayoutFile("UpgradesWiki");
const UpgradesWikiContainer = $.GetContextPanel().FindChildInLayoutFile("UpgradesWikiContainer");
const UpgradesWikiHeader = $.GetContextPanel().FindChildInLayoutFile("UpgradesWikiHeader");
const UpgradesWikiSubheader = $.GetContextPanel().FindChildInLayoutFile("UpgradesWikiSubheader");
const UpgradesWikiScenePanel = $.GetContextPanel().FindChildInLayoutFile("UpgradesWikiScenePanel");

const UpgradesWiki2 = $.GetContextPanel().FindChildInLayoutFile("UpgradesWiki2");
const UpgradesWikiContainer2 = $.GetContextPanel().FindChildInLayoutFile("UpgradesWikiContainer2");
const UpgradesWikiHeader2 = $.GetContextPanel().FindChildInLayoutFile("UpgradesWikiHeader2");
const UpgradesWikiSubheader2 = $.GetContextPanel().FindChildInLayoutFile("UpgradesWikiSubheader2");
const UpgradesWikiScenePanel2 = $.GetContextPanel().FindChildInLayoutFile("UpgradesWikiScenePanel2");

const WikiHomeButton = $("#WikiHomeButton");
const LocalID = Players.GetLocalPlayer();

function ShowRewardWiki(heroToShow) {
	UpgradesWiki.style["visibility"] = "collapse";
	UpgradesWiki2.style["visibility"] = "visible";

	const data = upgrade_list;
	if (!data) {
		$.Msg("no data, aborting reward wiki call");
		return;
	}

	UpgradesWikiContainer2.RemoveAndDeleteChildren();
	for (let name in data[heroToShow]) {
		if (name != "heroid") {
			UpgradesWikiHeader2.text = $.Localize(heroToShow + "_full_title");
			UpgradesWikiSubheader2.text = $.Localize(heroToShow + "_full_title_intro");
			UpgradesWikiScenePanel2.SetScenePanelToLocalHero(data[heroToShow]["heroid"]);

			var rewardPanel = $.CreatePanel("Panel", UpgradesWikiContainer2, "");
			rewardPanel.AddClass("WikiEntryContainer");

			var rewardPanelImage = $.CreatePanel("Image", rewardPanel, "");
			rewardPanelImage.AddClass("WikiEntryImage");
			// $.Msg('url("s2r://' + data[name] + '")');
			rewardPanelImage.style["background-image"] = 'url("s2r://' + data[heroToShow][name] + '")';

			var rewardPanelImageOverlay = $.CreatePanel("Panel", rewardPanel, "");
			rewardPanelImageOverlay.AddClass("WikiEntryImageOverlay");

			var rewardPanelName = $.CreatePanel("Label", rewardPanel, "");
			rewardPanelName.AddClass("WikiEntryName");
			rewardPanelName.text = $.Localize("DOTA_Tooltip_Ability_" + name);

			var rewardPanelDesc = $.CreatePanel("Label", rewardPanel, "");
			rewardPanelDesc.AddClass("WikiEntryDesc");
			var desc = GameUI.ReplaceDOTAAbilitySpecialValues(
				name,
				$.Localize("DOTA_Tooltip_Ability_" + name + "_Description"),
				rewardPanel,
			);
			desc = desc.replace(/class="GameplayValues"/g, "");
			desc = desc.replace(/class="GameplayVariable"/g, "");
			desc = desc.replace(/<span /g, "");
			desc = desc.replace(/<\/span>/g, "");
			desc = desc.replace(/>/g, "");
			rewardPanelDesc.text = desc;
		}
	}
}

var upgrade_list;

function SetUpgradeList(kv) {
	upgrade_list = kv.upgrade_list;
}
GameEvents.Subscribe("send_wiki_upgrades", SetUpgradeList);

function ShowWikiHome(kv) {
	const pinfo = Game.GetPlayerInfo(LocalID);

	UpgradesWikiContainer.RemoveAndDeleteChildren();
	UpgradesWikiScenePanel.SetScenePanelToLocalHero(pinfo["player_selected_hero_id"]);
	UpgradesWikiScenePanel.SetPanelEvent("onactivate", () => ShowRewardWiki(Players.GetPlayerSelectedHero(LocalID)));

	UpgradesWikiHeader.text = $.Localize("wiki_header");
	UpgradesWikiSubheader.text = $.Localize("wiki_subheader");
	for (let hero in kv) {
		if (hero != "splitscreenplayer") {
			const nameplate = $.CreatePanel("Button", UpgradesWikiContainer, "");
			nameplate.AddClass("HeroHomeNameplate");

			const heroPanel = $.CreatePanel("DOTAScenePanel", nameplate, "");
			heroPanel.AddClass("HeroHomeScenePanel");
			heroPanel.style["width"] = "100%";
			heroPanel.style["height"] = "100%";
			heroPanel.SetScenePanelToLocalHero(kv[hero]);
			heroPanel.SetPanelEvent("onactivate", () => ShowRewardWiki(hero));
			heroPanel.antialias = "true";
			heroPanel.renderdeferred = "true";
			heroPanel.drawbackground = "false";
			heroPanel.FireEntityInput("hero_prop_0", "TurnOff", "1");

			nameplate.SetPanelEvent("onactivate", () => ShowRewardWiki(hero));

			const nameplateLabel = $.CreatePanel("Label", nameplate, "");
			nameplateLabel.text = $.Localize(hero);
		}
	}
}
GameEvents.Subscribe("pathfinder_wiki_hero_list", ShowWikiHome);

function ShoWikiButton() {
	GameEvents.SendCustomGameEventToServer("get_heroes_list", {
		self_hero_name: Players.GetPlayerSelectedHero(LocalID),
	});
	$.Msg("Panorama sending get_heroes_list to all");
	WikiHomeButton.style["visibility"] = "visible";
}
GameEvents.Subscribe("show_wiki_button", ShoWikiButton);

function OnWikiHomeClick() {
	UpgradesWiki2.style["visibility"] = "collapse";

	if (UpgradesWiki.style["visibility"] != "visible") {
		UpgradesWiki.style["visibility"] = "visible";
	} else {
		UpgradesWiki.style["visibility"] = "collapse";
	}
}
