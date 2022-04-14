-- TODO overcomment code

-- scroll factor, negative value means 'natural' scrolling (ew)
local scroll_factor = 1
-- n of buttons shown on screen at once
local shown_buttons = 18
-- head (top) of shown filter buttons
local head = 1
-- tail (bottom) of shown filter buttons
local tail

-- TODO table
local previous_panel
local previous_text
local previous_right

function ContractBrokerGui.scroll_broker(self, x, y, n)
        -- check if panel exists, is visible, and is hovered over
        if self._panels and self._panels.filters and self._panels.filters:visible() and self._panels.filters:inside(x, y) then
                local button_count = #self._filter_buttons

                head = math.max(1, math.min(button_count, head + n))
                tail = head + shown_buttons
                local y = 0

                for i, panel in ipairs(self._filter_buttons) do
                        if i == tail and tail ~= button_count and panel:child('text') then
                                if previous_panel and previous_text then
                                        self._filter_buttons[previous_panel]:child('text'):set_text(previous_text)
                                end
                                -- TODO functions n stuff
                                previous_panel = i
                                previous_text = panel:child('text'):text()
                                panel:child('text'):set_text(head ..'-'.. tail .. ' of ' .. button_count)
                                panel:set_righttop(self._panels.filters:w() - 4, y)
                                panel:set_visible(true)

                        elseif i < head or i > tail then
                                panel:set_visible(false)
                                panel:set_righttop(self._panels.filters:w() - 4, 0)
                        else
                                panel:set_righttop(self._panels.filters:w() - 4, y)
                                y = panel:bottom() + 4
                                panel:set_visible(true)
                        end
                end

        end
end

--[[ update initial layout
-- TODO BROKEN
Hooks:PostHook(
        ContractBrokerGui,
        'init',
        'SCB_init',
        function(self, ws, fullscreen_ws, node)
                if self._panels and self._panels.filters then
                        previous_panel = shown_buttons + 1
                        previous_text = self._filter_buttons[previous_panel]:child('text'):text()
                        self._filter_buttons[previous_panel]:child('text'):set_text(1 ..'-'.. shown_buttons .. ' of ' .. #self._filter_buttons)
                end
        end
)
]]--
-- scrolling hooks
Hooks:PostHook(
        ContractBrokerGui,
        'mouse_wheel_up',
        'SCB_mouse_wheel_up',
        function(self, x, y)
                self.scroll_broker(self, x, y, (-1 * scroll_factor))
        end
)

Hooks:PostHook(
        ContractBrokerGui,
        'mouse_wheel_down',
        'SCB_mouse_wheel_down',
        function(self, x, y)
                self.scroll_broker(self, x, y, scroll_factor)
        end
)
