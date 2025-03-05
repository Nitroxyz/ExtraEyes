meta = {
    name = "ExtraEyes",
    version = "1.11",
    author = "Nitroxy",
    description = "Shows held items",
    online_safe = true
}
--Versions after 5.3:
--14

--[[ New:
Birdies
Recruits (Hidden) 
Class based system full rework lel (internal)
Debugging (Hidden)
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

local debug = require("debug_pack.lua")
debug.active = false


local backitem = {}
backitem[ENT_TYPE.ITEM_JETPACK]             = {columns = 10, rows = 2}
backitem[ENT_TYPE.ITEM_CAPE]                = {columns = 4, rows = 7}
backitem[ENT_TYPE.ITEM_VLADS_CAPE]          = {columns = 4, rows = 6}
backitem[ENT_TYPE.ITEM_HOVERPACK]           = {columns = 5, rows = 9}
backitem[ENT_TYPE.ITEM_TELEPORTER_BACKPACK] = {columns = 8, rows = 4}
backitem[ENT_TYPE.ITEM_POWERPACK]           = {columns = 8, rows = 11}

--Define vars
-- sorted by slot, holds the Drawable classes
local holding = {}
local arrows = {}
local birdies = {}

-- All use the same
local backitem_texture = 373
local backitems = {}

--backitem[ENT_TYPE.ITEM_JETPACK_MECH] = ???

local hud_size = get_setting(SAFE_SETTING.HUD_SIZE)
if hud_size ~= 0 then
    print('Your hud size needs to be "small" for the mod to work!')
end

local function set_draw(ent)
    --local temp = Drawable:new()
    local temp = {}
    local texture = ent:get_texture()
    local texture_width = math.floor(get_texture_definition(texture).width / get_texture_definition(texture).tile_width)
    temp.textures = texture;
    temp.columns = ent.animation_frame % texture_width;
    temp.rows =  math.floor(ent.animation_frame / texture_width);
    debug.print_if(math.abs(ent.width-1.25) > 0.001, "Oh what tha hell bruv w")
    debug.print_if(math.abs(ent.height-1.25) > 0.001, "Oh what tha hell bruv h")
    if (ent.width-ent.height) > 0.0001 then
        if debug.active then
            print("GUUUUUH")
        end
    end
    return temp
end

-- Find the backitem of the player
set_callback(function()
    --clear tables (If not in-game, it will not draw)

    holding = {}
    arrows = {}
    birdies = {}
    backitems = {}

    local new_state = get_local_state() --[[@as StateMemory]]

    if new_state.screen ~= SCREEN.LEVEL or new_state.loading == 0 then
        for slot = 1, 4 do
            local player = get_player(slot, false)
            if player then
                local held_item = player:get_held_entity()
                if held_item then
                    holding[slot] = set_draw(held_item)

                    if held_item.rendering_info.texture_num > 1 then
                        if debug.active then
                            print("Texture num is higher!")
                            prinspect(held_item.rendering_info.texture_num)
                        end
                    end
                    
                    -- Arrows
                    local arrow = held_item:get_held_entity()
                    if arrow then
                        -- Check if held item is a crossbow
                        if held_item.type.id == ENT_TYPE.ITEM_CROSSBOW or held_item.type.id == ENT_TYPE.ITEM_HOUYIBOW then
                            -- Check if its an arrow
                            local type = arrow.type.id
                            if type == ENT_TYPE.ITEM_WOODEN_ARROW or type == ENT_TYPE.ITEM_METAL_ARROW or type == ENT_TYPE.ITEM_LIGHT_ARROW then
                                arrows[slot] = set_draw(arrow)
                            end
                        end

                        
                    end

                    -- Birdies
                    local items = held_item:get_items()
                    if items then
                        for key, value in pairs(items) do
                            local bird = get_entity(value)
                            if bird.type.id == ENT_TYPE.FX_BIRDIES then
                                birdies[slot] = set_draw(bird)
                            end
                        end
                    end
                    debug.print_if(not items, "guh")
                end

                -- Back items!!!
                local backi = player:worn_backitem()
                if backi ~= -1 then
                    backitems[slot] = backitem[get_entity_type(backi)]
                    debug.print_if(get_entity_type(backi) == ENT_TYPE.ITEM_JETPACK_MECH, "HOOOW")
                end
            end
        end
    end
    local bf
    if options.before then
        bf = "After"
    else
        bf = "Before"
    end
    debug.q.draw(0, bf)
end, ON.POST_GAME_LOOP)

set_callback(function(render_ctx, hud)
    render_ctx = render_ctx --[[@as VanillaRenderContext]]
    hud = hud --[[@as Hud]]

    --0.86 base
    --1.15 up

    for slot, value in pairs(hud.data.inventory) do
        if value.enabled then
            debug.print_if(hud.opacity ~= hud.data.opacity, "There is an issue with my ai: " .. hud.opacity .. " " .. hud.data.opacity)
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

            if holding[slot] then
                local hold = holding[slot]
                render_ctx:draw_screen_texture(hold.textures, hold.rows, hold.columns, temp_quad, custom_color);
                --render_ctx:draw_screen_texture(textures[slot], sources[slot], temp_quad2, custom_color);
            end
            if arrows[slot] then
                local arrow = arrows[slot]
                render_ctx:draw_screen_texture(arrow.textures, arrow.rows, arrow.columns, temp_quad, custom_color);
            end
            if birdies[slot] and options.before then
                local bird = birdies[slot]
                temp_quad:offset(0, b * (16/9) * 0.4 / 1.25)
                render_ctx:draw_screen_texture(bird.textures, bird.rows, bird.columns, temp_quad, custom_color);
                temp_quad:offset(0, -b * (16/9) * 0.4 / 1.25)
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

            if backitems[slot] then
                render_ctx:draw_screen_texture(backitem_texture, backitems[slot].rows, backitems[slot].columns, temp_quad, custom_color)
            end
        end
    end
end, ON.RENDER_PRE_HUD)

register_option_bool("a_old", "Use old visuals", "Icons don't adjust to player fade", false);
register_option_bool("before", "Before/After", "", false)
--[[register_option_callback("b_recruit", false, function (draw_ctx)
    options.b_recruit = draw_ctx:win_check("Recruit", options.b_recruit)
    debug.active = options.b_recruit
    draw_ctx:win_text("Activates a bunch of debugging stuff helpful to find unknown issues")
end)]]
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