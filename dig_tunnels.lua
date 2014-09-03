tArg={...}
t=turtle
# wrap f_dig to makesure gravels will be digged
function s_dig(f_dig)
	t.select(1)
	while f_dig() do
	end
end
function go_ahead(n)
	while n>0 do
		s_dig(t.dig)
		while not t.forward() do
			t.dig()
		end
		n = n - 1
	end
end
for i = 1, 20 do
	go_ahead(32)
	s_dig(t.digUp)
	t.up()
	t.turnLeft()
	t.turnLeft()
	s_dig(t.dig)
	go_ahead(32)
	t.down()
	t.turnLeft()
	for j = 1, 3 do
		s_dig(t.dig)
		while not t.forward() do
			t.dig()
		end
	end
	t.turnLeft()
end
