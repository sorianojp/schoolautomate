<%@ page language="java" import="utility.*, health.ClinicVisitLog ,java.util.Vector " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript">
<!--
function ReloadPage()
{
	this.SubmitOnce('form_');
}
-->
</script>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
	Vector vComplaints =  null;
	Vector vPrognosis = null;
	
	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strSlash = "";
	String [] astrYN = {"Open", "Closed"};	

	boolean bolNoRecord = true; //it is false if there is error in edit info.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","case_detail.jsp");
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
														"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
														"case_detail.jsp");
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
ClinicVisitLog CVLog = new ClinicVisitLog();
if(WI.fillTextValue("view_dep").length() > 0)
	vRetResult = CVLog.getDependentPatientHistory(dbOP, request);
else
	vRetResult = CVLog.operateOnClinicVisit(dbOP, request, 3);
	
vComplaints = CVLog.operateOnComplaints(dbOP, request, 4);
vPrognosis = CVLog.operateOnPrognosis(dbOP, request, 4);
strErrMsg = CVLog.getErrMsg();

%>
<body bgcolor="#8C9AAA" class="bgDynamic">

<form action="./case_detail.jsp" method="post" name="form_">
<%if (vRetResult!=null && vRetResult.size()>0){%>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
<tr>
<td colspan="7" bgcolor="#697A8F" height="18" class="footerDynamic"><font color="#FFFFFF"><strong>&nbsp;&nbsp;::: CASE DETAILS :::</strong></font></td>
</tr> 
<tr>
<td width="3%" height="25">&nbsp;</td>
<td width="19%"><strong>Case No:</strong></td>
<td width="78%"><%=(String)vRetResult.elementAt(2)%></td>

</tr>
<tr>
<td height="25">&nbsp;</td>
<td><strong>Visit Date:</strong></td>
<td><%=(String)vRetResult.elementAt(1)%></td>
</tr>
<tr>
<td height="25">&nbsp;</td>
<td><strong>Attended by:</strong></td>
<%
	strTemp = WI.formatName((String)vRetResult.elementAt(3), (String)vRetResult.elementAt(4), (String)vRetResult.elementAt(5),7);
	strTemp2 = WI.formatName((String)vRetResult.elementAt(21), (String)vRetResult.elementAt(22), (String)vRetResult.elementAt(23),7);
	if(strTemp.length() > 0 && strTemp2.length() > 0)
		strSlash = " / ";
%>
<td><%=strTemp%><%=strSlash%><%=strTemp2%></td>
</tr>



<%if (vComplaints!=null && vComplaints.size()>0){%>
<tr>
<td>&nbsp;</td>
<td><strong>Complaints: </strong></td>
<td height="25"><%for (int i = 0; i<vComplaints.size(); i+=2){%><%if (i!=0){%>,&nbsp;<%}%><%=(String)vComplaints.elementAt(i)%><%}%></td>
</tr>
<%}%>
<%if (vPrognosis!=null && vPrognosis.size()>0){%>
<tr>
<td>&nbsp;</td>
<td height="25"><strong>Prognosis: </strong></td>
<td><%for (int i = 0; i<vPrognosis.size(); i+=2){%><%if (i!=0){%>,&nbsp;<%}%><%=(String)vPrognosis.elementAt(i)%><%}%></td>
</tr>
<%}%>
<tr>
<td height="25">&nbsp;</td>
<td><strong>Diagnosis:</strong></td>
<td><%=(String)vRetResult.elementAt(7)%></td>
</tr> 
 <tr>
<td height="25">&nbsp;</td>
<td><strong>Recommendation:</strong></td>
<td><%=(String)vRetResult.elementAt(8)%></td>
</tr> 
<tr>
<td height="25">&nbsp;</td>
<td><strong>Case Status:</strong></td>
<td><%=astrYN[Integer.parseInt((String)vRetResult.elementAt(10))]%></td>
</tr> 
</table>
<%}%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr> 
      <td height="10">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input name = "stud_id" type = "hidden"  value="<%=WI.fillTextValue("stud_id")%>">
<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
<input name = "visit_index" type = "hidden"  value="<%=WI.fillTextValue("visit_index")%>">

<input type="hidden" name="id_number" value="<%=WI.fillTextValue("id_number")%>">
<input type="hidden" name="show_close" value="">
<input type="hidden" name="is_final" value="">
<input type="hidden" name="view_dep" value="<%=WI.fillTextValue("view_dep")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>