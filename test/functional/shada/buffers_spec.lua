-- ShaDa buffer list saving/reading support
local helpers = require('test.functional.helpers')(after_each)
local nvim_command, funcs, eq, curbufmeths =
  helpers.command, helpers.funcs, helpers.eq, helpers.curbufmeths

local shada_helpers = require('test.functional.shada.helpers')
local reset, set_additional_cmd, clear =
  shada_helpers.reset, shada_helpers.set_additional_cmd,
  shada_helpers.clear

if helpers.pending_win32(pending) then return end

describe('ShaDa support code', function()
  local testfilename = 'Xtestfile-functional-shada-buffers'
  local testfilename_2 = 'Xtestfile-functional-shada-buffers-2'
  before_each(reset)
  after_each(clear)

  it('is able to dump and restore buffer list', function()
    set_additional_cmd('set shada+=%')
    reset()
    nvim_command('edit ' .. testfilename)
    nvim_command('edit ' .. testfilename_2)
    nvim_command('qall')
    reset()
    eq(3, funcs.bufnr('$'))
    eq('', funcs.bufname(1))
    eq(testfilename, funcs.bufname(2))
    eq(testfilename_2, funcs.bufname(3))
  end)

  it('does not restore buffer list without % in &shada', function()
    set_additional_cmd('set shada+=%')
    reset()
    nvim_command('edit ' .. testfilename)
    nvim_command('edit ' .. testfilename_2)
    set_additional_cmd('')
    nvim_command('qall')
    reset()
    eq(1, funcs.bufnr('$'))
    eq('', funcs.bufname(1))
  end)

  it('does not dump buffer list without % in &shada', function()
    nvim_command('edit ' .. testfilename)
    nvim_command('edit ' .. testfilename_2)
    set_additional_cmd('set shada+=%')
    nvim_command('qall')
    reset()
    eq(1, funcs.bufnr('$'))
    eq('', funcs.bufname(1))
  end)

  it('does not dump unlisted buffer', function()
    set_additional_cmd('set shada+=%')
    reset()
    nvim_command('edit ' .. testfilename)
    nvim_command('edit ' .. testfilename_2)
    curbufmeths.set_option('buflisted', false)
    nvim_command('qall')
    reset()
    eq(2, funcs.bufnr('$'))
    eq('', funcs.bufname(1))
    eq(testfilename, funcs.bufname(2))
  end)

  it('does not dump quickfix buffer', function()
    set_additional_cmd('set shada+=%')
    reset()
    nvim_command('edit ' .. testfilename)
    nvim_command('edit ' .. testfilename_2)
    curbufmeths.set_option('buftype', 'quickfix')
    nvim_command('qall')
    reset()
    eq(2, funcs.bufnr('$'))
    eq('', funcs.bufname(1))
    eq(testfilename, funcs.bufname(2))
  end)

  it('does not dump unnamed buffers', function()
    set_additional_cmd('set shada+=% hidden')
    reset()
    curbufmeths.set_line(0, 'foo')
    nvim_command('enew')
    curbufmeths.set_line(0, 'bar')
    eq(2, funcs.bufnr('$'))
    nvim_command('qall!')
    reset()
    eq(1, funcs.bufnr('$'))
    eq('', funcs.bufname(1))
  end)
end)
