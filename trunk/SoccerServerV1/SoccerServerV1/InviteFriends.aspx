<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="InviteFriends.aspx.cs" Inherits="SoccerServerV1.InviteFriends" %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://www.facebook.com/2008/fbml">
<head>
    <title></title>
</head>


<body style="margin:0px 0px 0px 0px;overflow:hidden;text-align:center;">
	
	<div style="margin-bottom:10px;">
		<img src="SoccerClientV1/Imgs/MainHeader.jpg" alt="" width="760" height="74" style="display:block;border:0;"></img>
	</div>

	<div id="fb-root"></div>

    <fb:serverFbml>
	    <script type="text/fbml">
		    <fb:fbml>
			    <fb:request-form
				    method="POST"
				    type="jugar a Mahou Liga Chapas"
				    action="http://mahouligachapas.unusualwonder.com"
				    content='¿ Te echas un partido conmigo? 
					    <fb:req-choice url="http://apps.facebook.com/mahouligachapas" label="Sí" />
					    <fb:req-choice url="http://www.facebook.com" label="No" />' 
                >
			        <fb:multi-friend-selector actiontext="Invita a tus amigos a jugar a Mahou Liga Chapas"/>
			    </fb:request-form>
		    </fb:fbml>
	    </script>
	</fb:serverFbml>

	<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4.3/jquery.min.js"></script>
	<script type="text/javascript" src="http://connect.facebook.net/es_ES/all.js"></script>

	<script type="text/javascript">
		$(document).ready(function () {
			FB.init({ appId: '129447350433277', status: true, cookie: true, xfbml: true });
		});

	</script>

</body>
</html>
