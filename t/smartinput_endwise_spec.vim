filetype plugin indent on
syntax on

runtime! plugin/smartinput.vm
call smartinput#define_default_rules()
call smartinput_endwise#define_default_rules()

function! ToBeExpandedTo(raw, ...)
  execute "normal! i" . a:raw
  execute "normal A\<CR>"
  let actual = getline(1, '$')

  let expected = a:000
  if actual == expected
    return 1
  else
    throw 'expected "' . a:raw . '" to be expanded to ' . string(expected) . ' but actual is ' . string(actual)
  endif
endfunction

function! ToBeNotExpanded(raw)
  return ToBeExpandedTo(a:raw, a:raw, '')
endfunction

call vspec#customize_matcher('to_be_expanded_to', function('ToBeExpandedTo'))
call vspec#customize_matcher('to_be_not_expanded', function('ToBeNotExpanded'))

describe 'smartinput_endwise'

  " vim "{{{
  describe 'vim'

    before
      new +setf\ vim
      " disable comment continuation
      setl formatoptions-=r shiftwidth=2
    end

    after
      close!
    end

    it 'typical function'
      Expect 'function hoge()' to_be_expanded_to 'function hoge()', '', 'endfunction'
    end

    it 'typical function with bang'
      Expect 'function! hoge()' to_be_expanded_to 'function! hoge()', '', 'endfunction'
    end

    it 'short-handed function'
      Expect 'fu hoge()' to_be_expanded_to 'fu hoge()', '', 'endfu'
    end

    it 'function in comment'
      Expect '" function! hoge()' to_be_not_expanded
    end

    it 'function but typo'
      Expect 'xfunction! hoge()' to_be_not_expanded
    end

    it 'typical if'
      Expect 'if a:bc== s:huga("end")' to_be_expanded_to 'if a:bc== s:huga("end")', '', 'endif'
    end

    it 'typical while'
      Expect 'while a==10 " while' to_be_expanded_to 'while a==10 " while', '', 'endwhile'
    end

    it 'short-handed while'
      Expect 'wh a==10 " while' to_be_expanded_to 'wh a==10 " while', '', 'endwh'
    end

    it 'typical for'
      Expect 'for var in list' to_be_expanded_to 'for var in list', '', 'endfor'
    end

    it 'typical try'
      Expect 'try' to_be_expanded_to 'try', '', 'endtry'
    end

    it 'nested for'
      Expect 'function! hoge()for i in var' to_be_expanded_to 'function! hoge()', '  for i in var', '', '  endfor'
    end

  end
  " }}}

  " ruby {{{
  describe 'ruby'

    before
      new +setf\ ruby
      setl formatoptions-=r shiftwidth=2
    end

    after
      close!
    end

    it 'typical module'
      Expect "module Hoge" to_be_expanded_to 'module Hoge', '', 'end'
    end

    it 'typical module with indent'
      Expect "  module Hoge" to_be_expanded_to '  module Hoge', '', '  end'
    end

    it 'unnamed module'
      Expect "module" to_be_expanded_to 'module', '', 'end'
    end

    it 'module within a string literal'
      Expect "'module Hoge" to_be_not_expanded
    end

    it 'module next a string literal'
      Expect "'module Hoge'" to_be_not_expanded
    end

    it 'module as oneliner'
      Expect "module H; end" to_be_not_expanded
    end

    it 'module but typo'
      Expect "nmodule H" to_be_not_expanded
    end

    it 'module as a comment'
      Expect '# module H' to_be_not_expanded
    end

    it 'in module'
      %delete
      execute "normal! imodule Hoge\<CR>end\<Esc>Oa = 1"
      execute "normal a\<CR>"
      Expect getline(1, '$') == ['module Hoge', '  a = 1', '', 'end']
    end

    it 'typical def'
      Expect "def hoge" to_be_expanded_to 'def hoge', '', 'end'
    end

    it 'def with argument'
      Expect "def hoge(foo, bar)" to_be_expanded_to 'def hoge(foo, bar)', '', 'end'
    end

    it 'def with indent'
      Expect "    def hoge(foo, bar)" to_be_expanded_to '    def hoge(foo, bar)', '', '    end'
    end

    it 'def within a string literal'
      Expect "'def hoge(foo, bar)" to_be_not_expanded
    end

    it 'def next a string literal'
      Expect "'def hoge(foo, bar)'" to_be_not_expanded
    end

    it 'def as an oneliner'
      Expect "def hoge(foo, bar); 100 end" to_be_not_expanded
    end

    it 'def as a singleton method'
      Expect "    def x.hoge(foo, bar)" to_be_expanded_to '    def x.hoge(foo, bar)', '', '    end'
    end

    it 'typical class'
      Expect 'class Hoge' to_be_expanded_to 'class Hoge', '', 'end'
    end

    it 'inherited class'
      " avoid vim-vspec weired behavior
      let l:expect = 'class Hoge < Fuga'
      Expect l:expect to_be_expanded_to 'class Hoge < Fuga', '', 'end'
    end

    it 'singleton class'
      let l:expect = 'class << Fuga'
      Expect l:expect to_be_expanded_to 'class << Fuga', '', 'end'
    end

    it 'class as an oneliner'
      Expect 'class Hoge; end' to_be_not_expanded
    end

    it 'typical if'
      let l:expect = 'if hoge == fuga'
      Expect l:expect to_be_expanded_to 'if hoge == fuga', '', 'end'
    end

    it 'if as an expression'
      Expect 'hoge = if 1' to_be_expanded_to 'hoge = if 1', '', '       end'
    end

    it 'if modifier statement'
      Expect 'hoge = 1 if fuga' to_be_not_expanded
    end

    it 'typical while'
      let l:expect = 'while x'
      Expect l:expect to_be_expanded_to 'while x', '', 'end'
    end

    it 'typical while'
      let l:expect = 'while x'
      Expect l:expect to_be_expanded_to 'while x', '', 'end'
    end

    it 'typical begin rescue'
      Expect 'begin' to_be_expanded_to 'begin', '', 'end'
    end

    it 'begin in comment'
      Expect '# begin' to_be_not_expanded
    end

    it 'typical block'
      Expect 'hoge do' to_be_expanded_to 'hoge do', '', 'end'
    end

    it 'block with a variable'
      Expect 'hoge do |var|' to_be_expanded_to 'hoge do |var|', '', 'end'
    end

    it 'block in a comment'
      Expect '# do' to_be_not_expanded
    end

  end
  " }}}

  " sh {{{
  describe 'sh'

    before
      new
      setl filetype=sh formatoptions-=r shiftwidth=2
    end

    after
      close!
    end

    it 'if'
      Expect 'if' to_be_expanded_to 'if', '', 'fi'
    end

    it 'typical if'
      Expect 'if test ${ret} -eq 0; then' to_be_expanded_to 'if test ${ret} -eq 0; then', '', 'fi'
    end

    it 'if in a comment'
      Expect '# if' to_be_not_expanded
    end

    it 'case'
      " this indentation is strange but endwise compatible
      Expect 'case' to_be_expanded_to 'case', '', 'esac'
    end

    it 'typical case'
      Expect 'case "$var" in' to_be_expanded_to 'case "$var" in', '', 'esac'
    end

    it 'do'
      Expect 'do' to_be_expanded_to 'do', '', 'done'
    end

    it 'do in a comment'
      Expect '# do' to_be_not_expanded
    end

    " FIXME: Can not obtain syntax as a Comment
    " it 'do in a multiline comment'
    "   let l:expect = ": <<\<CR>do"
    "   Expect l:expect to_be_not_expanded
    " end

    it 'while'
      Expect 'while "$var"; do' to_be_expanded_to 'while "$var"; do', '', 'done'
    end
  end
  " }}}

  " lua {{{
  describe 'lua'

    before
      new +setf\ lua
      setl formatoptions-=r shiftwidth=2
    end

    after
      close!
    end

    it 'typical function'
      Expect 'function foo()' to_be_expanded_to 'function foo()', '', 'end'
    end

    it 'typical function after string'
      Expect '"string function" function foo()' to_be_expanded_to '"string function" function foo()', '', 'end'
    end

    it 'typical function after strings'
      Expect '"string function" ' . "'string'" . '"string" function foo()' to_be_expanded_to '"string function" ' . "'string'" . '"string" function foo()', '', 'end'
    end

    it 'typical function after strings contain escape doble quote'
      Expect '"string function\" string" function foo()' to_be_expanded_to '"string function\" string" function foo()', '', 'end'
    end

    it 'function but in comment'
      Expect '--function' to_be_not_expanded
    end

    it 'function but typo'
      Expect 'xfunction foo()' to_be_not_expanded
    end

    it 'typical then'
      Expect 'if a== bar("end") then' to_be_expanded_to 'if a== bar("end") then', '', 'end'
    end

    it 'then but in comment'
      Expect '--then' to_be_not_expanded
    end

    " A syntax should become String, but it becomes Constant, and a test fails.
    " it 'then but in string'
    "   Expect '"then' to_be_not_expanded
    " end
  end
  " }}}

  " vb {{{
  describe 'vb'

    before
      new +setf\ vb
      setl formatoptions-=r shiftwidth=2
    end

    after
      close!
    end

    it 'typical Class'
      Expect 'Class foo' to_be_expanded_to 'Class foo', '', 'End Class'
    end

    it 'typical Class after string'
      Expect '"string Class" Class foo' to_be_expanded_to '"string Class" Class foo', '', 'End Class'
    end

    it 'typical Class after strings'
      Expect '"string Class" "string" Class foo' to_be_expanded_to '"string Class" "string" Class foo', '', 'End Class'
    end

    it 'typical Class after strings contain escape doble quote'
      Expect '"string Class"" string" Class foo' to_be_expanded_to '"string Class"" string" Class foo', '', 'End Class'
    end

    it 'typical Class mixed case'
      Expect 'cLaSs foo' to_be_expanded_to 'cLaSs foo', '', 'End Class'
    end

     it 'Class but in string'
       Expect '"Class' to_be_not_expanded
     end

    it 'Class but typo'
      Expect 'xClass foo' to_be_not_expanded
    end

    it 'typical Enum with accessmodifier and datatype'
      Expect 'Public Enum As Intger' to_be_expanded_to 'Public Enum As Intger', '', 'End Enum'
    end

    it 'typical Function'
      Expect 'Function foo()' to_be_expanded_to 'Function foo()', '', 'End Function'
    end

    it 'typical Module'
      Expect 'Module foo' to_be_expanded_to 'Module foo', '', 'End Module'
    end

    it 'typical Namespace'
      Expect 'Namespace foo' to_be_expanded_to 'Namespace foo', '', 'End Namespace'
    end

    it 'typical Sub'
      Expect 'Sub foo(arg As String)' to_be_expanded_to 'Sub foo(arg As String)', '', 'End Sub'
    end

    it 'typical Property'
      Expect 'Property Get foo' to_be_expanded_to 'Property Get foo', '', 'End Property'
    end

    it 'typical If'
      Expect 'If a=0 Then' to_be_expanded_to 'If a=0 Then', '', 'End If'
    end

    it 'typical For'
      Expect 'For Each item in col' to_be_expanded_to 'For Each item in col', '', 'Next'
    end

    it 'typical Select'
      Expect 'Select Case' to_be_expanded_to 'Select Case', '', 'End Select'
    end
  end
  " }}}
end
