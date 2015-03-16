

# Introduction #

Using AtomBeat out of the box with standard Atom Protocol operations provide basic CRUD persistence capabilities - you can create collection members, retrieve them, update them, delete them, and list collections (and also manage access and versioning). This is useful for some applications, but in more complex applications you often want to design a REST service where operations have effects beyond simple CRUD persistence.

For example, in an online shopping application, you might want a POST request to the `/orders` collection to trigger an order processing workflow, in addition to persisting the order. Or, in a scientific data repository application, you might want a POST request to the `/studies` collection to create a new study, but also create a new collection linked to the study where media can be uploaded.

AtomBeat provides a platform for using the Atom Protocol and Format as a starting point for developing more complicated REST services. You can implement **plug-ins** to the AtomBeat protocol engine, to execute arbitrary code either **before** or **after** the main protocol operation. During the **before** phase, plug-ins can modify the request data and can interrupt request processing. During the **after** phase, plug-ins can modify the response.

There are many ways in which plug-ins might be used. For example, you might implement a completely passive plug-in that simply logs some useful information both before and after main operation execution. Or, you might implement a plug-in that does not interrupt or alter the normal processing of a protocol operation, but adds a number of custom side-effects. Or, you could choose to implement plug-ins that override or modify the normal protocol operations in some way.

Plug-ins are written as XQuery functions, so you have access to the eXist function library. eXist also supports invocation of Java code from within XQueries.

The AtomBeat plug-in framework is roughly similar in concept to servlet filters, in that each protocol operation has a before chain (a sequence of functions invoked in turn prior to the main operation) and an after chain (a sequence of functions invoked in turn after the main operation has been executed). However, there are some important differences. The plug-in functions in the before chain are **not** invoked immediately upon receiving an incoming request. Rather, the Atom protocol operation will do some work to determine if the request is a **valid protocol operation**, prior to invoking the before chain.

E.g., the Atom protocol engine will determine if the resource to which the request is addressed exists, before the plug-in framework is involved. If the resource does not exist, a 404 response will be sent, and the **before** and **after** plug-ins will never be invoked.

In other words, the AtomBeat protocol engine will attempt to map the incoming request onto one of its known protocol operations, prior to executing plug-ins. The **plug-ins wrap the execution of a valid protocol operation**, and **not** the entire request processing engine. The plug-in framework is also roughly analogous to aspect-oriented programming, where code is executed before and after a method invocation.

# A Simple Plug-in Example: logger-plugin.xqm #

Below is an example of a simple plug-in function to log some information during the **before** phase of protocol execution. (See [logger-plugin.xqm](http://code.google.com/p/atombeat/source/browse/trunk/atombeat/war/atombeat/plugins/logger-plugin.xqm) for the full source code.)

```
xquery version "1.0";

module namespace logger-plugin = "http://purl.org/atombeat/xquery/logger-plugin";
declare namespace atom = "http://www.w3.org/2005/Atom" ;
import module namespace util = "http://exist-db.org/xquery/util" ;

declare function logger-plugin:before(
	$operation as xs:string ,
	$request-path-info as xs:string ,
	$request-data as item()* ,
	$request-media-type as xs:string?
) as item()*
{

	let $message := concat( "before: " , $operation , ", request-path-info: " , $request-path-info ) 
	let $log := util:log( "info" , $message )
	
	return $request-data
	
};
```

All before plug-in functions must have the same signature, with 4 arguments. This function logs a message, then returns the request data, which will cause request processing to continue on to the next plug-in in the before chain, or the main protocol operation if this is the last in the chain.

Below is a plug-in function to log some information during the **after** phase.

```
declare function logger-plugin:after(
	$operation as xs:string ,
	$request-path-info as xs:string ,
	$response as element(response)
) as element(response)
{

	let $message := concat( "after: " , $operation , ", request-path-info: " , $request-path-info ) 
	let $log := util:log( "info" , $message )
	
	return $response

}; 
```

All after plug-in functions must have the same signature, with 3 arguments. This function logs a message, then returns the response unchanged.

Plug-in modules are typically stored in the [plugins](http://code.google.com/p/atombeat/source/browse/trunk/atombeat/war/atombeat/plugins) folder within AtomBeat, and are configured in the [config/plugins.xqm](http://code.google.com/p/atombeat/source/browse/trunk/atombeat/war/atombeat/config/plugins.xqm) module. For example, ...

```
xquery version "1.0";

module namespace plugin = "http://purl.org/atombeat/xquery/plugin";

import module namespace logger-plugin = "http://purl.org/atombeat/xquery/logger-plugin" at "../plugins/logger-plugin.xqm" ;
import module namespace security-plugin = "http://purl.org/atombeat/xquery/security-plugin" at "../plugins/security-plugin.xqm" ;
import module namespace history-plugin = "http://purl.org/atombeat/xquery/history-plugin" at "../plugins/history-plugin.xqm" ;

declare function plugin:before() as function* {
	(
		util:function( QName( "http://purl.org/atombeat/xquery/logger-plugin" , "logger-plugin:before" ) , 4 ) ,
		util:function( QName( "http://purl.org/atombeat/xquery/security-plugin" , "security-plugin:before" ) , 4 ) ,
		util:function( QName( "http://purl.org/atombeat/xquery/history-plugin" , "history-plugin:before" ) , 4 )   
	)
};

declare function plugin:after() as function* {
	(
		util:function( QName( "http://purl.org/atombeat/xquery/history-plugin" , "history-plugin:after" ) , 3 ) ,
		util:function( QName( "http://purl.org/atombeat/xquery/security-plugin" , "security-plugin:after" ) , 3 ) ,
		util:function( QName( "http://purl.org/atombeat/xquery/logger-plugin" , "logger-plugin:after" ) , 3 )
	)
};
```

The plug-in functions are invoked in the order in which they are given. In the example above, the logger plug-in will be invoked as the first in the before chain and the last in the after chain.

The syntax of this configuration module may seem obscure, I'm sorry we haven't found a good way of simplifying it yet. One thing to be careful of when adding or removing plug-ins from this configuration file is to ensure that the commas at the end of each plug-in declaration are correct to construct an XQuery sequence.

# An Advanced Plug-in Example: security-plugin.xqm #

You will probably have noticed by now that both the versioning functionality and the security system are implemented in AtomBeat as plug-ins to the main (vanilla) Atom protocol engine.

For example, the [security-plugin.xqm](http://code.google.com/p/atombeat/source/browse/trunk/atombeat/war/atombeat/plugins/security-plugin.xqm) module checks during the before phase whether an operation is allowed for the current user, and if not, will interrupt request processing with a 403 Forbidden response. During the after phase, the security plug-in will install default security descriptors if a new collection, member or media resource has been created, and will augment responses with the appropriate security links.

For example, below is a slightly simplified version of the security plug-in before function...

```
xquery version "1.0";

module namespace security-plugin = "http://purl.org/atombeat/xquery/security-plugin";

declare namespace atom = "http://www.w3.org/2005/Atom" ;
declare namespace atombeat = "http://purl.org/atombeat/xmlns" ;

import module namespace request = "http://exist-db.org/xquery/request" ;
import module namespace response = "http://exist-db.org/xquery/response" ;
import module namespace text = "http://exist-db.org/xquery/text" ;
import module namespace util = "http://exist-db.org/xquery/util" ;
import module namespace CONSTANT = "http://purl.org/atombeat/xquery/constants" at "../lib/constants.xqm" ;
import module namespace config = "http://purl.org/atombeat/xquery/config" at "../config/shared.xqm" ;
import module namespace xutil = "http://purl.org/atombeat/xquery/xutil" at "../lib/xutil.xqm" ;
import module namespace mime = "http://purl.org/atombeat/xquery/mime" at "../lib/mime.xqm" ;
import module namespace atomdb = "http://purl.org/atombeat/xquery/atomdb" at "../lib/atomdb.xqm" ;
import module namespace atomsec = "http://purl.org/atombeat/xquery/atom-security" at "../lib/atom-security.xqm" ;

declare function security-plugin:before(
	$operation as xs:string ,
	$request-path-info as xs:string ,
	$request-data as item()* ,
	$request-media-type as xs:string?
) as item()*
{
	
    if ( $config:enable-security )
	
    then

    	let $forbidden := atomsec:is-denied( $operation , $request-path-info , $request-media-type )
    	
    	return 
    	
    	    if ( $forbidden )
    		
    	    then 
    		
    	        let $response-data := "The server understood the request, but is refusing to fulfill it. Authorization will not help and the request SHOULD NOT be repeated."
    			
    		return 
    			
    		    <response>
    		        <status>{$CONSTANT:STATUS-CLIENT-ERROR-FORBIDDEN}</status>
    		        <headers>
    		            <header>
    		                <name>{$CONSTANT:HEADER-CONTENT-TYPE}</name>
    		                <value>{$CONSTANT:MEDIA-TYPE-TEXT}</value>
    		            </header>
    		        </headers>
    		        <body>{$response-data}></body>
    		    </response>
    			
            else if ( 
                $operation = $CONSTANT:OP-CREATE-MEMBER 
                or $operation = $CONSTANT:OP-UPDATE-MEMBER 
                or $operation = $CONSTANT:OP-CREATE-COLLECTION 
                or $operation = $CONSTANT:OP-UPDATE-COLLECTION
            )
            
            then 
            
                let $request-data := security-plugin:strip-descriptor-links( $request-data )
    		return $request-data
    			
	    else $request-data

    else $request-data

};

declare function security-plugin:strip-descriptor-links(
    $request-data as element()
) as element()
{

    let $request-data :=
        element { node-name( $request-data ) }
        {
            $request-data/attribute::* ,
            for $child in $request-data/child::*
            let $ln := local-name( $child )
            let $ns := namespace-uri( $child )
            let $rel := $child/@rel
            where (
                not(
                    $ln = $CONSTANT:ATOM-LINK
                    and $ns = $CONSTANT:ATOM-NSURI 
                    and ( $rel = "http://purl.org/atombeat/rel/security-descriptor" or $rel = "http://purl.org/atombeat/rel/media-security-descriptor" )
                )
            )
            return $child
        }

    return $request-data

};
```

A before plug-in terminates request processing by returning a `<response>` element.

Notice that the before function uses the `strip-descriptor-links` function to modify the incoming request data when creating or updating an Atom collection or member. If you write a plug-in that augments Atom responses in any way (e.g., the security plug-in adds links), then you will also need to make sure that those additions cannot be corrupted by being persisted in the AtomBeat database. I.e., you need to also check incoming create and update requests, and filter out any elements or attributes you want to retain control of in the plug-in.

A snippet of the main after plug-in function of the security plug-in is below...

```

declare function security-plugin:after(
	$operation as xs:string ,
	$request-path-info as xs:string ,
	$response as element(response)
) as element(response)
{

    if ( $config:enable-security )

    then
            
    	let $message := ( "security plugin, after: " , $operation , ", request-path-info: " , $request-path-info ) 
    	let $log := local:debug( $message )
    
    	return
    		
    	   if ( $operation = $CONSTANT:OP-CREATE-MEMBER )
    		
    	   then security-plugin:after-create-member( $request-path-info , $response)
    
           else if ( $operation = $CONSTANT:OP-CREATE-MEDIA )
            
           then security-plugin:after-create-media( $request-path-info , $response )
    
           else if ( $operation = $CONSTANT:OP-UPDATE-MEDIA )
            
           then security-plugin:after-update-media( $request-path-info , $response )
    
    	   else if ( $operation = $CONSTANT:OP-CREATE-COLLECTION )
    		
    	   then security-plugin:after-create-collection( $request-path-info , $response )
    
    	   else if ( $operation = $CONSTANT:OP-UPDATE-COLLECTION )
    		
    	   then security-plugin:after-update-collection( $request-path-info , $response )
    
    	   else if ( $operation = $CONSTANT:OP-LIST-COLLECTION )
    		
    	   then security-plugin:after-list-collection( $request-path-info , $response )
    		
    	   else if ( $operation = $CONSTANT:OP-RETRIEVE-MEMBER )
    		
    	   then security-plugin:after-retrieve-member( $request-path-info , $response )
    
    	   else if ( $operation = $CONSTANT:OP-UPDATE-MEMBER )
    		
    	   then security-plugin:after-update-member( $request-path-info , $response )
    		
    	   else if ( $operation = $CONSTANT:OP-MULTI-CREATE ) 
    		
    	   then security-plugin:after-multi-create( $request-path-info , $response )
    
           else $response

    else $response

}; 

declare function security-plugin:after-create-member(
	$request-path-info as xs:string ,
	$response as element(response)
) as element(response)
{

    let $response-data := $response/body/atom:entry
    let $entry-uri := $response-data/atom:link[@rel="edit"]/@href
    let $entry-path-info := substring-after( $entry-uri , $config:content-service-url )

    (: if security is enabled, install default resource ACL :)
    let $resource-descriptor-installed := security-plugin:install-resource-descriptor( $request-path-info , $entry-path-info )
	
    let $response-data := security-plugin:augment-entry( $request-path-info , $response-data )

    return
	
    	<response>
        {
            $response/status ,
            $response/headers
        }
            <body>{$response-data}</body>
        </response>
	
};
```

Notice that the after-create-member function has a side-effect - the default ACL is installed - and also modifies the response via the augment-entry() function - the security-descriptor links are added to the returned Atom entry document.