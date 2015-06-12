--~ Reduces echoes to 1 loop flood

local function run(msg, matches)
  local text = matches[1]
  local b = 1
  if text:starts("!echo ") then
    text = string.gsub(text, "!echo", "")
  end

  while b ~= 0 do
    text = text:trim()
    text,b = text:gsub('^!+','')
  end
  return text
end

return {
  description = "Makes the bot say something",
  usage = "!echo [whatever]: Tells the bot what to say",
  patterns = {
    "^!echo +(.+)$"
  },
  run = run
}
