			
function random_in_array(array) {
    if (array.length== 0) return;
	  	return array[Math.floor(Math.random() * array.length)];
}

//"s2r://panorama/images/loadingscreens/fall_major_2016_loadscreen_1/loadingscreen.vtex",
const art = [	
				"s2r://panorama/images/econ/loading_screens/envisioning_wraith_king_loading_screen_png.vtex", 
				"s2r://panorama/images/econ/loading_screens/envisioning_weaver_loading_screen_png.vtex",
				"s2r://panorama/images/econ/loading_screens/envisioning_witch_doctor_loading_screen_png.vtex",
				"s2r://panorama/images/econ/loading_screens/envisioning_winter_wyvern_loading_screen_png.vtex",
				"s2r://panorama/images/econ/loading_screens/envisioning_queen_of_pain_loading_screen_png.vtex",];
		
$("#SplashArt").style.backgroundImage = random_in_array(art);		
