<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>...</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="window.print();">
<%@ page language="java" import="utility.*,enrollment.CurriculumSM,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CURRICULUM-Subject Equivalent - Advising","sub_equiv_advising.jsp");
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
														"Registrar Management","CURRICULUM-Subject Equivalent - Advising",request.getRemoteAddr(),
														"sub_equiv_advising.jsp");
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

CurriculumSM SM = new CurriculumSM();
Vector vRetResult = SM.showAllEquivSubjectWithCourse(dbOP, request);
Vector vCurListAll = null;	
if(vRetResult == null)  {
	strErrMsg = SM.getErrMsg();
	if(strErrMsg == null)
		strErrMsg = "Equivalent subject list not found.";
}
else
	vCurListAll = (Vector)vRetResult.remove(0);


%>
<%if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr style="font-weight:bold">
      <td height="25" width="2%">&nbsp;</td>
      <td class="thinborderNONE" style="font-size:14px; color:#FF0000;"><%=strErrMsg%></td>
    </tr>
  </table>
<%dbOP.cleanUP();
return;
}%>
<table width=100% border=0>
    <tr>
      <td height="25" class="thinborderBOTTOM" style="font-weight:bold" align="center">LIST OF SUBJECT EQUIVALENT USED IN CURRICULUM</td>
    </tr>
    <tr>
      <td style="font-size:9px" align="right">Date and Time Printed: <%=WI.getTodaysDateTime()%></td>
    </tr>
</table>
<%

int iIndexOf = 0;
Integer iObj = null;
Vector vCurList = null;
String strLecUnit = null;
String strLabUnit = null;

String strLHSSubject = null;
%>

<%while(vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="49%" valign="top">
<%
strLHSSubject = (String)vRetResult.elementAt(4);
iObj = new Integer(strLHSSubject);
iIndexOf = vCurListAll.indexOf(iObj);
if(iIndexOf >= 0) {
	vCurList = (Vector) vCurListAll.elementAt(iIndexOf + 1);
	if(vCurList != null && vCurList.size() == 0)
		vCurList = null;
	if(vCurList != null)
		strLecUnit = (String)vCurList.elementAt(2)+"/"+(String)vCurList.elementAt(2);
}
else {
	vCurList = null;
	strLecUnit = "&nbsp;";
}
%>	
		  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
			<tr bgcolor="#CCCCCC" style="font-weight:bold" align="center"> 
			  <td width="30%" height="25" class="thinborder" style="font-size:9px;">Subject Code</td>
			  <td width="55%" class="thinborder" style="font-size:9px;">Subject Name</td>
			  <td width="15%" class="thinborder" style="font-size:9px;">Lec/Lab Units</td>
			</tr>
			<tr style="font-weight:bold">
			  <td height="25" class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(0)%></td>
			  <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(1)%></td>
			  <td class="thinborder" style="font-size:9px;"><%=strLecUnit%></td>
		    </tr>
			<%if(vCurList == null) {%>
				<tr style="font-weight:bold">
				  <td height="25" colspan="3" class="thinborder" style="font-size:9px;">No Curriculum Created.</td>
				</tr>
			<%}else{//show all courses using this subject.%>
				<tr style="font-weight:bold">
				  <td height="25" colspan="3" class="thinborder" style="font-size:9px;">
					<table width="95%" align="center" border="0" cellpadding="0" cellspacing="0">
						<tr style="font-weight:bold;" align="center" bgcolor="#FFFFCC">
							<td class="thinborderBOTTOMRIGHT" style="font-size:9px" width="29%">Course Code</td>
							<td class="thinborderBOTTOMRIGHT" style="font-size:9px">Major Code</td>
							<td class="thinborderBOTTOMRIGHT" style="font-size:9px">CY From</td>
							<td class="thinborderBOTTOM" style="font-size:9px" width="13%">CY To</td>
						</tr>
						<%while(vCurList.size() > 0){%>
							<tr style="font-weight:bold;" align="center">
							  <td class="thinborderBOTTOMRIGHT" style="font-size:9px"><%=vCurList.remove(0)%></td>
							  <td class="thinborderBOTTOMRIGHT" style="font-size:9px"><%=WI.getStrValue(vCurList.remove(0),"&nbsp;")%></td>
							  <%vCurList.remove(0);vCurList.remove(0);vCurList.remove(0);vCurList.remove(0);%>
							  <td class="thinborderBOTTOMRIGHT" style="font-size:9px"><%=vCurList.remove(0)%></td>
							  <td class="thinborderBOTTOM" style="font-size:9px"><%=vCurList.remove(0)%></td>
							</tr>
						<%}%>
						<tr>
						  <td>&nbsp;</td>
						  <td>&nbsp;</td>
						  <td>&nbsp;</td>
						  <td>&nbsp;</td>
					  </tr>
					</table>				  
				  </td>
				</tr>
			<%}%>
		  </table>
		</td>
		<td width="49%" valign="top">
			<%while(vRetResult.size() > 0) {
				if(vRetResult.elementAt(4) != null && !strLHSSubject.equals(vRetResult.elementAt(4)))	
					break;
				iObj = (Integer)vRetResult.elementAt(5);
				iIndexOf = vCurListAll.indexOf(iObj);
				if(iIndexOf >= 0) {
					vCurList = (Vector) vCurListAll.elementAt(iIndexOf + 1);
					if(vCurList != null && vCurList.size() == 0)
						vCurList = null;
					if(vCurList != null)
						strLecUnit = (String)vCurList.elementAt(2)+"/"+(String)vCurList.elementAt(2);
				}
				else {
					vCurList = null;
					strLecUnit = "&nbsp;";
				}

			%>
			
		  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
			<tr bgcolor="#CCCCCC" style="font-weight:bold" align="center"> 
			  <td width="30%" height="25" class="thinborder" style="font-size:9px;">Equiv. Subject Code</td>
			  <td width="55%" class="thinborder" style="font-size:9px;">Subject Name</td>
			  <td width="15%" class="thinborder" style="font-size:9px;">Lec/Lab Units</td>
			</tr>
			<tr style="font-weight:bold">
			  <td height="25" class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(2)%></td>
			  <td class="thinborder" style="font-size:9px;"><%=vRetResult.elementAt(3)%></td>
			  <td class="thinborder" style="font-size:9px;"><%=strLecUnit%></td>
		    </tr>
			<%
			//remove vRetResult/
			vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
			
			if(vCurList == null) {%>
				<tr style="font-weight:bold">
				  <td height="25" colspan="3" class="thinborder" style="font-size:9px;">No Curriculum Created.</td>
				</tr>
			<%}else{//show all courses using this subject.%>
				<tr style="font-weight:bold">
				  <td height="25" colspan="3" class="thinborder" style="font-size:9px;">
					<table width="95%" align="center" border="0" cellpadding="0" cellspacing="0">
						<tr style="font-weight:bold;" align="center" bgcolor="#FFFFCC">
							<td class="thinborderBOTTOMRIGHT" style="font-size:9px" width="29%">Course Code</td>
							<td class="thinborderBOTTOMRIGHT" style="font-size:9px">Major Code</td>
							<td class="thinborderBOTTOMRIGHT" style="font-size:9px">CY From</td>
							<td class="thinborderBOTTOM" style="font-size:9px" width="13%">CY To</td>
						</tr>
						<%while(vCurList.size() > 0){%>
							<tr style="font-weight:bold;" align="center">
							  <td class="thinborderBOTTOMRIGHT" style="font-size:9px"><%=vCurList.remove(0)%></td>
							  <td class="thinborderBOTTOMRIGHT" style="font-size:9px"><%=WI.getStrValue(vCurList.remove(0),"&nbsp;")%></td>
							  <%vCurList.remove(0);vCurList.remove(0);vCurList.remove(0);vCurList.remove(0);%>
							  <td class="thinborderBOTTOMRIGHT" style="font-size:9px"><%=vCurList.remove(0)%></td>
							  <td class="thinborderBOTTOM" style="font-size:9px"><%=vCurList.remove(0)%></td>
							</tr>
						<%}%>
						<tr>
						  <td>&nbsp;</td>
						  <td>&nbsp;</td>
						  <td>&nbsp;</td>
						  <td>&nbsp;</td>
					  </tr>
					</table>				  
				  </td>
				</tr>
			<%}%>
		  </table>
			<%}//end of while.%>
		</td>
	</tr>
  </table>
<br>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>