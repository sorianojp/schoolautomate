<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<head>
<title>Conversion Table</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function ConvertToCM() {
	var FT   = document.form_.ft_.value;
	if(FT.length == 0)
		FT = 0;
	var INCH = document.form_.inch_.value;
	if(INCH.length == 0)
		INCH = 0;
	
	var vTotalInch = eval(FT) * 12 + eval(INCH);
	vTotalInch = Math.round(eval(vTotalInch) * 2.54);
	document.form_.convert_ft_to_cm.value = vTotalInch;
}
function ConvertToKG() {
	var KG   = document.form_.kg_.value;
	if(KG.length == 0)
		KG = 0;
	
	var vTotalKG = Math.round(eval(KG) * 2.2);
	document.form_.convert_kg_to_lb.value = vTotalKG;
}
function Copy(strStatus) {
	if(document.form_.called_fr_form.value.length == 0) {
		alert("Not called from any form.");
		return;
	}
	var strValue;
	if(strStatus == 1) {
		strValue = document.form_.convert_ft_to_cm.value;
		eval('window.opener.document.'+document.form_.called_fr_form.value+'.'+
			document.form_.cm_field_name.value+'.value='+strValue);
	}
	else {	
		strValue = document.form_.convert_kg_to_lb.value;
		eval('window.opener.document.'+document.form_.called_fr_form.value+'.'+
			document.form_.lb_field_name.value+'.value='+strValue);
	}
	self.close();
}
</script>
<body bgcolor="#46689B">
<form method="post" name="form_" action="./conversion.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#004488"> 
      <td height="26" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: 
          CONVERSIONS MADE EASY ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFFF"> 
      <td height="26" colspan="4">&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFF00"> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="31%" height="25"><div align="center"><font size="1"><strong>CONVERT</strong></font></div></td>
      <td width="28%"><div align="center"><font size="1"><strong>RESULT</strong></font></div></td>
      <td width="38%"><div align="center"><font size="1"><strong>COPY</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25"><input name="ft_" type="text" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="ConvertToCM();">
        ft 
        <input name="inch_" type="text" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="ConvertToCM();">
        inch </td>
      <td><input type="text" class="textbox_noborder" name="convert_ft_to_cm" readonly="yes"
	  	size=10>
        cms</td>
      <td><a href="javascript:Copy(1);"><img src="../images/copy.gif" border="0"></a></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25"><input name="kg_" type="text" size="4" maxlength="4" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="ConvertToKG();">
        KGs </td>
      <td><input type="text" class="textbox_noborder" name="convert_kg_to_lb" readonly="yes"
	  size=10>
        lbs </td>
      <td><a href="javascript:Copy(2);"><img src="../images/copy.gif" border="0"></a></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
    </tr> 
    <tr bgcolor="#004488">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%@ page language="java" import="utility.*,enrollment.Advising,java.util.Vector " buffer="16kb"%>
<%
WebInterface WI = new WebInterface(request);
%>
 <input type="hidden" name="called_fr_form" value="<%=WI.fillTextValue("called_fr_form")%>">
 <input type="hidden" name="cm_field_name" value="<%=WI.fillTextValue("cm_field_name")%>">
 <input type="hidden" name="lb_field_name" value="<%=WI.fillTextValue("lb_field_name")%>">
</form>
</body>
</html>
