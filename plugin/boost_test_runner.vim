if exists('g:loaded_boost_test_runner') | finish | endif

" Add a command to run the test suite the current file belongs to 
command! -nargs=0 BoostTestSuite lua require("boost_test_runner").boost_test_suite()
" Add a command to run all tests in the current file
command! -nargs=0 BoostTestFile lua require("boost_test_runner").boost_test_file()
" Add a command to run the test nearest to the cursor (above)
command! -nargs=0 BoostTestNearest lua require("boost_test_runner").boost_test_nearest()
" Add a command to build the test suite the current file belongs to
command! -nargs=0 BoostTestBuild lua require("boost_test_runner").build_test_suite()
" Add a command to debug the test at the current line.
command! -nargs=0 BoostTestDebug lua require("boost_test_runner").launch_executable()
" Add a command to set the build directory (default: <root of the project>/build )
command! -nargs=1 BoostSetBuildDirectory lua require("boost_test_runner").set_build_directory(<f-args>)

let s:save_cpo = &cpo
set cpo&vim

let g:loaded_boost_test_runner = 1

if !exists('g:boost_test_runner_build_directory')
  let g:boost_test_runner_build_directory = "build"
endif

let &cpo = s:save_cpo
unlet s:save_cpo
