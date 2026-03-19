" ****************************************************************************
" File:             checkbox.vim
" Author:           Jonas Kramer / Henrique Barcelos
" Version:          0.3.0
" Last Modified:    2026-03-18
" Copyright:        Copyright (C) 2010-2018 by Jonas Kramer. Published under the
"                   terms of the Artistic License 2.0.
" Fork Notice:      Modified fork of jkramer/vim-checkbox.
"                   See README for documented differences from the
"                   original implementation.
" License:          See LICENSE.
" Help:             :help vim-checkbox
" ****************************************************************************
" Markdown-only ftplugin for toggling checkboxes and list-item strikethrough.
" For usage, mappings, configuration, and fork-specific behavior, see:
"   :help vim-checkbox
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

function! checkbox#ListItemPrefixEnd(line)
  let list_prefix_pattern = '^\s*\%(>\s*\)*\%([-+*]\|\d\{1,9}[.)]\)\s\+'
  return matchend(a:line, list_prefix_pattern)
endfunction

function! checkbox#DefaultInsertPos(line)
  let list_prefix_end = checkbox#ListItemPrefixEnd(a:line)

  if list_prefix_end != -1
    return list_prefix_end
  endif

  let content_prefix_end = matchend(a:line, '^\s*\%(>\s*\)*')

  if content_prefix_end >= strlen(a:line)
    return -1
  endif

  return content_prefix_end
endfunction

function! checkbox#FindCheckbox(line)
  let found_index = -1
  let found_pos = -1

  for idx in range(len(g:checkbox_states))
    let state = g:checkbox_states[idx]
    let pattern = '\%(^\|\s\)\zs\[' . escape(state, '\^$.*~[]') . '\]\ze\%(\s\|$\)'
    let pos = match(a:line, pattern)

    if pos != -1 && (found_pos == -1 || pos < found_pos)
      let found_index = idx
      let found_pos = pos
    endif
  endfor

  return [found_index, found_pos]
endfunction

function! checkbox#ToggleOrInsertCheckbox()
	let line = getline('.')
  let [state_index, checkbox_pos] = checkbox#FindCheckbox(line)

  if state_index != -1
    let current_marker = '[' . g:checkbox_states[state_index] . ']'
    let next_index = (state_index + 1) % len(g:checkbox_states)
    let line = strpart(line, 0, checkbox_pos)
          \ . '[' . g:checkbox_states[next_index] . ']'
          \ . strpart(line, checkbox_pos + strlen(current_marker))
  else
    if g:checkbox_insert != ''
      let checkbox = g:checkbox_insert_prefix . '[' . g:checkbox_states[0] . ']' . g:checkbox_insert_suffix
      let default_insert_pos = checkbox#DefaultInsertPos(line)

      if g:checkbox_insert ==# '\<' && default_insert_pos != -1
        let line = strpart(line, 0, default_insert_pos) . checkbox . strpart(line, default_insert_pos)
      else
        let line = substitute(line, g:checkbox_insert, checkbox, '')
      endif
    endif
	endif

	call setline('.', line)

  silent! call repeat#set("\<Plug>(checkbox-toggle-or-insert)", -1)
endfunction

function! checkbox#ToggleCheckboxStrikethrough()
	let line = getline('.')
  let list_prefix_pattern = '^\s*\%(>\s*\)*\%([-+*]\|\d\{1,9}[.)]\)\s\+\%(\[[^]]\]\s*\)\?'
  let text_start = matchend(line, list_prefix_pattern)

  if text_start == -1
    return
  endif

  let prefix = strpart(line, 0, text_start)
  let text = strpart(line, text_start)

  if text ==# ''
    return
  endif

  if strlen(text) >= 4 && strpart(text, 0, 2) ==# '~~' && strpart(text, strlen(text) - 2) ==# '~~'
    let text = strpart(text, 2, strlen(text) - 4)
  else
    let text = '~~' . text . '~~'
  endif

	call setline('.', prefix . text)

  silent! call repeat#set("\<Plug>(checkbox-toggle-strikethrough)", -1)
endfunction

command! ToggleOrInsertCheckbox call checkbox#ToggleOrInsertCheckbox()
command! ToggleCheckboxStrikethrough call checkbox#ToggleCheckboxStrikethrough()

nnoremap <silent> <Plug>(checkbox-toggle-or-insert) :ToggleOrInsertCheckbox<CR>
nnoremap <silent> <Plug>(checkbox-toggle-strikethrough) :ToggleCheckboxStrikethrough<CR>

if (g:checkbox_create_mappings == 1)
  nmap <silent> <leader>tt <Plug>(checkbox-toggle-or-insert)
  nmap <silent> <leader>ts <Plug>(checkbox-toggle-strikethrough)
endif

let g:checkbox_loaded = 1
