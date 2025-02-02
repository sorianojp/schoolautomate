<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PrintPg()
{
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	
	document.getElementById("myADTable2").deleteRow(0);

	window.print();

}
</script>
<body>
<%@ page language="java" import="utility.*,enrollment.PersonalInfoManagement,java.util.Vector"%>

<%
    DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	//add security here.
	//strTemp = request.getParameter("userId");
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission-Student Info Mgmt","recruitment_report_detailed.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
 %>
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> Error in opening connection</font></p>
<%
		return;
	}
      //authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
							"Admission","Student Info Mgmt",
							request.getRemoteAddr(), "recruitment_report_detailed.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

PersonalInfoManagement pInfoMgmt = new PersonalInfoManagement();


Vector vRecDtls = new Vector();
vRecDtls = pInfoMgmt.getDetailedReport(dbOP, request);
	
	if(vRecDtls == null)
		strErrMsg = pInfoMgmt.getErrMsg();
		
String strDetailName = WI.fillTextValue("detailed_index");
if(strDetailName.length() > 0 && !strDetailName.equals("OTHERS") && !strDetailName.equals("REFERRAL")){
	strDetailName = "select DETAIL_NAME from GSPIS_RECRUITE_DTLS where DETAIL_INDEX = "+strDetailName;
	strDetailName = dbOP.getResultOfAQuery(strDetailName,0);
}
	

%>
<form name="form_" action="recruitment_report_detailed.jsp" method="post">
    <table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr>
       <td height="20" colspan="5" class="thinborderBOTTOM"><div align="center"><strong>::: RECRUITMENT DETAILED REPORT  ::: </strong></div></td>
    </tr>
	<tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
	</table>
<% 
if(vRecDtls != null && vRecDtls.size() > 0){ 
	int iRowCount = 1;
	int iNoOfStudPerPage = 35;
	
	if(WI.fillTextValue("rows_per_pg").length() > 0)
		iNoOfStudPerPage = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
		
		
	int iStudCount = 1;
	int iPageCount = 0;
	int iTotalStud = (vRecDtls.size()/6);
	int iTotalPageCount = iTotalStud/iNoOfStudPerPage;
	if(iTotalStud % iNoOfStudPerPage > 0)
		++iTotalPageCount;

	for(int i = 0; i < vRecDtls.size(); )
	{
		iRowCount = 1;
		if(i > 0){%>
		<div style="page-break-after:always;">&nbsp;</div>
	<%}%>
     <table width="100%" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" id="myADTable2" >
      <tr>
         <td height="25" colspan="2" align="right"><a href="JavaScript:PrintPg();">
        <img src="../../images/print.gif" border="0">
        </a></td>
      </tr>
     <tr>
        <td colspan="2"><br/>
        <div align="center"> <font style="font-size:13px; font-weight:bold;"> 
		<%=SchoolInformation.getSchoolName(dbOP,true,false)%> </font><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%> <br>
        Student List in Detailed Report <%=WI.getStrValue("<strong>"+strDetailName+"</strong>", " FOR ","","")%>        </div></td>
      </tr>
     <tr>
       <td width="50%">&nbsp;</td>
       <td width="50%" style="font-size:9px;" align="right">Page <%=++iPageCount%> of <%=iTotalPageCount%></td>
     </tr>
    </table>
 
      <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder" id="myADTable4">
			<tr>
			   <td width="5%" class="thinborder" height="22"><strong>Count</strong></td>
	  <td height="22" width="10%" class="thinborder"><strong>ID Number</strong></td>
      <td height="22"width="55%" class="thinborder"><strong>Student Name</strong></td>
	  <td height="22" width="30%" class="thinborder"><strong>Course - Year </strong></td>
      </tr>
<%
for(; i < vRecDtls.size(); i += 6)
{
%>
    <tr>
       <td  width="7%" class="thinborder"><%=iStudCount++%></td>
	  <td height="25"  width="26%" class="thinborder"><%=(String)vRecDtls.elementAt(i)%></td>
	  <td height="25"  width="21%" class="thinborder"><%=WebInterface.formatName((String)vRecDtls.elementAt(i+2),(String)vRecDtls.elementAt(i+1),(String)vRecDtls.elementAt(i+3),4)%></td>
	   <td height="25"  width="30%" class="thinborder"><%=(String)vRecDtls.elementAt(i+4)%><%=WI.getStrValue((String)vRecDtls.elementAt(i+5)," - ","","")%></td>
	  </tr>
	    <%
		
		if(++iRowCount >= iNoOfStudPerPage) {
			i+=6;
			break;
		}
}%>
   </table>
<%}

}%>
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>
