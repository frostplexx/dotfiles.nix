-- Calm AI hints for neovim.
--
-- Every hint here is pull-based (a keymap you press) or peripheral (a dim
-- statusline component), cached on disk, and rendered through channels nvim
-- already has: virt_lines and lualine. All model calls go through `pq`
-- (../pi.nix) and run asynchronously via vim.system, so nothing blocks.
--
--   <leader>gw   why does this line exist?  (git blame -> git show -> pq)
--   <leader>ce   explain the diagnostic on this line
--   :AiGist      toggle the five-word file description in the statusline

local ns = vim.api.nvim_create_namespace("ai_hints")
local cache_dir = vim.fn.stdpath("cache") .. "/ai_hints"
vim.fn.mkdir(cache_dir, "p")

local function cache_get(key)
  local f = io.open(cache_dir .. "/" .. key, "r")
  if not f then return nil end
  local t = f:read("*a")
  f:close()
  return t ~= "" and t or nil
end

local function cache_put(key, text)
  local f = io.open(cache_dir .. "/" .. key, "w")
  if f then
    f:write(text)
    f:close()
  end
end

--- Run `pq <prompt>` with `stdin`, memoised on disk under `key`.
--- `cb(text)` runs on the main loop.
local function pq(key, prompt, stdin, cb)
  local hit = key and cache_get(key)
  if hit then return cb(hit) end
  vim.system({ "pq", prompt }, { stdin = stdin, text = true }, function(out)
    vim.schedule(function()
      if out.code ~= 0 then
        return vim.notify("pq failed: " .. vim.trim(out.stderr or ""), vim.log.levels.WARN)
      end
      local text = vim.trim(out.stdout or "")
      if text == "" then return end
      if key then cache_put(key, text) end
      cb(text)
    end)
  end)
end

--- Show `text` as dim virtual lines attached to `row` (0-based).
local function show(buf, row, text, hl, above)
  if not vim.api.nvim_buf_is_valid(buf) then return end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local lines = {}
  for l in text:gmatch("[^\n]+") do
    lines[#lines + 1] = { { "  " .. l, hl } }
  end
  vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
    virt_lines = lines,
    virt_lines_above = above,
  })
end

-- Hints are a peek: any movement dismisses them.
vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave" }, {
  group = vim.api.nvim_create_augroup("ai_hints_clear", { clear = true }),
  callback = function(a)
    vim.api.nvim_buf_clear_namespace(a.buf, ns, 0, -1)
  end,
})

-- "Why" hint --------------------------------------------------------------

vim.keymap.set("n", "<leader>gw", function()
  local buf = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" then return end
  local dir = vim.fs.dirname(file)

  vim.system(
    { "git", "-C", dir, "blame", "--porcelain", "-L", row .. "," .. row, "--", file },
    { text = true },
    function(b)
      local out = b.stdout or ""
      local sha = out:match("^(%x+)")
      if b.code ~= 0 or not sha or sha:match("^0+$") then
        return vim.schedule(function()
          vim.notify("No committed change on this line", vim.log.levels.INFO)
        end)
      end
      local when = tonumber(out:match("\nauthor%-time (%d+)"))
      local prefix = ("[%s %s] "):format(sha:sub(1, 7), when and os.date("%Y-%m-%d", when) or "")

      vim.system({ "git", "-C", dir, "show", "--no-color", sha }, { text = true }, function(s)
        -- Cap the input: pq latency scales with prompt size (~5s small, ~40s at 20 KB).
        local body = (s.stdout or ""):sub(1, 30000)
        pq("why-" .. sha,
          "One sentence, no preamble: why was this change made? Describe the motivation, not the diff.",
          body,
          function(text) show(buf, row - 1, "⟶ " .. prefix .. text, "Comment", true) end)
      end)
    end
  )
end, { desc = "AI: why does this line exist?" })

-- Diagnostic gloss ----------------------------------------------------------

vim.keymap.set("n", "<leader>ce", function()
  local buf = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local d = vim.diagnostic.get(buf, { lnum = row - 1 })[1]
  if not d then
    return vim.notify("No diagnostic on this line", vim.log.levels.INFO)
  end
  local lo, hi = math.max(0, row - 11), row + 10
  local ctx = table.concat(vim.api.nvim_buf_get_lines(buf, lo, hi, false), "\n")
  local input = ("File: %s (%s)\nDiagnostic on line %d: %s\n\nSurrounding code:\n%s"):format(
    vim.fn.fnamemodify(vim.api.nvim_buf_get_name(buf), ":."), vim.bo[buf].filetype, row, d.message, ctx)

  pq("diag-" .. vim.fn.sha256(input),
    "Two sentences, no preamble: what does this diagnostic mean here, and what is the likely fix?",
    input,
    function(text) show(buf, row - 1, "⟶ " .. text, "DiagnosticVirtualTextHint", false) end)
end, { desc = "AI: explain diagnostic" })

-- File gist in the statusline ----------------------------------------------
-- The one push-style hint: computed once per file open (memoised by content
-- hash), only for git-tracked files under 20 KB. Toggle with :AiGist.

vim.g.ai_gist = vim.g.ai_gist == nil and true or vim.g.ai_gist
local gists = {}

local function compute_gist(buf)
  if not vim.g.ai_gist or gists[buf] then return end
  local file = vim.api.nvim_buf_get_name(buf)
  if file == "" or vim.bo[buf].buftype ~= "" then return end
  local size = vim.fn.getfsize(file)
  if size <= 0 or size > 20000 then return end

  vim.system({ "git", "-C", vim.fs.dirname(file), "ls-files", "--error-unmatch", "--", file }, {}, function(t)
    if t.code ~= 0 then return end -- untracked or not a repo: skip
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then return end
      local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
      local rel = vim.fn.fnamemodify(file, ":.")
      pq("gist-" .. vim.fn.sha256(rel .. "\n" .. content),
        "At most six words: what is this file for? Output only the phrase, no punctuation.",
        "File: " .. rel .. "\n\n" .. content,
        function(text)
          gists[buf] = text
          vim.cmd.redrawstatus()
        end)
    end)
  end)
end

vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("ai_hints_gist", { clear = true }),
  callback = function(a) compute_gist(a.buf) end,
})
vim.api.nvim_create_autocmd("BufDelete", {
  group = "ai_hints_gist",
  callback = function(a) gists[a.buf] = nil end,
})

vim.api.nvim_create_user_command("AiGist", function()
  vim.g.ai_gist = not vim.g.ai_gist
  if vim.g.ai_gist then compute_gist(vim.api.nvim_get_current_buf()) end
  vim.cmd.redrawstatus()
  vim.notify("AI file gist " .. (vim.g.ai_gist and "on" or "off"))
end, { desc = "Toggle the AI file description in the statusline" })

-- Append to lualine's existing sections rather than redeclaring them; this
-- block runs after nvf's plugin setup (see nvim_ai_hints.nix).
local ok, lualine = pcall(require, "lualine")
if ok then
  local cfg = lualine.get_config()
  cfg.sections.lualine_c = cfg.sections.lualine_c or {}
  table.insert(cfg.sections.lualine_c, {
    function()
      return vim.g.ai_gist and gists[vim.api.nvim_get_current_buf()] or ""
    end,
    color = "Comment",
  })
  lualine.setup(cfg)
end
