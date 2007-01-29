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
	<cfset variables.className = ""/>
	<cfset variables.paths = arrayNew(1)/>

	<cffunction name="init" returntype="JavaLoaderFactory" access="public" output="false">
		<cfreturn this/>
	</cffunction>

	<cffunction name="configure" returntype="void" access="private" output="false">
		<cfset var javaLoader = "null"/>

		<cfinvoke component="#getClassName()#" method="init" returnvariable="javaLoader">
			<cfinvokeargument name="loadPaths" value="#getPaths()#"/>
		</cfinvoke>
		<cfset setJavaLoader(javaLoader)/>
	</cffunction>

	<cffunction name="addPath" returntype="void" access="public" output="false">
		<cfargument name="path" type="string" required="true"/>

		<cfset arrayAppend(variables.paths, arguments.path)/>
	</cffunction>
	<cffunction name="setPaths" returntype="void" access="public" output="false">
		<cfargument name="paths" type="array" required="true"/>
		<cfset variables.paths = arguments.paths>
	</cffunction>
	<cffunction name="getPaths" returntype="array" access="private" output="false">
		<cfreturn variables.paths/>
	</cffunction>

	<cffunction name="getJavaLoader" returntype="any" access="public" output="false">
		<cfif isSimpleValue(variables.javaLoader)>
			<cfset configure()/>
		</cfif>
		<cfreturn variables.javaLoader/>
	</cffunction>
	<cffunction name="setJavaLoader" returntype="void" access="private" output="false">
		<cfargument name="javaLoader" type="any" required="true"/>
		<cfset variables.javaLoader = arguments.javaLoader/>
	</cffunction>

	<cffunction name="getClassName" returntype="string" access="private" output="false">
		<cfreturn variables.className>
	</cffunction>
	<cffunction name="setClassName" returntype="void" access="public" output="false">
		<cfargument name="className" type="string" required="true">
		<cfset variables.className = arguments.className>
	</cffunction>
</cfcomponent>