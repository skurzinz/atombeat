# About #

AtomBeat is an implementation of the [Atom Publishing Protocol](http://www.atomenabled.org/developers/protocol/atom-protocol-spec.php) with a number of extended features.

# Tutorials #

  * TutorialGettingStarted - Covers downloading and installing AtomBeat, creating a collection and retrieving an Atom feed; creating, retrieving, updating and deleting collection members; creating, retrieving, updating and deleting media resources.

  * TutorialVersioning - An introduction to AtomBeat's history plugin, which provides support for tracking revisions to collection members. Covers creating a versioned collection, retrieving a member history feed, retrieving member revisions and submitting a revision comment.

  * TutorialAccessControl - An introduction to AtomBeat's support for access control. AtomBeat's security plugin has support for fine-grained access control policies via access control lists (ACLs). ACLs can be defined at workspace, collection and member levels, with configurable precedence. Atom protocol operations can be allowed or denied based on users, roles and groups. ACLs can be discovered via links in Atom feeds and entries, and retrieved and modified using standard Atom protocol operations (HTTP GET and PUT).

Some other documentation, may be part-baked: TombstonesDesign DevelopingPlugins

# Downloads #

Please note that WAR packages in the 0.2 series are **not** available from the AtomBeat Google Code project downloads page. To obtain a WAR package, you can either download directly from the [CGGH maven repository](http://cloud1.cggh.org/maven2/org/atombeat/), e.g.:

```
wget http://cloud1.cggh.org/maven2/org/atombeat/atombeat-exist-minimal-secure/0.2-alpha-10/atombeat-exist-minimal-secure-0.2-alpha-10.war
```

...or you can check out and build it yourself (currently only works on Linux), e.g.:

```
svn checkout http://atombeat.googlecode.com/svn/tags/atombeat-parent-0.2-alpha-10
cd atombeat-parent-0.2-alpha-10
export MAVEN_OPTS="-Xmx1024M -XX:MaxPermSize=256M"
mvn install # might take a while first time - will package and test all WARs
```

## AtomBeat as a Maven WAR Overlay ##

To use one of the AtomBeat WAR packages (e.g., [atombeat-exist-minimal-secure](http://cloud1.cggh.org/maven2/org/atombeat/atombeat-exist-minimal-secure/)) as a Maven WAR overlay, do something like...

```
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

  <modelVersion>4.0.0</modelVersion>

  <!-- ... -->
    
  <dependencies>
  
    <dependency>
      <groupId>org.atombeat</groupId>
      <artifactId>atombeat-exist-minimal-secure</artifactId>
      <version>0.2-alpha-10</version>
      <type>war</type>
      <scope>runtime</scope>
    </dependency>
    
  </dependencies>

  <repositories>

    <repository>
      <id>cggh</id>
      <name>CGGH Maven Repository</name>
      <url>http://cloud1.cggh.org/maven2</url>
    </repository>

  </repositories>

  <!-- ... -->

</project>
```

# News #

See also the ReleaseNotes wiki page and the [AtomBeat mailing list](http://groups.google.com/group/atombeat).

  * **6 Sept 2012** - 0.2-alpha-11 and 0.2-alpha-12 released - a minor release attempting to resolve persistence problems

  * **25 May 2011** - [0.2-alpha-10 is released](http://groups.google.com/group/atombeat/browse_thread/thread/27bc4eca23a4042) - this release has a new paging-plugin to implement feed paging, some performance improvements for the link-extensions and security plugins, and a new unzip-plugin providing some special features for handling zipped media resources.

  * **8 March 2011** - [0.2-alpha-9 is released](http://groups.google.com/group/atombeat/browse_thread/thread/f44c299bea016328) - this is a minor release with a couple of bug-fixes and small features.

  * **1 March 2011** - [0.2-alpha-8 is released](http://groups.google.com/group/atombeat/browse_thread/thread/40248b970755586b) - this is a bug-fix release.

  * **28 February 2011** - [0.2-alpha-7 is released](http://groups.google.com/group/atombeat/browse_thread/thread/40fec419294661a5) - this is a bug-fix release, correcting a problem introduced in 0.2-alpha-6 relating to use of the new plugin-util module.

  * **16 February 2011** - [0.2-alpha-6 is released](http://groups.google.com/group/atombeat/browse_thread/thread/eb47abe8e3d9cbda), including support for content negotiation and access control extended to service documents, an improved link expansions plugin, and improved support for programmatically invoking Atom protocol operations from AtomBeat plugins and other XQueries.

  * **1 February 2011** - [0.2-alpha-5 is released](http://groups.google.com/group/atombeat/browse_thread/thread/56771c4536ce502), including support for server-driven content negotiation.

  * **19 January 2011** - 0.2-alpha-4 is released, including support for referencing security groups defined in Atom collection members, A first draft of a TutorialAccessControl is also available.

  * **6 January 2011** - 0.2-alpha-3 is released, including support for MD5 in @hash link extension attribute for media-link entries, and some configuration changes for more flexibility when generating self and edit links and atom IDs.

  * **24 November 2010** - 0.2-alpha-2 is released, including support for service documents, an upgrade to Spring Security 3.1 for security-enabled packages, and various changes and bug-fixes.

  * **27 October 2010** - 0.2-alpha-1 is released, including an implementation of Atom Tombstones, and support for protocol error plugins.

  * **14 October 2010** - 0.1-RC7 is released, this is the final release in the 0.1 series.

# Feature Overview #

  * Standard Atom Protocol Operations: create, retrieve, update and delete Atom entries and media resources; retrieve feeds of Atom collection members.

  * Protocol Extensions for Managing Atom Collections: create collections and update collection metadata; create collection hierarchies with recursive collections.

  * Protocol Extensions for Posting Media Directly From HTML Forms or XForms: create media resources using multipart/form-data requests.

  * Protocol Extensions for Creating Multiple Collection Members in a Single Request: add one or more members to a collection in a single request; copy one collection to another, including media resources.

  * Protocol and Format Extensions for Versioning: create versioned collections; retrieve a version history feed for any collection member; retrieve any previous revision of a member.

  * Security Extensions for Access Control: manage access control lists for Atom collections and collection members; specify fine-grained access control rules for users, groups and roles; can be integrated with external authentication and user role management systems, e.g., via Spring Security.

  * A Plug-in Framework for Developing Custom Extensions: write plugin functions that modify the behaviour of standard Atom Protocol operations, or implement custom side-effects; intercept and modify requests before and/or after main protocol operation execution.

  * Extensions for expanding links to other entries and feeds inline within an Atom entry

  * Configurable and extensible support for server-driven content negotiation, with default transformations to JSON and HTML supported out-of-the-box.

# Status #

Development is currently focused on the 0.2 series. This is currently in alpha, but should be relatively stable. There are a number of fairly substantial changes since the 0.1 series, see the ReleaseNotes wiki page for more information.

0.1-RC7 is the final release in the 0.1 series. See the [downloads page](http://code.google.com/p/atombeat/downloads/list?can=4) to download this version (hint: [search deprecated downloads](http://code.google.com/p/atombeat/downloads/list?can=4)).

AtomBeat is being developed as part of work on scientific data repositories at the Centre for Genomics and Global Health, a joint research programme of Oxford University and the Wellcome Trust Sanger Institute. If it's of interest to you, please feel free to [get in touch](mailto:atombeat@googlegroups.com) via the [AtomBeat Mailing List](http://groups.google.com/group/atombeat).

# eXist already has an Atom Protocol implementation, why do another? #

AtomBeat uses [eXist](http://exist.sourceforge.net/) as the underlying data storage engine. There are a couple of reasons why we've rolled our own Atom Protocol implementation in XQuery, rather than just using the Atom servlet that comes bundled with eXist...

  * We wanted to experiment with new features, like versioning and access control, and we found it quicker to do that by starting from scratch and working entirely in XQuery, rather than working with the existing Java servlet code.

  * eXist has its own security system, which borrows from the Unix model of users and groups. This is fine for many use cases, but there are situations where this is not sufficient to express the desired security model. For example, if you want to have an Atom collection where readers can retrieve any entry, authors can create entries, update any entry they have created, and choose other authors to collaborate with, and editors can update any entry, you cannot implement that with the Unix model of one user (owner) and group per resource. AtomBeat has a new security system based on access control lists, which is capable of expressing a wider range of security models. However, there are pros and cons here, see the documentation on security (TODO).

  * eXist can be configured to authenticate users via HTTP basic or digest authentication, and the user's credentials can be either stored in the eXist database or can be drawn from an LDAP repository. While this is fine for many situations, other scenarios require integration with single-sign-on authentication systems and a variety of user databases. Rather than try to implement any of this ourselves, we have designed AtomBeat to work with a wide range of authentication systems. For example, it is straightforward to use AtomBeat with Spring Security, which gives you access to implementations of a variety of authentication mechanisms including OpenID and CAS, and configurable integration with a variety of user databases.

Of course, we're on the exist-open mailing list and hope to feed back as much as we can to the eXist developers.

# Why "Atom Beat"? #

No particular reason. Apparently, "Atom Beat" was the name given to the style of drumming that Pete Best brought back to Liverpool after the Beatles' stint in Hamburg. It's got nothing to do with the Atom Publishing Protocol, but I saw it on an old Beatles gig poster and it caught my eye.