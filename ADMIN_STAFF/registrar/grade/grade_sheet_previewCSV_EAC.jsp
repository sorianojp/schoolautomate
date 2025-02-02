<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function CloseWindow()
{
	self.close();
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strCSV    = null;



//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-Grade Sheets","grade_sheet_previewCSV_EAC.jsp");
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
														"Registrar Management","GRADES",request.getRemoteAddr(),
														null);
//if iAccessLevel == 0, i have to check if user is set for sub module.
if(iAccessLevel == 0) {
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
									"Registrar Management","GRADES-Grade Sheets",request.getRemoteAddr(),
									null);

}

//I have to check if grade sheet is locked..
if(new enrollment.SetParameter().isGsLocked(dbOP))
	iAccessLevel = 0;

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

Vector vRetResult = null;
strCSV =WI.fillTextValue("CSV");
	if (strCSV.length()==0)
		strErrMsg = "Nothing entered";
	else
	{
		vRetResult = comUtil.convertCSVToVector(strCSV);
		if ((vRetResult.size()%4) != 0)
			strErrMsg = "You are lacking several values. Kindly check your entries.";
		//System.out.println("result: "+vRetResult);
	}
%>
<body bgcolor="#D2AE72">
<form name="gsheet" action="./grade_sheet_previewCSV_EAC.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" align="center"><font color="#FFFFFF"><strong>:::: CSV PREVIEW ::::</strong></font></td>
    </tr>
	<tr>
		<td align="left">&nbsp; <a href="javascript:CloseWindow();">
	  <img src="../../../images/close_window.gif" width="71" height="32" border="0"></a></td>
	</tr>
	<tr>
		<td align="left" height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
	</tr>
</table>
<%if (vRetResult != null && vRetResult.size()>0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EEEEEE">
	    <td width="34%" align="center" height="25" class="thinborder"><font size="2"><strong>STUDENT ID</strong></font></td>
    	<td width="34%" align="center" class="thinborder"><font size="2"><strong>SUBJECT CODE</strong></font></td>
    	<td width="33%" align="center" class="thinborder"><font size="2"><strong>GRADE</strong></font></td>
		<td width="33%" align="center" class="thinborder"><font size="2"><strong>REMARK</strong></font></td>
    </tr>
    <%for (int iCtr = 0; iCtr < vRetResult.size(); iCtr+=4){%>
    <tr>
		<td align="center" height="20" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(iCtr),"&nbsp;")%></td>
		<td align="center" class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(iCtr + 1),"&nbsp;")%></td>
		<td align="center" class="thinborder">
		<%if ((iCtr+2)>=vRetResult.size()){%>NOT DEFINED<%} else {%><%=WI.getStrValue((String)vRetResult.elementAt(iCtr+2),"&nbsp;")%><%}%></td>
		<td align="center" class="thinborder"><%if ((iCtr+3)>=vRetResult.size()){%>NOT DEFINED<%} else {%><%=WI.getStrValue((String)vRetResult.elementAt(iCtr+3),"&nbsp;")%><%}%></td>
	</tr>
	<%}%>
  </table>
<%}%>
 <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="CSV" value="<%=WI.fillTextValue("CSV")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
