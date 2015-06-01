local clock = os.clock

function sleep(n)  -- seconds
  local t0 = clock()
  while clock() - t0 <= n do end
end

local function async(msg)
   send_msg(msg.receiver, msg.text, ok_cb, false)
   --~ print("send_msg("..msg.receiver..", "..msg.text..", ok_cb, false)")
end

local function send_generic(keybase, keymatch, receiverbase , text)
   local keys = redis:keys(keybase)
   local already = {}
   if n == nil then
      n = 0
   end
   for k,key in pairs(keys) do
      if n > 990 then
         return n
      end
      local id = tonumber(string.match(key, keymatch))
      local receiver = receiverbase .. id
      if not already[id] and id ~= our_id then
         n = n + 1
         -- print("\t" .. receiver)
         local msg = {receiver=receiver, text=text}
         postpone (async(msg),false, 1)
         --~ if n % 5 == 0 then sleep(1) end
         -- send_msg(receiver, text, ok_cb, false)
         already[id] = true
      end
   end
   return n
end

local function send_chats(text)
   print("Sending broadcast to chats")
   return send_generic("chat:*:users", "chat:(%d+).*", "chat#id", text, n)
end

local function send_users(text)
   print("Sending broadcast to users")
   return send_generic("msgs:*:" .. our_id, "msgs:(%d+).*", "user#id", text, n)
end

-- local function get_n()
--    local n1 = redis:keys("chat:*:users")
--    local n2 = redis:keys("msgs:*:" .. our_id)
--    return #n1, #n2
-- end

local function run(msg, matches)
   local text = matches[1]
   local nchats = send_chats(text)
   local nusers = send_users(text, nchats)
   -- postpone (send_chats, text, 1)
   -- postpone (send_users, text, 1)
   -- nchats, nusers = get_n()
   return "Your message had been sended to " .. nchats .. " chats and " .. nusers .. " users."
end

return {
   description = "Send a broadcast message to all chats and users.",
   usage = {
      ".!broadcast (message): Send the message to all chats and users."
   },
   patterns = {
      "^!broadcast (.*)$"
   },
   privileged = true,
   run = run
}
