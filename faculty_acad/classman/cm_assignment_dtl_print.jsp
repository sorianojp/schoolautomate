<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMAssignment" %>
<%
 
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-CLASS MANAGEMENT-Assignments/Homeworks","cm_assignment_details.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Faculty/Acad. Admin","CLASS MANAGEMENT",request.getRemoteAddr(), 
														"cm_assignment_details.jsp");	
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
	String strEmployeeID = (String)request.getSession(false).getAttribute("userId");
	String strEmployeeIndex = dbOP.mapUIDToUIndex(strEmployeeID);
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	Vector vRetResult = null;
	Vector vAssignInfo = null;
	Vector vEditInfo = null;
	String strPageAction = WI.fillTextValue("page_action");
	String strSubSecIndex = WI.fillTextValue("sub_sec_index");
	String strAssignIndex = WI.fillTextValue("info_index");
	String[] astrSem= {"SUMMER", "1ST SEMESTER", "2ND SEMESTER","3RD SEMESTER","4TH SEMESTER"};

CMAssignment cm = new CMAssignment();

if(WI.fillTextValue("section_name").length() > 0 && WI.fillTextValue("subject").length() > 0 &&
	WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("offering_sem").length() > 0
	&& strSubSecIndex.length() == 0) {
	strSubSecIndex = dbOP.mapOneToOther("E_SUB_SECTION ",
		" section","'"+WI.fillTextValue("section_name")+"'"," e_sub_section.sub_sec_index", 
		" and e_sub_section.sub_index = "+WI.fillTextValue("subject")+ 
		" and e_sub_section.offering_sy_from = "+ WI.fillTextValue("sy_from") + 
		" and e_sub_section.offering_sem="+ WI.fillTextValue("offering_sem") +
		" and is_lec=0");
}

if (strSubSecIndex != null && strSubSecIndex.length() > 0){
	vAssignInfo = cm.operateOnAssignment(dbOP,request,3, strSubSecIndex);
	if(vAssignInfo == null)
		strErrMsg = cm.getErrMsg();
}

if (strAssignIndex.length() > 0){
	vRetResult = cm.operateOnAssignmentDetail(dbOP,request,4, strAssignIndex);
	if (vRetResult == null && cm.getErrMsg() == null){
		strErrMsg = cm.getErrMsg();
	}
}

%>
<html>
<head>
<title>Class Management Assign Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">	
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
table{
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
 }

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
	TABLE.thinborderALL{
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>

</head>
<body>
<form name="form_" method="post" action="./cm_assignment_detail.jsp">
  <% if (vAssignInfo != null){ %>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" class="thinborderALL">
    <tr bgcolor="#FFFFFF"> 
      <td width="3%" align="center">&nbsp;</td>
      <td width="12%" align="center"><div align="left">Subject </div></td>
      <td width="42%" ><strong><%=dbOP.mapOneToOther("subject","is_del","0","sub_code"," and sub_index = " + WI.fillTextValue("subject"))%></strong></td>
      <td width="12%" >Section</td>
      <td width="31%" ><strong><%=WI.fillTextValue("section_name")%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td align="center">&nbsp;</td>
      <td>Assignment </td>
      <td><strong><%=(String)vAssignInfo.elementAt(2)%></strong></td>
      <td>SY:: Term</td>
      <td><strong><%=WI.fillTextValue("sy_from") +" - " + WI.fillTextValue("sy_to") + " :: " + astrSem[Integer.parseInt(WI.fillTextValue("offering_sem"))] %></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td align="center">&nbsp;</td>
      <td>Date Given</td>
      <td><strong><%=(String)vAssignInfo.elementAt(3)%></strong></td>
      <td>Due Date</td>
      <td><strong><font color="#0000EE"><%=(String)vAssignInfo.elementAt(4)%></font></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td align="center">&nbsp;</td>
      <td>Instr. Note </td>
      <td colspan="3"><strong><%=WI.getStrValue((String)vAssignInfo.elementAt(6))%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td align="center">&nbsp;</td>
      <td>Stud. Notes </td>
      <td colspan="3"><strong><%=WI.getStrValue((String)vAssignInfo.elementAt(7))%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td align="center">&nbsp;</td>
      <td>References</td>
      <td colspan="3"><strong><%=WI.getStrValue((String)vAssignInfo.elementAt(5))%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td align="center">&nbsp;</td>
      <td>Max Score </td>
      <td colspan="3"><strong><%=WI.getStrValue((String)vAssignInfo.elementAt(10))%></strong></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td colspan="5" align="center">&nbsp;</td>
    </tr>
  </table>
  <% if (vRetResult != null){%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" class="thinborder">
    <tr> 
      <td width="8%" height="25" class="thinborder"><div align="center"><font size="1"><strong>NO. 
          </strong></font></div></td>
      <td width="92%" class="thinborder"><div align="center"><font size="1"><strong>QUESTION</strong></font></div></td>
    </tr>
    <%  
		for (int i = 0,iCtr=1; i < vRetResult.size(); i+=3,iCtr++) {%>
    <tr> 
      <td height="25" align="right" class="thinborder"><%=iCtr%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
    </tr>
    <%} // end of for loop%>
  </table>
  <%}// vRetREsult != null 
} // vAssignInfo != null%>
<input type="hidden" name="print_page">

</form>
<script language="JavaScript">

window.print();

</script>
</body>
</html>
<%
	dbOP.cleanUP();
%>