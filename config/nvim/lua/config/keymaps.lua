local term_buf = nil
local term_win = nil
local term_chan = nil

local function shell_pid()
    if not term_chan then
        return nil
    end
    local ok, pid = pcall(vim.fn.jobpid, term_chan)
    return ok and pid or nil
end

-- True if the shell job itself is still alive
local function shell_alive()
    return shell_pid() ~= nil
end

-- True if the shell has a foreground/child program still running
local function program_running()
    local pid = shell_pid()
    if not pid then
        return false
    end
    return #vim.api.nvim_get_proc_children(pid) > 0
end

local function wait_until_idle(timeout_ms)
    return vim.wait(timeout_ms, function()
        return not program_running()
    end, 20)
end

-- Make sure the previous program has exited and Bash is back at its prompt.
-- Escalates: Ctrl-C -> SIGTERM -> SIGKILL.
local function ensure_idle()
    if not program_running() then
        return true
    end

    -- 1. Polite interrupt (same as pressing Ctrl-C)
    vim.api.nvim_chan_send(term_chan, "\x03")
    if wait_until_idle(1000) then
        return true
    end

    -- 2. SIGTERM the children
    local pid = shell_pid()
    for _, child in ipairs(vim.api.nvim_get_proc_children(pid)) do
        vim.uv.kill(child, "sigterm")
    end
    if wait_until_idle(1000) then
        return true
    end

    -- 3. SIGKILL as a last resort
    for _, child in ipairs(vim.api.nvim_get_proc_children(pid)) do
        vim.uv.kill(child, "sigkill")
    end
    return wait_until_idle(1000)
end

-- Wait until the freshly started shell has drawn something (its prompt)
local function wait_for_prompt(buf, timeout_ms)
    vim.wait(timeout_ms, function()
        if not vim.api.nvim_buf_is_valid(buf) then
            return true
        end
        for _, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
            if line:match("%S") then
                return true
            end
        end
        return false
    end, 20)
end

local function reset_terminal()
    if term_chan then
        pcall(vim.fn.jobstop, term_chan)
    end
    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
        pcall(vim.api.nvim_buf_delete, term_buf, { force = true })
    end
    term_buf, term_win, term_chan = nil, nil, nil
end

local function open_terminal()
    vim.cmd("botright 12split")
    vim.cmd("terminal")

    term_buf = vim.api.nvim_get_current_buf()
    term_win = vim.api.nvim_get_current_win()
    term_chan = vim.b.terminal_job_id

    wait_for_prompt(term_buf, 3000)
end

local function run_in_terminal(command)
    -- Drop the terminal if its buffer is gone or the shell has died
    if term_buf and (not vim.api.nvim_buf_is_valid(term_buf) or not shell_alive()) then
        reset_terminal()
    end

    if not term_buf then
        open_terminal()
    elseif not term_win or not vim.api.nvim_win_is_valid(term_win) then
        -- Terminal buffer still exists, but its split was closed
        vim.cmd("botright 12split")
        term_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(term_win, term_buf)
    else
        vim.api.nvim_set_current_win(term_win)
    end

    -- Previous program must be gone before we send anything
    if not ensure_idle() then
        vim.notify("Previous program wouldn't exit; restarting terminal", vim.log.levels.WARN)
        reset_terminal()
        open_terminal()
    end

    -- \x15 (Ctrl-U) clears any half-typed text at the prompt
    vim.api.nvim_chan_send(term_chan, "\x15" .. command .. "\n")
    vim.cmd.startinsert()
end

local function hide_terminal()
    if term_win and vim.api.nvim_win_is_valid(term_win) then
        vim.api.nvim_win_close(term_win, true)
        term_win = nil
    end
end

local function compile_and_run()
    vim.cmd.write()

    local file = vim.api.nvim_buf_get_name(0)
    local ft = vim.bo.filetype

    if file == "" then
        vim.notify("No file to run", vim.log.levels.ERROR)
        return
    end

    -- Stop an old program before rebuilding.
    if term_buf and shell_alive() then
        ensure_idle()
    end

    -- Get rid of an old compiler-error window.
    vim.cmd("silent! cclose")
    vim.fn.setqflist({}, "r")

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

        run_cmd = vim.fn.shellescape(output)

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

        run_cmd = vim.fn.shellescape(output)

    elseif ft == "python" then
        run_cmd = "python3 " .. vim.fn.shellescape(file)

    else
        vim.notify(
            "Unsupported filetype: " .. ft,
            vim.log.levels.ERROR
        )
        return
    end

    if cmd then
        local result = vim.system(cmd, { text = true }):wait()

        if result.code ~= 0 then
            -- Hide runtime terminal while showing compiler errors.
            hide_terminal()

            vim.fn.setqflist({}, " ", {
                title = "Compiler",
                lines = vim.split(result.stderr or "", "\n"),
                efm = vim.o.errorformat,
            })

            vim.cmd("botright copen")
            vim.cmd("resize 10")
            return
        end
    end

    -- Compilation succeeded, so compiler errors are no longer relevant.
    vim.cmd("silent! cclose")

    run_in_terminal(run_cmd)
end

vim.keymap.set("n", "<leader>r", compile_and_run, {
    desc = "Compile and run",
})

local function platformio_root()
    local file = vim.api.nvim_buf_get_name(0)

    local start
    if file ~= "" then
        start = vim.fs.dirname(file)
    else
        start = vim.uv.cwd()
    end

    local ini = vim.fs.find("platformio.ini", {
        path = start,
        upward = true,
    })[1]

    if not ini then
        return nil
    end

    return vim.fs.dirname(ini)
end

local function platformio(command)
    local root = platformio_root()

    if not root then
        vim.notify(
            "Not inside a PlatformIO project",
            vim.log.levels.ERROR
        )
        return
    end

    -- Save all modified project files before building.
    vim.cmd("wall")

    -- Don't leave compiler quickfix windows around.
    vim.cmd("silent! cclose")

    local cmd =
        "cd "
        .. vim.fn.shellescape(root)
        .. " && "
        .. command

    run_in_terminal(cmd)
end

vim.keymap.set("n", "<leader>pb", function()
    platformio("pio run")
end, {
    desc = "PlatformIO build",
})

vim.keymap.set("n", "<leader>pu", function()
    platformio("pio run -t upload")
end, {
    desc = "PlatformIO upload",
})

vim.keymap.set("n", "<leader>pm", function()
    platformio("pio device monitor")
end, {
    desc = "PlatformIO monitor",
})

vim.keymap.set("n", "<leader>pr", function()
    platformio("pio run -t upload && pio device monitor")
end, {
    desc = "PlatformIO upload and monitor",
})

vim.keymap.set("n", "<leader>pc", function()
    platformio("pio run -t clean")
end, {
    desc = "PlatformIO clean",
})
