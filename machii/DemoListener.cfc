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
		<cfset var vm = getProperty("serviceFactory").getBean("validationMessages")/>
		<cfset var queryArgs = structNew()/>

		<!--- Structure returned for view --->
		<cfset result.abort = false/>
		<cfset result.success = false/>
		<cfset result.validationMessages = vm/>
		<cfset result.errorMessage = ""/>
		<cfset result.response = "null"/>

		<!--- Gather arguments for query --->
		<cfset gatherQueryArgs(arguments.event, queryArgs)/>

		<!--- Validate arguments --->
		<cfset validateQueryArgs(queryArgs, vm)/>
		<cfif vm.hasMessages()>
			<cfset result.abort = true/>
		</cfif>

		<cfif not result.abort>
			<cftry>
				<cfset dns.setResolverProperty("servers", queryArgs.server)/>
				<cfif queryArgs.tcp>
					<cfset dns.setResolverProperty("tcp", queryArgs.tcp)/>
				</cfif>
				<cfset dns.setResolverProperty("port", queryArgs.port)/>
				<cfset dns.setResolverProperty("retries", queryArgs.retries)/>
				<cfset dns.setResolverProperty("timeout", queryArgs.timeout)/>
				<cfset result.response = dns.doQuery(queryArgs.name, queryArgs.type, queryArgs.class, true)/>
				<cfset result.success = true/>
				<cfcatch>
					<cfset result.abort = true/>
					<cfset result.errorMessage = "Error Message: " & cfcatch.message/>
				</cfcatch>
			</cftry>
		</cfif>
		<cfreturn result/>
	</cffunction>
	
	<cffunction name="processDataRequest" returntype="struct" access="public" output="false">
		<cfargument name="event" type="MachII.framework.Event" required="true"/>

		<cfset var result = "null"/>
		
		<cfset result = processQueryForm(arguments.event)/>
		<cfreturn result/>
	</cffunction>
	
	<cffunction name="gatherQueryArgs" returntype="void" access="private" output="false">
		<cfargument name="event" type="any" required="true"/>
		<cfargument name="queryArgs" type="struct" required="true"/>
		
		<!--- Accommodate empty or missing arguments by setting defaults --->
		<cfset arguments.queryArgs.name = arguments.event.getArg("name")/>
		<cfset arguments.queryArgs.type = arguments.event.getArg("type", "ANY")/>
		<cfset arguments.queryArgs.class = arguments.event.getArg("class", "IN")/>
		<cfset arguments.queryArgs.timeout = arguments.event.getArg("timeout", 10)/>
		<cfset arguments.queryArgs.retries = arguments.event.getArg("retries", 3)/>
		<cfset arguments.queryArgs.server = arguments.event.getArg("server")/>
		<cfset arguments.queryArgs.port = arguments.event.getArg("port", 53)/>
		<cfset arguments.queryArgs.tcp = iif(arguments.event.isArgDefined("tcp"), true, false)/>
		<cfset arguments.queryArgs.rawMessage = iif(arguments.event.isArgDefined("rawMessage"), true, false)/>
	</cffunction>
	
	<cffunction name="validateQueryArgs" returntype="void" access="private" output="false">
		<cfargument name="args" type="struct" required="true"/>
		<cfargument name="vm" type="any" required="true"/>
	
		<cfif arguments.args.name eq "" or reFindNoCase("^[-a-z0-9\.]+$", arguments.args.name) eq 0>
			<cfset arguments.vm.add("name", "Please enter a name, such as company.com or 1.2.3.4")/>
		</cfif>
		<cfif arguments.args.type eq "">
			<cfset arguments.vm.add("type", "Please choose a record type.")/>
		</cfif>
		<cfif arguments.args.class eq "">
			<cfset arguments.vm.add("class", "Please choose a record class.")/>
		</cfif>
		<cfif arguments.args.server neq "" and reFindNoCase("^[-a-z0-9\.]+$", arguments.args.server) neq 1>
			<cfset arguments.vm.add("server", "Please enter a server host name or IP address, such as ns1.company.com")/>
		</cfif>
		<cfif not isNumeric(arguments.args.timeout) or arguments.args.timeout lte 0 or arguments.args.timeout gt 30>
			<cfset arguments.vm.add("timeout", "Please enter the timeout as a number of seconds between 1 and 30")/>
		</cfif>
		<cfif not isNumeric(arguments.args.retries) or arguments.args.retries lte 0 or arguments.args.retries gt 10>
			<cfset arguments.vm.add("timeout", "Please enter the number of retires between 1 and 10")/>
		</cfif>
		<cfif not isNumeric(arguments.args.port) or arguments.args.port lte 0 or arguments.args.port gt 65535>
			<cfset arguments.vm.add("port", "Please enter a numeric port number between 0 and 65535")/>
		</cfif>

	</cffunction>
</cfcomponent>