<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
	body{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
	}
	td{
		font-family:Verdana, Arial, Helvetica, sans-serif;
		font-size:11px;
	}
</style>
</head>
<script language="Javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function PrintPage(){
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myTable2');
	obj1.deleteRow(0);

	document.getElementById('myTable3').deleteRow(0);
	document.getElementById('myTable3').deleteRow(0);
	
	document.getElementById('myTR1').bgColor = "#FFFFFF";
	document.getElementById('myTR2').bgColor = "#FFFFFF";
	document.getElementById('myTR3').bgColor = "#FFFFFF";
	
	window.print();
}

</script>


<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.Organization"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strInfoIndex = null;


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OSA - Organization","org_add.jsp");
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
														"Student Affairs",
														"ORGANIZATIONS",request.getRemoteAddr(),
														"org_add.jsp");

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

Vector vRetResult  = null;
Vector vRetMembers = null;
Vector vTemp = null;

String[] astrStatus ={"Regular", "Probationary","Failed", "(No Status)","Accredited"};

boolean bolNoRecord = false;
boolean bolRetainValue = false;//if it is true, use wi.fillTextValue(..);
String strHistory = "0";
Organization organization = new Organization();

if(WI.fillTextValue("organization_id").length() > 0
	&& WI.fillTextValue("sy_from").length() > 0){
	
	vRetResult = organization.operateOnOrganization(dbOP, request,4);
	if(vRetResult == null)
		strErrMsg = organization.getErrMsg();
	
	vTemp = organization.operateOnOrgMember(dbOP, request, 5);
	if(vTemp == null)
		strErrMsg = organization.getErrMsg();
	if(vTemp.elementAt(0) == null && vTemp.elementAt(1) == null)
		vTemp = null;
}



%>
<body bgcolor="#D2AE72">
<form action="./view_organization_detail.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>::::
          ORGANIZATIONS - INFORMATION DETAIL PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<%if((vRetResult != null && vRetResult.size() > 0 ) || vTemp != null && vTemp.size() > 0){%> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTable2">
  	<tr><td align="right"><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a></td></tr>
  </table>
  
<%}if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">    
	 <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="25%">Organization ID : </td>
      <td colspan="3"><%=WI.fillTextValue("organization_id")%></td>
    </tr>
    <tr>
      <td width="5%" height="25">&nbsp;</td>
      <td width="25%">Organization name : </td>
      <td colspan="3"><%=(String)vRetResult.elementAt(2)%></td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td>College/Department</td>
      <td><strong><%=WI.getStrValue(vRetResult.elementAt(5))%><%=WI.getStrValue((String)vRetResult.elementAt(7),"/","","")%></strong></td>
    </tr>
-->
    <tr>
      <td height="25">&nbsp;</td>
      <td>Organization description : </td>
      <td colspan="3"><%=(String)vRetResult.elementAt(11)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Organization vision : </td>
      <td colspan="3"><%=(String)vRetResult.elementAt(12)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Organization mission : </td>
      <td colspan="3"><%=(String)vRetResult.elementAt(13)%></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Organization adviser(s): </td>
      <td colspan="3"><%=WI.getStrValue((String)vRetResult.elementAt(8))%></td>
    </tr>
<% if ((String)vRetResult.elementAt(14) != null){%>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3"><%=(String)vRetResult.elementAt(14)%> </td>
    </tr>
<%} if ((String)vRetResult.elementAt(15) != null){%>
    <tr>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3"><%=(String)vRetResult.elementAt(15)%> </td>
    </tr>
<%}%>  

    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Organization Status : </td>
      <td width="23%">
  	  <%=astrStatus[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(16),"3"))]%>      </td>
      <td width="22%">Date of Status Update: </td>
      <td width="25%"><strong><%=WI.getStrValue((String)vRetResult.elementAt(3))%>&nbsp;</strong></td>
    </tr>
    <tr>
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
  </table>  
<%}%>
  
  
  
    
 <% if (vTemp != null && vTemp.size() > 0) {
 		vRetMembers = (Vector)vTemp.elementAt(0);
 
  %> 
  
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">

  
    <tr bgcolor="#BFD9F9" id="myTR1">
      <td height="25"><div align="center"><strong>LIST OF OFFICERS AND MEMBERS</strong></div></td>
    </tr>
    <tr>
      <td height="10">
	  
	 <% if (vRetMembers != null && vRetMembers.size() > 0) {%> 
	  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr id="myTR2" bgcolor="#B9B292">
      <td height="25" colspan="6" class="thinborder"><div align="center"><strong>LIST
          OF OFFICERS FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></div></td>
    </tr>
    <tr>
	  <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>Position</strong></font></div></td>	
      <td width="13%" class="thinborder"><font size="1"><strong>Student ID </strong></font></td>
      <td width="23%" height="18" class="thinborder"><div align="center"><font size="1"><strong>Name</strong></font></div></td>
      <td width="14%" class="thinborder"><div align="center"><font size="1"><strong>Course &amp;Year </strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>Contact No. </strong></font></div></td>
      <td width="27%" class="thinborder"><div align="center"><font size="1"><strong>Address</strong></font></div></td>
      </tr>
<%if (vRetMembers != null) 
	for(int i =0 ; i < vRetMembers.size(); i += 12){%>
    <tr>
      <td class="thinborder"><%=(String)vRetMembers.elementAt(i + 2)%></td>
      <td class="thinborder"><%=(String)vRetMembers.elementAt(i + 4)%></td>
      <td height="25" class="thinborder"><%=(String)vRetMembers.elementAt(i + 5)%></td>
      <td class="thinborder">
	  		<%=WI.getStrValue((String)vRetMembers.elementAt(i + 6),"&nbsp;")%>
			<%=WI.getStrValue((String)vRetMembers.elementAt(i + 7),"(",")","")%>&nbsp;
			<%=WI.getStrValue(vRetMembers.elementAt(i + 8),"&nbsp;")%>
	  </td>
      <td class="thinborder">
	  		<%=WI.getStrValue((String)vRetMembers.elementAt(i+11),"&nbsp;")%>
	  </td>
	  <% strTemp = 	WI.getStrValue((String)vRetMembers.elementAt(i+9));
	  	  if (strTemp.length() > 0) 
		  	strTemp += ", ";
		 strTemp +=  WI.getStrValue((String)vRetMembers.elementAt(i+10));
	  %>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      </tr>
<%}%>
  </table>
 <%}%> 
      </td>
    </tr>
    <tr>
      <td height="10">
<%
	vRetMembers = (Vector) vTemp.elementAt(1);
	if (vRetMembers != null && vRetMembers.size() > 1) { 
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr><td height="5"></td></tr>	
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr id="myTR3" bgcolor="#B9B292">
      <td height="25" colspan="6" class="thinborder"><div align="center"><strong>LIST
          OF MEMBERS FOR SCHOOL YEAR <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></div></td>
    </tr>
    <tr>
      <td width="4%" class="thinborder"><strong><font size="1">No.</font></strong></td>
      <td width="10%" class="thinborder"><strong><font size="1">Student ID </font></strong></td>
      <td width="22%" height="25" class="thinborder"><div align="center"><font size="1"><strong>Name</strong></font></div></td>
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>Course &amp; Year </strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>Contact No. </strong></font></div></td>
      <td width="30%" class="thinborder"><div align="center"><font size="1"><strong>Address</strong></font></div></td>
      </tr>
<%
if (vRetMembers != null) 
for(int i = 0,iCtr = 1 ; i < vRetMembers.size(); i += 12, iCtr++){%>
    <tr>
      <td class="thinborder">&nbsp;<%=iCtr%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetMembers.elementAt(i + 4)%></td>
      <td class="thinborder" height="25"><%=(String)vRetMembers.elementAt(i + 5)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetMembers.elementAt(i + 6),"&nbsp;")%>
	  						<%=WI.getStrValue((String)vRetMembers.elementAt(i + 7),"(",")","")%>
							<%=WI.getStrValue((String)vRetMembers.elementAt(i + 8),"&nbsp;","","")%></td>
      <td class="thinborder">
	  		<%=WI.getStrValue((String)vRetMembers.elementAt(i+11),"&nbsp;")%>
	  </td>
	  <% strTemp = 	WI.getStrValue((String)vRetMembers.elementAt(i+9));
	  	  if (strTemp.length() > 0) 
		  	strTemp += ", ";
		 strTemp +=  WI.getStrValue((String)vRetMembers.elementAt(i+10));
	  %>
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      </tr>
<%}%>
  </table>
  
<%}%>
	  </td>
    </tr>

  </table>  
 <%}%>     


<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable3">
<tr><td height="10" align="center">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>
<input type="hidden" name="info_index" value="<%=WI.getStrValue(strInfoIndex)%>">
<input type="hidden" name="page_action">
<input type="hidden" name="cur_org_id" value="<%=WI.fillTextValue("organization_id")%>">
<input type="hidden" name="organization_id" value="<%=WI.fillTextValue("organization_id")%>">

<input type="hidden" name="myTR1" id="myTR1">
<input type="hidden" name="myTR2" id="myTR2">
<input type="hidden" name="myTR3" id="myTR3">


</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
