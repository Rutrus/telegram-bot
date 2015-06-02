do

function where_is_ip(domain)
        local res,code  = http.request("http://freegeoip.net/json/" .. domain)
        if code > 200 then return "HTTP ERROR "..code end
        local data = json:decode(res)
        local location = data.country_code .. ":" .. data.country_name .. " - " .. data.city
        if data.region_name ~= "" then
            location = location .. " (" .. data.region_name .. ")"
        end
        message = data.ip .. " -> " .. location
        return message
    end
end

function run(msg,matches)
    local receiver = get_receiver(msg)
    if matches[1] == "!whereisip" or matches[1] == "!ip" then
        return "How to use:\n" .. matches[1] .. " nasa.gov"
    else  --~ matches[1] should be IP or domain
        return where_is_ip(matches[1])
    end
end

return {
  description = "Send the origin of an IP or domain.cøm",
  usage = {"!ip (ip): Send the origin of an IP.\n!ip (domain.com) Looks for his IP origin.\nYou can find your ip in: http://lorenzomoreno.es/myip "},
  patterns = {
    "^!whereisip$",
    "^!ip$",
    "^!whereisip ([%w.:]*)",
    "^!ip ([%w.:]*)$"
  },
  run = run
}
