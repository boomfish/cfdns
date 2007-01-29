<cfsilent>

	<cfparam name="attributes.record" type="any" default=""/>
	<cfparam name="attributes.display" type="string" default="name"/>

	<cfif isSimpleValue(attributes.record)>
		<cfexit/>
	<cfelseif listFindNoCase("ttl,info", attributes.display) eq 0>
		<cfexit/>
	</cfif>

	<cffunction name="formattedTime" returntype="string">
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

</cfsilent>
<cfif thisTag.executionMode eq "start">
	<cfif attributes.display eq "ttl">
		<cfoutput>#formattedTime(attributes.record.getTTL())#</cfoutput>
	<cfelseif attributes.display eq "info">
		<cfif attributes.record.getType() eq 6>
			<cfoutput>NS #attributes.record.getHost()# - #attributes.record.getAdmin()#; serial:#attributes.record.getSerial()#; expire:#attributes.record.getExpire()#; min TTL:#attributes.record.getMinimum()#; refresh:#attributes.record.getRefresh()#; retry:#attributes.record.getRetry()#</cfoutput>
		<cfelseif attributes.record.getType() eq 15>
			<cfoutput>#attributes.record.getTarget()# (#attributes.record.getPriority()#)</cfoutput>
		<cfelse>
			<cfoutput>#attributes.record.getName()#</cfoutput>
		</cfif>
	</cfif>
<cfelse>
</cfif>