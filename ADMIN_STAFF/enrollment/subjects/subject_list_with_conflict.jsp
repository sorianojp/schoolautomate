<%@ page language="java" import="utility.*,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">
function PrintPg(){
	
	if(!confirm("Click OK to print report."))
		return;
	
	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	
	document.getElementById("myADTable2").deleteRow(0);
	
	document.getElementById("myADTable3").deleteRow(0);
	document.getElementById("myADTable3").deleteRow(0);
	

	window.print();


}
	
</script>
<%
	DBOperation dbOP  = null;	
	String strErrMsg  = null;
	String strTemp    = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS","subject_list_with_conflict.jsp");
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
	int iAccessLevel = 2;
	
	if(strAuthTypeIndex == null || strAuthTypeIndex.equals("4"))//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../admin_staff/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","Failed to access the report. Please login again.");
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


Vector vTemp = null;
Vector vConflictList = null;
Vector vRetResult = null;
enrollment.ReportEnrollment RE = new enrollment.ReportEnrollment();
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0){
	vRetResult = RE.generateRoomConflict(dbOP, request);
	if(vRetResult == null)
		strErrMsg = RE.getErrMsg();
	else if(vRetResult.size() == 0) 
		strErrMsg = "No Conflict found.";
	
}

%>
<body bgcolor="#D2AE72">
<form name="form_" action="./subject_list_with_conflict.jsp" method="post">
	<table width="100%" border="0" id="myADTable1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A">	
			<td colspan="3" height="25" bgcolor="#A49A6A"><div align="center">
			<font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: SUBJECT - SECTION WITH CONFLICT SCHEDULE REPORT ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;&nbsp;&nbsp;&nbsp;<strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	<tr>
		<td width="3%" height="25">&nbsp;</td>
		<td width="18%">SY-Term</td>
		<td width="79%">			
			<%strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
			<%strTemp = WI.getStrValue(WI.fillTextValue("semester"), (String)request.getSession(false).getAttribute("cur_sem"));%>
			<select name="semester">
			<%=CommonUtil.constructTermList(dbOP, request, strTemp)%>
			</select>
			&nbsp;
			<input type="image" src="../../../images/refresh.gif" border="0">
		</td>
	</tr>
</table>


<%if(vRetResult != null && vRetResult.size() > 0){
String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester", "Fourth Semester"};

%>
<table width="100%" id="myADTable2" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	    <td height="25" align="right">
		<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
		<font size="1">Click to print report</font>
		</td>
	    </tr>
	<tr><td height="25" align="center">
	<strong><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong><br>
	<%=SchoolInformation.getAddressLine1(dbOP, false, false)%><br><br>
	<strong>LIST OF SUBJECT - SECTION WITH CONFLICT SCHEDULE</strong><br>
	<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, AY <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%></td></tr>
</table>							
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
	    <td height="25"  class="thinborder" align="center"><strong>CLASS SCHEDULE</strong></td>
	    <td class="thinborder" align="center"><strong>CONFLICT SCHEDULE</strong></td>
	    </tr>
	<%
	String strTime = null;

	for(int i = 0; i < vRetResult.size(); i+=7){
		
		vConflictList = (Vector)vRetResult.elementAt(i+6);
	%>
	
	<tr>
		<td width="44%" height="25" valign="top" class="thinborder">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td width="43%">Subject Code</td>
					<td width="57%"><%=vRetResult.elementAt(i+2)%></td>					
				</tr>
				<tr>					
					<td>Subject Name</td>
					<td><%=vRetResult.elementAt(i+3)%></td>					
				</tr>
				<tr>
					
					<td>Section</td>
					<td><%=vRetResult.elementAt(i+1)%></td>
				</tr>
				<tr>
					
					<td>Room No</td>
					<td><%=vRetResult.elementAt(i+4)%></td>
				</tr>
				<tr>					
					<td valign="top">Schedule</td>
					<%
					strTime = null;
					vTemp = (Vector)vRetResult.elementAt(i+5);
					if(vTemp != null && vTemp.size() > 0){
						while(vTemp.size() > 0){
							vTemp.remove(0);vTemp.remove(0);							
							if(strTime == null)
								strTime = (String)vTemp.remove(0);
							else
								strTime += "<br>" +(String)vTemp.remove(0);
						}
					}
					%>
					<td valign="top"><%=strTime%></td>
				</tr>
			</table>		</td>
		<td width="56%" valign="top" class="thinborder">
			<%
			for(int j = 0; j < vConflictList.size(); j += 6){
			
			%>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td width="43%">Subject Code</td>
					<td width="57%"><%=vConflictList.elementAt(j+2)%></td>					
				</tr>
				<tr>					
					<td>Subject Name</td>
					<td><%=vConflictList.elementAt(j+3)%></td>					
				</tr>
				<tr>
					
					<td>Section</td>
					<td><%=vConflictList.elementAt(j+1)%></td>
				</tr>
				<tr>
					
					<td>Room No</td>
					<td><%=vConflictList.elementAt(j+4)%></td>
				</tr>
				<tr>					
					<td valign="top">Schedule</td>
					<%
					strTime = null;					
					vTemp = (Vector)vConflictList.elementAt(j+5);
					if(vTemp != null && vTemp.size() > 0){
						while(vTemp.size() > 0){
							vTemp.remove(0);vTemp.remove(0);							
							if(strTime == null)
								strTime = (String)vTemp.remove(0);
							else
								strTime += "<br>" +(String)vTemp.remove(0);
						}
					}
					%>
					<td valign="top"><%=strTime%></td>
				</tr>
			</table>
			<%if( (j + 6) < vConflictList.size() )%>
			<hr width="90%" size="1%">
			<%}%>		</td>
	</tr>
	<%}%>
</table>
<%}%>


<table width="100%" id="myADTable3" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">							
	<tr><td height="25">&nbsp;</td></tr>
    <tr bgcolor="#B8CDD1"><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>	
	<input type="hidden" name="exclude_subj">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
