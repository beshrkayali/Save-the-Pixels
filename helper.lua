-- split a string using an identifier
function splitter(inputstr, sep)
  if sep == nil then
          sep = "%s"
  end
  t={} ; i=1
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
          t[i] = str
          i = i + 1
  end
  return t
end


-- remove a key in a table
function table.removekey(table, key)
  local element = table[key]
  table[key] = nil
  return element
end


-- count keys in a table
function table.countkeys(table)
  i = 0
  for k,v in pairs(table) do
    i = i+1
  end
  return i
end


-- fade color function
function fadeColor(dt, from_o, to_o)
  if from_o > to_o then

  else

  end
end