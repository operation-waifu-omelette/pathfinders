function OpenFeedback() {
	const feedbackMenu = FindDotaHudElement("FeedbackHeaderRoot").GetParent();
	feedbackMenu.ToggleClass("show");
	Game.EmitSound("ui_chat_slide_in");
}
function OpenInventory() {
	boostGlow = false;
	ToggleMenu("CollectionDotaU");
}
function OpenSyncedChat() {
	GameEvents.SendEventClientSide("synced_chat:toggle", {});
}

const AUTO_HINT_TIME_STEP = 7;
const AUTO_HINTS_DATA = {
	TopMenuIcon_Inventory: "TopMenuIcon_Inventory_message",
	TopMenuIcon_Feedback: "feedback_top_menu_hint",
};
function StartTipsHint() {
	Object.entries(AUTO_HINTS_DATA).forEach(([panel_name, desc], index) => {
		const index_step = index + 1;
		const is_last_step = index_step == Object.keys(AUTO_HINTS_DATA).length;
		$.Schedule(index_step * AUTO_HINT_TIME_STEP, function () {
			TipsOver(desc, panel_name);
			if (is_last_step)
				$.Schedule(AUTO_HINT_TIME_STEP, function () {
					TipsOut();
				});
		});
	});
}
function TipsOver(message, pos) {
	const root = $(`#${pos}`);
	if (root) {
		$.DispatchEvent("DOTAShowTextTooltip", $("#" + pos), $.Localize(message));

		if (root.BHasClass("Unfocussed")) {
			root.RemoveClass("Unfocussed");
		}
		if (root.BHasClass("Ping")) {
			root.RemoveClass("Ping");
		}
	}
}

function TipsOut() {
	$.DispatchEvent("DOTAHideTitleTextTooltip");
	$.DispatchEvent("DOTAHideTextTooltip");
}

(function () {
	GameEvents.Subscribe("StartTipsHint", StartTipsHint);
	const top_panel = $("#TopMenuPanel");
	const updateDotaTopButton = function (id, name) {
		const button = FindDotaHudElement(id);
		button.style.margin = "0px 0px 0px 0px";
		button.style.width = "48px";
		button.style.height = "48px";
		button.style.opacity = 1;
		button.style.washColor = "transparent";
		button.style.backgroundImage = "url('')";
		button.style.transform = "scaleY(1)";
		button.RemoveAndDeleteChildren();
		const image = $.CreatePanel("Panel", top_panel, `${name}Color`);
		image.AddClass("TopMenuButtonColor");
		image.SetParent(button);

		const shadow = $.CreatePanel("Panel", top_panel, `${name}Shadow`);
		shadow.AddClass("TopMenuButtonShadow");
		shadow.SetParent(button);
		shadow.hittest = false;
	};

	updateDotaTopButton("DashboardButton", "ShrinkGame");
	updateDotaTopButton("SettingsButton", "GameSettings");
	FindDotaHudElement("MenuButtons").style.marginTop = "3px";
})();
