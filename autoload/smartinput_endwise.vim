function! smartinput_endwise#define_default_rules() abort
  call s:initialize()

  " regular expression pattern varialbes {{{
  let pat_str_qw = '"\%(\%(\\"\|\\\\\|[^"]\)*\)\@>"'
  let pat_str_qs = '''\%(\%(\\''\|\\\\\|[^'']\)*\)\@>'''
  let pat_not_q = '[^"'']'
  let pat_vb_str_qw = '"\%(\%(""\|[^"]\)*\)\@>"'
  " }}}

  let rules = []

  " vim-rules {{{
  let rules += [
        \  { 'vim' :
        \    [
        \      {
        \        'pattern' : '^\s*&word&\>.*\%#',
        \        'end' : 'end&word%',
        \        'word' : [ 'fu', 'fun', 'func', 'funct', 'functi', 'functio', 'function', 'if', 'wh', 'whi', 'whil', 'while', 'for', 'try', ],
        \      },
        \    ],
        \  },
        \]
  " }}}

  " ruby-rules {{{
  let rules += [
        \  { 'ruby' :
        \    [
        \      { 'pattern' : '^\s*\%(module\|def\|class\|if\|unless\|for\|while\|until\|case\)\>\%(.*[^.:@$]\<end\>\)\@!.*\%#', },
        \      { 'pattern' : '^\s*\%(begin\)\s*\%#', },
        \      { 'pattern' : '\%(^\s*#.*\)\@<!do\%(\s*|\k\+\%(\s*,\s*\k\+\)*|\)\?\s*\%#', },
        \      {
        \        'pattern' : '\<\%(if\|unless\)\>.*\%#',
        \        'location' : [ { 'filetype' : [ 'ruby', 'vim', ], 'syntax' : 'rubyConditionalExpression', }, ],
        \      },
        \    ],
        \    'location' : [ { 'filetype' : 'ruby ', }, { 'filetype' : 'vim', 'syntax' : 'VimRubyRegion', }, ],
        \  },
        \]
  " }}}

  " sh rules {{{
  let rules += [
        \  { 'sh,zsh' :
        \    [
        \      { 'pattern' : '^\s*if\>.*\%#', },
        \      { 'pattern' : '^\s*case\>.*\%#', },
        \      { 'pattern' : '\%(^\s*#.*\)\@<!do\>.*\%#', },
        \    ],
        \    'location' : [ { 'filetype' : [ 'sh', 'zsh' ], 'ignore_syntax' : 'String', }, ],
        \  },
        \]
  " }}}

  " lua rules {{{
  let pat_lua_func = '^' . pat_not_q . '*\zs\%(\%(' . pat_str_qw . '\|' . pat_str_qs . '\)*' . pat_not_q . '\)*\<function\>\%(.*\<end\>\)\@!.*\%#'
  let pat_lua_block = '\%(do\|then\)\>\s*\%#'
  let pat_lua_comment = '^' . pat_not_q . '*\zs\%(\%(' . pat_str_qw . '\|' . pat_str_qs . '\)*' . pat_not_q . '\)*--.*\<\%(function\|then\|do\)\>\%(.*\<end\>\)\@!.*\%#'
  let rules += [
        \  { 'lua' :
        \    [
        \      {
        \        'pattern' : pat_lua_func,
        \        'location' :
        \        [
        \          { 'filetype' : 'lua', 'ignore_syntax' : 'Comment', },
        \          { 'filetype' : 'vim', 'syntax' : 'VimLuaRegion', },
        \        ],
        \      },
        \      {
        \        'pattern' : pat_lua_block,
        \        'location' :
        \        [
        \          { 'filetype' : 'lua', 'ignore_syntax' : [ 'String', 'Comment', ], },
        \          { 'filetype' : 'vim', 'syntax' : 'VimLuaRegion', },
        \        ],
        \      },
        \      {
        \        'pattern' : pat_lua_comment,
        \        'input' : s:cr_key,
        \      },
        \    ],
        \  },
        \]
  unlet pat_lua_func
  unlet pat_lua_block
  unlet pat_lua_comment
  " }}}

  " VB rules {{{
  let pat_vb_bol = '\c^\s*\zs\%(\%(' . pat_vb_str_qw . '\)*[^"' . "'" . ']\)*'
  let pat_vb_eol = '\%([^' . "'" . ']*\<&end&\>\)\@!.*\%#'
  let rules += [
        \  { 'vb,vbnet,aspvbs' :
        \    [
        \      {
        \        'pattern' : pat_vb_bol . '\<&word&\>' . pat_vb_eol,
        \        'end' : 'End &wrd&',
        \        'word' : [ 'Class', 'Enum', 'Function', 'Module', 'Namespace', 'Sub', ],
        \      },
        \      {
        \        'pattern' : pat_vb_bol . '\<&word&\>\s\+\<\%(Get\|Let\|Set\)\>' . pat_vb_eol,
        \        'end' : 'End &word&',
        \        'word' : 'Property',
        \      },
        \      {
        \        'pattern' : '\c^\s*\zs\<Do\>' . pat_vb_eol,
        \        'end' : 'Loop',
        \      },
        \      {
        \        'pattern' : '\c^\s*\zs\<&word&\>[^' . "'" .']*\<Then\>' . pat_vb_eol,
        \        'end' : 'End &word&',
        \        'word' : 'If',
        \      },
        \      {
        \        'pattern' : '\c^\s*\zs\<For\>' . pat_vb_eol,
        \        'end' : 'Next',
        \      },
        \      {
        \        'pattern' : '\c^\s*\zs\<&word&\s\+Case\>' . pat_vb_eol,
        \        'end' : 'End &word&',
        \        'word' : 'Select',
        \      },
        \    ],
        \  },
        \]
  unlet pat_vb_bol
  unlet pat_vb_eol
  " }}}

  " cmake-rules {{{
  let rules += [
        \  { 'cmake' :
        \    [
        \      {
        \        'pattern' : '^\s*&word&(.*)\%#',
        \        'end' : 'end&word%',
        \        'word' : [ 'foreach', 'function', 'if', 'macro', 'while' ],
        \      },
        \    ],
        \  },
        \]
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
