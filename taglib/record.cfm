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
<cfsilent>

	<cfparam name="attributes.record" type="any" default=""/>
	<cfparam name="attributes.display" type="string" default="name"/>

	<cfif isSimpleValue(attributes.record)>
		<cfexit/>
	<cfelseif listFindNoCase("ttl,name,type,class,data", attributes.display) eq 0>
		<cfexit/>
	</cfif>

	<cfset formatter = createObject("component", "cfdns.util.Formatter").init()/>
</cfsilent>
<cfif thisTag.executionMode eq "start">
	<cfif attributes.display eq "ttl">
		<cfoutput>#attributes.record.xmlAttributes["ttl"]#s (#formatter.getFormattedTime(attributes.record.xmlAttributes["ttl"])#)</cfoutput>
	<cfelseif attributes.display eq "name">
		<cfoutput>#attributes.record.xmlAttributes["name"]#</cfoutput>
	<cfelseif attributes.display eq "type">
		<cfoutput>#attributes.record.xmlAttributes["type"]#</cfoutput>
	<cfelseif attributes.display eq "class">
		<cfoutput>#attributes.record.xmlAttributes["class"]#</cfoutput>
	<cfelseif attributes.display eq "data">
		<cfif attributes.record.xmlAttributes["type"] eq "A">
			<cfoutput>#attributes.record.xmlAttributes["address"]#</cfoutput>
		<cfelseif attributes.record.xmlAttributes["type"] eq "SOA">
			<cfoutput>#attributes.record.xmlAttributes["host"]# - #attributes.record.xmlAttributes["admin"]#; serial:#attributes.record.xmlAttributes["serial"]#; expire:#attributes.record.xmlAttributes["expire"]#; min TTL:#attributes.record.xmlAttributes["minimum"]#; refresh:#attributes.record.xmlAttributes["refresh"]#; retry:#attributes.record.xmlAttributes["retry"]#</cfoutput>
		<cfelseif attributes.record.xmlAttributes["type"] eq "NS">
			<cfoutput>#attributes.record.xmlAttributes["target"]# <cfif attributes.record.xmlAttributes["target"] neq attributes.record.xmlAttributes["additionalName"]>#attributes.record.xmlAttributes["additionalName"]#</cfif></cfoutput>
		<cfelseif attributes.record.xmlAttributes["type"] eq "CNAME">
			<cfoutput>#attributes.record.xmlAttributes["alias"]# <cfif attributes.record.xmlAttributes["alias"] neq attributes.record.xmlAttributes["target"]>#attributes.record.xmlAttributes["target"]#</cfif></cfoutput>
		<cfelseif attributes.record.xmlAttributes["type"] eq "MX">
			<cfoutput>#attributes.record.xmlAttributes["target"]# (#attributes.record.xmlAttributes["priority"]#)</cfoutput>
		</cfif>
	</cfif>
<cfelse>
</cfif>