<%@ page language="java" import="utility.*, java.util.Calendar" %>
<% 
String[] strColorScheme = CommonUtil.getColorScheme(7);
WebInterface WI = new WebInterface(request);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
 
	.txtbox_noborder {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		text-align:right;
		border: 0; 
	}
</style>

</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
<!--
	function ViewRecords(){
		document.form_.submit();
	} 
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%
	String strTime1 = WI.fillTextValue("val1");	
	String strTime2 = WI.fillTextValue("val2");	
	
	Calendar calTemp = Calendar.getInstance();
	if(strTime1.length() > 0){
		calTemp.setTimeInMillis(Long.parseLong(strTime1));
		strTime1 = ConversionTable.convertYYYYMMDDHHMMSS(calTemp.getTime());
	}

	if(strTime2.length() > 0){
		calTemp.setTimeInMillis(Long.parseLong(strTime2));
		strTime2 = ConversionTable.convertYYYYMMDDHHMMSS(calTemp.getTime());
	}
%>
<form action="./util_convert_long.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        UTILITY - LONG DATE TO SMALL DATE::::</strong></font></td>
    </tr>
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
  </table>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td width="7%" height="25">&nbsp;</td>
      <td width="10%">Time 1 </td>
      <td width="20%"><input name="val1" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyInteger('form_','val1')" value="<%=WI.fillTextValue("val1")%>" size="16" maxlength="16" 
			onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','val1')"></td>
      <td width="63%"><%=WI.getStrValue(strTime1)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Time 2 </td>
      <td><input name="val2" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			onKeyUp="AllowOnlyInteger('form_','val2')" value="<%=WI.fillTextValue("val2")%>" size="16" maxlength="16" 
			onBlur="style.backgroundColor='white';AllowOnlyInteger('form_','val2')"></td>
      <td><%=WI.getStrValue(strTime2)%></td>
    </tr>
  </table>
   <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">
			<a href="javascript:ViewRecords()">
			<img src="../../../images/online_help.gif" width="34" height="26" border="0">
			</a></td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>