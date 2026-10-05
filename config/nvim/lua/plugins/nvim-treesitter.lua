return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = { "c", "cpp", "lua", "py", "latex", "bibtex", "bash" },
                callback = function()
                    vim.treesitter.start()
                end,
            })
        end,
    },
}
