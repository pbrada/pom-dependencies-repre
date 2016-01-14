#  maven_dir_access.rb
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

require 'logger'

require_relative 'artefact'


# Traverses a Maven repository directory tree and stores the data
# about artefacts available in the repository.
# 
# A "DAO" class that returns domain objects (Artefact, Dependency).
# 
class MavenDirAccess

	attr_reader		:artefacts		# : list of Artefact
	
	@rootpath = ''
	@log = nil 		# : Logger
	
	# Create new instance with empty list of maven artefacts.
	def initialize()
		@log = Logger.new(STDERR)
		@log.level = $LOGLEVEL
		@reclevel = 0	# recursion level, just for interest
		
		@artefacts = Array.new
	end
	
	# Creates the representation of artefacts and their dependencies
	# stored in the repository at _path_. Adds to any already existing
	# artefact representations unless _clean_ is set to 'true'.
	def create_artefact_representation(path, clean=true)
	
		# first, get artefact list from directory structure
		scan_dir path, clean
		
		# second, for each artefact get its dependencies
		pa = PomAnalyzer.new
		@artefacts.each do |a|
			#puts "#{a}\n   (#{a.inspect})"
			file_of_a = get_pom_file a
			pa.init_from_file file_of_a
			a.add_dependencies pa.get_dependencies
		end
	end
	
	# Returns the File of the _artefact_'s POM. Params:
	# * String artefact = artefact name
	def get_pom_file(artefact)
		p = artefact.pom[0]  # if more POMs exist, take the first one
		f = File.new(File.join(artefact.root, artefact.path, p))
		@log.debug "returning #{f} as POM file from path #{p}"
		return f
	end

	# ----- 
	private
	
	# Scans the given path for maven artefacts.
	# Params:
	# * String path	= filesystem path that should be a maven repository root
	# * bool clean	= true: cleanup any previous artefacts found, false: add to previously found
	def scan_dir(path, clean=true)
		
		path = File.expand_path(path)
		if not Dir.entries(path).include?('repository')
			raise 'Not a Maven repository'
		end
		@rootpath = File.join(path, 'repository')

		@artefacts = Array.new if clean
		@artefacts.concat _scan_dir_for_artefact_names()
	end
	
	# Creates and returns a basic list of artefacts available in the repo.
	def _scan_dir_for_artefact_names
		top_groups = Dir.entries(@rootpath) - [".", ".."]
		# recurse into each top group-id directories until *.pom files are discovered
		# and return the artefact-id list
		artefacts = Array.new
		top_groups.each do |g|
			@log.info("--- top #{g}")
			if File.directory?(File.join(@rootpath,g))
				artefacts.concat( _traverse_dir(g) ) 
			end
		end
		artefacts.sort!
		return artefacts
	end
	
	# Starting from 'top' directory, recurse into its subdirs and look for those
	# which contain a *.pom file - add those to a list of artefacts,
	# and finally return this list.
	def _traverse_dir(top)
		@reclevel += 1
		@log.debug("traversing into #{top} (recursion level #{@reclevel})")
		artefacts = Array.new
		path = File.join(@rootpath, top)
		Dir.chdir(path)
		pom = Dir.glob('*.pom')
		if (pom.size > 0)	# found POM, add to found 
			a = Artefact.new(top, @rootpath, pom)
			@log.info("found artefact directory #{top} -> artefact #{a}")
			artefacts.push(a)
		end
		# investigate path content
		subs = Dir.entries(path) - [".", ".."]
		subs.each do |s|
			@log.debug("dir entry #{s}")
			next if not File.directory?(File.join(path,s))
			ssub = File.join(top, s)
			# recurse into each subdir
			arts = _traverse_dir(ssub)
			# and accumulate artefacts found within
			artefacts |= arts
		end
		@reclevel -= 1
		@log.debug("leaving #{top} with #{artefacts.size} new artefacts")
		return artefacts
	end
	
end
