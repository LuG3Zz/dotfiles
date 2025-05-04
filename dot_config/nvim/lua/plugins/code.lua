return {
  {
    "skywind3000/asynctasks.vim",
    dependencies = {
      "skywind3000/asyncrun.vim",
    },
    keys = {
      { "<F5>", ":AsyncTask file-run<cr>", desc = "Run current file" },
      { "<F9>", ":AsyncTask file-build<cr>", desc = "Build current file" },
    },
    event = "VeryLazy",
    config = function()
      vim.g.asyncrun_open = 8
      vim.g.asynctasks_term_pos = "kitty"
    end,
  },
  { "augmentcode/augment.vim" },
}
