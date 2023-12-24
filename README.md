## boost_test_runner

The scope of this neovim plugin is to run Boost unit tests and display results
in a `quickfix` window.

It assumes that the project is built with CMake and that the unit tests are built with the `BoostTest` module.

It also assumes that the current test file is located in a subdirectory of the
project root directory with a CMakelists.txt file at the same level containing
a add_test directive from which we can extract the test suite name.

It depends on the following plugins:
- `tpope/vim-dispatch`
- `nvim-lua/plenary.nvim`

### Installation

Use your favorite plugin manager to install the plugin. For example, in LazyVim:
```lua
{
    "sigurpol/boost_test_runner",
    lazy = false,
    dependencies = { "tpope/vim-dispatch", "nvim-lua/plenary.nvim" },
    config = function()
      vim.cmd([[autocmd FileType cpp nnoremap <buffer> <F5> :lua require('boost_test_runner').boost_test_file()<CR>]])
      vim.cmd(
        [[autocmd FileType cpp nnoremap <buffer> <F6> :lua require('boost_test_runner').boost_test_nearest()<CR>]]
      )
    end,
  }
```

### Supported commands

- `BoostTestFile`: Run the unit tests in the current file.
- `BooostTestNearest`: Run the unit test nearest to the cursor.
- `BooostTestSuite`: Run all the unit tests of the suite the current file belongs to.
- `BooostSetBuildDirectory`: Manually set the build directory. The default is <root of the project>/build.
- `BoostTestBuild`: build the test suite the current file belongs to
