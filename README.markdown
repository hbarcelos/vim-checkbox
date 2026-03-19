Vim Checkbox
============

Description
-----------

Simple Markdown-focused Vim plugin for toggling checkboxes on the current line.
This fork installs its logic from `after/ftplugin/markdown/checkbox.vim`, so it
is intended to be loaded for Markdown buffers.


Installation
------------

Install the repository on your Vim `runtimepath` with your plugin manager of
choice.

For a manual install, keep the file layout intact so Vim can load:

    after/ftplugin/markdown/checkbox.vim

Optional:

- Install `tpope/vim-repeat` if you want both actions to work with `.`

Help is available in Vim with:

    :help vim-checkbox


Usage
-----

The plugin defines:

- `:ToggleOrInsertCheckbox`
- `:ToggleCheckboxStrikethrough`
- `<Plug>(checkbox-toggle-or-insert)`
- `<Plug>(checkbox-toggle-strikethrough)`
- `nmap <silent> <leader>tt <Plug>(checkbox-toggle-or-insert)`
- `nmap <silent> <leader>ts <Plug>(checkbox-toggle-strikethrough)`

Running the command on the current line does one of two things:

1. If the line already contains a checkbox matching one of the configured
   states, it replaces that checkbox with the next state.
2. If the line does not contain a checkbox, it inserts one at the pattern
   configured by `g:checkbox_insert`.

With the default settings:

    let g:checkbox_states = [' ', 'x']

the command cycles:

    [ ] -> [x] -> [ ]

Example:

    - task      -> - [ ] task
    - [ ] task  -> - [x] task

The strikethrough command toggles Markdown `~~...~~` on the text of the current
Markdown list item. It preserves indentation, ordered or unordered list
markers, and any checkbox state already present:

    - [ ] task      -> - [ ] ~~task~~
    - [x] ~~task~~  -> - [x] task
    + task          -> + ~~task~~
    1. task         -> 1. ~~task~~
    1) ~~task~~     -> 1) task


Configuration
-------------

### `g:checkbox_states`

List of single-character checkbox states to cycle through. Default:

    let g:checkbox_states = [' ', 'x']

You can add more states if you want a longer cycle:

    let g:checkbox_states = [' ', 'x', '-']

which yields:

    [ ] -> [x] -> [-] -> [ ]


### `g:checkbox_insert`

Pattern used with `substitute()` when the current line has no checkbox.
Default:

    let g:checkbox_insert = '\<'

In this plugin's default Markdown-aware behavior, that inserts the checkbox at
the start of the line's content after indentation, blockquote markers, or list
markers. So input like:

    [Project board](https://example.com)
    - [Project board](https://example.com)
    > [Project board](https://example.com)

becomes:

    [ ] [Project board](https://example.com)
    - [ ] [Project board](https://example.com)
    > [ ] [Project board](https://example.com)

Other useful values:

    let g:checkbox_insert = '^'   " insert at the start of the line
    let g:checkbox_insert = '$'   " insert at the end of the line

Disable insertion entirely with:

    let g:checkbox_insert = ''


### `g:checkbox_insert_prefix`
### `g:checkbox_insert_suffix`

Text added before and after a newly inserted checkbox. Defaults:

    let g:checkbox_insert_prefix = ''
    let g:checkbox_insert_suffix = ' '

The default suffix adds a space after the inserted checkbox.


### `g:checkbox_create_mappings`

Controls whether the default `<leader>tt` mapping is created. Default:

    let g:checkbox_create_mappings = 1

Set it before the plugin loads to disable the default mapping:

    let g:checkbox_create_mappings = 0


Custom Mapping
--------------

If you disable the default mapping, define your own mapping to the `<Plug>`
target:

```vim
let g:checkbox_create_mappings = 0
nmap <silent> <leader>oo <Plug>(checkbox-toggle-or-insert)
nmap <silent> <leader>os <Plug>(checkbox-toggle-strikethrough)
```

If `tpope/vim-repeat` is installed, triggering the checkbox action through the
`<Plug>` mappings makes both actions repeatable with `.`.
