# Maven, Eclipse and Web Applications - WAR Overlays and Instant Gratification #

Here's my notes on setting up multiple web application projects with dependencies using the maven war overlay method, and still getting instant gratification in eclipse.

## Creating the Dependency Project (example-maven-webapp) ##

You need a web application project to use as the war dependency, i.e., as the project that will be overlaid on another web application project.

I'm going to use the example-maven-webapp project I [created previously](MavenEclipseGettingStarted.md). The relevant details from the dependency project are:

```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  ...
  <groupId>org.example.webapp</groupId>
  <artifactId>example-maven-webapp</artifactId>
  <packaging>war</packaging>
  <version>1.0-SNAPSHOT</version>
  ...
</project>
```

Once this project is set up, run `mvn install` from the command line, which will package and install the dependency project into your local maven repository.

## Creating the Project with the WAR Overlay Dependency (example-maven-webapp-overlay) ##

Create a second web application project and configure it for use with maven and eclipse wst as per the [getting started instructions](MavenEclipseGettingStarted.md).

Add the first project as a runtime dependency, e.g., by editing the pom.xml file to something like...

```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
  <modelVersion>4.0.0</modelVersion>
  <groupId>org.example.webapp</groupId>
  <artifactId>example-maven-webapp-overlay</artifactId>
  <packaging>war</packaging>
  <version>1.0-SNAPSHOT</version>
  <name>Example Maven Webapp with WAR Overlay</name>
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
    <!-- here's the WAR overlay dependency... -->
    <dependency>
    	<groupId>org.example.webapp</groupId>
    	<artifactId>example-maven-webapp</artifactId>
    	<version>1.0-SNAPSHOT</version>
    	<type>war</type>
    	<scope>runtime</scope>
    </dependency>
  </dependencies>
  <build>
    <finalName>example-maven-webapp-overlay</finalName>
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

Run `mvn package` from the command line. Inspect the contents of the `target/example-maven-webapp-overlay` folder - you should see files from the dependency project there as well as the files from the current project.

Note that any files from the current project will override files in the dependency. I.e., files from the dependency will not be overlaid if the file exists in the current project.

Finally, to get instant gratification with eclipse and tomcat, edit the .settings/org.eclise.wst.common.component file to add another `<wb-resource/>` element, e.g.:

```
<?xml version="1.0" encoding="UTF-8"?>
<project-modules id="moduleCoreId" project-version="1.5.0">
  <wb-module deploy-name="example-maven-webapp-overlay">
    <property name="java-output-path" value="/target/classes"/>
        <property name="context-root" value="example-maven-webapp-overlay"/>
    <wb-resource deploy-path="/" source-path="src/main/webapp"/>
    <wb-resource deploy-path="/WEB-INF/classes" source-path="src/main/java"/>
    <wb-resource deploy-path="/WEB-INF/classes" source-path="src/main/resources"/>
    <wb-resource deploy-path="/" source-path="target/example-maven-webapp-overlay"/>
  </wb-module>
</project-modules>
```

What this does is deploy files to tomcat from the src/main/webapp folder **and** from the maven build location (target/example-maven-webapp-overlay). The files in src/main/webapp will take precendence, so what you will see in tomcat is the most recent maven build overlaid with the project's source. If you make any changes to the project's source, that should get hot-deployed to tomcat and trigger a context reload - instant gratification.

Note that you **do not** get instant gratification for changes to the dependency project. If you make any changes to the dependency, you need to:

  * run `mvn install` from within the dependency project (example-maven-webapp)
  * run `mvn clean package` from within the current project (example-maven-webapp-overlay)
  * refresh the current project (example-maven-webapp-overlay) in eclipse

## The End ##

Hopefully that makes sense!

I've checked this example into the AtomBeat SVN repository at: http://atombeat.googlecode.com/svn/trunk/base/example-maven-webapp-overlay

You should be able to check out that and the example-maven-webapp projects, import them both into eclipse, add them both to tomcat, and test out what I said above.

If you know a better way to do this, drop a comment on this page, or [email me](mailto:alimanfoo@gmail.com) - I'd be very grateful.
