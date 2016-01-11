#  dependency.rb
#  
#  Copyright 2016 Premek Brada <brada@brada-ThinkPad-R51>
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


# Represents the maven data about an artefact's dependency.
class Dependency

	attr_reader :gid, :aid, :vers, :scope
	
	# Create from a hash with coordinates.
	def initialize(data)
		@gid = data["gid"]
		@aid = data["aid"]
		@vers = data["vers"]	# optional
		@scope = data["scope"]	# optional
	end
	
	def to_s
		return "#{gid}:#{aid}:#{vers} (#{scope})"
	end
end


