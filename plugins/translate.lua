
--[[
-- Translate text using Yandex.com
-- https://translate.yandex.net/api/v1.5/tr.json/detect?key=APIkey&text=Hello+world
--~ https://translate.yandex.net/api/v1.5/tr/translate?key=APIkey&lang=en-ru&text=To+be,+or+not+to+be%3F&text=That+is+the+question.
--]]
do

function translate(source_lang, target_lang, text, api_key)
--~ print(text)
  local path = "https://translate.yandex.net/api/v1.5/tr.json/translate"
  if not api_key then
    local config = load_from_file('data/config.lua')
    for _,sudo in pairs(config.sudo_users) do
        send_msg("user#id"..sudo, "Valid API key is not provided in data/translate_api.lua\nGet an API key from https://tech.yandex.com/keys/get/?service=trnsl", ok_cb, false)
    end
    return "Valid API key is not provided, contact owner. Owner noticed."
  end
  target_lang = target_lang or 'en'
  -- URL query parameters
  local params = {
    lang = source_lang.."-"..target_lang,
    text = URL.escape(text),
  }
  local query = format_http_params(params, true)
  local url = path..query.."&key="..api_key
  local res, code = https.request(url)
  -- Return nil if error
  if code > 200 then
    message = "HTTP error code "..code
    print(message)
    return message
  end

  local trans = json:decode(res)

  local sentences = ""
  -- Join multiple sentences
  --~ for k,sentence in pairs(trans.sentences) do
  --~ vardump(inpairs(trans))
  for i=1,#trans.text do
    sentences = sentences..trans.text[i]..'\n'
  end

  return sentences
end

    --~ Auto detect language
function detect_language (text, target, api_key)
  target = target or 'en'
  local url = "https://translate.yandex.net/api/v1.5/tr.json/detect?text="..URL.escape(text)
  if not api_key then
    return "Valid API key is not provided in data/translate_api.lua"
  end
  url = url.."&key="..api_key

  local res, code = https.request(url)
  local trans = json:decode(res)
  if code == 200 and trans.code == 200 then
    return translate(trans.lang,target,text,api_key)
  else
    print( "ERROR: return code"..code..":"..trans.code)
    return nil
  end
end

function run(msg, matches)
  api = load_from_file('data/translate_api.lua')
  local api_key = false
  if api then
    api_key = api[math.random(#api)]
  end

  local lang_codes = { "sq", "ar", "hy", "az", "be", "bs", "bg", "ca", "hr",
    "cs", "zh", "da", "nl", "en", "et", "fi", "fr", "ka", "de", "el", "he",
    "hu", "is", "id", "it", "ja", "ko", "lv", "lt", "mk", "ms", "mt", "no",
    "pl", "pt", "ro", "ru", "es", "sr", "sk", "sl", "sv", "th", "tr", "uk","vi"}
  --~ You can get an api from https://tech.yandex.com/keys/get/?service=trnsl
  if api_key then
      -- Third pattern
      if #matches == 1 then
        print("First: Only text")
        local text = matches[1]
        return detect_language(text, false, api_key)
      end

      -- Second pattern
      if #matches == 2 then
      print("Second pattern")
        if string.len(matches[1]) == 2 and matches[1] == string.lower(matches[1]) then
          for _,lang in pairs(lang_codes) do
            if matches[1] == lang then
              print("User set target language code: "..lang)
              local text = matches[2]
              return detect_language(text, lang, api_key)
            end
          end
        end
        local text = matches[1]..matches[2]
        print("User does not set correct source neither target language. Detecting source language.")
        return detect_language(text, false, api_key)
      end
      -- First pattern
      if #matches == 3 then
        print("Third")
        local text = matches[3]
        local source = false
        local target = false

        for _,lang in pairs(lang_codes) do
          if matches[1] == lang then
            source = lang
          elseif matches[2] == lang then
            target = lang
          end

          if target and source then
            return translate(source, target, text, api_key)
          end
        end
        text = matches[1]..", "..matches[2].." "..matches[3]
        return detect_language(text, false, api_key)
      end
    end
end

return {
  description = "Translate some text.",
  usage = {
    "!translate text. Translate the text to English.",
    "!translate target_lang text.",
    "!translate source,target text",
    "\n languages supported: sq, ar, hy, az, be, "
        .."bs, bg, ca, hr, cs, zh, da, nl, en, et, fi, fr, ka, de, el, he, hu, "
        .."is, id, it, ja, ko, lv, lt, mk, ms, mt, no, pl, pt, ro, ru, es, sr, "
        .."sk, sl, sv, th, tr, uk, vi"
  },
  patterns = {
    "^!translate ([%w]+),([%a]+) (.+)",
    "^!translate ([%w]+) (.+)",
    "^!translate (.+)",
  },
  run = run
}

end

--[[
Albanian  sq
Arabian ar
Armenian  hy
Azeri az
Belarusian  be
Bosnian bs
Bulgarian bg
Catalan ca
Croatian  hr
Czech cs
Chinese zh
Danish  da
Dutch nl
English en
Estonian  et
Finnish fi
French  fr
Georgian  ka
German  de
Greek el
Hebrew  he
Hungarian hu
Icelandic is
Indonesian  id
Italian it
Japanese  ja
Korean  ko
Latvian lv
Lithuanian  lt
Macedonian  mk
Malay ms
Maltese mt
Norwegian no
Polish  pl
Portuguese  pt
Romanian  ro
Russian ru
Spanish es
Serbian sr
Slovak  sk
Slovenian sl
Swedish sv
Thai  th
Turkish tr
Ukrainian uk
Vietnamese  vi
--]]
