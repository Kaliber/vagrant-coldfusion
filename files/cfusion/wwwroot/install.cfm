<cftry>
<cfscript> 
    // Login is always required. This example uses a single line of code. 
    createObject("component","cfide.adminapi.administrator").login("0000", "admin"); 
 
    // Instantiate the data source object. 
    
    /*     

    datasource = createObject("component","cfide.adminapi.datasource"); 
 
    stDSN = {
        driver = "MSSQLServer",
        name="",
        host = "",
        port = "1433",
        database = "",
        username = "",
        selectmethod = "direct",
        disable_blob = "NO",
        disable_clob = "NO",
        password = "",
        encryptpassword = true,
        pooling = "YES",
        sendStringParametersAsUnicode = "YES"
    };
 
    datasource.setMSSQL(argumentCollection=stDSN);  
    */

    /*
    extensions = createObject("component","cfide.adminapi.extensions"); 

    extensions.setCustomTagPath("xxxx");
    extensions.setMapping("/mapping", "/real/path");
    */

    runtime = createObject("component","cfide.adminapi.runtime"); 

    fonts_struct = runtime.getFonts();
    
    for (font in fonts_struct.userfonts)
    {
        for (fontspec in fonts_struct.userfonts[font])
        {
            fontfile = fonts_struct.userfonts[font][fontspec].location;
            runtime.deleteFont(fontfile);
        }
    }
    // Add MS core fonts such as "Arial".
    runtime.setFont("/usr/share/fonts/truetype/msttcorefonts/");
    runtime.setCacheProperty("TrustedCache", "NO");
    runtime.setCacheProperty("SaveClassFiles", "NO");
    runtime.setCacheProperty("ComponentCache", "NO");
    runtime.setCacheProperty("InRequestTemplateCache", "YES");
    
    runtime.setScopeProperty("enableJ2EESessions", "YES");
    
    runtime.setRuntimeProperty("PostParametersLimit", "1000");
    runtime.setRuntimeProperty("PostSizeLimit", "100");
    runtime.setRuntimeProperty("SecureSessionCookie", "NO");
    runtime.setRuntimeProperty("HttpOnlySessionCookie", "YES");
    runtime.setRuntimeProperty("CFInternalCookieDisableUpdate", "YES");

    debugging = createObject("component","cfide.adminapi.debugging"); 
    debugging.setDebugProperty("enableRobustExceptions", "YES");
    debugging.setIP("127.0.0.1,10.0.2.2");

    mail = createObject("component","cfide.adminapi.mail");
    mail.setMailServer("127.0.0.1");
    mail.setMailProperty("defaultPort", 25);
    mail.setMailProperty("enableSpool", "NO");
   

</cfscript> 

CF Admin settings: OK!

<cfmail to="logging@rhinofly.net" from="cf10@rhinofly.nl" subject="Testing e-mail settings" type="HTML">
    <html>
        <body>
            <h1>E-mail works!</h1>
        </body>
    </html>
</cfmail>

Test e-mail sent.


<cfcatch type="any">
<cfif cgi.HTTP_USER_AGENT contains "libcurl">
[[[<cfoutput>#cfcatch.message#</cfoutput>]]]
<cfelse>
<cfdump var="#cfcatch#" />
</cfif>
</cfcatch>
</cftry>
