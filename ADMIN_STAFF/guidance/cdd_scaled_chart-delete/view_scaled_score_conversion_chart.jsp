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
	document.form_.exam_name.value = document.form_.iq_exam_name[document.form_.iq_exam_name.selectedIndex].text;
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
		
	/**var obj1 = document.getElementById('myTable2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);
	obj1.deleteRow(0);	*/
	
	document.getElementById('myTable3').deleteRow(0);	
	
	document.getElementById('myTable4').deleteRow(0);
	document.getElementById('myTable4').deleteRow(0);	
		
	
	window.print();
}
</script>


<body bgcolor="#D2AE72">
<form name="form_" action="./view_scaled_score_conversion_chart.jsp" method="post">
<%
	DBOperation dbOP  = null;
	String strErrMsg  = null;	
	String strTemp    = null;
	String strExamMainIndex = WI.fillTextValue("exam_main_index");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-IQ Score Rating","view_scaled_score_conversion_chart.jsp");
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


	vRetResult = scoreConversion.operateOnScaledScoreConvChart(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = scoreConversion.getErrMsg();
	else
		vColumnDetail = (Vector)vRetResult.remove(0);



%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myTable1">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          LIST OF SCALED SCORE CONVERSION CHART ::::</strong></font></div></td>
    </tr>
    <tr><td height="25" colspan="6">&nbsp; &nbsp; &nbsp; <strong><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td></tr>
</table>

<!--<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF"  id="myTable2">
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">IQ Exam Name</td>
		<td>
		<select name="iq_exam_name" onChange="" >
			<option value="">Select Any</option>
			<%//=dbOP.loadCombo("EXAM_MAIN_INDEX","exam_name", " from CDD_EXAM_MAIN where is_valid = 1 order by exam_name ", WI.fillTextValue("iq_exam_name"), false)%>
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
</table>-->
  
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myTable3">
	<td><td colspan="3" align="right">
	<a href="javascript:PrintPage();">
		<img src="../../../../images/print.gif" border="0"></a>
	</td></td>
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr>
		<td height="30" width="20%"><font size="+1"><strong>M.A.B.</strong></font></td>
		<td align="center"><strong><font size="+1">SCALED SCORE CONVERSION CHART</font></strong></td>
		<td align="right" width="20%">RAW = Raw Score<br>SCA = Scaled Score</td>
	</tr>
	<tr><td colspan="3">&nbsp;</td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
	<%
	for(int i = 0; i < vColumnDetail.size(); i+=2){
	%>
		<td align="center" height="20" class="thinborder" colspan="2"><strong><%=(String)vColumnDetail.elementAt(i)%></strong></td>			
	<%}%>		
	</tr>
	
	<tr>
	<%
	for(int i = 0; i < vColumnDetail.size(); i+=2){
	%>
		<td align="center" height="20" class="thinborder"><strong>RAW</strong></td>
		<td align="center" height="20" class="thinborder"><strong>SCA</strong></td>					
	<%}%>		
	</tr>
	
	
	
	<tr>
	<%
	String strRawScore = "";
	String strScaledScore = "";
	for(int i = 0; i < vColumnDetail.size(); i+=2){
	%>
		<td valign="top" align="center" height="20" class="thinborder">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
				<%
				for(int x = 0; x < vRetResult.size(); x+=6){
					if(((String)vRetResult.elementAt(x+4)).equals((String)vColumnDetail.elementAt(i)))					
						strRawScore = (String)vRetResult.elementAt(x+1);								
					else
						continue;
				%>
				<tr>
					<td valign="top" align="center" style="border-bottom:1px #000000 solid;"><%=WI.getStrValue(strRawScore)%></td>					
				</tr>
				<%}%>
			</table>
		</td>
		
		
		<td valign="top" align="center" height="20" class="thinborder">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF"  >
				<%
				for(int x = 0; x < vRetResult.size(); x+=6){
					if(((String)vRetResult.elementAt(x+4)).equals((String)vColumnDetail.elementAt(i)))									
						strScaledScore = (String)vRetResult.elementAt(x+2);						
					else						
						continue;
					
				%>
				<tr>					
					<td valign="top" align="center" style="border-bottom:1px #000000 solid;"><%=WI.getStrValue(strScaledScore)%></td>
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
<input type="hidden" name="exam_main_index" value="<%=strExamMainIndex%>" />

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
