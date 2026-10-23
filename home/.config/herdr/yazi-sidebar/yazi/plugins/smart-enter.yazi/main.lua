--- @sync entry
-- Enter directories; open files (yazi.toml routes files to an nvim split).
return {
	entry = function()
		local h = cx.active.current.hovered
		ya.emit(h and h.cha.is_dir and "enter" or "open", { hovered = true })
	end,
}
