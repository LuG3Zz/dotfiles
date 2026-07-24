-- lua/config/agent.lua — opencode.nvim AI Agent

-- Config is via vim.g.opencode_opts (no setup() function)
-- Default keymaps in keymaps.lua:
--   <C-a>  Ask
--   <C-x>  Select command menu
--   go     Operator

vim.g.opencode_opts = {
  ask = {
    snacks = {
      win = {
        width = 100,  -- 输入框宽度，默认为 60
      },
    },
  },
  -- Custom commands visible in the select() command menu (<C-x>)
  commands = {
    -- Review
    review = {
      'Review: Code review the selected code and suggest improvements.',
      '@this: Review this code. Check for bugs, edge cases, and suggest improvements.',
      {
        agent = 'review',
        silent = false,
        group = 'review',
      },
    },
    review_selection = {
      'Review: Review the selected lines only.',
      '@this: Only review the selected lines in detail:',
      {
        agent = 'review',
        silent = false,
        group = 'review',
      },
    },

    -- Refactor
    refactor = {
      'Refactor: Refactor the selected code for better readability.',
      '@this: Refactor this code to be more readable and maintainable. Focus on clarity.',
      {
        agent = 'refactor',
        silent = false,
        group = 'refactor',
      },
    },

    -- Explain
    explain = {
      'Explain: Explain the selected code in detail.',
      '@this: Explain how this code works in detail, including the purpose and logic.',
      {
        agent = 'explain',
        silent = false,
        group = 'explain',
      },
    },

    -- Test
    test = {
      'Test: Generate unit tests for the selected code.',
      '@this: Generate comprehensive unit tests for this code.',
      {
        agent = 'test',
        silent = false,
        group = 'test',
      },
    },

    -- Fix
    fix = {
      'Fix: Suggest a fix for the selected code.',
      '@this: This code appears to have issues. Please analyze and suggest fixes.',
      {
        agent = 'fix',
        silent = false,
        group = 'fix',
      },
    },

    -- Optimize
    optimize = {
      'Optimize: Optimize the selected code for performance.',
      '@this: Optimize this code for better performance. Explain the changes.',
      {
        agent = 'optimize',
        silent = false,
        group = 'optimize',
      },
    },

    -- Document
    document = {
      'Document: Add documentation comments to the selected code.',
      '@this: Add clear and concise documentation comments to this code.',
      {
        agent = 'document',
        silent = false,
        group = 'document',
      },
    },

    -- Translate
    translate_to_python = {
      'Translate: Convert the selected code to Python.',
      '@this: Translate this code to idiomatic Python.',
      {
        agent = 'translate',
        silent = false,
        group = 'translate',
      },
    },
    translate_to_rust = {
      'Translate: Convert the selected code to Rust.',
      '@this: Translate this code to idiomatic Rust.',
      {
        agent = 'translate',
        silent = false,
        group = 'translate',
      },
    },
  },
}
