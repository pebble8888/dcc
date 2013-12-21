#!/usr/bin/env ruby
#
# @param    input file name
# @param    line number
# @return   doxygen comment 
#

# argument
if ARGV.length != 2
  puts "Usage: doxygenobjc.rb {filename} {linenumber}"
  exit
end

inputfilename = ARGV[0]
linenumber = ARGV[1].to_i

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

  retstr = "/**\n"
  retstr += " * @brief\n"
  params.each do |param|
    retstr += " * @param [in]  #{param} \n"
  end 
  retstr += " * @return #{retval} \n"
  retstr += " */\n"
  print retstr
end

# c
# TODO:not implemented
def parse_c( str )
  p "#{str}"
end

# main
column=inputfilename.split(/\./)
case column[-1]
when "m","mm","h"
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
      str += " "
      str += l.chomp
      if str =~ /{/ then
        parse_objc str.split("{").at(0).strip!
        break
      end
    end
  end
end

