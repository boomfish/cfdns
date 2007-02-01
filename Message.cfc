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

	<cffunction name="init" returntype="Message" access="public" output="false">
		<cfargument name="message" type="any" required="false"/>
		<cfargument name="xmldoc" type="any" required="false"/>

		<cfif structKeyExists(arguments, "message")>
			<cfset setMessage(arguments.message)/>
		</cfif>
		<cfif structKeyExists(arguments, "xmldoc")>
			<cfset setXMLDoc(arguments.xmldoc)/>
		</cfif>

		<cfreturn this/>
	</cffunction>

	<cffunction name="getXML" returntype="string" access="public" output="false">
		<cfreturn xmlTransform(getXMLDoc(), getXSL())/>
	</cffunction>

	<!--- Public Methods --->
	<cffunction name="getXMLDoc" returntype="any" access="public" output="false">
		<cfreturn variables.xmldoc/>
	</cffunction>
	<cffunction name="setXMLDoc" returntype="void" access="public" output="false">
		<cfargument name="xmldoc" type="any" required="true"/>
		<cfset variables.xmldoc = arguments.xmldoc/>
	</cffunction>

	<cffunction name="getMessage" returntype="any" access="public" output="false">
		<cfreturn variables.message/>
	</cffunction>
	<cffunction name="setMessage" returntype="void" access="public" output="false">
		<cfargument name="message" type="any" required="true"/>
		<cfset variables.message = arguments.message/>
	</cffunction>

	<!--- Private Methods --->
	<cffunction name="getXSL" returntype="string" access="private">
		<cfset var xsl = ""/>

		<cfsavecontent variable="xsl">
		<cfoutput>
			<?xml version="1.0" encoding="UTF-8"?>
			<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xalan="http://xml.apache.org/xalan" version="1.0">
			<xsl:output indent="yes" method="xml" xalan:indent-amount="4"/>
			<xsl:template match="/">
				<xsl:copy-of select="."/>
			</xsl:template>
			</xsl:stylesheet>
		</cfoutput>
		</cfsavecontent>
		<cfset xsl = reReplace(xsl, "^\s*", "")/>
		<cfreturn xsl/>
	</cffunction>
</cfcomponent>