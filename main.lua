meta = {
    name = "ExtraEyes",
    version = "5.6",
    author = "Nitroxy",
    description = "Shows held items"
}
--Versions after 5.3:
--3
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
local hi_rect = {}; --quad

--alpha
local polaroid_activate = false;

--noiZ
ready = false;

set_callback(function()
    --empty vars
    hi_text = {};
    hi_col = {};
    hi_row = {};
    hi_rect = {};

    if state.screen ~= SCREEN.LEVEL or options.debug_killswitch then
        --nothing
    else
        if state.loading == 0 and ready then
            --[[ alpha
            if polaroid_activate then
                console_prinspect("new shot")

            end
            ]]
            for i, tPlayer in ipairs(players) do
                if tPlayer.holding_uid > -1 then
                    --instanz stuff
                    local held_item = get_entity(tPlayer.holding_uid)
                    if held_item ~= nil then --Apperently THIS IS NECESSARY
                        local text = held_item:get_texture()
                        local text_width = math.floor(get_texture_definition(text).width / get_texture_definition(text).tile_width)
                        table.insert(hi_text, text)
                        --source
                        table.insert(hi_col, held_item.animation_frame % text_width)
                        table.insert(hi_row, math.floor(held_item.animation_frame / text_width))
                        --[[ alpha
                        if polaroid_activate then
                            --in order: player slot, holding uid, item uid, item type, item texture, item animation frame, texture width
                            console_prinspect(tPlayer.inventory.player_slot, tPlayer.holding_uid, held_item.uid, held_item.type.id, held_item:get_texture(), held_item.animation_frame, text_width)
                        end
                        ]]

                        --destination
                        --[[ delta
                        if options.a_custom then
                            x = options.left + ((tPlayer.inventory.player_slot-1)*0.320)
                            y = options.top
                            b = options.big
                        else
                        --]]
                        local x = -0.985 + ((tPlayer.inventory.player_slot-1)*0.320)
                        local y = 0.920
                        local b = 0.06
                        local temp_aabb = AABB:new(x, y, x + b, y - (b * (16/9)));
                        table.insert(hi_rect, Quad:new(temp_aabb));
                    end
                end
            end
        end
    end
end, ON.POST_UPDATE)

set_callback(function(render_ctx, hud)

    -- alpha
    if polaroid_activate then
        --console_prinspect("new shot")
        message("new shot")
    end

    --0.86 base
    --1.15 up


    for ii, v in ipairs(hi_text) do
        --shaddow
        --[[
        local shadow = Quad:new(hi_rect[ii]);
        shadow:offset( -0.003, -0.004);
        if options.shaddow then
            render_ctx:draw_screen_texture(v, hi_row[ii], hi_col[ii], shadow, c_black);
        end
        ]]
        --[[ Debug
        local r_ab = hi_rect[ii]:get_AABB();
        if polaroid_activate then
            -- In order: texture_id, row, column, aabb left, aabb bottom, aabb right, aabb top
            prinspect(v, hi_row[ii], hi_col[ii], r_ab.left, r_ab.bottom, r_ab.right, r_ab.top);
        end
        ]]
        local custom_color = Color:new(1, 1, 1, hud.opacity);

        render_ctx:draw_screen_texture(v, hi_row[ii], hi_col[ii], hi_rect[ii], custom_color);
        
    end
    -- alpha
    if polaroid_activate then
        message("shot taken")
        polaroid_activate = false
    end
    
end, ON.RENDER_POST_HUD)

-- wait 1 second before updating
set_callback(function ()
    set_timeout(function ()
        ready = true
    end, 60)
end, ON.POST_LEVEL_GENERATION)

-- alpha
register_option_button("debug_polariod", "Polaroid", "", function ()
    polaroid_activate = true
end)

register_option_bool("debug_killswitch", "killswitch", "", false)

--[[ delta
register_option_bool("a_custom", "custom position", "Be precise", false)
register_option_float("left", "left", "", -0.985, -1, 1)
register_option_float("top", "top", "", 0.910, -1, 1)
register_option_float("big", "big", "", 0.05, 0, 2)
--]]

register_option_bool("shaddow", "drop shaddow", "", false)

--[[ Credits
    NoiZ for ideas, inspiration and programming
    Deltarune for the name and betatesting
]]