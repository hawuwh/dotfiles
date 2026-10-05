-- Modern City Lights colorscheme for Neovim 0.12+
-- Based on jordanbrauer/citylights.nvim palette and mappings,
-- updated to native nvim_set_hl() and modern Tree-sitter @ captures.

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.g.colors_name = "citylights"
vim.o.background = "dark"
vim.o.termguicolors = true

local c = {
  bg           = "#171d23",
  black        = "#1f252b",
  fg           = "#ffffff",

  grey         = "#41505e",
  steel        = "#718ca1",
  red          = "#e27e8d",
  green        = "#54af83",
  blue         = "#539afc",
  yellow       = "#ebda65",
  aqua         = "#9effff",
  orange       = "#ebbf83",
  sage         = "#008b94",
  teal         = "#70e1e8",
  azure        = "#5ec4ff",
  error_red    = "#f88070",
  success      = "#8bd49c",

  column       = "#242b33",
  pmenu        = "#14232d",
  select_bg    = "#363c43",
}

local hl = vim.api.nvim_set_hl

local function set(group, opts)
  hl(0, group, opts)
end

local function link(group, target)
  hl(0, group, { link = target })
end

-- Core UI
set("Normal",       { fg = c.fg, bg = c.bg })
set("NormalNC",     { fg = c.fg, bg = c.bg })
set("NormalFloat",  { fg = c.fg, bg = c.bg_dark })
set("FloatBorder",  { fg = c.grey, bg = c.bg_dark })
set("EndOfBuffer",  { fg = c.grey, bg = c.bg })
set("NonText",      { fg = c.grey })
set("Whitespace",   { fg = c.grey })
set("SpecialKey",   { fg = c.steel })
set("Directory",    { fg = c.steel })
set("Title",        { fg = c.fg })
set("VertSplit",    { fg = c.grey, bg = c.bg })
set("WinSeparator", { fg = c.grey, bg = c.bg })
set("ColorColumn",  { bg = c.column })
set("CursorLine",   { bg = c.column })
set("CursorColumn", { bg = c.column })
set("CursorLineNr", { fg = c.fg, bold = true })
set("LineNr",       { fg = c.grey })
set("SignColumn",   { bg = c.bg })
set("Folded",       { fg = c.steel, bold = true })
set("FoldColumn",   { fg = c.steel, bg = c.bg })
set("Visual",       { bg = c.select_bg })
set("VisualNOS",    { bg = c.select_bg })
set("MatchParen",   { fg = c.fg, bg = c.select_bg, bold = true })

set("Pmenu",        { fg = c.fg, bg = c.pmenu })
set("PmenuSel",     { fg = c.bg, bg = c.blue })
set("PmenuSbar",    { bg = c.bg_dark })
set("PmenuThumb",   { bg = c.fg })

set("Search",       { fg = c.bg, bg = c.yellow })
set("IncSearch",    { fg = c.bg, bg = c.azure })
set("CurSearch",    { fg = c.bg, bg = c.azure })

set("StatusLine",   { fg = c.fg, bg = c.bg })
set("StatusLineNC", { fg = c.grey, bg = c.bg })

-- Classic syntax
set("Comment",      { fg = c.grey })
set("Constant",     { fg = c.red })
set("String",       { fg = c.blue })
set("Character",    { fg = c.red })
set("Number",       { fg = c.red })
set("Boolean",      { fg = c.red })
set("Float",        { fg = c.red })

set("Identifier",   { fg = c.orange })
set("Function",     { fg = c.teal })

set("Statement",    { fg = c.azure })
set("Conditional",  { fg = c.azure })
set("Repeat",       { fg = c.azure })
set("Label",        { fg = c.azure })
set("Operator",     { fg = c.azure })
set("Keyword",      { fg = c.azure })
set("Exception",    { fg = c.azure })

set("PreProc",      { fg = c.azure })
set("Include",      { fg = c.azure })
set("Define",       { fg = c.sage })
set("Macro",        { fg = c.sage })
set("PreCondit",    { fg = c.sage })

set("Type",         { fg = c.sage })
set("StorageClass", { fg = c.sage })
set("Structure",    { fg = c.sage })
set("Typedef",      { fg = c.sage })

set("Special",        { fg = c.steel })
set("SpecialChar",    { fg = c.red })
set("Tag",            { fg = c.sage })
set("Delimiter",      { fg = c.azure })
set("SpecialComment", { fg = c.grey })
set("Debug",          { fg = c.error_red })
set("Todo",           { fg = c.azure, bold = true })

-- Messages
set("ErrorMsg",   { fg = c.error_red })
set("WarningMsg", { fg = c.yellow })
set("MoreMsg",    { fg = c.fg })
set("Question",   { fg = c.azure })
set("ModeMsg",    { fg = c.fg })

-- Diff
set("DiffAdd",    { fg = c.green })
set("DiffDelete", { fg = c.red })
set("DiffChange", { fg = c.yellow })
set("DiffText",   { fg = c.aqua, bold = true })

-- Diagnostics
set("DiagnosticError", { fg = c.error_red })
set("DiagnosticWarn",  { fg = c.yellow })
set("DiagnosticInfo",  { fg = c.azure })
set("DiagnosticHint",  { fg = c.fg })
set("DiagnosticOk",    { fg = c.success })

set("DiagnosticUnderlineError", { undercurl = true, sp = c.error_red })
set("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.yellow })
set("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.azure })
set("DiagnosticUnderlineHint",  { undercurl = true, sp = c.fg })

-- Modern Tree-sitter captures
link("@comment", "Comment")
link("@comment.documentation", "Comment")

link("@constant", "Constant")
link("@constant.builtin", "Constant")
link("@constant.macro", "Constant")

link("@string", "String")
link("@string.documentation", "String")
link("@string.escape", "SpecialChar")
link("@string.regexp", "SpecialChar")
link("@character", "Character")
link("@number", "Number")
link("@number.float", "Float")
link("@boolean", "Boolean")

-- Match the old City Lights TS mappings:
set("@variable",         { fg = c.steel })
set("@variable.builtin", { fg = c.sage })
set("@variable.parameter", { fg = c.orange })
set("@variable.member",  { fg = c.steel })

-- Bash overrides
set("@string.bash", { fg = c.blue })
set("@variable.bash", { fg = c.orange })
set("shDerefSimple", { fg = c.orange })

set("@function",         { fg = c.teal })
set("@function.builtin", { fg = c.teal })
set("@function.call",    { fg = c.teal })
set("@function.method",  { fg = c.teal })
set("@function.method.call", { fg = c.teal })
set("@function.macro",   { fg = c.teal })
set("@constructor",      { fg = c.steel })

set("@keyword",          { fg = c.azure })
set("@keyword.coroutine",{ fg = c.azure })
set("@keyword.function", { fg = c.sage })
set("@keyword.operator", { fg = c.azure })
set("@keyword.return",   { fg = c.azure })
set("@keyword.import",   { fg = c.azure })
set("@keyword.conditional", { fg = c.azure })
set("@keyword.repeat",   { fg = c.azure })
set("@keyword.exception",{ fg = c.azure })

set("@operator",         { fg = c.azure })
set("@punctuation.bracket",   { fg = c.steel })
set("@punctuation.delimiter", { fg = c.azure })
set("@punctuation.special",   { fg = c.steel })

set("@type",             { fg = c.sage })
set("@type.builtin",     { fg = c.sage })
set("@type.definition",  { fg = c.sage })
set("@attribute",        { fg = c.sage })
set("@property",         { fg = c.steel })
set("@label",            { fg = c.azure })
set("@tag",              { fg = c.sage })
set("@tag.attribute",    { fg = c.aqua })
set("@tag.delimiter",    { fg = c.steel })

-- Markup
set("@markup.heading",      { fg = c.azure, bold = true })
set("@markup.strong",       { fg = c.fg, bold = true })
set("@markup.italic",       { fg = c.fg, italic = true })
set("@markup.link",         { fg = c.blue, underline = true })
set("@markup.link.url",     { fg = c.blue, underline = true })
set("@markup.raw",          { fg = c.blue })
set("@markup.list",         { fg = c.azure })

-- LSP semantic tokens: keep them aligned with Tree-sitter/classic syntax
link("@lsp.type.comment", "@comment")
link("@lsp.type.string", "@string")
link("@lsp.type.number", "@number")
link("@lsp.type.function", "@function")
link("@lsp.type.method", "@function.method")
link("@lsp.type.parameter", "@variable.parameter")
link("@lsp.type.variable", "@variable")
link("@lsp.type.property", "@property")
link("@lsp.type.type", "@type")
link("@lsp.type.class", "@type")
link("@lsp.type.interface", "@type")
link("@lsp.type.enum", "@type")
link("@lsp.type.enumMember", "@constant")
link("@lsp.type.keyword", "@keyword")
link("@lsp.type.macro", "@function.macro")
link("@lsp.type.operator", "@operator")
