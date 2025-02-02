 <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<body>

<%@ page language="java" import="utility.*,enrollment.CertificationReport,java.util.Vector, java.util.Date" %>

<%
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	WebInterface WI   = new WebInterface(request);
	
	
//add security here.
	try
	{
		/**dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-Reports-Book Distribution Per Course","book_distribution_per_course.jsp");**/
		dbOP = new DBOperation();
								
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
														"index.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../../../../../../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

Vector vRetResult = new Vector();
CertificationReport certReport = new CertificationReport();
String strGender = null;
String strHisHer = null;
String strhisher = null;
String strSheHe = null;
String strshehe = null;

if(WI.fillTextValue("stud_id").length() > 0){
	vRetResult = certReport.getStudDetailForCertificate(dbOP, request);
	if(vRetResult == null)
		strErrMsg = certReport.getErrMsg();
}

if(strErrMsg != null){
	%>
	
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center"><font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td></tr>
</table>


<%}if(vRetResult != null && vRetResult.size() > 0){

if(((String)vRetResult.elementAt(5)).equals("M")){
	strGender = "MR.";
	strHisHer = "His.";
	strhisher = "his";
	strSheHe = "He";
	strshehe = "he";
}else{
	strGender = "MS.";
	strHisHer = "Her.";
	strhisher = "her";
	strSheHe = "She";
	strshehe = "she";
}

String[] astrConvertSem = {"Summer", "First Semester", "Second Semester", "Third Semester", "Fourth Semester"};
String[] astrConvertYear = {"","First Year", "Second Year", "Third Year", "Fourth Year", "Fifth Year", "Sixth Year"};
%>
		    
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="15%">&nbsp;</td>
		<td>
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr><td height="200px" align="center" valign="bottom"><font size="+1"><strong>OFFICE OF THE UNIVERSITY REGISTRAR</strong></font></td></tr>
				<tr><td align="center" valign="bottom" height="70px"><font size="+2"><u><strong>C E R T I F I C A T I O N</strong></u></font></td></tr>
				<tr><td height="70">&nbsp;</td></tr>
				<tr>
					<td height="150px" align="justify" style="word-spacing:2px;">&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
							This is to certify that <strong><%=strGender%> <%=WebInterface.formatName((String)vRetResult.elementAt(2),(String)vRetResult.elementAt(3),(String)vRetResult.elementAt(4),7)%></strong> is presently enrolled
							as a <%=astrConvertYear[Integer.parseInt((String)vRetResult.elementAt(6))]%> student at the <%=(String)vRetResult.elementAt(8)%> (<%=(String)vRetResult.elementAt(14)%>) of our University for the <%=astrConvertSem[Integer.parseInt((String)vRetResult.elementAt(11))]%> SY
							<%=(String)vRetResult.elementAt(9)%>-<%=(String)vRetResult.elementAt(10)%>.
							<br><br>
							&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; This certification is being issued this <%=WI.getTodaysDate(14)%> upon the
							request of <strong><%=strGender%> <%=(String)vRetResult.elementAt(4)%></strong> for whatever legal purpose(s) this may serve.
					</td>
				</tr>
				<tr><td height="120" valign="bottom">
					<table width="100%">
						<tr>
							<td width="50%">&nbsp;</td>
							<td align="center"><strong><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP,"University Registrar",1)).toUpperCase()%></strong></td>
						</tr>
						<tr>
							<td width="50%">&nbsp;</td>
							<td align="center">University Registar</td>
						</tr>
					</table>
				</td></tr>
				
				<tr><td height="200" valign="bottom"><font size="1"><i>NOT VALID WITHOUT<BR>SCHOOL SEAL</i></font></td></tr>
				
			</table>
		</td>
		<td width="15%">&nbsp;</td>
	</tr>
</table>

  

  
<%}%>
<%
dbOP.cleanUP();
if(strErrMsg == null) {//no error.%>
<script language="javascript">
window.print();

</script>
<%}%>
</body>
</html>

