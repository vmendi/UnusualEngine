<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Silverlight_game.Web._Default" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" >
<head id="Head1" runat="server">
    <title>Damian &amp; Donny</title>
    <style type="text/css">
    html, body {
	    height: 100%;
	    overflow: auto;
    }
    #silverlightControlHost {
	    text-align:center;
	    width: 144px;
    }
    body
	{
		padding: 0;
		margin: 0;
		background-color: #f1f1f1;
	}
	#main_content
	{
		background-image: url('images/main.jpg');
		width: 916px;
		height: 882px;
		margin: auto;
		border-bottom: 1px solid #ccc;
	}
	#wrapper 
	{
		width: 100%;
		background-image: url('images/background.jpg');
		background-position: 50% 0%;
		background-repeat: repeat-y;
	}
	#silverlight_video
	{
		width: 320px;
		height: 240px;
		margin-top: 70px;
		margin-left: 280px;
	}
    </style>
    <script type="text/javascript" src="Silverlight.js"></script>
    <script type="text/javascript">
    	function SilverlightRun() {
			if (window.opener != null)
				window.opener.silverRun = true;
        }
        function onSilverlightError(sender, args) {
            var appSource = "";
            if (sender != null && sender != 0) {
              appSource = sender.getHost().Source;
            }
            
            var errorType = args.ErrorType;
            var iErrorCode = args.ErrorCode;

            if (errorType == "ImageError" || errorType == "MediaError") {
              return;
            }

            var errMsg = "Error no controlado en la aplicación de Silverlight " +  appSource + "\n" ;

            errMsg += "Código: "+ iErrorCode + "    \n";
            errMsg += "Categoría: " + errorType + "       \n";
            errMsg += "Mensaje: " + args.ErrorMessage + "     \n";

            if (errorType == "ParserError") {
                errMsg += "Archivo: " + args.xamlFile + "     \n";
                errMsg += "Línea: " + args.lineNumber + "     \n";
                errMsg += "Posición: " + args.charPosition + "     \n";
            }
            else if (errorType == "RuntimeError") {           
                if (args.lineNumber != 0) {
                    errMsg += "Línea: " + args.lineNumber + "     \n";
                    errMsg += "Posición: " +  args.charPosition + "     \n";
                }
                errMsg += "Nombre de método: " + args.methodName + "     \n";
            }

            throw new Error(errMsg);
        }
    </script>
</head>
<body>
	<div id="wrapper">
        <div id="main_content">&nbsp;
        	<div id="silverlight_video">
                <form id="form1" runat="server">
                <div id="silverlightControlHost">
                    <object data="data:application/x-silverlight-2," type="application/x-silverlight-2" width="320px" height="240px">
		              <param name="source" value="ClientBin/Silverlight_game.xap"/>
		              <param name="onError" value="onSilverlightError" />
		              <param name="background" value="white" />
		              <param name="minRuntimeVersion" value="3.0.40624.0" />
		              <param name="autoUpgrade" value="true" />
		              <a href="http://go.microsoft.com/fwlink/?LinkID=149156&v=3.0.40624.0" style="text-decoration:none">
 			              <img src="http://go.microsoft.com/fwlink/?LinkId=108181" alt="Get Microsoft Silverlight" style="border-style:none"/>
		              </a>
	                </object><iframe id="_sl_historyFrame" style="visibility:hidden;height:0px;width:0px;border:0px"></iframe></div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>
