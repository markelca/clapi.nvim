-- local x = vim.lsp.buf_request_sync(7, "workspace/symbol", {}, 1000)
-- local x = vim.lsp.buf_request_sync(7, "typeHierarchy/supertypes", {}, 1000)

local _request_name_to_capability = {
	["callHierarchy/incomingCalls"] = { "callHierarchyProvider" },
	["callHierarchy/outgoingCalls"] = { "callHierarchyProvider" },
	["codeAction/resolve"] = { "codeActionProvider", "resolveProvider" },
	["codeLens/resolve"] = { "codeLensProvider", "resolveProvider" },
	["documentLink/resolve"] = { "documentLinkProvider", "resolveProvider" },
	["inlayHint/resolve"] = { "inlayHintProvider", "resolveProvider" },

	["textDocument/codeAction"] = { "codeActionProvider" },
	["textDocument/codeLens"] = { "codeLensProvider" },
	["textDocument/completion"] = { "completionProvider" },
	["textDocument/declaration"] = { "declarationProvider" },

	["textDocument/definition"] = { "definitionProvider" },

	["textDocument/diagnostic"] = { "diagnosticProvider" },
	["textDocument/documentHighlight"] = { "documentHighlightProvider" },
	["textDocument/documentLink"] = { "documentLinkProvider" },
	["textDocument/documentSymbol"] = { "documentSymbolProvider" },
	["textDocument/formatting"] = { "documentFormattingProvider" },
	["textDocument/hover"] = { "hoverProvider" },
	["textDocument/implementation"] = { "implementationProvider" },
	["textDocument/inlayHint"] = { "inlayHintProvider" },
	["textDocument/prepareCallHierarchy"] = { "callHierarchyProvider" },
	["textDocument/prepareRename"] = { "renameProvider", "prepareProvider" },
	["textDocument/prepareTypeHierarchy"] = { "typeHierarchyProvider" },
	["textDocument/rangeFormatting"] = { "documentRangeFormattingProvider" },
	["textDocument/references"] = { "referencesProvider" },
	["textDocument/rename"] = { "renameProvider" },
	["textDocument/semanticTokens/full"] = { "semanticTokensProvider" },
	["textDocument/semanticTokens/full/delta"] = { "semanticTokensProvider" },
	["textDocument/signatureHelp"] = { "signatureHelpProvider" },
	["textDocument/typeDefinition"] = { "typeDefinitionProvider" },
	["typeHierarchy/subtypes"] = { "typeHierarchyProvider" },
	["workspace/executeCommand"] = { "executeCommandProvider" },
	["typeHierarchy/supertypes"] = { "typeHierarchyProvider" },
}
function PrintToTab(text, title)
	-- Set default title if none provided
	title = title or "Output"

	-- Create a new tab
	vim.cmd("tabnew")

	-- Get the current buffer in the new tab
	local buf = vim.api.nvim_get_current_buf()

	-- Set buffer name/title
	vim.api.nvim_buf_set_name(buf, title)

	-- Split the text into lines
	local lines = {}
	for line in string.gmatch(text .. "\n", "(.-)\n") do
		table.insert(lines, line)
	end

	-- Set the content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

	-- Set buffer options for better usability
	vim.api.nvim_buf_set_option(buf, "modifiable", true) -- Allow initial edits if needed
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile") -- Not a real file
	vim.api.nvim_buf_set_option(buf, "swapfile", false) -- No swap file

	-- You can optionally set filetype for syntax highlighting if content is code
	-- vim.api.nvim_buf_set_option(buf, 'filetype', 'lua') -- For Lua code

	-- Return to the first line
	vim.cmd("normal! gg")

	return buf -- Return the buffer id in case you need it
end

-- local x = vim.lsp.buf_request_sync(12, "textDocument/documentSymbol", {
-- 	position = { character = 0, line = 1 },
-- 	textDocument = { uri = "file:///home/markel/estudio/hex/php-ddd-example/src/Mooc/Courses/Domain/Course.php" },
-- }, 1000)
-- local
local x = vim.lsp.buf_request_sync(12, "workspace/symbol", { query = "AggregateRoot", name = "AggregateRoot" }, 1000)
vim.print(x)

-- vim.print(x)
-- PrintToTab(vim.inspect(x), "output")
