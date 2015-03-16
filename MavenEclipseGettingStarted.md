# Getting Started with Maven, Eclipse and Web Applications #

Here are my notes on setting up and using maven with eclipse to develop web applications.

## Install Eclipse with Web Tools ##

There are a couple of options here.

I'm using ubuntu 10.04 as my desktop os, and eclipse 3.5 is available through apt, so one option is:

```
sudo apt-get install eclipse
```

Then, to install web tools, run eclipse and do...

  * Help > Install New Software...
  * Work with: Galileo Update Site
  * Select all under "Web, XML and Java EE Development"
  * Next >
  * Next >
  * Accept and Finish
  * Restart Eclipse

As an aside, I also prefer to work with sun java rather than openjdk, so I also do...

```
# close eclipse
sudo gedit /etc/apt/sources.list # enable the partner repository
sudo apt-get update
sudo apt-get install sun-java6-jdk
sudo update-java-alternatives --set java-6-sun
java -version # check it's working
# run eclipse
```

The other option is, of course, to download the pre-packaced eclipse for java ee developers bundle from the eclipse site and install manually.

## Install Subversion ##

This is another aside, but to install svn for both command line use and eclipse I do:

```
sudo apt-get install subversion
```

...then in eclipse:

  * Help > Install New Software...
  * Work with: Galileo Update Site
  * Select "Subversive SVN Team Provider" under "Collaboration"
  * Next >
  * Finish
  * Restart Eclipse

You still need to get an svn connector to use svn in eclipse. After eclipse has restarted, try this:

  * Window > Preferences
  * Team > SVN

This should trigger the connector discovery feature:

  * Select "SVN Kit 1.3.0" (compatible with svn 1.6.x)
  * Finish
  * (Install) Next >
  * (Install Details) Next >
  * (Review Licenses) Accept and Finish
  * Restart Eclipse

## Install Maven ##

Again, I'm on ubuntu, so I do:

```
sudo apt-get install maven2
```

## Install M2Eclipse ##

This is the maven-eclipse plugin. To install:

  * Help > Install New Software...
  * Work with: http://m2eclipse.sonatype.org/sites/m2e
  * Select "Maven Integration for Eclipse"
  * Next >
  * (Install Details) Next >
  * (Review Licenses) Accept and Finish
  * Restart Eclipse

Detailed installation instructions are also available at http://m2eclipse.sonatype.org/installing-m2eclipse.html

## Create a New Web Project ##

There are probably other ways to do this, but here's one that works for me.

Start by using a maven archetype to create the initial project structure:

```
cd ~/workspace # my eclipse workspace
mvn archetype:create -DgroupId=org.example.webapp -DartifactId=example-webapp -DarchetypeArtifactId=maven-archetype-webapp # create the project structure and initial pom
cd example-webapp
mvn clean package # test maven can compile and package ok
ls -al target # should see example-webapp.war
```

...then create eclipse project files with web tools support:

```
mvn -Dwtpversion=2.0 eclipse:eclipse
ls -al # should see .classpath .project and .settings
```

Now import the project into eclipse:

  * File > Import
  * General > Existing Projects into Workspace
  * Next >
  * Select root directory: /home/joebloggs/workspace
  * Select the project to import
  * Finish

At this stage I get an error reported that the "Java compiler level does not match the version of the install Java project facet." To get both maven and eclipse lined up to compile to Java 1.6, I do:

  * Right click the new project
  * Maven > Enable Dependency Management
  * Give it a couple of seconds.

...then edit the pom.xml to look like:

```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>org.example.webapp</groupId>
  <artifactId>example-maven-webapp</artifactId>
  <packaging>war</packaging>
  <version>1.0-SNAPSHOT</version>
  <name>Example Maven Webapp</name>
  <url>http://maven.apache.org</url>
  <dependencies>
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>3.8.1</version>
      <scope>test</scope>
    </dependency>
    <dependency>
    	<groupId>javax.servlet</groupId>
    	<artifactId>servlet-api</artifactId>
    	<version>2.5</version>
    	<scope>provided</scope>
    </dependency>
  </dependencies>
  <build>
    <finalName>example-maven-webapp</finalName>
    <plugins>
      <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-compiler-plugin</artifactId>
      <version>2.3.2</version>
      <configuration>
        <source>1.6</source>
        <target>1.6</target>
      </configuration>
      </plugin>
    </plugins>
  </build>
</project>
```

(See also: http://maven.apache.org/plugins/maven-compiler-plugin/examples/set-compiler-source-and-target.html)

After doing that, I regenerate the eclipse project files:

```
mvn -Dwtpversion=2.0 eclipse:eclipse
```

...then refresh the project in eclipse. Now I see two warnings in eclipse, which can be ignored, and no errors.

(You might also want to right click the project in eclipse and do Maven > Update Project Configuration.)

## Install Tomcat & Integrate with Eclipse ##

You can install tomcat 6 via apt in ubuntu, but the ubuntu folder structure causes eclipse problems when you add tomcat as a server. To work around this, you can either manually install tomcat, or do:

```
sudo apt-get install tomcat6
cd /usr/share/tomcat6
sudo ln -s /var/lib/tomcat6/conf conf
sudo ln -s /etc/tomcat6/policy.d/03catalina.policy conf/catalina.policy
sudo ln -s /var/log/tomcat6 log
sudo chmod -R 777 /usr/share/tomcat6/conf
```

(Taken from http://ubuntuforums.org/showthread.php?p=8541057)

<strong>Note however that, for some reason, when using tomcat installed via apt, auto-reloading of web applications doesn't seem to work (i.e., no instant gratification).</strong> I'm going back to a manual install of tomcat, e.g.:

```
wget http://mirrors.dedipower.com/ftp.apache.org//tomcat/tomcat-6/v6.0.29/bin/apache-tomcat-6.0.29.tar.gz
tar -xvzf apache-tomcat-6.0.29.tar.gz
sudo mv apache-tomcat-6.0.29 /opt
```

Once tomcat is installed, start eclipse and do:

  * Window > Preferences
  * Server > Runtime Environments
  * (Server Runtime Environments) Add...
  * (New Server Runtime Environment) Select "Apache Tomcat v6.0" under "Apache" and click Next >
  * (Tomcat Server) Tomcat installation directory: /usr/share/tomcat6 [or /path/to/manually/installed/tomcat6 ](.md)
  * (Tomcat Server) Finish

To show the servers view in eclipse, either switch to the Java EE perspective, or do:

  * Window > Show View > Other...
  * Select "Servers" under "Server"

Then, to create a new server, do:

  * Right click in the servers view
  * New > Server
  * (Define a New Server) Next >
  * (Add and Remove) Add All >> then Finish

To start the server and check the example-webapp is running do:

  * Click on the server in the servers view
  * Click the play button (Start the Server)

If you installed tomcat as a service on your machine as well, you'll need to make sure that the tomcat service is not running.

Once tomcat has started, go to http://localhost:8080/example-webapp/ - you should see "Hello World" if it has all worked.

You can check that instant gratification is working (i.e., the webapp is auto-reloaded on any changes you make to the source) by editing the index.jsp file in the src/main/webapp folder. When you save the changes, you should shortly thereafter see a message in the eclipse console that the context is reloading, then refreshing your browser should show the changes.

## Creating an Example Servlet ##

I added a new source folder in Eclipse by right clicking the project and doing:

  * New > Source Folder
  * Folder name: src/main/java
  * Finish

No modification to the pom is necessary, this is already assumed to be a source folder by maven.

To create an example servlet, I right clicked the project, and did:

  * New > Other...
  * Select "Servlet" under "Web"
  * Enter a class name, click Next >
  * Modify the description and/or URL mappings as you like, click Next >
  * Select the method stubs to create, click Finish

Eclipse now reports some build errors, because the servlet API is not on the build path.

To resolve this, I did:

  * Right click the project
  * Maven > Add Dependency
  * Type "servlet-api" then select "2.5 - servlet-api-2.5.jar" under "javax.servlet", select Scope: Provided and click OK

The servlet api should now appear under the Maven Dependencies in the project.

Implement the servlet, then restart tomcat, and test the servlet path in your browser.

## Updating web.xml ##

The web.xml file created by the maven webapp archetype uses the version 2.3 DTD. You can update this to use the version 2.5 XML schema. Manually edit the prolog of web.xml to look like:

```
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns="http://java.sun.com/xml/ns/javaee" xmlns:web="http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd" xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd" version="2.5">
  <display-name>Example Web Application with Maven</display-name>
  <servlet>
    <servlet-name>ExampleServlet</servlet-name>
    <servlet-class>example.ExampleServlet</servlet-class>
  </servlet>
  <servlet-mapping>
    <servlet-name>ExampleServlet</servlet-name>
    <url-pattern>/ExampleServlet</url-pattern>
  </servlet-mapping>
</web-app>
```

Now this may not be strictly consistent with the version of the Dynamic Web Module Project Facet, which is 2.4 in the eclipse settings generated by the maven eclipse plugin.

To set the facet version to 2.5, I regenerated the eclipse project files:

```
mvn -Dwtpversion=2.0 eclipse:eclipse
```

...then refreshed the project in eclipse.

(You might also want to right click the project in eclipse and do Maven > Update Project Configuration.)

N.B. if you try modifying the Dynamic Web Module Project Facet to version 2.5 by hand you get an error, which may be a [bug](https://issues.sonatype.org/browse/MNGECLIPSE-1266).

## Tidy Up ##

I noticed that the org.eclipse.wst.common.component settings file (found under .settings folder) had some duplicate `<wb-resource/>` entries, although this doesn't seem to cause any problems. I edited by hand to:

```
<?xml version="1.0" encoding="UTF-8"?>
<project-modules id="moduleCoreId" project-version="1.5.0">
  <wb-module deploy-name="example-maven-webapp">
    <property name="java-output-path" value="/target/classes"/>
        <property name="context-root" value="example-maven-webapp"/>
    <wb-resource deploy-path="/" source-path="src/main/webapp"/>
    <wb-resource deploy-path="/WEB-INF/classes" source-path="src/main/java"/>
    <wb-resource deploy-path="/WEB-INF/classes" source-path="src/main/resources"/>
  </wb-module>
</project-modules>
```

Then I regenerated the eclipse project files from the command line and did Maven > Update Project Configuration, and the duplicates did not reappear.

## The End ##

That should be it for getting started. Next step is [configuring war overlays with instant gratification...](MavenEclipseOverlays.md)

If you know a better way to do this, drop a comment on this page, or [email me](mailto:alimanfoo@gmail.com) - I'd be very grateful.

## Epilogue ##

I've checked this project into the AtomBeat SVN repository, so you should be able to use it as a template to create new projects. E.g.:

```
cd ~/workspace
svn export http://atombeat.googlecode.com/svn/trunk/base/example-maven-webapp my-new-project
```

...then, in Eclipse, import the project into your workspace.

You probably also want to edit the .project file with the new project name, edit the .settings/org.eclipse.wst.common.component file with a new deploy-name, and change the context root (right click the project, click Properties, then see under Web Project Settings), before adding the project to your tomcat server in eclipse.
