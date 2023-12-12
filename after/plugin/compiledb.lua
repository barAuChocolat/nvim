local function restart_lsp_server()
  for _, client in ipairs(vim.lsp.get_active_clients()) do
    if client.config.name == 'clangd' then -- replace 'clangd' with your LSP server name
      client.stop()
      vim.defer_fn(function() vim.lsp.start_client(client.config) end, 500) -- Restart after 500ms
    end
  end
end

local function generate_compile_commands()
  local cache_dir = vim.fn.stdpath('cache')
  vim.cmd('silent !compiledb make')
  vim.cmd('silent !mv compile_commands.json ' .. cache_dir)
  restart_lsp_server() -- Restart LSP server to pick up new compile_commands.json
end

local function defer_compile_commands()
  vim.defer_fn(generate_compile_commands, 1000) -- Defers for 1 second
end

vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
  pattern = {"*.c", "*.cpp", "*.h"},
  callback = defer_compile_commands,
})