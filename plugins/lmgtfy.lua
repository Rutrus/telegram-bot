do

function run(msg, matches)
    local query = URL.escape(matches[1])
    query = string.gsub(query, '%%20', '+')
    return "http://lmgtfy.com/?q=" .. query
end

return {
  description = "LMGTFY",
  usage = "!lmgtfy Let me google that for you.",
  patterns = {
    "^!lmgtfy (.*)$"
  },
  run = run
}

end
