<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
 }


    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;	
    }

    TD.thinborder {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

-->
</style>
</head>
<%@ page language="java" import="utility.*, clearance.ClearanceMain, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vEditInfo  = null;
	Vector vRetResult = null;
	Vector vStudInfo = null;
	
	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	int iSearchResult = 0;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Clearance-POST DUE","update_status.jsp");
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
														"Clearances","POST DUES",request.getRemoteAddr(),
														"update_status.jsp");
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

	ClearanceMain clrMain = new ClearanceMain();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(clrMain.operateOnClearancePmt(dbOP, request, Integer.parseInt(strTemp)) != null ) {
				strErrMsg = "Operation successful.";
				}
		else
				strErrMsg = clrMain.getErrMsg();

	}
	if(strPrepareToEdit.compareTo("1") == 0) {
		vStudInfo = clrMain.operateOnClearancePmt(dbOP, request, 3);
		if(vStudInfo == null && strErrMsg == null ) 
			strErrMsg = clrMain.getErrMsg();
	}
	
	vRetResult = clrMain.operateOnClearancePmt(dbOP, request, 4);
	iSearchResult = clrMain.getSearchCount();
	if (strErrMsg == null)
		strErrMsg = clrMain.getErrMsg();
	
%>
<body >
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
    <tr>
      <td width="100%"><div align="center"> 
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%> <br>
          <%=SchoolInformation.getAddressLine3(dbOP,false,false)%> <br>
          <strong> <%=SchoolInformation.getInfo2(dbOP,false,false)%></strong> <br>
      </p></div></td>
      </tr>
      <tr>
      <td>&nbsp;</td>
      </tr>
	</table>
  <%if (vRetResult!=null && vRetResult.size()>0){%>
  <table   width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr> 
		<td height="25" colspan="8" class="thinborder">
			<div align="center"><strong>LIST OF STUDENTS WITH PENDING STATUS UNDER <%=WI.getStrValue(request.getParameter("sig"))%></strong></div>
		</td>
	</tr>
	<tr>
		<td colspan="7" height="24" class="thinborder"><font size="1">Total Number of students: <%=iSearchResult%></font></td>
	</tr>
	<tr> 
		<td width="21%" height="24" class="thinborder"><div align="center"><font size="1"><strong>CLEARANCE</strong></font></div></td>
		<td width="12%" class="thinborder">
			<div align="center"><font size="1"><strong>STUDENT 
				ID </strong></font></div>
		</td>
		<td width="18%" class="thinborder">
			<div align="center"><font size="1"><strong>STUDENT NAME</strong></font></div>
		</td>
		<td width="10%" class="thinborder">
			<div align="center"><strong><font size="1">COURSE/YR</font></strong></div>
		</td>
		
		<td width="7%" class="thinborder">
			<div align="center"><strong><font size="1">DUE</font></strong></div>
		</td>
		<td width="32%" colspan="2" class="thinborder">
			<div align="center"><strong><font size="1">REMARKS</font></strong></div>
		</td>
	</tr>
	<%for (int i = 0; i < vRetResult.size();i+=29){%>
	<tr> 
		<td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+27)%><br><%=(String)vRetResult.elementAt(i+28)%></font></td>
		<td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i)%></font></td>
		<td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),7)%></font></td>
		<td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+6),((String)vRetResult.elementAt(i+4)) + "/","",
	  (String)vRetResult.elementAt(i+4))%></font></td>
		
		<td class="thinborder">
			<div align="center"><font size="1"><%if (vRetResult.elementAt(i+7)!=null){%><%=WI.getStrValue((String)vRetResult.elementAt(i+22),((String)vRetResult.elementAt(i+7)) + " ","",
	  (String)vRetResult.elementAt(i+7))%><%} else {%>N/A<%}%></font></div>
		</td>
		<td colspan="2" class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+8),"","","")%></font></td>
	</tr>
	<%}%>
</table>
  <script language="JavaScript">
	window.print();
</script>
  <%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>