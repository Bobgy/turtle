tArg = {...}

function gen_dig()
  local safe = function(dig)
    return function()
			t.select(1)
			return dig()
    end
  end
  for i = -1, 1 do
    dig[i] = safe(dig[i])
  end
end

function gen_safe_move()
  move_s = {}
  local safe = function(move, dig, atk)
    return function()
			local cnt = 0
      while not move() do
        dig()
        atk()
				cnt = cnt + 1
				if cnt > 10 then
					return false
				end
      end
      step = step + 1
      if step % 32 == 0 then
        self_check()
      end
			return true
    end
  end
  for i = -1, 1 do
    move_s[i] = safe(move[i], dig[i], atk[i])
  end
  move_s[2] = function()
    if not move[2]() then
      turn[0]()
      if not move_s[0]() then return false end
      turn[0]()
    end
    return true
  end
end

function init_move()
  facing = 0
  dx = { 0, 0,-1, 1}
  dy = {-1, 1, 0, 0}
  dig = {[0]=t.dig,[1]=t.digUp,[-1]=t.digDown}
	gen_dig()
  turn = {[-1]=t.turnRight,[1]=t.turnLeft}
  turn[0] = function()
    turn[1]()
    turn[1]()
  end
  comp = {[0]=t.compare,[1]=t.compareUp,
          [-1]=t.compareDown,[2]=t.compareTo}
  drop = {[0]=t.drop,[1]=t.dropUp,[-1]=t.dropDown}
  suck = {[0]=t.suck,[1]=t.suckUp(),[-1]=t.suckDown}
  detect = {[0]=t.detect,[1]=t.detectUp,[-1]=t.detectDown}
  atk = {[0]=t.attack,[1]=t.attackUp,[-1]=t.attackDown}
  place = {[0]=t.place,[1]=t.placeUp,[-1]=t.placeDown}
  move = {[0]=t.forward,[1]=t.up,[-1]=t.down,[2]=t.back}
  gen_safe_move(move)
end

--return success
function init_config(file_name)
  local f = fs.open(file_name, "r")
  if f == nil then
    print("Cannot open config file " .. file_name)
    return false
  end
  n_ignore = f.readLine() + 0
  f.close()
  return true
end

--return success
function init()
  t = turtle
  step = 0
  local success = init_config("lib.config")
  if not success then
    print("Initialization failed!")
    return false
  end
  init_move()
  return true
end

--return nil=not enought fuel, true=refueled, false=no need
function refuel()
  local fuel = t.getFuelLevel()
  if fuel > 200 then return nil end
  t.select(n_ignore+1)
  local cnt = t.getItemCount()
  if cnt <= 1 then return false end
  t.refuel(cnt - 1)
  return true
end

function sort()
  -- [1, n_ignore]: ignored
  -- [n_ignore+1]: coal
  for i = n_ignore+2, 16 do
    for j = 1, i-1 do
      t.select(i)
      if t.transferTo(j) then
        local cnt = t.getItemCount()
        if cnt == 0 then break end
      end
    end
  end
end

-- return isOK
function self_check()
  local cnt
	local slots_with_item = 0
  for i = 1, 16 do
    t.select(i)
    cnt = t.getItemCount()
    if cnt and cnt > 0 then
      slots_with_item = slots_with_item + 1
    end
  end
  if slots_with_item > 14 then
    for i = 1, n_ignore do
      t.select(i)
      cnt = t.getItemCount()
      if cnt>=16 then
        t.drop(cnt-16)
      end
    end
    sort()
  end
  if refuel() == false then
    -- lack of energy
    go_home = true
    return false
  end
  return true
end

-- k: direction [-1, 0, 1]
function valuable(k)
  if not detect[k]() then return false end
  for i = 1, n_ignore do
    t.select(i)
    if comp[k]() then return false end
  end
  return true
end

function dfs_dig()
  if go_home then return nil end
  for i = -1, 1 do
    if valuable(i) and move_s[i]() then
      dfs_dig()
      if i == 0 then
        move_s[2]()
      else
        move_s[-i]()
      end
    end
  end
  for i = 1, 3 do
    turn[1]()
    if valuable(0) and move_s[0]() then
      dfs_dig()
      move_s[2]()
    end
  end
  turn[1]()
end

function dig_forward(n)
  while n > 0 do
    for i = -1, 1 do
      if valuable(i) then
        dfs_dig()
        break
      end
    end
    move_s[0]()
    n = n - 1
  end
end

-- k = [-1, 0, 1]
function dig_all(k, n)
	local dep = 0
  while dep < n do
    if not move_s[k]() then
			break
		end
    dfs_dig()
		dep = dep + 1
  end
	return dep
end

function go(k, n)
	local cnt
  while n > 0 do
    if not move_s[k]() then
			return false
		end
		t.select(1)
		cnt = t.getItemCount()
		if n < cnt then
			place[-k]()
		end
    n = n - 1
  end
	return true
end

function dig_a_hole(n)
  local depth = dig_all(-1, n)
  go(1, depth)
end

--k: direction[-1, 0, 1]
function dump_to_container(k)
  if not detect[k] then
    return false
  end
  local cnt
  for i = 1, n_ignore do
    t.select(i)
    cnt = t.getItemCount()
    if not drop[k](cnt-1) then return false end
  end
  return true
end

init()