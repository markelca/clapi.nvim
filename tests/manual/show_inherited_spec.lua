local parser = require("clapi.parser")
local lsp = require("clapi.lsp")

-- Mock functions to avoid actual LSP call dependency
local old_get_file = lsp.get_file_from_position
lsp.get_file_from_position = function()
  return "/home/markel/estudio/lua/clapi.nvim/tests/clapi/functional/resources/code/java/example/src/com/example/shared/AggregateRoot.java"
end

-- This test verifies that the show_inherited option works correctly
local function test_show_inherited_option()
  -- Test with default (show_inherited = true)
  local course_file = "/home/markel/estudio/lua/clapi.nvim/tests/clapi/functional/resources/code/java/example/src/com/example/course/Course.java"
  local results_with_inherited = parser.parse_file({ filename = course_file })
  
  -- Results should contain items from both Course.java and AggregateRoot.java
  local found_course_method = false
  local found_aggregate_method = false
  
  for _, item in ipairs(results_with_inherited) do
    if item.name == "getTitle" then
      found_course_method = true
    elseif item.name == "getId" then
      found_aggregate_method = true
    end
  end
  
  print("Test with show_inherited = true (default):")
  print("Found Course.getTitle: " .. tostring(found_course_method))
  print("Found AggregateRoot.getId: " .. tostring(found_aggregate_method))
  print("")
  
  -- Test with show_inherited = false
  local results_without_inherited = parser.parse_file({ 
    filename = course_file,
    show_inherited = false
  })
  
  -- Results should only contain items from Course.java
  found_course_method = false
  found_aggregate_method = false
  
  for _, item in ipairs(results_without_inherited) do
    if item.name == "getTitle" then
      found_course_method = true
    elseif item.name == "getId" then
      found_aggregate_method = true
    end
  end
  
  print("Test with show_inherited = false:")
  print("Found Course.getTitle: " .. tostring(found_course_method))
  print("Found AggregateRoot.getId: " .. tostring(found_aggregate_method))
  print("")
  
  -- Restore original function
  lsp.get_file_from_position = old_get_file
  
  return (found_course_method and found_aggregate_method) ~= (found_course_method and not found_aggregate_method)
end

print("\n---------- Testing show_inherited option ----------")
local success = test_show_inherited_option()
print("Test " .. (success and "PASSED" or "FAILED"))
print("---------------------------------------------------\n")

return success