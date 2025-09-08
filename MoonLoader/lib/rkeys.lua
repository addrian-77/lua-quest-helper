--[[
   Author: DonHomka
   [Functions]
      HotKeys:
      # registerHotKey(table keycombo, int activationType, [bool blockInput = false], function callback)
         Ðåãèñòðèðóåò íîâûé õîòêåé. Ìîæíî îïóñòèòü ïàðàìåòð áëîêèðîâêè ââîäà. Âîçâðàùàåò ID íîâîãî õîòêåÿ
      # unRegisterHotKey(int id)
         Óäàëÿåò õîòêåé ïî ID
      # unRegisterHotKey(table keycombo)
         Óäàëÿåò õîòêåé ïî êîìáèíàöèè êëàâèø. Âîçâðàùàåò ðåçóëüòàò óäàëåíèÿ è êîëëè÷åñòâî óäàëåííûõ õîòêååâ.
      # isHotKeyDefined(ind id)
         Ïðîâåðÿåò íà ñóùåñòâîâàíèå îïðåäåëåííûõ ID êëàâèøè.
      # isHotKeyDefined(table keycombo)
         Ïðîâåðÿåò íà ñóùåòñâîâàíèå õîòêåÿ ñ çàäàííîé êîìáèíàöèåé
      # getHotKey(int id)
         Âîçâðàùàåò äàííûå õîòêåÿ èç òàáëèöû tHotKeys ïî ID. Ïåðâûì âîçâðàùàåìûì ïàðàìåòðîì èäåò ðåçóëüòàò ïîèñêà.
      # getHotKey(table keycombo)
         Âîçâðàùàåò äàííûå õîòêåÿ èç òàáëèöû tHotKeys ïî êîìáèíàöèè êëàâèø. Ïåðâûì âîçâðàùàåìûì ïàðàìåòðîì èäåò ðåçóëüòàò ïîèñêà.
      Other:
      # isKeyExist(int keyid, [table keylist = tCurKeys])
         Ïðîâåðÿåò ñóùåñòâîâàíèå îïðåäåëåííîé êëàâèøè â ñïèñêå. Ïî óìîë÷àíèþ áåðåòñÿ ñïèñîê òåêóùèõ íàæàòûõ êëàâèø.
      # isKeyComboExist(talbe keycombo, [table keylist = tCurKeys])
         Ïðîâåðÿåò íà ñóùåñòâîâàíèå êîìáèíàöèè êëàâèø â ñïèñêå
      # getKeyPosition(int keyid, [table keylist = tCurKeys])
         Âîçâðàùàåò ïîçèöèþ êëàâèøè â ñïèñêå. Åñëè êëàâèøè íåò - âåðíåò nil
      # getExtendedKeys(int keyid, int scancode, int keyex)
         Âîçâðàùàåò ðàñøèðåíóþ âåðñèþ ìîäèôèêàòîðîâ èëè nil
      # getKeys([bool showKeyName = false])
         Âîçâðàùàåò òàáëèöó òåêóùèõ íàæàòûõ êëàâèø. Àðãóìåíòîì çàäàåòñÿ íóæíî ëè âîçâðàùàòü èìÿ êëàâèøè.
      tHotKeys data:
         - keys - êëàâèøè äëÿ õîòêåÿ
         - aType - òèï õîòêåÿ:
            1 - ñðàáàòûâàåò íà íàæàòèå êëàâèøè
            2 - ñðàáàòûâàåò íà íàæàòèå è äî òåõ ïîð ïîêà êëàâèøà çàæàòà
            3 - ñðàáàòûâàåò ïðè îòæàòèè ïîñëåäíåé(!) êëàâèøè â êîìáî (Alt + Shift + R - ñðàáîòàåò åñëè çàæàòü êîìáèíàöèþ è îòïóñòèòü R)
         - isBlock - íóæíî ëè áëîêèðîâàòü ââîä äëÿ ïîñëåäíåé(!) êëàâèøè êîìáî. Íå ðàáîòàåò äëÿ aType = 3.
         - callback - ôóíêöèÿ îáðàòíîãî âûçîâà äëÿ ñðàáàòûâàíèÿ êëàâèøè
         - id - óíèêàëüíûé èíäåôèêàòîð õîòêåÿ (íå ïîçèöèÿ â tHotKeys, à èìåííî óíèêàëüíûé èíäåôèêàòîð). Èìååíî ïî ýòîìó ID ïðîèñõîäèò ïîèñê êëàâèø.
   E-mail: idonhomka@gmail.com
   VK: http://vk.com/DonHomka
   TeleGramm: http://t.me/iDonHomka
   Discord: DonHomka#2534
]]
local vkeys = require 'vkeys'
local wm = require 'windows.message'
local bitex = require 'bitex'
local ffi = require 'ffi'

local tCurKeys = {}
local tModKeys = { [vkeys.VK_MENU] = true, [vkeys.VK_SHIFT] = true, [vkeys.VK_CONTROL] = true }
local tModKeysList = { vkeys.VK_MENU, vkeys.VK_LMENU, vkeys.VK_RMENU, vkeys.VK_SHIFT, vkeys.VK_RSHIFT, vkeys.VK_LSHIFT, vkeys.VK_CONTROL, vkeys.VK_LCONTROL, vkeys.VK_RCONTROL }
local tMessageTrigger = {
                        [wm.WM_KEYDOWN] = true,
                        [wm.WM_SYSKEYDOWN] = true,
                        [wm.WM_KEYUP] = true,
                        [wm.WM_SYSKEYUP] = true,
                        [wm.WM_LBUTTONDOWN] = true,
                        [wm.WM_LBUTTONDBLCLK] = true,
                        [wm.WM_LBUTTONUP] = true,
                        [wm.WM_RBUTTONDOWN] = true,
                        [wm.WM_RBUTTONDBLCLK] = true,
                        [wm.WM_RBUTTONUP] = true,
                        [wm.WM_MBUTTONDOWN] = true,
                        [wm.WM_MBUTTONDBLCLK] = true,
                        [wm.WM_MBUTTONUP] = true,
                        [wm.WM_XBUTTONDOWN] = true,
                        [wm.WM_XBUTTONDBLCLK] = true,
                        [wm.WM_XBUTTONUP] = true,
                        [wm.WM_MOUSEWHEEL] = true
                     }
local tRewriteMouseKeys = {
                           [wm.WM_LBUTTONDOWN] = vkeys.VK_LBUTTON,
                           [wm.WM_LBUTTONUP] = vkeys.VK_LBUTTON,
                           [wm.WM_RBUTTONDOWN] = vkeys.VK_RBUTTON,
                           [wm.WM_RBUTTONUP] = vkeys.VK_RBUTTON,
                           [wm.WM_MBUTTONDOWN] = vkeys.VK_MBUTTON,
                           [wm.WM_MBUTTONUP] = vkeys.VK_MBUTTON,
                        }
local tXButtonMessage = {
                           [wm.WM_XBUTTONUP] = true,
                           [wm.WM_XBUTTONDOWN] = true,
                           [wm.WM_XBUTTONDBLCLK] = true,
                        }
local tXButtonMouseData = {
                           vkeys.VK_XBUTTON1,
                           vkeys.VK_XBUTTON2
                        }
local tDownMessages = {
                        [wm.WM_KEYDOWN] = true,
                        [wm.WM_SYSKEYDOWN] = true,
                        [wm.WM_LBUTTONDOWN] = true,
                        [wm.WM_RBUTTONDOWN] = true,
                        [wm.WM_MBUTTONDOWN] = true,
                        [wm.WM_XBUTTONDOWN] = true,
                        [wm.WM_LBUTTONDBLCLK] = true,
                        [wm.WM_RBUTTONDBLCLK] = true,
                        [wm.WM_MBUTTONDBLCLK] = true,
                        [wm.WM_XBUTTONDBLCLK] = true,
                        [wm.WM_MOUSEWHEEL] = true
                     }
local tHotKeys = {}
local tActKeys = {}
local hkId = 0
local mod = {}
--- Òåêóùàÿ âåðñèÿ ìîäóëÿ
mod._VERSION = "2.1.1"
--- Ñïèñîê êëàâèø ìîäèôèêàòîðîâ âêëþ÷àÿ ðàñøèðåíûå âåðñèè
mod._MODKEYS = tModKeysList
--- Îïðåäåëÿåò íóæíî ëè áëîêèðîâàòü íàæàòèÿ äëÿ îêíà ïðè íàæàòèè ëþáîãî çàðåãèñòðèðîâàííîãî ñî÷åòàíèÿ
mod._LOCKKEYS = false
--- Ïñåâäî-êëàâèøè äëÿ WM_MOUSEWHEEL
mod.vkeys = {
   VK_WHEELDOWN = 0x100,
   VK_WHEELUP = 0x101
}
--- Íàçâàíèÿ ïñåâäî-êëàâèø
mod.vkeys.names = {
   [mod.vkeys.VK_WHEELDOWN] = "Mouse Wheel Down",
   [mod.vkeys.VK_WHEELUP] = "Mouse Wheel Up",
}

local id_to_name = function(id)
   local name = vkeys.id_to_name(id) or mod.vkeys.names[id]
   return name
end
local HIWORD = function(param)
  return bit.rshift(bit.band(param, 0xffff0000), 16);
end
local splitsigned = function(n) -- ÑÏÀÑÈÁÎ WINAPI.lua è GITHUB è Chat mimgui
  n = tonumber(n)
  local x, y = bit.band(n, 0xffff), bit.rshift(n, 16)
  if x >= 0x8000 then x = x-0xffff end
  if y >= 0x8000 then y = y-0xffff end
  return x, y
end

addEventHandler("onWindowMessage", function (message, wparam, lparam)
   if tMessageTrigger[message] then
      local scancode = bitex.bextract(lparam, 16, 8)
      local keystate = bitex.bextract(lparam, 30, 1)
      local keyex = bitex.bextract(lparam, 24, 1)
      if tXButtonMessage[message] then
         local btn = HIWORD(wparam)
         wparam = tXButtonMouseData[btn]
      elseif message == wm.WM_MOUSEWHEEL then
         local btn, delta = splitsigned(ffi.cast('int32_t', wparam))
         if delta < 0 then
            wparam = mod.vkeys.VK_WHEELDOWN
         elseif delta > 0 then
            wparam = mod.vkeys.VK_WHEELUP
         end
      elseif tRewriteMouseKeys[message] then
         wparam = tRewriteMouseKeys[message]
      end
      local keydown = mod.isKeyExist(wparam)
      if tDownMessages[message] then
         if not keydown and keystate == 0 then
            table.insert(tCurKeys, wparam)
            if tModKeys[wparam] then
               local exKey = mod.getExtendedKeys(wparam, scancode, keyex)
               if exKey then
                  table.insert(tCurKeys, exKey)
               end
            end
         end
         for k, v in ipairs(tHotKeys) do
            if v.aType ~= 3 and (tActKeys[v.id] == nil or v.aType == 2)
               and ((v.aType == 1 and keystate == 0) or v.aType == 2)
               and mod.isKeyComboExist(v.keys)
               and (not mod.isKeysExist(tModKeysList, v.keys) and not mod.isKeysExist(tModKeysList) or mod.isKeysExist(tModKeysList, v.keys))
               and (mod.onHotKey == nil or (mod.onHotKey and mod.onHotKey(v.id, v) ~= false))
            then
               lua_thread.create(function()
                  wait(0)
                  v.callback(v)
               end)
               tActKeys[v.id] = true
            end
            if v.isBlock and (tActKeys[v.id] or v.aType == 2) or (tActKeys[v.id] and not v.isBlock and mod._LOCKKEYS) then
               consumeWindowMessage()
            end
         end
      else
         for k, v in ipairs(tHotKeys) do
            if v.aType == 3 and keystate == 1 and mod.isKeyComboExist(v.keys)
               and (mod.onHotKey == nil or (mod.onHotKey and mod.onHotKey(v.id, v) ~= false))
               then
               v.callback(v)
            end
         end
         if keydown then
            local pos = mod.getKeyPosition(wparam)
            table.remove(tCurKeys, pos)
            if tModKeys[wparam] then
               local exKey = mod.getExtendedKeys(wparam, scancode, keyex)
               if exKey then
                  pos = mod.getKeyPosition(exKey)
                  table.remove(tCurKeys, pos)
               end
            end
         end
      end
      if message == wm.WM_MOUSEWHEEL then
         local pos = mod.getKeyPosition(wparam)
         table.remove(tCurKeys, pos)
      end
      for k, v in ipairs(tHotKeys) do
         if v.aType == 2 or tActKeys[v.id] and not mod.isKeyComboExist(v.keys) then
            tActKeys[v.id] = nil
         end
      end
   elseif message == wm.WM_KILLFOCUS then
      tCurKeys = {}
   end
end)

--- Ðåãèñòðèðóåò íîâîå ñî÷åòàíèå êëàâèø. Ïàðàìåòð isBlock ìîæíî îïóñòèòü
---@param keycombo table
---@param activationType integer
---@param isBlock_or_callback boolean|function
---@param callback function
---@return integer
function mod.registerHotKey(keycombo, activationType, isBlock_or_callback, callback)
   local newId = hkId + 1
   tHotKeys[#tHotKeys + 1] = {
      keys = keycombo,
      aType = activationType,
      callback = type(isBlock_or_callback) == "function" and isBlock_or_callback or callback,
      id = newId,
      isBlock = type(isBlock_or_callback) == "boolean" and isBlock_or_callback or false
   }
   hkId = hkId + 1
   return newId
end

--- Ïðîâåðÿåò ñóùåñòâóåò ëè óêàçàííîå êîìáî. Ïåðâûì ïàðàìåòðîì âîçâðàùàåò ðåçóëüòàò ïðîâåðêè, âòîðûì êîëè÷åñòâî íàéäåíûõ êîìáî.
---@param keycombo_or_id table|integer
---@return boolean,integer
function mod.isHotKeyDefined(keycombo_or_id)
   local bool = false
   local count = 0
   if type(keycombo_or_id) == "number" then
      for k, v in ipairs(tHotKeys) do
         if v.id == keycombo_or_id then
            bool = true
            count = count + 1
         end
      end
   elseif type(keycombo_or_id) == "table" then
      for k, v in ipairs(tHotKeys) do
         if mod.compareKeys(v.keys, keycombo_or_id) then
            bool = true
            count = count + 1
         end
      end
   end
   return bool, count
end

--- Âîçâðàùàåò äàííûå õîòêåÿ ïî ID èëè êîìáî êëàâèø. Âîçâðàùàåò ðåçóëüòàò ïîèñêà è òàáëèöó äàííûõ.
---@param keycombo_or_id table|integer
---@return boolean,table
function mod.getHotKey(keycombo_or_id)
   local bool = false
   local data = {}
   if type(keycombo_or_id) == "number" then
      for k, v in ipairs(tHotKeys) do
         if v.id == keycombo_or_id then
            bool = true
            data = v
            break
         end
      end
   elseif type(keycombo_or_id) == "table" then
      for k, v in ipairs(tHotKeys) do
         if mod.compareKeys(v.keys, keycombo_or_id) then
            bool = true
            data = v
            break
         end
      end
   end
   return bool, data
end

---Èçìåíÿåò êîìáî êëàâèø äëÿ õîòêåÿ. Âîçâðàùàåò ðåçóëüòàò èçìåíåíèÿ.
---@param id integer
---@param keycombo table
---@return boolean
function mod.changeHotKey(id, keycombo)
   local bool = false
   for k, v in ipairs(tHotKeys) do
      if v.id == id then
         bool = true
         v.keys = keycombo
      end
   end
   return bool
end

--- Óäàëÿåò êîìáî. Ïåðâûì ïàðàìåòðîì âîçâðàùàåò ðåçóëüòàò óäàëåíèÿ, âòîðûì êîëè÷åñòâî óäàëåííûõ êîìáî.
---@param keycombo_or_id table|integer
---@return boolean,integer
function mod.unRegisterHotKey(keycombo_or_id)
   local bool = false
   local count = 0
   local idsToRemove = {}
   if type(keycombo_or_id) == "number" then
      for k, v in ipairs(tHotKeys) do
         if v.id == keycombo_or_id then
            bool = true
            count = count + 1
            table.insert(idsToRemove, k)
         end
      end
   elseif type(keycombo_or_id) == "table" then
      for k, v in ipairs(tHotKeys) do
         if mod.compareKeys(v.keys, keycombo_or_id) then
            bool = true
            count = count + 1
            table.insert(idsToRemove, k)
         end
      end
   end
   for k, v in ipairs(idsToRemove) do
      table.remove(tHotKeys, v)
   end
   return bool, count
end

--- Ïðîâåðÿåò àêòèâåí ëè õîòêåé keycombo â ñïèñêå keylist. Åñëè îïóùåí keylist - èñïîëüçóåò òåêóùèå íàæàòûå êëàâèøè.
---@param keycombo table
---@param keylist table
---@return boolean
function mod.isKeyComboExist(keycombo, keylist)
   keylist = keylist or tCurKeys
   local b = false
   local i = 1
   for k, v in ipairs(keylist) do
      if v == keycombo[i] then
         if i == #keycombo then
            b = true
            break
         end
         i = i + 1
      end
   end
   return b
end

--- Ñðàâíèâàåò äâà êîìáî
---@param keycombo table
---@param keycombotwo table
---@return boolean
function mod.compareKeys(keycombo, keycombotwo)
   local b = true
   for k, v in ipairs(keycombo) do
      if keycombotwo[k] ~= v then
         b = false
         break
      end
   end
   return b
end

--- Èùåò keyid â ñïèñêå keylist. Â îòëè÷èè îò isKeyComboExist íå èùåò íåñêîëüêî êëàâèø, à òîëüêî îäíó ñ óêàçàííîé äàòîé.
---@param keyid integer
---@param keylist table
---@return boolean
function mod.isKeyExist(keyid, keylist)
   keylist = keylist or tCurKeys
   for k, v in ipairs(keylist) do
      if tonumber(v) == tonumber(keyid) then
         return true
      end
   end
   return false
end

--- Èùåò íåñêîëüêî id èç ñïèñêà keyids â keylist. Âîçâðàùàåò èñòèíó åñëè íàéäåí õîòÿáû îäèí id èç keyids
---@param keyids table
---@param keylist table
---@return boolean
function mod.isKeysExist(keyids, keylist)
   keylist = keylist or tCurKeys
   for k, v in ipairs(keyids) do
      for kk, vv in ipairs(keylist) do
         if v == vv then
            return true
         end
      end
   end
   return false
end

--- Àíàëîã isKeyExist, íî âîçâðàùàåò ïîçèöèþ â keylist åñëè íàõîäèò.
---@param keyid integer
---@param keylist table
---@return integer|nil
function mod.getKeyPosition(keyid, keylist)
   keylist = keylist or tCurKeys
   for k, v in ipairs(keylist) do
      if v == keyid then
         return k
      end
   end
   return nil
end

--- Ïîëó÷àåò ðàñøèðåíûå âåðñèè Alt, Shift, Ctrl íà îñíîâå ñêàíêîäà è ðàñøèðåíèÿ.
---@param keyid integer
---@param scancode integer
---@param extend integer
---@return integer|nil
function mod.getExtendedKeys(keyid, scancode, extend)
   local newKeyId = nil
   if keyid == vkeys.VK_MENU then
      if extend == 1 then
         newKeyId = vkeys.VK_RMENU
      else
         newKeyId = vkeys.VK_LMENU
      end
   elseif keyid == vkeys.VK_SHIFT then
      if scancode == 42 then
         newKeyId = vkeys.VK_LSHIFT
      elseif scancode == 54 then
         newKeyId = vkeys.VK_RSHIFT
      end
   elseif keyid == vkeys.VK_CONTROL then
      if extend == 1 then
         newKeyId = vkeys.VK_RCONTROL
      else
         newKeyId = vkeys.VK_LCONTROL
      end
   end
   return newKeyId
end

--- Âîçâðàùàåò ñïèñîê òåêóùèõ íàæàòûõ êëàâèø â ôîðìàòå ñêðèïòà. Â êà÷åñòâå àðãóìåíòà ïðèíèìàåò òî êàêèå íóæíî âûâîäèòü äàííûå. Òîëüêî ÈÄ, íóæíî ëè íàçâàíèå êëàâèø
---@param keyname boolean
---@param keyscan boolean
---@param keyex boolean
---@return table
function mod.getKeys(keyname, keyscan, keyex)
   keyname = keyname or false
   local szKeys = {}
   for k, v in ipairs(tCurKeys) do
      table.insert(szKeys, ("%s%s"):format(tostring(v), (keyname and ":" .. id_to_name(v) or "")))
   end
   return szKeys
end

--- Âîçâðàùàåò êîëëè÷åñòâî íàæàòûõ êëàâèø
---@return integer
function mod.getCountKeys()
   return #tCurKeys
end

return mod