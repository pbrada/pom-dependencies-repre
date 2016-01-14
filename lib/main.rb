#  main.rb
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

require_relative 'maven_dir_access'
require_relative 'pom_analyzer'

require 'logger'

$LOGLEVEL = Logger::ERROR

class MainClass

	@mvn	# maven repo accessor
	
	def initialize(dirname)
		@dirname = dirname
		if not File::exists?(@dirname)
			raise "Directory #{dirname} does not exist"
		end
		@mvn = MavenDirAccess.new()
	end
	
	def run
		puts "initialized with directory: #{@dirname}"
		puts "running maven scan..."

		# obtain data
		@mvn.create_artefact_representation @dirname
		
		puts "... and the result is:"
		@mvn.artefacts.each do |a| 
			#puts "#{a}\n   (#{a.inspect})"
			puts a.get_representation
		end

	end
	
end
