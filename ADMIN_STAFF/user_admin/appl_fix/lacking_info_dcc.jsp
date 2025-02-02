<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage() {
	document.form_.fix_floating_ra.value = "";
	document.form_.page_action.value = "";
	document.form_.submit();
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Application Fix","lacking_info_dcc.jsp");

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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","Application Fix",request.getRemoteAddr(),
														"lacking_info_dcc.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
utility.AllProgramFix apf = new utility.AllProgramFix();
if(WI.fillTextValue("date_fr").length() > 0 && WI.fillTextValue("date_to").length() > 0) {
	vRetResult = apf.getLackingInfo(dbOP, request);
	if(vRetResult == null)
		strErrMsg = apf.getErrMsg();
}

%>


<form name="form_" action="./lacking_info_dcc.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          LIST OF LACKING INFO - CASHIER'S REPORT ERROR ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="14%" height="25">Date Paid Range </td>
      <td width="54%">
      <input name="date_fr" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
		to 
        <input name="date_to" type="text" size="12" maxlength="12" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>
		
	  
	  
	  </td>
      <td width="29%"><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
 <%
 if (vRetResult!= null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#FFFFAF"> 
      <td height="26" colspan="7" class="thinborder"><div align="center"><strong>List of Lacking Info to be fixed </strong></div></td>
    </tr>
    <tr align="center" style="font-weight:bold">
      <td width="4%" class="thinborder">Count</td> 
      <td width="20%" height="27" class="thinborder"><div align="center"><strong>OR Number </strong></div></td>
      <td width="14%" class="thinborder"><div align="center"><strong>Amount </strong></div></td>
      <td width="38%" class="thinborder"><div align="center"><strong>Student Name </strong></div></td>
      <td width="14%" class="thinborder">Student Type </td>
      <td width="5%" class="thinborder">SY</td>
      <td width="5%" class="thinborder">Term</td>
    </tr>
    <%int iCount =0;
	String[] astrConverStudType = {"OLD","TEMP"};
 for(int i = 0; i < vRetResult.size(); i += 7){%>
    <tr>
      <td  class="thinborder"><%=++iCount%>.</td> 
      <td height="25"  class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=astrConverStudType[Integer.parseInt((String)vRetResult.elementAt(i + 4))]%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
    </tr>
<%}%>
  </table>
<%}else if(false){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#77ccFF"> 
      <td height="25" colspan="5"  class="thinborder">&nbsp;&nbsp;<b>*************** 
        No Error found *************** </b></td>
    </tr>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr><td width="25">&nbsp;</td></tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25"bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="info_index">
 <input type="hidden" name="page_action">
 <input type="hidden" name="fix_floating_ra">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
