xquery version "1.0";

(:~
 : This module exists to work around the limitation on circular imports.
 : It allows plugin functions to call functions from various protocol modules
 : without creating an import cycle.
 :)
 
module namespace plugin-util = "http://purl.org/atombeat/xquery/plugin-util";

declare namespace atom = "http://www.w3.org/2005/Atom" ;

declare function plugin-util:atom-protocol-do-get(
    $request as element(request)
) as element(response)
{
    let $query := concat( 
        "import module namespace atom-protocol = 'http://purl.org/atombeat/xquery/atom-protocol' at '../lib/atom-protocol.xqm' ; " ,
        "import module namespace config = 'http://purl.org/atombeat/xquery/config' at '../config/shared.xqm' ; " ,
        "let $login := xmldb:login( '/' , $config:exist-user , $config:exist-password ) " ,
        "return atom-protocol:do-get($request)"
    )
    return util:eval( $query , false() )
};

declare function plugin-util:atom-protocol-do-get-member(
    $request as element(request)
) as element(response)
{
    let $query := concat( 
        "import module namespace atom-protocol = 'http://purl.org/atombeat/xquery/atom-protocol' at '../lib/atom-protocol.xqm' ; " ,
        "import module namespace config = 'http://purl.org/atombeat/xquery/config' at '../config/shared.xqm' ; " ,
        "let $login := xmldb:login( '/' , $config:exist-user , $config:exist-password ) " ,
        "return atom-protocol:do-get-member($request)"
    )
    return util:eval( $query , false() )
};

declare function plugin-util:atom-protocol-do-get-collection(
    $request as element(request)
) as element(response)
{
    let $query := concat( 
        "import module namespace atom-protocol = 'http://purl.org/atombeat/xquery/atom-protocol' at '../lib/atom-protocol.xqm' ; " ,
        "import module namespace config = 'http://purl.org/atombeat/xquery/config' at '../config/shared.xqm' ; " ,
        "let $login := xmldb:login( '/' , $config:exist-user , $config:exist-password ) " ,
        "return atom-protocol:do-get-collection($request)"
    )
    return util:eval( $query , false() )
};

declare function plugin-util:atom-protocol-do-post-atom(
    $request as element(request) ,
    $entity as item()*
) as element(response)
{
    let $query := concat( 
        "import module namespace atom-protocol = 'http://purl.org/atombeat/xquery/atom-protocol' at '../lib/atom-protocol.xqm' ; " ,
        "import module namespace config = 'http://purl.org/atombeat/xquery/config' at '../config/shared.xqm' ; " ,
        "let $login := xmldb:login( '/' , $config:exist-user , $config:exist-password ) " ,
        "return atom-protocol:do-post-atom($request, $entity)"
    )
    return util:eval( $query , false() )
};

declare function plugin-util:atom-protocol-do-post-atom-entry(
    $request as element(request) ,
    $entity as element(atom:entry)
) as element(response)
{
    let $query := concat( 
        "import module namespace atom-protocol = 'http://purl.org/atombeat/xquery/atom-protocol' at '../lib/atom-protocol.xqm' ; " ,
        "import module namespace config = 'http://purl.org/atombeat/xquery/config' at '../config/shared.xqm' ; " ,
        "let $login := xmldb:login( '/' , $config:exist-user , $config:exist-password ) " ,
        "return atom-protocol:do-post-atom-entry($request, $entity)"
    )
    return util:eval( $query , false() )
};

declare function plugin-util:atom-protocol-do-post-atom-feed(
    $request as element(request) ,
    $entity as element(atom:feed)
) as element(response)
{
    let $query := concat( 
        "import module namespace atom-protocol = 'http://purl.org/atombeat/xquery/atom-protocol' at '../lib/atom-protocol.xqm' ; " ,
        "import module namespace config = 'http://purl.org/atombeat/xquery/config' at '../config/shared.xqm' ; " ,
        "let $login := xmldb:login( '/' , $config:exist-user , $config:exist-password ) " ,
        "return atom-protocol:do-post-atom-feed($request, $entity)"
    )
    return util:eval( $query , false() )
};

declare function plugin-util:atom-protocol-do-put-atom(
    $request as element(request) ,
    $entity as item()*
) as element(response)
{
    let $query := concat( 
        "import module namespace atom-protocol = 'http://purl.org/atombeat/xquery/atom-protocol' at '../lib/atom-protocol.xqm' ; " ,
        "import module namespace config = 'http://purl.org/atombeat/xquery/config' at '../config/shared.xqm' ; " ,
        "let $login := xmldb:login( '/' , $config:exist-user , $config:exist-password ) " ,
        "return atom-protocol:do-put-atom($request, $entity)"
    )
    return util:eval( $query , false() )
};

declare function plugin-util:atom-protocol-do-put-atom-entry(
    $request as element(request) ,
    $entity as element(atom:entry)
) as element(response)
{
    let $query := concat( 
        "import module namespace atom-protocol = 'http://purl.org/atombeat/xquery/atom-protocol' at '../lib/atom-protocol.xqm' ; " ,
        "import module namespace config = 'http://purl.org/atombeat/xquery/config' at '../config/shared.xqm' ; " ,
        "let $login := xmldb:login( '/' , $config:exist-user , $config:exist-password ) " ,
        "return atom-protocol:do-put-atom-entry($request, $entity)"
    )
    return util:eval( $query , false() )
};

declare function plugin-util:atom-protocol-do-put-atom-feed(
    $request as element(request) ,
    $entity as element(atom:feed)
) as element(response)
{
    let $query := concat( 
        "import module namespace atom-protocol = 'http://purl.org/atombeat/xquery/atom-protocol' at '../lib/atom-protocol.xqm' ; " ,
        "import module namespace config = 'http://purl.org/atombeat/xquery/config' at '../config/shared.xqm' ; " ,
        "let $login := xmldb:login( '/' , $config:exist-user , $config:exist-password ) " ,
        "return atom-protocol:do-put-atom-feed($request, $entity)"
    )
    return util:eval( $query , false() )
};

declare function plugin-util:atom-protocol-do-delete(
    $request as element(request) 
) as element(response)
{
    let $query := concat( 
        "import module namespace atom-protocol = 'http://purl.org/atombeat/xquery/atom-protocol' at '../lib/atom-protocol.xqm' ; " ,
        "import module namespace config = 'http://purl.org/atombeat/xquery/config' at '../config/shared.xqm' ; " ,
        "let $login := xmldb:login( '/' , $config:exist-user , $config:exist-password ) " ,
        "return atom-protocol:do-delete($request)"
    )
    return util:eval( $query , false() )
};

declare function plugin-util:atom-protocol-do-delete-member(
    $request as element(request) 
) as element(response)
{
    let $query := concat( 
        "import module namespace atom-protocol = 'http://purl.org/atombeat/xquery/atom-protocol' at '../lib/atom-protocol.xqm' ; " ,
        "import module namespace config = 'http://purl.org/atombeat/xquery/config' at '../config/shared.xqm' ; " ,
        "let $login := xmldb:login( '/' , $config:exist-user , $config:exist-password ) " ,
        "return atom-protocol:do-delete-member($request)"
    )
    return util:eval( $query , false() )
};

declare function plugin-util:atom-protocol-do-delete-media(
    $request as element(request) 
) as element(response)
{
    let $query := concat( 
        "import module namespace atom-protocol = 'http://purl.org/atombeat/xquery/atom-protocol' at '../lib/atom-protocol.xqm' ; " ,
        "import module namespace config = 'http://purl.org/atombeat/xquery/config' at '../config/shared.xqm' ; " ,
        "let $login := xmldb:login( '/' , $config:exist-user , $config:exist-password ) " ,
        "return atom-protocol:do-delete-media($request)"
    )
    return util:eval( $query , false() )
};

declare function plugin-util:security-protocol-do-get(
    $request as element(request)
) as element(response)
{
    let $query := concat( 
        "import module namespace security-protocol = 'http://purl.org/atombeat/xquery/security-protocol' at '../lib/security-protocol.xqm' ; " ,
        "import module namespace config = 'http://purl.org/atombeat/xquery/config' at '../config/shared.xqm' ; " ,
        "let $login := xmldb:login( '/' , $config:exist-user , $config:exist-password ) " ,
        "return security-protocol:do-get($request)"
    )
    return util:eval( $query , false() )
};

declare function plugin-util:security-protocol-do-put(
    $request as element(request) ,
    $entity as item()*
) as element(response)
{
    let $query := concat( 
        "import module namespace security-protocol = 'http://purl.org/atombeat/xquery/security-protocol' at '../lib/security-protocol.xqm' ; " ,
        "import module namespace config = 'http://purl.org/atombeat/xquery/config' at '../config/shared.xqm' ; " ,
        "let $login := xmldb:login( '/' , $config:exist-user , $config:exist-password ) " ,
        "return security-protocol:do-put($request, $entity)"
    )
    return util:eval( $query , false() )
};



