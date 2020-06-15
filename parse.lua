-- these are globals in PICO-8
-- (don't need these lines there)
local sub = sub or string.sub
local tonum = tonum or tonumber

function table_from_string(str)
  local tab, is_key = {}, true
  local key,val,is_on_key
  local function reset()
    key,val,is_on_key = '','',true
  end
  local function parse(key)
    return tonum(key) or key
  end
  reset()
  local i, len = 1, #str
  while i <= len do
    local char = sub(str, i, i)
    -- token separator
    if char == '\31' then
      if is_on_key then
        is_on_key = false
      -- we check for boolean value
      elseif val=='\6' or val=='\21' then
        tab[parse(key)] = (val=='\6')
        reset()
      else
        -- we parse val into a numeric or a string
        tab[parse(key)] = parse(val)
        reset()
      end
    -- subtable start
    elseif char == '\29' then
      local j,c,l = i,'',0
      -- checking for subtable end character at the same level 
      -- of the subtable start character
      while (c ~= '\30' or l ~= 0) do
        if c == '\29' then l += 1
        elseif c == '\30' then l -= 1 end
        j = j + 1
        c = sub(str, j, j)
      end
      tab[parse(key)] = table_from_string(sub(str,i+1,j-1))
      reset()
      i = j
    else
      if is_on_key then
        key = key..char
      else
        val = val..char
      end
    end
    i = i + 1
  end
  return tab
end

-- module export - don't
-- include this in PICO-8
return {
  table_from_string=table_from_string
}
