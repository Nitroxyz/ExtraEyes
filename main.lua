meta = {
    name = "ExtraEyes",
    version = "1.10.0",
    author = "Nitroxy",
    description = "Shows held items",
    online_safe = true
}
--Versions after 5.3:
--11

--[[ New:
Warns you if you don't have the correct hud size
arrows in crossbows are now also displayed
]]

--[[ TODO: 
ADD DISPLAY FOR HIRED HAND
Put the icon to the right of the ropes pls
Add fade to pauses and other occasions
Mount display
]]

--[[ Positions
DISTANCE BETWEEN HUD'S: 0.320
OG: -0.952,0.74,0.041
Next to: -0.7, 0.96, 0.08
On heart: -0.985, 0.910, 0.05
New heart: -0.985, 0.920, 0.06
--]]

local backitem = {}
backitem[ENT_TYPE.ITEM_JETPACK]             = {columns = 10, rows = 2}
backitem[ENT_TYPE.ITEM_CAPE]                = {columns = 4, rows = 7}
backitem[ENT_TYPE.ITEM_VLADS_CAPE]          = {columns = 4, rows = 6}
backitem[ENT_TYPE.ITEM_HOVERPACK]           = {columns = 5, rows = 9}
backitem[ENT_TYPE.ITEM_TELEPORTER_BACKPACK] = {columns = 8, rows = 4}
backitem[ENT_TYPE.ITEM_POWERPACK]           = {columns = 8, rows = 11}

--Define vars
local textures = {}
local columns = {}
local rows = {}
-- Special case: Use the slot to find it, gives the texture id of the arrow when present
local arrows = {
    textures = {},
    columns = {},
    rows = {},
}

-- All use the same
local backitem_texture = 373

local player_backitem = {}

--backitem[ENT_TYPE.ITEM_JETPACK_MECH] = ???

local hud_size = get_setting(SAFE_SETTING.HUD_SIZE)
if hud_size ~= 0 then
    print('Your hud size needs to be "small" for the mod to work!')
end

-- Find the backitem of the player
set_callback(function()
    --clear tables (If not in-game, it will not draw)
    textures = {}
    columns = {}
    rows = {}
    arrows = {
        textures = {},
        columns = {},
        rows = {},
    }
    player_backitem = {}

    local new_state = get_local_state() --[[@as StateMemory]]

    if new_state.screen ~= SCREEN.LEVEL or new_state.loading == 0 then
        for slot = 1, 4 do
            local player = get_player(slot, false)
            if player then
                --local held_item = get_entity(player.holding_uid)
                local held_item = player:get_held_entity()
                if held_item then
                    local texture = held_item:get_texture()
                    --if not texture then
                        --print("THIS NEEDS TO BE INVESTIGATED")
                        --prinspect(held_item.type.id)
                    --end
                    local texture_width = math.floor(get_texture_definition(texture).width / get_texture_definition(texture).tile_width)
                    textures[slot] = texture;
                    columns[slot] = held_item.animation_frame % texture_width;
                    rows[slot] =  math.floor(held_item.animation_frame / texture_width);
                    
                    --[[
                    local redner = held_item.rendering_info
                    --sources[slot] = redner.source

                    if redner.render_inactive then
                        -- Occurs when outside of visible screen
                        --print("NO RENDER!!!")
                    end
                    
                    if redner.texture_num > 1 then
                        --print("Texture num is higher!")
                        --prinspect(redner.texture_num)
                    end
                    ]]
                    
                    -- Arrows
                    local arrow = held_item:get_held_entity()
                    if arrow then
                        -- Check if its a crossbow
                        if held_item.type.id == ENT_TYPE.ITEM_CROSSBOW or held_item.type.id == ENT_TYPE.ITEM_HOUYIBOW then
                            -- Check if its an arrow
                            local type = arrow.type.id
                            if type == ENT_TYPE.ITEM_WOODEN_ARROW or type == ENT_TYPE.ITEM_METAL_ARROW or type == ENT_TYPE.ITEM_LIGHT_ARROW then
                                local a_texture = arrow:get_texture()
                                --if not texture then
                                    --print("THIS NEEDS TO BE INVESTIGATED")
                                    --prinspect(held_item.type.id)
                                --end
                                local a_texture_width = math.floor(get_texture_definition(a_texture).width / get_texture_definition(a_texture).tile_width)
                                arrows.textures[slot] = a_texture;
                                arrows.columns[slot] = arrow.animation_frame % a_texture_width;
                                arrows.rows[slot] =  math.floor(arrow.animation_frame / a_texture_width);
                            end
                        end
                    end
                end

                -- Back items!!!
                local backi = player:worn_backitem()
                if backi ~= -1 then
                    player_backitem[slot] = backitem[get_entity_type(backi)]
                end
            end
        end
    end
end, ON.POST_GAME_LOOP)

set_callback(function(render_ctx, hud)
    render_ctx = render_ctx --[[@as VanillaRenderContext]]
    hud = hud --[[@as Hud]]

    --0.86 base
    --1.15 up

    for slot, value in pairs(hud.data.inventory) do
        if(value.enabled)then
            --if hud.opacity ~= hud.data.opacity then
                --print("There is an issue with my ai")
                --prinspect(hud.opacity)
                --prinspect(hud.data.opacity)
            --end
            local player_opacity;
            if options.a_old then
                player_opacity = 1;
            else
                player_opacity = hud.data.players[slot].opacity;
            end
            local custom_color = Color:new(1, 1, 1, hud.opacity * player_opacity);
            local x = -0.985 + ((slot-1)*0.320);
            local y = 0.06 + hud.y;
            local b = 0.06;
            local temp_aabb = AABB:new(x, y, x + b, y - (b * (16/9)));
            local temp_quad = Quad:new(temp_aabb);

            --[[
            local temp_aabb2 = AABB:new(x, y-0.1, x + b, y - (b * (16/9)));
            local temp_quad2 = Quad:new(temp_aabb2);
            ]]

            if textures[slot] then
                render_ctx:draw_screen_texture(textures[slot], rows[slot], columns[slot], temp_quad, custom_color);
                --render_ctx:draw_screen_texture(textures[slot], sources[slot], temp_quad2, custom_color);
            end
            if arrows.textures[slot] then
                render_ctx:draw_screen_texture(arrows.textures[slot], arrows.rows[slot], arrows.columns[slot], temp_quad, custom_color);
            end
        end
    end
end, ON.RENDER_POST_HUD)

set_callback(function (render_ctx, hud)
    render_ctx = render_ctx --[[@as VanillaRenderContext]]
    hud = hud --[[@as Hud]]

    for slot, value in pairs(hud.data.inventory) do
        if(value.enabled)then
            local player_opacity;
            if options.a_old then
                player_opacity = 1;
            else
                player_opacity = hud.data.players[slot].opacity;
            end
            local kapala_offset = 0
            if value.kapala then
                kapala_offset = 0.016
            end
            local custom_color = Color:new(1, 1, 1, hud.opacity * player_opacity);
            local x = -0.978 + ((slot-1)*0.320) + kapala_offset;
            local y = 0.120 + hud.y;
            local b = 0.1;
            local temp_aabb = AABB:new(x, y, x + b, y - (b * (16/9)));
            local temp_quad = Quad:new(temp_aabb);

            if player_backitem[slot] then
                render_ctx:draw_screen_texture(backitem_texture, player_backitem[slot].rows, player_backitem[slot].columns, temp_quad, custom_color)
            end
        end
    end
end, ON.RENDER_PRE_HUD)

register_option_bool("a_old", "Use old visuals", "Icons don't adjust to player fade", false);
--[[ delta
register_option_bool("c_custom", "custom position", "Be precise", true)
register_option_float("d_just", "SEEEE", "", 0.320, 0, 0)
register_option_float("e_left", "left", "", -0.977, -1, 1)
]]
--[[
register_option_string("d_left", "left", "", "0.016")
register_option_float("e_top", "top", "", 0.120, -1, 1)
register_option_float("f_big", "big", "", 0.1, 0, 2)
]]

--[[
-0.961
-0.978
0.120
0.100
]]

--[[ Credits
    NoiZ for ideas, inspiration and programming
    Deltarune for the name and betatesting
]]

--1 -> 1
--0 -> p_opacity