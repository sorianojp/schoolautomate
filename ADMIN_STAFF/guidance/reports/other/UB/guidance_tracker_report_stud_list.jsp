
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
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

//	document.getElementById("myADTable1").deleteRow(0);
//	document.getElementById("myADTable1").deleteRow(0);
//	
//	document.getElementById("myADTable2").deleteRow(0);
//	
//	document.getElementById("myADTable3").deleteRow(0);
//	document.getElementById("myADTable3").deleteRow(0);
//	
//	document.getElementById("myADTable4").deleteRow(0);
//	document.getElementById("myADTable4").deleteRow(0);

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
								"Admin/staff-Students Affairs-Guidance-Reports-Other","leave_absence.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}


GDTrackerServices trackService = new GDTrackerServices();
Vector vRetResult 	= null;
vRetResult = trackService.generateStudTrackerReport(dbOP, request, 1);
if(vRetResult == null)
	strErrMsg = trackService.getErrMsg();

%>

<body <%if(strErrMsg == null){%>onLoad="PrintPg();"<%}%>>
<%
if(strErrMsg != null){
dbOP.cleanUP();
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">    
	<tr><td height="25" style="padding-left:30px;"><font color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td></tr>
  </table>
<%
return;}
if(vRetResult != null && vRetResult.size() > 0){




String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester","Fourth Semester"};

String strCollegeName = null;
if(WI.fillTextValue("c_index").length() > 0){
	strTemp = "select c_name from college where c_index = "+WI.fillTextValue("c_index");
	strCollegeName = dbOP.getResultOfAQuery(strTemp,0);
}

strTemp = "select FIELD_NAME  from GD_TRACKER_EXTN where TRACKER_EXTN_INDEX = "+WI.fillTextValue("track_extn_index");
strTemp = dbOP.getResultOfAQuery(strTemp,0);
strTemp += " DEVELOPMENT";

%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
<tr><td align="center"><%=SchoolInformation.getSchoolName(dbOP, true, false)%><br>
	<%=SchoolInformation.getAddressLine1(dbOP, false, true)%><br>
	<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]+", S.Y. "+WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%>
	<%=WI.getStrValue(strCollegeName,"<br>","","")%>
	<br>
	</td></tr>
<tr><td height="22" align="center" class="" style="font-weight:bold">LIST OF STUDENT FOR <%=strTemp.toUpperCase()%></td></tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="6%" height="25" align="center" class="thinborder"><strong>COUNT</strong></td>
		<td width="17%" align="center" class="thinborder"><strong>ID NUMBER</strong></td>
		<td width="34%" align="center" class="thinborder"><strong>STUDENT NAME</strong></td>
		<td width="12%" align="center" class="thinborder"><strong>GENDER</strong></td>
		<%
		if(!WI.fillTextValue("is_basic").equals("1"))
			strTemp = "COURSE-MAJOR";
		else
			strTemp = "LEVEL NAME - SECTION NAME";
		%>
		<td align="center" class="thinborder"><strong><%=strTemp%></strong></td>
		<%if(!WI.fillTextValue("is_basic").equals("1")){%><td width="7%" align="center" class="thinborder"><strong>YEAR LEVEL</strong></td><%}%>
	</tr>
	<%
	int iCount = 0;
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
		strTemp = (String)vRetResult.elementAt(i+7);
		if(strTemp.toLowerCase().equals("m"))
			strTemp = "Male";
		else
			strTemp = "Female";
		%>
		<td class="thinborder" align="center"><%=strTemp%></td>
		
		<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4))+WI.getStrValue((String)vRetResult.elementAt(i+5),"(",")","");
		%>
		<td class="thinborder"><%=strTemp%></td>
		<%if(!WI.fillTextValue("is_basic").equals("1")){%><td class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(i+6),"N/A")%></td><%}%>
	</tr>
	<%}%>
</table>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>