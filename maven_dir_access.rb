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

# Traverses a Maven repository directory tree and stores the data
# about artefacts available in the repository.

class MavenDirAccess
	@rootpath = ''
	@entries
	@log
	
	def initialize(path)
		_entries = Dir.entries(path)
		if not _entries.include?('repository')
			raise 'Not a Maven repository'
		end
		@rootpath = File.join( path, 'repository')
		@log = Logger.new(STDERR)
		@log.level = Logger::INFO

		@entries = _scan_dir_for_artefact_names
	end
	
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
		return artefacts
	end
	
	# starting from 'top' directory, recurse into its subdirs and look for those
	# which contain a *.pom file - add those to a list of artefact
	def _traverse_dir(sub)
		@log.info("traversing into #{sub}")
		artefacts = Array.new
		path = File.join(@rootpath, sub)
		Dir.chdir(path)
		pom = Dir.glob('*.pom')
		if (pom.size > 0)	# found POM, add to found 
			art = _path2art(sub)
			@log.info("found artefact directory #{sub} -> artefact #{art}")
			artefacts.push(art)
		end
		# recurse into subdirs, if any
		subs = Dir.entries(path) - [".", ".."]
		subs.each do |s|
			@log.info("dir entry #{s}")
			next if not File.directory?(File.join(path,s))
			ssub = File.join(sub, s)
			arts = _traverse_dir(ssub)
			artefacts |= arts
		end
		@log.info("leaving #{sub} with #{artefacts.size} new artefacts")
		return artefacts
	end
	
	# takes a subpath of maven repo - which is assumed to be a directory
	# holding a POM file - and from the path string creates artefact string
	#
	# Example: cz/zcu/kiv/crce/crce-reactor/2.1.0-SNAPSHOT/ -> 
	# cz.zcu.kiv.crce.crce-reactor
	def _path2art(path)
		artpath = path.sub(/\/[^\/]+\/?$/,"")	# remove last path component
		#artpath.sub!(/\/$/,"")  # remove trailing slash
		artpath.tr!('/','.')	# turn into gid-artefactid
		return artpath
	end
	
	# takes a subpath of maven repo - which is assumed to be a directory
	# holding a POM file - and from the path string creates artefact version
	#
	# Example: cz/zcu/kiv/crce/crce-reactor/2.1.0-SNAPSHOT/ -> 
	# 2.1.0-SNAPSHOT
	def _path2ver(path)
		@log.warn("STUB")
		return ""
	end
	
	def get_artefacts
	# returns a list of artefact names available in the repo
		return @entries
	end
	
	def get_artefact_pom
		# returns the File of the artefact's POM
		return nil
	end
	
end
