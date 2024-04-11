local logger = require("ReasonableInnPrices/logger")
local singletons = require("ReasonableInnPrices/singletons")

local hooks = {}

local function is_inn(character_shop)
    local character_shop_type = character_shop:get_type_definition()
    local character_shop_type_full_name = character_shop_type:get_full_name()
    return character_shop_type_full_name == "app.NpcShopInnParam"
end

local function handle_character_shop_data(character_shop_data)
    if character_shop_data == nil then
        logger.log_info("CharacterShopData is null")
        return
    end

    local iter = character_shop_data:GetEnumerator()
    iter:MoveNext()
    while iter:get_Current() ~= nil do
        local character_shop = iter:get_Current()

        if is_inn(character_shop) then
            local chara_id = character_shop._CharaID
            local cost = character_shop._Cost

            local character_data = singletons.get_npc_manager():getNPCData(chara_id)
            local name = character_data:get_Name()

            logger.log_info("Adjusting inn price for " .. name .. " (" .. chara_id .. ") to " .. cost .. " G.")

            if cost >= 1000 then
                character_shop._Cost = character_shop._Cost * 0.1
            end
        end

        iter:MoveNext()
    end
end

local function handle_shop_talk_event_data_catalog(shop_talk_event_data_catalog)
    if shop_talk_event_data_catalog == nil then
        logger.log_info("ShopTalkEventDataCatalog is nil")
        return
    end

    local iter = shop_talk_event_data_catalog:GetEnumerator()
    iter:MoveNext()
    while iter:get_Current():get_Value() ~= nil do

        local npc_shop_talk_data = iter:get_Current():get_Value()
        local character_shop_data = npc_shop_talk_data._CharacterShopData
        handle_character_shop_data(character_shop_data)

        iter:MoveNext()
    end
end

local function post_on_change_scene_type()
    local shop_talk_event_data_catalog = singletons.get_talk_event_manager()._ShopTalkEventDataCatalog
    handle_shop_talk_event_data_catalog(shop_talk_event_data_catalog)

    logger.log_info("Inn prices updated.")
end

function hooks.init()
    sdk.hook(sdk.find_type_definition("app.GuiManager"):get_method("OnChangeSceneType"), nil, post_on_change_scene_type)
    logger.log_info("Initialized hooks.")
end

return hooks
