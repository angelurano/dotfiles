-- Colorscheme: Dobri Next -C06- Ayu
-- Ported from VSCode theme config for Neovim

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end
vim.g.colors_name = "ayu_dobri"

local colors = {
  bg = "#0b1015",
  fg = "#97a7c8",
  border = "#2c3e50",
  dark_bg = "#05080a",
  sidebar_bg = "#080b0f",
  widget_bg = "#111820",
  active_selection = "#111820",
  accent = "#ff8d03",
  selection = "#3d4148",
  find_match = "#2c3e50",
  line_hl = "#14344b",
  suggest_bg = "#13232e",
  suggest_selected = "#14344b",
  hover_bg = "#14344b",

  -- Token colors
  comment = "#5c6773",
  variable = "#f5f5f5",
  keyword = "#ff7733",
  operator = "#e7c547",
  tag = "#61afef",
  func = "#ffb454",
  support_var = "#fb467b",
  number = "#ffcc00",
  string = "#b8cc52",
  class = "#61afef",
  regexp = "#95e6cb",
  invalid = "#ff3333",

  -- Git / Diff
  added = "#98c379",
  modified = "#ffcc00",
  deleted = "#ef4444",
}

local hl = function(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- Base Editor Highlights
hl("Normal", { fg = colors.fg, bg = colors.bg })
hl("NormalFloat", { fg = colors.fg, bg = colors.bg })
hl("NormalNC", { fg = colors.fg, bg = colors.bg })
hl("FloatBorder", { fg = colors.border, bg = colors.bg })
hl("FloatTitle", { fg = colors.accent, bg = colors.bg, bold = true })
hl("Cursor", { fg = colors.bg, bg = colors.accent })
hl("CursorLine", { bg = colors.line_hl })
hl("CursorColumn", { bg = colors.line_hl })
hl("ColorColumn", { bg = colors.line_hl })
hl("LineNr", { fg = colors.comment, bg = "NONE" })
hl("CursorLineNr", { fg = colors.accent, bg = "NONE", bold = true })
hl("WinSeparator", { fg = colors.border, bg = colors.bg })
hl("VertSplit", { fg = colors.border, bg = colors.bg })
hl("Folded", { fg = colors.comment, bg = colors.dark_bg })
hl("FoldColumn", { fg = colors.comment, bg = "NONE" })
hl("SignColumn", { bg = "NONE" })
hl("Pmenu", { fg = colors.fg, bg = colors.bg })
hl("PmenuSel", { fg = colors.accent, bg = colors.line_hl, bold = true })
hl("PmenuSbar", { bg = colors.bg })
hl("PmenuThumb", { bg = colors.border })
hl("StatusLine", { fg = colors.fg, bg = colors.bg })
hl("StatusLineNC", { fg = colors.comment, bg = colors.bg })
hl("Search", { fg = colors.fg, bg = colors.find_match })
hl("IncSearch", { fg = colors.bg, bg = colors.accent })
hl("Visual", { bg = colors.selection })
hl("VisualNOS", { bg = colors.selection })
hl("MatchParen", { fg = colors.accent, bg = colors.border, bold = true })
hl("Question", { fg = colors.func })
hl("QuickFixLine", { bg = colors.selection })
hl("SpecialKey", { fg = colors.regexp })
hl("SpellBad", { undercurl = true, sp = colors.deleted })
hl("SpellCap", { undercurl = true, sp = colors.modified })
hl("SpellLocal", { undercurl = true, sp = colors.added })
hl("SpellRare", { undercurl = true, sp = colors.operator })
hl("Title", { fg = colors.string, bold = true })
hl("WarningMsg", { fg = colors.modified })
hl("ErrorMsg", { fg = colors.invalid })
hl("Directory", { fg = colors.func })
hl("NonText", { fg = colors.border })
hl("Whitespace", { fg = colors.border })
hl("Conceal", { fg = colors.comment })

-- Syntax Highlights
hl("Comment", { fg = colors.comment })
hl("Constant", { fg = colors.number })
hl("String", { fg = colors.string })
hl("Character", { fg = colors.number })
hl("Number", { fg = colors.number })
hl("Boolean", { fg = colors.number })
hl("Float", { fg = colors.number })
hl("Identifier", { fg = colors.variable })
hl("Function", { fg = colors.func })
hl("Statement", { fg = colors.keyword })
hl("Conditional", { fg = colors.keyword })
hl("Repeat", { fg = colors.keyword })
hl("Label", { fg = colors.keyword })
hl("Operator", { fg = colors.operator })
hl("Keyword", { fg = colors.keyword })
hl("Exception", { fg = colors.keyword })
hl("PreProc", { fg = colors.keyword })
hl("Include", { fg = colors.keyword })
hl("Define", { fg = colors.keyword })
hl("Macro", { fg = colors.keyword })
hl("PreCondit", { fg = colors.keyword })
hl("Type", { fg = colors.class })
hl("StorageClass", { fg = colors.keyword })
hl("Structure", { fg = colors.keyword })
hl("Typedef", { fg = colors.class })
hl("Special", { fg = colors.operator })
hl("SpecialChar", { fg = colors.regexp })
hl("Tag", { fg = colors.tag })
hl("Delimiter", { fg = colors.fg })
hl("SpecialComment", { fg = colors.comment })
hl("Debug", { fg = colors.invalid })
hl("Underlined", { underline = true })
hl("Bold", { bold = true })
hl("Italic", { italic = true })
hl("Ignore", { fg = colors.bg })
hl("Error", { fg = colors.invalid, bg = colors.dark_bg })
hl("Todo", { fg = colors.accent, bg = colors.dark_bg, bold = true })

-- TreeSitter Highlights
hl("@comment", { link = "Comment" })
hl("@keyword", { link = "Keyword" })
hl("@keyword.function", { link = "Keyword" })
hl("@keyword.operator", { link = "Operator" })
hl("@keyword.return", { link = "Keyword" })
hl("@string", { link = "String" })
hl("@string.regex", { fg = colors.regexp })
hl("@string.escape", { fg = colors.regexp })
hl("@character", { link = "Character" })
hl("@number", { link = "Number" })
hl("@boolean", { link = "Boolean" })
hl("@float", { link = "Float" })
hl("@function", { link = "Function" })
hl("@function.call", { link = "Function" })
hl("@function.builtin", { fg = colors.func, italic = true })
hl("@function.macro", { link = "Macro" })
hl("@parameter", { fg = colors.number })
hl("@method", { link = "Function" })
hl("@method.call", { link = "Function" })
hl("@field", { fg = colors.variable })
hl("@property", { fg = colors.variable })
hl("@constructor", { fg = colors.class })
hl("@variable", { fg = colors.variable })
hl("@variable.builtin", { fg = colors.class, italic = true })
hl("@variable.parameter", { fg = colors.number })
hl("@constant", { fg = colors.number })
hl("@constant.builtin", { fg = colors.number })
hl("@constant.macro", { fg = colors.number })
hl("@type", { link = "Type" })
hl("@type.builtin", { link = "Type" })
hl("@type.definition", { link = "Typedef" })
hl("@tag", { fg = colors.tag })
hl("@tag.attribute", { fg = colors.keyword })
hl("@tag.delimiter", { fg = colors.tag })
hl("@operator", { link = "Operator" })
hl("@punctuation.delimiter", { fg = colors.fg })
hl("@punctuation.bracket", { fg = colors.fg })
hl("@punctuation.special", { fg = colors.operator })

-- LSP Semantic Tokens
hl("@lsp.type.class", { link = "Type" })
hl("@lsp.type.decorator", { fg = colors.number, italic = true })
hl("@lsp.type.enum", { link = "Type" })
hl("@lsp.type.enumMember", { link = "Constant" })
hl("@lsp.type.function", { link = "Function" })
hl("@lsp.type.interface", { link = "Type" })
hl("@lsp.type.member", { fg = colors.variable })
hl("@lsp.type.method", { link = "Function" })
hl("@lsp.type.namespace", { fg = colors.class })
hl("@lsp.type.parameter", { fg = colors.number })
hl("@lsp.type.property", { fg = colors.variable })
hl("@lsp.type.struct", { link = "Type" })
hl("@lsp.type.type", { link = "Type" })
hl("@lsp.type.variable", { fg = colors.variable })

-- Diagnostics
hl("DiagnosticError", { fg = colors.deleted })
hl("DiagnosticWarn", { fg = colors.modified })
hl("DiagnosticInfo", { fg = colors.class })
hl("DiagnosticHint", { fg = colors.comment })
hl("DiagnosticUnderlineError", { undercurl = true, sp = colors.deleted })
hl("DiagnosticUnderlineWarn", { undercurl = true, sp = colors.modified })
hl("DiagnosticUnderlineInfo", { undercurl = true, sp = colors.class })
hl("DiagnosticUnderlineHint", { undercurl = true, sp = colors.comment })

-- Git Signs / Diff
hl("DiffAdd", { fg = colors.added, bg = "#19221f" })
hl("DiffChange", { fg = colors.modified, bg = "#242213" })
hl("DiffDelete", { fg = colors.deleted, bg = "#221519" })
hl("DiffText", { fg = "#ffffff", bg = "#1f4a7d" })
hl("GitSignsAdd", { fg = colors.added })
hl("GitSignsChange", { fg = colors.modified })
hl("GitSignsDelete", { fg = colors.deleted })
hl("GitSignsUntracked", { fg = colors.class })
hl("GitSignsAddStaged", { fg = "#6f9b5a" })
hl("GitSignsChangeStaged", { fg = "#cca028" })
hl("GitSignsDeleteStaged", { fg = "#c93b3b" })
hl("GitSignsTopdeleteStaged", { fg = "#c93b3b" })
hl("GitSignsChangedeleteStaged", { fg = "#cca028" })

-- Telescope
hl("TelescopeNormal", { fg = colors.fg, bg = colors.bg })
hl("TelescopeBorder", { fg = colors.border, bg = colors.bg })
hl("TelescopePromptNormal", { fg = colors.variable, bg = colors.bg })
hl("TelescopePromptBorder", { fg = colors.accent, bg = colors.bg })
hl("TelescopePromptTitle", { fg = colors.accent, bg = colors.bg, bold = true })
hl("TelescopeSelection", { fg = colors.accent, bg = colors.line_hl, bold = true })
hl("TelescopeSelectionCaret", { fg = colors.accent, bg = colors.line_hl })
hl("TelescopeMatching", { fg = colors.number, bold = true })

-- Snacks
hl("SnacksIndent", { fg = colors.border })
hl("SnacksIndentScope", { fg = colors.accent, nocombine = true })
hl("SnacksPicker", { fg = colors.fg, bg = colors.bg })
hl("SnacksPickerBorder", { fg = colors.border, bg = colors.bg })
hl("SnacksPickerNormal", { fg = colors.fg, bg = colors.bg })
hl("SnacksPickerBox", { fg = colors.border, bg = colors.bg })

hl("SnacksPickerInput", { fg = colors.fg, bg = colors.bg })
hl("SnacksPickerInputNormal", { fg = colors.fg, bg = colors.bg })
hl("SnacksPickerInputBorder", { fg = colors.accent, bg = colors.bg })
hl("SnacksPickerInputSearch", { fg = colors.variable })
hl("SnacksPickerPrompt", { fg = colors.accent, bold = true })
hl("SnacksPickerSpinner", { fg = colors.accent })
hl("SnacksPickerTotals", { fg = colors.comment })

hl("SnacksPickerList", { fg = colors.fg, bg = colors.bg })
hl("SnacksPickerListNormal", { fg = colors.fg, bg = colors.bg })
hl("SnacksPickerListBorder", { fg = colors.border, bg = colors.bg })
hl("SnacksPickerListCursorLine", { fg = colors.accent, bg = colors.line_hl, bold = true })

hl("SnacksPickerPreview", { fg = colors.fg, bg = colors.bg })
hl("SnacksPickerPreviewNormal", { fg = colors.fg, bg = colors.bg })
hl("SnacksPickerPreviewBorder", { fg = colors.border, bg = colors.bg })
hl("SnacksPickerPreviewCursorLine", { bg = colors.line_hl })

hl("SnacksPickerSearch", { fg = colors.fg, bg = colors.find_match })
hl("SnacksPickerSelected", { fg = colors.accent, bold = true })
hl("SnacksPickerUnselected", { fg = colors.comment })

hl("SnacksPickerDir", { fg = colors.func })
hl("SnacksPickerFile", { fg = colors.variable })
hl("SnacksPickerMatch", { fg = colors.accent, bold = true })

hl("SnacksPickerGitStatusAdded", { fg = colors.added })
hl("SnacksPickerGitStatusModified", { fg = colors.modified })
hl("SnacksPickerGitStatusDeleted", { fg = colors.deleted })
hl("SnacksPickerGitStatusRenamed", { fg = colors.class })
hl("SnacksPickerGitStatusCopied", { fg = colors.class })
hl("SnacksPickerGitStatusUntracked", { fg = colors.class })
hl("SnacksPickerGitStatusStaged", { fg = colors.added })
hl("SnacksPickerGitStatusUnmerged", { fg = colors.modified })

hl("SnacksDashboardHeader", { fg = colors.func })
hl("SnacksDashboardFooter", { fg = colors.comment })
hl("SnacksDashboardDesc", { fg = colors.fg })
hl("SnacksDashboardKey", { fg = colors.accent })
hl("SnacksDashboardIcon", { fg = colors.func })
hl("SnacksDashboardSpecial", { fg = colors.class })

-- Bufferline
hl("BufferLineFill", { bg = colors.dark_bg })
hl("BufferLineBackground", { bg = colors.dark_bg, fg = colors.comment })
hl("BufferLineBufferSelected", { bg = colors.bg, fg = colors.accent, bold = true })
hl("BufferLineBufferVisible", { bg = colors.dark_bg, fg = colors.fg })
hl("BufferLineSeparator", { fg = colors.dark_bg, bg = colors.dark_bg })
hl("BufferLineSeparatorSelected", { fg = colors.bg, bg = colors.bg })
hl("BufferLineSeparatorVisible", { fg = colors.dark_bg, bg = colors.dark_bg })
hl("BufferLineIndicatorSelected", { fg = colors.accent, bg = colors.bg })
hl("BufferLineModified", { fg = colors.modified, bg = colors.dark_bg })
hl("BufferLineModifiedSelected", { fg = colors.modified, bg = colors.bg })

-- Tree / Sidebar Highlights
hl("NvimTreeFolderName", { fg = colors.func })
hl("NvimTreeOpenedFolderName", { fg = colors.func, bold = true })
hl("NvimTreeEmptyFolderName", { fg = colors.comment })
hl("NvimTreeIndentMarker", { fg = colors.border })
hl("NeoTreeDirectoryName", { fg = colors.func })
hl("NeoTreeDirectoryIcon", { fg = colors.func })
hl("NeoTreeFileName", { fg = colors.variable })

-- Markdown Highlights
hl("markdownH1", { fg = colors.string, bold = true })
hl("markdownH2", { fg = colors.string, bold = true })
hl("markdownH3", { fg = colors.string, bold = true })
hl("markdownH4", { fg = colors.string, bold = true })
hl("markdownH5", { fg = colors.string, bold = true })
hl("markdownH6", { fg = colors.string, bold = true })
hl("markdownHeadingDelimiter", { fg = colors.comment })
hl("markdownLinkText", { fg = colors.number, underline = true })
hl("markdownUrl", { fg = colors.support_var, underline = true })
hl("markdownCode", { fg = colors.class })
hl("markdownCodeBlock", { fg = colors.variable, bg = colors.widget_bg })
hl("markdownItalic", { fg = colors.support_var, italic = true })
hl("markdownBold", { fg = colors.support_var, bold = true })

-- Dropbar
hl("DropBarIconUIIndicator", { fg = colors.comment })
hl("DropBarIconUISeparator", { fg = colors.comment })
hl("DropBarIconUISeparatorMenu", { fg = colors.comment })
hl("DropBarMenuHoverEntry", { bg = colors.line_hl, fg = colors.accent })
hl("DropBarMenuHoverIcon", { reverse = false, bg = colors.line_hl })
hl("DropBarMenuHoverSymbol", { fg = colors.accent, bg = colors.line_hl, bold = false })
hl("DropBarCurrentContext", { bg = colors.line_hl })
hl("DropBarCurrentContextName", { fg = colors.accent, bg = colors.line_hl, bold = false })
