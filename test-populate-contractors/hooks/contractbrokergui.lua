local function make_fine_text(text)
	local x, y, w, h = text:text_rect()

	text:set_size(w, h)
	text:set_position(math.round(text:x()), math.round(text:y()))
end

local tbl = {
        "bain",
        "the elephant",
        "the continental",
        "vlad",
        "hector",
        "locke",
        "asian man",
        "oruga",
        "Oreztov",
        "crashbreaker",
        "hoppip",
        "fish",
        "mercu",
        "offyerrocker",
        "rex",
        "lofi",
        "almir",
        "matthelzor",
        "mako",
        "shovel man",
        "alan turing (real)",
        "paydayfan1234",
        "beardlibhater",
        "simon",
        "p3dev",
        "luajit itself",
        "a racial slur",
        "the super mario brothers",
        "i am running out of names",
        "balls",
        "test1",
        "test2",
        "sora",
        "joe mama"
}

-- copied function with removal of allow_contact so you get one filter per heist lmfao
function ContractBrokerGui:_setup_filter_contact()
	local contacts = {}
	local filters = {}
        local n = 1
	for index, job_id in ipairs(tweak_data.narrative:get_jobs_index()) do
		local job_tweak = tweak_data.narrative:job_data(job_id)
		local contact = job_tweak.contact
		local contact_tweak = tweak_data.narrative.contacts[contact]

		if contact then
			local allow_contact = true
			--allow_contact = not table.contains(contacts, contact) and (not contact_tweak or not contact_tweak.hidden)
			if allow_contact and n < #tbl then
				table.insert(contacts, tbl[n])
                                n = n + 1
				table.insert(filters, {
					id = contact,
					data = contact_tweak
				})
			end
		end
	end

	--[[table.sort(filters, function (a, b)
		return managers.localization:to_upper_text(a.data.name_id) < managers.localization:to_upper_text(b.data.name_id)
                end)]]--

	local last_y = 0
	local check_new_job_data = {
		filter_key = "contact",
		filter_func = ContractBrokerGui.perform_filter_contact
	}
        local n = 1
	for filter_index, contact in ipairs(filters) do
		check_new_job_data.filter_param = contact
		local text = self:_add_filter_button2(tbl[n], last_y, {
			check_new_job_data = check_new_job_data
		})
		last_y = text:bottom() + 1
                n = n + 1
	end

	self._contact_filter_list = filters

	self:add_filter("contact", ContractBrokerGui.perform_filter_contact)
	self:set_sorting_function(ContractBrokerGui.perform_standard_sort)
end


function ContractBrokerGui:_add_filter_button2(text_id, y, params)
	local filter_button_panel = self._panels.filters:panel({
		h = tweak_data.menu.pd2_small_font_size + (params and params.extra_h or 0)
	})
	local text = filter_button_panel:text({
		name = "text",
		alpha = 1,
		layer = 2,
		text = text_id,
		font = tweak_data.menu.pd2_small_font,
		font_size = tweak_data.menu.pd2_small_font_size,
		color = tweak_data.screen_colors.button_stage_3
	})

	make_fine_text(text)
	text:set_right(filter_button_panel:w() - 4)
	text:set_h(filter_button_panel:h())

	local check_new_job_data = params and params.check_new_job_data or {}

	if check_new_job_data.filter_key and check_new_job_data.filter_func then
		local filter_key = check_new_job_data.filter_key
		local filter_func = check_new_job_data.filter_func
		local filter_param = check_new_job_data.filter_param
		local filtered_jobs = self:filter_job_data(filter_key, filter_func, filter_param)
		local is_new = false

		for _, job_data in ipairs(filtered_jobs) do
			if job_data.is_new then
				is_new = true
			end
		end

		if is_new then
			local new_name = filter_button_panel:text({
				name = "new_name",
				visible = true,
				alpha = 1,
				layer = 1,
				text = managers.localization:to_upper_text("menu_new"),
				font = tweak_data.menu.pd2_small_font,
				font_size = tweak_data.menu.pd2_small_font_size,
				color = Color(255, 105, 254, 59) / 255
			})

			make_fine_text(new_name)
			new_name:set_right(text:left() - 5)
			new_name:set_h(filter_button_panel:h())
		end
	end

	filter_button_panel:set_righttop(self._panels.filters:w() - 4, y)
	table.insert(self._buttons, {
		type = "filter",
		element = text
	})
	table.insert(self._filter_buttons, filter_button_panel)

	return filter_button_panel
end
