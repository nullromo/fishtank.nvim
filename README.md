# 🐟 Fishtank.nvim

A little friend to keep you company.

## 🐠 Video Demo

## 🌊 Installation and Configuration

Lazy.nvim config:

```lua
{
    'nullromo/fishtank.nvim',
    opts = {}, -- specify options here
    config = function(_, opts)
        local fishtank = require('fishtank')
        fishtank.setup(opts)
    end,
}
```

### Default Options

```lua
-- default options if unspecified by user
M.defaultOptions = {
    -- options for controlling the behavior of the screensaver
    screensaver = {
        -- whether or not the screensaver comes on at all
        enabled = true,
        -- amount of idle time before the screensaver comes on
        timeout = 60 * 1000 * 10, -- 10 minutes
    },
}
```

### Options Table

| Option                | Data Type | Default               | Description                                                            |
| --------------------- | --------- | --------------------- | ---------------------------------------------------------------------- |
| `screensaver.enabled` | boolean   | `true`                | Whether or not to turn the fishtank on after an amount of idle time.   |
| `screensaver.timeout` | number    | `600000` (10 minutes) | Amount of time in milliseconds to wait before turning the fishtank on. |

## 🐡 License, Contributing, etc.

See [LICENSE](./LICENSE) and [CONTRIBUTING.md](./CONTRIBUTING.md).

I am very open to feedback and criticism.

## 🪼 Special Thanks

- 🏅
  [`<Your name here>`](https://github.com/nullromo/go-up.nvim/blob/main/README.md#-donating)

## 🎣 Donating

To say thanks, [sponsor me on GitHub](https://github.com/sponsors/nullromo) or
use [@Kyle-Kovacs on Venmo](https://venmo.com/u/Kyle-Kovacs). Your donation is
appreciated!
