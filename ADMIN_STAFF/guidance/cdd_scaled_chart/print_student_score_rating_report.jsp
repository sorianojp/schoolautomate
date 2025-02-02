<%@ page language="java" import="utility.*,enrollment.ScaledScoreConversion,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../Ajax/ajax2.js"></script>

<script language="JavaScript">
/**function ReloadPage(){
	document.form_.info_index.value = '';
	document.form_.prepareToEdit.value = '';
	document.form_.submit();
}*/

/**function PageAction(strAction, strInfoIndex){
	if(strAction == '0'){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	
	document.form_.page_action.value = strAction;	
	document.form_.submit();
}*/



function PrintPage()
{	
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	/**var obj1 = document.getElementById('myTable2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);	*/
	
	//document.getElementById('myTable3').deleteRow(0);	
	
	document.getElementById('myTable2').deleteRow(0);
	document.getElementById('myTable2').deleteRow(0);	
		
	
	window.print();
}


</script>


<body bgcolor="#D2AE72">

<%
	DBOperation dbOP  = null;
	String strErrMsg  = null;	
	String strTemp    = null;
	String strTemp2   = null;
	String strTemp3   = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-IQ Test","print_student_score_rating_report.jsp");
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
									"Guidance & Counseling","IQ Test",request.getRemoteAddr(), null);

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

ScaledScoreConversion scoreConversion = new ScaledScoreConversion();
Vector vRetResult = new Vector();

if(WI.fillTextValue("iAction").length() > 0){
	vRetResult = scoreConversion.getReportRating(dbOP, request, Integer.parseInt(WI.fillTextValue("iAction")));
	if(vRetResult == null)
		strErrMsg = scoreConversion.getErrMsg();	
}
		
%>
<form name="form_" action="./print_student_score_rating_report.jsp" method="post">
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myTable1">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF"><strong>::::
          LIST OF STUDENT SCORE RATING ::::</strong></font></div></td>
    </tr>
    <tr><td height="25" colspan="" width="70%">&nbsp; &nbsp; &nbsp; <strong><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	  <td align="right"><a href="javascript:PrintPage();"><img src="../../../images/print.gif" border="0"></a></td>
	</tr>
</table>

<%
String[] astrConvertSem = {"Summer", "1st Sem", "2nd Sem", "3rd Sem", "4th Sem", "5th Sem", "6th Sem"};
if(vRetResult != null && vRetResult.size() > 0){%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
<tr><td colspan="5"><div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,true)%></div></td></tr>

<%
strTemp = WI.fillTextValue("exam_name");
if(strTemp.equals("All"))
	strTemp = "";
%>

<tr><td colspan="5" height="25"><strong><font size="2"><%=WI.fillTextValue("test_name")%><%=WI.getStrValue(strTemp," - ","","")%></font></strong></td></tr>
<tr><td colspan="5" height="25">
	<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>
	S.Y. <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>
</td></tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
<tr bgcolor="">
	<td class="thinborder" width="5%"><strong>Count</strong></td>
	<td height="25" class="thinborder" width="15%"><strong>Student ID</strong></td>
	<td class="thinborder" width="25%"><strong>Student Name</strong></td>
	<td class="thinborder" width="10%"><strong>Gender</strong></td>
	<td class="thinborder" width="20%"><strong>Course</strong></td>
	<td class="thinborder" width="10%"><strong>Year Level</strong></td>
	<td class="thinborder" width="15%"><strong>Remark</strong></td>
</tr>

<%
int iCount = 1;
for(int i = 0; i < vRetResult.size(); i+=9){
%>
<tr>
	<td class="thinborder"><%=iCount++%>.</td>
	<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
	<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
	<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6))%></td>
	<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+3))%><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"-","","")%></td>
	<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5))%></td>
	<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></td>
</tr>
<%}%>

</table>

<%}%>

  
  


  
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myTable2">
    <tr><td colspan="8" height="25" >&nbsp;</td></tr>
    <tr><td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td></tr>	
</table>
<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>" />
<input type="hidden" name="test_name" value="<%=WI.fillTextValue("test_name")%>" />
<input type="hidden" name="exam_name" value="<%=WI.fillTextValue("exam_name")%>" />	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
