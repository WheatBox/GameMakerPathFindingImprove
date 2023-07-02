if(mouse_check_button_pressed(mb_left) && mouse_x > room_width / 2) {
	if(mp_grid_path(obj_PfCore.grid, myPath, x, y, mouse_x, mouse_y, true)) {
		path_start(myPath, moveSpeed, path_action_stop, false);
	}
	
	with(obj_Player) {
		if(PfPathFind(pfPath, x, y, mouse_x - room_width / 2, mouse_y)) {
			PfPathStart(pfPath, moveSpeed);
		}
	}
}
