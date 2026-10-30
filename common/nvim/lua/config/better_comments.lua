local M = {}

-- Highlight groups representing tag colors and styles
local highlights = {
  BetterCommentAlert = { fg = "#FF2D00", bg = "NONE", bold = false, italic = false, underline = false, strikethrough = false },
  BetterCommentQuestion = { fg = "#3498DB", bg = "NONE", bold = false, italic = false, underline = false, strikethrough = false },
  BetterCommentStrike = { fg = "#474747", bg = "NONE", bold = false, italic = false, underline = false, strikethrough = true },
  BetterCommentTodo = { fg = "#FF8C00", bg = "NONE", bold = false, italic = false, underline = false, strikethrough = false },
  BetterCommentHighlight = { fg = "#98C379", bg = "NONE", bold = false, italic = false, underline = false, strikethrough = false },
  BetterCommentParam = { fg = "#B080FF", bg = "NONE", bold = false, italic = false, underline = false, strikethrough = false }, -- Violet for JSDoc/doxygen parameters
  Todo = { fg = "#FF8C00", bg = "NONE", bold = false, italic = false, underline = false, strikethrough = false },               -- Override built-in Todo syntax group
}

-- Map tag strings to highlight groups
local tags = {
  { tag = "!",    hl = "BetterCommentAlert",     case_insensitive = false },
  { tag = "?",    hl = "BetterCommentQuestion",  case_insensitive = false },
  { tag = "//",   hl = "BetterCommentStrike",    case_insensitive = false },
  { tag = "todo", hl = "BetterCommentTodo",      case_insensitive = true },
  { tag = "*",    hl = "BetterCommentHighlight", case_insensitive = false },
  { tag = "@",    hl = "BetterCommentParam",     case_insensitive = false },
}

-- Cache for compiled buffer patterns to avoid re-generating on every cursor/window switch
local pattern_cache = {}

-- Create or restore highlight groups
function M.setup_highlights()
  for hl_name, hl_opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, hl_name, hl_opts)
  end
end

-- Escape special characters for Vim's very magic (\v) regex mode
local function escape_for_very_magic(str)
  if type(str) ~= "string" then
    return ""
  end
  return str:gsub("[\\.*^$()[%]~|?+<>/@{}=]", "\\%0")
end

-- Find block comment continuation character (e.g., '*') from buffer 'comments' setting
local function get_block_continuation(buf)
  local comments = vim.bo[buf].comments
  if not comments or comments == "" then
    return nil
  end

  local parts = vim.split(comments, ",", { plain = true })
  for _, part in ipairs(parts) do
    if part:sub(1, 3) == "mb:" then
      local cont = part:sub(4)
      -- Ensure the character is non-empty and not whitespace
      if cont ~= "" and not cont:match("^%s+$") then
        return cont
      end
    end
  end
  return nil
end

-- Generate regex patterns for a tag based on buffer comment configuration (cached)
local function get_buf_patterns(buf)
  if pattern_cache[buf] then
    return pattern_cache[buf]
  end

  local cs = vim.bo[buf].commentstring
  local main_prefix = "//"

  if cs and cs ~= "" then
    local parts = vim.split(cs, "%s", { plain = true })
    local raw_prefix = vim.trim(parts[1] or "")
    if raw_prefix ~= "" then
      main_prefix = raw_prefix
    end
  end

  local escaped_main = escape_for_very_magic(main_prefix)
  local block_cont = get_block_continuation(buf)

  -- Allow block comments starting with '/*' if '*' is the continuation character
  if block_cont == "*" and main_prefix ~= "/*" and main_prefix ~= "/**" then
    escaped_main = "(" .. escaped_main .. "|/\\*)"
  end

  local buf_patterns = {}

  for _, tag_config in ipairs(tags) do
    local escaped_tag = escape_for_very_magic(tag_config.tag)
    local case_prefix = tag_config.case_insensitive and "\\c" or ""

    -- Pattern 1: Match main or block comment prefix anywhere in the line
    local pattern1 = "\\v" .. case_prefix .. escaped_main .. "\\s*\\zs" .. escaped_tag .. ".*"
    local patterns = { pattern1 }

    if block_cont then
      local escaped_cont = escape_for_very_magic(block_cont)
      -- Pattern 2: Match continuation lines starting with block comment character
      local pattern2 = "\\v" .. case_prefix .. "^\\s*" .. escaped_cont .. "\\s*\\zs" .. escaped_tag .. ".*"
      table.insert(patterns, pattern2)
    end

    buf_patterns[tag_config] = patterns
  end

  pattern_cache[buf] = buf_patterns
  return buf_patterns
end

-- Clear window matches
function M.clear_matches()
  local matches = vim.w.better_comments_matches
  if matches then
    for _, match_id in ipairs(matches) do
      pcall(vim.fn.matchdelete, match_id)
    end
    vim.w.better_comments_matches = nil
  end
end

-- Update matches for the current window and buffer
function M.update_matches(force)
  -- local win = vim.api.nvim_get_current_win()
  local buf = vim.api.nvim_get_current_buf()

  -- Check if matches are already configured for this buffer in this window
  if not force and vim.w.better_comments_buf == buf then
    return
  end

  M.clear_matches()

  -- Verify buffer is valid
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  -- Only apply to normal buffers
  local ok, buftype = pcall(function() return vim.bo[buf].buftype end)
  if not ok or buftype ~= "" then
    return
  end

  local match_ids = {}
  local buf_patterns = get_buf_patterns(buf)

  for tag_config, patterns in pairs(buf_patterns) do
    for _, pattern in ipairs(patterns) do
      -- Match priority 11 to override default comment highlighting
      local ok_add, match_id = pcall(vim.fn.matchadd, tag_config.hl, pattern, 11)
      if ok_add then
        table.insert(match_ids, match_id)
      end
    end
  end

  vim.w.better_comments_matches = match_ids
  vim.w.better_comments_buf = buf
end

-- Initialize the better comments system
function M.setup()
  M.setup_highlights()

  -- Re-apply highlights on ColorScheme change
  vim.api.nvim_create_autocmd("ColorScheme", {
    pattern = "*",
    callback = M.setup_highlights,
  })

  local group = vim.api.nvim_create_augroup("better_comments", { clear = true })

  -- Update matches on window or buffer transitions
  vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter", "BufEnter" }, {
    group = group,
    callback = function()
      M.update_matches()
    end,
  })

  -- Invalidate cache and update when filetype changes
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      pattern_cache[buf] = nil
      M.update_matches(true)
    end,
  })

  -- Update when commentstring changes for a buffer
  vim.api.nvim_create_autocmd("OptionSet", {
    group = group,
    pattern = "commentstring",
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      pattern_cache[buf] = nil
      M.update_matches(true)
    end,
  })

  -- Clear cache when buffer is deleted to prevent memory leaks
  vim.api.nvim_create_autocmd({ "BufWipeout", "BufDelete" }, {
    group = group,
    callback = function(args)
      pattern_cache[args.buf] = nil
    end,
  })
end

return M
