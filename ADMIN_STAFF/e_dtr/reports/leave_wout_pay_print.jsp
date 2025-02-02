<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTRExtn"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Leave Summary per Department/office</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head> 
<script language="JavaScript" src="../../../jscript/common.js"></script> 
<%	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Leave Application","leave_summary_auf.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(),
														"leave_summary_auf.jsp");

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
Vector vRetResult = null;
Vector vEmpRec = null; 
Vector vEmpLeaves = null;

int iSearchResult = 0;
ReportEDTRExtn rptLeave = new ReportEDTRExtn(request);
int iAction =  -1;


String[] astrMonth = {" Select Month"," January"," February", " March", " April", " May", " June",
					  " July", " August", " September"," October", " November", " December"};
 String strSYFrom = WI.fillTextValue("sy_from");
 String strSYTo = WI.fillTextValue("sy_to");
 String strSemester = WI.fillTextValue("semester");
 
 String[] astrNature = {"Sick Leave", "Maternity Leave","Vacation Leave","Emergency Leave",
 												"Paternity Leave","Bereavement Leave","Others"};

	String strOffice = "";
	Long lUserIndex = null;
	String strSem = null;
	int iLeaves = 0;
	double dHour = 0d;
	double dMin = 0d;
	double dDuration = 0d;
	double dTotalLeave = 0d;
	int i = 0;
	boolean bolPageBreak = false;

 	vRetResult = rptLeave.viewLeavesWoutPaySummaryAUF(dbOP, request);	
	if (vRetResult != null) {	
		int iCount = 0;
 		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){
%>
<body onLoad="javescript:window.print();">
<form name="form_">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="center">ANGELES UNIVERSITY FOUNDATION </td>
    </tr>
  <tr>
    <td align="center">Angeles City </td>
    </tr>
  <tr>
    <td height="23">&nbsp;</td>
  </tr>
  <tr>
  <%
	  if(!WI.fillTextValue("strMonth").equals("0"))
			strTemp = " for month of " + astrMonth[Integer.parseInt(WI.getStrValue(WI.fillTextValue("strMonth"),"0"))] + " " + WI.fillTextValue("year_of");
		else
			strTemp = " between " + WI.fillTextValue("date_fr") + " and " + WI.fillTextValue("date_to");
	%>
    <td align="center">Leave without pay <%=strTemp%> </td>
    </tr>
</table>

   <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td>		
		<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>
		  <td width="27%" rowspan="2" align="center" class="thinborder"><strong>NAME</strong></td> 
			<td width="11%" rowspan="2" align="center" class="thinborder"><strong>UNIT</strong></td>
			<td height="12" colspan="4" align="center" class="thinborder"><strong>DURATION</strong></td>
			<td width="26%" rowspan="2" align="center" class="thinborder"><strong>REMARKS</strong></td>
		</tr>
		<tr>
		  <td width="11%" height="13" align="center" class="thinborder"><strong>FROM</strong></td>
			<td width="11%" align="center" class="thinborder"><strong>TO</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>HRS</strong></td>
			<td width="7%" align="center" class="thinborder"><strong>MIN</strong></td>
		</tr>
		<% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=14,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;	
						
			vEmpLeaves = (Vector)vRetResult.elementAt(i+10);
			dTotalLeave = 0d;
		%>
		<%
		if(vEmpLeaves != null && vEmpLeaves.size() > 0){
		strSem = null;
		for(iLeaves = 0; iLeaves < vEmpLeaves.size(); iLeaves+=21){%>
		<tr>		
			<%
			strTemp = "";
			strTemp2 = "";
			if(iLeaves == 0){
				strTemp = (String)vRetResult.elementAt(i+1) + "<br>";
				strTemp += WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4), 4);
				
			}
			%>
		  <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
				if((String)vRetResult.elementAt(i+8) != null)
					strTemp2 = (String)vRetResult.elementAt(i+8);
				else
					strTemp2 = (String)vRetResult.elementAt(i+9);			
			%>
		  <td class="thinborder"><%=WI.getStrValue(strTemp2,"&nbsp;")%></td> 
		 <td height="25" class="thinborder">&nbsp;<%=(String)vEmpLeaves.elementAt(iLeaves)%></td>
		 <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue((String)vEmpLeaves.elementAt(iLeaves+4),"&nbsp;")%></td>
		 <%
		 	strTemp = WI.getStrValue((String)vEmpLeaves.elementAt(iLeaves+17),"0");
			dDuration = Double.parseDouble(strTemp);
			dHour = (int)dDuration;
			dMin = (int)((dDuration  - dHour) * 60);
			dTotalLeave += dDuration;
		 %>
		 <td height="25" align="right" class="thinborder"><%=Double.toString(dHour)%>&nbsp;</td>
		 <td height="25" align="right" class="thinborder"><%=Double.toString(dMin)%>&nbsp;</td>
		 <td class="thinborder"><%=WI.getStrValue((String)vEmpLeaves.elementAt(iLeaves+16),"&nbsp;")%></td>
		</tr>
		<%} // end for loop %>
		<%}
 		}%>
	</table>
		
		</td>
  </tr>
	</table>
	 <table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="67%">&nbsp;</td>
    <td width="33%">&nbsp;</td>
  </tr>
  <tr>
    <td>Noted By :</td>
    <td>Prepared By : </td>
  </tr>
  <tr>
    <td height="24"><%=WI.fillTextValue("noted_by")%></td>
    <td class="thinborderBOTTOM">&nbsp;<%=WI.fillTextValue("prepared_by")%></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>date printed : <%=WI.getTodaysDateTime()%></td>
  </tr>
</table>

<%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
