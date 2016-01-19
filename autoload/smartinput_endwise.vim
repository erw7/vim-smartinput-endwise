function! smartinput_endwise#define_default_rules()
  call s:initialize()

  " regular expression pattern varialbes {{{
    let pat_str_qw = '"\%(\%(\\"\|\\\\\|[^"]\)*\)\@>"'
    let pat_str_qs = "'" . '\%(\%(\\' . "'" . '\|\\\\\|[^' . "'" . ']\)*\)\@>' ."'"
    let pat_not_q = '[^"' . "'" . ']'
    let pat_vb_str_qw = '"\%(\%(""\|[^"]\)*\)\@>"'
  " }}}

  " vim-rules {{{
  for word in ['fu', 'fun', 'func', 'funct', 'functi', 'functio', 'function', 'if', 'wh', 'whi', 'whil', 'while', 'for', 'try']
    call s:define_rule('vim', '^\s*&\>.*\%#', 'end&', '', word)
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
  call s:define_rule(['sh', 'zsh'], '^\s*if\>.*\%#', 'fi', '', '')
  call s:define_rule(['sh', 'zsh'], '^\s*case\>.*\%#', 'esac', '', '')
  call s:define_rule(['sh', 'zsh'], '\%(^\s*#.*\)\@<!do\>.*\%#', 'done', '', '')
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
    let pat_vb_bol = '\c^\s*\zs\%(\%(' . pat_vb_str_qw . '\)*[^"]\)*'
    let pat_vb_eol = '\%([^' . "'" . ']*\<End\>\s\+\<&\>\)\@!.*\%#'
    let pat_vb_comment = '\c^\s*\zs\%(\%(' . pat_vb_str_qw . '\)*[^"]\)*' . "'" . '.*\<\%(Class\|Enum\|Function\|Module\|Namespace\|Sub\|Property\|Do\|If\|For\Select\)\>.*\%#'
    for word in ['Class', 'Enum', 'Function', 'Module', 'Namespace', 'Sub', ]
      call s:define_rule(['vb', 'vbnet', 'aspvbs'], pat_vb_bol . '\<&\>' . pat_vb_eol, 'End &', '', word)
    endfor
    call s:define_rule(['vb', 'vbnet', 'aspvbs'], pat_vb_bol . '\<&\>\s\+\<\%(Get\|Let\|Set\)\>' . pat_vb_eol, 'End &', '', 'Property')
    call s:define_rule(['vb', 'vbnet', 'aspvbs'], pat_vb_bol . '\<Do\>\%([^' . "'" .']*\<&\>\)\@!.*\%#' , '&', '', 'Loop')
    call s:define_rule(['vb', 'vbnet', 'aspvbs'], '\c^\s*\zs\<&\>.*\<Then\>' . pat_vb_eol, 'End &', '', 'If')
    call s:define_rule(['vb', 'vbnet', 'aspvbs'], '\c^\s*\zs\<For\>\%([^' . "'" .']*\<&\>\)\@!.*\%#' , '&', '', 'Next')
    call s:define_rule(['vb', 'vbnet', 'aspvbs'], '\c^\s*\zs\<&\s\+Case\>\%([^' . "'" .']*\<End\s\+&\>\)\@!.*\%#' , 'End &', '', 'Select')
    call smartinput#define_rule({
          \ 'at' : pat_vb_comment,
          \ 'char' : '<CR>',
          \ 'filetype' : ['vb', 'vbnet', 'aspvbs'],
          \ 'input' : s:cr_key
          \})
    unlet pat_vb_bol
    unlet pat_vb_eol
    unlet pat_vb_comment
    unlet word
    " }}}

    " Cleanup of varialbes
    unlet pat_str_qw
    unlet pat_str_qs
    unlet pat_not_q
  " }}}
endfunction

function! s:initialize()
  if !exists('g:smartinput_endwise_avoid_neocon_conflict')
    let g:smartinput_endwise_avoid_neocon_conflict = 1
  endif
  let s:cr_key = '<C-r>=smartinput_endwise#_avoid_conflict_cr()<CR>'
  call smartinput#define_rule({'at': '\%#', 'char': '<CR>', 'input': s:cr_key})
endfunction

function! smartinput_endwise#_avoid_conflict_cr()
  if exists('*neocomplete#close_popup') && g:smartinput_endwise_avoid_neocon_conflict
    return "\<C-r>=neocomplete#close_popup()\<CR>\<CR>"
  elseif exists('*neocomplcache#close_popup()') && g:smartinput_endwise_avoid_neocon_conflict
    return "\<C-r>=neocomplcache#close_popup()\<CR>\<CR>"
  else
    return "\<CR>"
  endif
endfunction

function! s:define_rule(filetype, pattern, end, ignore_syntax, word)
  if a:word != ''
    let rule = {
    \ 'at': substitute(a:pattern, '&', a:word, 'g'),
    \ 'char': '<CR>',
    \ 'input': s:cr_key . substitute(a:end, '&', a:word, 'g') . '<Esc>O'
    \ }
  else
    let rule = {
    \ 'at': a:pattern,
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
