function _CreatePurchaseAccess(name, image_path, header_key, desc_key, price) {
	$("#PatreonPaymentButton").visible = name.match("_booster") != null;
	$("#PurchasingHeader").text = $.Localize("#" + header_key);
	$("#PurchasingDescription").text = $.Localize("#" + desc_key);

	let price_value = 0;
	let newPayment = name;

	if (PAYMENT_VALUES[name]) {
		if (PAYMENT_VALUES[name].price) price_value = PAYMENT_VALUES[name].price;
	}

	paymentKind = newPayment;
	if (price) price_value = price;
	$("#Price").SetDialogVariable("price", GetLocalPrice(price_value));
	$("#Price").SetDialogVariable("paySymbol", $.Localize("#paySymbol"));
	$("#PurchasingIcon").SetImage(image_path);

	SetPaymentVisible(true);
}

function SetPaymentVisible(state) {
	$("#CollectionPayment").SetHasClass("show", state);
}

function BuyBoost(type) {
	_CreatePurchaseAccess(
		type,
		"file://{resources}/images/custom_game/payment/payment_boost.png",
		type + "_purchase_header",
		type + "_purchase_description",
	);
}
