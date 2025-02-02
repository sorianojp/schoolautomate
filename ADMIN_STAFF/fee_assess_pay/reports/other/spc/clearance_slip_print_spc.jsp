<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/common.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<body>
<%@ page language="java" import="utility.*,enrollment.ReportFeeAssessment,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-FEE ASSESSMENT & PAYMENTS-REPORTS",
								"clearance_slip_print_spc.jsp");
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"FEE ASSESSMENT & PAYMENTS","REPORTS",request.getRemoteAddr(),"clearance_slip_print_spc.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}
Vector vRetResult = new Vector();
ReportFeeAssessment reportFA = new ReportFeeAssessment();

vRetResult = reportFA.getStudListForClearanceSlipSPC(dbOP, request);
if(vRetResult == null)
	strErrMsg = reportFA.getErrMsg();
	
	
String strCourseCode = "";	
String strCollege    = "";
if(strErrMsg != null){dbOP.cleanUP();%>
	<div align="center"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></div>

<%return;}
if(vRetResult != null && vRetResult.size() > 0){

int iCount = 1;
boolean bolPageBreak = false;
String strIDNumber = null;


String strHeight = "30";

String[] strConvertSem = {"Summer","1st","2nd","3rd","4th"};
while(vRetResult.size() > 0){
	
	
	
	strIDNumber = (String)vRetResult.remove(0);
	
	strCourseCode = (String)vRetResult.elementAt(2);
	strCollege = (String)vRetResult.elementAt(5);
	

%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="<%=strHeight%>">&nbsp;</td></tr>
	<tr><td align="center" height="25"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong>
	<br><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br><br>
	CLEARANCE SLIP<br><br>&nbsp;
	</td></tr>
</table>


<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td valign="bottom" width="17%" height="25">Name : </td>
		<td valign="bottom"><div style="border-bottom:solid 1px #000000;"><%=vRetResult.remove(0)%> <%=WI.getStrValue(strIDNumber, "(",")","")%></div></td>
		<td>&nbsp;</td>
		<td align="right"><!--Section : --></td>
		<td>&nbsp;</td>
		<td><!--<%//=WI.getStrValue((String)vRetResult.remove(0))%>--></td>
	</tr>
  <tr>
    <td valign="bottom" height="22"><!--Course & Year :-->Section :</td>
    <td valign="bottom" width="33%"><div style="border-bottom:solid 1px #000000;"><%=WI.getStrValue((String)vRetResult.remove(0))%>&nbsp;</div><!--<%=vRetResult.remove(0)%><%=WI.getStrValue((String)vRetResult.remove(0)," / ","","")%> <%=WI.getStrValue((String)vRetResult.remove(0)," - ","","N/A")%>--> </td>
    <td width="5%">&nbsp;</td>
    <td width="18%" valign="bottom" align="right">__<u><%=strConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%></u>__ Sem.</td>
    <td width="3%" >&nbsp;</td>
    <td width="24%" valign="bottom">S.Y. __<u><%=WI.fillTextValue("sy_from") +"-"+ WI.fillTextValue("sy_to")%></u>__</td>
  </tr>
  <%
	vRetResult.remove(0);
	vRetResult.remove(0);
	%>
  <tr>
    <td colspan="6" height="40">This is to certify that this student has been cleared from all school obligations, accountabilities and other requirements.</td>
  </tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<!--<tr><td height="10">&nbsp;</td></tr>-->
	<tr>
		<td valign="top">
			<table bgcolor="#FFFFFF" align="center" width="90%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td valign="bottom" width="22%" height="30">School Nurse</td>
					<td valign="bottom" width="25%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
					<td width="4%" height="30">&nbsp;</td>
					<td valign="bottom" width="22%" height="30">Registrar</td>
					<td valign="bottom" width="27%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
				</tr>
				
				<tr>
					<td valign="bottom" width="22%" height="30">Spirituality Center Dir.</td>
					<td valign="bottom" width="25%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
					<td width="4%" height="30">&nbsp;</td>
					<td valign="bottom" width="22%" height="30">Librarian</td>
					<td valign="bottom" width="27%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
				</tr>
				
				<tr>
					<td valign="bottom" width="22%" height="30">OSA Director</td>
					<td valign="bottom" width="25%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
					<td width="4%" height="30">&nbsp;</td>
					<td valign="bottom" width="22%" height="30">Guidance Director</td>
					<td valign="bottom" width="27%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
				</tr>
			<%if(strCourseCode.toLowerCase().indexOf("bmls") > -1 || strCourseCode.toLowerCase().indexOf("pharm")  > -1
					|| strCollege.toLowerCase().startsWith("as") || strCollege.toLowerCase().startsWith("bm")
					|| strCollege.toLowerCase().indexOf("cpt") > -1  
					|| strCourseCode.toLowerCase().indexOf("bsrt")  > -1
					|| strCollege.toLowerCase().startsWith("hcs") || strCourseCode.toLowerCase().indexOf("bspt") > -1
					|| strCourseCode.toLowerCase().startsWith("hcs")){%>	
				<tr>
					<td height="30" colspan="2" valign="bottom">Laboratory Stockroom :</td>
					<td width="4%" height="30">&nbsp;</td>
					<td valign="bottom" width="22%" height="30">Spark Moderator</td>
					<td valign="bottom" width="27%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
				</tr>
				
				<tr>
					<td valign="bottom" width="22%" height="20" align="right">A &nbsp; &nbsp;&nbsp;</td>
					<td valign="bottom" width="25%" height="20"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
					<td width="4%" height="20">&nbsp;</td>
					<td height="20" colspan="2" valign="top" style="text-indent:50px;">(Graduating students only)</td>
				</tr>
				<tr>
					<td valign="bottom" width="22%" height="30" align="right">B &nbsp; &nbsp;&nbsp;</td>
					<td valign="bottom" width="25%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
					<td height="30" colspan="3">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" width="22%" height="30" align="right">C &nbsp; &nbsp;&nbsp;</td>
					<td valign="bottom" width="25%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
					<td height="30">&nbsp;</td>
					<td valign="bottom" width="22%" height="30">Cashier</td>
					<td valign="bottom" width="27%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
				</tr>	
				<tr>
					<td valign="bottom" width="22%" height="30">Department Dean</td>
					<td valign="bottom" width="25%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
					<td width="4%" height="30">&nbsp;</td>
					<td valign="bottom" width="22%" height="30">Comptroller</td>
					<td valign="bottom" width="27%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
				</tr>
				
				<%if(  strCourseCode.toLowerCase().indexOf("bsrt")  > -1 ){%>
						<tr>
							<td valign="bottom" width="22%" height="30">RT Program Coordinator</td>
							<td valign="bottom" width="25%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
							<td height="30" colspan="3">&nbsp;</td>
						</tr>
						
						<tr>
							<td valign="bottom" width="22%" height="30">RT Laboratory</td>
							<td valign="bottom" width="25%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
							<td height="30" colspan="3">&nbsp;</td>
						</tr>
				<%}//end strCourseCode == bsrt
				
				if(  strCourseCode.toLowerCase().startsWith("hcs")){%>
						<tr>
							<td valign="bottom" width="22%" height="30">CES Director</td>
							<td valign="bottom" width="25%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
							<td height="30" colspan="3">&nbsp;</td>
						</tr>
						
						<tr>
							<td height="20" colspan="5" valign="top">&nbsp; &nbsp; &nbsp; &nbsp; (for HCS-NC students only)</td>
						</tr>
				<%}//end strCollege == hcsnc
				
				
				}
				
				else if(  strCollege.toLowerCase().indexOf("con")  > -1 || strCourseCode.toLowerCase().indexOf("bsn")  > -1 ){
				%>
				
				
				<tr>
					<td height="30" colspan="2" valign="bottom">Laboratory Stockroom :</td>
					<td width="4%" height="30">&nbsp;</td>
					<td valign="bottom" width="22%" height="30">Nsg. Skills</td>
					<td valign="bottom" width="27%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
				</tr>
				
				<tr>
					<td valign="bottom" width="22%" height="20" align="right">A &nbsp; &nbsp;&nbsp;</td>
					<td valign="bottom" width="25%" height="20"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
					<td width="4%" height="20">&nbsp;</td>
					<td valign="bottom" height="20">&nbsp;&nbsp;&nbsp;Lab. Custodian</td>
					<td valign="bottom" height="20"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
				</tr>
				<tr>
					<td valign="bottom" width="22%" height="30" align="right">B &nbsp; &nbsp;&nbsp;</td>
					<td valign="bottom" width="25%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
					<td height="30" colspan="3">&nbsp;</td>
				</tr>	
				<tr>
					<td valign="bottom" width="22%" height="30" align="right">C &nbsp; &nbsp;&nbsp;</td>
					<td valign="bottom" width="25%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
					<td height="30">&nbsp;</td>
					<td valign="bottom" width="22%" height="30">Spark Moderator</td>
					<td valign="bottom" width="27%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
				</tr>	
				
				<tr>
					<td height="20" colspan="3" align="right" valign="bottom">&nbsp;</td>
					<td height="20" colspan="2" valign="top" style="text-indent:50px;">(Graduating students only)</td>
			  </tr>
				<tr>
					<td height="20" colspan="5" valign="bottom">BSN Level Chairman</td>
			  </tr>
				<tr>
					<td valign="bottom" width="22%" height="30">&nbsp;&nbsp;&nbsp;&nbsp;1 2 3 4</td>
					<td valign="bottom" width="25%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
					<td width="4%" height="30">&nbsp;</td>
					<td valign="bottom" width="22%" height="30">Cashier</td>
					<td valign="bottom" width="27%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
				</tr>
				<tr>
					<td valign="bottom" width="22%" height="30">Department Dean</td>
					<td valign="bottom" width="25%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
					<td width="4%" height="30">&nbsp;</td>
					<td valign="bottom" width="22%" height="30">Comptroller</td>
					<td valign="bottom" width="27%" height="30"><div style="border-bottom:solid 1px #000000;">&nbsp;</div></td>
				</tr>
				
				<%}%>
			</table>
		</td>
	</tr>
</table>
<div style="page-break-after:always;">&nbsp;</div>
<%

}//end while%>




<script>window.print();</script>


<%}//end vRetResult != null%>




</body>
</html>
<%
dbOP.cleanUP();
%>
