local M = {}

local defaults = {
  thresholds = {
    size = 2 * 1024 * 1024,
    lines = 20000,
    columns = 10000,
    sample = 128,
  },
  notify = {
    enabled = true,
    delay = 150,
    title = "Neovim",
    level = vim.log.levels.INFO,
  },
}

M.config = vim.deepcopy(defaults)

function M.is_large_buffer(bufnr)
  bufnr = bufnr or 0

  local cached = vim.b[bufnr].large_buffer
  if cached ~= nil then
    return cached
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  local stat = name ~= "" and vim.uv.fs_stat(name) or nil
  if stat and stat.size > M.config.thresholds.size then
    vim.b[bufnr].large_buffer = true
    return true
  end

  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if line_count > M.config.thresholds.lines then
    vim.b[bufnr].large_buffer = true
    return true
  end

  local sample = math.min(line_count, M.config.thresholds.sample)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, sample, false)
  for _, line in ipairs(lines) do
    if #line > M.config.thresholds.columns then
      vim.b[bufnr].large_buffer = true
      return true
    end
  end

  vim.b[bufnr].large_buffer = false
  return false
end

function M.notify_large_buffer_mode(bufnr, feature)
  bufnr = bufnr or 0

  if not M.config.notify.enabled then
    return
  end

  local features = vim.b[bufnr].large_buffer_disabled_features or {}
  if feature then
    features[feature] = true
  end
  vim.b[bufnr].large_buffer_disabled_features = features

  if vim.b[bufnr].large_buffer_notify_pending then
    return
  end
  vim.b[bufnr].large_buffer_notify_pending = true

  vim.defer_fn(function()
    if not vim.api.nvim_buf_is_valid(bufnr) then
      return
    end

    vim.b[bufnr].large_buffer_notify_pending = false

    local disabled = {}
    for name in pairs(vim.b[bufnr].large_buffer_disabled_features or {}) do
      table.insert(disabled, name)
    end
    table.sort(disabled)

    local suffix = ""
    if #disabled > 0 then
      suffix = " Disabled: " .. table.concat(disabled, ", ") .. "."
    end

    vim.notify(
      "Large buffer mode enabled for this file." .. suffix,
      M.config.notify.level,
      { title = M.config.notify.title }
    )
  end, M.config.notify.delay)
end

function M.wrap_lsp_config(server_name, opts)
  opts = vim.deepcopy(opts or {})

  local base_config = vim.lsp.config[server_name] or {}
  local base_root_dir = opts.root_dir or base_config.root_dir
  if not base_root_dir then
    return opts
  end

  opts.root_dir = function(bufnr, on_dir)
    if M.is_large_buffer(bufnr) then
      M.notify_large_buffer_mode(bufnr, server_name)
      return
    end

    if type(base_root_dir) == "function" then
      return base_root_dir(bufnr, on_dir)
    end

    on_dir(base_root_dir)
  end

  return opts
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", {}, defaults, opts or {})
end

return M
