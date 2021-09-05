$("#face_selected").unit = "npc_dota_hero_wisp";

var intBG = [
	'url("s2r://panorama/images/compendium/international2017/scroll_texture_psd.vtex")',
	'url("s2r://panorama/images/compendium/international2017/scroll_left_texture_psd.vtex");',
];

var agiBG = [
	'url("s2r://panorama/images/compendium/international2018/scroll_texture_psd.vtex")',
	'url("s2r://panorama/images/compendium/international2018/scroll_left_texture_psd.vtex");',
];

var strBG = [
	'url("s2r://panorama/images/compendium/newbloom_scroll_texture_psd.vtex")',
	'url("s2r://panorama/images/compendium/newbloom_scroll_left_texture_psd.vtex");',
];

var locked_heroes = [];

var hero_names = [
	"npc_dota_hero_axe",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_tidehunter",
	"npc_dota_hero_venomancer",
	"npc_dota_hero_disruptor",
	"npc_dota_hero_magnataur",
	"npc_dota_hero_mars",
	"npc_dota_hero_snapfire",
	"npc_dota_hero_phoenix",
	"npc_dota_hero_sniper",
	"npc_dota_hero_tusk",
	"npc_dota_hero_ursa",
	"npc_dota_hero_viper",
	"npc_dota_hero_weaver",
	"npc_dota_hero_winter_wyvern",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_slark",
	"npc_dota_hero_queenofpain",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_legion_commander",
	"npc_dota_hero_juggernaut",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_jakiro",
	"npc_dota_hero_hoodwink",
	"npc_dota_hero_dawnbreaker",
	"npc_dota_hero_dazzle",
	"npc_dota_hero_pangolier",
	"npc_dota_hero_invoker",
	"npc_dota_hero_dark_willow",
];

var current_selection = hero_names[Game.GetLocalPlayerID()];

// function CreatePopuplateHeroScenesAction(data)
// {
//     var scenePanel = $("#HeroScene1")
//     var playerSlot = data.playerSlot;
//     var matchID = data.matchID;
//     scenePanel.SpawnHeroInScenePanelByPlayerSlotWithFullBodyView(matchID, playerSlot);
//     // scenePanel.SetScenePanelToLocalHero(playerSlot);
//     scenePanel.SetCustomPostProcessMaterial("materials/dev/deferred_post_process_graphic_ui.vmat");
// }
// GameEvents.Subscribe( "populate_hero_panel", CreatePopuplateHeroScenesAction );

function OpenPatreon() {
	$.DispatchEvent("ExternalBrowserGoToURL", "https://www.patreon.com/dota2unofficial");
}

function SetDisplayHero(heroName) {
	// if (Number($("#" + heroName).style["brightness"]) != 1) {
	//     return
	// }
	GameEvents.SendCustomGameEventToAllClients("unfade_face", { hero: current_selection });
	var id = Game.GetLocalPlayerID();
	// var chosen_str = "p" + String(id + 1) + "_" + heroName;
	// for (var i = 0; i < hero_names.length; i++){
	//     var ent_str = "p" + String(id + 1) + "_" + hero_names[i];
	//     if (chosen_str == ent_str) {
	//         $.DispatchEvent("DOTAGlobalSceneFireEntityInput", "scene", ent_str, "Enable", 0)
	//     } else {
	//         $.DispatchEvent("DOTAGlobalSceneFireEntityInput", "scene", ent_str, "Disable", 0)
	//     }
	// }
	var hero = heroName.slice(14);

	if (hero == "legion_commander") {
		hero = "legioncommander";
	} else if (hero == "witch_doctor") {
		hero = "witchdoctor";
	} else if (hero == "templar_assassin") {
		hero = "templarassassin";
	} else if (hero == "phantom_assassin") {
		hero = "phantomassassin";
	} else if (hero == "ogre_magi") {
		hero = "OgreMagi";
	} else if (hero == "juggernaut") {
		Game.EmitSound("juggernaut_jug_spawn_03");
	} else if (hero == "dragon_knight") {
		hero = "DragonKnight";
	}

	Game.EmitSound("Hero_" + hero + ".Pick");
	current_selection = heroName;
	GameEvents.SendCustomGameEventToAllClients("fade_face", { hero: current_selection });

	GameEvents.SendCustomGameEventToAllClients("broadcast_pick", { hero: current_selection, pid: id });
}

function ClickFaceInt(heroName) {
	if (locked_heroes.includes(heroName)) {
		return;
	}
	var id = Game.GetLocalPlayerID();

	var context = $.GetContextPanel();

	var button = context.FindChildrenWithClassTraverse("RedConfirm")[0];
	var buttonL = $("#RedConfirmLeft");
	var buttonR = $("#RedConfirmRight");
	// button.style.position = '0px 0px 3px';

	// $("#grid_container").style.opacity = 0;
	button.style["background-image"] = intBG[0];
	buttonL.style["background-image"] = intBG[1];
	buttonR.style["background-image"] = intBG[1];

	SetDisplayHero(heroName);
}

function ClickFaceAgi(heroName) {
	if (locked_heroes.includes(heroName)) {
		return;
	}
	var id = Game.GetLocalPlayerID();

	var context = $.GetContextPanel();

	var button = context.FindChildrenWithClassTraverse("RedConfirm")[0];
	var buttonL = $("#RedConfirmLeft");
	var buttonR = $("#RedConfirmRight");
	// button.style.position = '0px 0px 3px';

	// $("#grid_container").style.opacity = 0;
	button.style["background-image"] = agiBG[0];
	buttonL.style["background-image"] = agiBG[1];
	buttonR.style["background-image"] = agiBG[1];

	SetDisplayHero(heroName);
}

function ClickFaceStr(heroName) {
	if (locked_heroes.includes(heroName)) {
		return;
	}
	var id = Game.GetLocalPlayerID();

	var context = $.GetContextPanel();

	var button = context.FindChildrenWithClassTraverse("RedConfirm")[0];
	var buttonL = $("#RedConfirmLeft");
	var buttonR = $("#RedConfirmRight");
	// button.style.position = '0px 0px 3px';

	// $("#grid_container").style.opacity = 0;
	button.style["background-image"] = strBG[0];
	buttonL.style["background-image"] = strBG[1];
	buttonR.style["background-image"] = strBG[1];

	SetDisplayHero(heroName);
}

function UnclickFace() {
	var context = $.GetContextPanel();

	var button = context.FindChildrenWithClassTraverse("RedConfirm")[0];
	// button.style.position = '500px 0px 3px';

	// $("#grid_container").style.opacity = 1;
}

function LockFace() {
	$("#grid_container").style["width"] = "0%";
	var local_id = Game.GetLocalPlayerID();
	GameEvents.SendCustomGameEventToServer("pick_face", { hero: current_selection, id: local_id });

	GameEvents.SendCustomGameEventToAllClients("lock_face", { hero: current_selection, pid: local_id });
	$.Schedule(1, function () {
		GameEvents.SendCustomGameEventToAllClients("lock_face", { hero: current_selection, pid: local_id });
	});
}

function getRandomInt(min, max) {
	min = Math.ceil(min);
	max = Math.floor(max);
	return Math.floor(Math.random() * (max - min + 1)) + min;
}

function LockFaceRandom() {
	var rand = getRandomInt(0, hero_names.length - 1);

	SetDisplayHero(hero_names[rand]);

	LockFace();
}

function OnPickingDone(data) {}
GameEvents.Subscribe("selection_done", OnPickingDone);

/* Visual timer update */
function OnTimeUpdate(data) {
	$("#TimerTxtTop").text = data.time;
	var id = Game.GetLocalPlayerID();
	GameEvents.SendCustomGameEventToAllClients("broadcast_pick", { hero: current_selection, pid: id });

	if (data.time <= 10) {
		Game.EmitSound("General.CastFail_AbilityInCooldown");
	} else {
		Game.EmitSound("BUTTON_MOUSE_OVER ");
	}
}
GameEvents.Subscribe("picking_time_update", OnTimeUpdate);

function UpdatePlayerName(data) {
	var pID = data.id + 1;
	var txt = "#name" + pID + "_text";
	$(txt).text = data.name;
}
GameEvents.Subscribe("player_name_init", UpdatePlayerName);

function DisableFace(data) {
	var hero = data.hero;
	var id = data.pid;
	// $("#" + hero).style["box-shadow"] = "inset #FF0D0D 0px 0px 120px 0px";
	$("#" + hero).style["wash-color"] = "rgba(247, 27, 38, 0.99)";
	ShowReadyParticle(id);
	$.Schedule(1, () => ShowReadyParticle(id));
	$.Schedule(3, () => ShowReadyParticle(id));
	$.Schedule(5, () => ShowReadyParticle(id));
	$.Schedule(10, () => ShowReadyParticle(id));
	$.Schedule(15, () => ShowReadyParticle(id));
	$.Schedule(25, () => ShowReadyParticle(id));
	locked_heroes.push(hero);
}
GameEvents.Subscribe("lock_face", DisableFace);

function ShowReadyParticle(id) {
	$.DispatchEvent("DOTAGlobalSceneFireEntityInput", "scene", "p" + String(id + 1) + "_ready", "Start", 0);
}

function FadeFace(data) {
	var hero = data.hero;
	$("#" + hero).style["brightness"] = "0.5";
}
GameEvents.Subscribe("fade_face", FadeFace);

function UnfadeFace(data) {
	var hero = data.hero;
	$("#" + hero).style["brightness"] = "1";
}
GameEvents.Subscribe("unfade_face", UnfadeFace);

function DisplayAllyHero(data) {
	var hero = data.hero;
	var id = data.pid;
	var chosen_str = "p" + String(id + 1) + "_" + hero;
	for (var i = 0; i < hero_names.length; i++) {
		var ent_str = "p" + String(id + 1) + "_" + hero_names[i];
		if (chosen_str == ent_str) {
			$.DispatchEvent("DOTAGlobalSceneFireEntityInput", "scene", ent_str, "Enable", 0);
		} else {
			$.DispatchEvent("DOTAGlobalSceneFireEntityInput", "scene", ent_str, "Disable", 0);
		}
	}
}
GameEvents.Subscribe("broadcast_pick", DisplayAllyHero);

function BroadcastChatInput() {
	$("#ChatMessagesContainer").ScrollToBottom();
	var input = $("#ChatBox").text;
	if (!input || /^\s*$/.test(input) || input == "") {
		$("#ChatBox").text = "";
		return;
	}

	var color = Players.GetPlayerColor(Players.GetLocalPlayer());
	var name = Players.GetPlayerName(Players.GetLocalPlayer()).substring(0, 10);

	GameEvents.SendCustomGameEventToAllClients("broadcast_chat_input", { text: input, pcolor: color, pname: name });
	$("#ChatBox").text = "";
}

function OnChatSubmit(data) {
	// var text = $("#ChatMessagesContent").text;
	var input = data.text;
	$("#ChatMessagesContainer").ScrollToBottom();

	// $("#ChatMessagesContent").text = "<font color=#FF0000>" + Players.GetPlayerName(Players.GetLocalPlayer()).substring(0, 10) + '</font>' + ": " + input + '\n' + text;

	var chat_message = $.CreatePanel("Label", $("#ChatMessagesContainer"), "");
	chat_message.AddClass("ChatMessagesContent");
	chat_message.text = data.pname + ": " + input;

	var color = toColor(data.pcolor);

	chat_message.style["color"] = color;

	$("#ChatMessagesContainer").ScrollToBottom();
}
GameEvents.Subscribe("broadcast_chat_input", OnChatSubmit);

function toColor(num) {
	num >>>= 0;
	var b = num & 0xff,
		g = (num & 0xff00) >>> 8,
		r = (num & 0xff0000) >>> 16,
		a = ((num & 0xff000000) >>> 24) / 255;
	return "rgba(" + [r, g, b, a].join(",") + ")";
}
