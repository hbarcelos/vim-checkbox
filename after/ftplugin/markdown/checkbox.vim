" ****************************************************************************
" File:             checkbox.vim
" Author:           Jonas Kramer / Henrique Barcelos
" Version:          0.2
" Last Modified:    2023-08-29
" Copyright:        Copyright (C) 2010-2018 by Jonas Kramer. Published under the
"                   terms of the Artistic License 2.0.
" ****************************************************************************
" Installation: Copy this script into your plugin folder.
" Usage: Call "ToggleOrInsertCheckbox" to toggle the (first) checkbox on the current
" line, if any. That means, "[ ]" will be replaced with "[x]" and "[x]" with
" "[ ]". If you want more or different checkbox states, you can override the
" contents of g:checkbox_states with an array of characters, which the plugin
" will cycle through. The default is:
"
"     let g:checkbox_states = [' ', 'x']
"
" When there's no checkbox on the current line, "ToggleOrInsertCheckbox" will insert one
" at the pattern defined in {g:checkbox_insert}. The new checkbox's state will
" be the first element of {g:checkbox_states}. The default for {g:checkbox_insert}
" is '\<', which will insert the checkbox in front of the first word of the
" line (not necessarily at the beginning of the line, '^'), which is
" particularly useful when working in markdown-formatted lists. The pattern
" can be overridden. Other useful patterns would be '^' (insert at the very
" beginning of the line) and '$' (end of line). When inserting a new checkbox,
" g:checkbox_insert_prefix and g:checkbox_insert_suffix are
" prepended/appended, respectively. This is mostly useful for adding a space
" behind the checkbox, which is the default:
"
"     let g:checkbox_insert_prefix = ''
"     let g:checkbox_insert_suffix = ' '
"
" Inserting a checkbox can be disabled by setting g:checkbox_insert to an
" empty string ('').
" ****************************************************************************

if exists('g:checkbox_loaded')
	finish
endif

if !exists('g:checkbox_states')
  let g:checkbox_states = [' ', 'x']
endif


if !exists('g:checkbox_insert')
  "let g:checkbox_insert = '^'
  "let g:checkbox_insert = '$'
  let g:checkbox_insert = '\<'
endif

if !exists('g:checkbox_insert_prefix')
  let g:checkbox_insert_prefix = ''
endif

if !exists('g:checkbox_insert_suffix')
  let g:checkbox_insert_suffix = ' '
endif

if !exists('g:checkbox_create_mappings')
  let checkbox_create_mappings = 1
endif

function! checkbox#ToggleOrInsertCheckbox()
	let line = getline('.')

  if(match(line, '\[.\]') != -1)
    let states = copy(g:checkbox_states)
    call add(states, g:checkbox_states[0])

    for state in states
      if(match(line, '\[' . state . '\]') != -1)
        let next_state = states[index(states, state) + 1]
        let line = substitute(line, '\[' . state . '\]', '[' . next_state . ']', '')
        break
      endif
    endfor
  else
    if g:checkbox_insert != ''
      let line = substitute(line, g:checkbox_insert, g:checkbox_insert_prefix . '[' . g:checkbox_states[0] . ']' . g:checkbox_insert_suffix, '')
    endif
  endif

	call setline('.', line)
endfunction

command! ToggleOrInsertCheckbox call checkbox#ToggleOrInsertCheckbox()

if (g:checkbox_create_mappings == 1)
  nnoremap <silent> <leader>tt :ToggleOrInsertCheckbox<CR>
endif

let g:checkbox_loaded = 1

