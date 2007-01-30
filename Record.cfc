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

	<cffunction name="init" returntype="Record" access="public" output="false">
		<cfargument name="dns" type="DNS" required="true"/>
		<cfargument name="record" type="any" required="true"/>

		<cfset setDNS(arguments.dns)/>
		<cfset setRecord(arguments.record)/>
		<cfreturn this/>
	</cffunction>

	<!--- Public Methods --->
	<cffunction name="getDNSType" returntype="string" access="public" output="false">
		<cfreturn getDNS().getConstantName("DNSType", getRecord().getType())/>
	</cffunction>
	<cffunction name="getDNSClass" returntype="string" access="public" output="false">
		<cfreturn getDNS().getConstantName("DNSClass", getRecord().getDClass())/>
	</cffunction>
	<cffunction name="getTTL" returntype="numeric" access="public" output="false">
		<cfreturn getRecord().getTTL()/>
	</cffunction>
	<cffunction name="getName" returntype="string" access="public" output="false">
		<cfreturn getRecord().getName()/>
	</cffunction>
	<cffunction name="getAdditionalName" returntype="string" access="public" output="false">
		<cfreturn getRecord().getAdditionalName()/>
	</cffunction>
	<cffunction name="getAddress" returntype="string" access="public" output="false">
		<cfreturn getRecord().getAddress()/>
	</cffunction>
	<cffunction name="getTarget" returntype="string" access="public" output="false">
		<cfreturn getRecord().getTarget()/>
	</cffunction>
	<cffunction name="getAlias" returntype="string" access="public" output="false">
		<cfreturn getRecord().getAlias()/>
	</cffunction>
	<cffunction name="getHost" returntype="string" access="public" output="false">
		<cfreturn getRecord().getHost()/>
	</cffunction>
	<cffunction name="getAdmin" returntype="string" access="public" output="false">
		<cfreturn getRecord().getAdmin()/>
	</cffunction>
	<cffunction name="getPriority" returntype="numeric" access="public" output="false">
		<cfreturn getRecord().getPriority()/>
	</cffunction>
	<cffunction name="getSerial" returntype="numeric" access="public" output="false">
		<cfreturn getRecord().getSerial()/>
	</cffunction>
	<cffunction name="getExpire" returntype="numeric" access="public" output="false">
		<cfreturn getRecord().getExpire()/>
	</cffunction>
	<cffunction name="getMinimum" returntype="numeric" access="public" output="false">
		<cfreturn getRecord().getMinimum()/>
	</cffunction>
	<cffunction name="getRefresh" returntype="numeric" access="public" output="false">
		<cfreturn getRecord().getRefresh()/>
	</cffunction>
	<cffunction name="getRetry" returntype="numeric" access="public" output="false">
		<cfreturn getRecord().getRetry()/>
	</cffunction>


	<!--- Private Methods --->
	<cffunction name="getDNS" returntype="any" access="private" output="false">
		<cfreturn variables.dns/>
	</cffunction>
	<cffunction name="setDNS" returntype="void" access="private" output="false">
		<cfargument name="dns" type="any" required="true"/>
		<cfset variables.dns = arguments.dns/>
	</cffunction>

	<cffunction name="getRecord" returntype="any" access="private" output="false">
		<cfreturn variables.record/>
	</cffunction>
	<cffunction name="setRecord" returntype="void" access="private" output="false">
		<cfargument name="record" type="any" required="true"/>
		<cfset variables.record = arguments.record/>
	</cffunction>

</cfcomponent>