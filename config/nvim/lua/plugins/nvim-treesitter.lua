return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",

        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                callback = function(args)
                    local ft = vim.bo[args.buf].filetype
                    local lang = vim.treesitter.language.get_lang(ft)

                    if vim.treesitter.language.add(lang) then
                        vim.treesitter.start(args.buf, lang)
                    end
                end,
            })
        end,
    },
}
