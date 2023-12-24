local M = {}

-- The build directory (default to 'build')
M.build_directory = "build"

-- Set the build directory
function M.set_build_directory(dir)
	M.build_directory = dir
end

-- Find the executable associated to the current test file.
-- The logic is the following:
-- 1. Look for CMakelists.txt in the current directory
-- 2. Look for the `add_test(NAME X ...)` line. X is the name of the executable
-- 3. returns the executable name (without the path)
-- If no executable is found, returns nil
function M.find_executable_name()
	local pl = require("plenary")
	local current_dir = vim.fn.expand("%:p:h")
	local cmake_file = pl.Path:new(current_dir .. "/CMakeLists.txt")

	-- Check if CMakeLists.txt exists in the current directory
	if not cmake_file:exists() then
		return nil
	end

	for line in cmake_file:iter() do
		local executable_name = string.match(line, "add_test%(NAME%s+(%S+)")

		if executable_name then
			return executable_name
		end
	end

	return nil
end

-- Find the full path of the executable in the build directory.
-- If no executable is found, returns nil
function M.find_executable()
	local executable_name = M.find_executable_name()
	if not executable_name then
		return nil
	end
	local exe = string.format("find %s -type f -perm -111 -name %s | head -n 1", M.build_directory, executable_name)
	local f = io.popen(exe)
	local l = f:read("*a")
	f:close()
	return l:match("([^\n]+)")
end

-- Build the test suite the current file belongs to.
function M.build_test_suite()
	local executable_name = M.find_executable_name()
	local cmd = string.format("!cmake --build %s --target %s", M.build_directory, executable_name)
	vim.api.nvim_command(cmd)
end

-- Run all the tests in the current suite
function M.boost_test_suite()
	-- build the test suite first
	M.build_test_suite()
	local executable_name = M.find_executable()
	local cmd = string.format("Dispatch %s --color_output=yes", executable_name)
	vim.api.nvim_command(cmd)
end

-- Run all the tests in the current file
function M.boost_test_file()
	-- build the test suite first
	M.build_test_suite()
	local file = vim.fn.expand("%:p") -- Gets the full path of the current file
	local executable_name = M.find_executable()

	-- Open the target file and find all BOOST_AUTO_TEST_SUITE macros
	local lines = {}
	for line in io.lines(file) do
		lines[#lines + 1] = line
	end

	-- Pattern to match `BOOST_AUTO_TEST_SUITE(X)`
	local pattern = "BOOST_AUTO_TEST_SUITE%((.+)%)"
	local matches = {}

	for _, line in pairs(lines) do
		local match = line:match(pattern)
		if match then
			table.insert(matches, match)
		end
	end

	-- Concatenate all tests into X
	local X = table.concat(matches, "/")

	-- Add the --run_test=<X> argument to the command
	local cmd = string.format("Dispatch %s --run_test=%s --color_output=yes", executable_name, X)
	vim.api.nvim_command(cmd)
end

-- Run the test nearest the cursor
function M.boost_test_nearest()
	-- build the test suite first
	M.build_test_suite()
	local file = vim.fn.expand("%:p")
	local executable_name = M.find_executable()

	-- Open the target file and find all BOOST_AUTO_TEST_SUITE, BOOST_AUTO_TEST_CASE and BOOST_FIXTURE_TEST_CASE macros
	local lines = {}
	local lineNumber = 1
	for line in io.lines(file) do
		lines[lineNumber] = line
		lineNumber = lineNumber + 1
	end

	-- Patterns to match `BOOST_AUTO_TEST_SUITE(X)`, `BOOST_AUTO_TEST_CASE(X)` and `BOOST_FIXTURE_TEST_CASE(X)`
	local patternSuite = "BOOST_AUTO_TEST_SUITE%((.+)%)"
	local patternCase = "BOOST_AUTO_TEST_CASE%((.+)%)"
	local patternFixtureCase = "BOOST_FIXTURE_TEST_CASE%((.+)%,.*%)"
	local matchesSuite = {}
	local matchCase = nil
	local matchFixtureCase = nil

	-- Get the current line in the open buffer
	local currentLine = vim.fn.line(".")

	-- Loop over each line in reverse order starting from currentLine
	for i = currentLine, 1, -1 do
		if not matchCase then
			-- Look for the first `BOOST_AUTO_TEST_CASE` above the current line
			matchCase = lines[i]:match(patternCase)
		end
		if not matchFixtureCase then
			-- Look for the first `BOOST_FIXTURE_TEST_CASE` above the current line
			matchFixtureCase = lines[i]:match(patternFixtureCase)
		end
		-- Add each `BOOST_AUTO_TEST_SUITE` we find to the tally
		local match = lines[i]:match(patternSuite)
		if match then
			table.insert(matchesSuite, 1, match) -- Prepend to keep order
		end
	end

	-- Use matchCase or matchFixtureCase depending on which is non-nil
	matchCase = matchCase or matchFixtureCase
	-- Abort if no TEST_CASE or TEST_SUITE found
	if not matchCase or #matchesSuite == 0 then
		print("No TEST_CASE found above current line or no TEST_SUITE found in file.")
		return
	end

	-- Create the run_test string
	local X = table.concat(matchesSuite, "/") .. "/" .. matchCase
	-- Add the --run_test=<X> argument to the command
	local cmd = string.format("Dispatch %s --run_test=%s --color_output=yes", executable_name, X)
	vim.api.nvim_command(cmd)
end

return M
