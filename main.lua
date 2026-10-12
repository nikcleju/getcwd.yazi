local function setup()
	ps.sub_remote("get-active-cwd", function(body)
		if type(body) ~= "table" then
			return
		end

		local client_id = body.client_id
		if type(client_id) ~= "number" or client_id <= 0 or client_id % 1 ~= 0 then
			return
		end

		ps.pub_to(client_id, "return-active-cwd", {
			cwd = tostring(cx.active.current.cwd),
		})
	end)
end

return { setup = setup }
