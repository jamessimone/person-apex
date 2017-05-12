# person-apex
Wrapper class to get around inaccessible interfaces within Salesforce.

If you are developing in Apex, odds are likely that you are oftentimes working with collections of SObjects.  You may even find yourself iterating through those collections!  If you aren't do that, I would advise stopping here. While having access to this base abstraction for all Salesforce object type can be extremely convenient in the re-use of code, there are unfortunate complications that come from using the base SObject type within Salesforce.

Pros:

You can an insert /update as many as 10 different SObject types in the same List! That's pretty cool.  Take that, SQL!!
You still have access to the Id of the more complicated object while it has been "upcast"

Cons:

All other properties have to be accessed with the same getter.  This opens you up to two different issues, both ugly.

a) Lack of type safety.  The compiler isn't going to be able to tell you whether or not a given field exists. For some,
that might be an acceptable risk.  If you amenable to calling the getter twice - once to null check, once to actually access
the property - and if you accept the fact that you'll be duplicating this exact ternary or other conditional throughout your system,
you can save space by consolidating methods that accomplish the same function for different objects.

To be clear - overloading methods is a fine alternative to this issue.  Duplication still presents an issue with overloading, unless all
of the "get" methods you care about can be centrally consolidated (<--- spoiler alert!).

b) The SObject interface and class are sealed - they are not open to extension or modification. Blast!


For many organizations, it may be the case that the most common similarities between SObjects occur between new Leads and the Contacts that those Leads become.
After all, when is the last time that a Lead that you spoke with was a company? Given the difficulty most inanimate / abstract entities have in communicating,
the Person class exists to provide a Salesforce crutch for Apex developers who would like to abstract out their business logic dealing with people from the somewhat hobbled SObject. After several days of riding off away from the OOD sunset while adding Contact / Lead checks throughout our project, I decided that if there couldn't be a standard better way, there could at least be a tangential solution.

The Person class can be extended however you would like as a means of hiding away the ugliness associated with the SObject getters. Indeed, an alternative strategy to the provided encapsulations (which still, in some cases, go through the hassle of null checks as a way of avoiding having to declare so many properties upfront) would be to only store the underlying SObject, and abstract the getters to within each of the children classes for accessing properties like Email / Phone. This would provide truly type-safe methods for accessing the underlying data, at the cost of some minor duplication.  Either way, when it comes time to return your records to the cloud database they're safely nestled in, you have the ability to retrieve the SObjects themselves, perform any necessary updates to them, and proceed on your way.  This also allows you to use inheritance to define how updates between Leads / Contacts should behave. If that last sentence doesn't get you clicking your heels for Kansas, it's ok! No hard feelings.
