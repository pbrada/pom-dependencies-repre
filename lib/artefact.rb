#  artefact.rb
#  
#  Copyright 2015 Premek Brada <brada@xubuntu1504vbox>
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


# Represents an Maven artefact, via its gid+aid+version, together
# with the repository where it is stored.
class Artefact

	attr_accessor	:gid, :aid, :vers, :path, :root, :pom
	
	@gid
	@aid
	@vers
	
	# list of Dependency items
	@dependencies
	
	# path within repository where the artefact is found
	@path
	# path of repository root directory
	@root
	# name(s) of POM file(s) for the artefact
	@pom
	
	# Instantiate by parsing a sub-path of maven repo
	# (e.g. "ch/qos/logback/logback-core/1.1.3").
	def initialize(path,root="/",pom="")
		@root = root
		@path = path
		@pom = pom
		# empty dependency list at the beginning
		@dependencies = Array.new
		# parse the path to get artefact coordinate elements
		# e.g. -> ch.qos.logback , logback-core , 1.1.3
		elems = path.split("/")		
		@vers = elems[-1]
		@aid = elems[-2]
		@gid = elems[0...-2].join('.')
	end
	
	# Adds a dependency
	def add_dependency(dep)
		@dependencies.push dep
	end
	
	# Appends an array of Dependency items to the already stored ones.
	def add_dependencies(deps)
		@dependencies.concat deps
	end
	
	def get_dependencies
		return @dependencies
	end
	
	# Given a hash with "gid","aid","vers" returns true if the hash
	# represents the same artefact as this object; false otherwise.
	def check(artdata)
		res = ((@gid == artdata["gid"]) and (@aid == artdata["aid"]) and (@vers == artdata["vers"]))
	end
	
	def get_coordinates
		return "#{gid}:#{aid}:#{vers}"
	end
	
	def to_s
		return "#{get_coordinates}@#{@root}"
	end
	
	# Returns a string with this artefacts full representation 
	# in the given format.
	# _fmt_ can be one of "txt", "yml", "xml", "graphml"
	def get_representation(fmt="txt", scope=false)
		res = ""
		
		case fmt
		when "yml" then
			puts "not yet implemented"
		when "xml" then
			puts "not yet implemented"
		when "graphml" then
			puts "not yet implemented"
		else	# return "txt" by default
			res += get_coordinates + "\n"
			@dependencies.each do |d|
				if scope then
					res += "\t#{d}\n"
				else
					res += "\t#{d.get_coordinates}\n"
				end
			end
		end
		
		return res
	end
	
	def <=>(other)
		return self.get_coordinates <=> other.get_coordinates
	end
	
end


