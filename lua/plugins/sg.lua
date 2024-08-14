return {
  {
    "sourcegraph/sg.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope.nvim" },
    config = function()
      require("sg").setup({})
    end,
    vim.keymap.set("n", "<leader>k", function()
      require("sg.cody.commands").toggle()
    end, {desc = "Toggle Cody"}),
  },
}
