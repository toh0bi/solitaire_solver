--[[
global parameters
]]
total_moves = 0

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
print board pretty,
insert positions in printable order
]]
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
auxillary function
convert pin position i,j to pos (as difined in brd_allwd)
]]
function pin_to_pos(i,j)
  return 10*i+j
end
function pos_to_pin(pos)
  return math.floor(pos/10) , pos % 10
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
starting board
]]
brd_start     = table.clone(brd_allwd)
brd_start[44] = nil --> Mitte entnehmen

--[[
main function to recursive solve the board
]]
function solve(brd,pin,moves,recursive_move)
  if total_moves % 1000000 == 0 then io.write(string.format("DEBUG: in total %d moves made\n",total_moves))
  end
  total_moves = total_moves + 1
  --solution found?
  if pins_left(brd) == 1 then print("solution found!")
  end
  -- TODO check if board alredy was solved

  -- find a pin to move
  for pos in pairs(brd) do
    if pos ~= pin -- gleicher pin wie vorheriger Zug wird nicht gezählt
     then moves = moves + 1
    end
    -- alle Richtungen ziehen
    if pin_move_is_possible(brd,pos,'left') then
      local brd_new, pos_new = brd_pin_move_to(brd,pos,'left')
      solve(brd_new,pos_new,moves,true)
    end
    if pin_move_is_possible(brd,pos,'right') then
      local brd_new, pos_new = brd_pin_move_to(brd,pos,'right')
      solve(brd_new,pos_new,moves,true)
    end
    if pin_move_is_possible(brd,pos,'top') then
      local brd_new, pos_new = brd_pin_move_to(brd,pos,'top')
      solve(brd_new,pos_new,moves,true)
    end
    if pin_move_is_possible(brd,pos,'bottom') then
      local brd_new, pos_new = brd_pin_move_to(brd,pos,'bottom')
      solve(brd_new,pos_new,moves,true)
    end
  end
  -- TODO save board
end


print("START solving")
solve(brd_start,nil,0,false)
