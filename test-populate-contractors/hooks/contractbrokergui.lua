-- copied function with removal of allow_contact so you get one filter per heist lmfao
function ContractBrokerGui:_setup_filter_contact()
	local contacts = {}
	local filters = {}

	for index, job_id in ipairs(tweak_data.narrative:get_jobs_index()) do
		local job_tweak = tweak_data.narrative:job_data(job_id)
		local contact = job_tweak.contact
		local contact_tweak = tweak_data.narrative.contacts[contact]

		if contact then
			local allow_contact = true
			--allow_contact = not table.contains(contacts, contact) and (not contact_tweak or not contact_tweak.hidden)
			if allow_contact then
				table.insert(contacts, contact)
				table.insert(filters, {
					id = contact,
					data = contact_tweak
				})
			end
		end
	end

	table.sort(filters, function (a, b)
		return managers.localization:to_upper_text(a.data.name_id) < managers.localization:to_upper_text(b.data.name_id)
	end)

	local last_y = 0
	local check_new_job_data = {
		filter_key = "contact",
		filter_func = ContractBrokerGui.perform_filter_contact
	}

	for filter_index, contact in ipairs(filters) do
		check_new_job_data.filter_param = contact
		local text = self:_add_filter_button(contact.data.name_id, last_y, {
			check_new_job_data = check_new_job_data
		})
		last_y = text:bottom() + 1
	end

	self._contact_filter_list = filters

	self:add_filter("contact", ContractBrokerGui.perform_filter_contact)
	self:set_sorting_function(ContractBrokerGui.perform_standard_sort)
end
