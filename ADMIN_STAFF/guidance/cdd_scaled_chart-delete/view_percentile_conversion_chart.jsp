<%@ page language="java" import="utility.*,enrollment.ScaledScoreConversion,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>

</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function Search(){	
	document.form_.search_.value = '1';	
	//document.form_.exam_name.value = document.form_.exam_main_index[document.form_.exam_main_index.selectedIndex].text;
	document.form_.exam_catg_name.value = document.form_.exam_catg[document.form_.exam_catg.selectedIndex].text;
	document.form_.submit();
}

function PrintPage()
{	
	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myTable1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myTable2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);	
	obj1.deleteRow(0);	
	obj1.deleteRow(0);		
	
	document.getElementById('myTable3').deleteRow(0);	
	
	document.getElementById('myTable4').deleteRow(0);
	document.getElementById('myTable4').deleteRow(0);	
		
	
	window.print();
}
</script>


<body bgcolor="#D2AE72">
<form name="form_" action="./view_percentile_conversion_chart.jsp" method="post">
<%
	DBOperation dbOP  = null;
	String strErrMsg  = null;	
	String strTemp    = null;
	String strExamMainIndex = WI.fillTextValue("exam_main_index");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-IQ Score Rating","view_percentile_conversion_chart.jsp");
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
									"Registrar Management","GRADES-IQ Score Rating",request.getRemoteAddr(), null);

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

ScaledScoreConversion scoreConversion = new ScaledScoreConversion();
Vector vRetResult = new Vector();
Vector vColumnDetail = new Vector();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

strTemp = WI.fillTextValue("search_");
if(strTemp.length() > 0){
	vRetResult = scoreConversion.operateOnPercentileConChart(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = scoreConversion.getErrMsg();	
}


%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myTable1">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          LIST OF PERCENTILE CONVERSION CHART ::::</strong></font></div></td>
    </tr>
    <tr><td height="25" colspan="6">&nbsp; &nbsp; &nbsp; <strong><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF"  id="myTable2">
	<!--<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">IQ Exam Name</td>
		<td>
		<select name="iq_exam_name" onChange="document.form_.submit();" >
			<option value="">Select Any</option>
			<%=dbOP.loadCombo("EXAM_MAIN_INDEX","exam_name", " from CDD_EXAM_MAIN where is_valid = 1 order by exam_name ", WI.fillTextValue("iq_exam_name"), false)%>
		</select>
		</td>
	</tr>-->
	
	<%if(strExamMainIndex.length() > 0){%>
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">Exam Category</td>
		<%
		strTemp = " from CDD_EXAM_CATG where is_valid = 1 AND EXAM_MAIN_INDEX = "+strExamMainIndex+" order by exam_catg_index ";
		%>
		<td>
		<select name="exam_catg">
			<option value="">Select Any</option>
			<%=dbOP.loadCombo("exam_catg_index","catg_name", strTemp, WI.fillTextValue("exam_catg"), false)%>
		</select>
		</td>
	</tr>
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Age From</td>
		<td>
		<select name="age_from" >
			<option value=""></option>
			<%//=dbOP.loadCombo("distinct age","age", " from CDD_IQ_RATING where is_valid = 1 order by age ", WI.fillTextValue("age_from"), false)%>
	<%
	for(int i = 7; i <= 70; i++){
		strTemp = WI.fillTextValue("age_from");
		if(strTemp.equals(i+""))
			strTemp = "selected";
		else
			strTemp = "";		
	%>	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
	<%}%>
		</select>
		</td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Age To</td>
		<td>
		<select name="age_to" >
			<option value=""></option>
			<%//=dbOP.loadCombo("distinct age","age", " from CDD_IQ_RATING where is_valid = 1 order by age ", WI.fillTextValue("age_to"), false)%>
		
	<%
	for(int i = 7; i <= 70; i++){
		strTemp = WI.fillTextValue("age_to");
		if(strTemp.equals(i+""))
			strTemp = "selected";
		else
			strTemp = "";		
	%>	<option value="<%=i%>" <%=strTemp%>><%=i%></option>
	<%}%>
		</select>
		</td>
	</tr>
	
	
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr>
		<td colspan="2" height="25">&nbsp;</td>
		<td>
		<a href="javascript:Search();">
		<img src="../../../../images/form_proceed.gif" border="0"></a>				
		</td>
	</tr>
	
	<tr><td colspan="3">&nbsp;</td></tr>
	
	<%}%>
</table>
  
<%if(vRetResult != null && vRetResult.size() > 0){%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myTable3">
	<tr>
		<td align="right" colspan="3">
		<a href="javascript:PrintPage();">
		<img src="../../../../images/print.gif" border="0"></a>
		</td>
	</tr>
	
	<tr><td colspan="3" align="center">Computronix College<br><i>Dagupan City</i></td></tr>
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr><td colspan="3" align="center"><strong>M.A.B. IQ AND PERCENTILE CONVERSION CHART</strong></td></tr>
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr><td colspan="3" align="center"><strong><%=WI.fillTextValue("age_from")%><%=WI.getStrValue(WI.fillTextValue("age_to"),"-","","")%> (<%=WI.getStrValue(WI.fillTextValue("exam_catg_name"))%>)</strong></td></tr>
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr>
		<td>
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
				<tr>
					<td align="center" width="30%" height="25" class="thinborder"><strong>Sum of Scaled Scores</strong></td>
					<td align="center" width="20%" class="thinborder"><strong>IQ</strong></td>
					<td align="center" width="30%" class="thinborder"><strong>Stand Score</strong></td>
					<td align="center" width="20%" class="thinborder"><strong>%ile Rank</strong></td>
				</tr>
				
			<%
			int iEndLoop = 0;
			if(vRetResult.size() > 405)
				iEndLoop = 405;
			else
				iEndLoop = vRetResult.size();
				
			for(int i =0; i < iEndLoop; i+=9){				
			%>
				<tr>
					<td align="center" width="30%" height="25" class="thinborder" ><%=(String)vRetResult.elementAt(i+3)%></td>
					<td align="center" width="20%" class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
					<td align="center" width="30%" class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
					<td align="center" width="20%" class="thinborder"><%=(String)vRetResult.elementAt(i + 6)%></td>
				</tr>
			<%}%>
			</table>
		</td>
		
		<%if(vRetResult.size() > 405){%>
		<td width="5%">&nbsp;</td>
		
		
		<td valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
				<tr>
					<td align="center" width="30%" height="25" class="thinborder" ><strong>Sum of Scaled Scores</strong></td>
					<td align="center" width="20%" class="thinborder"><strong>IQ</strong></td>
					<td align="center" width="30%" class="thinborder"><strong>Stand Score</strong></td>
					<td align="center" width="20%" class="thinborder"><strong>%ile Rank</strong></td>
				</tr>
			<%
			for(int i = 405; i < vRetResult.size(); i+=9){
			%>
				<tr>
					<td align="center" width="30%" height="25" class="thinborder" ><%=(String)vRetResult.elementAt(i)%></td>
					<td align="center" width="20%" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
					<td align="center" width="30%" class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
					<td align="center" width="20%" class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
				</tr>
			<%}%>
			</table>
		</td>
		<%}%>
	</tr>
	
	
	
</table>

<%}%>
  
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myTable4">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>" >
<input type="hidden" name="exam_name" value="<%=WI.fillTextValue("exam_name")%>" >
<input type="hidden" name="exam_catg_name" value="<%=WI.fillTextValue("exam_catg_name")%>" >
<input type="hidden" name="exam_main_index" value="<%=strExamMainIndex%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
