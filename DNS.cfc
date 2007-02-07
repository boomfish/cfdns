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
	<cfset variables.type = "null"/>
	<cfset variables.dClass = "null"/>
	<cfset variables.address = "null"/>
	<cfset variables.name = "null"/>
	<cfset variables.message = "null"/>
	<cfset variables.section = "null"/>
	<cfset variables.header = "null"/>
	<cfset variables.record = "null"/>
	<cfset variables.flags = "null"/>
	<cfset variables.inetAddress = "null"/>
	<cfset variables.reverseMap = "null"/>
	<cfset variables.resolverProperties = structNew()/>

	<cffunction name="init" access="public" returntype="DNS" output="false">
		<cfargument name="javaLoader" type="any" required="true"/>
		<cfargument name="resolverProperties" type="struct" required="false"/>

		<cfset setJavaLoader(arguments.javaLoader)/>
		<cfif structKeyExists(arguments, "resolverProperties")>
			<cfset setResolverProperties(arguments.resolverProperties)/>
		</cfif>

		<!--- Create persistent references these static classes --->
		<cfset setType(arguments.javaLoader.create("org.xbill.DNS.Type"))/>
		<cfset setDClass(arguments.javaLoader.create("org.xbill.DNS.DClass"))/>
		<cfset setAddress(arguments.javaLoader.create("org.xbill.DNS.Address"))/>
		<cfset setName(arguments.javaLoader.create("org.xbill.DNS.Name"))/>
		<cfset setMessage(arguments.javaLoader.create("org.xbill.DNS.Message"))/>
		<cfset setSection(arguments.javaLoader.create("org.xbill.DNS.Section"))/>
		<cfset setHeader(arguments.javaLoader.create("org.xbill.DNS.Header"))/>
		<cfset setRecord(arguments.javaLoader.create("org.xbill.DNS.Record"))/>
		<cfset setFlags(arguments.javaLoader.create("org.xbill.DNS.Flags"))/>
		<cfset setInetAddress(arguments.javaLoader.create("java.net.InetAddress"))/>
		<cfset setReverseMap(arguments.javaLoader.create("org.xbill.DNS.ReverseMap"))/>

		<cfreturn this/>
	</cffunction>

	<cffunction name="doQuery" returntype="any" access="public" output="false">
		<cfargument name="name" type="string" required="true"/>
		<cfargument name="type" type="string" required="true" default=""/>
		<cfargument name="class" type="string" required="true" default=""/>
		<cfargument name="throwOnError" type="boolean" required="true" default="false"/>

		<cfset var result = structNew()/>
		<cfset var query = "null"/>
		<cfset var record = "null"/>
		<cfset var response = "null"/>
		<cfset var _name = arguments.name/>

		<cfset result.abort = false/>
		<cfset result.success = false/>
		<cfset result.message = createObject("component", "Message").init()/>

		<cfif getAddress().isDottedQuad(arguments.name)>
			<cfset _name = getReverseMap().fromAddress(_name).toString()/>
		<cfelseif right(_name, 1) neq ".">
			<cfset _name = _name & "."/>
		</cfif>

		<cftry>
			<cfset record = getRecord().newRecord(getName().fromString(_name), getType().value(arguments.type), getDClass().value(arguments.class))/>
			<cfset query = getMessage().newQuery(record)/>
			<cfset response = getResolver().send(query)/>
			<cfset result.message.setMessage(response)/>
			<cfset result.message.setXMLDoc(createMessageXML(response))/>
			<cfset result.success = true/>
			<cfcatch>
				<cfif arguments.throwOnError>
					<cfthrow type="DNSQueryException" message="#cfcatch.message#"/>
				<cfelse>
					<cfset result.abort = true/>
				</cfif>
			</cfcatch>
		</cftry>

		<cfreturn result.message/>
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

		<!--- TODO: use the dnsjava address instead --->
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

		<!--- TODO: use the dnsjava address instead --->
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


	<cffunction name="createMessageXML" returntype="any" access="private" output="false">
		<cfargument name="message" type="any" required="true"/>

		<cfset var xd = xmlNew(true)/>
		<cfset var ra = "null"/>
		<cfset var header = "null"/>
		<cfset var section = "null"/>
		<cfset var sections = "null"/>
		<cfset var record = "null"/>
		<cfset var records = "null"/>
		<cfset var type = ""/>
		<cfset var class = ""/>
		<cfset var i = 0/>
		<cfset var j = 0/>

		<cfset xd.xmlRoot = xmlElemNew(xd, "message")/>
		<cfset header = xmlElemNew(xd, "header")/>
		<cfset sections = xmlElemNew(xd, "sections")/>

		<cfloop from="1" to="4" index="i">
			<cfset ra = arguments.message.getSectionArray(javaCast("int", i - 1))/>
			<cfif arrayLen(ra) gt 0>
				<cfset section = xmlElemNew(xd, "section")/>
				<cfset section.xmlAttributes["id"] = getSection().string(javaCast("int", i - 1))/>
				<cfset section.xmlAttributes["name"] = getSection().longstring(javaCast("int", i - 1))/>
				<cfloop from="1" to="#arrayLen(ra)#" index="j">
					<cfset records = xmlElemNew(xd, "records")/>
					<cfset record = xmlElemNew(xd, "record")/>
					<cfif ra[j].getTTL() gt 0>
						<cfset record.xmlAttributes["ttl"] = ra[j].getTTL()/>
					</cfif>
					<cfset type = getType().string(ra[j].getType())/>
					<cfset class = getDClass().string(ra[j].getDClass())/>
					<cfset record.xmlAttributes["type"] = type/>
					<cfset record.xmlAttributes["class"] = class/>
					<cfset record.xmlAttributes["name"] = ra[j].getName()/>
					<cfif ra[j].getAdditionalName() neq "">
						<cfset record.xmlAttributes["additionalName"] = ra[j].getAdditionalName()/>
					</cfif>
					<cfif i gt 1>
						<cfif type eq "SOA">
							<cfset record.xmlAttributes["admin"] = ra[j].getAdmin()/>
							<cfset record.xmlAttributes["expire"] = ra[j].getExpire()/>
							<cfset record.xmlAttributes["host"] = ra[j].getHost()/>
							<cfset record.xmlAttributes["minimum"] = ra[j].getMinimum()/>
							<cfset record.xmlAttributes["refresh"] = ra[j].getRefresh()/>
							<cfset record.xmlAttributes["retry"] = ra[j].getRetry()/>
							<cfset record.xmlAttributes["serial"] = ra[j].getSerial()/>
						</cfif>
						<cfif type eq "MX">
							<cfset record.xmlAttributes["priority"] = ra[j].getPriority()/>
							<cfset record.xmlAttributes["target"] = ra[j].getTarget()/>
						</cfif>
						<cfif type eq "NS" or type eq "PTR">
							<cfset record.xmlAttributes["target"] = ra[j].getTarget()/>
						</cfif>
						<cfif type eq "A">
							<cfset record.xmlAttributes["address"] = ra[j].getAddress().getHostAddress()/>
						</cfif>
						<cfif type eq "CNAME">
							<cfset record.xmlAttributes["alias"] = ra[j].getAlias()/>
							<cfset record.xmlAttributes["target"] = ra[j].getTarget()/>
						</cfif>
					</cfif>

					<cfset records.xmlChildren[j] = record/>
					<cfset arrayAppend(section.xmlChildren, records)/>
					<cfset sections.xmlChildren[i] = section/>
				</cfloop>
			</cfif>
		</cfloop>

		<cfset arrayAppend(xd.xmlRoot.xmlChildren, header)/>
		<cfset arrayAppend(xd.xmlRoot.xmlChildren, sections)/>
		<cfreturn xd/>
	</cffunction>

	<cffunction name="getResolver" returntype="any" access="private" output="false">
		<cfset var resolver = "null"/>

		<cfif getResolverProperty("servers") neq "">
			<cfset resolver = getJavaLoader().create("org.xbill.DNS.ExtendedResolver").init(getResolverProperty("servers").split(","))/>
		<cfelse>
			<cfset resolver = getJavaLoader().create("org.xbill.DNS.ExtendedResolver")/>
		</cfif>
		<cfif getResolverProperty("timeout", 0) gt 0>
			<cfset resolver.setTimeout(javaCast("int", getResolverProperty("timeout")))/>
		</cfif>
		<cfif getResolverProperty("retries", 0) gt 0>
			<cfset resolver.setRetries(javaCast("int", getResolverProperty("retries")))/>
		</cfif>
		<cfif getResolverProperty("port", 0) gt 0>
			<cfset resolver.setPort(javaCast("int", getResolverProperty("port")))/>
		</cfif>
		<cfif getResolverProperty("tcp", false) eq true>
			<cfset resolver.setTCP(javaCast("boolean", getResolverProperty("tcp")))/>
		</cfif>
		<cfreturn resolver/>
	</cffunction>

	<cffunction name="getResolverProperty" returntype="any" access="public" output="false">
		<cfargument name="property" type="string" required="true"/>
		<cfargument name="default" type="any" required="false" default=""/>

		<cfset var rp = getResolverProperties()/>

		<cfif structKeyExists(rp, arguments.property)>
			<cfreturn rp[arguments.property]/>
		<cfelse>
			<cfreturn arguments.default/>
		</cfif>
	</cffunction>
	<cffunction name="setResolverProperty" returntype="void" access="public" output="false">
		<cfargument name="property" type="string" required="true"/>
		<cfargument name="value" type="any" required="true"/>

		<cfset var rp = getResolverProperties()/>

		<cfif structKeyExists(rp, arguments.property)>
			<cfset structUpdate(rp, arguments.property, arguments.value)/>
		<cfelse>
			<cfset structInsert(rp, arguments.property, arguments.value)/>
		</cfif>
	</cffunction>

	<cffunction name="getResolverProperties" returntype="struct" access="private" output="false">
		<cfreturn variables.resolverProperties/>
	</cffunction>
	<cffunction name="setResolverProperties" returntype="void" access="private" output="false">
		<cfargument name="resolverProperties" type="struct" required="true"/>
		<cfset variables.resolverProperties = arguments.resolverProperties/>
	</cffunction>


	<!--- Private Methods --->
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

	<cffunction name="getSection" returntype="any" access="private" output="false">
		<cfreturn variables.section/>
	</cffunction>
	<cffunction name="setSection" returntype="void" access="private" output="false">
		<cfargument name="section" type="any" required="true"/>
		<cfset variables.section = arguments.section/>
	</cffunction>

	<cffunction name="getHeader" returntype="any" access="private" output="false">
		<cfreturn variables.header/>
	</cffunction>
	<cffunction name="setHeader" returntype="void" access="private" output="false">
		<cfargument name="header" type="any" required="true"/>
		<cfset variables.header = arguments.header/>
	</cffunction>

	<cffunction name="getRecord" returntype="any" access="private" output="false">
		<cfreturn variables.record/>
	</cffunction>
	<cffunction name="setRecord" returntype="void" access="private" output="false">
		<cfargument name="record" type="any" required="true"/>
		<cfset variables.record = arguments.record/>
	</cffunction>

	<cffunction name="getFlags" returntype="any" access="private" output="false">
		<cfreturn variables.flags/>
	</cffunction>
	<cffunction name="setFlags" returntype="void" access="private" output="false">
		<cfargument name="flags" type="any" required="true"/>
		<cfset variables.flags = arguments.flags/>
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