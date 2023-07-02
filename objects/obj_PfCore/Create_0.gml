left = 0;
top = 0;
cellwidth = 16;
cellheight = 16;
hcells = ceil(room_width / cellwidth);
vcells = ceil(room_height / cellheight);

grid = mp_grid_create(left, top, hcells, vcells, cellwidth, cellheight);

alarm_set(0, 1);
