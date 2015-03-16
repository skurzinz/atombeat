**N.B. since writing this page nixj14 has contributed a single script for executing the entire patch and build process, see the comments at the bottom of the page.**

# Introduction #

We'd like to use AtomBeat with [Orbeon Forms](http://www.orbeon.com/), but Orbeon comes with eXist 1.2.6 embedded, and AtomBeat requires eXist 1.4.0.

This page has notes on work done to create a build of Orbeon with eXist 1.4.0 patched and embedded.

Any comments or bugs or fixes found [gratefully received](mailto:alimanfoo@gmail.com).

# Downloads & Projects in SVN #

The following location in SVN has the Orbeon source code obtained from the 20100324 nightly build download, with exist 1.4.0 patched for orbeon and embedded:

  * http://atombeat.googlecode.com/svn/tags/orbeon-src-20100324-exist-1_4_0/

You should be able to do:

```
svn co http://atombeat.googlecode.com/svn/tags/orbeon-src-20100324-exist-1_4_0/ orbeon
cd orbeon
ant orbeon-dist-war
```

There is also a download of the WAR built as above at:

  * http://atombeat.googlecode.com/files/orbeon-20100324-exist-1_4_0.war

The following location in SVN has an Eclipse dynamic web project created from a above WAR:

  * http://atombeat.googlecode.com/svn/tags/orbeon-dwp-20100324-exist-1_4_0/

You should be able to check that out and import into Eclipse 3.5. This is what we plan to use as the basis for the AtomBeat server project.

# Patching and Embedding Process #

Here are the steps followed to embed eXist 1.4.0 in Orbeon.

The process was based on the [notes on third-party libraries in the Orbeon contributor guide](http://wiki.orbeon.com/forms/doc/contributor-guide/third-party-java-libraries#TOC-eXist), without the "by hand" modifications (we weren't sure how to do those).

1. Download Orbeon nightly build with source.

```
wget http://forge.ow2.org/nightlybuilds/ops/ops/orbeon-src.zip
unzip orbeon-src.zip -d orbeon-src-20100324
```

2. Check Orbeon builds OK as distributed.

```
cd orbeon-src-20100324/
ant orbeon-dist-war 
```

3. Check out eXist 1.4.0 and check it builds OK as distributed.

```
cd ..
svn co https://exist.svn.sourceforge.net/svnroot/exist/releases/eXist-1.4 exist-1.4
cd exist-1.4/
ant
```

4. Edit patch\_exist.sh, copy to eXist directory and run.

```
cp patch_exist.sh patch_exist.sh.original
emacs patch_exist.sh
cp patch_exist.sh ../exist-1.4/
cd ../exist-1.4/
chmod +x patch_exist.sh 
./patch_exist.sh 
```

See also: [edited version of patch\_exist.sh](http://atombeat.googlecode.com/svn/tags/orbeon-src-20100324-exist-1_4_0/patch_exist.sh)

5. Merge eXist conf.xml with Orbeon exist-conf.xml.

```
cd ../orbeon-src-20100324/
find ./ -name exist-conf.xml
cd descriptors/web-inf/static/
cp exist-conf.xml exist-conf.xml.original
emacs exist-conf.xml
```

See also: [merged exist-conf.xml](http://atombeat.googlecode.com/svn/tags/orbeon-src-20100324-exist-1_4_0/descriptors/web-inf/static/exist-conf.xml)

6. Edit Orbeon build.xml with new names of jar files.

```
cd ../../..
cp build.xml build.xml.original
emacs build.xml
```

See also: [edited build.xml](http://atombeat.googlecode.com/svn/tags/orbeon-src-20100324-exist-1_4_0/build.xml)

7. Rebuild Orbeon and test in a servlet container.

```
ant clean
ant orbeon-dist-war 
# deploy to tomcat and test
```