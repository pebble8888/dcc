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
vim_buffer = VIM::Buffer.current
inputfilename = vim_buffer.name
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
def parse_objc( str )
  case str[0]
  when "+","-"
  else
    return nil
  end
  str.slice!(0).strip!
  ary = []
  while (r=str.rindex( ":")) != nil
    ary.push str.slice((r+1)..-1)
    str.slice!(r..-1)
  end
  ary.push str

  params = []
  ary.each do |item|
    if item =~ /\(.*\)/ then
      type = $&
      #p type
      param = $'
      param = param.split("\s").at(0)
      #p param
      val = type + param
      params.push val
    end
  end
  params[-1] =~ /\(.*\)/
  retval = $&  
  params.delete_at(-1)
  params.reverse!

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

str=""
for lineindex in linenumber..vim_buffer.count  
  l = vim_buffer[lineindex]
  str += "\s"
  str += l.chomp
  if str =~ /{/ then
    case filepattern
    when :filepattern_objc
      results = parse_objc( str.split("{").at(0).strip! )
      unless results then
        results = parse_c( str.split("{").at(0).strip! )
      end
    when :filepattern_c
      results = parse_c( str.split("{").at(0).strip! )
    end
    break
  end
end

for i in 0..(results.count-1)
  vim_buffer.append( linenumber-1+i, results[i] )
end

EOF
endfunction

if !exists('g:dcc_no_default_key_mappings')
  noremap ,d :call DoxygenCommentCreatorRuby()<CR>
endif
