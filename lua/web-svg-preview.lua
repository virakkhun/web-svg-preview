local M = {}

local lazy_config = require("lazy.core.config")
local lazy_root = lazy_config.options.root
local is_prod = vim.fn.isdirectory(lazy_root .. "/" .. "web-svg-preview") == 1
local local_dir = os.getenv("HOME") .. "/Documents/lib/plugins/web-svg-preview.nvim"
local index_html = is_prod and lazy_root .. "/web-svg-preview/lua/index.html" or local_dir .. "/lua/index.html"

local function readFile(path)
	local file = vim.uv.fs_open(path, "r", 438)
	local stat = vim.uv.fs_fstat(file or 0)
	local content = vim.uv.fs_read(file or 0, stat and stat.size or 0, 0)
	vim.uv.fs_close(file or 0)
	return content
end

local function writeFile(path, content)
	local file = vim.uv.fs_open(path, "w", 438)
	if file == nil then
		return
	end

	vim.uv.fs_write(file, content, 0)
end

local tmpl = [[
<!doctype html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>SVG previewer</title>
    <meta name="tilte" content="SVG previewer" />
    <meta
      name="description"
      content="a simple and easy web app to preview svg"
    />
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }

      html,
      body {
        font-family:
          system-ui,
          -apple-system,
          BlinkMacSystemFont,
          "Segoe UI",
          Roboto,
          Oxygen,
          Ubuntu,
          Cantarell,
          "Open Sans",
          "Helvetica Neue",
          sans-serif;
      }

      body {
        width: 100svw;
        height: 100svh;
        display: flex;
        flex-direction: column;
        justify-content: space-evenly;
        align-items: center;
        background: #181926;
        color: #cad3f5;
      }

      svg {
        width: 100%;
        height: 50svh;
      }
    </style>
  </head>
  <body>
    <h1>SVG previewer</h1>

    <div class="container">
      ###svg###
    </div>

    <footer style="text-align: center">
      <p>made with 💗 web-svg-preview.lua</p>
    </footer>
  </body>
</html>
]]

local function preview_svg_on_web()
	local bufnr = vim.api.nvim_get_current_buf()
	local cur_file_path = vim.api.nvim_buf_get_name(bufnr)
	local svg_content = readFile(cur_file_path)

	if svg_content == nil then
		print("Can't read content of this svg...")
		return
	end

	local new_html = string.gsub(tmpl, "###svg###", svg_content)

	writeFile(index_html, new_html)

	vim.ui.open(index_html)
end

local function setup()
	local is_not_svg = vim.bo.filetype ~= "svg"

	if is_not_svg then
		print("Filetype not support...✨")
		return
	end

	preview_svg_on_web()
end

M.setup = setup

return M
