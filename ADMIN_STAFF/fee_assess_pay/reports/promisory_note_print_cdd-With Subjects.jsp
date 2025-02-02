<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
<body onLoad="window.print();" topmargin="0">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,enrollment.ReportEnrollmentDagupan,enrollment.EnrlAddDropSubject,java.util.Vector" %>
	
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
	try
	{
		dbOP = new DBOperation();
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
	
String[] astrConvertYear = {"","FIRST YEAR","SECOND YEAR","THIRD YEAR","FOURTH YEAR","FIFTH YEAR","SIXTH YEAR"};
Vector vRetResult = new Vector();
Vector vStudDetail= new Vector();
Vector vStudInfo  = new Vector();

String strParentName = null;



EnrlAddDropSubject enrlStudInfo = new EnrlAddDropSubject();
ReportEnrollment reportEnrl= new ReportEnrollment();
ReportEnrollmentDagupan reportEnrlDagupan = new ReportEnrollmentDagupan();


vStudInfo = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));

if(vStudInfo == null)
	strErrMsg = enrlStudInfo.getErrMsg();
else{
	strParentName = reportEnrlDagupan.getParentGuardianInfo(dbOP,request,(String)vStudInfo.elementAt(0));	
	if(strParentName == null)
		strErrMsg = reportEnrlDagupan.getErrMsg();
	vRetResult = reportEnrl.getStudentLoad(dbOP, WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));	
	if(vRetResult == null)
		strErrMsg = reportEnrl.getErrMsg();
	else
		vStudDetail = (Vector)vRetResult.remove(0);	
}

String astrConvertTerm[] = {"Summer","1st Semester","2nd Semester","3rd Semester"};

if(strErrMsg != null){
dbOP.cleanUP();%>
<table border="0" width="100%">
    <tr>
      <td width="100%"><div align="center"><font size="3"><%=strErrMsg%></font></div></td>
    </tr>
</table>
<%return;}%>

<br><br><br><br>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<!--------------------------------------  PARA SA PRESIDENT OG PARENTS COPY  ------------------->
	<tr>
		<td width="50%">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<!--<tr><td colspan="2" height="80px" valign="top" align="center"><font size="2"><strong>&nbsp;</strong></font></td></tr>-->
				<tr><td colspan="2" height="40" valign="top">&nbsp;</td></tr>
				<tr><td align="right"><%=WI.getTodaysDateTime()%></td><td align="right" width="10%">&nbsp;&nbsp;&nbsp;</td></tr>
				<tr><td colspan="2" height="55" valign="middle" align="center"><strong>&nbsp;</strong></td></tr>
				
				<tr>
					<td colspan="2">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr><td valign="top" width="25%" height="17">&nbsp;</td><td width="75%">&nbsp; <%=WI.fillTextValue("pnNumber")%></td></tr>
							<tr><td height="17" valign="top">&nbsp;</td><td>&nbsp; <%=request.getParameter("stud_id")%></td></tr>
							<tr><td height="17" valign="top">&nbsp;</td><td>&nbsp; <%=((String)vStudDetail.elementAt(2)).toUpperCase()%></td></tr>
							<tr><td height="17" valign="top">&nbsp;</td><td>&nbsp; <%=((String)vStudDetail.elementAt(3)).toUpperCase()%></td></tr>
							<tr><td height="17" valign="top">&nbsp;</td><td>&nbsp; <%=astrConvertYear[Integer.parseInt((String)vStudDetail.elementAt(4))]%></td></tr>
						</table>
					</td>
				</tr>		
							
				<tr><td colspan="2" height="20">&nbsp;</td></tr>
				<tr>
					<td colspan="2">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="47%" height="22">&nbsp;</td>
								<td width="53%" align="left">&nbsp;<%=WI.getStrValue(strParentName)%></td>
							</tr>
							<tr>
								<td width="47%" height="22">&nbsp;</td>
								<td align="left">&nbsp;Php <%=WI.fillTextValue("amount")%></td>
							</tr>
							<tr>
								<td width="47%" height="22">&nbsp;</td>
								<td align="left">&nbsp;<%=WI.fillTextValue("dueDate")%></td>
							</tr>
							<tr>
								<td width="47%" height="22">&nbsp;</td>
								<td align="left">&nbsp;<%=WI.fillTextValue("exam").toUpperCase()%></td>
							</tr>
							<tr><td height="22" colspan="2" align="right" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
							<%=astrConvertTerm[Integer.parseInt(request.getParameter("semester"))]%>, SY <%=request.getParameter("sy_from")%> -<%=request.getParameter("sy_to")%> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
						  </td></tr>
						</table>
					</td>
				</tr>
								
				<tr>
					<td height="40px">&nbsp;</td>
					<td>&nbsp;</td>
				</tr>
				<tr>
				  <td height="30px" valign="bottom">&nbsp;</td>
				  <td valign="bottom">&nbsp;</td>
				</tr>
				<tr>
					<td height="30px" >&nbsp;</td>
					<td valign="bottom"><i><strong>&nbsp;</strong></i></td>
				</tr>
			</table>
    </td>
		
		
		<!---------------------------PARENTS COPY------------------------------------>
		
		<td width="50%">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<!--<tr><td colspan="2" height="80px" valign="top" align="center"><font size="2"><strong>&nbsp;</strong></font></td></tr>-->
				<tr><td colspan="2" height="40" valign="top">&nbsp;</td></tr>
				<tr><td align="right" colspan="2"><%=WI.getTodaysDateTime()%></td></tr>
				<tr><td colspan="2" height="55" valign="middle" align="center"><strong>&nbsp;</strong></td></tr>
				
				<tr>
					<td colspan="2">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr><td valign="top" width="30%" height="17">&nbsp;</td><td width="70%">&nbsp; <%=WI.fillTextValue("pnNumber")%></td></tr>
							<tr><td valign="top" height="17">&nbsp;</td><td>&nbsp; <%=request.getParameter("stud_id")%></td></tr>
							<tr><td valign="top" height="17">&nbsp;</td><td>&nbsp; <%=((String)vStudDetail.elementAt(2)).toUpperCase()%></td></tr>
							<tr><td valign="top" height="17">&nbsp;</td><td>&nbsp; <%=((String)vStudDetail.elementAt(3)).toUpperCase()%></td></tr>
							<tr><td valign="top" height="17">&nbsp;</td><td>&nbsp; <%=astrConvertYear[Integer.parseInt((String)vStudDetail.elementAt(4))]%></td></tr>
						</table>
					</td>
				</tr>		
							
				<tr><td colspan="2" height="20">&nbsp;</td></tr>
				<tr>
					<td colspan="2">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="55%" height="22">&nbsp;</td>
								<td width="45%" align="left">&nbsp;<%=WI.getStrValue(strParentName)%></td>
							</tr>
							<tr>
								<td width="55%" height="22">&nbsp;</td>
								<td align="left">&nbsp;Php <%=WI.fillTextValue("amount")%></td>
							</tr>
							<tr>
								<td width="55%" height="22">&nbsp;</td>
								<td align="left">&nbsp;<%=WI.fillTextValue("dueDate")%></td>
							</tr>
							<tr>
								<td width="55%" height="22">&nbsp;</td>
								<td align="left">&nbsp;<%=WI.fillTextValue("exam").toUpperCase()%></td>
							</tr>
							
							<tr>
							<td height="22" colspan="2" align="right">
							<%=astrConvertTerm[Integer.parseInt(request.getParameter("semester"))]%>, SY <%=request.getParameter("sy_from")%> -<%=request.getParameter("sy_to")%>							</td>
							</tr>
						</table>
					</td>
				</tr>
								
				<tr>
					<td height="40px">&nbsp;</td>
					<td>&nbsp;</td>
				</tr>
				<tr>
				  <td height="30px" valign="bottom">&nbsp;</td>
				  <td valign="bottom">&nbsp;</td></tr>
				<tr><td height="30px" >&nbsp;</td><td valign="bottom">&nbsp;</td></tr>
			</table>
		</td>
	
	
	<!--<tr><td colspan="2" height="50px" >&nbsp;</td></tr>-->
	
	
	
	<!-------------------  PARA EXAM PERMIT ------------------------>
	<tr>
		<td colspan="2">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr><td colspan="4" height="110" valign="middle">&nbsp;</td></tr>
				<tr><td colspan="4" height="20" valign="top" align="center"><strong>&nbsp;</strong></td></tr>	
				<tr>
					<td width="11%" height="15">&nbsp;</td>
					<td width="41%"><%=request.getParameter("stud_id")%></td>
					<td width="14%" height="15">&nbsp;</td>
					<td width="34%">&nbsp;<%=WI.fillTextValue("pnNumber")%></td>
				</tr>
				<tr>
					<td height="15">&nbsp;</td><td><%=((String)vStudDetail.elementAt(2)).toUpperCase()%></td>
					<td>&nbsp;</td><td>&nbsp;<%=WI.fillTextValue("exam").toUpperCase()%></td>
				</tr>
				<tr>
					<td  height="15">&nbsp;</td><td><%=((String)vStudDetail.elementAt(3)).toUpperCase()%></td>
					<td>&nbsp;</td><td>&nbsp;<%=WI.fillTextValue("dueDate")%></td>
				</tr>
				<tr><td colspan="4" height="30px" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<%=astrConvertTerm[Integer.parseInt(request.getParameter("semester"))]%>, SY <%=request.getParameter("sy_from")%> -<%=request.getParameter("sy_to")%></td></tr>
				<tr>
					<td colspan="4">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
							  <td width="3%">&nbsp;</td>
								<td width="15%" height="25px">&nbsp;</td>
								<td width="32%">&nbsp;</td>
								<td width="23%">&nbsp;</td>
								<td width="27%">&nbsp;</td>
							</tr>
							
							<%for(int i=0;i<vRetResult.size();i+=11){%>
							<tr>
							  <td class="">&nbsp;</td>
								<td class=""><%=vRetResult.elementAt(i)%></td>
								<td class=""><%=vRetResult.elementAt(i+1)%></td>
								<td class="">_____________</td>
								<td class="">_____________</td>
							</tr>
							<%}%>
						</table>
					</td>
				</tr>
				<tr><td colspan="2" height="60px" valign="bottom"><%=WI.getTodaysDateTime()%></td><td colspan="2">&nbsp;</td></tr>
				<tr><td colspan="2" height="40px">&nbsp;</td><td colspan="2">&nbsp;</td></tr>
			</table>
		</td>
	</tr>
	
</table>


</body>
</html>
<%
dbOP.cleanUP();
%>
