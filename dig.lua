t=turtle
n_ignore=4
function s_dig(f_dig)
	while f_dig() do
	end
end
function cmp(cmpr)
	flag=true;
	for i = 1, n_ignore do
		t.select(i)
		if cmpr() then
			flag=false
			break
		end
	end
	return flag
end
function gao(dir)
	if dir=='up' then
		dig=t.digUp
		cmpr=t.compareUp
	elseif dir=='down' then
		dig=t.digDown
		cmpr=t.compareDown
	else
		dig=t.dig
		cmpr=t.compare
	end
	if cmp(cmpr) then
		s_dig(dig)
	end
end
function go_ahead(n, dir)
	while n>0 do
		s_dig(t.dig)
		while not t.forward() do
		end
		t.turnLeft()
		gao('')
		t.turnRight()
		gao(dir)
		t.turnRight()
		gao('')
		t.turnLeft()
		n = n - 1
	end
end
for i = 1, 10 do
	go_ahead(32, 'down')
	gao('')
	s_dig(t.digUp)
	t.up()
	gao('')
	t.turnLeft()
	gao('')
	t.turnLeft()
	gao('up')
	t.turnLeft()
	gao('')
	t.turnRight()
	
	go_ahead(32, 'up')
	t.down()
	t.turnLeft()
	for j = 1, 3 do
		s_dig(t.dig)
		while not t.forward() do
		end
	end
	t.turnLeft()
end
