-- TODO menu for this
-- TODO better way of scrolling instead of filters hack
--      actually nvm i like that

-- scroll factor, negative value means 'natural' scrolling (ew)
local scroll_factor = 1
local shown_buttons = 20
local head = 1 -- head (top) of shown filter buttons
local tail -- tail (bottom) of shown filter buttons

function ContractBrokerGui.scroll_broker(self, x, y, n)
        -- check if panel exists, is visible, and is hovered over
        if self._panels and self._panels.filters and self._panels.filters:visible() and self._panels.filters:inside(x, y) then
                head = math.max(1, math.min(#self._filter_buttons, head + n))
                tail = head + shown_buttons
                local y = 0
                for i, panel in ipairs(self._filter_buttons) do
                        if i < head or i > tail then
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
