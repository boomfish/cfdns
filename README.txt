
What is cfdns?

The cfdns project is a ColdFusion enhancement that allows a developer to make
DNS queries easily. It is a CFC wrapper for the dnsjava library, and uses
JavaLoader to dynamically load the Java library, thus it does not require that
you change your server's JVM classpath.

The cfdns.DNS component should be created at application initialization, say by
ColdSpring for example, and then kept in a persistent scope. The timeout,
retries, and servers options can be changed at any time; a new resolver is
created internally for each query using the current state. If no server is
specified, the component uses the local system's name resolution configuration
and cache.

Accompanying the component is a tag library that assists in the output of
information gathered from a query. This isolates the code implementing the view
from knowing about the Java classes created by the underlying library.

The demo site at www.cfdns.org is a Mach-II application running on Open
BlueDragon 1.3. 

License:

cfdns is released under the BSD License. See license.txt for details.

You are encouraged to examine the source code and make your own modifications
and announce your changes on www.cfdns.org so they may be incorporated into
future versions of the project.

dnsjava is included under the BSD License. See lib/license.txt for details.

JavaLoader is included under the Common Public License Version 1.0. See
javaloader/license.txt for details.

The source code for JavaLoader may be obtained from the RIAForge site
<http://javaloader.riaforge.org/> or Mark Mandel's JavaLoader page
<http://www.compoundtheory.com/?action=javaloader.index>. 

Other files may be under additional licenses; see the individual files for
details.
