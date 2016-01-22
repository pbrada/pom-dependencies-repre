#  pdr.rb -- driver script for "POM Dependency Representation" tool
#  
#  Copyright 2015 Premek Brada <p.brada@gmail.com>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  

require 'main'

dir = ARGV[0]
if not dir 
	puts "Hallo there, would you please provide me with a path to a Maven repo?"
	exit
elsif not File.directory?(dir) 
	puts "Listen, I need a _directory path_ as the argument. #{dir} is something else."
	exit
end

prog = MainClass.new(dir)
prog.run
