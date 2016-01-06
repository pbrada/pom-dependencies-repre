#  pom_analyzer.rb
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


require "rexml/document"

# Analyzes the contents of POM file, to extract information on the 
# artefact and its dependencies.
class PomAnalyzer

	# the document representation
	@pom
	
	# Constructor, takes a File reference to the POM file.
	def initialize(pomfile)
		@pom = REXML::Document.new pomfile
	end
	
	def init_from_string(string)
		@pom = REXML::Document.new string
	end
	
	def get_artefact_coords
		root = @pom.root
		res = Hash.new
		res["gid"] = root.elements["groupId"].text
		res["aid"] = root.elements["artifactId"].text
		res["vers"] = root.elements["version"].text
		return res
	end
	
	def get_dependency(elem)
		res = Hash.new
		res["gid"] = elem.elements["groupId"].text
		res["aid"] = elem.elements["artifactId"].text
		res["vers"] = elem.elements["version"].text
		res["scope"] = elem.elements["scope"].text
		return res
	rescue	# most probably a XML parsing error due to missing elements
		if (res["gid"] == nil) or (res["aid"] == nil)
			# missing required parts of dependency declaration, bail out
			res = nil
			raise "missing required elements in a dependency declaration"
		else	# only optional parts missing, bear with that
			return res
		end
	end
	
	def get_dependencies
		root = @pom.root
		deps = Array.new
		root.elements.each("dependencies/dependency") do |d|
			puts "(analyzing dep decl #{d})"
			begin
				dep = get_dependency d
			rescue	# is here to catch RuntimeError due to bad 'd' syntax
				puts "(syntax error in dependency decl: #{d})"
			else 
				deps.push dep
			end
		end
		return deps
	end
	
end


# ----- crude testing/trials of functionality -----

xmlstring = <<EOF
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <parent>
    <groupId>org.apache.commons</groupId>
    <artifactId>commons-parent</artifactId>
    <version>7</version>
  </parent>
  <modelVersion>4.0.0</modelVersion>
  <groupId>commons-io</groupId>
  <artifactId>commons-io</artifactId>
  <version>1.4</version>
  <name>Commons IO</name>

  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>
    <dependency>
      <groupId>G</groupId>
      <artifactId>A</artifactId>
      <version>3</version>
      <scope>nope</scope>
    </dependency>

    <dependency> <!-- missing optional elements -->
      <groupId>G</groupId>
      <artifactId>A</artifactId>
    </dependency>
    <dependency> <!-- missing required element -->
      <artifactId>A</artifactId>
      <version>3</version>
    </dependency>

  </dependencies>

  <inceptionYear>2002</inceptionYear>
  <description>
        Commons-IO contains utility classes, stream implementations, file filters, file comparators and endian classes.
  </description>

  <url>http://commons.apache.org/io/</url>
</project>
EOF

pa = PomAnalyzer.new nil
pa.init_from_string xmlstring
puts "artefact:"
puts pa.get_artefact_coords
puts "dependencies:"
pa.get_dependencies.each { |d| puts d }
puts "---"
