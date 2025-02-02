<%if(request.getSession(false).getAttribute("is_sap") == null) {%>
	<p style="font-family:Verdana, Arial, Helvetica, sans-serif; font-weight:bold; font-size:18px; color:#FF0000">You are not authorized to view this link. </p>
	<%return;

}%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.submit();
}
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;

	document.form_.submit();
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,sap.Configuration,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation();

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
Vector vRetResult  = null;

Configuration conf = new Configuration();
strTemp = WI.getStrValue(WI.fillTextValue("page_action"), "4");
vRetResult = conf.setSYTermSAP(dbOP, request, Integer.parseInt(strTemp));
strErrMsg = conf.getErrMsg();
%>


<form name="form_" action="./set_sy_term.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: SET DEFAULT SY-TERM ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="2%" height="28">&nbsp;</td>
      <td colspan="4"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td width="12%">School Year : </td>
      <td colspan="3"> 
<%
strTemp = WI.getStrValue((String)vRetResult.elementAt(0));
%> 
<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        -
<%
strTemp = WI.getStrValue((String)vRetResult.elementAt(1));
%> 
 <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; 
		<select name="semester">
<%
strTemp = WI.getStrValue((String)vRetResult.elementAt(2));
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
<%}else{%>
          <option value="0">Summer</option>
<%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Term</option>
<%}else{%>
          <option value="1">1st Term</option>
<%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Term</option>
<%}else{%>
          <option value="2">2nd Term</option>
<%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Term</option>
<%}else{%>
          <option value="3">3rd Term</option>
<%}%>
        </select>
		
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
Term Type: 		
		<select name="is_tri">
<%
strTemp = WI.getStrValue((String)vRetResult.elementAt(3));
if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Semestral</option>
<%}else{%>
          <option value="0">Semestral</option>
<%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>Trimester</option>
<%}else{%>
          <option value="1">Trimester</option>
<%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>Annual (for HS)</option>
<%}else{%>
          <option value="2">Annual (for HS)</option>
<%}%>
        </select>		</td>
    </tr>
    <tr>
      <td height="44">&nbsp;</td>
      <td align="center">&nbsp;</td>
      <td width="38%" align="center"><input type="submit" name="122" value="Update SY-Term" style="font-size:11px; height:24px;border: 1px solid #FF0000;" 
		  onClick="document.form_.page_action.value='2';"></td>
      <td width="41%" align="center">&nbsp;</td>
      <td width="7%" align="center">&nbsp;</td>
    </tr>
  </table>
<%}%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
