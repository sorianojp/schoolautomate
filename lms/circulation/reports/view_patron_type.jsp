<%@ page language="java" import="utility.*,enrollment.ReportEnrollment, lms.CirculationReport, java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function GenerateReport(){
	document.form_.patron_name.value = document.form_.patron_type[document.form_.patron_type.selectedIndex].text;
	document.form_.view_patron.value = "1";
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}
</script>
<body bgcolor="#D0E19D" topmargin="0" bottommargin="0">
<%
	String strTemp = null;
	int iSubTotal   = 0; // sub total of a course - major.
	int iElemSubTotal = 0;
	int iHSSubTotal = 0;
	int iPreElemSubTotal = 0;	
	String strErrMsg = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LMS-CIRCULATION-REPORTS","view_patron_type.jsp");
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
														"LIB_Circulation","REPORTS",request.getRemoteAddr(),
														"view_patron_type.jsp");
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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";//for UI, the detrails are different from others. UI adds elementary details.
	

CirculationReport CR = new CirculationReport();
Vector vRetResult = null;
if(WI.fillTextValue("view_patron").length() > 0){
	vRetResult = CR.getPatronTypeInfo(dbOP,request);
	if(vRetResult == null)
		strErrMsg = CR.getErrMsg();

}

%>
<form action="./view_patron_type.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable1">
    <tr bgcolor="#77A251">
      <td width="100%" height="25" colspan="4"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          VIEW PATRON PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable2">
 	<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Patron Type: </td>
			<td width="80%">
			<select name="patron_type">
				<option value="">Select Patron Type</option>
				<%=dbOP.loadCombo("patron_type_index", "patron_type", " from lms_patron_type where patron_type_index <> 1 order by patron_type_index ", WI.fillTextValue("patron_type"), false)%>
			</select> &nbsp; &nbsp;
			<a href="javascript:GenerateReport();"><img src="../../../images/form_proceed.gif" border="0"></a> </td>
 	</tr>
	<tr><td height="10" colspan="4"></td></tr>
	
  </table>
  
  
  
<%if(vRetResult != null && vRetResult.size() > 0){%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable3">
	<tr>
		<td align="center" height="25"><strong>LIST OF PATRON TYPE : <%=WI.fillTextValue("patron_name")%></strong></td>
	</tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	<tr>
		<td class="thinborder" height="25" width="30%" align="center"><strong>ID Number</strong></td>
		<td class="thinborder" height="25"><strong>Patron Name</strong></td>
	</tr>
	
	<%
	for(int i = 0; i < vRetResult.size(); i+=3){
	%>
	<tr>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+1)%></td>
		<td class="thinborder" height="25"><%=(String)vRetResult.elementAt(i+2)%></td>
	</tr>
	<%}%>
</table>

<%}%>	
   
   
 



<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTable4">
<tr><td height="25">&nbsp;</td></tr>
<tr><td height="25" bgcolor="#77A251">&nbsp;</td></tr>
</table>
<input type="hidden" name="view_patron" >
<input type="hidden" name="patron_name" value="<%=WI.fillTextValue("patron_type")%>" >
</form>


<!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>

</body>
</html>
<%
dbOP.cleanUP();
%>