# 🐟 Fishtank.nvim

A little friend to keep you company.

## 🐠 Video Demo

The fish will appear automatically after a given amount of time, and disappear
whenever you do something. Or if you choose to show it manually, it will stay
with you until manually dismissed.

https://github.com/user-attachments/assets/e58915f4-8e6d-40ad-92a3-1f0b271a337b

## 🌊 Installation, Usage, and Configuration

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

### User Command

There is one user command, `:Fishtank`. It accepts the following arguments:

- `start`, `on`, `open`, or `show` : shows the fishtank manually.
- `stop`, `off`, `close`, or `hide` : hides the fishtank manually.
- `toggle` : shows the fishtank if it is hidden; otherwise hides it.

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
        -- sprite customization
        sprite = {
            right = '><>', -- fish moving to the right
            left = '<><', -- fish moving to the left
        },
    },
}
```

### Options Table

| Option                     | Data Type | Default               | Description                                                            |
| -------------------------- | --------- | --------------------- | ---------------------------------------------------------------------- |
| `screensaver.enabled`      | boolean   | `true`                | Whether or not to turn the fishtank on after an amount of idle time.   |
| `screensaver.timeout`      | number    | `600000` (10 minutes) | Amount of time in milliseconds to wait before turning the fishtank on. |
| `screensaver.sprite.right` | number    | `'><>'`               | Sprite to use for the fish when facing right. |
| `screensaver.sprite.left`  | number    | `'<><'`               | Sprite to use for the fish when facing left. |

## 🐡 License, Contributing, etc.

See [LICENSE](./LICENSE) and [CONTRIBUTING.md](./CONTRIBUTING.md).

I am very open to feedback and criticism.

## 🪼 Special Thanks

- 🏅
  [`<Your name here>`](https://github.com/nullromo/fishtank.nvim/blob/main/README.md#-donating)

### Inspiration

This plugin was inspired by a program I wrote on a
[TI-84 Plus Silver Edition graphing calculator](https://en.wikipedia.org/wiki/TI-84_Plus_series)
in high school.

Also, VSCode users
[have this kind of thing](https://marketplace.visualstudio.com/items?itemName=tonybaloney.vscode-pets),
so why can't we have it too? 😄

Partly inspired by [drop.nvim](https://github.com/folke/drop.nvim).

## 🎣 Donating

To say thanks, [sponsor me on GitHub](https://github.com/sponsors/nullromo) or
use [@Kyle-Kovacs on Venmo](https://venmo.com/u/Kyle-Kovacs). Your donation is
appreciated!
