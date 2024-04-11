local logger = require("ReasonableInnPrices/logger")

local singletons = {}

local npc_manager = nil
local talk_event_manager = nil

function singletons.get_npc_manager()
    if npc_manager == nil then
        npc_manager = sdk.get_managed_singleton("app.NPCManager")
    end
    return npc_manager
end

function singletons.get_talk_event_manager()
    if talk_event_manager == nil then
        talk_event_manager = sdk.get_managed_singleton("app.TalkEventManager")
    end
    return talk_event_manager
end

return singletons