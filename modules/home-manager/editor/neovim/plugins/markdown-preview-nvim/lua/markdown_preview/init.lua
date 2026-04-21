local M = {}
local state = {
  processes = {},
}

local defaults = {
  command = { "gh-gfm-preview" },
  keymap = "<Leader>P",
  notify = {
    title = "Markdown Preview",
    level = vim.log.levels.ERROR,
  },
}

M.config = vim.deepcopy(defaults)

function M.stop_preview(bufnr)
  bufnr = bufnr or 0

  local process = state.processes[bufnr]
  if not process then
    return
  end

  pcall(process.kill, process, "sigterm")
  pcall(process.wait, process, 500)
  state.processes[bufnr] = nil
end

function M.preview_buffer(bufnr)
  bufnr = bufnr or 0

  local file = vim.api.nvim_buf_get_name(bufnr)
  if file == "" then
    vim.notify(
      "Save the buffer before starting preview.",
      vim.log.levels.WARN,
      { title = M.config.notify.title }
    )
    return
  end

  M.stop_preview(bufnr)

  local command = vim.deepcopy(M.config.command)
  table.insert(command, file)

  local process = vim.system(command, {}, function(out)
    vim.schedule(function()
      state.processes[bufnr] = nil

      if out.code == 0 or out.signal == 15 then
        return
      end

      vim.notify(
        ("Preview exited with code %d."):format(out.code),
        M.config.notify.level,
        { title = M.config.notify.title }
      )
    end)
  end)

  state.processes[bufnr] = process
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", {}, defaults, opts or {})

  local group = vim.api.nvim_create_augroup("markdown_preview", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = "markdown",
    callback = function(ev)
      if vim.b[ev.buf].markdown_preview_attached then
        return
      end
      vim.b[ev.buf].markdown_preview_attached = true

      vim.keymap.set("n", M.config.keymap, function()
        M.preview_buffer(ev.buf)
      end, {
        buffer = ev.buf,
        desc = "Markdown preview",
      })

      vim.api.nvim_create_autocmd({ "BufDelete", "BufUnload" }, {
        group = group,
        buffer = ev.buf,
        once = true,
        callback = function()
          M.stop_preview(ev.buf)
        end,
      })
    end,
  })
end

return M
