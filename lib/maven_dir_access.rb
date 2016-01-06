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

class MavenDirAccess
	@rootpath = ''
	@entries
	@log
	
	# Create new instance with empty list of maven artefacts.
	def initialize()
		@log = Logger.new(STDERR)
		@log.level = Logger::DEBUG
		@reclevel = 0
		
		@entries = Array.new
	end
	
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

		@entries = Array.new if clean
		@entries.concat(_scan_dir_for_artefact_names())
	end
	
	# Returns a list of artefact names available in the repo.
	def get_artefacts
		return @entries
	end
	
	# Returns the File of the _artefact_'s POM. Params:
	# * String artefact = artefact name
	def get_pom_file(artefact)
		p = artefact.pom[0]  # if more POMs exist, take the first one
		f = File.new(File.join(artefact.root, artefact.path, p))
		return f
	end

	# ----- 
	private
	
	# creates and returns a basic list of artefacts available in the repo
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
	
	# starting from 'top' directory, recurse into its subdirs and look for those
	# which contain a *.pom file - add those to a list of artefact
	def _traverse_dir(sub)
		@reclevel += 1
		@log.debug("traversing into #{sub} (recursion level #{@reclevel})")
		artefacts = Array.new
		path = File.join(@rootpath, sub)
		Dir.chdir(path)
		pom = Dir.glob('*.pom')
		if (pom.size > 0)	# found POM, add to found 
			a = Artefact.new(sub, @rootpath, pom)
			@log.info("found artefact directory #{sub} -> artefact #{a}")
			artefacts.push(a)
		end
		# investigate path content
		subs = Dir.entries(path) - [".", ".."]
		subs.each do |s|
			@log.debug("dir entry #{s}")
			next if not File.directory?(File.join(path,s))
			ssub = File.join(sub, s)
			# recurse into each subdir
			arts = _traverse_dir(ssub)
			# and accumulate artefacts found within
			artefacts |= arts
		end
		@reclevel -= 1
		@log.debug("leaving #{sub} with #{artefacts.size} new artefacts")
		return artefacts
	end
	
end
