-- scroll factor, negative value means 'natural' scrolling (ew)
local scroll_factor = 1
-- n of buttons shown on screen at once
local shown_buttons = 18
-- head (top) of shown filter buttons
local head = 1
-- tail (bottom) of shown filter buttons
local tail
-- postition of footer (overidden text / counter at bottom)
local footer_position = 85

-- previous data for overwritten stuff
local previous_data = {
        panel = nil,
        text = nil,
        x = nil,
        w = nil,
        h = nil
}

function ContractBrokerGui.scroll_broker(self, x, y, n, override)
        -- check if panel exists, is visible, and is hovered over
        if (self._panels and self._panels.filters and self._panels.filters:visible() and self._panels.filters:inside(x, y)) or override then
                -- total amount of contractors
                local button_count = #self._filter_buttons

                -- clamp head and tail to total buttons
                head = math.max(1, math.min(button_count, head + n))
                tail = math.min(head + shown_buttons, button_count)

		-- starting position of broker buttons
                local y = 0

		-- iterate over every broker button
                for i, panel in ipairs(self._filter_buttons) do
                        -- test if this will be the last shown entry
                        if i == tail then
                                -- revert overridden text to previous state
                                if previous_data.panel then -- its implied that previous_data.text is already set, no need to check
                                        local text_panel = self._filter_buttons[previous_data.panel]:child('text')
                                        text_panel:set_text(previous_data.text)
                                        text_panel:set_size(previous_data.w, previous_data.h)
                                        text_panel:set_position(previous_data.x, text_panel:y())
                                end

				local text_panel = panel:child('text')
				-- store new previous data for next scroll
				-- there might be wasted cycles here because if this is the last entry we will not be using this data and overwriting the same panel which we never even modified, but it does save lines of code and effort
                                previous_data.panel = i
                                previous_data.text = text_panel:text()
                                previous_data.x = text_panel:x()
                                previous_data.w = text_panel:w()
                                previous_data.h = text_panel:h()

                                -- if this is the last entry in the whole list we want its original text to be shwon
				if tail ~= button_count then
                                        -- set current panel text to "<head> - <tail> of <total>"
					-- ex: "3 - 21 of 36"
                                        text_panel:set_text(head ..'-'.. tail .. ' of ' .. button_count)

					-- positions entire panel where it should be
                                        panel:set_righttop(self._panels.filters:w() - 4, y)

                                        -- reposition text
                                        local _, _, w, h = text_panel:text_rect()
                                        text_panel:set_size(w, h)
                                        text_panel:set_position(footer_position, text_panel:y())

					-- show our panel in case it is hidden
                                        panel:set_visible(true)
                                end

                        -- checks if this panel should not be shown ...
                        elseif i < head or i > tail then
                                -- ... and then hides it!
                                panel:set_visible(false)

                                -- sets position to top (hidden) because it should be hidden
                                panel:set_righttop(self._panels.filters:w() - 4, 0)

                        -- and if this panel meets no other criteria, it means it should be shown
                        else
                                -- so we set its position to below the previous panel
                                panel:set_righttop(self._panels.filters:w() - 4, y)
                                -- and tell the next panel where the bottom of it is
                                y = panel:bottom() + 4
                                -- and shows itself
                                panel:set_visible(true)
                        end
                end

        end
end

-- update initial layout
Hooks:PostHook(
        ContractBrokerGui,
        '_setup_filter_contact',
        'SCB_setup_filter_contact',
        function(self)
                if self._panels and self._panels.filters then
                        self.scroll_broker(self, 0, 0, 0, true)
                end
        end
)


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
