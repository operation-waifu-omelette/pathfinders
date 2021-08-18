

GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_MINIMAP, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_ITEMS, false);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_CUSTOMUI_BEHIND_HUD_ELEMENTS, false);
        
GameUI.SetCameraYaw(0);
$("#face_selected").heroname = "npc_dota_hero_wisp";

function RemoveCover() {
    if ($("#LoadingCover")){
        $("#LoadingCover").style['position'] = '3000px 0px 0px';
        $("#LoadingCover").RemoveAndDeleteChildren();
    }
}
GameEvents.Subscribe("remove_cover", RemoveCover);


function PathfinderHeroSelect(data)
{		        
    var to = Entities.GetAbsOrigin(parseInt(Entities.GetAllEntitiesByName('anchor')[0]));

    var playerInd = Players.GetPlayerHeroEntityIndex(Players.GetLocalPlayer());

    InitialYaw = GameUI.GetCameraYaw();
    
    var pitch = 350;

	GameUI.SetCameraPitchMin(  pitch );
	GameUI.SetCameraPitchMax( pitch );
	GameUI.SetCameraDistance(250 );
    GameUI.SetCameraLookAtPositionHeightOffset(320);
    GameUI.SetCameraYaw( 20 );
    //GameUI.SetCameraTarget( to );
    GameUI.SetCameraTargetPosition(to, 0.4)        
}
GameEvents.Subscribe("pathfinder_hero_select", PathfinderHeroSelect);

var intBG = ['url("s2r://panorama/images/compendium/international2017/scroll_texture_psd.vtex")',
    'url("s2r://panorama/images/compendium/international2017/scroll_left_texture_psd.vtex");']
            
var agiBG = ['url("s2r://panorama/images/compendium/international2018/scroll_texture_psd.vtex")',
    'url("s2r://panorama/images/compendium/international2018/scroll_left_texture_psd.vtex");']
            
var strBG = ['url("s2r://panorama/images/compendium/newbloom_scroll_texture_psd.vtex")',
            'url("s2r://panorama/images/compendium/newbloom_scroll_left_texture_psd.vtex");']

function ClickFaceInt(heroName) {    
    var id = Game.GetLocalPlayerID()    

    var context = $.GetContextPanel()

    var button = context.FindChildrenWithClassTraverse("RedConfirm")[0]    
    var buttonL = $("#RedConfirmLeft")
    var buttonR = $("#RedConfirmRight")
    button.style.position = '0px 0px 3px'; 
    
    $("#grid_container").style.opacity = 0;
    button.style['background-image'] = intBG[0];
    buttonL.style['background-image'] = intBG[1];
    buttonR.style['background-image'] = intBG[1];
    if (heroName != $("#face_selected").heroname) {
        $("#face_selected").heroname = heroName;
        GameEvents.SendCustomGameEventToServer("pick_face", { hero: heroName, pid: id });   
    }   
    var hero = heroName.slice(14);  
    
    if (hero == "legion_commander") {
        hero = "legioncommander";
    }
    else if (hero == "witch_doctor") {
        hero = "witchdoctor"
    }
    else if (hero == "templar_assassin") {
        hero = "templarassassin"
    }
    else if (hero == "phantom_assassin") {
        hero = "phantomassassin"
    }
    
    Game.EmitSound("Hero_" + hero + ".Pick");
}

function ClickFaceAgi(heroName) {    
    var id = Game.GetLocalPlayerID()    


    var context = $.GetContextPanel()

    var button = context.FindChildrenWithClassTraverse("RedConfirm")[0]    
    var buttonL = $("#RedConfirmLeft")
    var buttonR = $("#RedConfirmRight")
    button.style.position = '0px 0px 3px'; 
    
    $("#grid_container").style.opacity = 0;
    button.style['background-image'] = agiBG[0];
    buttonL.style['background-image'] = agiBG[1];
    buttonR.style['background-image'] = agiBG[1];

    if (heroName != $("#face_selected").heroname) {
        $("#face_selected").heroname = heroName;
        GameEvents.SendCustomGameEventToServer("pick_face", { hero: heroName, pid: id });   
    }   
    var hero = heroName.slice(14);
    
    if (hero == "legion_commander") {
        hero = "legioncommander";
    }
    else if (hero == "witch_doctor") {
        hero = "witchdoctor"
    }
    else if (hero == "templar_assassin") {
        hero = "templarassassin"
    }
    else if (hero == "phantom_assassin") {
        hero = "phantomassassin"
    }    
    Game.EmitSound("Hero_" + hero + ".Pick");
}


function ClickFaceStr(heroName) {    
    var id = Game.GetLocalPlayerID()        
    

    var context = $.GetContextPanel()

    var button = context.FindChildrenWithClassTraverse("RedConfirm")[0]    
    var buttonL = $("#RedConfirmLeft")
    var buttonR = $("#RedConfirmRight")
    button.style.position = '0px 0px 3px'; 
    
    $("#grid_container").style.opacity = 0;
    button.style['background-image'] = strBG[0];
    buttonL.style['background-image'] = strBG[1];
    buttonR.style['background-image'] = strBG[1];

    if (heroName != $("#face_selected").heroname) {
        $("#face_selected").heroname = heroName;
        GameEvents.SendCustomGameEventToServer("pick_face", { hero: heroName, pid: id });   
    }

    var hero = heroName.slice(14);
    
    if (hero == "legion_commander") {
        hero = "legioncommander";
    }
    else if (hero == "witch_doctor") {
        hero = "witchdoctor";
    }
    else if (hero == "templar_assassin") {
        hero = "templarassassin";
    }
    else if (hero == "phantom_assassin") {
        hero = "phantomassassin";
    }
    else if (hero == "juggernaut") {
        Game.EmitSound("juggernaut_jug_acknow_01");
    }        
    Game.EmitSound("Hero_" + hero + ".Pick");    
}


function UnclickFace() {        
    var context = $.GetContextPanel();

    var button = context.FindChildrenWithClassTraverse("RedConfirm")[0];
    button.style.position = '500px 0px 3px';   
    
    $("#grid_container").style.opacity = 1;

}

function LockFace() {        
    var context = $.GetContextPanel();
    var button = context.FindChildrenWithClassTraverse("RedConfirm")[0];
    button.style.position = '150px 0px 3px';         

    GameEvents.SendCustomGameEventToServer("hero_selected", {hero: $("#face_selected").heroname, id: Game.GetLocalPlayerID()    });
}

function getRandomInt(min, max) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}

function LockFaceRandom() {        
    var context = $.GetContextPanel();
    
    var int_faces = context.FindChildrenWithClassTraverse("face_int");
    var agi_faces = context.FindChildrenWithClassTraverse("face_agi");
    var str_faces = context.FindChildrenWithClassTraverse("face_str");
        
    var rand = getRandomInt(1, 3);



    if (rand == 3) {
        ClickFaceStr('npc_dota_hero_' + str_faces[Math.floor(Math.random() * str_faces.length)].heroname);
    }
    else if (rand == 2) {
        ClickFaceAgi('npc_dota_hero_' + agi_faces[Math.floor(Math.random() * agi_faces.length)].heroname);
    }
    else if (rand == 1) {
        ClickFaceInt('npc_dota_hero_' + int_faces[Math.floor(Math.random() * int_faces.length)].heroname);
    }        
        
    LockFace();
}

function LockFaceVoiceLine(hero) {    
    if (hero == "legion_commander") {
        hero = "legioncommander";
    }
    else if (hero == "witch_doctor") {
        hero = "wd"
    }
    else if (hero == "templar_assassin") {
        hero = "ta"
    }
    else if (hero == "phantom_assassin") {
        hero = "pa"
    }  
    else if (hero == "omniknight") {
        hero = "omni"
    }
    else if (hero == "windrunner") {
        hero = "wr"
    }
    else if (hero == "auroth") {
        hero = "winter_wyvern"
    }
    else if (hero == "venomancer") {
        hero = "veno"
    }
    else if (hero == "queenofpain") {
        hero = "qop"
    }
    else if (hero == "winter_wyvern") {
        hero = "auroth"
    }
    if (hero != "viper") {
        Game.EmitSound("announcer_dlc_bastion_announcer_pick_" + hero + "_follow");
        $.Msg("announcer_dlc_bastion_announcer_pick_" + hero + "_follow");
    }
    else {
        if (Math.random() < 0.5) {
            Game.EmitSound("announcer_dlc_bastion_announcer_pick_" + hero + "_follow");
        }
        else {
            Game.EmitSound("viper_vipe_spawn_04");
        }        
    }

    if (hero == "tusk") {
        Game.EmitSound("announcer_dlc_bastion_announcer_pick_tuskkar_follow_02");
    }
    else if (hero == "mars") {
        Game.EmitSound("mars_mars_respawn_08");
    }
    else if (hero == "snapfire") {
        Game.EmitSound("snapfire_snapfire_immort_02");
    }
}


function OnPickingDone(data) {
    if ($("#LoadingCover")) {
        $("#LoadingCover").style['position'] = '3000px 0px 0px';
        $("#LoadingCover").RemoveAndDeleteChildren();
    }
    GameUI.SetCameraPitchMin( 38 );
	GameUI.SetCameraPitchMax( 60 );
	GameUI.SetCameraDistance( 1134.0 );
	GameUI.SetCameraLookAtPositionHeightOffset( 0 );
	GameUI.SetCameraTarget( -1 );
	GameUI.SetCameraYaw(0 );
     
    var context = $.GetContextPanel()   
    context.style['width'] = '0%';  
    context.style['margin-top'] = '-110%';
    context.RemoveAndDeleteChildren();
        
    
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ACTION_PANEL, true);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_PANEL, true);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_SHOP, true);
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_INVENTORY_ITEMS, true);    
    GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_CUSTOMUI_BEHIND_HUD_ELEMENTS, true);
}
GameEvents.Subscribe( "selection_done", OnPickingDone );

/* Visual timer update */
function OnTimeUpdate( data ) {    
    $("#TimerTxtTop").text = data.time;

    if (data.time <= 10) {
        Game.EmitSound("General.CastFail_AbilityInCooldown");
    }
    else {
        Game.EmitSound("BUTTON_MOUSE_OVER ");
    }
}
GameEvents.Subscribe("picking_time_update", OnTimeUpdate);


