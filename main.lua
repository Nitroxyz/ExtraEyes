meta = {
    name = "ExtraEyes",
    version = "5.7",
    author = "Nitroxy",
    description = "Shows held items"
}
--Versions after 5.3:
--4
--[[ TODO: 
ADD DISPLAY FOR HIRED HAND
Put the icon to the right of the ropes pls
Put backitems behind the heart
Add fade to pauses and other occasions
Make the hud transparent
make the hud adjust to the options
Mount display
]]

--[[ Positions
DISTANCE BETWEEN HUD'S: 0.320
OG: -0.952,0.74,0.041
Next to: -0.7, 0.96, 0.08
On heart: -0.985, 0.910, 0.05
New heart: -0.985, 0.920, 0.06
--]]

--Define vars
local hi_text = {}; --texture
local hi_col = {}; --column
local hi_row = {}; --row

--noiZ
--local ready = false;

set_callback(function()
    --empty vars
    hi_text = {};
    hi_col = {};
    hi_row = {};

    if state.screen == SCREEN.LEVEL then
        if state.loading == 0 --[[and ready]] then
            for _, tPlayer in ipairs(players) do
                if tPlayer.holding_uid > -1 then
                    --instanz stuff
                    local held_item = get_entity(tPlayer.holding_uid)
                    if held_item ~= nil then --Apperently THIS IS NECESSARY
                        local player_slot = tPlayer.inventory.player_slot;
                        local text = held_item:get_texture()
                        local text_width = math.floor(get_texture_definition(text).width / get_texture_definition(text).tile_width)
                        hi_text[player_slot] = text;
                        --source
                        hi_col[player_slot] = held_item.animation_frame % text_width;
                        hi_row[player_slot] =  math.floor(held_item.animation_frame / text_width);

                        --destination
                        --[[ delta
                        if options.a_custom then
                            x = options.left + ((tPlayer.inventory.player_slot-1)*0.320)
                            y = options.top
                            b = options.big
                        else
                        --]]
                    end
                end
            end
        end
    end
end, ON.POST_UPDATE)

set_callback(function(render_ctx, hud)

    --0.86 base
    --1.15 up

    for i, v in pairs(hud.data.inventory) do
        if(v.enabled)then
            local p_opacity = hud.data.players[i].opacity;
            local custom_color = Color:new(1, 1, 1, hud.opacity * p_opacity);
            local x = -0.985 + ((i-1)*0.320);
            local y = 0.920; -- add hud.y later
            local b = 0.06;
            local temp_aabb = AABB:new(x, y, x + b, y - (b * (16/9)));
            local temp_quad = Quad:new(temp_aabb);

            if(hi_text[i] ~= nil)then
                render_ctx:draw_screen_texture(hi_text[i], hi_row[i], hi_col[i], temp_quad, custom_color);
            end
        end
    end
end, ON.RENDER_POST_HUD)

-- wait 1 second before updating
--[[
set_callback(function ()
    set_timeout(function ()
        ready = true
    end, 60)
end, ON.POST_LEVEL_GENERATION)
]]

--[[ delta
register_option_bool("a_custom", "custom position", "Be precise", false)
register_option_float("left", "left", "", -0.985, -1, 1)
register_option_float("top", "top", "", 0.910, -1, 1)
register_option_float("big", "big", "", 0.05, 0, 2)
--]]

--[[ Credits
    NoiZ for ideas, inspiration and programming
    Deltarune for the name and betatesting
]]