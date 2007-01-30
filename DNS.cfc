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
	<cfset variables.dnsType = "null"/>
	<cfset variables.dnsClass = "null"/>
	<cfset variables.dnsAddress = "null"/>
	<cfset variables.dnsCredibility = "null"/>
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
		<cfset setDNSType(arguments.javaLoader.create("org.xbill.DNS.Type"))/>
		<cfset setDNSClass(arguments.javaLoader.create("org.xbill.DNS.DClass"))/>
		<cfset setDNSAddress(arguments.javaLoader.create("org.xbill.DNS.Address"))/>
		<cfset setDNSCredibility(arguments.javaLoader.create("org.xbill.DNS.Credibility"))/>
		<cfset setInetAddress(arguments.javaLoader.create("java.net.InetAddress"))/>
		<cfset setReverseMap(arguments.javaLoader.create("org.xbill.DNS.ReverseMap"))/>
		<cfset setTimeout(arguments.timeout)/>
		<cfset setRetries(arguments.retries)/>
		<cfset setServers(arguments.servers)/>
		<cfreturn this/>
	</cffunction>

	<cffunction name="getRecords" returntype="array" access="public" output="false">
		<cfargument name="query" type="string" required="true"/>
		<cfargument name="type" type="string" required="true" default="ANY"/>
		<cfargument name="class" type="string" required="true" default="IN"/>
		<cfargument name="credibility" type="string" required="true" default="ANY"/>
		<cfargument name="throwOnError" type="boolean" required="true" default="false"/>

		<cfset var result = structNew()/>
		<cfset var records = arrayNew(1)/>
		<cfset var lookup = "null"/>
		<cfset var _query = arguments.query/>
		<cfset var dnsType = getConstantValue("DNSType", arguments.type)/>
		<cfset var dnsClass = getConstantValue("DNSClass", arguments.class)/>
		<cfset var dnsCredibility = getConstantValue("DNSCredibility", arguments.credibility)/>
		<cfset var i = 0/>

		<cfset result.lookup = 0/>
		<cfset result.success = false/>
		<cfset result.message = ""/>
		<cfset result.records = arrayNew(1)/>

		<cfif getDNSAddress().isDottedQuad(_query)>
			<cfset _query = getReverseMap().fromAddress(_query)/>
		</cfif>

		<cftry>
			<cfset lookup = getJavaLoader().create("org.xbill.DNS.Lookup").init(_query, javaCast("int", dnsType), javaCast("int", dnsClass))/>
			<cfset lookup.setResolver(getResolver())/>
			<cfset lookup.setCredibility(dnsCredibility)/>
			<cfset records = lookup.run()/>
			<cfset result.lookup = lookup.getResult()/>
			<cfif result.lookup eq lookup.SUCCESSFUL>
				<cfset result.success = true/>
			<cfelse>
				<cfset result.message = lookup.getErrorString()/>
				<cfthrow type="DNSLookupException" message="#result.message#"/>
			</cfif>
			<cfcatch>
				<cfif arguments.throwOnError>
					<cfrethrow/>
				</cfif>
			</cfcatch>
		</cftry>

		<cfif result.success>
			<cfloop from="1" to="#arrayLen(records)#" index="i">
				<cfset arrayAppend(result.records, createObject("component", "Record").init(this, records[i]))/>
			</cfloop>
		</cfif>
		<cfreturn result.records/>
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

		<!--- Potential performance improvement: use a dirty bit to recycle the last resolver if state is static --->
		<cfif getServers() neq "">
			<cfset resolver = getJavaLoader().create("org.xbill.DNS.ExtendedResolver").init(getServers().split(","))/>
		<cfelse>
			<cfset resolver = getJavaLoader().create("org.xbill.DNS.ExtendedResolver")/>
		</cfif>
		<cfset resolver.setTimeout(javaCast("int", getTimeout()))/>
		<cfset resolver.setRetries(javaCast("int", getRetries()))/>
		<cfreturn resolver/>
	</cffunction>

	<cffunction name="getConstantName" returntype="string" access="public" output="false">
		<cfargument name="type" type="string" required="true" default="DNSType"/>
		<cfargument name="value" type="numeric" required="true" default="0"/>

		<cfif arguments.type eq "DNSType">
			<cfreturn getDNSType().string(javaCast("int", arguments.value))/>
		<cfelseif arguments.type eq "DNSClass">
			<cfreturn getDNSClass().string(javaCast("int", arguments.value))/>
		<cfelseif arguments.type eq "DNSCredibility">
			<cfreturn "ANY"/>
		<cfelse>
			<cfreturn ""/>
		</cfif>
	</cffunction>
	<cffunction name="getConstantValue" returntype="numeric" access="public" output="false">
		<cfargument name="type" type="string" required="true" default="DNSType"/>
		<cfargument name="name" type="string" required="true" default=""/>

		<cfif arguments.type eq "DNSType">
			<cfreturn getDNSType().value(arguments.name)/>
		<cfelseif arguments.type eq "DNSClass">
			<cfreturn getDNSClass().value(arguments.name)/>
		<cfelseif arguments.type eq "DNSCredibility">
			<cfreturn getDNSCredibility().ANY/>
		<cfelse>
			<cfreturn 0/>
		</cfif>
	</cffunction>

	<!--- State Settings --->
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


	<!--- Private Methods --->
	<cffunction name="getDNSType" returntype="any" access="private" output="false">
		<cfreturn variables.dnsType/>
	</cffunction>
	<cffunction name="setDNSType" returntype="void" access="private" output="false">
		<cfargument name="dnsType" type="any" required="true"/>
		<cfset variables.dnsType = arguments.dnsType/>
	</cffunction>

	<cffunction name="getDNSClass" returntype="any" access="private" output="false">
		<cfreturn variables.dnsClass/>
	</cffunction>
	<cffunction name="setDNSClass" returntype="void" access="private" output="false">
		<cfargument name="dnsClass" type="any" required="true"/>
		<cfset variables.dnsClass = arguments.dnsClass/>
	</cffunction>

	<cffunction name="getDNSAddress" returntype="any" access="private" output="false">
		<cfreturn variables.dnsAddress/>
	</cffunction>
	<cffunction name="setDNSAddress" returntype="void" access="private" output="false">
		<cfargument name="dnsAddress" type="any" required="true"/>
		<cfset variables.dnsAddress = arguments.dnsAddress/>
	</cffunction>

	<cffunction name="getDNSCredibility" returntype="any" access="private" output="false">
		<cfreturn variables.dnsCredibility/>
	</cffunction>
	<cffunction name="setDNSCredibility" returntype="void" access="private" output="false">
		<cfargument name="dnsCredibility" type="any" required="true"/>
		<cfset variables.dnsCredibility = arguments.dnsCredibility/>
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

	<cffunction name="getJavaLoader" returntype="any" access="private" output="false">
		<cfreturn variables.javaLoader/>
	</cffunction>
	<cffunction name="setJavaLoader" returntype="void" access="private" output="false">
		<cfargument name="javaLoader" type="any" required="true"/>
		<cfset variables.javaLoader = arguments.javaLoader/>
	</cffunction>

</cfcomponent>