

# Versioning #

See http://tools.ietf.org/id/draft-snell-atompub-revision-00.txt

  * 'history'
  * 'initial-revision'
  * 'current-revision'
  * 'this-revision'
  * 'prior-revision'
  * 'next-revision'

## Examples ##

E.g., an Atom entry with a 'history' link...

```
<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
    <atom:id>http://localhost:8081/atombeat/atombeat/content/0.1995552997730068/0c9ba353-f7ce-4601-a23f-e74ce17f4a87.atom</atom:id>
    <atom:published>2010-03-25T13:24:09.602Z</atom:published>
    <atom:updated>2010-03-25T13:24:09.602Z</atom:updated>
    <atom:link rel="self" type="application/atom+xml" href="http://localhost:8081/atombeat/atombeat/content/0.1995552997730068/0c9ba353-f7ce-4601-a23f-e74ce17f4a87.atom"/>
    <atom:link rel="edit" type="application/atom+xml" href="http://localhost:8081/atombeat/atombeat/content/0.1995552997730068/0c9ba353-f7ce-4601-a23f-e74ce17f4a87.atom"/>
    <atom:title>Test Member</atom:title>
    <atom:summary>This is a summary, first daft.</atom:summary>
    <atom:link rel="history" href="http://localhost:8081/atombeat/atombeat/history/0.1995552997730068/0c9ba353-f7ce-4601-a23f-e74ce17f4a87.atom"/>
</atom:entry>
```

E.g., an Atom entry revision with various revision links...

```
<atom:entry>
    <ar:revision xmlns:ar="http://purl.org/atompub/revision/1.0" number="3" when="2010-03-25T13:24:09.915Z" initial="no"/>
    <atom:link rel="current-revision" type="application/atom+xml" href="http://localhost:8081/atombeat/atombeat/content/0.1995552997730068/0c9ba353-f7ce-4601-a23f-e74ce17f4a87.atom"/>
    <atom:link rel="initial-revision" type="application/atom+xml" href="http://localhost:8081/atombeat/atombeat/history/0.1995552997730068/0c9ba353-f7ce-4601-a23f-e74ce17f4a87.atom?revision=1"/>
    <atom:link rel="this-revision" type="application/atom+xml" href="http://localhost:8081/atombeat/atombeat/history/0.1995552997730068/0c9ba353-f7ce-4601-a23f-e74ce17f4a87.atom?revision=3"/>
    <atom:link rel="previous-revision" type="application/atom+xml" href="http://localhost:8081/atombeat/atombeat/history/0.1995552997730068/0c9ba353-f7ce-4601-a23f-e74ce17f4a87.atom?revision=2"/>
    <atom:id>http://localhost:8081/atombeat/atombeat/content/0.1995552997730068/0c9ba353-f7ce-4601-a23f-e74ce17f4a87.atom</atom:id>
    <atom:published>2010-03-25T13:24:09.602Z</atom:published>
    <atom:updated>2010-03-25T13:24:09.915Z</atom:updated>
    <atom:link rel="self" type="application/atom+xml" href="http://localhost:8081/atombeat/atombeat/content/0.1995552997730068/0c9ba353-f7ce-4601-a23f-e74ce17f4a87.atom"/>
    <atom:link rel="edit" type="application/atom+xml" href="http://localhost:8081/atombeat/atombeat/content/0.1995552997730068/0c9ba353-f7ce-4601-a23f-e74ce17f4a87.atom"/>
    <atom:title>Test Member - Updated Again</atom:title>
    <atom:summary>This is a summary, updated (third draft).</atom:summary>
</atom:entry>
```

# Access Control #

## security-descriptor ##

**URI: '`http://purl.org/atombeat/rel/security-descriptor`'**

Atom feed elements MAY contain an atom:link element with a rel attribute value of '`http://purl.org/atombeat/rel/security-descriptor`' whose href attribute identifies a resource that is an access control list for the collection.

Atom entry elements MAY contain an atom:link element with a rel attribute value of '`http://purl.org/atombeat/rel/security-descriptor`' whose href attribute identifies a resource that is an access control list for the entry.

## media-security-descriptor ##

**URI: '`http://purl.org/atombeat/rel/media-security-descriptor`'**

Atom entry elements MAY contain an atom:link element with a rel attribute value of '`http://purl.org/atombeat/rel/media-security-descriptor`' whose href attribute identifies a resource that is an access control list for the media resource for which the entry is the media-link entry.

## Examples ##

E.g., an Atom feed with a '`http://purl.org/atombeat/rel/security-descriptor`' link...

```
<atom:feed xmlns:atom="http://www.w3.org/2005/Atom">
    <atom:id>http://localhost:8081/atombeat/atombeat/content/0.7944490448575703</atom:id>
    <atom:updated>2010-03-25T13:34:09.607Z</atom:updated>
    <atom:link rel="self" type="application/atom+xml" href="http://localhost:8081/atombeat/atombeat/content/0.7944490448575703"/>
    <atom:link rel="edit" type="application/atom+xml" href="http://localhost:8081/atombeat/atombeat/content/0.7944490448575703"/>
    <atom:title>Test Collection</atom:title>
    <atom:link rel="http://purl.org/atombeat/rel/security-descriptor" href="http://localhost:8081/atombeat/atombeat/acl/0.7944490448575703" type="application/atom+xml"/>
</atom:feed>
```

E.g., an Atom entry with a '`http://purl.org/atombeat/rel/security-descriptor`' link...

```
<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
    <atom:id>http://localhost:8081/atombeat/atombeat/content/0.9255307573775159/322fedb1-d46c-4d7b-8982-732d967e8360.atom</atom:id>
    <atom:published>2010-03-25T13:34:11.064Z</atom:published>
    <atom:updated>2010-03-25T13:34:11.064Z</atom:updated>
    <atom:link rel="self" type="application/atom+xml" href="http://localhost:8081/atombeat/atombeat/content/0.9255307573775159/322fedb1-d46c-4d7b-8982-732d967e8360.atom"/>
    <atom:link rel="edit" type="application/atom+xml" href="http://localhost:8081/atombeat/atombeat/content/0.9255307573775159/322fedb1-d46c-4d7b-8982-732d967e8360.atom"/>
    <atom:title>Test Entry</atom:title>
    <atom:summary>this is a test</atom:summary>
    <atom:link rel="http://purl.org/atombeat/rel/security-descriptor" href="http://localhost:8081/atombeat/atombeat/acl/0.9255307573775159/322fedb1-d46c-4d7b-8982-732d967e8360.atom" type="application/atom+xml"/>
</atom:entry>
```

E.g., an Atom media-link entry with a '`http://purl.org/atombeat/rel/media-security-descriptor`' link...

```
<atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
    <atom:id>http://localhost:8081/atombeat/atombeat/content/0.08023994864766848/9a787644-6669-42b5-89cc-fd62ad50c9a7.atom</atom:id>
    <atom:published>2010-05-14T13:40:59.096+01:00</atom:published>
    <atom:updated>2010-05-14T13:40:59.096+01:00</atom:updated>
    <atom:link rel="self" type="application/atom+xml" href="http://localhost:8081/atombeat/atombeat/content/0.08023994864766848/9a787644-6669-42b5-89cc-fd62ad50c9a7.atom"/>
    <atom:link rel="edit" type="application/atom+xml" href="http://localhost:8081/atombeat/atombeat/content/0.08023994864766848/9a787644-6669-42b5-89cc-fd62ad50c9a7.atom"/>
    <atom:link rel="edit-media" type="text/plain" href="http://localhost:8081/atombeat/atombeat/content/0.08023994864766848/9a787644-6669-42b5-89cc-fd62ad50c9a7.media"/>
    <atom:content src="http://localhost:8081/atombeat/atombeat/content/0.08023994864766848/9a787644-6669-42b5-89cc-fd62ad50c9a7.media" type="text/plain"/>
    <atom:title type="text">download-9a787644-6669-42b5-89cc-fd62ad50c9a7.media</atom:title>
    <atom:summary type="text">media resource (text/plain)</atom:summary>
    <atom:link rel="http://purl.org/atombeat/rel/security-descriptor" href="http://localhost:8081/atombeat/atombeat/acl/0.08023994864766848/9a787644-6669-42b5-89cc-fd62ad50c9a7.atom" type="application/atom+xml"/>
    <atom:link rel="http://purl.org/atombeat/rel/media-security-descriptor" href="http://localhost:8081/atombeat/atombeat/acl/0.08023994864766848/9a787644-6669-42b5-89cc-fd62ad50c9a7.media" type="application/atom+xml"/>
</atom:entry>
```