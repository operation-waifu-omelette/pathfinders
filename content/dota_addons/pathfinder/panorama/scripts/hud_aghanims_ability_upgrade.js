"use strict"
CustomNetTables.SubscribeNetTableListener("special_ability_upgrades", OnAbilitiesUpgradesReceived);
GameEvents.Subscribe("special_ability_upgrades_enabled", ToggleButton)
GameEvents.Subscribe("special_ability_upgrades_button_clicked", AbilityButtonClicked)


var UpgradeAbilitiesPanel = $.GetContextPanel().FindChildInLayoutFile("UpgradeAbilitiesPanel");
var UpgradeAbilitiesButton = $.GetContextPanel().FindChildInLayoutFile("UpgradeAbilitiesPanelButtonOuter");
var SkillTreePanel = $.GetContextPanel().FindChildInLayoutFile("SkillTree");
var SkillInstanceSnippet = $.GetContextPanel().FindChildInLayoutFile("SkillInstanceSnippet");
var SkillAbilityContainer = $.GetContextPanel().FindChildrenWithClassTraverse("AbilityContainer");






function ToggleSkillTree()
{
    // Toggles the visibility of the actual ability list

    Game.EmitSound("ui.books.pageturns");
    UpgradeAbilitiesPanel.ToggleClass("Hidden");

    return;
}


function ToggleButton() {
    // Toggles the visibility of the ability list button (toggled with the special_ability_upgrades_enabled convar)
        $.Msg("ToggleButton");
    UpgradeAbilitiesButton.ToggleClass("Hidden");

  


    var specialAbilities = CustomNetTables.GetTableValue("special_ability_upgrades", "0");
    if (specialAbilities === undefined) {
        return;
    }
    // Only build the UI for the local hero, since their abilities are going to be different
    var nLocalPlayerHeroName = GetLocalHeroName();
    var specialAbilitiesData = specialAbilities //[nLocalPlayerHeroName];
    var nAbilityNumber = 1;
    for (nAbilityNumber; nAbilityNumber < Object.keys(specialAbilitiesData).length + 1; nAbilityNumber++)
    {
        //Build a panel for each of the abilities in the aghanim_ability_upgrade_constants list for the specified hero
        var AbilityName = specialAbilitiesData[nAbilityNumber];

        $.Msg(AbilityName);

        var szAbilityPanelName = nLocalPlayerHeroName + "Ability" + nAbilityNumber;
        var szAbilityPanelName = AbilityName;
        var AbilityPanel = SkillTreePanel.FindChildTraverse(szAbilityPanelName);
        var bLearned = true;
        if (AbilityPanel !== null)
        {
            // Create a snippet with the ability instance
            $.Msg("AbilityPanel", AbilityPanel);
            AbilityPanel.ToggleClass("Hidden");
            
        }

    }
    return;
}

function GetLocalHeroName() {
    var localPlayerId = 0;
    localPlayerId = Game.GetLocalPlayerID();
    return Players.GetPlayerSelectedHero(localPlayerId);
}

function OnAbilityButtonClicked( abilityName )
{
    //$.Msg("OnAbilitiesUpgradesReceived");
}


function AbilityButtonClicked( data )
{
    //$.Msg("AbilityButtonClicked");
    // Toggles the visual of the ability button when one learns it
    var szButtonAbilityPanelName = data["AbilityName"];
    var ButtonAbilityPanel = $.GetContextPanel().FindChildTraverse(szButtonAbilityPanelName);
    if (ButtonAbilityPanel !== null)
    {
        ButtonAbilityPanel.ToggleClass("Learned");
    }

}



function OnAbilitiesUpgradesReceived() {
    //$.Msg("OnAbilitiesUpgradesReceived");


    var specialAbilities = CustomNetTables.GetTableValue("special_ability_upgrades", "0");
    if (specialAbilities === undefined) {
        return;
    }
    // Only build the UI for the local hero, since their abilities are going to be different
    var nLocalPlayerHeroName = GetLocalHeroName();
    var specialAbilitiesData = specialAbilities //[nLocalPlayerHeroName];

    var AbilityContainerPanel = $("#AbilityContainer");
    if (nLocalPlayerHeroName !== undefined) {
        var specialAbilitiesData = specialAbilities //[nLocalPlayerHeroName];
        if (specialAbilitiesData === undefined) {
            return;
        }
        var nAbilityNumber = 1;
        for (nAbilityNumber; nAbilityNumber < Object.keys(specialAbilitiesData).length + 1; nAbilityNumber++)
        {
            //Build a panel for each of the abilities in the aghanim_ability_upgrade_constants list for the specified hero
            var AbilityName = specialAbilitiesData[nAbilityNumber];

            var szAbilityPanelName = nLocalPlayerHeroName + "Ability" + nAbilityNumber;
            var szAbilityPanelName = AbilityName;
            var AbilityPanel = SkillTreePanel.FindChildTraverse(szAbilityPanelName);
            var bLearned = true;
            if (AbilityPanel === null)
            {
                // Create a snippet with the ability instance
                AbilityPanel = $.CreatePanel("Panel", SkillTreePanel, szAbilityPanelName);
                AbilityPanel.BLoadLayoutSnippet("SkillInstanceSnippet");
                
            }
            var CurrentAbility = AbilityPanel.FindChildTraverse("Ability");
            CurrentAbility.abilityname = AbilityName;
            //Set the onActivate of the ability panel to upgrade the ability
            CurrentAbility.SetPanelEvent('onactivate', function ( strAbilityName ) { return function () {
                var data = [];
                data["PlayerID"] = Players.GetLocalPlayer();
                data["AbilityName"] = strAbilityName;
                data["AbilityNumber"] = nAbilityNumber;
                data["LevelReward"] = false
                GameEvents.SendCustomGameEventToServer("ability_upgrade_button_clicked", data);
            } }( AbilityName ) );
        }

    }

}