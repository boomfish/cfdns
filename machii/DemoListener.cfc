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

<cfcomponent extends="MachII.framework.Listener">

	<cfset variables.queryTypes = arrayNew(1)/>
	<cfset arrayAppend(variables.queryTypes, listToArray("ANY,Any"))/>
	<cfset arrayAppend(variables.queryTypes, listToArray("A,Address (A)"))/>
	<cfset arrayAppend(variables.queryTypes, listToArray("IPSECKEY,IPSEC Key"))/>
	<cfset arrayAppend(variables.queryTypes, listToArray("LOC,Location"))/>
	<cfset arrayAppend(variables.queryTypes, listToArray("MX,Mail Exchanger (MX)"))/>
	<cfset arrayAppend(variables.queryTypes, listToArray("NS,Name Server (NS)"))/>
	<cfset arrayAppend(variables.queryTypes, listToArray("PTR,Pointer Record (PTR)"))/>
	<cfset arrayAppend(variables.queryTypes, listToArray("SIG,Signature"))/>
	<cfset arrayAppend(variables.queryTypes, listToArray("SOA,Start of Authority (SOA)"))/>
	<cfset arrayAppend(variables.queryTypes, listToArray("SPF,Sender Policy Framework"))/>
	<cfset arrayAppend(variables.queryTypes, listToArray("SSHFP,SSH Key Fingerprint"))/>
	<cfset arrayAppend(variables.queryTypes, listToArray("TXT,Text"))/>

	<cfset variables.queryClasses = arrayNew(1)/>
	<cfset arrayAppend(variables.queryClasses, listToArray("ANY,Any"))/>
	<cfset arrayAppend(variables.queryClasses, listToArray("IN,Internet (IN)"))/>
	<cfset arrayAppend(variables.queryClasses, listToArray("CH,Chaos (CH)"))/>
	<cfset arrayAppend(variables.queryClasses, listToArray("CHAOS,Chaos (CHAOS)"))/>
	<cfset arrayAppend(variables.queryClasses, listToArray("HS,Hesiod (HS)"))/>
	<cfset arrayAppend(variables.queryClasses, listToArray("HESIOD,Hesiod (HESIOD)"))/>

	<cffunction name="configure" access="public" returntype="void" output="false">
	</cffunction>

	<cffunction name="getQueryTypes" returntype="array" access="public" output="false">
		<cfreturn variables.queryTypes/>
	</cffunction>

	<cffunction name="getQueryClasses" returntype="array" access="public" output="false">
		<cfreturn variables.queryClasses/>
	</cffunction>

	<cffunction name="processQueryForm" access="public" returntype="struct" output="false">
		<cfargument name="event" type="MachII.framework.Event" required="true"/>

		<cfset var result = structNew()/>
		<cfset var dns = getProperty("serviceFactory").getBean("DNS")/>
		<cfset var servers = arguments.event.getArg("server")/>

		<cfset result.abort = false/>
		<cfset result.success = false/>
		<cfset result.message = ""/>
		<cfset result.sections = arrayNew(1)/>

		<cfif arguments.event.getArg("name") eq "">
			<cfset result.abort = true/>
			<cfset result.message = "Please enter a name, such as company.com or 1.2.3.4"/>
		<cfelseif servers neq "" and reFindNoCase("^[-a-z0-9\.]+$", servers) neq 1>
			<cfset result.abort = true/>
			<cfset result.message = "Please enter a server host name or IP address, such as ns1.company.com"/>
		<cfelseif not isNumeric(arguments.event.getArg("timeout")) or arguments.event.getArg("timeout") gt 60>
			<cfset result.abort = true/>
			<cfset result.message = "Please enter the timeout as a number of seconds between 1 and 60"/>
		<cfelseif not isNumeric(arguments.event.getArg("retries")) or arguments.event.getArg("retries") gt 10>
			<cfset result.abort = true/>
			<cfset result.message = "Please enter the retries as a number between 1 and 10"/>
		<cfelseif not isNumeric(arguments.event.getArg("port"))>
			<cfset result.abort = true/>
			<cfset result.message = "Please enter a numeric port number between 0 and 65535"/>
		</cfif>

		<cfif not result.abort>
			<cftry>
				<cfset dns.setResolverProperty("servers", servers)/>
				<cfif arguments.event.isArgDefined("tcp")>
					<cfset dns.setResolverProperty("tcp", true)/>
				</cfif>
				<cfif arguments.event.getArg("port", 53)>
					<cfset dns.setResolverProperty("port", arguments.event.getArg("port"))/>
				</cfif>
				<cfset result.response = dns.doQuery(arguments.event.getArg("name"), arguments.event.getArg("type"), arguments.event.getArg("class"), true)/>
				<cfset result.success = true/>
				<cfcatch>
					<cfset result.abort = true/>
					<cfset result.message = "Error Message: " & cfcatch.message/>
				</cfcatch>
			</cftry>
		</cfif>
		<cfreturn result/>
	</cffunction>

</cfcomponent>