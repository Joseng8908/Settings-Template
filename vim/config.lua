lvim.plugins = {
	{"lervag/vimtex"}
}

lvim.keys.insert_mode["jk"] = "<ESC>"
lvim.keys.insert_mode["kj"] = "<ESC>"

lvim.keys.insert_mode["JK"] = "<ESC>"
lvim.keys.insert_mode["KJ"] = "<ESC>"

lvim.keys.insert_mode["ㅓㅏ"] = "<ESC>"
lvim.keys.insert_mode["ㅏㅓ"] = "<ESC>"


vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = false

lvim.keys.normal_mode["<S-x>"] = ":BufferKill<CR>"

lvim.keys.normal_mode["<S-h>"] = ":bprev<CR>"
lvim.keys.normal_mode["<S-l>"] = ":bnext<CR>"

lvim.builtin.terminal.direction = "horizontal"
lvim.builtin.terminal.size = 10

if lvim.lsp.automatic_servers and lvim.lsp.automatic_servers.tex then
    lvim.lsp.automatic_servers.tex = nil
end
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tex",
  callback = function()
    vim.g.vimtex_compiler_method = 'latexmk'
    vim.g.vimtex_view_method = 'zathura'
  end,
})

-- 배경 투명화 설정 (LunarVim/Neovim)
lvim.autocommands = {
  {
    "ColorScheme",
    {
      pattern = "*",
      callback = function()
        -- 배경색을 담당하는 하이라이트 그룹들을 투명(NONE)으로 설정
        local hl_groups = {
          "Normal", "NormalNC", "Comment", "Constant", "Special", "Identifier",
          "Statement", "PreProc", "Type", "Underlined", "Todo", "String",
          "Function", "Conditional", "Repeat", "Operator", "Structure",
          "LineNr", "NonText", "SignColumn", "CursorLine", "CursorLineNr",
          "StatusLine", "StatusLineNC", "EndOfBuffer",
		  "NvimTreeNormal", "NvimTreeNormalNC", "NvimTreeStatusLine", "NvimTreeStatusLineNC",
  		  "NvimTreeWindowPicker", "NvimTreeEndOfBuffer", "NvimTreeVertSplit"
        }
        for _, group in ipairs(hl_groups) do
          vim.api.nvim_set_hl(0, group, { bg = "none", ctermbg = "none" })
        end
      end,
    },
  },
}
