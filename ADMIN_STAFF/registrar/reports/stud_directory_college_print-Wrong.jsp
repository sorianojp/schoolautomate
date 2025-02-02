<%@ page language="java" import="utility.*,enrollment.EnrollmentStatusUC,java.util.Vector,java.util.Date " %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Student's Directory</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	DBOperation dbOP  = null;	
	String strErrMsg  = null;
	String strTemp    = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Student Directory","stud_directory.jsp");
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
															"Registrar Management","REPORTS",request.getRemoteAddr(),
															"stud_directory_college.jsp");
	
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../admin_staff/admin_staff_home_button_content.htm");
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
	
	boolean bolPageBreak = false;
	boolean bolIsRepair = false;
	int i = 0;
	int iSearchResult = 0;
	Vector vRetResult = new Vector();

	EnrollmentStatusUC eSUC = new EnrollmentStatusUC();
	vRetResult = eSUC.viewMasterListDBTC(dbOP, request);
	if(vRetResult == null)
		strErrMsg = eSUC.getErrMsg();
	
	if (vRetResult != null) {
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(15*iMaxRecPerPage);
		if(vRetResult.size()%(15*iMaxRecPerPage) > 0)
			iTotalPages++;	
		for (;iNumRec < vRetResult.size();iPageNo++){%>
		
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td height="20" align="center"><font size="+1"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td>
		</tr>
		<tr>
			<td height="20" align="center"><%=(SchoolInformation.getAddressLine1(dbOP,false,false)).toUpperCase()%></td>
		</tr>
		<tr>
			<td height="20" align="center"><font size="2"><strong>COLLEGE DEPARTMENT</strong></font></td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" align="center"><font size="2" color="#FF0000"><strong>STUDENT'S DIRECTORY</strong></font></td>
		</tr>
		<tr>
			<td height="20" align="center"><strong><%=WI.fillTextValue("semester_name")%> 
				A.Y. <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></strong></td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
		
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="20" width="2%" align="center" class="thinborder">&nbsp;</td>
			<td width="10%" align="center" class="thinborder"><strong><font style="font-size:10px">NAME</font></strong></td>
			<td width="8%" align="center" class="thinborder"><strong><font style="font-size:10px">COURSE</font></strong></td>
			<td width="15%" align="center" class="thinborder"><strong><font style="font-size:10px">EMERGENCY ADDRESS</font></strong></td>
			<td width="15%" align="center" class="thinborder"><strong><font style="font-size:10px">CURRENT ADDRESS</font></strong></td>
			<td width="15%" align="center" class="thinborder"><strong><font style="font-size:10px">RESIDENCE ADDRESS</font></strong></td>
			<td width="10%" align="center" class="thinborder"><strong><font style="font-size:10px">FATHER</font></strong></strong></td>
			<td width="10%" align="center" class="thinborder"><strong><font style="font-size:10px">MOTHER</font></strong></td>
			<td width="10%" align="center" class="thinborder"><strong><font style="font-size:10px">GUARDIAN</font></strong></td>
			<td width="8%" align="center" class="thinborder"><strong><font style="font-size:10px">BIRTHDATE</font></strong></td>
			<td width="2%" align="center" class="thinborder"><strong><font style="font-size:10px">AGE</font></strong></td>
			<td width="5%" align="center" class="thinborder"><strong><font style="font-size:10px">GENDER</font></strong></td>
		</tr>
		<% 
			int iResultCount = (iPageNo - 1) * iMaxRecPerPage + 1;
			for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=15, ++iCount,++iResultCount){
				i = iNumRec;
				if (iCount > iMaxRecPerPage){
					bolPageBreak = true;
					break;
				}
				else 
					bolPageBreak = false;
		%>
		<tr>
			<td height="25" class="thinborder"><font style="font-size:10px"><%=iResultCount%></font></td>
			<td class="thinborder" style="font-size:10px"><%=WebInterface.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i + 3), 4)%></td>
			<td class="thinborder" style="font-size:10px"><%=(String)vRetResult.elementAt(i+8)%><%=WI.getStrValue((String)vRetResult.elementAt(i+9), " - ", "","")%></td>
			<td class="thinborder" style="font-size:10px"><%=WI.getStrValue((String)vRetResult.elementAt(i+11), "&nbsp;")%></td>
			<td class="thinborder" style="font-size:10px"><%=WI.getStrValue((String)vRetResult.elementAt(i+12), "&nbsp;")%></td>
			<td class="thinborder" style="font-size:10px"><%=WI.getStrValue((String)vRetResult.elementAt(i+13), "&nbsp;")%></td>
			<td class="thinborder" style="font-size:10px"><%=WI.getStrValue((String)vRetResult.elementAt(i+5), "&nbsp;")%></td>
			<td class="thinborder" style="font-size:10px"><%=WI.getStrValue((String)vRetResult.elementAt(i+6), "&nbsp;")%></td>
			<td class="thinborder" style="font-size:10px"><%=WI.getStrValue((String)vRetResult.elementAt(i+7), "&nbsp;")%></td>
			<td class="thinborder" style="font-size:10px"><%=WI.getStrValue((String)vRetResult.elementAt(i+4), "&nbsp;")%></td>
			<td class="thinborder" style="font-size:10px" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+14), "&nbsp;")%></td>
			<td class="thinborder" style="font-size:10px" align="center"><%=WI.getStrValue((String)vRetResult.elementAt(i+10), "&nbsp;")%></td>
		</tr>
	<%} //end for loop%>
	</table>
	<%if (bolPageBreak){%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
	} //end end upper most if (vRetResult !=null)%>
</body>
</html>
<%
dbOP.cleanUP();
%>