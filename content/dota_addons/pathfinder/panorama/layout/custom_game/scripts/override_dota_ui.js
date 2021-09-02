function OverrideDotaNeutralItemsShop() {
	const player_info = Game.GetPlayerInfo(Game.GetLocalPlayerID());
	if (player_info == undefined || player_info.player_selected_hero == "") {
		$.Schedule(0.5, OverrideDotaNeutralItemsShop);
		return;
	}

	var shop_grid_1 = $.GetContextPanel().GetParent().GetParent().GetParent().FindChildTraverse("GridNeutralsCategory");
	if (shop_grid_1) {
		shop_grid_1.style.overflow = "squish scroll";
		const items_lines = shop_grid_1.FindChildrenWithClassTraverse("TeamNeutralItemsTier");
		items_lines.forEach((line) => {
			const list = line.GetChild(1);
			list.style.flowChildren = "right-wrap";
		});
	}
}

(function () {
	OverrideDotaNeutralItemsShop();
})();
