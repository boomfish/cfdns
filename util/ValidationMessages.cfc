<cfcomponent>

	<cfset variables.fieldOrder = ""/>
	<cfset variables.messages = structNew()/>

	<cffunction name="init" access="public" returntype="ValidationMessages" output="false">
		<cfreturn this />
	</cffunction>

	<cffunction name="add" access="public" returntype="void" output="false">
		<cfargument name="fieldName" type="string" required="true" />
		<cfargument name="validationMessage" type="string" required="true" />
		
		<cfif structKeyExists(variables.messages, arguments.fieldName)>
			<cfset structDelete(variables.messages, arguments.fieldName) />
			<cfset variables.fieldOrder = listDeleteAt(variables.fieldOrder, listFindNoCase(variables.fieldOrder, arguments.fieldName)) />
		</cfif>
		<cfset structInsert(variables.messages, arguments.fieldName, arguments.validationMessage) />
		<cfset variables.fieldOrder = listAppend(variables.fieldOrder, arguments.fieldName) />
	</cffunction>
	
	<cffunction name="getFieldNames" access="public" returntype="string" output="false">
		<cfreturn variables.fieldOrder />
	</cffunction>
	
	<cffunction name="hasMessages" access="public" returntype="boolean" output="false">
		<cfif structCount(variables.messages) gt 0>
			<cfreturn true />
		<cfelse>
			<cfreturn false />
		</cfif>
	</cffunction>
	
	<cffunction name="getMessageCount" access="public" returntype="numeric" output="false">
		<cfreturn structCount(variables.messages) />
	</cffunction>

	<cffunction name="getMessageByIndex" access="public" returntype="string" output="false">
		<cfargument name="index" required="yes" type="numeric" />

		<cfset var keyList = structKeyList(variables.messages) />
		<cfset var keyCount = listLen(keyList) />
		<cfset var result = "" />
		
		<cfif keyCount lte arguments.index>
			<cfset result = variables.messages[listGetAt(keyList, arguments.index)] />
		</cfif>
		<cfreturn result />
	</cffunction>
	
	<cffunction name="getMessageByField" access="public" returntype="string" output="false">
		<cfargument name="fieldName" required="yes" type="string" />

		<cfset var result = "" />
		
		<cfif structKeyExists(variables.messages, arguments.fieldName)>
			<cfset result = variables.messages[arguments.fieldName] />
		</cfif>
		<cfreturn result />
	</cffunction>

	<cffunction name="hasMessageByField" access="public" returntype="string" output="false">
		<cfargument name="fieldName" required="yes" type="string" />

		<cfreturn structKeyExists(variables.messages, arguments.fieldName) />
	</cffunction>

	<cffunction name="clear" access="public" returntype="void" output="false">
		<cfset variables.messages = structNew() />
	</cffunction>

	<cffunction name="append" access="public" returntype="void" output="false">
		<cfargument name="validationMessages" type="ValidationMessages" required="true" />
		
		<cfset var fieldName = ""/>
		<cfset var validationMessage = ""/>
		
		<cfloop list="#arguments.validationMessages.getFieldNames()#" index="fieldName">
			<cfset validationMessage = arguments.validationMessages.getMessageByField(fieldName)/>
			<cfset add(fieldName, validationMessage)/>
		</cfloop>
	</cffunction>
	
</cfcomponent>