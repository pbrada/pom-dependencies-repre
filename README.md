
POM dependencies discovery and representation creating tool
===============================

Status
------

Under development, information below serves as a sketch specification
(not as tool description).


Usage
-----

bin/pdr <directory> [filename]


Description
-----------

Traverses a directory tree under a given root (assumed to be a Maven
cache root) and reads pom.xml files. From the artefact coordinates
and <dependencies> creates a dependency graph, which is saved in 
GraphML format.

Version history

* 0.1 -- lists artefacts (not versions) in plain text format
* 0.2 -- lists artefacts, and versions of each, in plain text format
* 0.8 -- for each artefact (not by versions) lists dependencies (artefacts, not versions) in plain text format
* 0.9 -- same as 0.8 but outputs basic GraphML 

Known issues

* ignores info stored in <dependencyManagement> declarations, leading to 
  dependencies without versions ("javax.mail:mail:")
* does not expand maven keywords (e.g. org.springframework:spring-beans:${project.version})
