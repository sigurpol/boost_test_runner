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

It requires `lldb-vscode` to be installed in order to debug via `BoostTestDebug`.
On `macOS` you can install it via `homebrew`:
```bash
brew install llvm
```

By default, it assumes to find it in `/opt/homebrew/opt/llvm/bin/lldb-vscode`.
This can be configured via the global variable
`boost_test_runner_lldb_vscode_path`.
It can also be changed via `BoostSetLldbVSCodePath` command.

By default, it assumes that the build directory is `<root of the project>/build`.
This can be configured via the global variable
`boost_test_runner_build_directory`.
The build directory can also be changed via `BoostSetBuildDirectory` command.

### Installation

Use your favorite plugin manager to install the plugin. For example, in LazyVim:
```lua
{
    "sigurpol/boost_test_runner",
    lazy = false,
    dependencies = { "tpope/vim-dispatch", "nvim-lua/plenary.nvim", 'mfussenegger/nvim-dap' },
    config = function()
      -- Set the lldb vscode path
      vim.g.boost_test_runner_lldb_vscode_path = "/opt/homebrew/opt/llvm/bin/lldb-vscode"
      -- Set the default build path
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
- `BoostSetLldbVSCodePath`: Set the path to the lldb-vscode executable.
- `BoostSetBuildDirectory`: Manually set the build directory.
