<%@ page language="java" import="utility.*, java.util.Vector" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
</head>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head><style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }
th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
 }
-->
</style>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PageAction(strAction){
	document.form_.page_action.value = strAction;
	document.form_.submit();
}
</script>
<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
    //add security here.

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE","manage_swu_current_batch.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
        <p align="center"><font face="Verdana, Arial, Helvetica, sans-serif" size="3">Error in opening connection</font></p>
		<%return;
	}
	
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"manage_swu_current_batch.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
//end of authenticaion code.
	
	String[] astrSemester = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};
	String[] astrMonth ={"January","February","March","April","May","June","July","August","September","October","November","December"};
	
	enrollment.FAFeeMaintenance feeMaintenance =new enrollment.FAFeeMaintenance();
	Vector vRetResult = new Vector();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(feeMaintenance.operateOnCurrentBatchNo(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = feeMaintenance.getErrMsg();
		else
			strErrMsg = "Current batch number successfully set.";
	}	
	
	vRetResult = feeMaintenance.operateOnCurrentBatchNo(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = feeMaintenance.getErrMsg();
	

%>
<form name="form_" action="manage_swu_current_batch.jsp" method="post">
<%if (vRetResult != null && vRetResult.size() > 0) { %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" align="center"><font color="#FFFFFF"><strong>::::
        CURRENT BATCH NUMBER MANAGEMENT PAGE ::::</strong></font></td>
    </tr>
	<tr>
      <td height="25">&nbsp;&nbsp;&nbsp; <font size="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></font> </td>
    </tr>	
  </table>

<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="20%" height="25" class="thinborder"><strong>SY</strong></td>
		<td width="40%" class="thinborder"><strong>Batch Number </strong></td>
		<td width="28%" class="thinborder"><strong>Is Current </strong></td>
		<td width="12%" class="thinborder" align="center"><strong>Set To Current</strong></td>
	</tr>
	
	<%
	
	int iCount = 0;
	String[] astrConvertYesNo = {"No","Yes"};
	for(int i = 0; i < vRetResult.size(); i+=4){
	%>
	<tr>
		<td class="thinborder" height="25"><%=vRetResult.elementAt(i)%></td>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+1)%> - <%=(String)vRetResult.elementAt(i+2)%></td>
		<td class="thinborder" height="25"><%=astrConvertYesNo[Integer.parseInt((String)vRetResult.elementAt(i+3))]%></td>
		<%
		if(WI.getStrValue(vRetResult.elementAt(i+3)).equals("1"))
			strTemp = "checked";
		else	
			strTemp = "";
		%>
		<td class="thinborder" align="center">
			<input type="checkbox" name="batch_no_<%=++iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1" <%=strTemp%>/>
		</td>
	</tr>
	<%}%>
	<input type="hidden" name="item_count" value="<%=iCount%>" />
</table>
 <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 	<tr><td align="center">
		<a href="javascript:PageAction('1');"><img src="../../../images/update.gif" border="0" /></a>
		<font size="1">Click to set current batch number</font>
	</td></tr>
 </table>
  <%} // end of vRetResult != null && vRetResult.size() > 0%>
  <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable5">
    <tr bgcolor="#FFFFFF">
      <td height="25"></td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
  <input type="hidden" name="page_refresh">
  <input type="hidden" name="info_index" value="<%= WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%dbOP.cleanUP();%>
