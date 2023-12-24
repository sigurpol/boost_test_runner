function! Reload() abort
	lua for k in pairs(package.loaded) do if k:match("^boost_test_runner") then package.loaded[k] = nil end end
	lua require("boost_test_runner")
endfunction

nnoremap rr :call Reload()<CR>
