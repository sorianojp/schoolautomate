<%
String strUserID = (String)request.getSession(false).getAttribute("userId");
if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}

//if(!strUserID.toLowerCase().equals("sa-01")){%>
	<!--
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are not allowed to access this link.</p>
	-->
<%//return;}%>

<%@ page language="java" import="utility.*,sms.SystemSetup,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex, strPageAction) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strPageAction;
	document.form_.submit();
}
function focusID() {
	document.form_.prefix.focus();
}
</script>

<body bgcolor="#D2AE72" onLoad="focusID();">
<%
	String strErrMsg = null;
	String strTemp = null;
	if (WI.fillTextValue("shift_page_basic").compareTo("1") == 0){
		response.sendRedirect(response.encodeRedirectURL("./srch_stud_basic.jsp?fs="+WI.fillTextValue("fs")));		
		return;
	}
// if this page is calling print page, i have to forward page to print page.
	if (WI.fillTextValue("shift_page_basic").compareTo("2") == 0){%>
		<jsp:forward page="./srch_stud_temp.jsp" />
	<%	return;
	}
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./srch_stud_print.jsp" />
	<%	return;
	}

	try {
		dbOP = new DBOperation(strUserID,"SMS-Setting","mobile_prefix.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

int iSearchResult = 0;
Vector vEditInfo = null;Vector vRetResult = null;

SystemSetup systemSetup = new SystemSetup();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(systemSetup.operateOnGSMProviderPrefix(dbOP, request, Integer.parseInt(strTemp)) == null) 
		strErrMsg = systemSetup.getErrMsg();
	else	
		strErrMsg = "Operation Successful.";
}
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("prepared_to_edit"), "0");
if(strPreparedToEdit.equals("1"))
	vEditInfo = systemSetup.operateOnGSMProviderPrefix(dbOP, request, 3);
vRetResult = systemSetup.operateOnGSMProviderPrefix(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null) 
	strErrMsg = systemSetup.getErrMsg();
%>
<form action="./mobile_prefix.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: MOBILE SERVICE PROVIDER PREFIX::::</strong></font></div></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="17%">Service Provider </td>
      <td width="80%">
	  <select name="provider" style="font-size:10px;">
          <%=dbOP.loadCombo("PROVIDER_INDEX","PROVIDER_NAME"," from SMS_GSM_PROVIDER order by PROVIDER_NAME asc", WI.fillTextValue("provider"), false)%> 
        </select></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Prefix (max 5 digits) </td>
      <td><input type="text" name="prefix" value="<%=WI.fillTextValue("prefix")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" maxlength="5" onKeyUp="AllowOnlyInteger('form_','prefix')"></td>
    </tr>
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr> 
      <td width="3%" height="18">&nbsp;</td>
      <td width="8%">&nbsp;</td>
      <td width="27%">&nbsp;</td>
      <td width="28%">&nbsp;</td>
      <td width="34%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>
	  	<input type="submit" name="1" value="&nbsp;&nbsp;SAVE&nbsp;&nbsp;" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1';">	  </td>
      <td>&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr> 
      <td width="136%" height="25" colspan="3" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH 
          RESULT</font></strong></div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="11%" height="25" align="center" style="font-size:9px; font-weight:bold;">Mobile Service Provider </td>
      <td width="78%" style="font-size:9px; font-weight:bold;" align="center">Prefix</td>
      <td width="11%" style="font-size:9px; font-weight:bold;" align="center">Delete</td>
    </tr>
<%//System.out.println(vRetResult);
//strTemp = dbOP.loadCombo("PROVIDER_INDEX","SMS_GSM_PROVIDER_PREFIX.PREFIX_INDEX +'('+PROVIDER_NAME+')'"," from SMS_GSM_PROVIDER_PREFIX "+
//	"join SMS_GSM_PROVIDER on (SMS_GSM_PROVIDER.provider_index = SMS_GSM_PROVIDER_PREFIX.PREFIX_INDEX) order by PROVIDER_NAME,SMS_GSM_PROVIDER_PREFIX.PREFIX_INDEX", null, false); 
for(int i=0; i<vRetResult.size(); i+=3){%>
    <tr> 
      <td height="25"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i)%></td>
      <td align="center"><a href="javascript:PageAction('<%=(String)vRetResult.elementAt(i)%>','0');"><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
  	<tr>
		<td height="25">&nbsp;</td>
	</tr>
	</table>
<%}//vRetResult is not null
%>
  <table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="25" bgcolor="#A49A6A">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>