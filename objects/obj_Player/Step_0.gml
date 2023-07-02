if(mouse_check_button_pressed(mb_left) && mouse_x < room_width / 2) {
	if(PfPathFind(pfPath, x, y, mouse_x, mouse_y)) {
		PfPathStart(pfPath, moveSpeed);
	}
	
	with(obj_Player2) {
		if(mp_grid_path(obj_PfCore.grid, myPath, x, y, mouse_x + room_width / 2, mouse_y, true)) {
			path_start(myPath, moveSpeed, path_action_stop, false);
		}
	}
}
