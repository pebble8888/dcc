"
" DoxygenCommentCreator vim plugin
" pebble8888/dcc.vim
" pebble8888@gmail.com
" 2013-12-31 pebble8888 initial 
"
" You need if_ruby enabled vim.
" Please check +ruby to type :version.
"
" Support C/C++/Objective-C function comment only
"

function! DoxygenCommentCreatorRuby()
ruby << EOF
# current opening file
vim_buffer = VIM::Buffer.current
# current file name
inputfilename = vim_buffer.name
# current line number (0-)
linenumber = VIM::Buffer.current.line_number

#
def comments( retval, params )
  lines = []
  lines.push "/**"
  lines.push " * @brief "
  params.each do |param|
    lines.push " * @param [in]  #{param} "
  end
  lines.push " * @return #{retval} "
  lines.push " */"
end

# objc
# ex "- (void)method:(NSUInteger *)arg1 Hoge:(NSUInteger *)arg2" 
def parse_objc( str )
  unless str.length > 0 then
    return nil
  end
  case str[0]
  when "+","-"
  else
    return nil
  end
  # delete first character + or -
  # delete first space and last space
  str.slice!(0).strip!
  # "(void)method"
  # "(NSUInteger *)arg1 Hoge"
  # "(NSUInteger *)arg2"
  ary = []
  while (r=str.rindex( ":")) != nil
    ary.push str.slice((r+1)..-1)
    str.slice!(r..-1)
  end
  ary.push str

  params = []
  ary.each do |item|
    # found (hoge)
    if item =~ /\(.*\)/ then
      # matched text
      type = $&
      # trailing text
      tmp = $'
      param = tmp.strip().split("\s").at(0)
      val = type + param
      params.push val
    end
  end
  if params.length > 0 then
    # found (hoge)
    params[-1] =~ /\(.*\)/
    # matched text
    retval = $&
    params.delete_at(-1)
    params.reverse!
  else
    return nil
  end

  comments( retval, params )
end

# c
def parse_c( str )
  ary = str.split( /[,\(\)]/ )
  retval = ary.at(0).split("\s").at(0)
  params = []
  ary.delete_at(0)
  ary.each do |val|
    params.push val.strip
  end
  comments( retval, params )
end

# main
column=inputfilename.split(/\./)
case column[-1]
when "m","mm"
  filepattern=:filepattern_objc
when "c","cpp"
  filepattern=:filepattern_c
else
  p "This file type is unknown!"
  exit
end

# next line ~ last line
str=""
for lineindex in linenumber..(vim_buffer.count-1)  
  l = vim_buffer[lineindex]
  str += "\s"
  # remove last return code
  str += l.chomp
  # found {
  if str =~ /{/ then
    case filepattern
    when :filepattern_objc
      # .m/.mm
      # parse for Objective-C
      results = parse_objc( str.split("{").at(0).strip! )
      unless results then
        # parse for c
        results = parse_c( str.split("{").at(0).strip! )
      end
    when :filepattern_c
      # .c/.cpp
      results = parse_c( str.split("{").at(0).strip! )
    end
    break
  end
end

if results then
  for i in 0..(results.count-1)
    vim_buffer.append( linenumber-1+i, results[i] )
  end
end

EOF
endfunction

if !exists('g:dcc_no_default_key_mappings')
  noremap ,d :call DoxygenCommentCreatorRuby()<CR>
endif
