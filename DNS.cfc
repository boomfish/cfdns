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
		<cfset setName(arguments.javaLoader.create("org.xbill.DNS.Name"))/>
		<cfset setRecord(arguments.javaLoader.create("org.xbill.DNS.Record"))/>
		<cfset setMessage(arguments.javaLoader.create("org.xbill.DNS.Message"))/>
		<cfset setType(arguments.javaLoader.create("org.xbill.DNS.Type"))/>
		<cfset setDClass(arguments.javaLoader.create("org.xbill.DNS.DClass"))/>
		<cfset setAddress(arguments.javaLoader.create("org.xbill.DNS.Address"))/>
		<cfset setCredibility(arguments.javaLoader.create("org.xbill.DNS.Credibility"))/>
		<cfset setInetAddress(arguments.javaLoader.create("java.net.InetAddress"))/>
		<cfset setReverseMap(arguments.javaLoader.create("org.xbill.DNS.ReverseMap"))/>
		<cfset setTimeout(arguments.timeout)/>
		<cfset setRetries(arguments.retries)/>
		<cfset setServers(arguments.servers)/>
		<cfreturn this/>
	</cffunction>

	<cffunction name="doQuery" returntype="any" access="public" output="false">
		<cfargument name="name" type="string" required="true"/>
		<cfargument name="type" type="string" required="true" default=""/>
		<cfargument name="class" type="string" required="true" default=""/>
		<cfargument name="credibility" type="string" required="true" default=""/>
		<cfargument name="throwOnError" type="boolean" required="true" default="false"/>

		<cfset var result = structNew()/>
		<cfset var query = "null"/>
		<cfset var record = "null"/>
		<cfset var resolver = "null"/>
		<cfset var response = "null"/>
		<cfset var section = "null"/>
		<cfset var _name = arguments.name/>
		<cfset var _type = getConstantValue("Type", arguments.type)/>
		<cfset var dClass = getConstantValue("DClass", arguments.class)/>
		<cfset var _credibility = getConstantValue("Credibility", arguments.credibility)/>
		<cfset var i = 0/>
		<cfset var j = 0/>

		<cfset result.success = false/>
		<cfset result.sections = arrayNew(1)/>

		<cfif getAddress().isDottedQuad(_name)>
			<cfset _name = getReverseMap().fromAddress(_name)/>
		<cfelseif right(_name, 1) neq ".">
			<cfset _name = _name & "."/>
		</cfif>

		<cftry>
			<cfset record = getRecord().newRecord(getName().fromString(_name), javaCast("int", _type), javaCast("int", dClass))/>
			<cfset query = getMessage().newQuery(record)/>
			<cfset resolver = getResolver()/>
			<cfset response = resolver.send(query)/>
			<cfset result.success = true/>
			<cfcatch>
				<cfif arguments.throwOnError>
					<cfthrow type="DNSQueryException" message="#cfcatch.message#"/>
				</cfif>
			</cfcatch>
		</cftry>

		<cfif result.success>
			<cfloop from="1" to="4" index="i">
				<cfset section = response.getSectionArray(javaCast("int", i - 1))/>
				<cfset result.sections[i] = arrayNew(1)/>
				<cfloop from="1" to="#arrayLen(section)#" index="j">
					<cfset arrayAppend(result.sections[i], createObject("component", "Record").init(this, section[j]))/>
				</cfloop>
			</cfloop>
		</cfif>
		<cfreturn result.sections/>
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
		<cfset var sections = "null"/>
		<cfset var records = "null"/>
		<cfset var i = 0/>

		<cftry>
			<cfset sections = doQuery(name="#arguments.address#", type="PTR", class="IN", throwOnError="true")/>
			<cfset records = sections[2]/>
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
		<cfset var sections = "null"/>
		<cfset var records = "null"/>
		<cfset var i = 0/>

		<cftry>
			<cfset sections = doQuery(name="#arguments.name#", type="A", class="IN", throwOnError="true")/>
			<cfset records = sections[2]/>
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

		<cfif arguments.type eq "Type">
			<cfreturn getType().string(javaCast("int", arguments.value))/>
		<cfelseif arguments.type eq "DClass">
			<cfreturn getDClass().string(javaCast("int", arguments.value))/>
		<cfelseif arguments.type eq "Credibility">
			<cfreturn "ANY"/>
		<cfelse>
			<cfreturn ""/>
		</cfif>
	</cffunction>
	<cffunction name="getConstantValue" returntype="numeric" access="public" output="false">
		<cfargument name="type" type="string" required="true" default="DNSType"/>
		<cfargument name="name" type="string" required="true" default=""/>

		<cfif arguments.type eq "Type">
			<cfreturn getType().value(arguments.name)/>
		<cfelseif arguments.type eq "DClass">
			<cfreturn getDClass().value(arguments.name)/>
		<cfelseif arguments.type eq "Credibility">
			<cfreturn -1/>
		<cfelse>
			<cfreturn -1/>
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
	<cffunction name="getName" returntype="any" access="private" output="false">
		<cfreturn variables.name/>
	</cffunction>
	<cffunction name="setName" returntype="void" access="private" output="false">
		<cfargument name="name" type="any" required="true"/>
		<cfset variables.name = arguments.name/>
	</cffunction>

	<cffunction name="getMessage" returntype="any" access="private" output="false">
		<cfreturn variables.message/>
	</cffunction>
	<cffunction name="setMessage" returntype="void" access="private" output="false">
		<cfargument name="message" type="any" required="true"/>
		<cfset variables.message = arguments.message/>
	</cffunction>

	<cffunction name="getRecord" returntype="any" access="private" output="false">
		<cfreturn variables.record/>
	</cffunction>
	<cffunction name="setRecord" returntype="void" access="private" output="false">
		<cfargument name="record" type="any" required="true"/>
		<cfset variables.record = arguments.record/>
	</cffunction>

	<cffunction name="getType" returntype="any" access="private" output="false">
		<cfreturn variables.type/>
	</cffunction>
	<cffunction name="setType" returntype="void" access="private" output="false">
		<cfargument name="type" type="any" required="true"/>
		<cfset variables.type = arguments.type/>
	</cffunction>

	<cffunction name="getDClass" returntype="any" access="private" output="false">
		<cfreturn variables.dClass/>
	</cffunction>
	<cffunction name="setDClass" returntype="void" access="private" output="false">
		<cfargument name="dClass" type="any" required="true"/>
		<cfset variables.dClass = arguments.dClass/>
	</cffunction>

	<cffunction name="getAddress" returntype="any" access="private" output="false">
		<cfreturn variables.address/>
	</cffunction>
	<cffunction name="setAddress" returntype="void" access="private" output="false">
		<cfargument name="address" type="any" required="true"/>
		<cfset variables.address = arguments.address/>
	</cffunction>

	<cffunction name="getCredibility" returntype="any" access="private" output="false">
		<cfreturn variables.credibility/>
	</cffunction>
	<cffunction name="setCredibility" returntype="void" access="private" output="false">
		<cfargument name="credibility" type="any" required="true"/>
		<cfset variables.credibility = arguments.credibility/>
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