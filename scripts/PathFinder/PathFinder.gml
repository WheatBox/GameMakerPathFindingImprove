function PfPathCreate() {
	return path_add();
}

function PfPathFind(path, sx, sy, dx, dy, hitboxWidth = bbox_right - bbox_left, hitboxHeight = bbox_bottom - bbox_top) {
	static _PfPathFind_CollisionLine = function(_x1, _y1, _x2, _y2, _xadd, _yadd) {
		return collision_line(_x1 + _xadd, _y1 + _yadd, _x2 + _xadd, _y2 + _yadd, obj_PfWall, false, false) != noone
			|| collision_line(_x1 + _xadd, _y1 - _yadd, _x2 + _xadd, _y2 - _yadd, obj_PfWall, false, false) != noone
			|| collision_line(_x1 - _xadd, _y1 + _yadd, _x2 - _xadd, _y2 + _yadd, obj_PfWall, false, false) != noone
			|| collision_line(_x1 - _xadd, _y1 - _yadd, _x2 - _xadd, _y2 - _yadd, obj_PfWall, false, false) != noone;
	}
	
	if(!instance_exists(obj_PfCore)) {
		return false;
	}
	
	var collxadd = floor((hitboxWidth - 1) / 2);
	var collyadd = floor((hitboxHeight - 1) / 2);
	
	
	/* 调整目标点位置（各项具体参数根据实际所需情况调整） */
	
	var startdir = point_direction(dx, dy, sx, sy);
	var dirsteps = 16;
	var dirstepdir = 360 / dirsteps;
	
	dirsteps = ceil(dirsteps / 2);
	
	var steps = 64;
	var stepdis = 1;
	for(var i = 0; i < steps; i++) { // 设定一定的最大次数，防止死循环
		var distance = i * stepdis;
		
		for(var j = 0; j < dirsteps; j++) {
			for(var dirsign = (j > 0); dirsign >= -1; dirsign -= 2) {
				
				var xcheck = dx + lengthdir_x(distance, startdir + j * dirstepdir * dirsign);
				var ycheck = dy + lengthdir_y(distance, startdir + j * dirstepdir * dirsign);
				
				if(collision_rectangle(xcheck - collxadd - 1, ycheck - collyadd - 1, xcheck + collxadd + 1, ycheck + collyadd + 1, obj_PfWall, false, false) == noone
					&& mp_grid_get_cell(obj_PfCore.grid, xcheck / obj_PfCore.cellwidth, ycheck / obj_PfCore.cellheight) != -1
				) {
					dx = xcheck;
					dy = ycheck;
					
					i = steps;
					j = dirsteps;
					
					break;
				}
			}
		}
	}
	
	
	/* 寻路 */
	
	var res = mp_grid_path(obj_PfCore.grid, path, sx, sy, dx, dy, true);
	if(res == false) {
		return res;
	}
	
	
	/* 删去多余的路径点 */
	
	var len = path_get_number(path);
	for(var i = 0; i < len - 2; i++) {
		var xtemp1 = path_get_point_x(path, i);
		var ytemp1 = path_get_point_y(path, i);
		for(var j = i + 2; j < len; j++) {
			var xtemp2 = path_get_point_x(path, j);
			var ytemp2 = path_get_point_y(path, j);
			
			if(_PfPathFind_CollisionLine(xtemp1, ytemp1, xtemp2, ytemp2, collxadd, collyadd) == false) {
				while(j > i + 1) {
					j--;
					len--;
					path_delete_point(path, j);
				}
			}
		}
	}
	
	
	/* 对最后可能出现的拐角进行特殊处理（各项具体参数根据实际所需情况调整） */
	// 其实这一段主要是为了一点点小细节，但是会进行许多次的碰撞检测
	// 所以如果觉得运算量有点多可以删掉这一段
	
	if(len >= 3) {
		var last2x = path_get_point_x(path, len - 2);
		var last2y = path_get_point_y(path, len - 2);
		var last3x = path_get_point_x(path, len - 3);
		var last3y = path_get_point_y(path, len - 3);
		
		var last23dir = point_direction(last2x, last2y, last3x, last3y);
		
		var insertsteps = 20;
		var insertstepadd = max(1, point_distance(last2x, last2y, last3x, last3y) / insertsteps);
		
		var insertstepxadd = lengthdir_x(insertstepadd, last23dir);
		var insertstepyadd = lengthdir_y(insertstepadd, last23dir);
		
		var xinsert = last2x;
		var yinsert = last2y;
		for(var i = 1; i < insertsteps; i++) {
			xinsert += insertstepxadd;
			yinsert += insertstepyadd;
			
			if(_PfPathFind_CollisionLine(xinsert, yinsert, dx, dy, collxadd, collyadd)) {
				if(i != 1) {
					path_delete_point(path, len - 2);
					path_insert_point(path, len - 2, xinsert - insertstepxadd, yinsert - insertstepyadd, 100);
				}
				
				break;
			}
		}
	}
	
	
	/* 返回 */
	
	return res;
}

function PfPathStart(path, _speed, endaction = path_action_stop, absolute = false) {
	path_start(path, _speed, endaction, absolute);
}
