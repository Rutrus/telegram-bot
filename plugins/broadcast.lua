MSGS = 5
STOP = 1.0

local function is_channel_disabled( receiver )
    if not _config.disabled_channels then
        return false
    end
    if _config.disabled_channels[receiver] == nil then
        return false
    end
  return _config.disabled_channels[receiver]
end

local function async(params)
    local i = 0
    while i<MSGS do
        n = #params.receivers
        if n ~= 0 then
            if not is_channel_disabled(params.receivers[n]) then
                -- Comment next line for debug:
                send_large_msg(params.receivers[n],params.text)
                print(n.."Message sended to "..params.receivers[n])
            else print(n.."Channel disabled: "..params.receivers[n])
            end
            table.remove(params.receivers, n)
            i = i+1
        else break
        end
    end
    print('stop '..STOP..' second(s)')
    if #params.receivers ~= 0 then
        return postpone(async,{receivers=params.receivers,text=params.text},STOP)
    else return
    end
end

local function send_generic(keybase, keymatch, receiverbase , text)
    local keys = redis:keys(keybase)
    local already = {}
    local receivers = {}
    if n == nil then
        n = 0
    end
    for k,key in pairs(keys) do
        local id = tonumber(string.match(key, keymatch))
        table.insert(receivers, receiverbase .. id)
    end
    return receivers
end

local function send_chats(text)
    print("Sending broadcast to chats")
    return send_generic("chat:*:users", "chat:(%d+).*", "chat#id", text, n)
end

local function send_users(text)
    print("Sending broadcast to users")
    return send_generic("msgs:*:" .. our_id, "msgs:(%d+).*", "user#id", text, n)
end

local function run(msg, matches)
    local text = ""
    local receivers = {}
    local chats = {}
    local nusers = 0
    local nchats = 0

    if #matches == 1 then
        text = matches[1]
        receivers = send_users(text)
    elseif #matches == 2 then
        text = matches[2]
    end

    chats = send_chats(text)
    nusers = #receivers
    nchats = #chats

print(#matches)
    for i=1,#chats do
        receivers[#receivers+1] = chats[i]
    end
    --~ vardump(receivers)
    print( "Your message was sended to " .. nchats .. " chats and " .. nusers .. " users.")
    async({receivers=receivers,text=text})
    return "Your message was sended to " .. nchats .. " chats and " .. nusers .. " users."
end

return {
    description = "Send a broadcast message to all chats and users.",
    usage = {
          "!broadcast (message): Send the message to all chats and users."
        .."!broadcast (groups) (message): Send the message to group chats"
    },
    patterns = {
        "^!broadcast (groups?) (.*)",
        "^!broadcast (.*)"
    },
    privileged = true,
    run = run
}
