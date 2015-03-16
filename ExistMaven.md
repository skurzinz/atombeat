To make exist 1.4.0 artifacts available via Maven, I downloaded exist 1.4 and installed on my local file system, then did...

```
cd /opt/exist-1.4.0-rev10440/
# build exist
ant
# manually install jars into local maven repository
mvn install:install-file -Dfile=exist.jar -DgroupId=org.exist-db -DartifactId=exist -Dversion=1.4.0 -Dpackaging=jar
mvn install:install-file -Dfile=exist-optional.jar -DgroupId=org.exist-db -DartifactId=exist-optional -Dversion=1.4.0 -Dpackaging=jar
mvn install:install-file -Dfile=lib/core/xmldb.jar -DgroupId=org.exist-db -DartifactId=exist-xmldb -Dversion=1.4.0 -Dpackaging=jar
mvn install:install-file -Dfile=lib/extensions/exist-versioning.jar -DgroupId=org.exist-db -DartifactId=exist-versioning -Dversion=1.4.0 -Dpackaging=jar
```