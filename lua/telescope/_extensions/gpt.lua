local has_telescope, _ = pcall(require, 'telescope')
if not has_telescope then
  error('This plugin requires nvim-telescope/telescope.nvim')
end

local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local conf = require('telescope.config').values
local make_entry = require('telescope.make_entry')

local flatten = vim.tbl_flatten

local config = {
  param = '',
}

local function setup(ext_config)
  for k, v in pairs(ext_config) do
    config[k] = v
  end
end

local run = function(opts)
  opts = vim.tbl_deep_extend('force', config, opts or {})
  local command_params = {}
  if opts.param then
    table.insert(command_params, opts.param)
  end
  pickers
    .new(opts, {
      prompt_title = 'GPT',
      finder = finders.new_job(function(prompt)
        if not prompt or prompt == '' then
          return nil
        end
        return flatten({ 'sgpt', command_params, prompt })
      end, make_entry.gen_from_file(opts)),
      previewer = conf.file_previewer(opts),
      sorter = sorters.highlighter_only(opts),
    })
    :find()
end

return require('telescope').register_extension({
  setup = setup,
  exports = {
    gpt = run,
  },
})
