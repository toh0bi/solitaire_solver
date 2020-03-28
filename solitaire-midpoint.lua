--[[
auxillary function
table.clone: alle werte mit pairs kopieren return {table.unpack(org)} funktioniert nicht, da kein array
]]
function table.clone(org)
 local out = {}
 for i,v in pairs(org) do out[i]=v end
 return out
end

--[[
auxillary function
print board pretty
]]
--insert positions in printable order
local printable_brd = {}
  for i=1,7 do table.insert(printable_brd,i+10) end
  for i=1,7 do table.insert(printable_brd,i+20) end
  for i=1,7 do table.insert(printable_brd,i+30) end
  for i=1,7 do table.insert(printable_brd,i+40) end
  for i=1,7 do table.insert(printable_brd,i+50) end
  for i=1,7 do table.insert(printable_brd,i+60) end
  for i=1,7 do table.insert(printable_brd,i+70) end
function print_brd(brd)
  local out = '-------\n'
  local row = 1
  for _,pos in ipairs(printable_brd) do
    if row < math.floor(pos/10) then out = out .. "\n" ; row=row+1 end
    if brd[pos] then out = out .. "o" else out = out .. " " end
  end
  out = out .. '\n-------'
  print(out)
end

--[[
auxillary function
How many pins are left
]]
function pins_left(brd)
  local sum = 0
  for _,__ in pairs(brd) do sum=sum+1 end
  return sum
end

--[[
move pin on board and return new board and pin pos
]]
function brd_pin_move_to(brd,pos,dir)
  local brd_new = table.clone(brd)
  if dir=='left' then
    brd_new[pos-2]= true
    brd_new[pos-1]= nil
    brd_new[pos]  = nil
    return brd_new , pos-2
  elseif dir=='right' then
    brd_new[pos+2]= true
    brd_new[pos+1]= nil
    brd_new[pos]  = nil
    return brd_new , pos+2
  elseif dir=='top' then
    brd_new[pos-20]= true
    brd_new[pos-10]= nil
    brd_new[pos]   = nil
    return brd_new , pos-20
  elseif dir=='bottom' then
    brd_new[pos+20]= true
    brd_new[pos+10]= nil
    brd_new[pos]   = nil
    return brd_new , pos+20
  else error("ERROR: dir not allowd: " .. dir) end
end

--[[
board definition
index der table: Zehner ist die Reihe & Einer die Spalte
Falls Wert gesetzt (=true) ist es eine gültige Spielposition, sonst (=nil) nicht
]]
brd_allwd = {
                     [13]=true,[14]=true,[15]=true
                    ,[23]=true,[24]=true,[25]=true
,[31]=true,[32]=true,[33]=true,[34]=true,[35]=true,[36]=true,[37]=true
,[41]=true,[42]=true,[43]=true,[44]=true,[45]=true,[46]=true,[47]=true
,[51]=true,[52]=true,[53]=true,[54]=true,[55]=true,[56]=true,[57]=true
                    ,[63]=true,[64]=true,[65]=true
                    ,[73]=true,[74]=true,[75]=true
}

--[[
function to rotate board by 90°
]]
function rot90(brd)
  local brd_turned = {
                   [13]=37,[14]=47,[15]=57
                  ,[23]=36,[24]=46,[25]=56
  ,[31]=15,[32]=25,[33]=35,[34]=45,[35]=55,[36]=65,[37]=75
  ,[41]=14,[42]=24,[43]=34,[44]=44,[45]=54,[46]=64,[47]=74
  ,[51]=13,[52]=23,[53]=33,[54]=43,[55]=53,[56]=63,[57]=73
                  ,[63]=32,[64]=42,[65]=52
                  ,[73]=31,[74]=41,[75]=51
  }
  local brd_out={}
  for pos,v in pairs(brd) do
    brd_out[brd_turned[pos]] = v
  end
  return brd_out
end

--[[
jede erlaubte position bekommt eine id (1 bis 33) to calculate specific board id
]]
pos_id = {}
local j = 1
for i,_ in pairs(brd_allwd) do
  pos_id[i]=j
  j=j+1
end

--[[
check if move in direction is possible
]]
function pin_move_is_possible(brd,pos,dir)
  if dir=='left' then
    return brd_allwd[pos-2] and brd[pos-2]==nil and brd[pos-1]
  elseif dir=='right' then
    return brd_allwd[pos+2] and brd[pos+2]==nil and brd[pos+1]
  elseif dir=='top' then
    return brd_allwd[pos-20] and brd[pos-20]==nil and brd[pos-10]
  elseif dir=='bottom' then
    return brd_allwd[pos+20] and brd[pos+20]==nil and brd[pos+10]
  else error("ERROR: dir not allowd: " .. dir) end
end

--[[
main function to recursive solve the board
]]
function solve(brd,pin,moves,recursive_move, brd_hist)
  if total_moves % 1000000 == 0 then
    print(string.format("DEBUG: in total: %1.1e moves made",total_moves),
          string.format("elapsed time: %.2f s", os.clock() - x))
    local i=0
    for _,__ in pairs(brd_id_hist) do i = i+1 end
    print("DEBUG: saved boards: ", i)
    print("DEBUG: skipped boards:", skipped)
    print("DEBUG: saved counter: ", saved)
  end
  total_moves = total_moves + 1

    --solution found?
  if pins_left(brd) == 1 and brd[44] then
      table.insert(solutions,{total_moves,moves,brd_hist})
      print("     !! solution found with # moves: " .. moves )
      print("     !! with # total_moves: " .. total_moves )
  end

  -- calculate specific board id for each board orientation
  local brd_id = 0 -- outside of loop to save later
  for o=1,4 do
    brd_id = 0 -- reset for new orientation
    for pos,_ in pairs(brd) do
      brd_id = brd_id + math.pow(2,pos_id[pos])
    end
    -- skip this board if already solved or solved with lower or equal moves
    if brd_id_hist[brd_id] and brd_id_hist[brd_id] < moves then
      skipped = skipped +1
      return 0
    end
    brd=rot90(brd)
  end

  --[[DEBUG
  print("================")
  print_brd(brd)
  print("pins_left: " , pins_left(brd))
  print("pin: " , pin)
  print("moves: " , moves)
  print("total_moves: ", total_moves)
  if total_moves > 5 then return 1 end
  print("================")
]]

  -- skip if moves are to high to be interesting
  if moves > 9 then return 0 end

  -- find a pin to move
  for pos in pairs(brd) do
    local moves_new = 0
    if pos ~= pin
      then moves_new = moves + 1
      else moves_new = moves
    end
    -- alle Richtungen ziehen
    if pin_move_is_possible(brd,pos,'left') then
      if recursive_move == false then print("INFO: first move to the left") end
      local brd_new, pos_new = brd_pin_move_to(brd,pos,'left')
      local brd_hist_new = table.clone(brd_hist)
      table.insert(brd_hist_new,{brd_new,pos,pos_new,moves_new})
      solve(brd_new,pos_new,moves_new,true,brd_hist_new)
    end
    if pin_move_is_possible(brd,pos,'right') then
      if recursive_move == false then print("INFO: first move to the right") end
      local brd_new, pos_new = brd_pin_move_to(brd,pos,'right')
      local brd_hist_new = table.clone(brd_hist)
      table.insert(brd_hist_new,{brd_new,pos,pos_new,moves_new})
      solve(brd_new,pos_new,moves_new,true,brd_hist_new)
    end
    if pin_move_is_possible(brd,pos,'top') then
      if recursive_move == false then print("INFO: first move to the top") end
      local brd_new, pos_new = brd_pin_move_to(brd,pos,'top')
      local brd_hist_new = table.clone(brd_hist)
      table.insert(brd_hist_new,{brd_new,pos,pos_new,moves_new})
      solve(brd_new,pos_new,moves_new,true,brd_hist_new)
    end
    if pin_move_is_possible(brd,pos,'bottom') then
      if recursive_move == false then print("INFO: first move to the bottom") end
      local brd_new, pos_new = brd_pin_move_to(brd,pos,'bottom')
      local brd_hist_new = table.clone(brd_hist)
      table.insert(brd_hist_new,{brd_new,pos,pos_new,moves_new})
      solve(brd_new,pos_new,moves_new,true,brd_hist_new)
    end --if

  end --for
  --save board
  brd_id_hist[brd_id] = moves
  saved=saved+1
  return 0
end --solve


-- starting board
brd_start     = table.clone(brd_allwd)
brd_start[44] = nil --> Mitte entnehmen
--global value that stores all brd IDs
brd_id_hist = {}
--global value to store solutions
solutions={}
--counter of total solve executions
total_moves = 0
skipped = 0
saved = 0
-- start time
x = os.clock()
print("\nSTART solving", os.date("%c") )

solve(brd_start,44,0,false,{})

for n,k in pairs(solutions) do
  print("solution " .. n .. " with " .. solutions[2] .. " moves:")
  for i,v in ipairs(solutions[3]) do
    print("board constellation in total move " .. i .. " with pin " .. v[2] .. " to " .. v[3] .. " move: " .. v[4])
    print_brd(v[1])
  end
end
