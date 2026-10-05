local term_buf = nil
local term_win = nil
local term_chan = nil

local function run_in_terminal(command)
    -- Recreate terminal if it doesn't exist anymore
    if not term_buf or not vim.api.nvim_buf_is_valid(term_buf) then
        vim.cmd("botright 12split")
        vim.cmd("terminal")

        term_buf = vim.api.nvim_get_current_buf()
        term_win = vim.api.nvim_get_current_win()
        term_chan = vim.b.terminal_job_id

    elseif not term_win or not vim.api.nvim_win_is_valid(term_win) then
        -- Terminal buffer still exists, but its split was closed
        vim.cmd("botright 12split")
        term_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(term_win, term_buf)
    else
        vim.api.nvim_set_current_win(term_win)
    end

    vim.api.nvim_chan_send(term_chan, command .. "\n")
    vim.cmd.startinsert()
end

local function compile_and_run()
    vim.cmd.write()

    local file = vim.api.nvim_buf_get_name(0)
    local ft = vim.bo.filetype

    if file == "" then
        vim.notify("No file to run", vim.log.levels.ERROR)
        return
    end

    local output = vim.fn.stdpath("cache") .. "/nvim-run"
    local cmd
    local run_cmd

    if ft == "c" then
        cmd = {
            "gcc",
            "-Wall",
            "-Wextra",
            "-g",
            file,
            "-o",
            output,
        }

        run_cmd = output

    elseif ft == "cpp" then
        cmd = {
            "g++",
            "-std=c++20",
            "-Wall",
            "-Wextra",
            "-g",
            file,
            "-o",
            output,
        }

        run_cmd = output

    elseif ft == "python" then
        run_cmd = "python3 " .. vim.fn.shellescape(file)

    else
        vim.notify("Unsupported filetype: " .. ft, vim.log.levels.ERROR)
        return
    end

    if cmd then
        local result = vim.system(cmd, { text = true }):wait()

        if result.code ~= 0 then
            vim.fn.setqflist({}, " ", {
                title = "Compiler",
                lines = vim.split(result.stderr or "", "\n"),
                efm = vim.o.errorformat,
            })

            vim.cmd.copen()
            return
        end
    end

    run_in_terminal(run_cmd)
end

vim.keymap.set("n", "<leader>r", compile_and_run, {
    desc = "Compile and run",
})
