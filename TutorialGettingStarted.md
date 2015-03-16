

# Introduction #

This tutorial covers the following topics:

  * downloading and installing AtomBeat
  * creating an Atom collection and retrieving an Atom feed
  * creating, retrieving, updating and deleting Atom collection members
  * creating, retrieving, updating and deleting media resources

# Prerequisites #

You will need to have a servlet container like [Tomcat](http://tomcat.apache.org/download-60.cgi) or [Jetty](http://docs.codehaus.org/display/JETTY/Downloading+Jetty) installed on your computer, and you will need to know how to deploy a WAR file. AtomBeat 0.2 has been tested with Tomcat 6.0 and Jetty 6.1.

You will need to have the cURL HTTP command-line utility installed on your computer. If you're on a Linux computer, you probably already have curl installed, or can install it via a software repository, e.g.:

```
$ sudo apt-get install curl
```

If you are on a Windows or Mac computer, you can [download cURL](http://curl.haxx.se/download.html) and install it manually.

OPTIONAL: You might also like to install a TCP proxy so you can observe the communication between the client (cURL) and server (AtomBeat). There are a couple of options here. You can download and install [tcpmon](https://tcpmon.dev.java.net/) on any operating system. You can also install a very simple utility called [tcpwatch](http://hathawaymix.org/Software/TCPWatch), e.g.:

```
$ sudo apt-get install tcpwatch-httpproxy
$ tcpwatch-httpproxy -h -L 8081:8080 &
```

This tutorial assumes you have your servlet container installed and listening on port 8080.

This tutorial also assumes you have a TCP proxy installed and running, listening on port 8081 and forwarding to port 8080. If you are doing this tutorial **without** a TCP proxy, replace "8081" with "8080" wherever you see it below.

# Downloading and Installing AtomBeat #

We are going to be downloading and installing one of the WAR packages available for AtomBeat. Specifically, we are going to be using the **atombeat-exist-minimal** WAR package. This package is a web application containing an AtomBeat workspace, overlaid with a cut-down version of the [eXist](http://exist.sourceforge.net/) web application.

**For this tutorial you will need to install AtomBeat 0.2-alpha-2 or later.**

Please note that WAR packages in the 0.2 series are **not** available from the Google Code project downloads page. To obtain a WAR package, you can download directly from the [CGGH maven repository](http://cloud1.cggh.org/maven2/org/atombeat/), e.g.:

```
wget http://cloud1.cggh.org/maven2/org/atombeat/atombeat-exist-minimal/0.2-alpha-4/atombeat-exist-minimal-0.2-alpha-4.war
```

...or you can check out and build it yourself (currently only works on Linux), e.g.:

```
svn checkout http://atombeat.googlecode.com/svn/tags/atombeat-parent-0.2-alpha-4
cd atombeat-parent-0.2-alpha-4
export MAVEN_OPTS="-Xmx1024M -XX:MaxPermSize=256M"
mvn install # might take a while first time
```

Once the war file is downloaded (or built), deploy it to your servlet container. There are usually several options for deploying a war file, e.g., on Tomcat you can usually copy the war file to the `webapps` directory and restart Tomcat, and the war will automatically be exploded and deployed. Alternatively, you can do something a bit more manual, e.g.:

```
wget http://cloud1.cggh.org/maven2/org/atombeat/atombeat-exist-minimal/0.2-alpha-4/atombeat-exist-minimal-0.2-alpha-4.war
sudo unzip atombeat-exist-minimal-0.2-alpha-4.war -d /opt/atombeat-exist-minimal-0.2-alpha-4
sudo rm /var/lib/tomcat6/webapps/atombeat # remove previous link if already there
sudo ln -s /opt/atombeat-exist-minimal-0.2-alpha-4 /var/lib/tomcat6/webapps/atombeat
sudo chown -R tomcat6:tomcat6 /opt/atombeat-exist-minimal-0.2-alpha-4
sudo service tomcat6 restart
```

The rest of the tutorial assumes you have **deployed the AtomBeat web application at the context path /atombeat**. If you have deployed the war by copying the file to the webapps directory and letting tomcat automatically explode and deploy it, you might need to rename the file from `atombeat-exist-minimal-0.2-alpha-4.war` to `atombeat.war` before you do, to make sure it gets deployed to the right context path.

Once you've done this, restart your servlet container, and point your browser to http://localhost:8080/atombeat/ - you should see a web page saying, "It works!"

OPTIONAL: If you are going to use a TCP proxy, start it now, forwarding from 8081 to 8080, e.g.:

```
$ tcpwatch-httpproxy -h -L 8081:8080 &
```

Once the TCP proxy is running, point your browser to http://localhost:8081/atombeat/ - you should see the same "It works!" message. Have a look at the TCP communication to check you can see the HTTP requests and responses.

# Collections and Feeds #

There are several different ways to create an Atom collection in AtomBeat. In this tutorial, we're going to use an administration utility that comes with AtomBeat to create a pre-configured Atom collection. For more information on managing Atom collections, see TODO.

Go to the following link in your browser: http://localhost:8081/atombeat/service/admin/install.xql

You should see a page entitled "Atom Collections" and a table listing two collections.

Click the "Install" button. You should see the "Available" column change from "false" to "true". You have just created two Atom collections.

To retrieve an Atom feed from the Test Collection, click on the [/test](http://localhost:8081/atombeat/service/content/test) link, or go to the following URL: http://localhost:8081/atombeat/service/content/test

If you are using Firefox, you should see the default Firefox feed reader offering to subscribe to the feed, and below that the title of the collection: "Test Collection". What you see in other browsers will vary.

Let's do the same thing - retrieve an Atom feed from the Test collection - using cURL:

```
$ curl --verbose http://localhost:8081/atombeat/service/content/test
```

You should see the raw Atom XML representation of the feed document output in your console.

Finally, check the TCP proxy, you should see something like this in the most recent traffic:

```
GET /atombeat/service/content/test HTTP/1.1
User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15
Host: localhost:8081
Accept: */*


HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
pragma: no-cache
Cache-Control: no-cache
Content-Type: application/atom+xml;type=entry;charset=UTF-8
Transfer-Encoding: chunked
Date: Thu, 14 Oct 2010 17:01:02 GMT

<atom:feed xmlns:atom="http://www.w3.org/2005/Atom" xmlns:atombeat="http://purl.org/atombeat/xmlns" atombeat:enable-versioning="false" atombeat:exclude-entry-content="false" atombeat:recursive="false">
    <atom:id>http://localhost:8081/atombeat/service/content/test</atom:id>
    <atom:updated>2010-10-14T17:55:42.208+01:00</atom:updated>
    <atom:author>
        <atom:name/>
    </atom:author>
    <atom:title type="text">Test Collection</atom:title>
    <atom:link rel="self" href="http://localhost:8081/atombeat/service/content/test" type="application/atom+xml;type=feed"/>
    <atom:link rel="edit" href="http://localhost:8081/atombeat/service/content/test" type="application/atom+xml;type=feed"/>
</atom:feed>
```

# Collection Members #

## Create a Member ##

You can create new members in an Atom collection by POSTing an Atom entry document to the collection URI.

To do this, first create a file in your current directory called "entry1.xml", with the following content:

```
<?xml version="1.0"?>
<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
  <atom:title>Atom-Powered Robots Run Amok</atom:title>
  <atom:content>Some text.</atom:content>
</atom:entry>
```

Next, use cURL to send an HTTP POST request, e.g.:

```
$ curl --verbose --header "Content-Type: application/atom+xml" --data-binary @entry1.xml http://localhost:8081/atombeat/service/content/test
```

You should see an Atom entry document returned to you, representing the newly created collection member.

The TCP communication trace should look something like:

```
POST /atombeat/service/content/test HTTP/1.1
User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15
Host: localhost:8081
Accept: */*
Content-Type: application/atom+xml
Content-Length: 188

<?xml version="1.0"?>
<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
  <atom:title>Atom-Powered Robots Run Amok</atom:title>
  <atom:content>Some text.</atom:content>
</atom:entry>


HTTP/1.1 201 Created
Server: Apache-Coyote/1.1
pragma: no-cache
Cache-Control: no-cache
Location: http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom
Content-Location: http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom
ETag: "0e95efe893e345c34ab1f79c757c719f"
Content-Type: application/atom+xml;type=entry;charset=UTF-8
Transfer-Encoding: chunked
Date: Thu, 14 Oct 2010 17:29:48 GMT

<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
    <atom:id>http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom</atom:id>
    <atom:published>2010-10-14T18:29:48.687+01:00</atom:published>
    <atom:updated>2010-10-14T18:29:48.687+01:00</atom:updated>
    <atom:author>
        <atom:name/>
    </atom:author>
    <atom:title>Atom-Powered Robots Run Amok</atom:title>
    <atom:content>Some text.</atom:content>
    <atom:link rel="self" type="application/atom+xml;type=entry" href="http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom"/>
    <atom:link rel="edit" type="application/atom+xml;type=entry" href="http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom"/>
</atom:entry>
```

Once you've done this, try retrieving a feed from the collection again. E.g., go to http://localhost:8081/atombeat/service/content/test in your browser again, or do:

```
$ curl --verbose http://localhost:8081/atombeat/service/content/test
```

You should see the new member appearing in the feed, e.g.:

```
GET /atombeat/service/content/test HTTP/1.1
User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15
Host: localhost:8081
Accept: */*


HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
pragma: no-cache
Cache-Control: no-cache
Content-Type: application/atom+xml;type=entry;charset=UTF-8
Transfer-Encoding: chunked
Date: Thu, 14 Oct 2010 17:33:36 GMT

<atom:feed xmlns:atom="http://www.w3.org/2005/Atom" xmlns:atombeat="http://purl.org/atombeat/xmlns" atombeat:enable-versioning="false" atombeat:exclude-entry-content="false" atombeat:recursive="false">
    <atom:id>http://localhost:8081/atombeat/service/content/test</atom:id>
    <atom:updated>2010-10-14T18:29:48.687+01:00</atom:updated>
    <atom:author>
        <atom:name/>
    </atom:author>
    <atom:title type="text">Test Collection</atom:title>
    <atom:link rel="self" href="http://localhost:8081/atombeat/service/content/test" type="application/atom+xml;type=feed"/>
    <atom:link rel="edit" href="http://localhost:8081/atombeat/service/content/test" type="application/atom+xml;type=feed"/>
    <atom:entry>
        <atom:id>http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom</atom:id>
        <atom:published>2010-10-14T18:29:48.687+01:00</atom:published>
        <atom:updated>2010-10-14T18:29:48.687+01:00</atom:updated>
        <atom:author>
            <atom:name/>
        </atom:author>
        <atom:title>Atom-Powered Robots Run Amok</atom:title>
        <atom:content>Some text.</atom:content>
        <atom:link rel="self" type="application/atom+xml;type=entry" href="http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom"/>
        <atom:link rel="edit" type="application/atom+xml;type=entry" href="http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom"/>
    </atom:entry>
</atom:feed>
```

## Retrieve a Member ##

To retrieve a collection member, you need the member URI. You can find the member URI either from the value of the `Location` header sent back when you created the member, or from the `@href` attribute on the `atom:link` with `@rel="edit"` (I'll call this the "edit link" from now on). In the example above, the member URI is http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom - but it will be different for you, because AtomBeat generates a new URI for every new member.

Once you've found the member URI, send a GET request to the URI, e.g.:

```
$ curl --verbose http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom
```

You should see an Atom entry document returned, e.g.:

```
GET /atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom HTTP/1.1
User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15
Host: localhost:8081
Accept: */*


HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
pragma: no-cache
Cache-Control: no-cache
ETag: "0e95efe893e345c34ab1f79c757c719f"
Content-Type: application/atom+xml;type=entry;charset=UTF-8
Transfer-Encoding: chunked
Date: Thu, 14 Oct 2010 17:28:29 GMT

<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
    <atom:id>http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom</atom:id>
    <atom:published>2010-10-14T18:29:48.687+01:00</atom:published>
    <atom:updated>2010-10-14T18:29:48.687+01:00</atom:updated>
    <atom:author>
        <atom:name/>
    </atom:author>
    <atom:title>Atom-Powered Robots Run Amok</atom:title>
    <atom:content>Some text.</atom:content>
    <atom:link rel="self" type="application/atom+xml;type=entry" href="http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom"/>
    <atom:link rel="edit" type="application/atom+xml;type=entry" href="http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom"/>
</atom:entry>
```

## Update a Member ##

To update a collection member, send a PUT request to the member URI with an Atom entry document containing the updated data.

E.g., create a new file `entry1-updated.xml` in your current directory containing the following:

```
<?xml version="1.0"?>
<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
  <atom:title>Atom-Powered Robots Run Amok</atom:title>
  <atom:content type="xhtml">
    <div xmlns="http://www.w3.org/1999/xhtml">
      <p><em>AtomBeat 0.2 has been released!</em></p>
    </div>
  </atom:content>
</atom:entry>
```

Then, send a PUT request using cURL, e.g.:

```
$ curl --verbose --header "Content-Type: application/atom+xml" --upload-file entry1-updated.xml http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom
```

You should see a response containing the updated entry, e.g.:

```
PUT /atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom HTTP/1.1
User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15
Host: localhost:8081
Accept: */*
Content-Type: application/atom+xml
Content-Length: 306

<?xml version="1.0"?>
<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
  <atom:title>Atom-Powered Robots Run Amok</atom:title>
  <atom:content type="xhtml">
    <div xmlns="http://www.w3.org/1999/xhtml">
      <p><em>AtomBeat 0.2 has been released!</em></p>
    </div>
  </atom:content>
</atom:entry>


HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
pragma: no-cache
Cache-Control: no-cache
ETag: "fc53a08a2259b8975bd5f0003c731844"
Content-Type: application/atom+xml;type=entry;charset=UTF-8
Transfer-Encoding: chunked
Date: Thu, 14 Oct 2010 17:45:57 GMT

<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
    <atom:id>http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom</atom:id>
    <atom:published>2010-10-14T18:29:48.687+01:00</atom:published>
    <atom:updated>2010-10-14T18:45:57.257+01:00</atom:updated>
    <atom:author>
        <atom:name/>
    </atom:author>
    <atom:title>Atom-Powered Robots Run Amok</atom:title>
    <atom:content type="xhtml">
        <div xmlns="http://www.w3.org/1999/xhtml">
            <p>
                <em>AtomBeat 0.2 has been released!</em>
            </p>
        </div>
    </atom:content>
    <atom:link rel="self" type="application/atom+xml;type=entry" href="http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom"/>
    <atom:link rel="edit" type="application/atom+xml;type=entry" href="http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom"/>
</atom:entry>
```

## Delete a Member ##

To delete a collection member, send an HTTP DELETE request to the member URI. E.g.:

```
$ curl --verbose --request DELETE http://localhost:8081/atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom
```

If successful, you should receive a 204 response without any content, e.g.:

```
DELETE /atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom HTTP/1.1
User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15
Host: localhost:8081
Accept: */*


HTTP/1.1 204 No Content
Server: Apache-Coyote/1.1
pragma: no-cache
Cache-Control: no-cache
Date: Thu, 14 Oct 2010 17:50:14 GMT
```

Any subsequent attempt to retrieve the member should result in a 404, e.g.:

```
GET /atombeat/service/content/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom HTTP/1.1
User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15
Host: localhost:8081
Accept: */*


HTTP/1.1 404 Not Found
Server: Apache-Coyote/1.1
pragma: no-cache
Cache-Control: no-cache
Content-Type: application/xml;charset=UTF-8
Transfer-Encoding: chunked
Date: Thu, 14 Oct 2010 17:50:52 GMT

<error>
    <status>404</status>
    <message>The server has not found anything matching the Request-URI.</message>
    <request>
        <method>GET</method>
        <path-info>/test/4d0ec6d9-bead-4843-bcc9-444392a55b5c.atom</path-info>
        <parameters/>
        <headers>
            <header>
                <name>user-agent</name>
                <value>curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15</value>
            </header>
            <header>
                <name>host</name>
                <value>localhost:8081</value>
            </header>
            <header>
                <name>accept</name>
                <value>*/*</value>
            </header>
        </headers>
        <user/>
        <roles/>
    </request>
</error>
```

# Media Resources #

## Creating a Media Resource ##

You can create new media resource in an Atom collection by POSTing a media file to the collection URI.

To do this, first create a file in your current directory called "media1.txt", with the following content:

```
This is some not-very-exciting media content.
```

Here we are using a text file, but you could use any file in any format (e.g., a jpg, an mp3, a spreadsheet, ...).

Next, use cURL to send an HTTP POST request, e.g.:

```
$ curl --verbose --header "Content-Type: text/plain" --header "Slug: media1.txt" --data-binary @media1.txt http://localhost:8081/atombeat/service/content/test
```

If you are using something other than a text file, remember to set the correct Content-Type header in the request. E.g., for a jpeg file, use `--header "Content-Type: image/jpeg"`. You can find a [list of registered media types at IANA](http://www.iana.org/assignments/media-types/).

You should see an Atom entry document returned - this is called the "media-link entry", and it contains metadata about your newly created media resource, e.g.:

```
POST /atombeat/service/content/test HTTP/1.1
User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15
Host: localhost:8081
Accept: */*
Content-Type: text/plain
Slug: media1.txt
Content-Length: 46

This is some not-very-exciting media content.


HTTP/1.1 201 Created
Server: Apache-Coyote/1.1
pragma: no-cache
Cache-Control: no-cache
Location: http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.atom
Content-Location: http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.atom
Content-Type: application/atom+xml;type=entry;charset=UTF-8
Transfer-Encoding: chunked
Date: Thu, 14 Oct 2010 18:05:18 GMT

<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
    <atom:id>http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.atom</atom:id>
    <atom:published>2010-10-14T19:05:18.652+01:00</atom:published>
    <atom:updated>2010-10-14T19:05:18.652+01:00</atom:updated>
    <atom:content src="http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.media" type="text/plain"/>
    <atom:title type="text">media1.txt</atom:title>
    <atom:summary type="text">media resource</atom:summary>
    <atom:author>
        <atom:name/>
    </atom:author>
    <atom:link rel="self" type="application/atom+xml;type=entry" href="http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.atom"/>
    <atom:link rel="edit" type="application/atom+xml;type=entry" href="http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.atom"/>
    <atom:link rel="edit-media" type="text/plain" href="http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.media" length="46"/>
</atom:entry>
```

Note that you can update this entry as you would update a normal collection member, by sending a PUT request to the URI given in the edit link, with an Atom entry document containing the updated metadata.

## Retrieving a Media Resource ##

To retrieve a media resource, you need to find the media resource URI. There are two places you can find this in the Atom entry document you got back when you created the resource, either from the `edit-media` link, or from the `@src` attribute on the `atom:content` element, e.g.: http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.media - although this URI will be different for you, as AtomBeat creates a new URI for each new media resource.

Once you've found the media resource URI, send an HTTP GET request, e.g.:

```
$ curl --verbose http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.media
```

You should see something like:

```
GET /atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.media HTTP/1.1
User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15
Host: localhost:8081
Accept: */*

HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
pragma: no-cache
Cache-Control: no-cache
Content-Disposition: attachment; filename="media1.txt"
Content-Type: text/plain;charset=UTF-8
Content-Length: 46
Date: Thu, 14 Oct 2010 18:09:53 GMT

This is some not-very-exciting media content.
```

## Updating a Media Resource ##

To update a media resource, send a PUT request to the media resource URI with the updated media content as the request body.

E.g., create a new file `media1-updated.txt` in your current directory containing the following:

```
This is some not-very-exciting media content - updated with some more content.  
```

(...or whatever you want to write.)

Then, send a PUT request using cURL, e.g.:

```
$ curl --verbose --header "Content-Type: text/plain" --upload-file media1-updated.txt http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.media
```

You should see a response with the media-link entry corresponding to the media resource you just updated. Notice that the `atom:updated` element should have changed to reflect your recent update to the media resource. E.g.:

```
PUT /atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.media HTTP/1.1
User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15
Host: localhost:8081
Accept: */*
Content-Type: text/plain
Content-Length: 79

This is some not-very-exciting media content - updated with some more content.


HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
pragma: no-cache
Cache-Control: no-cache
Content-Location: http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.atom
Content-Type: application/atom+xml;type=entry;charset=UTF-8
Transfer-Encoding: chunked
Date: Fri, 15 Oct 2010 12:08:47 GMT

<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
    <atom:id>http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.atom</atom:id>
    <atom:published>2010-10-14T19:05:18.652+01:00</atom:published>
    <atom:updated>2010-10-15T13:08:47.661+01:00</atom:updated>
    <atom:content type="text/plain" src="http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.media"/>
    <atom:title type="text">media1.txt</atom:title>
    <atom:summary type="text">media resource</atom:summary>
    <atom:author>
        <atom:name/>
    </atom:author>
    <atom:link rel="self" type="application/atom+xml;type=entry" href="http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.atom"/>
    <atom:link rel="edit" type="application/atom+xml;type=entry" href="http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.atom"/>
    <atom:link rel="edit-media" type="text/plain" href="http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.media" length="79"/>
</atom:entry>
```

A subsequent GET request to the media resource URI should return your updated content, e.g.:

```
$ curl --verbose http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.media
```

...should give you something like:

```
GET /atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.media HTTP/1.1
User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15
Host: localhost:8081
Accept: */*


HTTP/1.1 200 OK
Server: Apache-Coyote/1.1
pragma: no-cache
Cache-Control: no-cache
Content-Disposition: attachment; filename="media1.txt"
Content-Type: text/plain;charset=UTF-8
Content-Length: 79
Date: Fri, 15 Oct 2010 12:14:05 GMT

This is some not-very-exciting media content - updated with some more content.
```

## Deleting a Media Resource ##

To delete a media resource, send a DELETE request to the media resource URI. E.g.:

```
$ curl --verbose --request DELETE http://localhost:8081/atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.media
```

If successful, you should receive a 204 response without any content, e.g.:

```
DELETE /atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.media HTTP/1.1
User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15
Host: localhost:8081
Accept: */*


HTTP/1.1 204 No Content
Server: Apache-Coyote/1.1
pragma: no-cache
Cache-Control: no-cache
Date: Fri, 15 Oct 2010 12:21:11 GMT
```

Any subsequent GET request to the media resource URI should return a 404, e.g.:

```
GET /atombeat/service/content/test/c5695f1c-af7d-4d18-b21c-96940636209e.media HTTP/1.1
User-Agent: curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15
Host: localhost:8081
Accept: */*


HTTP/1.1 404 Not Found
Server: Apache-Coyote/1.1
pragma: no-cache
Cache-Control: no-cache
Content-Type: application/xml;charset=UTF-8
Transfer-Encoding: chunked
Date: Fri, 15 Oct 2010 12:21:21 GMT

<error>
    <status>404</status>
    <message>The server has not found anything matching the Request-URI.</message>
    <request>
        <method>GET</method>
        <path-info>/test/c5695f1c-af7d-4d18-b21c-96940636209e.media</path-info>
        <parameters/>
        <headers>
            <header>
                <name>user-agent</name>
                <value>curl/7.19.7 (x86_64-pc-linux-gnu) libcurl/7.19.7 OpenSSL/0.9.8k zlib/1.2.3.3 libidn/1.15</value>
            </header>
            <header>
                <name>host</name>
                <value>localhost:8081</value>
            </header>
            <header>
                <name>accept</name>
                <value>*/*</value>
            </header>
        </headers>
        <user/>
        <roles/>
    </request>
</error>
```

**Note that the media-link collection member corresponding to the media resource will also have been deleted. Note also that a DELETE request sent to the media-link URI will have exactly the same effect, i.e., both the media resource and the corresponding media-link member will be deleted.**

# Further Reading #

For a list of other AtomBeat tutorials available, see the [AtomBeat wiki home page](AtomBeat.md).

The [Atom Protocol Specification](http://www.atomenabled.org/developers/protocol/atom-protocol-spec.php) and the [Atom Format Specification](http://www.atomenabled.org/developers/syndication/atom-format-spec.php) are recommended reading.