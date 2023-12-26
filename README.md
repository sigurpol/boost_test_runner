## boost_test_runner

The purpose of this neovim plugin is to execute or debug Boost unit tests and show the results in a _quickfix_ window.

It assumes that the project is constructed using `CMake` and that the
`BoostTest` module is used to build the unit tests. Additionally, it assumes
that the test file is situated in a subdirectory of the project's root
directory, along with a `CMakelists.txt` file at the same level.
This `CMakelists.txt` file should include a `add_test` command from which we can
obtain the test suite name.

It depends on the following plugins:
- `tpope/vim-dispatch`
- `nvim-lua/plenary.nvim`
- `mfussenegger/nvim-dap` (only if you are interested in debugging via `BoostTestDebug`)

By default, it assumes that the build directory is `<root of the project>/build`.
This can be configured via the global variable
`boost_test_runner_build_directory`.
The build directory can also be changed via `BoostSetBuildDirectory` command.

### Debugging via `nvim-dap`

In order to debug the unit test nearest to the current position, `nvim-dap`
needs to be properly configured in your `init.lua` file (or equivalent).

An example configuration is the following:
```lua
-- Dap setup
require("dap").adapters.lldb = {
  type = "executable",
  command = "/opt/homebrew/opt/llvm/bin/lldb-vscode", -- adjust as needed
  name = "lldb",
}
require("dap").configurations.cpp = {
  name = "Launch lldb",
  type = "lldb", -- matches the adapter
  request = "launch", -- could also attach to a currently running process
  program = function()
    return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
  end,
  cwd = "${workspaceFolder}",
  stopOnEntry = false,
  args = {},
  runInTerminal = false,
}
```

In the example above, `lldb-vscode` must be installed.
E.g. on `macOS` you can install it via `homebrew`:
```bash
brew install llvm
```

Once debugging is configured in your neovim setup, run `BoostTestDebug` to
debug the unit test nearest to the current position.

`boost_test_runner` reuses neovim's `DAP` configuration (as shown above) and it
just overwrites `dap.configurations.cpp.program` with the name of the
executable of the test suite.


### Installation

Use your favorite plugin manager to install the plugin. For example, in LazyVim:
```lua
{
    "sigurpol/boost_test_runner",
    lazy = false,
    dependencies = { "tpope/vim-dispatch", "nvim-lua/plenary.nvim", 'mfussenegger/nvim-dap' },
    config = function()
      -- Set the default build path relative to the project's root directory
      vim.g.boost_test_runner_build_directory = "build"
      vim.cmd([[autocmd FileType cpp nnoremap <buffer> <F5> :lua require('boost_test_runner').boost_test_file()<CR>]])
      vim.cmd(
        [[autocmd FileType cpp nnoremap <buffer> <F6> :lua require('boost_test_runner').boost_test_nearest()<CR>]]
      )
    end,
  }
```

### Supported commands

- `BoostTestFile`: Run the unit tests in the current file.
- `BoostTestNearest`: Run the unit test nearest to the cursor.
- `BoostTestSuite`: Run all the unit tests of the suite the current file
belongs to.
- `BoostTestBuild`: build the test suite the current file belongs to
- `BoostTestDebug`: Run the unit test nearest the current position in debug mode
via `nvim-dap`.
  - Before running the command, set a breakpoint in the test you want to debug
  (e.g. via `DapToggleBreakpoint`).
- `BoostSetBuildDirectory`: Manually set the build directory.
