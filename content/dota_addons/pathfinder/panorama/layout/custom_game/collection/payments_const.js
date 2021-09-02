const PAYMENT_VALUES = {
	base_booster: {
		price: "3.99",
	},
	// boost_level_2: {
	// 	price: "5.99",
	// },
	// boost_level_3: {
	// 	price: "7.99",
	// },
	golden_booster: {
		price: "19.99",
	},
};

const EXCHANGE_RATE = {
	//By one dollar
	schinese: 7,
};

function GetLocalPrice(basePrice) {
	if (EXCHANGE_RATE[$.Language()]) basePrice = Math.round(basePrice * EXCHANGE_RATE[$.Language()] * 100) / 100;
	return basePrice;
}
