<!---
Copyright (c) 2007, Joseph Lamoree
http://www.lamoree.com/
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

 + Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

 + Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--->

<cfcomponent>

	<cfset variables.javaLoader = "null"/>
	<cfset variables.dnsTypes = "null"/>
	<cfset variables.address = "null"/>
	<cfset variables.inetAddress = "null"/>
	<cfset variables.reverseMap = "null"/>
	<cfset variables.timeout = 0/>
	<cfset variables.retries = 0/>
	<cfset variables.servers = ""/>

	<cffunction name="init" access="public" returntype="DNS" output="false">
		<cfargument name="javaLoader" type="any" required="true"/>
		<cfargument name="timeout" type="numeric" required="true" default="10"/>
		<cfargument name="retries" type="numeric" required="true" default="3"/>
		<cfargument name="servers" type="string" required="true" default=""/>

		<cfset setJavaLoader(arguments.javaLoader)/>
		<cfset setDNSTypes(arguments.javaLoader.create("org.xbill.DNS.Type"))/>
		<cfset setInetAddress(arguments.javaLoader.create("java.net.InetAddress"))/>
		<cfset setAddress(arguments.javaLoader.create("org.xbill.DNS.Address"))/>
		<cfset setReverseMap(arguments.javaLoader.create("org.xbill.DNS.ReverseMap"))/>
		<cfset setTimeout(arguments.timeout)/>
		<cfset setRetries(arguments.retries)/>
		<cfset setServers(arguments.servers)/>
		<cfreturn this/>
	</cffunction>

	<cffunction name="getRecords" returntype="array" access="public" output="false">
		<cfargument name="name" type="string" required="true"/>
		<cfargument name="type" type="string" required="true" default="ANY"/>
		<cfargument name="throwOnError" type="boolean" required="true" default="false"/>

		<cfset var result = structNew()/>
		<cfset var records = arrayNew(1)/>
		<cfset var lookup = "null"/>
		<cfset var query = arguments.name/>
		<cfset var dnsType = getDNSTypes().value(arguments.type)/>

		<cfset result.lookup = 0/>
		<cfset result.success = false/>
		<cfset result.message = ""/>

		<cfif getAddress().isDottedQuad(query)>
			<cfset query = getReverseMap().fromAddress(query)/>
		</cfif>

		<cftry>
			<cfset lookup = getJavaLoader().create("org.xbill.DNS.Lookup").init(query, dnsType)/>
			<cfset lookup.setResolver(getResolver())/>
			<cfset records = lookup.run()/>
			<cfset result.lookup = lookup.getResult()/>
			<cfif result.lookup eq lookup.SUCCESSFUL>
				<cfset result.success = true/>
			<cfelse>
				<cfset result.message = lookup.getErrorString()/>
				<cfset records = arrayNew(1)/>
				<cfthrow type="DNSLookupException" message="#result.message#"/>
			</cfif>
			<cfcatch>
				<cfif arguments.throwOnError>
					<cfrethrow/>
				</cfif>
			</cfcatch>
		</cftry>
		<cfreturn records/>
	</cffunction>

	<cffunction name="getType" returntype="string" access="public" output="false">
		<cfargument name="value" type="numeric" required="true"/>
		<cfreturn getDNSTypes().string(javaCast("int", arguments.value))/>
	</cffunction>
	<cffunction name="getTypeValue" returntype="numeric" access="public" output="false">
		<cfargument name="type" type="string" required="true"/>
		<cfreturn getDNSTypes().value(arguments.type)/>
	</cffunction>

	<cffunction name="getLocalHostName" returntype="string" access="public" output="true">
		<cfset var result = "unknown"/>

		<cftry>
			<cfset result = getInetAddress().getLocalHost().getHostName()/>
			<cfcatch>
				<!-- Bummer -->
			</cfcatch>
		</cftry>
		<cfreturn result/>
	</cffunction>

	<cffunction name="getHostName" returntype="string" access="public" output="true">
		<cfargument name="address" type="string" required="true"/>

		<cfset var result = "unknown"/>
		<cfset var records = "null"/>
		<cfset var i = 0/>

		<cftry>
			<cfset records = getRecords(name="#arguments.address#", type="PTR", throwOnError="true")/>
			<cfset result = ""/>
			<cfloop from="1" to="#arrayLen(records)#" index="i">
				<cfset result = listAppend(result, records[i].getTarget())/>
			</cfloop>
			<cfcatch>
				<!-- Bummer -->
			</cfcatch>
		</cftry>
		<cfreturn result/>
	</cffunction>

	<cffunction name="getHostAddress" returntype="string" access="public" output="true">
		<cfargument name="name" type="string" required="true"/>

		<cfset var result = "unknown"/>
		<cfset var records = "null"/>
		<cfset var i = 0/>

		<cftry>
			<cfset records = getRecords(name="#arguments.name#", type="A", throwOnError="true")/>
			<cfset result = ""/>
			<cfloop from="1" to="#arrayLen(records)#" index="i">
				<cfset result = listAppend(result, records[i].getAddress().getHostAddress())/>
			</cfloop>
			<cfcatch>
				<!-- Bummer -->
			</cfcatch>
		</cftry>
		<cfreturn result/>
	</cffunction>

	<cffunction name="getResolver" returntype="any" access="private" output="false">
		<cfset var resolver = "null"/>

		<cfif getServers() neq "">
			<cfset resolver = getJavaLoader().create("org.xbill.DNS.ExtendedResolver").init(getServers().split(","))/>
		<cfelse>
			<cfset resolver = getJavaLoader().create("org.xbill.DNS.ExtendedResolver")/>
		</cfif>
		<cfset resolver.setTimeout(javaCast("int", getTimeout()))/>
		<cfset resolver.setRetries(javaCast("int", getRetries()))/>
		<cfreturn resolver/>
	</cffunction>

	<cffunction name="getDNSTypes" returntype="any" access="private" output="false">
		<cfreturn variables.dnsTypes/>
	</cffunction>
	<cffunction name="setDNSTypes" returntype="void" access="private" output="false">
		<cfargument name="dnsTypes" type="any" required="true"/>
		<cfset variables.dnsTypes = arguments.dnsTypes/>
	</cffunction>

	<cffunction name="getJavaLoader" returntype="any" access="private" output="false">
		<cfreturn variables.javaLoader/>
	</cffunction>
	<cffunction name="setJavaLoader" returntype="void" access="private" output="false">
		<cfargument name="javaLoader" type="any" required="true"/>
		<cfset variables.javaLoader = arguments.javaLoader/>
	</cffunction>

	<cffunction name="getAddress" returntype="any" access="private" output="false">
		<cfreturn variables.address/>
	</cffunction>
	<cffunction name="setAddress" returntype="void" access="private" output="false">
		<cfargument name="address" type="any" required="true"/>
		<cfset variables.address = arguments.address/>
	</cffunction>

	<cffunction name="getInetAddress" returntype="any" access="private" output="false">
		<cfreturn variables.inetAddress/>
	</cffunction>
	<cffunction name="setInetAddress" returntype="void" access="private" output="false">
		<cfargument name="inetAddress" type="any" required="true"/>
		<cfset variables.inetAddress = arguments.inetAddress/>
	</cffunction>

	<cffunction name="getReverseMap" returntype="any" access="private" output="false">
		<cfreturn variables.reverseMap/>
	</cffunction>
	<cffunction name="setReverseMap" returntype="void" access="private" output="false">
		<cfargument name="reverseMap" type="any" required="true"/>
		<cfset variables.reverseMap = arguments.reverseMap/>
	</cffunction>

	<cffunction name="getTimeout" returntype="any" access="private" output="false">
		<cfreturn variables.timeout/>
	</cffunction>
	<cffunction name="setTimeout" returntype="void" access="private" output="false">
		<cfargument name="timeout" type="any" required="true"/>
		<cfset variables.timeout = arguments.timeout/>
	</cffunction>

	<cffunction name="getRetries" returntype="any" access="private" output="false">
		<cfreturn variables.retries/>
	</cffunction>
	<cffunction name="setRetries" returntype="void" access="private" output="false">
		<cfargument name="retries" type="any" required="true"/>
		<cfset variables.retries = arguments.retries/>
	</cffunction>

	<cffunction name="getServers" returntype="any" access="private" output="false">
		<cfreturn variables.servers/>
	</cffunction>
	<cffunction name="setServers" returntype="void" access="public" output="false">
		<cfargument name="servers" type="any" required="true"/>
		<cfset variables.servers = arguments.servers/>
	</cffunction>

</cfcomponent>