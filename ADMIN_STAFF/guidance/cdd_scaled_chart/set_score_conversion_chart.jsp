<%@ page language="java" import="utility.*,enrollment.ScaledScoreConversion,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	String strExamMainIndex = WI.fillTextValue("exam_main_index");
	String strCatgIndex = WI.fillTextValue("exam_catg_");
	
	if(WI.fillTextValue("show_link").length() > 0){
	
		if(strExamMainIndex.length() > 0){
			if(strExamMainIndex.equals("1")){
				if(strCatgIndex.equals("1")){%>
					<jsp:forward page="./scaled_score_conversion_chart.jsp" />
				<%}else{%>
					<jsp:forward page="./percentile_conversion_chart.jsp" />
				<%}%>			
			<%}else{//this is for iq & age rating%>
				<jsp:forward page="./score_rating.jsp" />
			<%}
		}
	}
	
	
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
<script language="JavaScript">

function Proceed(){	
	var strMainExamIndex = document.form_.exam_main_index.value;
	if(strMainExamIndex == ''){
		alert("Please choose exam name.");
		return;
	}
		
	if(strMainExamIndex == '1'){
		if(document.form_.exam_catg_.value == ''){
			alert('Please choose exam category.');
			return;
		}			
	}
	document.form_.show_link.value = '1';
	document.form_.submit();
}

</script>


<body bgcolor="#D2AE72">
<form name="form_" action="./set_score_conversion_chart.jsp" method="post">
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
								"Admin/staff-Guidance & Counseling-IQ Test","set_score_conversion_chart.jsp");
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

%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          SET SCORE CONVERSION CHART ::::</strong></font></div></td>
    </tr>
    <tr><td height="25" colspan="6">&nbsp; &nbsp; &nbsp; <strong><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">Exam Name</td>
		<%
		strTemp = WI.fillTextValue("exam_main_index");		
		%>		
		<td>
		<select name="exam_main_index" onChange="document.form_.submit();" >
			<option value="">Select Any</option>
			<%=dbOP.loadCombo("EXAM_MAIN_INDEX","exam_name", " from CDD_EXAM_MAIN where is_valid = 1 order by exam_name ", strTemp, false)%>
		</select>
		</td>
	</tr>
	
	<%if(strTemp.length() > 0){
		if(strTemp.equals("1")){
	%>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Exam Category</td>		
		<td>
		<select name="exam_catg_">
			<option value="">Select Any</option>
		<%
		strTemp = WI.fillTextValue("exam_catg_");
		if(strTemp.equals("1"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%>
			<option value="1" <%=strErrMsg%>>Scaled Score Conversion Chart</option>
		<%
		if(strTemp.equals("2"))
			strErrMsg = "selected";
		else
			strErrMsg = "";
		%>
			<option value="2" <%=strErrMsg%>>Percentile Conversion Chart</option>
		</select>
		</td>
	</tr>
	
	
	
		<%}
	}%>	

	<tr><td colspan="3">&nbsp;</td></tr>
	<tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>
			<a href="javascript:Proceed();">
			<img src="../../../images/form_proceed.gif" border="0"></a>
		</td>
	</tr>
</table>


  
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="show_link" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
