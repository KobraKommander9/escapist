# escapist

Many people use mappings like `jk` or `jj` to escape insert mode (or other modes). The
issue with these mappings is that you have to wait `timeoutlen` whenever you type a `j`
before you insert a `j`. This will always cause delays.

## Features

- Write mappings in any modes without having delays when typing
  - Easily create mappings using strings or tables
  - Customize modes the modes these mappings occur in
  - Alter the "escape" functionality of each mapping
- Customizable timout
- Small and *should* be fast

## Installation

Use your favorite package manager and call the setup function.
```lua
-- lua with lazy.nvim
{
  "KobraKommander9/escapist",
  opts = {
    keys = { "jk" },
  },
}
```

## Configuration

The default configuration:
```lua
{
  keys = { "jk" },
  timeout = vim.o.timeoutlen,
}
```

The default configuration is quite minimal, but it can be rewritten as:
```lua
{
  keys = {
    { "jk", mode = { "n", "i", "c", "v", "s" }, action = "<Esc>" },
    { "jk", mode = "t", action = "<C-\\><C-n>" },
  },
  timeout = vim.o.timeoutlen,
}
```

The `keys` parameter must be a table, but each value in the table can
be either a string or a table. If the entry is a string, it must be 2
characters long and it will be mapped to the default escape action
for each of the supported modes. If the entry is a table, the first
key must be a 2 character string representing the escape sequence,
with optional `mode` and `action` settings specified.

The `mode` can either be a single string for one mode, or a list of
all modes.

The `action` can either be a string or a function (callback).

## API

`require("escapist").waiting` is a boolean indicating if it's waiting for
a mapped sequence to complete.

### Events

`Escapist` exports both a `EscapistExecutePre` and `EscapistExecutePost`
`User` events for use with autocmds.

## Similar Plugins

- [better-escape](https://github.com/max397574/better-escape.nvim) `Escapist` differs
  from the better escape plugin in that it does not register any of the provided
  keys as actual nvim mappings (thus avoiding conflicts with other plugins/custom
  mappings).
