xquery version "1.0";

module namespace atom-protocol = "http://purl.org/atombeat/xquery/atom-protocol";

declare namespace atom = "http://www.w3.org/2005/Atom" ;
declare namespace atombeat = "http://purl.org/atombeat/xmlns" ;
 
import module namespace request = "http://exist-db.org/xquery/request" ;
import module namespace response = "http://exist-db.org/xquery/response" ;
import module namespace text = "http://exist-db.org/xquery/text" ;
import module namespace util = "http://exist-db.org/xquery/util" ;

import module namespace atombeat-util = "http://purl.org/atombeat/xquery/atombeat-util" at "java:org.atombeat.xquery.functions.util.AtomBeatUtilModule";

import module namespace CONSTANT = "http://purl.org/atombeat/xquery/constants" at "../lib/constants.xqm" ;
import module namespace xutil = "http://purl.org/atombeat/xquery/xutil" at "../lib/xutil.xqm" ;
import module namespace mime = "http://purl.org/atombeat/xquery/mime" at "../lib/mime.xqm" ;
import module namespace atomdb = "http://purl.org/atombeat/xquery/atomdb" at "../lib/atomdb.xqm" ;
import module namespace common-protocol = "http://purl.org/atombeat/xquery/common-protocol" at "../lib/common-protocol.xqm" ;

import module namespace config = "http://purl.org/atombeat/xquery/config" at "../config/shared.xqm" ;
import module namespace plugin = "http://purl.org/atombeat/xquery/plugin" at "../config/plugins.xqm" ;




(:~
 : Entry point when called as the main query. 
 :)
declare function atom-protocol:main() as item()*
{    

    let $request := common-protocol:get-request()
        
    (: process the request :)
    let $response := atom-protocol:do-service( $request )
    
    (: return a response :)
    return common-protocol:respond( $request, $response )

};




(:~
 : This is the starting point for the Atom protocol engine. 
 : 
 : @return TODO
 :)
declare function atom-protocol:do-service(
    $request as element(request)
) as element(response)
{

	if ( $request/method = $CONSTANT:METHOD-POST )

	then atom-protocol:do-post( $request )
	
	else if ( $request/method = $CONSTANT:METHOD-PUT )
	
	then atom-protocol:do-put( $request )
	
	else if ( $request/method = $CONSTANT:METHOD-GET )
	
	then atom-protocol:do-get( $request )
	
	else if ( $request/method = $CONSTANT:METHOD-DELETE )
	
	then atom-protocol:do-delete( $request )
	
	else common-protocol:do-method-not-allowed( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request , ( "GET" , "POST" , "PUT" , "DELETE" ) )

};




(:~
 : Process a POST request.
 : 
 : @param TODO
 : 
 : @return TODO
 :)
declare function atom-protocol:do-post(
	$request as element(request)
) as element(response)
{

	let $request-content-type := xutil:get-header( $CONSTANT:HEADER-CONTENT-TYPE , $request )

	return 

        if ( empty( $request-content-type ) )
        
        then common-protocol:do-bad-request( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request , "POST requests must provide a Content-Type header." )
        
		else if ( starts-with( $request-content-type, $CONSTANT:MEDIA-TYPE-ATOM ) )
		
		then atom-protocol:do-post-atom( $request , request:get-data() (: consume the request body :) )
		
		else if ( starts-with( $request-content-type, $CONSTANT:MEDIA-TYPE-MULTIPART-FORM-DATA ) )
		
		then atom-protocol:do-post-multipart-formdata( $request ) (: do not consume request entity here, allow for streaming :)
		
		else atom-protocol:do-post-media( $request ) (: do not consume request entity here, allow for streaming :)

};




(:~
 : Process a POST request where the request entity content type is  
 : application/atom+xml.
 :
 : @param TODO
 : 
 : @return TODO
 :)
declare function atom-protocol:do-post-atom(
	$request as element(request) ,
	$entity as item()* (: don't make any assumptions about the request entity yet :)
) as element(response)
{

	if ( $entity instance of element(atom:feed) )
	
	then atom-protocol:do-post-atom-feed( $request , $entity )

	else if ( $entity instance of element(atom:entry) )
	
	then atom-protocol:do-post-atom-entry( $request , $entity )
	
	else common-protocol:do-bad-request( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request , "Request entity must be well-formed XML and the root element must be either an Atom feed element or an Atom entry element." )

};




(:~
 : Process a POST request where the request entity is an Atom feed document. 
 : <p>
 : N.B. this is not a standard Atom protocol operation, but is a protocol 
 : extension. The PUT request is preferred for creating collections, but the 
 : POST form is also supported for compatibility with the native eXist Atom
 : Protocol implementation.
 : </p>
 : @param TODO
 : 
 : @return TODO
 :)
declare function atom-protocol:do-post-atom-feed(
	$request as element(request) ,
	$entity as element(atom:feed)
) as element(response)
{

	let $create := not( atomdb:collection-available( $request/path-info/text() ) )
	
	return 
	
		if ( $create ) 

		then 
			
            (: 
             : Here we bottom out at the "CREATE_COLLECTION" operation.
             :)
             
			let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-create-collection" ) , 2 )
			return common-protocol:apply-op( $CONSTANT:OP-CREATE-COLLECTION , $op , $request , $entity )
		
(:		else common-protocol:do-bad-request( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request-path-info , "A collection already exists at the given location." ) :)

        else 
        
            (:
             : EXPERIMENTAL - here we bottom out at the "MULTI_CREATE" operation
             :)
             
			let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-multi-create" ) , 2 )
			return common-protocol:apply-op( $CONSTANT:OP-MULTI-CREATE , $op , $request , $entity )
        	
};




(:~ 
 : Implementation of the CREATE_COLLECTION operation.
 : 
 : @param TODO
 : 
 : @return TODO
 :)
declare function atom-protocol:op-create-collection(
	$request as element(request) ,
	$entity as element(atom:feed) 
) as element(response)
{

    let $request-path-info := $request/path-info/text() 
    
    let $create-collection := atomdb:create-collection( $request-path-info , $entity , $request/user/text() )
	
	return 
	
	    if ( exists( $create-collection ) )
	    
	    then

        	let $feed := atomdb:retrieve-feed( $request-path-info )
                    
            let $location := $feed/atom:link[@rel='self']/@href cast as xs:string
                	
        	return
        	
        	    <response>
        	        <status>{$CONSTANT:STATUS-SUCCESS-CREATED}</status>
        	        <headers>
        	            <header>
        	                <name>{$CONSTANT:HEADER-CONTENT-TYPE}</name>
        	                <value>{$CONSTANT:MEDIA-TYPE-ATOM-FEED}</value>
        	            </header>
        	            <header>
        	                <name>{$CONSTANT:HEADER-LOCATION}</name>
        	                <value>{$location}</value>
        	            </header>
        	            <header>
        	                <name>{$CONSTANT:HEADER-CONTENT-LOCATION}</name>
        	                <value>{$location}</value>
        	            </header>
        	        </headers>
        	        <body type='xml'>{$feed}</body>
        	    </response>

        else common-protocol:do-internal-server-error( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request , "Failed to create collection." )

};




(:~ 
 : EXPERIMENTAL - Implementation of the MULTI_CREATE operation.
 : 
 : @param TODO
 : 
 : @return TODO
 :)
declare function atom-protocol:op-multi-create(
	$request as element(request) ,
	$entity as element(atom:feed) 
) as element(response)
{

    (:
     : Iterate through the entries in the supplied feed, creating a member for
     : each.
     :)

    let $collection-path-info := $request/path-info/text()
    let $user-name := $request/user/text()

    let $feed :=

        <atom:feed>
        {
            for $entry in $entity/atom:entry
            let $media-path-info := substring-after($entry/atom:link[@rel='edit-media']/@href/string(), $config:edit-media-link-uri-base)
            let $local-media-available := ( 
                exists( $media-path-info ) 
                and atomdb:media-resource-available( $media-path-info )
            )
            return 
                if ( $local-media-available )
                then
                    (: media is local, attempt to copy :)
                    let $media-type := $entry/atom:link[@rel='edit-media']/@type
                	let $media-link :=
                	    if ( $config:media-storage-mode = "DB" ) then
                	        let $media := atomdb:retrieve-media( $media-path-info )
                	        return atomdb:create-media-resource( $collection-path-info , $media , $media-type , $user-name ) 
                        else if ( $config:media-storage-mode = "FILE" ) then        
                	        atomdb:create-file-backed-media-resource-from-existing-media-resource( $collection-path-info , $media-type , $media-path-info , $user-name )
                	    else ()
                    let $media-link-path-info := substring-after($media-link/atom:link[@rel='edit']/@href/string(), $config:edit-link-uri-base)
                    let $media-link := atomdb:update-member( $media-link-path-info , $entry )
                    return $media-link
                else atomdb:create-member( $collection-path-info , $entry , $user-name )
        }
        </atom:feed>
        

	return
	
	    <response>
	        <status>{$CONSTANT:STATUS-SUCCESS-OK}</status>
	        <headers>
	            <header>
	                <name>{$CONSTANT:HEADER-CONTENT-TYPE}</name>
	                <value>{$CONSTANT:MEDIA-TYPE-ATOM-FEED}</value>
	            </header>
	        </headers>
	        <body type='xml'>{$feed}</body>
	    </response>

};





(:~
 : Process a POST request where the request entity in an Atom entry document.
 :
 : @param TODO
 :
 : @return TODO
 :)
declare function atom-protocol:do-post-atom-entry(
	$request as element(request),
	$entity as element(atom:entry)
) as element(response)
{

	(: 
	 : First we need to know whether an atom collection exists at the 
	 : request path.
	 :)
	 
	let $collection-available := atomdb:collection-available( $request/path-info/text() )
	
	return 
	
		if ( not( $collection-available ) ) 

		then common-protocol:do-not-found( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request )
		
		else
		
            (: 
             : Here we bottom out at the "CREATE_MEMBER" operation.
             :)
             
			let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-create-member" ) , 2 )
			
            return common-protocol:apply-op( $CONSTANT:OP-CREATE-MEMBER , $op , $request , $entity )
        
};




(:~ 
 : Implementation of the CREATE_MEMBER operation.
 : 
 : @param TODO
 : 
 : @return TODO
 :)
declare function atom-protocol:op-create-member(
	$request as element(request) ,
	$entity as element(atom:entry) 
) as element(response)
{

    let $log := util:log("debug", "atom-protocol:op-create-member")
    let $collection-path-info := $request/path-info/text()
    let $log := util:log("debug", $collection-path-info)
    let $user-name := $request/user/text()
    let $log := util:log("debug", $user-name)
    let $slug := xutil:get-header( "Slug" , $request )
    let $log := util:log("debug", $slug)

    (: create the member :)
	let $entry := atomdb:create-member( $collection-path-info , $slug , $entity , $user-name )
    let $log := util:log("debug", $entry)

    (: set the location and content-location headers :)
    let $location := $entry/atom:link[@rel="edit"]/@href/string()
    let $log := util:log("debug", $location)

	(: set the etag header :)
    let $entry-path-info := substring-after($entry/atom:link[@rel='edit']/@href/string(), $config:edit-link-uri-base)
    let $log := util:log("debug", 'entry-path-info...')
    let $log := util:log("debug", $entry-path-info)
    let $etag := concat( '"' , atomdb:generate-etag( $entry-path-info ) , '"' )
    let $log := util:log("debug", $etag)
        
    (: update the feed date updated :)    
    let $feed-date-updated := atomdb:touch-collection( $collection-path-info )
    			
	return
	
	    <response>
	        <status>{$CONSTANT:STATUS-SUCCESS-CREATED}</status>
	        <headers>
	            <header>
	                <name>{$CONSTANT:HEADER-CONTENT-TYPE}</name>
	                <value>{$CONSTANT:MEDIA-TYPE-ATOM-ENTRY}</value>
	            </header>
	            <header>
	                <name>{$CONSTANT:HEADER-LOCATION}</name>
	                <value>{$location}</value>
	            </header>
	            <header>
	                <name>{$CONSTANT:HEADER-CONTENT-LOCATION}</name>
	                <value>{$location}</value>
	            </header>
                <header>
                    <name>{$CONSTANT:HEADER-ETAG}</name>
                    <value>{$etag}</value>
                </header>
	        </headers>
	        <body type='xml'>{$entry}</body>
	    </response>
};




(:~
 : Process a POST request where the request content type is not 
 : application/atom+xml.
 : 
 : @param TODO
 :
 : @return TODO
 :)
declare function atom-protocol:do-post-media(
	$request as element(request) 
) as element(response)
{

	(: 
	 : First we need to know whether an atom collection exists at the 
	 : request path.
	 :)
	
	let $collection-path-info := $request/path-info/text()
	let $collection-available := atomdb:collection-available( $collection-path-info )
	
	return 
	
		if ( not( $collection-available ) ) 

		then common-protocol:do-not-found( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request )
		
		else
		
            (: 
             : Here we bottom out at the "CREATE_MEDIA" operation.
             :)
             
        	let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-create-media" ) , 2 )
	
	        (: don't consume request data because we may want to stream media to a file :)
            return common-protocol:apply-op( $CONSTANT:OP-CREATE-MEDIA , $op , $request , () )
                        			
};





(:~
 : Implementation of the CREATE_MEDIA operation.
 :
 : @param TODO
 : 
 : @return TODO
 :)
declare function atom-protocol:op-create-media(
	$request as element(request) ,
	$entity as item()* (: expect this to be empty, but have to include to get consistent function signature :)
) as element(response)
{

    let $request-path-info := $request/path-info/text()
    let $user-name := $request/user/text()
	let $request-content-type := xutil:get-header( $CONSTANT:HEADER-CONTENT-TYPE , $request )
	let $request-media-type := tokenize( $request-content-type , ';' )[1]

    (: check for slug to use as title :)
	let $slug := xutil:get-header( $CONSTANT:HEADER-SLUG , $request )
	
	(: check for summary :) 
	let $summary := xutil:get-header( "X-Atom-Summary" , $request )
	
	(: check for category :) 
	let $category := xutil:get-header( "X-Atom-Category" , $request )
	
	(: create the media resource :)
	let $media-link :=
	    if ( $config:media-storage-mode = "DB" ) then
	        atomdb:create-media-resource( $request-path-info , request:get-data() , $request-media-type , $user-name , $slug , $summary , $category ) 
        else if ( $config:media-storage-mode = "FILE" ) then        
	        atomdb:create-file-backed-media-resource-from-request-data( $request-path-info , $request-media-type , $user-name , $slug , $summary , $category )
	    else ()
	    
    (: TODO handle case where $media-link is empty? :)    
	
	(: set location and content-location headers :)
    let $location := $media-link/atom:link[@rel="edit"]/@href cast as xs:string

    (: update date feed updated :)
    let $feed-date-updated := atomdb:touch-collection( $request-path-info )
        
	return
	
	    <response>
	        <status>{$CONSTANT:STATUS-SUCCESS-CREATED}</status>
	        <headers>
	            <header>
	                <name>{$CONSTANT:HEADER-CONTENT-TYPE}</name>
	                <value>{$CONSTANT:MEDIA-TYPE-ATOM-ENTRY}</value>
	            </header>
	            <header>
	                <name>{$CONSTANT:HEADER-LOCATION}</name>
	                <value>{$location}</value>
	            </header>
	            <header>
	                <name>{$CONSTANT:HEADER-CONTENT-LOCATION}</name>
	                <value>{$location}</value>
	            </header>
	        </headers>
	        <body type='xml'>{$media-link}</body>
	    </response>

};




(:~
 : Process a POST request where the content-type is multipart/form-data. N.B. 
 : this is not a standard Atom protocol operation but is a protocol extension
 : included to enable POSTing of media resources directly from HTML forms.
 :
 : @param TODO
 : @return TODO
 :)
declare function atom-protocol:do-post-multipart-formdata(
	$request as element(request) 
) as element(response)
{

	(: 
	 : First we need to know whether an atom collection exists at the 
	 : request path.
	 :)
	
    let $request-path-info := $request/path-info/text()
	let $collection-available := atomdb:collection-available( $request-path-info )
	
	return 
	
		if ( not( $collection-available ) ) 

		then common-protocol:do-not-found( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request )
		
		else

			(: check for file name to use as title :)
			
			let $file-name := request:get-uploaded-file-name( "media" )
			
			return
			
			    if ( empty( $file-name ) )
			    
			    then common-protocol:do-bad-request( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request , "Requests with content type 'multipart/form-data' must have a 'media' part." )
			    
			    else
			
                    (: 
                     : Here we bottom out at the "CREATE_MEDIA" operation. However, we
                     : will use a special implementation to support return of HTML
                     : response to requests from HTML forms for compatibility with forms
                     : submitted via JavaScript.
                     :)
                     
                    let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-create-media-from-multipart-form-data" ) , 2 ) 
                    return common-protocol:apply-op( $CONSTANT:OP-CREATE-MEDIA , $op , $request , () )

};





(:~
 : Special implementation of the CREATE_MEDIA operation for multipart/form-data 
 : requests. N.B., this function CAN NOT be used via an XQuery call from another
 : XQuery as it must interact directly with the context HTTP request.
 : 
 : @param TODO
 :
 : @return TODO
 :)
declare function atom-protocol:op-create-media-from-multipart-form-data (
	$request as element(request) ,
	$entity as item()* (: expect this to be empty, but have to include to get consistent function signature :)
) as element(response)
{

    (: TODO bad request if expected form parts are missing :)

    let $request-path-info := $request/path-info/text()
    let $user-name := $request/user/text()

    (: check for file name to use as title :)
	let $file-name := request:get-uploaded-file-name( "media" )

    (:
     : Unfortunately eXist's function library doesn't give us any way
     : to retrieve the content type for the uploaded file, so we'll
     : work around by using a mapping from file name extensions to
     : mime types.
     :)
     
    let $extension := text:groups( $file-name , "\.([^.]+)$" )[2]
     
    let $media-type := $mime:mappings//mime-mapping[extension=$extension]/mime-type
    
    let $media-type := if ( empty( $media-type ) ) then "application/octet-stream" else $media-type
    
    (: check for title param :)
    let $title-param := xutil:get-parameter( "title" , $request )
    let $title := if ( exists( $title-param ) ) then $title-param else $file-name

	(: check for summary param :)
	let $summary := xutil:get-parameter( "summary" , $request )
	
	(: check for category param :)
	let $category := xutil:get-parameter( "category" , $request )
 
    (: one of the few occasions where we are forced to interact directly with the context HTTP request :)
    let $media-link :=
	    if ( $config:media-storage-mode = "DB" ) then
	        let $entity := request:get-uploaded-file-data( "media" ) 
	        return atomdb:create-media-resource( $request-path-info , $entity , $media-type , $user-name , $title , $summary , $category ) 
        else if ( $config:media-storage-mode = "FILE" ) then        
	        atomdb:create-file-backed-media-resource-from-upload( $request-path-info , $media-type , $user-name , $title , $summary , $category )
	    else ()
	    
    let $feed-date-updated := atomdb:touch-collection( $request-path-info )
        
    let $location := $media-link/atom:link[@rel="edit"]/@href cast as xs:string

	return
	
	    <response>
	        <status>{$CONSTANT:STATUS-SUCCESS-CREATED}</status>
	        <headers>
	            <header>
	                <name>{$CONSTANT:HEADER-CONTENT-TYPE}</name>
	                <value>{$CONSTANT:MEDIA-TYPE-ATOM-ENTRY}</value>
	            </header>
	            <header>
	                <name>{$CONSTANT:HEADER-LOCATION}</name>
	                <value>{$location}</value>
	            </header>
	            <header>
	                <name>{$CONSTANT:HEADER-CONTENT-LOCATION}</name>
	                <value>{$location}</value>
                </header>
	        </headers>
	        <body type='xml'>{$media-link}</body>
	    </response>

};





(:~
 : Process a PUT request.
 : 
 : @param TODO
 : 
 : @return TODO
 :)
declare function atom-protocol:do-put (
	$request as element(request) 
) as element(response)
{

	let $request-content-type := xutil:get-header( $CONSTANT:HEADER-CONTENT-TYPE , $request )

	return 

		if ( starts-with( $request-content-type, $CONSTANT:MEDIA-TYPE-ATOM ) )
		
		then atom-protocol:do-put-atom( $request , request:get-data() ) (: consume request entity :)

		else atom-protocol:do-put-media( $request )

};




(:~
 : Process a PUT request where the media type of the request entity is 
 : application/atom+xml.
 : 
 : @param TODO
 : 
 : @return TODO
 :)
declare function atom-protocol:do-put-atom(
	$request as element(request) ,
	$entity as item()* (: don't make any assumptions about the request entity yet :) 
) as element(response)
{

    if ( atomdb:media-resource-available( $request/path-info/text() ) ) then
    
        common-protocol:do-unsupported-media-type( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request, "You cannot PUT content with mediatype application/atom+xml to a media resource URI." )
    
    else if ( $entity instance of element(atom:feed) ) then
    
        atom-protocol:do-put-atom-feed( $request , $entity )

    else if ( $entity instance of element(atom:entry) ) then
    
        atom-protocol:do-put-atom-entry( $request , $entity )
    
    else common-protocol:do-bad-request( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request , "Request entity must be well-formed XML and the root element must be either an Atom feed element or an Atom entry element." )

};




(:~
 : Process a PUT request where the request entity is an Atom feed document. N.B.
 : this is not a standard Atom protocol operation, but is a protocol extension
 : to provide a means for creating new collections. The interpretation of the 
 : request will depend on whether a collection already exists at the given
 : location. If it does, the feed metadata will be updated using the request
 : data. If it does not, a new Atom collection will be created at that location.
 : 
 : @param TODO
 :
 : @return TODO
 :)
declare function atom-protocol:do-put-atom-feed(
	$request as element(request) ,
	$entity as element(atom:feed)
) as element(response)
{

    (:
     : Check for bad request.
     :)
    
    if ( atomdb:member-available( $request/path-info/text() ) )
    then common-protocol:do-bad-request( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request , "You cannot PUT an atom:feed to a member URI." )
    
    else
	
    	(: 
    	 : We need to know whether an atom collection already exists at the 
    	 : request path, in which case the request will update the feed metadata,
    	 : or whether no atom collection exists at the request path, in which case
    	 : the request will create a new atom collection and initialise the atom
    	 : feed document with the given feed metadata.
    	 :)
    	
    	let $request-path-info := $request/path-info/text()
    	let $create := not( atomdb:collection-available( $request-path-info ) )
    
    	return
    	
    		if ( $create ) then atom-protocol:do-put-atom-feed-to-create-collection( $request , $entity )
    		else atom-protocol:do-put-atom-feed-to-update-collection( $request , $entity )	

};




(:~
 : Process a PUT request where the request entity is an Atom feed document and
 : no collection exists at the given location.
 : 
 : @param TODO
 :
 : @return TODO
 :)
declare function atom-protocol:do-put-atom-feed-to-create-collection(
	$request as element(request) ,
	$entity as element(atom:feed)
) as element(response)
{

    (: 
     : Here we bottom out at the "CREATE_COLLECTION" operation.
     :)
     
	let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-create-collection" ) , 2 )
    return common-protocol:apply-op( $CONSTANT:OP-CREATE-COLLECTION , $op , $request , $entity )
        		
};




(:~
 : Process a PUT request where the request entity is an Atom feed document and
 : an Atom collection already exists at the given location.
 : 
 : @param TODO
 :
 : @return TODO
 :)
declare function atom-protocol:do-put-atom-feed-to-update-collection(
	$request as element(request) ,
	$entity as element(atom:feed)
) as element(response)
{

    (: 
     : Here we bottom out at the "UPDATE_COLLECTION" operation.
     :)

	let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-update-collection" ) , 2 )
    return common-protocol:apply-op( $CONSTANT:OP-UPDATE-COLLECTION , $op , $request , $entity )

};




(:~ 
 : Implementation of the UPDATE_COLLECTION operation.
 :
 : @param TODO
 :
 : @return TODO
 :)
declare function atom-protocol:op-update-collection(
	$request as element(request) ,
	$entity as element(atom:feed)
) as element(response)
{

	let $feed := atomdb:update-collection( $request/path-info/text() , $entity )
		
    return 
    
        <response>
            <status>{$CONSTANT:STATUS-SUCCESS-OK}</status>
            <headers>
                <header>
                    <name>{$CONSTANT:HEADER-CONTENT-TYPE}</name>
                    <value>{$CONSTANT:MEDIA-TYPE-ATOM-FEED}</value>
                </header>
            </headers>
            <body type='xml'>{$feed}</body>
        </response>
};





(:
 : TODO doc me
 :)
declare function atom-protocol:do-put-atom-entry(
	$request as element(request) ,
	$entity as element(atom:entry)
) as element(response)
{

    let $request-path-info := $request/path-info/text()
    
    return
    
    	(:
    	 : Check for bad request.
    	 :)
    	 
     	 if ( atomdb:collection-available( $request-path-info ) )
     	 then common-protocol:do-bad-request( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request , "You cannot PUT an atom:entry to a collection URI." )
     	 
     	 else
     	  
    		(: 
    		 : First we need to know whether an atom entry exists at the 
    		 : request path.
    		 :)
    		 
    		let $member-available := atomdb:member-available( $request-path-info )
    		
    		return 
    		
    			if ( not( $member-available ) ) 
    	
    			then common-protocol:do-not-found( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request )
    			
    			else
    			
    			    let $header-if-match := xutil:get-header( "If-Match" , $request )
    			    
    			    return 
    			    
    			         if ( exists( $header-if-match ) )
    			         
    			         then atom-protocol:do-conditional-put-atom-entry( $request , $entity )
    			         
    			         else
            			     
            			    (: 
            			     : Here we bottom out at the "update-member" operation.
            			     :)
            	            let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-update-member" ) , 2 )
            	            return common-protocol:apply-op( $CONSTANT:OP-UPDATE-MEMBER , $op , $request , $entity ) 
            
};




(:
 : TODO doc me
 :)
declare function atom-protocol:do-conditional-put-atom-entry(
	$request as element(request) ,
	$entity as element(atom:entry)
) as element(response)
{

    let $request-path-info := $request/path-info/text()
    let $header-if-match := xutil:get-header( "If-Match" , $request )
    let $match-etags := tokenize( $header-if-match , "\s*,\s*" )
    let $etag := atomdb:generate-etag( $request-path-info ) 
    
    let $matches := xutil:match-etag( $header-if-match , $etag )

    return
    
        if ( exists( $matches ) )
        then

            (: 
             : Here we bottom out at the "update-member" operation.
             :)
            let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-update-member" ) , 2 )
            return common-protocol:apply-op( $CONSTANT:OP-UPDATE-MEMBER , $op , $request , $entity ) 
        
        else common-protocol:do-precondition-failed( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request , "The entity tag does not match." )
        
};


(:
 : TODO doc me
 :)
declare function atom-protocol:op-update-member(
	$request as element(request) ,
	$entity as element(atom:entry)
) as element(response)
{
    
    let $request-path-info := $request/path-info/text()
	let $entry := atomdb:update-member( $request-path-info , $entity )
    let $etag := concat( '"' , atomdb:generate-etag( $request-path-info ) , '"' )
    let $collection-path-info := let $entry-path-info := substring-after($entry/atom:link[@rel='edit']/@href/string(), $config:edit-link-uri-base) return text:groups($entry-path-info, "^(.+)/[^/]+$")[2]
    let $feed-date-updated := atomdb:touch-collection( $collection-path-info )
    
	return
	
	    <response>
	        <status>{$CONSTANT:STATUS-SUCCESS-OK}</status>
	        <headers>
	            <header>
	                <name>{$CONSTANT:HEADER-CONTENT-TYPE}</name>
	                <value>{$CONSTANT:MEDIA-TYPE-ATOM-ENTRY}</value>
	            </header>
                <header>
                    <name>{$CONSTANT:HEADER-ETAG}</name>
                    <value>{$etag}</value>
                </header>
	        </headers>
	        <body type='xml'>{$entry}</body>
	    </response>

};




(: 
 : TODO doc me
 :)
declare function atom-protocol:do-put-media(
	$request as element(request)
) as element(response)
{

    let $request-path-info := $request/path-info/text()
	
	return
	
     	if ( atomdb:collection-available( $request-path-info ) ) then

            common-protocol:do-unsupported-media-type( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request , "You cannot PUT media content to a collection URI." )
     	 
     	else if ( atomdb:member-available( $request-path-info ) ) then

            common-protocol:do-unsupported-media-type( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request, "You cannot PUT media content to a member URI." )
     	 
     	else if ( not( atomdb:media-resource-available( $request-path-info ) ) ) then
    		
    	    common-protocol:do-not-found( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request )
    			
    	else
    	
    		(: here we bottom out at the UPDATE_MEDIA operation :)
    		
    		let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-update-media" ) , 2 )
    		
    		return common-protocol:apply-op( $CONSTANT:OP-UPDATE-MEDIA , $op , $request , () ) (: don't consume request data, to allow for streaming :)
				
};




declare function atom-protocol:op-update-media(
	$request as element(request) ,
	$entity as item()* (: expect this to be empty, but have to include to get consistent function signature :)
) as element(response)
{
	
    let $request-path-info := $request/path-info/text()
	let $request-content-type := xutil:get-header( $CONSTANT:HEADER-CONTENT-TYPE , $request )
	let $request-media-type := tokenize( $request-content-type , ';' )[1]

	let $media-link :=
	    if ( $config:media-storage-mode = "DB" ) then
	        atomdb:update-media-resource( $request-path-info , request:get-data() , $request-media-type ) 
        else if ( $config:media-storage-mode = "FILE" ) then        
	        atomdb:update-file-backed-media-resource( $request-path-info , $request-media-type )
	    else ()

    let $collection-path-info := let $entry-path-info := substring-after($media-link/atom:link[@rel='edit']/@href/string(), $config:edit-link-uri-base) return text:groups($entry-path-info, "^(.+)/[^/]+$")[2]
    
    let $feed-date-updated := atomdb:touch-collection( $collection-path-info )
    
    (: return the media-link entry :)
    
	return
	
	    <response>
	        <status>{$CONSTANT:STATUS-SUCCESS-OK}</status>
	        <headers>
	            <header>
	                <name>{$CONSTANT:HEADER-CONTENT-TYPE}</name>
	                <value>{$CONSTANT:MEDIA-TYPE-ATOM-ENTRY}</value>
	            </header>
	            <header>
	                <name>{$CONSTANT:HEADER-CONTENT-LOCATION}</name>
	                <value>{$media-link/atom:link[@rel='edit']/@href cast as xs:string}</value>
	            </header>
	        </headers>
	        <body type='xml'>{$media-link}</body>
	    </response>
	    
};




(: 
 : TODO doc me 
 :)
declare function atom-protocol:do-get(
	$request as element(request)
) as element(response)
{

    let $request-path-info := $request/path-info/text() 

    return
    
    	if ( atomdb:media-resource-available( $request-path-info ) )
    	
    	then atom-protocol:do-get-media-resource( $request )
    	
    	else if ( atomdb:member-available( $request-path-info ) )
    	
    	then atom-protocol:do-get-member( $request )
    	
    	else if ( atomdb:collection-available( $request-path-info ) )
    	
    	then atom-protocol:do-get-collection( $request )
    
    	else common-protocol:do-not-found( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request )
	
};




(:
 : TODO doc me
 :)
declare function atom-protocol:do-get-member(
	$request as element(request)
) as element(response)
{
    
    (: additional check here in case function is called directly from an external XQuery :)
    
    if ( not( atomdb:member-available( $request/path-info/text() ) ) ) then
    
        common-protocol:do-not-found( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request )
        
    else

        let $header-if-none-match := xutil:get-header( "If-None-Match" , $request )
        
        return 
        
            if ( exists( $header-if-none-match ) )
            
            then atom-protocol:do-conditional-get-member( $request )
            
            else
    
                (: 
                 : Here we bottom out at the "retrieve-member" operation.
                 :)
            
            	let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-retrieve-member" ) , 2 )
            	
                return common-protocol:apply-op( $CONSTANT:OP-RETRIEVE-MEMBER , $op , $request , () )
    
};



(:
 : TODO doc me
 :)
declare function atom-protocol:do-conditional-get-member(
	$request as element(request)
) as element(response)
{
    
    let $request-path-info := $request/path-info/text() 

    (: TODO is this a security risk? i.e., could someone probe for changes to a 
     : resource even if they don't have permission to retrieve it? If so, should
     : the conditional processing be pushed into the main operation? :)
     
    let $header-if-none-match := xutil:get-header( "If-None-Match" , $request )
    
    let $etag := atomdb:generate-etag( $request-path-info ) 
   
    let $matches := xutil:match-etag( $header-if-none-match , $etag )
        
    return
    
        if ( exists( $matches ) )
        
        then common-protocol:do-not-modified( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request )
        
        else
        
            (: 
             : Here we bottom out at the "retrieve-member" operation.
             :)
        
            let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-retrieve-member" ) , 2 )
            
            return common-protocol:apply-op( $CONSTANT:OP-RETRIEVE-MEMBER , $op , $request , () )

};



(:
 : TODO doc me
 :)
declare function atom-protocol:op-retrieve-member(
	$request as element(request) ,
	$entity as item()* (: expect this to be empty, but have to include to get consistent function signature :)
) as element(response)
{

    let $request-path-info := $request/path-info/text()
	let $entry := atomdb:retrieve-member( $request-path-info )
    let $etag := concat( '"' , atomdb:generate-etag( $request-path-info ) , '"' )
    let $location := $entry/atom:link[@rel='edit']/@href cast as xs:string
    
	return

	    <response>
	        <status>{$CONSTANT:STATUS-SUCCESS-OK}</status>
	        <headers>
	            <header>
	                <name>{$CONSTANT:HEADER-CONTENT-TYPE}</name>
	                <value>{$CONSTANT:MEDIA-TYPE-ATOM-ENTRY}</value>
	            </header>
                <header>
                    <name>{$CONSTANT:HEADER-ETAG}</name>
                    <value>{$etag}</value>
                </header>
                <header>
                    <name>{$CONSTANT:HEADER-CONTENT-LOCATION}</name>
                    <value>{$location}</value>
                </header>
	        </headers>
	        <body type='xml'>{$entry}</body>
	    </response>

};





(:
 : TODO doc me
 :)
declare function atom-protocol:do-get-media-resource(
	$request as element(request) 
) as element(response)
{

	let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-retrieve-media" ) , 2 )
	
    return common-protocol:apply-op( $CONSTANT:OP-RETRIEVE-MEDIA , $op , $request , () )

};




declare function atom-protocol:op-retrieve-media(
	$request as element(request) ,
	$entity as item()* (: expect this to be empty, but have to include to get consistent function signature :)
) as element(response)
{

    let $request-path-info := $request/path-info/text()
    (: media type :)
    let $mime-type := atomdb:get-mime-type( $request-path-info )
    (: title as filename :)
    let $media-link := atomdb:get-media-link( $request-path-info )
    let $title := $media-link/atom:title
    let $content-disposition-header :=
        if ( $title ) then 
            <header>
                <name>{$CONSTANT:HEADER-CONTENT-DISPOSITION}</name>
                <value>{concat( 'attachment; filename="' , $title , '"' )}</value>
            </header>
    	else ()
    
	return 

	    <response>
	        <status>{$CONSTANT:STATUS-SUCCESS-OK}</status>
	        <headers>
	            <header>
	                <name>{$CONSTANT:HEADER-CONTENT-TYPE}</name>
	                <value>{$mime-type}</value>
	            </header>
            {
                $content-disposition-header
            }
	        </headers>
	        <body type="media">{$request-path-info}</body>
	    </response>
	    
};





declare function atom-protocol:do-get-collection(
	$request as element(request)
) as element(response)
{

    (: additional check here in case function is called directly from an external XQuery :)
    
    if ( not( atomdb:collection-available( $request/path-info/text() ) ) ) then
    
        common-protocol:do-not-found( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request )
        
    else

        (: 
         : Here we bottom out at the LIST_COLLECTION operation.
         :)
    
    	let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-list-collection" ) , 2 )
    	
        return common-protocol:apply-op( $CONSTANT:OP-LIST-COLLECTION , $op , $request , () )
    
};


 

declare function atom-protocol:op-list-collection(
	$request as element(request) ,
	$entity as item()* (: expect this to be empty, but have to include to get consistent function signature :)
) as element(reponse)
{

    let $request-path-info := $request/path-info/text()
    let $feed := atomdb:retrieve-feed( $request-path-info ) 
    let $location := $feed/atom:link[@rel='self']/@href cast as xs:string
    
	return

	    <response>
	        <status>{$CONSTANT:STATUS-SUCCESS-OK}</status>
	        <headers>
	            <header>
	                <name>{$CONSTANT:HEADER-CONTENT-TYPE}</name>
	                <value>{$CONSTANT:MEDIA-TYPE-ATOM-FEED}</value>
	            </header>
	            <header>
	                <name>{$CONSTANT:HEADER-CONTENT-LOCATION}</name>
	                <value>{$location}</value>
	            </header>
	        </headers>
	        <body type='xml'>{$feed}</body>
	    </response>

};





declare function atom-protocol:do-delete(
	$request as element(request)
) as element(response)
{
	
    let $request-path-info := $request/path-info/text()
    
    return
    
        (: 
    	 : We first need to know whether we are deleting a collection, a collection
    	 : member entry, a media-link entry, or a media resource.
    	 :)
    	 
    	if ( atomdb:collection-available( $request-path-info ) )
    	then atom-protocol:do-delete-collection( $request )
    	
    	else if ( atomdb:member-available( $request-path-info ) )
    	then atom-protocol:do-delete-member( $request )
    	
    	else if ( atomdb:media-resource-available( $request-path-info ) )
    	then atom-protocol:do-delete-media( $request )
    	
    	else common-protocol:do-not-found( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request )
	
};




declare function atom-protocol:do-delete-collection(
	$request as element(request)
) as element(response)
{

    (: for now, do not support this operation :)
    common-protocol:do-method-not-allowed( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request , ( "GET" , "POST" , "PUT" ) )
    
};




declare function atom-protocol:do-delete-member(
	$request as element(request)
) as element(response)
{

    let $request-path-info := $request/path-info/text()
    
    return
    
        (: 
         : This is a little bit tricky...
         :
         : We need to know if this is a simple atom entry, or if this a media-link
         : entry. If it is a simple atom entry, then do the obvious, which is to
         : bottom out at the "delete-member" operation. However, if it is a media-link
         : entry, we will treat this as a "delete-media" operation, because the
         : delete on the media-link also causes a delete on the associated media
         : resource.
         :)
         
        if ( atomdb:media-link-available( $request-path-info ) ) then
        
        	let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-delete-media" ) , 2 )
        	return common-protocol:apply-op( $CONSTANT:OP-DELETE-MEDIA , $op, $request, () )
        
        else if ( atomdb:member-available( $request-path-info ) ) then

            let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-delete-member" ) , 2 )
        	return common-protocol:apply-op( $CONSTANT:OP-DELETE-MEMBER , $op , $request , () )
        	
        else
        
            (: additional check here in case function is called directly from an external XQuery :)
            common-protocol:do-not-found( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request )
			
};





(:
 : TODO doc me 
 :)
declare function atom-protocol:op-delete-member(
	$request as element(request) ,
	$entity as item()* (: expect this to be empty, but have to include to get consistent function signature :)
) as element(response)
{

    let $request-path-info := $request/path-info/text()
    let $member-deleted := atomdb:delete-member( $request-path-info ) 
    let $collection-path-info := text:groups( $request-path-info , "^(.*)/[^/]+$" )[2]
    let $feed-date-updated := atomdb:touch-collection( $collection-path-info )
    
	return

	    <response>
	        <status>{$CONSTANT:STATUS-SUCCESS-NO-CONTENT}</status>
	        <headers/>
	        <body/>
	    </response>

};




(:
 : TODO doc me 
 :)
declare function atom-protocol:do-delete-media(
	$request as element(request)
) as element(response)
{

    (: additional check here in case function is called directly from an external XQuery :)
    
    if ( not( atomdb:media-resource-available( $request/path-info/text() ) ) ) then
    
        common-protocol:do-not-found( $CONSTANT:OP-ATOM-PROTOCOL-ERROR , $request )
        
    else

        (: here we bottom out at the "delete-media" operation :)
        
    	let $op := util:function( QName( "http://purl.org/atombeat/xquery/atom-protocol" , "atom-protocol:op-delete-media" ) , 2 )
    	
    	return common-protocol:apply-op( $CONSTANT:OP-DELETE-MEDIA , $op , $request , () )

};




(:
 : TODO doc me 
 :)
declare function atom-protocol:op-delete-media(
	$request as element(request) ,
	$entity as item()* (: expect this to be empty, but have to include to get consistent function signature :)
) as element(response)
{

    let $request-path-info := $request/path-info/text()
    let $media-deleted := atomdb:delete-media( $request-path-info ) 
    let $collection-path-info := text:groups( $request-path-info , "^(.*)/[^/]+$" )[2]
    let $feed-date-updated := atomdb:touch-collection( $collection-path-info )
    
	return

	    <response>
	        <status>{$CONSTANT:STATUS-SUCCESS-NO-CONTENT}</status>
	        <headers/>
	        <body/>
	    </response>
};




 

