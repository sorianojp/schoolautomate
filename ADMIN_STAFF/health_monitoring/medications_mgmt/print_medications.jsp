<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<%@ page language="java" import="utility.*, health.MedicationMgmt, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;

	String strInfoIndex = null;
	String strPrepareToEdit = null;
	String strErrMsg = null;
	String strTemp = null;
	String [] astrYN = {"No", "Yes"};	
	int iSearchResult = 0;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring - Medication Management","medication.jsp");
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
														"Health Monitoring","Medication Management",request.getRemoteAddr(),
														"medication.jsp");
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

	MedicationMgmt medMgmt = new MedicationMgmt();
	
	vRetResult = medMgmt.operateOnMedicationEntry(dbOP, request, 4);
	iSearchResult = medMgmt.getSearchCount();
	if (strErrMsg == null)
		strErrMsg = medMgmt.getErrMsg();
	
%>

<body>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%"><div align="center"> 
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%> <br>
          <%//=SchoolInformation.getAddressLine3(dbOP,false,false)%>
          <strong> <%//=SchoolInformation.getInfo2(dbOP,false,false)%></strong> <br>
      </p></div></td>
       </tr>
       <tr>
       <td>&nbsp;</td>
       </tr>
</table>
  
  <%if (vRetResult!=null && vRetResult.size()>0){%>
    
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr> 
      		<td height="25" colspan="6" class="thinborder"><div align="center"><strong>LIST OF MEDICATIONS 
          IN THE DATABASE </strong></div></td>
    </tr>
    <tr> 
      		<td height="25" colspan="6" class="thinborder">&nbsp;</td>
    </tr>
    <tr> 
      <td width="22%" height="26" class="thinborder"><div align="center"><font size="1"><strong>MEDICATION 
          NAME</strong></font></div></td>
      <td width="19%" class="thinborder"><div align="center"><font size="1"><strong>USAGE/TYPE</strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>STRENGTH</strong></font></div></td>
      <td width="19%" class="thinborder"><div align="center"><font size="1"><strong>MEDICATION FORM</strong></font></div></td>
      <td width="19%" class="thinborder"><div align="center"><font size="1"><strong>PRESCRIPTION 
          TYPE</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>AVAILABLE IN 
          CLINIC</strong></font></div></td>
    </tr>
    <%for(int i =0; i<vRetResult.size(); i+=11){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>
      <td class="thinborder"><div align="center"><%=astrYN[Integer.parseInt((String)vRetResult.elementAt(i+9))]%></div></td>
      <td class="thinborder"><div align="center"><%=astrYN[Integer.parseInt((String)vRetResult.elementAt(i+10))]%></div></td>
    </tr>
    <%}%>
  </table>
  <script language="JavaScript">
window.print();
</script>  
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
