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
	<cffunction name="init" returntype="Formatter" access="public" output="false">
		<cfreturn this/>
	</cffunction>

	<cffunction name="getFormattedTime" returntype="string" access="public" output="false">
		<cfargument name="input" type="numeric" required="true"/>
		<cfargument name="verbose" type="boolean" required="true" default="false"/>

		<cfset var result = ""/>
		<cfset var remainder = arguments.input/>
		<cfset var parts = structNew()/>
		<cfset var names = structNew()/>

		<cfset parts.week = 0/>
		<cfset names.week = listToArray("week,w")/>
		<cfset parts.day = 0/>
		<cfset names.day = listToArray("day,d")/>
		<cfset parts.hour = 0/>
		<cfset names.hour = listToArray("hour,h")/>
		<cfset parts.minute = 0/>
		<cfset names.minute = listToArray("minute,m")/>
		<cfset parts.second = 0/>
		<cfset names.second = listToArray("second,s")/>

		<cfif remainder gte 604800>
			<cfset parts.week = int(remainder / 604800)/>
			<cfset remainder = remainder - (parts.week * 604800)/>
		</cfif>
		<cfif remainder gte 86400>
			<cfset parts.day = int(remainder / 86400)/>
			<cfset remainder = remainder - (parts.day * 86400)/>
		</cfif>
		<cfif remainder gte 3600>
			<cfset parts.hour = int(remainder / 3600)/>
			<cfset remainder = remainder - (parts.hour * 3600)/>
		</cfif>
		<cfif remainder gte 60>
			<cfset parts.minute = int(remainder / 60)/>
			<cfset remainder = remainder - (parts.minute * 60)/>
		</cfif>
		<cfif remainder gte 1>
			<cfset parts.second = remainder/>
		</cfif>

		<cfloop list="week,day,hour,minute,second" index="part">
			<cfif arguments.verbose>
				<cfif parts[part] eq 1>
					<cfset result = result & "#parts[part]# #names[part][1]# "/>
				<cfelseif parts[part] gt 1>
					<cfset result = result & "#parts[part]# #names[part][1]#s "/>
				</cfif>
			<cfelse>
				<cfif parts[part] gt 0>
					<cfset result = result & "#parts[part]##names[part][2]# "/>
				</cfif>
			</cfif>
		</cfloop>
		<cfreturn result/>
	</cffunction>
</cfcomponent>