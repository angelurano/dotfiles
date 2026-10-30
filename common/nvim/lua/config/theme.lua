local M = {}

M.state_file = vim.fn.stdpath("state") .. "/colorscheme"

local function find_theme_file(name)
  local rtp = vim.o.runtimepath
  if package.loaded.lazy then
    rtp = rtp .. "," .. table.concat(require("lazy.core.util").get_unloaded_rtp(""), ",")
  end
  local files = vim.fn.globpath(rtp, "colors/" .. name .. ".lua", false, true)
  if #files > 0 then
    return files[1]
  end
  files = vim.fn.globpath(rtp, "colors/" .. name .. ".vim", false, true)
  if #files > 0 then
    return files[1]
  end
  return nil
end

M.curated_themes = {
  {
    text = "gruvbox (dark - transparent)",
    colorscheme = "gruvbox",
    background = "dark",
    transparent = true,
  },
  {
    text = "gruvbox (dark)",
    colorscheme = "gruvbox",
    background = "dark",
    transparent = false,
  },
  {
    text = "gruvbox (light)",
    colorscheme = "gruvbox",
    background = "light",
    transparent = false,
  },
  {
    text = "retrobox (dark)",
    colorscheme = "retrobox",
    background = "dark",
    transparent = false,
  },
  {
    text = "retrobox (light)",
    colorscheme = "retrobox",
    background = "light",
    transparent = false,
  },
  {
    text = "ayu_dobri",
    colorscheme = "ayu_dobri",
    background = "dark",
    transparent = true,
  },
}

function M.apply(item)
  if not item or not item.colorscheme then
    return
  end

  if item.colorscheme == "gruvbox" then
    local ok, gruvbox = pcall(require, "gruvbox")
    if ok then
      gruvbox.setup({
        contrast = "hard",
        transparent_mode = item.transparent == true,
        italic = {
          strings = false,
          emphasis = true,
          comments = true,
          operators = false,
          folds = true,
        },
      })
    end
  end

  vim.o.background = item.background or "dark"
  pcall(vim.cmd.colorscheme, item.colorscheme)
end

function M.get_current()
  local ok, gruvbox = pcall(require, "gruvbox")
  local is_trans = ok and gruvbox.config and gruvbox.config.transparent_mode == true
  return {
    colorscheme = vim.g.colors_name or "retrobox",
    background = vim.o.background or "dark",
    transparent = is_trans or false,
  }
end

function M.load_saved()
  local f = io.open(M.state_file, "r")
  if not f then
    return { colorscheme = "retrobox", background = "dark", transparent = false }
  end
  local content = f:read("*a")
  f:close()
  if not content or #content == 0 then
    return { colorscheme = "retrobox", background = "dark", transparent = false }
  end

  local ok, data = pcall(vim.json.decode, content)
  if ok and type(data) == "table" and data.colorscheme then
    return {
      text = data.text or data.colorscheme,
      colorscheme = data.colorscheme,
      background = data.background or "dark",
      transparent = data.transparent == true,
    }
  end

  -- Fallback for legacy plain text format (e.g. "retrobox" or "gruvbox")
  local raw = vim.trim(content)
  if #raw > 0 then
    return {
      text = raw,
      colorscheme = raw,
      background = "dark",
      transparent = false,
    }
  end

  return { colorscheme = "retrobox", background = "dark", transparent = false }
end

function M.save(item)
  local f = io.open(M.state_file, "w")
  if f then
    local payload = {
      text = item.text,
      colorscheme = item.colorscheme,
      background = item.background or "dark",
      transparent = item.transparent == true,
    }
    f:write(vim.json.encode(payload))
    f:close()
  end
end

function M.get_all_picker_items()
  local items = {}
  local seen = {}

  for _, t in ipairs(M.curated_themes) do
    local entry = vim.deepcopy(t)
    entry.file = find_theme_file(t.colorscheme)
    items[#items + 1] = entry
    seen[t.colorscheme] = true
  end
  seen["README"] = true

  local rtp = vim.o.runtimepath
  if package.loaded.lazy then
    rtp = rtp .. "," .. table.concat(require("lazy.core.util").get_unloaded_rtp(""), ",")
  end
  local files = vim.fn.globpath(rtp, "colors/*", false, true)
  for _, file in ipairs(files) do
    local name = vim.fn.fnamemodify(file, ":t:r")
    local ext = vim.fn.fnamemodify(file, ":e")
    if (ext == "vim" or ext == "lua") and not seen[name] then
      seen[name] = true
      items[#items + 1] = {
        text = name,
        colorscheme = name,
        background = "dark",
        transparent = false,
        file = file,
      }
    end
  end

  return items
end

return M
