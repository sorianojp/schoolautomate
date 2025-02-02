<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Guidance Services Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<script language="JavaScript">
function PrintPg(){
	if(!confirm("Click OK to print."))
		return;
	document.bgColor = "#FFFFFF";
	window.print();		
}
</script>
<%@ page language="java" import="utility.*,osaGuidance.GDTrackerServices,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");	
	if (strSchCode == null)
		strSchCode = "";

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-Guidance-Reports-Other","guidance_services_print.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}	
	
	String strField = WI.fillTextValue("field");      
	
	GDTrackerServices guidanceServ =new GDTrackerServices ();
	Vector vRetResult = null;
			
	vRetResult = guidanceServ.generateStudentSevices(dbOP, request,1);
	if(vRetResult == null)
	   strErrMsg = guidanceServ.getErrMsg();

%>
<body <%if(strErrMsg == null){%>onLoad="PrintPg();"<%}%>>
<%	if(strErrMsg != null){
		dbOP.cleanUP();
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">    
	<tr><td height="25" style="padding-left:30px;"><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td></tr>
  </table>
<%		return;
	}
	if(vRetResult != null && vRetResult.size() > 0){

	String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};	
	String strCollegeName = null;
	if(WI.fillTextValue("c_index").length() > 0){
		strTemp = "select c_name from college where c_index = "+WI.fillTextValue("c_index");
		strCollegeName = dbOP.getResultOfAQuery(strTemp,0);
	}
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
<tr><td align="center"><%=SchoolInformation.getSchoolName(dbOP, true, false)%><br>
	<%=SchoolInformation.getAddressLine1(dbOP, false, true)%><br>
	<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]+", S.Y. "+
	WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%>
	<%=WI.getStrValue(strCollegeName,"<br>","","")%>
	<br>
	</td></tr>
<tr><td height="22" align="center" class="" style="font-weight:bold">LIST OF STUDENT FOR GUIDANCE SERVICES</td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="3%" height="25" align="center" class="thinborder"><strong>COUNT</strong></td>
		<td width="12%" align="center" class="thinborder"><strong>ID NUMBER</strong></td>
		<td width="25%" align="center" class="thinborder"><strong>STUDENT NAME</strong></td>
<%
if(strField.equals("field_37") || strField.equals("field_41")){
%>
		<td width="21%" align="center" class="thinborder"><strong>TITLE</strong></td>
		<td width="14%" align="center" class="thinborder"><strong>DATE</strong></td>
<%}%>
		<td width="7%" align="center" class="thinborder"><strong>GENDER</strong></td>
		<%
		if(!WI.fillTextValue("is_basic").equals("1"))
			strTemp = "COURSE-MAJOR";
		else
			strTemp = "LEVEL NAME - SECTION NAME";
		%>
		<td align="center" class="thinborder"><strong><%=strTemp%></strong></td>
		<%if(!WI.fillTextValue("is_basic").equals("1")){%><td width="5%" align="center" class="thinborder"><strong>YEAR LEVEL</strong></td><%}%>
	</tr>
	<%int iCount = 0;
	  for(int i = 0; i < vRetResult.size(); i+=13){
	%>
	<tr>
		<td class="thinborder" align="right" height="22"><%=++iCount%>.&nbsp;</td>
		<td class="thinborder"><%=vRetResult.elementAt(i)%></td>
		<%
		strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),4);
		%>
		<td class="thinborder"><%=strTemp%></td>
<%
if(strField.equals("field_37") || strField.equals("field_41")){
%>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+9),"&nbsp;")%></td>
		<td class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i+8),"&nbsp;")%></td>

<%}	
			strTemp = (String)vRetResult.elementAt(i+7);
			if(strTemp.toLowerCase().equals("m"))
				strTemp = "Male";
			else
				strTemp = "Female";
		%>
		<td class="thinborder" align="center"><%=strTemp%></td>		
		<%		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4))+WI.getStrValue((String)vRetResult.elementAt(i+5),"(",")","");%>
		<td class="thinborder"><%=strTemp%></td>
		<%if(!WI.fillTextValue("is_basic").equals("1")){%><td class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i+6),"N/A")%></td><%}%>
	</tr>
	<%}//end of vRetResult loop%>
</table>
<%}//end of vRetResult !=null && vRetResult.size()>0%>
</body>
</html>
<%
dbOP.cleanUP();
%>