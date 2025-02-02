<%@ page language="java" import="utility.*,enrollment.CreditEvaluation,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Credit Evaluation</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD{
	font-size:10px;
	font-family:Verdana, Arial, Helvetica, sans-serif;
}
TD.thinborderTOP {
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;	
	String strTemp = null;
	String strErrMsg = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-CREDIT EVALUATION-CREDIT EVALUATION","credit_eval.jsp");
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
															"Enrollment","CREDIT EVALUATION",request.getRemoteAddr(),
															null);
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission","Registration",request.getRemoteAddr(),
														null);
	}
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
	
	String strEvaluatedBy = null;
	String strCreateTime = null;
	String strComment = null;
	String[] astrStatus = {"", "C", "T", "P"};
	String[] astrYear = {"", "First Year", "Second Year", "Third Year", "Fourth Year", "Fifth Year", "Sixth Year", "Seventh Year", "Eigth Year"};
	String[] astrSemester = {"Summer", "First Semester", "Second Semester", "Third Semester"};
	boolean bolHasEntry = false;
	Vector vInfo = null;
	Vector vSubjects = null;
	CreditEvaluation ce = new CreditEvaluation();	
	
	vInfo = ce.getTempStudInfo(dbOP, request);
	if(vInfo == null)
		strErrMsg = ce.getErrMsg();
	else{
		vSubjects = ce.getSubjsForCredEval(dbOP, request, vInfo);
		if(vSubjects == null)
			ce.getErrMsg();
		else{
			strEvaluatedBy = (String)vSubjects.remove(0);
			strCreateTime = (String)vSubjects.remove(0);
			strComment = WI.getStrValue((String)vSubjects.remove(0));
		}
	}
	
	if(vInfo != null && vInfo.size() > 0){%>
	<input type="hidden" name="application_index" value="<%=(String)vInfo.elementAt(0)%>">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" width="27%"><%=(String)vInfo.elementAt(1)%></td>
			<td width="46%" rowspan="2" align="center" valign="top"><font size="2"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td>
			<td width="27%" align="right"><%=strCreateTime%></td>
		</tr>
		<tr>
			<td height="18"><%=WI.fillTextValue("temp_id")%></td>
			<td align="right"><%=WI.getStrValue(strEvaluatedBy, "Evaluated by: ", "", "")%></td>
		</tr>
		<tr>
		  <td colspan="5" align="center"><font size="2"><%=(String)vInfo.elementAt(10)%><%=WI.getStrValue((String)vInfo.elementAt(12), "-", "", "")%><br>
		    CURRICULUM YEAR <%=(String)vInfo.elementAt(7)%> - <%=(String)vInfo.elementAt(8)%></font></td>
		</tr>
	</table>
<%}

int iCount = 1;
boolean bolChange = false;
Vector vTemp = null;
Vector vFirst = null;
Vector vSecond = null;
Vector vSummer = null;

String strSubIndex = null;
String strSubCode = null;
String strSubName = null;
String strLecUnit = null;
String strLabUnit = null;
String strYear = null;
String strSemester = null;
String strStatus = null;
String strCurrentSem = null;

double dLecUnit = 0d;
double dLabUnit = 0d;

if(vSubjects != null && vSubjects.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%for(int i = 0; i < vSubjects.size(); i += 2){
		vFirst = new Vector();
		vSecond = new Vector();
		vSummer = new Vector();
		vTemp = (Vector)vSubjects.elementAt(i+1);
		while(vTemp.size() > 0){
			strTemp = (String)vTemp.elementAt(6);//semester
			if(strTemp.equals("2")){//if 2nd sem
				vSecond.addElement((String)vTemp.remove(0));vSecond.addElement((String)vTemp.remove(0));
				vSecond.addElement((String)vTemp.remove(0));vSecond.addElement((String)vTemp.remove(0));
				vSecond.addElement((String)vTemp.remove(0));vSecond.addElement((String)vTemp.remove(0));
				vSecond.addElement((String)vTemp.remove(0));vSecond.addElement((String)vTemp.remove(0));
			}
			else if(strTemp.equals("1")){//if first sem and summer
				vFirst.addElement((String)vTemp.remove(0));vFirst.addElement((String)vTemp.remove(0));
				vFirst.addElement((String)vTemp.remove(0));vFirst.addElement((String)vTemp.remove(0));
				vFirst.addElement((String)vTemp.remove(0));vFirst.addElement((String)vTemp.remove(0));

				vFirst.addElement((String)vTemp.remove(0));vFirst.addElement((String)vTemp.remove(0));
			}
			else{
				vSummer.addElement((String)vTemp.remove(0));vSummer.addElement((String)vTemp.remove(0));
				vSummer.addElement((String)vTemp.remove(0));vSummer.addElement((String)vTemp.remove(0));
				vSummer.addElement((String)vTemp.remove(0));vSummer.addElement((String)vTemp.remove(0));
				vSummer.addElement((String)vTemp.remove(0));vSummer.addElement((String)vTemp.remove(0));
			}
		}
	%>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td width="2%">&nbsp;</td>
			<td width="47%" valign="top">
				<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<%
				dLecUnit = 0d;
				dLabUnit = 0d;
				bolHasEntry = false;
				while(vFirst.size() > 0){
					bolHasEntry = true;
					iCount++;
					bolChange = false;
					strSubIndex = (String)vFirst.remove(0);
					strSubCode = (String)vFirst.remove(0);
					strSubName = (String)vFirst.remove(0);
					strLecUnit = (String)vFirst.remove(0);
					strLabUnit = (String)vFirst.remove(0);
					strYear = (String)vFirst.remove(0);
					strSemester = (String)vFirst.remove(0);
					strStatus = WI.getStrValue((String)vFirst.remove(0), "0");
					
					if(strCurrentSem == null){
						strCurrentSem = strSemester;
						bolChange = true;
					}
					
					if(!strCurrentSem.equals(strSemester)){					
						strCurrentSem = strSemester;
						bolChange = true;
					}
					
					dLecUnit += Double.parseDouble(strLecUnit);
					dLabUnit += Double.parseDouble(strLabUnit);
				
				if(bolChange){%>
					<tr>
						<td height="15" colspan="3" align="center">
							<u><%=astrYear[Integer.parseInt(strYear)]%> - <%=astrSemester[Integer.parseInt(strSemester)]%></u></td>
					</tr>
				<%}%>
					<tr>
						<td height="15" width="10%" align="right"><%=astrStatus[Integer.parseInt(strStatus)]%>&nbsp;</td>
						<td width="75%"><%=strSubCode%> - <%=strSubName%></td>
						<td width="15%" align="right"><%=strLecUnit%>/<%=strLabUnit%></td>
					</tr>
				<%}
				if(bolHasEntry){%>
					<tr>
						<td height="15" colspan="2">&nbsp;</td>
						<td class="thinborderTOP" align="right"><%=dLecUnit%>/<%=dLabUnit%></td>
					</tr>
				<%}
				dLecUnit = 0d;
				dLabUnit = 0d;
				bolHasEntry = false;
				while(vSummer.size() > 0){
					bolHasEntry = true;
					iCount++;
					bolChange = false;
					strSubIndex = (String)vSummer.remove(0);
					strSubCode = (String)vSummer.remove(0);
					strSubName = (String)vSummer.remove(0);
					strLecUnit = (String)vSummer.remove(0);
					strLabUnit = (String)vSummer.remove(0);
					strYear = (String)vSummer.remove(0);
					strSemester = (String)vSummer.remove(0);
					strStatus = WI.getStrValue((String)vSummer.remove(0), "0");
					
					if(strCurrentSem == null){
						strCurrentSem = strSemester;
						bolChange = true;
					}
					
					if(!strCurrentSem.equals(strSemester)){					
						strCurrentSem = strSemester;
						bolChange = true;
					}
					
					dLecUnit += Double.parseDouble(strLecUnit);
					dLabUnit += Double.parseDouble(strLabUnit);
					
				if(bolChange){%>
					<tr>
						<td height="15" colspan="3" align="center">&nbsp;</td>
					</tr>
					<tr>
						<td height="15" colspan="3" align="center">
							<u><%=astrYear[Integer.parseInt(strYear)]%> - <%=astrSemester[Integer.parseInt(strSemester)]%></u></td>
					</tr>
				<%}%>
					<tr>
				  	  <td height="15" width="10%" align="right"><%=astrStatus[Integer.parseInt(strStatus)]%>&nbsp;</td>
						<td width="75%"><%=strSubCode%> - <%=strSubName%></td>
						<td width="15%" align="right"><%=strLecUnit%>/<%=strLabUnit%></td>
					</tr>
				<%}
				if(bolHasEntry){%>
					<tr>
						<td height="15" colspan="2">&nbsp;</td>
						<td class="thinborderTOP" align="right"><%=dLecUnit%>/<%=dLabUnit%></td>
					</tr>
				<%}%>
				</table></td>
			<td width="2%">&nbsp;</td>
			<td width="47%" valign="top">
				<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
				<%
				strCurrentSem = null;
				dLecUnit = 0d;
				dLabUnit = 0d;
				bolHasEntry = false;
				while(vSecond.size() > 0){
					bolHasEntry = true;
					iCount++;
					bolChange = false;
					strSubIndex = (String)vSecond.remove(0);
					strSubCode = (String)vSecond.remove(0);
					strSubName = (String)vSecond.remove(0);
					strLecUnit = (String)vSecond.remove(0);
					strLabUnit = (String)vSecond.remove(0);
					strYear = (String)vSecond.remove(0);
					strSemester = (String)vSecond.remove(0);
					strStatus = WI.getStrValue((String)vSecond.remove(0), "0");
					
					if(strCurrentSem == null){
						strCurrentSem = strSemester;
						bolChange = true;
					}
					
					if(!strCurrentSem.equals(strSemester)){
						strCurrentSem = strSemester;
						bolChange = true;
					}
					
					dLecUnit += Double.parseDouble(strLecUnit);
					dLabUnit += Double.parseDouble(strLabUnit);
					
				if(bolChange){%>
					<tr>
						<td height="15" colspan="3" align="center">
							<u><%=astrYear[Integer.parseInt(strYear)]%> - <%=astrSemester[Integer.parseInt(strSemester)]%></u>
						</td>
					</tr>
				<%}%>
					<tr>
						<td height="15" width="10%" align="right"><%=astrStatus[Integer.parseInt(strStatus)]%>&nbsp;</td>
						<td width="75%"><%=strSubCode%> - <%=strSubName%></td>
						<td width="15%" align="right"><%=strLecUnit%>/<%=strLabUnit%></td>
					</tr>				
				<%}
				if(bolHasEntry){%>
					<tr>
						<td height="15" colspan="2">&nbsp;</td>
						<td class="thinborderTOP" align="right"><%=dLecUnit%>/<%=dLabUnit%></td>
					</tr>
				<%}%>
				</table></td>
			<td width="2%">&nbsp;</td>
		</tr>
	<%}%>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<!--
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		-->
		<tr>
			<td height="15" width="3%">&nbsp;</td>
			<td width="17%">Comment:</td>
			<td width="80%"><%=strComment%></td>
		</tr>
		<tr>
		  <td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
		  <td height="15" colspan="3" align="center">
				C - Credited&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				T - Temp Credit&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				P - Passed</td>
		</tr>
	</table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>