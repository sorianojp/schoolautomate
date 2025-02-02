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
<script language="JavaScript">
function ReloadPage(){
	document.form_.info_index.value = '';
	document.form_.prepareToEdit.value = '';
	document.form_.submit();
}

function PageAction(strAction, strInfoIndex){
	if(strAction == '0'){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	
	document.form_.page_action.value = strAction;	
	document.form_.submit();
}

function PrepareToEdit(strInfoIndex){
	document.form_.prepareToEdit.value = '1';
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
</script>


<body bgcolor="#D2AE72">

<%
	DBOperation dbOP  = null;
	String strErrMsg  = null;	
	String strTemp    = null;
	String strTemp2   = null;
	String strTemp3   = null;
	String strExamMainIndex = WI.fillTextValue("exam_main_index");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Guidance & Counseling-IQ Test","percentile_conversion_chart.jsp");
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
Vector vEditInfo  = new Vector();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if(strExamMainIndex.length() > 0){
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){		
		if(scoreConversion.operateOnPercentileConChart(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = scoreConversion.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Entry Successfully Deleted.";
			if(strTemp.equals("1"))
				strErrMsg = "Entry Successfully Saved.";
			if(strTemp.equals("2"))
				strErrMsg = "Entry Successfully Updated.";
			strPrepareToEdit = "";
			
		}
	}
	
	vRetResult = scoreConversion.operateOnPercentileConChart(dbOP, request, 5);
	if(vRetResult == null)
		strErrMsg = scoreConversion.getErrMsg();
		
	if(strPrepareToEdit.length() > 0){
		vEditInfo = scoreConversion.operateOnPercentileConChart(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = scoreConversion.getErrMsg();
	}
}
%>
<form name="form_" action="./percentile_conversion_chart.jsp" method="post">
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          PERCENTILE CONVERSION CHART ::::</strong></font></div></td>
    </tr>
    <tr><td height="25" colspan="6">&nbsp; &nbsp; &nbsp; <strong><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<%if(strExamMainIndex.length() > 0){%>
	<tr>
		<td width="5%" height="25">&nbsp;</td>
		<td width="15%">Exam Type</td>
		<%
		strTemp = WI.fillTextValue("exam_catg");		
		if(vEditInfo != null && vEditInfo.size() > 0){
			strTemp = (String)vEditInfo.elementAt(2);			
			strExamMainIndex = (String)vEditInfo.elementAt(1);
			
			strTemp2 = " from CDD_EXAM_CATG where is_valid = 1 AND exam_catg_index = "+strTemp+
				" and EXAM_MAIN_INDEX = "+strExamMainIndex+" order by exam_catg_index ";
		}else{
			strTemp2 = " from CDD_EXAM_CATG where is_valid = 1 AND EXAM_MAIN_INDEX = "+strExamMainIndex+" order by exam_catg_index ";		
		}
		%>
		<td>
		<select name="exam_catg" onChange="ReloadPage();" >
			<option value="">Select Any</option>
			<%=dbOP.loadCombo("exam_catg_index","catg_name", strTemp2, strTemp, false)%>
		</select>
		</td>
	</tr>
	
	
	<%if(WI.fillTextValue("exam_catg").length() > 0){%>
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">Sum of Scaled Scores</td>				
		<%
		strTemp = WI.fillTextValue("sum_scaled_score");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(3);
		%>
		<td>
		<input type="text" name="sum_scaled_score" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','sum_scaled_score');style.backgroundColor='white';" 
					onkeyup="AllowOnlyInteger('form_','sum_scaled_score')" size="5" maxlength="5" value="<%=strTemp%>" />
		</td>
	</tr>
	
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">IQ</td>
		<%
		strTemp = WI.fillTextValue("iq_score");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(4);
		%>
		<td>
		<input type="text" name="iq_score" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','iq_score');style.backgroundColor='white';" 
					onkeyup="AllowOnlyInteger('form_','iq_score')" size="5" maxlength="5" value="<%=strTemp%>" />
		</td>
	</tr>
	
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">Standard Score</td>
		<%
		strTemp = WI.fillTextValue("standard_score");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(5);
		%>
		<td>
		<input type="text" name="standard_score" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','standard_score');style.backgroundColor='white';" 
					onkeyup="AllowOnlyInteger('form_','standard_score')" size="5" maxlength="5" value="<%=strTemp%>" />
		</td>
	</tr>
	
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">Percentile Ranking</td>
		<%
		strTemp = WI.fillTextValue("percentile_rank");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);
		%>
		<td>
		<input type="text" name="percentile_rank" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','percentile_rank');style.backgroundColor='white';" 
					onkeyup="AllowOnlyInteger('form_','percentile_rank')" size="5" maxlength="5" value="<%=strTemp%>" />
		</td>
	</tr>
	
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">Age From</td>
		<td>
		<select name="age_from" >
			<option value=""></option>
			<%//=dbOP.loadCombo("distinct age","age", " from CDD_IQ_RATING where is_valid = 1 order by age ", WI.fillTextValue("age_from"), false)%>
	<%
	for(int i = 7; i <= 70; i++){
		strTemp = WI.fillTextValue("age_from");				
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);		
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
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">Age To</td>
		<td>
		<select name="age_to" >
			<option value=""></option>
			<%//=dbOP.loadCombo("distinct age","age", " from CDD_IQ_RATING where is_valid = 1 order by age ", WI.fillTextValue("age_to"), false)%>
		
	<%
	for(int i = 7; i <= 70; i++){
		strTemp = WI.fillTextValue("age_to");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(8);
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
		<%if(iAccessLevel > 1){
			if(strPrepareToEdit.length() == 0){
		%>			
				<a href="javascript:PageAction('1','');">
				<img src="../../../images/save.gif" border="0"></a>		
				<font size="1">Click to save conversion</font>
			<%}else if(strPrepareToEdit.length() > 0 && vEditInfo != null && vEditInfo.size() > 0){%>
				<a href="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');">
				<img src="../../../images/edit.gif" border="0"></a>		
				<font size="1">Click to update conversion</font>
			<%}%>			
			<a href="javascript:ReloadPage();">
			<img src="../../../images/cancel.gif" border="0"></a>		
			<font size="1">Click to refresh page</font>
		<%}%>
		</td>
	</tr>
		<%}
	}%>
	<tr><td colspan="3">&nbsp;</td></tr>
</table>
  
  
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td class="thinborder" align="center" height="25" width="15%"><strong>Sum of Scaled Score</strong></td>
		<td class="thinborder" align="center" width="15%"><strong>IQ</strong></td>
		<td class="thinborder" align="center" width="15%"><strong>Standard Score</strong></td>
		<td class="thinborder" align="center" width="15%"><strong>%ile Rank</strong></td>
		<td class="thinborder" align="center" width="10%"><strong>Age From</strong></td>
		<td class="thinborder" align="center" width="10%"><strong>Age To</strong></td>
		<td class="thinborder" align="center" width="20%"><strong>Option</strong></td>
	</tr>
	
	<%
	for(int i = 0; i < vRetResult.size(); i+=9){
	%>
	
	<tr>
		<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
		<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
		<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
		<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
		
		<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+7)%></td>
		<td align="center" class="thinborder"><%=(String)vRetResult.elementAt(i+8)%></td>
		
		<td class="thinborder" align="center">
			<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
			<img src="../../../images/edit.gif" border="0"></a>
			
			<%if(iAccessLevel == 2){%>
			<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
			<img src="../../../images/delete.gif" border="0"></a>
			<%}%>
		</td>
	</tr>
	
	<%}%>
</table>
<%}%>


  
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td colspan="8" height="25" >&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8"  height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action" >
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="exam_main_index" value="<%=strExamMainIndex%>" />

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
