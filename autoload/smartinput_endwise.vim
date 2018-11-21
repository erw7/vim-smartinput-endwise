function! smartinput_endwise#define_default_rules() abort
  call s:initialize()

  " regular expression pattern varialbes {{{
  let pat_str_qw = '"\%(\%(\\"\|\\\\\|[^"]\)*\)\@>"'
  let pat_str_qs = '''\%(\%(\\''\|\\\\\|[^'']\)*\)\@>'''
  let pat_not_q = '[^"'']'
  let pat_vb_str_qw = '"\%(\%(""\|[^"]\)*\)\@>"'
  " }}}

  " vim-rules {{{
  for word in ['fu', 'fun', 'func', 'funct', 'functi', 'functio', 'function', 'if', 'wh', 'whi', 'whil', 'while', 'for', 'try']
    call s:define_rule('vim', '^\s*&word&\>.*\%#', 'end&word&', '', word)
  endfor
  unlet word
  " }}}

  " ruby-rules {{{
  call s:define_rule('ruby', '^\s*\%(module\|def\|class\|if\|unless\|for\|while\|until\|case\)\>\%(.*[^.:@$]\<end\>\)\@!.*\%#', 'end', '', '')
  call s:define_rule('ruby', '^\s*\%(begin\)\s*\%#', 'end', '', '')
  call s:define_rule('ruby', '\%(^\s*#.*\)\@<!do\%(\s*|\k\+\%(\s*,\s*\k\+\)*|\)\?\s*\%#', 'end', '', '')
  call smartinput#define_rule({
        \ 'at': '\<\%(if\|unless\)\>.*\%#',
        \ 'char': '<CR>',
        \ 'input': s:cr_key . 'end<Esc>O',
        \ 'filetype': ['ruby'],
        \ 'syntax': ['rubyConditionalExpression']
        \ })
  " }}}

  " sh rules {{{
  call s:define_rule(['sh', 'zsh'], '^\s*if\>.*\%#', 'fi', [ 'String', ], '')
  call s:define_rule(['sh', 'zsh'], '^\s*case\>.*\%#', 'esac', [ 'String', ], '')
  call s:define_rule(['sh', 'zsh'], '\%(^\s*#.*\)\@<!do\>.*\%#', 'done', [  'String', ], '')
  " }}}

  " lua rules {{{
  let pat_lua_func = '^' . pat_not_q . '*\zs\%(\%(' . pat_str_qw . '\|' . pat_str_qs . '\)*' . pat_not_q . '\)*\<function\>\%(.*\<end\>\)\@!.*\%#'
  let pat_lua_block = '\%(do\|then\)\>\s*\%#'
  let pat_lua_comment = '^' . pat_not_q . '*\zs\%(\%(' . pat_str_qw . '\|' . pat_str_qs . '\)*' . pat_not_q . '\)*--.*\<\%(function\|then\|do\)\>\%(.*\<end\>\)\@!.*\%#'
  call s:define_rule('lua', pat_lua_func, 'end', [ 'Comment', ], '')
  call s:define_rule('lua', pat_lua_block, 'end', [ 'String', 'Comment' ], '')
  call smartinput#define_rule({
        \ 'at' : pat_lua_comment,
        \ 'char' : '<CR>',
        \ 'filetype' : ['lua'],
        \ 'input' : s:cr_key,
        \})
  unlet pat_lua_func
  unlet pat_lua_block
  unlet pat_lua_comment
  " }}}

  " VB rules {{{
  let pat_vb_bol = '\c^\s*\zs\%(\%(' . pat_vb_str_qw . '\)*[^"' . "'" . ']\)*'
  let pat_vb_eol = '\%([^' . "'" . ']*\<&end&\>\)\@!.*\%#'
  for word in ['Class', 'Enum', 'Function', 'Module', 'Namespace', 'Sub', ]
    call s:define_rule(['vb', 'vbnet', 'aspvbs'], pat_vb_bol . '\<&word&\>' . pat_vb_eol, 'End &word&', '', word)
  endfor
  call s:define_rule(['vb', 'vbnet', 'aspvbs'], pat_vb_bol . '\<&word&\>\s\+\<\%(Get\|Let\|Set\)\>' . pat_vb_eol, 'End &word&', '', 'Property')
  call s:define_rule(['vb', 'vbnet', 'aspvbs'], '\c^\s*\zs\<Do\>' . pat_vb_eol, 'Loop', '', '')
  call s:define_rule(['vb', 'vbnet', 'aspvbs'], '\c^\s*\zs\<&word&\>[^' . "'" .']*\<Then\>' . pat_vb_eol, 'End &word&', '', 'If')
  call s:define_rule(['vb', 'vbnet', 'aspvbs'], '\c^\s*\zs\<For\>' . pat_vb_eol, 'Next', '', '')
  call s:define_rule(['vb', 'vbnet', 'aspvbs'], '\c^\s*\zs\<&word&\s\+Case\>' . pat_vb_eol, 'End &word&', '', 'Select')
  unlet pat_vb_bol
  unlet pat_vb_eol
  unlet word
  " }}}

  " cmake-rules {{{
  for word in ['function', 'foreach', 'if', 'macro', 'while', ]
    call s:define_rule('cmake', '^\s*&word&(.*)\%#', 'end&word&()', '', word)
  endfor
  unlet word
  " }}}

  " Cleanup of varialbes
  unlet pat_str_qw
  unlet pat_str_qs
  unlet pat_not_q
  " }}}
endfunction

function! s:initialize() abort
  if !exists('g:smartinput_endwise_avoid_neocon_conflict')
    let g:smartinput_endwise_avoid_neocon_conflict = 1
  endif
  let s:cr_key = '<C-r>=smartinput_endwise#_avoid_conflict_cr()<CR>'
  call smartinput#define_rule({'at': '\%#', 'char': '<CR>', 'input': s:cr_key})
endfunction

function! smartinput_endwise#_avoid_conflict_cr() abort
  if exists('*neocomplete#close_popup') && g:smartinput_endwise_avoid_neocon_conflict
    return "\<C-r>=neocomplete#close_popup()\<CR>\<CR>"
  elseif exists('*neocomplcache#close_popup()') && g:smartinput_endwise_avoid_neocon_conflict
    return "\<C-r>=neocomplcache#close_popup()\<CR>\<CR>"
  else
    return "\<CR>"
  endif
endfunction

function! s:define_rule(filetype, pattern, end, ignore_syntax, word) abort
  if a:word !=? ''
    let end = substitute(a:end, '&word&', a:word, 'g')
    let pat_end = substitute(end, ' ', '\>\s\+\<', 'g')
    let rule = {
          \ 'at': substitute(substitute(a:pattern, '&word&', a:word, 'g'), '&end&', pat_end, 'g'),
          \ 'char': '<CR>',
          \ 'input': s:cr_key . end . '<Esc>O'
          \ }
  else
    let pat_end = substitute(a:end, ' ', '\>\s\+\<', 'g')
    let rule = {
          \ 'at': substitute(a:pattern, '&end&', pat_end, 'g'),
          \ 'char': '<CR>',
          \ 'input': s:cr_key . a:end . '<Esc>O'
          \ }
  endif

  if type(a:filetype) == type('')
    let rule.filetype = [a:filetype]
  elseif type(a:filetype) == type([])
    let rule.filetype = a:filetype
  endif
  call smartinput#define_rule(rule)

  if !empty(a:ignore_syntax)
    let ignore_rule = copy(rule)
    if type(a:ignore_syntax) == type('')
      let ignore_rule.syntax = [a:ignore_syntax]
    elseif type(a:ignore_syntax) == type([])
      let ignore_rule.syntax = a:ignore_syntax
    end
    let ignore_rule.input = s:cr_key
    call smartinput#define_rule(ignore_rule)
  endif
endfunction
