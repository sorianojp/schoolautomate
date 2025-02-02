<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
}

-->
</style>
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

</head>

<body>
<%@ page language="java" import="utility.*,enrollment.ReportRegistrarExtn,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	
	String[] astrConvertYear ={"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
	String[] astrConvertSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
	String[] astrConvertRegStat = {"Regular","Irregular"};

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORTS-Student list with INC","student_list_w_inc_view_one_print.jsp");
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
			strErrMsg = "Error in opening connection";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = 2;//comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
						//								"Registrar Management","REPORTS",request.getRemoteAddr(),
							//							"student_list_w_inc_view_one_print.jsp");
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
ReportRegistrarExtn RR = new ReportRegistrarExtn();
enrollment.GradeSystem GS = new enrollment.GradeSystem();

Vector vRetResult      = null;
Vector vStudInfo       = GS.getResidencySummary(dbOP, request.getParameter("stud_id"));
if(vStudInfo == null)
	strErrMsg = GS.getErrMsg();
else {
	strImgFileExt = "<img src=\"../../../upload_img/"+request.getParameter("stud_id")+"."+strImgFileExt+"\" width=125 height=125>";
	vRetResult  = RR.getListOfSubOfAStudWithINC(dbOP, (String)vStudInfo.elementAt(0),
					request.getParameter("report_type"), WI.getStrValue(WI.fillTextValue("sy_from"),null), 
					WI.getStrValue(WI.fillTextValue("semester"),null));
	if(vRetResult == null)
		strErrMsg = RR.getErrMsg();
}
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";strSchCode = "VMUF";
%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="985" height="16"><div align="center">
          <p align="right"><strong> </strong></div></td>
  </tr>
  <tr>
    <td height="73"><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
		   <%=SchoolInformation.getAddressLine2(dbOP,false,false)%> 
          <br>
          <br>
          <strong><font size="3">REGISTRAR'S OFFICE</font></strong><br>
          <br>
        <font size="2"><strong>LIST OF SUBJECTS WITH GRADE STATUS :<%=request.getParameter("report_type_name")%></strong><br>
          <font size="1"></font></font></div></td>
  </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#dddddd">
      <td height="20" colspan="4"><div align="center"><strong>:::: STUDENT DETAILS ::::</strong></div></td>
    </tr>
</table>
<%if(strErrMsg != null){%>  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr > 
    <td width="5%" height="20">&nbsp;</td>
    <td width="95%"> <font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
  </tr>
</table>

<%}
if(vStudInfo != null) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" >
  <tr> 
    <td height="20">&nbsp;</td>
    <td>Student ID</td>
    <td><strong><%=request.getParameter("stud_id")%></strong></td>
    <td width="37%" rowspan="6" valign="top"><%=strImgFileExt%></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td width="12%">Name</td>
    <td width="46%"><strong><%=WebInterface.formatName((String)vStudInfo.elementAt(1),(String)vStudInfo.elementAt(2),(String)vStudInfo.elementAt(3),1)%></strong></td>
  </tr>
  <tr> 
    <td width="5%" height="20">&nbsp;</td>
    <td>Course/Major</td>
    <td><strong><%=(String)vStudInfo.elementAt(6)%> 
      <%if(vStudInfo.elementAt(7) != null){%>
      /<%=(String)vStudInfo.elementAt(6)%> 
      <%}%>
      </strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20">Year</td>
    <td height="20"><strong><%=WI.getStrValue(vStudInfo.elementAt(10),"N/A")%></strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20"  colspan="2">Total units required for this course : <strong><%=WI.getStrValue(vStudInfo.elementAt(12),"0")%></strong></td>
  </tr>
  <tr> 
    <td height="20">&nbsp;</td>
    <td height="20" colspan="2">Total units completed : <strong><%=WI.getStrValue(vStudInfo.elementAt(13),"0")%></strong></td>
  </tr>
</table>
<%//System.out.println(vStudInfo);
}//if stud info not null

if(vRetResult != null && vRetResult.size() > 0) { %>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#dddddd"> 
      <td height="20" class="thinborderTOPLEFTRIGHT"><div align="center"><strong>::: LIST OF SUBJECTS :::</strong></div></td>
    </tr>
</table>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td width="20%" height="20" class="thinborder"><strong>SUBJECT CODE</strong></td>
    <td width="40%" class="thinborder"><strong>SUBJECT TITLE</strong></td>
<!--    <td width="13%"><strong>TOTAL UNITS</strong></td>-->
    <td width="13%" class="thinborder"><strong>FACULTY NAME</strong></td>
<%if(strSchCode.startsWith("VMUF")){%>
    <td width="12%" class="thinborder"><div align="center"><strong><font size="1">SIGNATURE</font></strong></div></td>
    <td width="10%" class="thinborder"><div align="center"><strong><font size="1">DATE</font></strong></div></td>
    <td width="10%" class="thinborder"><div align="center"><strong><font size="1">OR NUMBER</font></strong></div></td>
<%}%>
  </tr>
<%
int iSYFrom = 0; 
int iSYTo   = 0 ; 
int iSem    = 0;

String strDispSYInfo = null;

for(int i = 0 ; i< vRetResult.size() ; i += 7){
if(iSYFrom == 0 || Integer.parseInt((String)vRetResult.elementAt(i + 2)) != iSYFrom || 
	iSem != Integer.parseInt((String)vRetResult.elementAt(i + 4))) {
iSYFrom = Integer.parseInt((String)vRetResult.elementAt(i + 2));
iSYTo   = Integer.parseInt((String)vRetResult.elementAt(i + 3));
iSem    = Integer.parseInt((String)vRetResult.elementAt(i + 4));
strDispSYInfo = "<b> SY ("+(String)vRetResult.elementAt(i + 2)+" - "+(String)vRetResult.elementAt(i + 3)+"),"+ astrConvertSem[iSem];
}
else 
	strDispSYInfo = null;

if(strDispSYInfo != null){%>
  <tr> 
    <td height="20" colspan="2" class="thinborder"><%=strDispSYInfo%></td>
    <td class="thinborder">&nbsp;</td>
<%if(strSchCode.startsWith("VMUF")){%>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
<%}%>
  </tr>
<%}%>
	<tr> 
		<td height="20" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
<!--		<td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>-->
		<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"N/F")%></td>
<%if(strSchCode.startsWith("VMUF")){%>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
    <td class="thinborder">&nbsp;</td>
<%}%>
  </tr>
 <%}//end of for loop%>
</table>
<!-- print here. -->
<script language="javascript">
 window.print();

</script>

<%}//only if vRetResult not null
dbOP.cleanUP();
%>

</body>
</html>
