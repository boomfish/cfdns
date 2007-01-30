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
		<cfoutput>#attributes.record.getTTL()#s (#formatter.getFormattedTime(attributes.record.getTTL())#)</cfoutput>
	<cfelseif attributes.display eq "name">
		<cfoutput>#attributes.record.getName()#</cfoutput>
	<cfelseif attributes.display eq "type">
		<cfoutput>#attributes.record.getDNSType()#</cfoutput>
	<cfelseif attributes.display eq "class">
		<cfoutput>#attributes.record.getDNSClass()#</cfoutput>
	<cfelseif attributes.display eq "data">
		<cfif attributes.record.getDNSType() eq "A">
			<cfoutput>#attributes.record.getAddress()#</cfoutput>
		<cfelseif attributes.record.getDNSType() eq "SOA">
			<cfoutput>#attributes.record.getHost()# - #attributes.record.getAdmin()#; serial:#attributes.record.getSerial()#; expire:#attributes.record.getExpire()#; min TTL:#attributes.record.getMinimum()#; refresh:#attributes.record.getRefresh()#; retry:#attributes.record.getRetry()#</cfoutput>
		<cfelseif attributes.record.getDNSType() eq "NS">
			<cfoutput>#attributes.record.getTarget()# <cfif attributes.record.getTarget() neq attributes.record.getAdditionalName()>#attributes.record.getAdditionalName()#</cfif></cfoutput>
		<cfelseif attributes.record.getDNSType() eq "CNAME">
			<cfoutput>#attributes.record.getAlias()# <cfif attributes.record.getAlias() neq attributes.record.getTarget()>#attributes.record.getTarget()#</cfif></cfoutput>
		<cfelseif attributes.record.getDNSType() eq "MX">
			<cfoutput>#attributes.record.getTarget()# (#attributes.record.getPriority()#)</cfoutput>
		<cfelse>
			<cfoutput>#attributes.record.getName()#</cfoutput>
		</cfif>
	</cfif>
<cfelse>
</cfif>