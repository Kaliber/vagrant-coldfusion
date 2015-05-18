<cfscript>
	/*
	 * Easy PHP Tail 
	 * by: Thomas Depole
	 * v1.0
	 * 
	 * just fill in the varibles bellow, open in a web browser and tail away 
	 */
	param name="url.file" default="coldfusion-out.log";
	fileName = url.file;
	logFile = "/opt/coldfusion10/cfusion/logs/#fileName#"; // local path to log file
	interval = 1000; //how often it checks the log file for changes, min 100
	textColor = ""; //use CSS color

	// Don't have to change anything bellow
	if(!len(textColor)) textColor = "white";
	if(interval < 100) interval = 100;
</cfscript>

<cfif structKeyExists(url, "getLog")>
	<cfcontent file="#logfile#" />
<cfelse>

<html>
	<title>Log [<cfoutput>#fileName#</cfoutput>]</title>
	<style>
		@import url(http://fonts.googleapis.com/css?family=Ubuntu);
		body{
			background-color: black;
			color: <cfoutput>#textcolor#</cfoutput>;
			font-family: 'Ubuntu', sans-serif;
			font-size: 16px;
			line-height: 20px;	
		}
		h4{
			font-size: 18px;
			line-height: 22px;
			color: #353535;
		}
		#log {
			position: relative;
			top: -34px;
		}
		#scrollLock{
			width:2px;
			height: 2px;
			overflow:visible;
		}
	</style>
	<script src="//ajax.googleapis.com/ajax/libs/jquery/1.8.0/jquery.min.js" type="text/javascript"></script>
	<script>
		setInterval(readLogFile, <cfoutput>#interval#</cfoutput>);
		window.onload = readLogFile; 
		var pathname = window.location.pathname;
		var scrollLock = true;
		
		$(document).ready(function(){
			$('.disableScrollLock').click(function(){
				$("html,body").clearQueue()
				$(".disableScrollLock").hide();
				$(".enableScrollLock").show();
				scrollLock = false;
			});
			$('.enableScrollLock').click(function(){
				$("html,body").clearQueue()
				$(".enableScrollLock").hide();
				$(".disableScrollLock").show();
				scrollLock = true;
			});
		});
		function readLogFile(){
			$.get(pathname, { getLog : "true", file : "<cfoutput>#filename#</cfoutput>" }, function(data) {
				data = data.replace(new RegExp("\n", "g"), "<br />");
		        $("#log").html(data);
		        
		        if(scrollLock == true) { $('html,body').animate({scrollTop: $("#scrollLock").offset().top}, <cfoutput>#interval#</cfoutput>) };
		    });
		}
	</script>
	<body>
		<h4><cfoutput>#logfile#</cfoutput></h4>
		<div id="log">
			
		</div>
		<div id="scrollLock"> <input class="disableScrollLock" type="button" value="Disable Scroll Lock" /> <input class="enableScrollLock" style="display: none;" type="button" value="Enable Scroll Lock" /></div>
	</body>
</html>

</cfif>