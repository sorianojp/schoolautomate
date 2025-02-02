<%@ page language="java" import="utility.*,cashcard.CardManagement,java.util.Vector"%>
<%
	WebInterface WI  = new WebInterface(request);	
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>View Card Balance Page</title>
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-CASH CARD BALANCE INQUIRY"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD"),"0"));
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-CASH CARD BALANCE INQUIRY","card_balance.jsp");	
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
	
	Vector vRetResult = null;
	Vector vStudInfo = null;
	int iSearchResult = 0;
	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr"};

	
	CardManagement cm = new CardManagement();
	enrollment.OfflineAdmission OAdm = new enrollment.OfflineAdmission();
	boolean bolIsStaff = false;
	boolean bolIsStudEnrolled = false;
	boolean bolBasicStudent = false;
	
	String strStudID = WI.fillTextValue("stud_id");

	if(strStudID.length() > 0) {
		if(bolIsSchool) {
			vStudInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"));				
			if(vStudInfo == null) //may be it is the teacher/staff
			{
				request.setAttribute("emp_id",request.getParameter("stud_id"));
				vStudInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
				if(vStudInfo != null)
					bolIsStaff = true;
			}
			else {//check if student is currently enrolled
				Vector vTempBasicInfo = OAdm.getStudentBasicInfo(dbOP, WI.fillTextValue("stud_id"),
				(String)vStudInfo.elementAt(10),(String)vStudInfo.elementAt(11),(String)vStudInfo.elementAt(9));
				if(vTempBasicInfo != null){
					bolIsStudEnrolled = true;
					if(((String)vTempBasicInfo.elementAt(5)).equals("0"))
						bolBasicStudent = true;
					//System.out.println("vTempBasicInfo: "+vTempBasicInfo);
				}
	 		}
			if(vStudInfo == null)
				strErrMsg = OAdm.getErrMsg();
		}
		else{//check faculty only if not school...
			request.setAttribute("emp_id",request.getParameter("stud_id"));
			vStudInfo = new enrollment.Authentication().operateOnBasicInfo(dbOP, request,"0");
			if(vStudInfo != null)
				bolIsStaff = true;
			if(vStudInfo == null)
				strErrMsg = "Employee Information not found.";
		}
		}
	else
		strErrMsg = "Please provide ID Number.";
	
	if(vStudInfo != null){
		String strUserIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("stud_id"));
		
		vRetResult = cm.generateStudentLedger(dbOP, request, strUserIndex);
		if(vRetResult == null)
			strErrMsg = cm.getErrMsg();
		else
			iSearchResult = cm.getSearchCount();
	}
	
	
	
	int iElemCount    = 8; //vector row count	
%>		
<body>


<%if(strErrMsg != null){%>
	<div align="center"><strong><font size="2" color="#FF0000"><%=strErrMsg%></font></strong></div>
<%}



if(vStudInfo != null && vStudInfo.size() > 0 && vRetResult != null && vRetResult.size() > 0 ) {	
	


int iRowCount = 1;
int iNoOfRowPerPage = 35;

if(WI.fillTextValue("rows_per_pg").length() > 0)
	iNoOfRowPerPage = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
	
	

int iPageCount = 1;
int iTotalCount = (vRetResult.size()/iElemCount);
int iTotalPageCount = iTotalCount/iNoOfRowPerPage;
if(iTotalCount % iNoOfRowPerPage > 0)
	++iTotalPageCount;
boolean bolPageBreak = false;

for(int i = 0; i < vRetResult.size();){
	iRowCount = 1;
	if(bolPageBreak){
		bolPageBreak = false;
%>
	<div style="page-break-after:always;">&nbsp;</div>
	<%}%>
	
<table width="100%" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">	
	<tr><td align="center"><strong>
		<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
		<%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
		CASH CARD LEDGER REPORT <%=WI.fillTextValue("date_fr")%><%=WI.getStrValue(WI.fillTextValue("date_to"),"-","","")%>
		<br><%=WI.fillTextValue("terminal_name").toUpperCase()%>
	</strong></td></tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<%if(!bolIsStaff){%>
    	<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Student Name : </td>
			<td width="43%"><strong><%=WebInterface.formatName((String)vStudInfo.elementAt(0), (String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),4)%></strong></td>
			<td width="13%">Status : </td>
			<td width="24%"><%if(bolIsStudEnrolled){%>Currently Enrolled<%}else{%>Not Currently Enrolled<%}%></td>
		</tr>
<%if(!bolBasicStudent){%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Course/Major :</td>
			<td height="25" colspan="3">
				<%
					strTemp = WI.getStrValue((String)vStudInfo.elementAt(7));
					strErrMsg = WI.getStrValue((String)vStudInfo.elementAt(8));
					if(strErrMsg.length() > 0)
						strTemp += "/" + strErrMsg;
				%>
		    <%=strTemp%></td>
		</tr>
<%}%>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Year :</td>
			<td colspan="3">
				<%
					if(bolBasicStudent)
						strTemp = dbOP.getBasicEducationLevel(Integer.parseInt((String)vStudInfo.elementAt(14)));
					else
						strTemp = astrConvertYrLevel[Integer.parseInt((String)vStudInfo.elementAt(14))];
				%>
				<%=strTemp%></td>
		</tr>
	<%}else{%>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Emp. Name :</td>
			<td width="43%"><strong><%=WebInterface.formatName((String)vStudInfo.elementAt(1), (String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),4)%></strong></td>
			<td width="13%">Emp. Status :</td>
			<td width="24%"><strong><%=(String)vStudInfo.elementAt(16)%></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office :</td>
			<td><strong><%=WI.getStrValue(vStudInfo.elementAt(13))%>/<%=WI.getStrValue(vStudInfo.elementAt(14))%></strong></td>
			<td>Designation :</td>
			<td><strong><%=(String)vStudInfo.elementAt(15)%></strong></td>
		</tr>
	<%}//only if staff %>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" width="3%"></td>
			<td width="17%">Card Balance:</td>
			<td width="80%">
				<%
					if(vRetResult != null && vRetResult.size() > 0)
						strTemp = (String)vRetResult.elementAt(vRetResult.size() - 2);
					else
						strTemp = "0";
					strTemp = CommonUtil.formatFloat(strTemp, true);
				%>
				<%=strTemp%></td>			
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>


	<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">		
		<tr>
		  	<td width="12%" height="22" align="center" class="thinborder"><strong>Date</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Reference # </strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Particulars</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Collected by</strong></td>			
			<td width="12%" align="center" class="thinborder"><strong>Debit</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Credit</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Balance</strong></td>
		</tr>
	<%for(; i < vRetResult.size(); i += iElemCount){%>
		<tr>
			<td height="22" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2), "&nbsp;")%></td>
			<td class="thinborder">
				<%=WI.getStrValue((String)vRetResult.elementAt(i+3), "&nbsp;")%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i), " (Location: ", ")", "&nbsp;")%></td>
			<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+7), "&nbsp;")%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+4);
				if(Double.parseDouble(strTemp) > 0d)
					strTemp = CommonUtil.formatFloat(strTemp, true);
				else
					strTemp = "&nbsp;";
			%>
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i+5);
				if(Double.parseDouble(strTemp) > 0d)
					strTemp = CommonUtil.formatFloat(strTemp, true);
				else
					strTemp = "&nbsp;";
			%>
			<td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+6), true)%>&nbsp;</td>
		</tr>
	<%
	if(iRowCount++ >= iNoOfRowPerPage){		
		i+=iElemCount;
		bolPageBreak = true;
		break;
	}
	}
	%>
	</table>
	
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0">
	<tr>
		<td width="48%"><font size="1">Date and Time Printed : <%=WI.formatDateTime(null,4)%></font></td>
		<td width="52%" height="16" align="right"><font size="1">Page <%=iPageCount++%> of <%=iTotalPageCount%></font></td>
	</tr>
	</table>
	
<%}//outer loop%>
<script>window.print();</script>	
<%}%>

	
		
</body>
</html>
<%
dbOP.cleanUP();
%>