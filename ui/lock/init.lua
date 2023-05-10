local wibox = require("wibox")
local helpers = require("helpers")
local awful = require("awful")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi
local pam = require("liblua_pam")
local auth = function(password)
  return pam.auth_current_user(password)
end


local entered = 0

local header = wibox.widget {
  {
    {
      image         = beautiful.profilepicture,
      clip_shape    = helpers.rrect(100),
      forced_height = 200,
      forced_width  = 200,
      halign        = 'center',
      widget        = wibox.widget.imagebox
    },
    id = "arc",
    widget = wibox.container.arcchart,
    max_value = 100,
    min_value = 0,
    value = 0,
    rounded_edge = true,
    thickness = dpi(7),
    start_angle = 4.71238898,
    bg = beautiful.fg,
    colors = { beautiful.fg },
    forced_width = dpi(200),
    forced_height = dpi(200)
  },
  widget = wibox.container.place,
  halign = 'center',
}


local promptbox = wibox {
  type = "dock",
  width = dpi(500),
  height = dpi(500),
  bg = beautiful.bg .. '00',
  ontop = true,
  visible = false
}

local background = wibox({
  width = dpi(beautiful.scrwidth),
  height = dpi(beautiful.scrheight),
  visible = false,
  ontop = true,
  type = "splash"
})

awful.placement.centered(background)

local visible = function(v)
  background.visible = v
  promptbox.visible = v
end

local reset = function(f)
  header:get_children_by_id('arc')[1].value = not f and 100 or 0
  header:get_children_by_id('arc')[1].colors = { not f and beautiful.err or beautiful.fg }
end
local input = ""
local function grab()
  local grabber = awful.keygrabber {
    auto_start           = true,
    stop_event           = 'release',
    mask_event_callback  = true,
    keybindings          = {
      awful.key {
        modifiers = { 'Mod1', 'Mod4', 'Shift', 'Control' },
        key       = 'Return',
        on_press  = function(_)
          input = input
        end
      }
    },
    keypressed_callback  = function(self, mod, key, command)
      if key == 'Escape' then
        input = ""
        return
      end

      -- Accept only the single charactered key
      -- Ignore 'Shift', 'Control', 'Return', 'F1', 'F2', etc., etc.
      if #key == 1 then
        header:get_children_by_id('arc')[1].colors = { beautiful.pri }
        header:get_children_by_id('arc')[1].value = 25
        header:get_children_by_id('arc')[1].start_angle = tonumber(string.format("%.8f", math.random(0, math.pi * 2)))
        if input == nil then
          input = key
          return
        end
        input = input .. key
      elseif key == "BackSpace" then
        header:get_children_by_id('arc')[1].colors = { beautiful.pri }
        header:get_children_by_id('arc')[1].value = 25
        header:get_children_by_id('arc')[1].start_angle = tonumber(string.format("%.8f", math.random(0, math.pi * 2)))
        input = input:sub(1, -2)
        if #input == 0 then
          header:get_children_by_id('arc')[1].colors = { beautiful.dis }
          header:get_children_by_id('arc')[1].value = 100
        end
      end
    end,
    keyreleased_callback = function(self, _, key, _)
      -- Validation
      if key == 'Return' then
        print("authing")
        if auth(input) then
          self:stop()
          reset(true)
          visible(false)
          input = ""
        else
          header:get_children_by_id('arc')[1].colors = { beautiful.err }
          reset(false)
          grab()
          input = ""
        end
      end
    end
  }
  grabber:start()
end


awesome.connect_signal("toggle::lock", function()
  visible(true)
  grab()
end)

background:setup {
  {
    widget = wibox.widget.imagebox,
    forced_height = beautiful.scrheight,
    horizontal_fit_policy = "fit",
    vertical_fit_policy = "fit",
    forced_width = beautiful.scrwidth,
    image = beautiful.blurwall,
  },
  layout = wibox.layout.stack
}
promptbox:setup {
  {
    {
      font = beautiful.sans .. " Bold 82",
      format = "%H:%M",
      align = "center",
      valign = "center",
      widget = wibox.widget.textclock
    },
    header,
    {
      {
        markup = helpers.colorizeText("Namish Pande", beautiful.fg),
        font = beautiful.sans .. " Semibold 16",
        align = 'center',
        valign = 'center',
        widget = wibox.widget.textbox,
      },
      top = 10,
      widget = wibox.container.margin
    },
    spacing = 10,
    layout = wibox.layout.fixed.vertical
  },
  margins = dpi(10),
  widget = wibox.container.margin
}
awful.placement.centered(
  promptbox
)
