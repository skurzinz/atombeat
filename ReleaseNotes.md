**See the AtomBeat wiki page for information on downloading and/or building AtomBeat.**



# 0.2-alpha-13-SNAPSHOT #
# 0.2-alpha-12 #

Sort out some maven problems connected to release

# 0.2-alpha-11 #

## [issue 179](https://code.google.com/p/atombeat/issues/detail?id=179) validated save ##

For atomdb:update-member check that the saved member is as expected - read back and compare - this requires an enhanced xquery deep-equal function in atombeat-xquery-functions that can ignore white space changes (similar to that available in saxon)

## [issue 180](https://code.google.com/p/atombeat/issues/detail?id=180) media element consistency ##

For media entries put the atom:content after the atom:title - while unnecessary according to the Atom spec it is more consistent

# 0.2-alpha-10 #

## [issue 75](https://code.google.com/p/atombeat/issues/detail?id=75) implement feed pagination (limit and offset for list collection) ##

A new paging-plugin is available in this release. This plugin enables a collection to be configured to return a paged feed when a request is made to list the collection. For example, if a collection is configured with a default page size of 20, then a GET request on the collection URI will return a feed with the first 20 entries from the collection. Links are provided in the feed document to navigate to next, previous, first or last pages, if available. This conforms to the feed paging behaviour described in [RFC 5005](http://tools.ietf.org/html/rfc5005).

To enable the paging-plugin, include the paging-plugin before and after functions in the [config/plugins.xqm](http://code.google.com/p/atombeat/source/browse/tags/atombeat-parent-0.2-alpha-10/atombeat-service/src/main/files/config/plugins.xqm) configuration module. Note that the placement of the paging-plugin:after() function is important. Any other plugin functions executing in the after chain that might filter entries from the feed (such as the security-plugin:after() function) **must** come prior to the paging-plugin:after function, because otherwise the pages may be broken. The paging-plugin:after() should then be placed as early as possible in the chain, to cut down the amount of work done by downstream plugin functions and thus optimise the performance of the list collection operation (because downstream plugin functions only need to operate on the page, and not on the complete feed). This can dramatically improve performance for large collections where computationally expensive plugins like the link-extensions and link-expansion plugins are in use.

To create a collection with paging enabled, add an `@atombeat:enable-paging="true"` attribute to the feed document root element. The default and maximum page sizes can also be configured by adding additional markup to the feed document. E.g.:

```
<atom:feed
  xmlns:atom="http://www.w3.org/2005/Atom"
		xmlns:atombeat="http://purl.org/atombeat/xmlns"
		atombeat:enable-paging="true">
  <atom:title>Collection With Paging</atom:title>
  <atombeat:config-paging default-page-size="20" max-page-size="50"/>
</atom:feed>
```

In addition to the next, previous, first and last links as specified in RFC 5005, the total number of entries, start index of the current page, and number of items per page are provided via the `opensearch:totalResults`, `opensearch:startIndex` and `opensearch:itemsPerPage` elements. Also, a link with a URI template is provided for clients wishing to specify the page and page size in a request.

For more information, see the [paging plugin test case](http://code.google.com/p/atombeat/source/browse/tags/atombeat-parent-0.2-alpha-10/atombeat-integration-tests/src/test/java/org/atombeat/it/plugin/paging/TestPagingPlugin.java).

## [issue 132](https://code.google.com/p/atombeat/issues/detail?id=132) history plugin has bad reference to constants module location ##

The import statements have been checked and normalised across all XQuery files.

## [issue 145](https://code.google.com/p/atombeat/issues/detail?id=145) link expansion support for using atom:id as link target ##

In this release the link expansion plugin has been modified to enable links to be expanded where the value of the `@href` attribute matches the `atom:id` of a collection member.

When expanding a link, the link expansion plugin first attempts to match the @href against the 'self' URI of a collection, collection member, security descriptor or history feed, and then falls back to attempting to find a collection member where the `atom:id` matches the link `@href` attribute.

## [issue 171](https://code.google.com/p/atombeat/issues/detail?id=171) unzip plugin ##

In this release a new experimental unzip plugin is available. For more information on how to enable, configure and use this plugin, see the [config/plugins.xqm](http://code.google.com/p/atombeat/source/browse/tags/atombeat-parent-0.2-alpha-10/atombeat-service/src/main/files/config/plugins.xqm) configuration module and the [unzip plugin test case](http://code.google.com/p/atombeat/source/browse/tags/atombeat-parent-0.2-alpha-10/atombeat-integration-tests/src/test/java/org/atombeat/it/plugin/unzip/TestUnzipPlugin.java).

## [issue 175](https://code.google.com/p/atombeat/issues/detail?id=175) improve performance of link extensions plugin ##

It has been found that, in previous releases, the link extensions plugin, and in particular the @atombeat:allow extension attribute, has a substantial performance cost when used on links within entries in a feed (the 'entry-in-feed' context).

In this release, a new algorithm is used to calculate the value of the @atombeat:allow extension attribute, which may reduce the time taken to generate a feed containing several hundred entries by a factor of between 1 and 6, depending on how many links are being decorated and on how the access control lists are configured and used.

However, note that calculating the value of the @atombeat:allow extension attribute for a significant number of entries is still an expensive operation, and will still dominate the costs of generating a large feed. If you are working with collections of more than 100 members, and performance when listing the collection is important, then it is recommended that the @atombeat:allow extension attribute is only used in entries within a feed where absolutely necessary, and that the link-extensions plugin is used in conjunction with the paging plugin.

## [issue 176](https://code.google.com/p/atombeat/issues/detail?id=176) improve performance of list collection under security ##

In the absence of any other plugins, the costs of generating a large feed will be dominated by the security-plugin:after() function, and in particular by the costs of filtering the entries in the feed according to the user's permissions.

This release contains a performance optimisation for the cases where the workspace and collection ACLs have priority over resource ACLs, and where decisions are made at the workspace or collection level.

# 0.2-alpha-9 #

## [issue 169](https://code.google.com/p/atombeat/issues/detail?id=169) use of atomdb:edit-path-info() causes cardinality issues ##

It has been found that use of the atomdb:edit-path-info() function under some circumstances causes unpredictable behaviour, which we believe is related to an issue in eXist 1.4.0 regarding storage of temporary XML fragments in the database. All use of the atomdb:edit-path-info() function within AtomBeat has been removed, and it is strongly recommended that any third-party extensions or plugins do likewise.

If you need this utility function, then it appears safe to create an equivalent function in your module's local namespace and use that instead.

## [issue 168](https://code.google.com/p/atombeat/issues/detail?id=168) recognise "title" field in multipart/form-data post to create media ##

When using the AtomBeat protocol extension to create a media resource via a multipart/form-data POST request, you can now include a "title" field in the request data, and this will be used to populate the title of the new media-link entry. If not provided, AtomBeat will fall back to using the "media" field's filename as the title.

## [issue 167](https://code.google.com/p/atombeat/issues/detail?id=167)	@count link extension ##

Support has been added in the link extensions plugin for an @atombeat:count attribute on links referring to collections. When configured to appear, the attribute will report the number of members in the linked collection.

To configure the attribute to appear on one or more links, add markup like the following to an Atom feed document when creating or updating a collection:

```
<atombeat:config-link-extensions xmlns:atombeat="http://purl.org/atombeat/xmlns">
    <atombeat:extension-attribute
        name="count"
        namespace="http://purl.org/atombeat/xmlns">
        <atombeat:config context="feed">
            <atombeat:param name="match-rels" value="foo http://example.org/rel/bar"/>
        </atombeat:config>
        <atombeat:config context="entry">
            <atombeat:param name="match-rels" value="*"/>
        </atombeat:config>
        <atombeat:config context="entry-in-feed">
            <atombeat:param name="match-rels" value="baz http://example.org/rel/quux"/>
        </atombeat:config>
    </atombeat:extension-attribute>
</atombeat:config-link-extensions>
```

The link extensions plugin must also be enabled in the config/plugins.xqm module.

## [issue 165](https://code.google.com/p/atombeat/issues/detail?id=165)	2G limit on creating media ##

In previous releases there was a bug causing an unintended limit on the size of media resource that could be created by POSTing the media content to a collection URI. The limit was 2G, and any request above this size would appear to succeed but no data would actually be stored.

There is now no limit on the size of media resource that can be created by direct POST.

# 0.2-alpha-8 #

## [issue 164](https://code.google.com/p/atombeat/issues/detail?id=164) request-path-info is coerced to lower-case, which is not backwards-compatible with existing data ##

In the previous release the request path-info was coerced to lower case, which is clearly not backwards-compatible with any resources that used capital letters in the resource ID.

The request path-info is now compared in a **case-sensitive** manner, which means that this release should be backwards-compatible with existing data created by previous releases in the 0.2-alpha-**series.**

## [issue 163](https://code.google.com/p/atombeat/issues/detail?id=163) security-protocol:do-get($request). XPDY0002 : variable '$CONSTANT:OP-RETRIEVE-COLLECTION-ACL' is not set ##

This is a bug fix, in the previous release there was a problem related to the use of the plugin-util module (e.g., as used by the link expansion plugin).

## [issue 160](https://code.google.com/p/atombeat/issues/detail?id=160)	xutil:get-header does not do case-insensitive match ##

This is a minor bug fix, the xutil:get-header() function now does a case-insensitive comparison when looking up header names. The xutil:get-parameter() function also does a case-insensitive comparison.

## [issue 134](https://code.google.com/p/atombeat/issues/detail?id=134) allow a collection to be configured to not appear in the service document ##

In this release, a collection can be configured to **not** appear in the service document by including the following markup within the `<app:collection>` element when you create or update the collection:

```
<f:features xmlns:f="http://purl.org/atompub/features/1.0">
  <f:feature ref="http://purl.org/atombeat/feature/HiddenFromServiceDocument"/>
</f:features>
```

...e.g.:

```
<atom:feed 
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:app="http://www.w3.org/2007/app"
    xmlns:f="http://purl.org/atompub/features/1.0">
    <atom:title type='text'>A Hidden Collection</atom:title>
    <app:collection>
        <atom:title type='text'>A Hidden Collection</atom:title>
        <app:accept>application/atom+xml;type=entry</app:accept>
        <f:features>
            <f:feature ref="http://purl.org/atombeat/feature/HiddenFromServiceDocument"/>
        </f:features>
    </app:collection>
</atom:feed>
```

# 0.2-alpha-7 #

## [issue 157](https://code.google.com/p/atombeat/issues/detail?id=157) null pointer exception during internal request call to request:set-attribute ##

In the previous release (0.2-alpha-6) there is a bug related to internal requests (e.g., direct calls to atom-protocol:do-`*` or plugin-util:`*`), where some modules or plugins executing during an internal requests attempt to access the context HTTP request object via the eXist request: function module. This bug can manifest as a 500 response and a null pointer exception in the server's stack trace.

This bug highlights the fact that it is **not safe** to use the eXist request: function module in **any** code that might execute as part of an internal request. This includes plugin functions and configuration modules such as `config/shared.xqm`. Any information required from the request **must** be obtained from the $request variable passed in to protocol and plugin functions. In particular, it is **not** safe to use request:set-attribute() to pass data from the before phase of execution to the after phase. All uses of request:set-attribute() within AtomBeat plugins has been removed.

Note that, in order to allow plugins to pass data safely from the before phase of execution to the after phase, the return signature of plugin functions has been slightly modified.

Any existing plugin executing in the before phase now has a choice. Plugin functions in the before phase can return a single item, which will be treated as the (possibly modified) request entity, as in previous releases. This means that this release should be backwards-compatible with plugin functions written to the 0.2-alpha-6 signature. In addition, in this release, before plugins can also return a sequence of two items, in which case the first item will be treated as the (possibly modified) request entity, and the second item will be treated as a set of request attributes to be incorporated into the request. E.g.:

```
declare function example-plugin:before(
    $operation as xs:string ,
    $request as element(request) ,
    $entity as item()*
) as item()*
{

    let $modified-entity := 
        if ( empty( $entity) ) then <void/>
        else local:do-something-to-request-entity( $entity )
    
    let $set-request-attributes :=
        <attributes>
            <attribute>
                <name>example-plugin.foo</name>
                <value>bar</value>
            </attribute>
        </attributes>
            
    return ( $modified-entity , $set-request-attributes )
    
};
```

The set request attribute can be accessed in downstream plugins via the $request variable, e.g., `$request/attributes/attribute[name='example-plugin.foo']/value/text()`. You can include XML fragments within the attribute value as well as atomic datatypes.

Note that any attributes already in the request with the same attribute name(s) as those returned by the plugin funciton will be replaced, but any other request attributes already present will be retained in the request. I.e., this is not a complete replacement of all request attributes, just an instruction to set given named request attributes.

Note also that care must be taken to handle cases where the request entity is empty (e.g., for a GET or DELETE request) and you also want to set some request attributes. In this case, use a `<void/>` XML fragment in place of the entity in the response sequence.

# 0.2-alpha-6 #

## [issue 155](https://code.google.com/p/atombeat/issues/detail?id=155) proper link expansion using internal sub-requests ##

Previously, it was not possible to use any of the protocol query modules ([atom-protocol.xqm](http://code.google.com/p/atombeat/source/browse/trunk/parent/atombeat-service/src/main/files/lib/atom-protocol.xqm), [security-protocol.xqm](http://code.google.com/p/atombeat/source/browse/trunk/parent/atombeat-service/src/main/files/lib/security-protocol.xqm), [history-protocol.xqm](http://code.google.com/p/atombeat/source/browse/trunk/parent/atombeat-service/src/main/files/lib/history-protocol.xqm)) from within a plugin, because this created an import cycle, which is not permitted in XQuery 1.0.

This was unfortunate as it meant, among other things, that the link expansion plugin could not properly simulate retrieval of the link target (including execution of plugins which may augment the response), all it could do was retrieve and inline the content actually stored in the database.

This release includes a work-around for the import cycle limitation. A new module [plugin-util.xqm](http://code.google.com/p/atombeat/source/browse/trunk/parent/atombeat-service/src/main/files/lib/plugin-util.xqm) contains functions that can safely be called from within a plugin function, in either before or after chains. For example, the plugin-util:atom-protocol-do-get() function is a proxy for the atom-protocol:do-get() function, and can be used to make internal protocol requests that return the same response as if making an external HTTP GET request.

The link expansion plugin has been updated to make use of this new facility. This means that, now, the inline content provided in expanded links will be identical to that which would have been obtained via an HTTP GET request on the link @href.

Note that this means inline content may also be expanded itself, but link cycles will be detected and any URI already expanded once will not be expanded where it appears subsequently.

## [issue 74](https://code.google.com/p/atombeat/issues/detail?id=74) catch errors ##

Any dynamic errors are now caught in Atom protocol queries, and will result in a 500 response with the error message as text/plain response entity.

(Static query compilation errors will still be reported by eXist as 400 with an HTML error trace.)

## [issue 123](https://code.google.com/p/atombeat/issues/detail?id=123) auto-categorise feature ##

In this release AtomBeat implements support for the app:categories element within collection definitions. The [Atom protocol spec](http://www.atomenabled.org/developers/protocol/atom-protocol-spec.php#categories-elem) is a bit vague on how exactly this should work, so AtomBeat's behaviour is as follows.

If an app:collection contains an app:categories element where the @fixed='yes' but there is no @scheme attribute, then any category in an Atom entry not within the given list is stripped automatically on create or update.

If an app:collection contains an app:categories element where the @fixed='yes' and there **is** a @scheme attribute, then any category in an Atom entry **with the given scheme** but not within the given list is stripped automatically on create or update. Any categories in a different scheme are allowed to remain. This enables collections to specify control of categories within a given scheme but also allow uncontrolled use of categories from other schemes.

AtomBeat also supports an extension attribute @default on at most one atom:category element within an app:categories element. The default category will be automatically added if no categories match the given list.

E.g., a collection defined like:

```
<app:collection xmlns:app='http://www.w3.org/2007/app' href='http://localhost:8081/atombeat/service/content/test'>
  <app:categories scheme='http://example.org/scheme' fixed='yes'>
    <atom:category term='foo' label='Foo'/>
    <atom:category term='bar' label='Bar' default='yes'/>
  </app:categories>
</app:collection>
```

...will mean that any member of the collection must contain one category with scheme http://example.org/scheme from the given list (either 'foo' or 'bar'). Any categories with scheme http://example.org/scheme but not in this list will be stripped automatically. If no categories from this list are given, the default category ('bar') will be automatically added. Categories in schemes other than http://example.org/scheme will be uncontrolled, i.e., clients are free to do what they want.

## [issue 151](https://code.google.com/p/atombeat/issues/detail?id=151) service links ##

Atom entries and feeds now include an atom:link with rel='service' pointing to the service document location.

## [issue 150](https://code.google.com/p/atombeat/issues/detail?id=150) use slug to allow client preference for member uri ##

In this release the "Slug" request header can be used when POSTing an Atom entry document to a collection URI to indicate a client preference for the URI of the new collection member to be created.

E.g., if the header "Slug: foo" is included in a request to create a new member in the http://localhost:8081/atombeat/service/content/test collection, then the URI of the new member will be http://localhost:8081/atombeat/service/content/test/foo - if no member at that URI already exists. If a member does already exist at that URI, AtomBeat will try foo1, foo2 ... foo5, and then fall back to using the `config:generate-identifier()` function as if no Slug header were present.

## [issue 141](https://code.google.com/p/atombeat/issues/detail?id=141) conneg for service documents ##

Content negotiation can now be configured for the Atom service document. Transformations to HTML and JSON are supported in the default configuration, and additional variants can be configured in a similar way to configuration of content negotiation for Atom feeds and entries.

To upgrade to this release two additional configuration variables need to be added to the `config/conneg.xqm` configuration file. These are `$conneg-config:service-variants` and `$conneg-config:service-transformers`. An example configuration from the default configuration is given below:

```
xquery version "1.0";

module namespace conneg-config = "http://purl.org/atombeat/xquery/conneg-config";

...

(:~
 : Define variant representations for service document.
 :)
declare variable $conneg-config:service-variants := 
    <variants>
        <variant>
            <output-key>html</output-key>
            <media-type>text/html</media-type>
            <output-type>xml</output-type>
            <doctype-public>-//W3C//DTD&#160;XHTML&#160;1.0&#160;Strict//EN</doctype-public>
            <doctype-system>http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd</doctype-system>
            <qs>0.95</qs>
        </variant>
        <variant>
            <output-key>atomsvc</output-key>
            <media-type>application/atomsvc+xml</media-type>
            <output-type>xml</output-type>
            <qs>0.8</qs>
        </variant>
        <variant>
            <output-key>json</output-key>
            <media-type>application/json</media-type>
            <output-type>text</output-type>
            <qs>0.5</qs>
        </variant>
        <variant>
            <output-key>xml</output-key>
            <media-type>application/xml</media-type>
            <output-type>xml</output-type>
            <qs>0.3</qs>
        </variant>
        <variant>
            <output-key>textxml</output-key>
            <media-type>text/xml</media-type>
            <output-type>xml</output-type>
            <qs>0.2</qs>
        </variant>
        <variant>
            <output-key>text</output-key>
            <media-type>text/plain</media-type>
            <output-type>xml</output-type>
            <qs>0.1</qs>
        </variant>
    </variants>
;



(:~
 : Define transformers for variant representations. There MUST be one transformer
 : for each variant, and they must occur in the same position within the sequence
 : as the corresponding variant definition above.
 :)
declare variable $conneg-config:service-transformers := (
    <stylesheet>/stylesheets/atomsvc2html4.xslt</stylesheet> , (: if not absolute URI will be concatenated with $config:service-url-base :)
    <identity/> ,
    util:function( QName( "http://purl.org/atombeat/xquery/json" , "json:xml-to-json" ) , 1 ) , (: if you use a function as a transformer, then the function's module MUST be imported into this module, see imports at the top of this file :)
    <identity/> ,
    <identity/> ,
    <identity/> 
);
```

## [issue 137](https://code.google.com/p/atombeat/issues/detail?id=137) link from service document to workspace security descriptor ##

The service document in a security-enabled AtomBeat service now includes a link from within the singleton `<app:workspace>` element to the workspace security descriptor.

## [issue 120](https://code.google.com/p/atombeat/issues/detail?id=120) filter service documents using permissions ##

In a security-enabled AtomBeat service, service documents will now be filtered to include only `<app:collection>` elements where the requesting user is allowed to list that collection.

## [issue 152](https://code.google.com/p/atombeat/issues/detail?id=152) access control for service documents ##

In security-enabled AtomBeat service, retrieval of service documents can now be controlled via access control lists. The new operation name RETRIEVE\_SERVICE can be used in access control entries to allow or deny access to the service document.

Note that this feature has been implemented by passing the RETRIEVE\_SERVICE operation through the plugin functions. I.e., any plugin functions can now intercept the RETRIEVE\_SERVICE operation and execute side-effects and/or transform the response.

## [issue 149](https://code.google.com/p/atombeat/issues/detail?id=149) cannot use atom-protocol:do-`*` from within xquery as headers from host page are interpreted as headers in nested request ##

The signature of all plugin functions has been changed, to provide better support for calling the [Atom protocol library functions](http://code.google.com/p/atombeat/source/browse/trunk/parent/atombeat-service/src/main/files/lib/atom-protocol.xqm) (e.g., `atom-protocol:do-post-atom-entry()`) programmatically from within other XQueries.

Plugins in the **before** chain now must have the following signature:

```
declare function example-plugin:before(
    $operation as xs:string ,
    $request as element(request) ,
    $entity as item()*
) as item()*
{

    (: any side-effects :)	
    let $modified-entity := ... (: transform the request entity, if desired :)
    return $modified-entity
    
};
```

The `$operation` argument is the name of the protocol operation being executed, as in previous versions.

The `$request` argument is an XML fragment representing the HTTP request being executed. It has the general form:

```
<request>
    <path-info>/test/xyz</path-info>
    <method>POST</method>
    <headers>
        <header>
            <name>Accept</name>
            <value>application/atom+xml</value>
        </header>
        <header>
            <name>Content-Type</name>
            <value>application/atom+xml</value>
        </header>
    </headers>
    <parameters>
        <parameter>
            <name>foo</name>
            <value>bar</value>
        </parameter>
    </parameters>
    <user>someone@example.org</user>
    <roles>
        <role>ROLE_FOO</role>
    </roles>
</request>
```

So, whereas previously $request-path-info was supplied as a function argument, now the path-info can be accessed (along with other features of the request) via the $request argument, e.g.:

```
    let $request-path-info := $request/path-info/text()
```

The `$entity` argument is the request payload, if available. This will also be empty in the case of media operations, as media payloads may be streamed directly from the context request.

The return type of **before** plugins is not changed. Either the request entity is returned, possibly with modifications, in which case request processing will continue, or a `<response>` element is returned, in which case request processing will terminate and a response be sent immediately.

Plugins in the **after** chain now must have the following signature:

```
declare function logger-plugin:after(
	$operation as xs:string ,
	$request as element(request) ,
	$response as element(response)
) as element(response)
{

    (: any side-effects :)	
    let $modified-response := ... (: modify the response, if desired :)
    return $modified-response

}; 
```

The `$operation` and `$request` arguments are as described above for the **before** plugins. The `$response` argument is as in previous versions. The return type is as in previous versions, being an XML fragment representing the response, either unmodified or with modifications if desired.

**Plugin functions in either before or after chains should now access request headers and parameters via the $request variable, and should not call `request:get-header()` or `request:get-parameter()` directly, as this can lead to confusion and incorrect behaviour when an Atom protocol library function such as `atom-protocol:do-post-atom-entry()` is called programmatically from another XQuery.**

For convenience, the xutil module has some functions for accessing request headers and parameters, e.g.:

```
    let $content-type-header := xutil:get-header( "Content-Type" , $request )
    let $foo-parameter := xutil:get-parameter( "foo" , $request )
```

Because the number of arguments supplied to plugin functions in the **before** chain has changed from 4 to 3, the plugin configuration file (`config/plugins.xqm`) will need to be changed accordingly, e.g.:

```
declare function plugin:before() as function* {
    (
        util:function( QName( "http://purl.org/atombeat/xquery/logger-plugin" , "logger-plugin:before" ) , 3 ) ,
        util:function( QName( "http://purl.org/atombeat/xquery/security-plugin" , "security-plugin:before" ) , 3 ) , 
        util:function( QName( "http://purl.org/atombeat/xquery/conneg-plugin" , "conneg-plugin:before" ) , 3 ) , 
        util:function( QName( "http://purl.org/atombeat/xquery/tombstones-plugin" , "tombstones-plugin:before" ) , 3 ) ,  
       	util:function( QName( "http://purl.org/atombeat/xquery/link-expansion-plugin" , "link-expansion-plugin:before" ) , 3 ) ,  
        util:function( QName( "http://purl.org/atombeat/xquery/link-extensions-plugin" , "link-extensions-plugin:before" ) , 3 ) ,  
        util:function( QName( "http://purl.org/atombeat/xquery/history-plugin" , "history-plugin:before" ) , 3 )   
    )
};
```

The number of arguments supplied to plugin functions in the **after** chain has not changed.

The upshot of all this is that now it should be safe to write XQueries that do things like combining multiple virtual Atom protocol requests, e.g. (trivial example, hopefully you get the general idea):

```
declare namespace atom = "http://www.w3.org/2005/Atom" ;
import module namespace atom-protocol = "http://purl.org/atombeat/xquery/atom-protocol" at "../lib/atom-protocol.xqm" ;

let $request1 :=
    <request>
        <path-info>/foo</path-info>
        <method>POST</method>
        <headers>
            <header>
                <name>Accept</name>
                <value>application/atom+xml</value>
            </header>
            <header>
                <name>Content-Type</name>
                <value>application/atom+xml</value>
            </header>
        </headers>
        <parameters/>
        <user>someone@example.org</user>
        <roles/>
    </request>

let $entity1 :=
    <atom:entry>
        <atom:title>foo entry</atom:title>
    </atom:entry>
    
let $response1 := atom-protocol:do-post-atom-entry( $request1 , $entity1 ) (: will perform protocol operation including plugin execution :)

return

    if ( $response1/status = 201 ) then
    
        let $request2 :=
            <request>
                <path-info>/bar</path-info>
                <method>POST</method>
                <headers>
                    <header>
                        <name>Accept</name>
                        <value>application/atom+xml</value>
                    </header>
                    <header>
                        <name>Content-Type</name>
                        <value>application/atom+xml</value>
                    </header>
                </headers>
                <parameters/>
                <user>someone@example.org</user>
                <roles/>
            </request>

        let $entity2 :=
            <atom:entry>
                <atom:title>bar entry</atom:title>
                <atom:link rel='related' href='{$response1/body/atom:entry/atom:link[@rel="edit"]/@href cast as xs:string}'/>
            </atom:entry>
            
        let $response2 := atom-protocol:do-post-atom-entry( $request2 , $entity2 ) (: will perform protocol operation including plugin execution :)

        return
                
            if ( $response2/status = 201 ) then ... (: handle success :)
                
            else ... (: handle failure after second sub-request :)
    
    else ... (: handle failure after first sub-request :)
```

Another example of an XQuery that makes use of this pattern is the [admin/install.xql](http://code.google.com/p/atombeat/source/browse/trunk/parent/atombeat-service/src/main/files/admin/install.xql) page.

Please note that **not all functions in the [atom-protocol XQuery module](http://code.google.com/p/atombeat/source/browse/trunk/parent/atombeat-service/src/main/files/lib/atom-protocol.xqm) can be called in this way**. Some functions, in particular those processing media content, need to access the context request, and thus can only be used via direct HTTP request to the /service/content endpoint. Those functions that **can** safely be called from within another XQuery include:

  * atom-protocol:do-get()
  * atom-protocol:do-get-member()
  * atom-protocol:do-get-collection()
  * atom-protocol:do-post-atom()
  * atom-protocol:do-post-atom-entry()
  * atom-protocol:do-post-atom-feed()
  * atom-protocol:do-put-atom()
  * atom-protocol:do-put-atom-entry()
  * atom-protocol:do-put-atom-feed()
  * atom-protocol:do-delete-member()
  * atom-protocol:do-delete-media()

# 0.2-alpha-5 #

## [issue 140](https://code.google.com/p/atombeat/issues/detail?id=140) make json output consistent using element local names instead of qnames ##

The function used to transform from Atom XML to JSON in the default content negotiation plugin configuration has been changed to use a slightly tweaked version of the XML-to-JSON function that comes with eXist. The tweak is to use element local names to generate JSON object keys instead of node names, which means that clients asking for JSON won't get confused by inconsistent use of namespace prefixes in the source Atom XML document.

E.g., an Atom entry document like:

```
<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
    <atom:id>urn:uuid:0b7c7ded-0eaf-43ca-84ac-7de93ad7f636</atom:id>
    <atom:published>2011-02-01T11:24:42.81Z</atom:published>
    <atom:updated>2011-02-01T11:24:42.81Z</atom:updated>
    <atom:author>
        <atom:name>adam</atom:name>
    </atom:author>
    <title xmlns="http://www.w3.org/2005/Atom" type="text">testing json representstation</title>
    <summary xmlns="http://www.w3.org/2005/Atom" type="text">this is a test to check that element local names are used in json representation</summary>
    <atom:link rel="edit" type="application/atom+xml;type=entry" href="http://localhost:8081/atombeat-exist-minimal-secure/service/content/test/0b7c7ded-0eaf-43ca-84ac-7de93ad7f636"/>
    <atom:link rel="alternate" type="application/atom+xml" href="http://localhost:8081/atombeat-exist-minimal-secure/service/content/test/0b7c7ded-0eaf-43ca-84ac-7de93ad7f636?output=atom"/>
    <atom:link rel="alternate" type="application/json" href="http://localhost:8081/atombeat-exist-minimal-secure/service/content/test/0b7c7ded-0eaf-43ca-84ac-7de93ad7f636?output=json"/>
</atom:entry>
```

...gets transformed to JSON like:

```
{
  "id" : "urn:uuid:0b7c7ded-0eaf-43ca-84ac-7de93ad7f636", 
  "published" : "2011-02-01T11:24:42.81Z", 
  "updated" : "2011-02-01T11:24:42.81Z", 
  "author" : {
    "name" : "adam"
  }, 
  "title" : {
    "@type": "text", 
    "#text": "testing json representstation"
  }, 
  "summary" : {
    "@type": "text", 
    "#text": "this is a test to check that element local names are used in json representation"
  }, 
  "link" : [ 
    {
      "@rel": "edit", 
      "@type": "application/atom+xml;type=entry", 
      "@href": "http://localhost:8081/atombeat-exist-minimal-secure/service/content/test/0b7c7ded-0eaf-43ca-84ac-7de93ad7f636"
    }, 
    {
      "@rel": "alternate", 
      "@type": "application/atom+xml", 
      "@href": "http://localhost:8081/atombeat-exist-minimal-secure/service/content/test/0b7c7ded-0eaf-43ca-84ac-7de93ad7f636?output=atom"
    }, 
    {
      "@rel": "alternate", 
      "@type": "application/json", 
      "@href": "http://localhost:8081/atombeat-exist-minimal-secure/service/content/test/0b7c7ded-0eaf-43ca-84ac-7de93ad7f636?output=json"
    }, 
  ]
}
```

## [issue 139](https://code.google.com/p/atombeat/issues/detail?id=139) conneg plugin doesn't strip alternate links prior to create or update ##

This is a bug fix in the content negotiation plugin.

## [issue 57](https://code.google.com/p/atombeat/issues/detail?id=57) configurable conneg plugin ##

This release includes a new content negotiation (conneg) plugin, that allows you to request and serve Atom feeds and entries in variant representation formats, including HTML and JSON. The plugin implements [server-driven content negotation](http://www.w3.org/Protocols/rfc2616/rfc2616-sec12.html) based on the values provided in the Accept request header. The plugin also adds `alternate` links to entries and feeds, so you can use these links to retrieve a specific representation format if you need to without having to provide an `Accept` header.

To enable the conneg plugin, the [config/plugins.xqm](http://code.google.com/p/atombeat/source/browse/trunk/parent/atombeat-service/src/main/files/config/plugins.xqm) file needs to be modified, to include the conneg plugin before and after functions in the respective plugin chains.

The plugin configuration is defined in the [config/conneg.xqm](http://code.google.com/p/atombeat/source/browse/trunk/parent/atombeat-service/src/main/files/config/conneg.xqm) file. A [default version](http://code.google.com/p/atombeat/source/browse/trunk/parent/atombeat-service/src/main/files/config/conneg.xqm) of this file is included in all AtomBeat WAR packages.

This default configuration supports content negotiation to HTML and JSON formats out of the box. If you want to add additional variant formats, you need to implement either an XSLT transformation or an XQuery function to transform from Atom to the new format, then modify the `$conneg-config:variants` and `$conneg-config:transformers` variables. Note that these two variables need to be kept consistent with each other, i.e., the ordering of variants must correspond to the ordering of transformers.

The server-driven content negotiation algorithm implemented in AtomBeat is close to that implemented in Apache, see also the [Apache content negotiation documentation](http://httpd.apache.org/docs/current/content-negotiation.html#methods).

# 0.2-alpha-4 #

## [issue 81](https://code.google.com/p/atombeat/issues/detail?id=81) reference groups where source is any atom member ##

The way that out-of-line security groups are referenced from a security descriptor has changed. In this release, you can either reference a security group defined in another security descriptor, **or** you can reference a group defined in an Atom collection member.

To reference a group defined in a security descriptor, use the **security descriptor URI** in the `@src` attribute. E.g.:

```
<atombeat:security-descriptor>
     <atombeat:groups>
         <atombeat:group id="admins" src="http://example.org/atombeat/service/security/mycollection/mymember"/>
     </atombeat:groups>
     <atombeat:acl>
     </atombeat:acl>
 </atombeat:security-descriptor>
```

To reference a group defined in an Atom collection member, use the **member's edit URI** in the `@src` attribute.

```
<atombeat:security-descriptor>
     <atombeat:groups>
         <atombeat:group id="admins" src="http://example.org/atombeat/service/content/mycollection/mymember"/>
     </atombeat:groups>
     <atombeat:acl>
     </atombeat:acl>
 </atombeat:security-descriptor>
```

The definition of a group can appear **anywhere** within the member's Atom entry document. I.e., AtomBeat will use the XPath `//atombeat:group[@id='admins']` to find matching groups within the referenced document.

In previous releases, you could only reference groups defined in a security descriptor, and this was done indirectly **via** the URI of the workspace, collection or member whose descriptor you wanted to reference. Upgrading to this release will require that any URIs given in `@src` attributes on `atombeat:group` elements are **changed** to point **directly** to the URI of the security descriptor containing the group definitions.

# 0.2-alpha-3 #

## [issue 130](https://code.google.com/p/atombeat/issues/detail?id=130) remove references to request from atomdb xquery module ##

The signature of the following functions has changed:

  * atomdb:create-entry
  * atomdb:create-media-link-entry
  * atomdb:create-feed
  * atomdb:create-member
  * atomdb:create-media-resource
  * atomdb:create-collection
  * atomdb:create-file-backed-media-resource-from-request-data
  * atomdb:create-file-backed-media-resource-from-existing-media-resource
  * atomdb:create-file-backed-media-resource-from-upload

An additional parameter `$user-name` has been added to the function signature, to remove some of the dependencies of the `lib/atomdb.xqm` module on the eXist request function module. This change has been made to make testing the `lib/atomdb.xqm` functions easier.

Upgrading to this release will require any custom XQuery modules that call any of the above functions to be modified to use the new function signature.

## [issue 129](https://code.google.com/p/atombeat/issues/detail?id=129) make atom:id construction configurable ##

A new configuration function `config:construct-member-atom-id()` has been added to the `config/shared.xqm` configuration module. This new function allows customisation of the way in which `atom:id` elements are populated for new collection members.

Upgrading to this release will require this function to be implemented in the `config/shared.xql` configuration module.

If you are using UUIDs as the basis for member identifiers, then you have the option to use UUID URNs for atom:id elements. E.g.,:

```
declare function config:generate-identifier(
    $collection-path-info as xs:string
) as xs:string
{
    util:uuid()
};

declare function config:contruct-member-atom-id(
    $identifier as xs:string ,
    $collection-path-info as xs:string
) as xs:string
{
    concat( 'urn:uuid:' , $identifier )
};
```

The $identifier parameter passed into this function is obtained from calling the config:generate-identifier() function.

Alternatively, e.g., if you were using shorter identifiers that are not guaranteed to be unique across collections, you could do something like the following:

```
declare function config:generate-identifier(
    $collection-path-info as xs:string
) as xs:string
{
    xutil:random-alphanumeric( 6 )
};

declare function config:contruct-member-atom-id(
    $identifier as xs:string ,
    $collection-path-info as xs:string
) as xs:string
{
    concat( $config:self-link-uri-base , $collection-path-info , $identifier )
};
```

## [issue 118](https://code.google.com/p/atombeat/issues/detail?id=118)	implement md5 in @hash link extension attribute for media-link entries ##

If the FILE media storage mode is being used, an MD5 hash will automatically be calculated for every new and updated media resource, and the hash value will be added to the associated media-link entry in a @hash attribute on both the 'edit-media' link and the atom:content element.

This is a backwards compatible change, in that upgrading to this release does not require any migration of the data. However, note that media-link entries created prior to upgrade will not include a @hash attribute.

## [issue 114](https://code.google.com/p/atombeat/issues/detail?id=114) configure self link uri base independently from edit uri base ##

The way in which the URI base for 'self', 'edit' and 'edit-media' links is configured has changed. The variable $config:content-service-url in the config/shared.xqm configuration module has been removed. Three new variables have been added in it's place, being $config:self-link-uri-base, $config:edit-link-uri-base and $config:edit-media-link-uri-base. These new variables allow URI bases for different link types to be configured independently if desired.

Upgrading to this release will require modification of the config/shared.xqm to use the new configuration variables.

# 0.2-alpha-2 #

TODO document me complete release notes for this version

## [issue 24](https://code.google.com/p/atombeat/issues/detail?id=24) provide service documents ##

This release implements Atom Protocol service documents. E.g., if an AtomBeat service is located at at http://example.org/atombeat/service/ then a GET request to this URI will return an Atom Protocol service document listing available Atom collections.

The title and summary given in the atom:workspace element in the service document are configured using two new variables in the config/shared.xqm configuration module, being $config:workspace-title and $config:workspace-summary.

Upgrading to this release will require modification of the config/shared.xqm to use the new configuration variables.

Note also that collections created prior to upgrading to this release will not initially appear in the service document. They will appear after an update to the collection feed metadata, i.e., after a PUT to the collection URI.

## [issue 97](https://code.google.com/p/atombeat/issues/detail?id=97) remove ".atom" from the end of member URIs ##

In this release the string ".atom" is no longer appending to member URIs.

This is a major change, and requires that all member URIs present in the database prior to upgrade, e.g., in Atom entry documents, need to be modified following an upgrade to have the ".atom" suffix removed.

Note however that the documents stored in the eXist database still retain the ".atom" suffix, i.e., the documents themselves don't need to be moved.

## [issue 99](https://code.google.com/p/atombeat/issues/detail?id=99) wrong content type param on list collection ##

This was a bug in the response content-type when listing a collection, now fixed.

## [issue 104](https://code.google.com/p/atombeat/issues/detail?id=104) attributes are stripped on updated feed ##

This was a bug on updating collection metadata, now fixed.

## [issue 105](https://code.google.com/p/atombeat/issues/detail?id=105) maven looks at atombeat repo first ##

This was a bug in the maven configuration, now fixed.

## [issue 106](https://code.google.com/p/atombeat/issues/detail?id=106) migrate workspace to service ##

The default location for the AtomBeat service in all WAR packages has changed from /workspace to /service.

All AtomBeat URIs for resources (collections, members, media) created prior to upgrade will need to be modified to reflect the new URL base.

## [issue 111](https://code.google.com/p/atombeat/issues/detail?id=111) deleted entries should get stripped on request with feed ##

This was a bug on requests involving Atom feeds as the request entity, where any deleted entries were not previously stripped from the request, now fixed.

## [issue 112](https://code.google.com/p/atombeat/issues/detail?id=112) plugin returns empty in after or after-error ##

Reporting of bad return values from plugin functions in after and after-error chains has been improved. Plugin functions that do not return element(response) should now result in a more helpful error.

## [issue 116](https://code.google.com/p/atombeat/issues/detail?id=116) upgrade to spring security 3.1 ##

Spring Security in secure WAR packages has been upgraded to 3.1.0.M1.

# 0.2-alpha-1 #

## [issue 98](https://code.google.com/p/atombeat/issues/detail?id=98) implement tombstones ##

This release includes an implementation of the Atom Tombstones draft - http://tools.ietf.org/html/draft-snell-atompub-tombstones-11. See the TombstonesDesign wiki page for more information on configuring a collection with support for tombstones.

## [issue 100](https://code.google.com/p/atombeat/issues/detail?id=100) error plugins ##

A new plugin chain has been added in this release, allowing plugin functions to intercept protocol error responses and possibly modify the response or invoke side-effects. Upgrading to this release requires that a new function `plugin:after-error()` be defined in the [config/plugins.xqm](http://code.google.com/p/atombeat/source/browse/trunk/parent/atombeat-service/src/main/files/config/plugins.xqm) configuration module. The syntax is the same as for the `plugin:after()` configuration function. An example is below:

```
declare function plugin:after-error() as function* {
    (
        util:function( QName( "http://purl.org/atombeat/xquery/tombstones-plugin" , "tombstones-plugin:after-error" ) , 3 ) 
    )
};
```