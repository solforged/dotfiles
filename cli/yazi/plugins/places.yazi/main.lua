return {
  entry = function()
    local output, err = Command("places"):arg({ "list", "--tsv" }):output()
    if not output or not output.status.success then
      return ya.notify({ title = "Places", content = tostring(err or (output and output.stderr)), level = "error", timeout = 5 })
    end
    local places = {}
    for line in output.stdout:gmatch("[^\n]+") do
      local name, path, description, exists = line:match("^([^\t]+)\t([^\t]+)\t([^\t]+)\t([01])$")
      if name then
        places[#places + 1] = { name = name, path = path, description = description, exists = exists == "1" }
      end
    end
    local cands = {}
    for _, place in ipairs(places) do
      local keys = {}
      for key in place.name:gmatch(".") do keys[#keys + 1] = key end
      cands[#cands + 1] = { on = keys, desc = place.description .. (place.exists and "" or " [missing]") }
    end
    local selected = ya.which({ cands = cands })
    if selected then
      local place = places[selected]
      if place.exists then
        ya.emit("cd", { place.path })
      else
        ya.notify({ title = "Places", content = "Directory does not exist: " .. place.path, level = "warn", timeout = 5 })
      end
    end
  end,
}
