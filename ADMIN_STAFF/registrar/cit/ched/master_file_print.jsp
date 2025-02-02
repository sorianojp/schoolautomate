<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Transferee Info Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<body onLoad="window.print()">
<%@ page language="java" import="utility.*,enrollment.CITChedBilling,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-CHED Scholar-manage Scholarship Type","master_file_print.jsp");
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
														"Registrar Management","CHED SCHOLAR",request.getRemoteAddr(),
														"master_file.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

CITChedBilling CCB = new CITChedBilling();
Vector vRetResult = null; 
String strPrevSYTerm = null;
String[] astrConvertSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM"};

String strSchloarType = WI.fillTextValue("scholar_type");
String strScholarName = null;
strSchloarType = "select SCHOLAR_CODE, SCHOLAR_NAME from CIT_CHED_SCHOLAR_TYPE where SCHOLAR_TYPE_INDEX = "+WI.fillTextValue("scholar_type");
java.sql.ResultSet rs = dbOP.executeQuery(strSchloarType);
if(rs.next()) {
	strSchloarType = rs.getString(1);
	strScholarName = rs.getString(2);
}

strTemp = WI.fillTextValue("page_action");
if(strTemp.equals("0")) {
	strTemp = "update CIT_CHED_SCHOLAR set is_valid = 0 where SCHOLAR_INDEX = "+WI.fillTextValue("info_index");
	dbOP.executeUpdateWithTrans(strTemp, null, null, false);
}

if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = CCB.generateMasterFile(dbOP, request);
	if(vRetResult == null) 
		strErrMsg = CCB.getErrMsg();

	//make the prev sy/term information.
	int iSYFrom   = Integer.parseInt(WI.fillTextValue("sy_from"));
	int iSYTo     = iSYFrom + 1;
	int iSemester = Integer.parseInt(WI.fillTextValue("semester"));
	
	if(iSemester == 1) {
		--iSYFrom; --iSYTo;
		iSemester = 2;
	}
	else
		iSemester = 1;
	
	strPrevSYTerm= astrConvertSem[iSemester]+", AY "+Integer.toString(iSYFrom)+" - "+Integer.toString(iSYTo);
}


%>
<%if(vRetResult != null && vRetResult.size() > 0) {

int iDefNoOfRowPerPg = 0;
if(request.getParameter("rows_per_page") == null)
	iDefNoOfRowPerPg = 40;
else
	iDefNoOfRowPerPg = Integer.parseInt(request.getParameter("rows_per_page"));
int iRowCount = 0;

for(int i = 0;i < vRetResult.size();) {
	if(i > 0) {%>
		<DIV style="page-break-after:always" >&nbsp;</DIV>
	<%iRowCount = 0;}%>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	  <td height="25" align="center">
	  <font size="3"><b>COMMISSION ON HIGHER EDUCATION <br>
	  REGIONAL OFFICE VII</b></font><br>
		<br>
	  CERTIFICATION OF ENROLMENT AND GRADES-GWA OF CHED STUFAPs GRANTEES<br>
	  <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> SEMESTER, ACADEMIC YEAR 
	  <%=WI.fillTextValue("sy_from")%>-<%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%>
		<br>&nbsp;	  </td>
    </tr>
	<tr>
	  <td height="25">Name of HEI: Cebu Institute of Technology - University<br>
      Type of STUFAP: <%=strScholarName%></td>
    </tr>
	<tr>
	  <td align="center">&nbsp;</td>
    </tr>
	</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr align="center" style="font-weight:bold">
      <td width="3%" height="25" style="font-size:9px" class="thinborder">COUNT</td>
      <td width="10%" style="font-size:9px" class="thinborder">AWARD NO.</td>
      <td width="10%" style="font-size:9px" class="thinborder">LAST NAME</td>
      <td width="10%" style="font-size:9px" class="thinborder">FIRST NAME</td>
      <td width="3%" style="font-size:9px" class="thinborder">MI</td>
      <td width="3%" style="font-size:9px" class="thinborder">SEX</td>
      <td width="12%" style="font-size:9px" class="thinborder">COURSE</td>
      <td width="4%" style="font-size:9px" class="thinborder">YEAR LEVEL</td>
      <td width="10%" style="font-size:9px" class="thinborder"> GRADES-GWA GRANTEES <br>
					   PREVIOUS SEMESTER<br>
					   <%=strPrevSYTerm%>	  </td>
      <td width="10%" style="font-size:9px" class="thinborder"> CURRENT SEMESTER <br>
	  				   UNITS ENROLLED<br>
					   <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, AY <%=WI.fillTextValue("sy_from")%> - <%=Integer.parseInt(WI.fillTextValue("sy_from")) + 1%></td>
      <td width="10%" style="font-size:9px" class="thinborder">REMARKS*</td>
    </tr>
<%
int iCount =0; 
for(;i < vRetResult.size(); i += 15) {
	++iRowCount;
	if(iRowCount >= iDefNoOfRowPerPg)
		break;
%>
    <tr>
      <td height="25" style="font-size:9px" class="thinborder"><%=++iCount%></td>
      <td style="font-size:9px" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td style="font-size:9px" class="thinborder"><%=vRetResult.elementAt(i + 6)%></td>
      <td style="font-size:9px" class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
<%
strTemp = (String)vRetResult.elementAt(i + 5);
if(strTemp != null) {
	if(strTemp.length() > 0)
		strTemp = String.valueOf(strTemp.charAt(0));
}%>
      <td style="font-size:9px" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
      <td style="font-size:9px" class="thinborder"><%=vRetResult.elementAt(i + 7)%></td>
<%
//course.. 
strTemp = (String)vRetResult.elementAt(i + 8);
if(vRetResult.elementAt(i + 10) != null) {
	strTemp = strTemp + " - "+(String)vRetResult.elementAt(i + 10);
}%>
      <td style="font-size:9px" class="thinborder"><%=strTemp%></td>
      <td style="font-size:9px" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 12),"&nbsp;")%></td>
      <td style="font-size:9px" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3),"&nbsp;")%></td>
      <td style="font-size:9px" class="thinborder"><%=vRetResult.elementAt(i + 13)%></td>
      <td style="font-size:9px" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 2),"&nbsp;")%></td>
    </tr>
<%}%>
  </table>
  <br>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	  <td height="35" colspan="2">
	  *Status of grantee may either be that the grantee is a new grantee, a replacement, graduated from the course, dropped from the course, transferred to another school,etc.	  </td>
    </tr>
	<tr valign="bottom">
	  <td width="50%" height="25">Prepared by:</td>
      <td width="50%"><strong>Certified Correct:</strong></td>
	</tr>
	<tr valign="bottom">
	  <td height="45" align="center">
	  <u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=CommonUtil.getNameForAMemberType(dbOP, "Scholarship Coordinator",7)%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
      <td height="45" align="center">
	  <u>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7),"GRETCHEN LIZARES - TORMIS, MBA")%>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</u></td>
	</tr>
	<tr align="center" valign="top">
	  <td height="25">
	  HEI Scholarship Coordinator
	  <br>(Printed name & Signature)	  </td>
      <td height="25">
	  University Registrar <br>
	  (Printed name & Signature)
	  </td>
	</tr>
	</table>
  
<%}//Outer loop.. 
}
%>  
</body>
</html>
<%
dbOP.cleanUP();
%>
