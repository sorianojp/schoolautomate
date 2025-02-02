<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
WebInterface WI = new WebInterface(request);


boolean bolIsBatchPrint = false;
if(WI.fillTextValue("batch_print").equals("1"))
	bolIsBatchPrint = true;

String strFontSize = "12";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<style type="text/css">
	<!--
	body {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=strFontSize%>px;
	}
	td {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=strFontSize%>px;
	}
	th {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=strFontSize%>px;
	}
	@media print { 
	  @page {
	  		size:9.50in 11in; 
			margin-bottom:0in;
			margin-top:.1in;
			margin-right:.1in;
			margin-left:.1in;
		}
	}
	-->
	</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script>
function PrintPg() {
	<%if(!bolIsBatchPrint){%>
		window.print();
		if(confirm('Click OK to Finish Printing and Close this page'))
			window.close();	
	<%}%>

}
</script>
<body bottommargin="0" onLoad="PrintPg();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

//authenticate this user.
	int iAccessLevel = 2;

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}




//add security here.
	try
	{
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

enrollment.ReportEnrollment reportEnrl= new enrollment.ReportEnrollment();
enrollment.EnrlAddDropSubject enrlStudInfo = new enrollment.EnrlAddDropSubject();

boolean bolIsBasic = false;

String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester"};

//list of student id
Vector vStudList = new Vector();
String strStudList = (String)request.getSession(false).getAttribute("stud_list");

request.getSession(false).removeAttribute("stud_list");

if(strStudList == null) {
	if(WI.fillTextValue("stud_id").length() > 0) 
		vStudList.addElement(WI.fillTextValue("stud_id"));
}
else 
	vStudList = CommonUtil.convertCSVToVector(strStudList);

String strStudID1     = null;
String strStudID2     = null;

String strSYFrom      = WI.fillTextValue("sy_from");
String strSYTo        = WI.fillTextValue("sy_to");
String strSemester    = WI.fillTextValue("offering_sem");
String strExamPeriod  = WI.fillTextValue("pmt_schedule");
String strExamName    = null;
if(strExamPeriod.length() > 0){
	strTemp = "select exam_name from fa_pmt_schedule where pmt_sch_index = "+strExamPeriod;
	strExamName = dbOP.getResultOfAQuery(strTemp, 0);
}

Vector vRetResult1  = null;//get subject schedule information.
Vector vRetResult2  = null;//get subject schedule information.

boolean bolAllowPrinting1 = false;
boolean bolAllowPrinting2 = false;

Vector vStudInfo1   = null; 
Vector vStudInfo2   = null; 

String strAdmSlipNo1   = null;
String strAdmSlipNo2   = null;

String strSection1 = null;
String strSection2 = null;

boolean bolPageBreak = false;
int iPrintCount = 0;

java.sql.PreparedStatement pstmt = null;
java.sql.ResultSet rs = null;
String strSQLQuery = "select section_name from stud_Curriculum_hist where user_index = ? and sy_from = "+strSYFrom+" and semester = "+strSemester+" and is_valid = 1";
pstmt = dbOP.getPreparedStatement(strSQLQuery);

if(vStudList != null && vStudList.size() > 0){
	while(vStudList.size() > 0){
		if(bolPageBreak){
			bolPageBreak = false;
		%>
			<div style="page-break-after:always;">&nbsp;</div>
		<%}
		
	bolAllowPrinting1 = false;	
	bolAllowPrinting2 = false;
	strStudID1    = null;
	strStudID2    = null;
	vStudInfo1    = null;
	vStudInfo2    = null;
	vRetResult1   = null;
	vRetResult2   = null;
	strAdmSlipNo1 = null;
	strAdmSlipNo2 = null;
	
	if(vStudList.size() > 0)
		strStudID1 = (String)vStudList.remove(0);	
	if(vStudList.size() > 0)
		strStudID2 = (String)vStudList.remove(0);	
	
	if(strStudID1 != null && strStudID1.length() > 0)
		vStudInfo1 = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),	strStudID1,strSYFrom, strSYTo, strSemester);
	if(strStudID2 != null && strStudID2.length() > 0)
		vStudInfo2 = enrlStudInfo.getEnrolledStudInfo(dbOP,(String)request.getSession(false).getAttribute("userId"),	strStudID2,strSYFrom, strSYTo, strSemester);	

	if(vStudInfo1 != null && vStudInfo1.size() > 0)
		bolAllowPrinting1 = true;
	if(vStudInfo2 != null && vStudInfo2.size() > 0)
		bolAllowPrinting2 = true;

if(bolAllowPrinting1) {
	vRetResult1 = reportEnrl.getStudentLoad(dbOP, strStudID1,strSYFrom, strSYTo, strSemester);
	if(vRetResult1 != null){		
		strAdmSlipNo1 = reportEnrl.autoGenAdmSlipNum(dbOP, (String)vStudInfo1.elementAt(0),strExamPeriod, strSYFrom, strSemester);					
		pstmt.setInt(1, Integer.parseInt((String)vStudInfo1.elementAt(0)));
		rs = pstmt.executeQuery();
		if(rs.next())
			strSection1 = rs.getString(1);
		rs.close();
	}
}

if(bolAllowPrinting2) {
	vRetResult2 = reportEnrl.getStudentLoad(dbOP, strStudID2,strSYFrom, strSYTo, strSemester);
	if(vRetResult2 != null)	{			
		strAdmSlipNo2 = reportEnrl.autoGenAdmSlipNum(dbOP, (String)vStudInfo2.elementAt(0),strExamPeriod, strSYFrom, strSemester);					
		pstmt.setInt(1, Integer.parseInt((String)vStudInfo2.elementAt(0)));
		rs = pstmt.executeQuery();
		if(rs.next())
			strSection2 = rs.getString(1);
		rs.close();
	}
}


if( (vStudInfo1 != null && vStudInfo1.size() > 0) || (vStudInfo2 != null && vStudInfo2.size() > 0)  ){
	
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%
	if(iPrintCount == 2){
	%>
		<tr><td height="58" colspan="2">&nbsp;</td></tr>	
	<%}%>
	<tr>
		
	<%
	/**
	if left side has no value, then the right side will accomodate the left side and leave the right side &nbsp;
	
	*/	
	if(vStudInfo1 != null && vStudInfo1.size() > 0){%>
		<td valign="top" width="50%">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<%if(iPrintCount == 0){%>
				<tr><td height="12"></td></tr>
				<%}%>
				<tr><td valign="bottom" align="center"><%=strExamName.toUpperCase()%> EXAMINATION PERMIT</td></tr>
			</table>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td width="50%" height="30" style="padding-left:80px;"><%=strStudID1%></td>
					<td style="padding-left:80px;" width="50%"><%=strAdmSlipNo1%></td>
				</tr>
				<tr>
					<td height="30" colspan="2"><%=(String)vStudInfo1.elementAt(1)%>
						&nbsp; &nbsp; &nbsp; &nbsp;
						<%//=(String)vStudInfo1.elementAt(16)%>
						<%//if(vStudInfo1.elementAt(6) != null){%>
							<!--/--> <%//=WI.getStrValue(vStudInfo1.elementAt(22))%>
						<%//}%><%//=WI.getStrValue((String)vStudInfo1.elementAt(4)," - ","","N/A")%>
						Section: <%=WI.getStrValue(strSection1)%>
					</td>		
				</tr>
			</table>
			
			
			<%if(vRetResult1 != null && vRetResult1.size() > 0) {%>
				<table width="100%" cellpadding="0" cellspacing="0">
					<tr>
						<%
						if(iPrintCount == 2)
							strTemp = "355px";
						else
							strTemp = "340px";
						%>
						<td valign="top" height="<%=strTemp%>">
							<table width="100%" cellpadding="0" cellspacing="0" border="0">
							  <tr>
								<td width="40%" height="50">&nbsp;</td>
								<td width="18%">&nbsp;</td>
								<td width="42%">&nbsp;</td>
							  </tr>
							   <%
							   int iCount = 0;
							   for(int i=1; i< vRetResult1.size(); i += 11){		   	
									strErrMsg = (String)vRetResult1.elementAt(i);
									if(strErrMsg != null && strErrMsg.startsWith("NSTP") && strErrMsg.indexOf("(")> 0)
										strErrMsg = strErrMsg.substring(0, strErrMsg.indexOf("("));			
								%>
								  <tr>
									<td><%=strErrMsg%></td>
									<td><%=(String)vRetResult1.elementAt(i+9)%></td>
									<td valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%;">&nbsp;</div></td>
								  </tr>
							  <%}%>
							</table>
						</td>
					</tr>
					<tr>
						<td><%=WI.getTodaysDateTime()%></td>
					</tr>
				</table>
			<%}%>
		</td>
		<%}
		
		if(vStudInfo2 != null && vStudInfo2.size() > 0){%>	
		<td valign="top" width="50%">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<%if(iPrintCount == 0){%>
				<tr><td height="12"></td></tr>
				<%}%>
				<tr><td valign="bottom" align="center"><%=strExamName.toUpperCase()%> EXAMINATION PERMIT</td></tr>
			</table>
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>
					<td width="50%" height="30" style="padding-left:60px;"><%=strStudID2%></td>
					<td style="padding-left:100px;" width="50%"><%=strAdmSlipNo2%></td>
				</tr>
				<tr>
					<td height="30" colspan="2" style="padding-left:30px;"><%=(String)vStudInfo2.elementAt(1)%>
						&nbsp; &nbsp; &nbsp; &nbsp;
						<%//=(String)vStudInfo2.elementAt(16)%>
						<%//if(vStudInfo2.elementAt(6) != null){%>
							<!--/--> <%//=WI.getStrValue(vStudInfo2.elementAt(22))%>
						<%//}%><%//=WI.getStrValue((String)vStudInfo2.elementAt(4)," - ","","N/A")%>
						Section: <%=WI.getStrValue(strSection1)%>
					</td>		
				</tr>
			</table>
			
			
			<%if(vRetResult2 != null && vRetResult2.size() > 0) {%>
				<table width="100%" cellpadding="0" cellspacing="0">
					<tr>
						<%
						if(iPrintCount == 2)
							strTemp = "355px";
						else
							strTemp = "340px";
						%>
						<td valign="top" height="<%=strTemp%>">
							<table width="100%" cellpadding="0" cellspacing="0" border="0">
							  <tr>
								<td width="51%" height="50">&nbsp;</td>
								<td width="14%">&nbsp;</td>
								<td width="35%">&nbsp;</td>
							  </tr>
							   <%
							   int iCount = 0;
							   for(int i=1; i< vRetResult2.size(); i += 11){		   	
									strErrMsg = (String)vRetResult2.elementAt(i);
									if(strErrMsg != null && strErrMsg.startsWith("NSTP") && strErrMsg.indexOf("(")> 0)
										strErrMsg = strErrMsg.substring(0, strErrMsg.indexOf("("));			
								%>
								  <tr>
									<td style="padding-left:30px;"><%=strErrMsg%></td>
									<td><%=(String)vRetResult2.elementAt(i+9)%></td>
									<td valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%;">&nbsp;</div></td>
								  </tr>
							  <%}%>
							</table>
						</td>
					</tr>
					<tr>
						<td style="padding-left:30px;"><%=WI.getTodaysDateTime()%></td>
					</tr>
				</table>
			<%}%>
		</td>
		<%}
		
		if( (vStudInfo1 == null || vStudInfo1.size() == 0 ) || (vStudInfo2 == null || vStudInfo2.size() == 0 ) ){
			//this will get the right side if the left size is empty..
			%>
			<td>&nbsp;</td>
		<%}%>
	</tr>
</table>



<%

iPrintCount+=2;

}//vRetResult is not null

if(iPrintCount >= 4){
	bolPageBreak = true;
	iPrintCount = 0;
}

}//end while
}//end vStudList != null && vStudList.size()
%>
</body>
</html>
<%
dbOP.cleanUP();
%>