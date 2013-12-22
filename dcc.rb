#!/usr/bin/env ruby
#
# @param    input file name
# @param    line number
# @return   doxygen comment 
# @copyright pebble8888@gmail.com
#

# argument
if ARGV.length != 2
  puts "Usage: dcc.rb {filename} {linenumber}"
  exit
end

inputfilename = ARGV[0]
linenumber = ARGV[1].to_i

# 
def putcomment( retval, params )
  retstr = "/**\n"
  retstr += " * @brief\n"
  params.each do |param|
    retstr += " * @param [in]  #{param} \n"
  end 
  retstr += " * @return #{retval} \n"
  retstr += " */\n"
  print retstr
end

# objc
def parse_objc( str )
  case str[0]
  when "+","-"
  else
    p "No method found!"
    return 
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
      param = param.split( "\s" ).at(0)
      #p param
      val = type + param
      params.push val
    end
  end
  params[-1] =~ /\(.*\)/
  retval = $&  
  params.delete_at(-1)
  params.reverse!

  putcomment( retval, params ) 
end

# c
def parse_c( str )
  ary = str.split( /[,\(\)]/ )
  retval = ary.at(0).split( "\s").at(0)
  params = []
  ary.delete_at(0)
  ary.each do |val|
    params.push val.strip!
  end
  putcomment( retval, params )
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
lineindex = 0;
open(inputfilename) do |file|
  while l = file.gets
    lineindex += 1
    if lineindex >= linenumber 
      str += "\s"
      str += l.chomp
      if str =~ /{/ then
        case filepattern
        when :filepattern_objc
          parse_objc str.split("{").at(0).strip!
        when :filepattern_c
          parse_c str.split("{").at(0).strip!
        end
        break
      end
    end
  end
end

