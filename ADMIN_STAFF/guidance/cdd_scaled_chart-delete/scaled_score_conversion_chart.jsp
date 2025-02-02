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

function PrepareToEdit(strInfoIndex){	
	document.form_.prepareToEdit.value = '1';
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}

function PageAction(strAction, strInfoIndex){
	if(strAction == '0'){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
		
		
	if(strAction == '1'){
		document.form_.save_.value = '1';
	}
	
	document.form_.page_action.value = strAction;	
	document.form_.submit();
}

function LoadExamName(){	
	document.form_.exam_details_name.value = document.form_.exam_dtls[document.form_.exam_dtls.selectedIndex].text;
	this.ReloadPage();
}

function ReloadPage(){
	document.form_.info_index.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.submit();
}

function ScoreSetFocus(){	
	document.form_.raw_score.value = "";
	document.form_.scaled_score.value = "";
	document.form_.raw_score.focus();
}

</script>




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
								"Admin/staff-Registrar Management-GRADES-IQ Score Rating","scaled_score_conversion_chart.jsp");
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
Vector vEditInfo  = new Vector();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if(strExamMainIndex.length() > 0){
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(scoreConversion.operateOnScaledScoreConvChart(dbOP, request, Integer.parseInt(strTemp)) == null)
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

	vRetResult = scoreConversion.operateOnScaledScoreConvChart(dbOP, request, 5);
	if(vRetResult == null)
		strErrMsg = scoreConversion.getErrMsg();
		
	if(strPrepareToEdit.length() > 0){	
		vEditInfo = scoreConversion.operateOnScaledScoreConvChart(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = scoreConversion.getErrMsg();
	}
}

boolean bolIsSaved = false;
if(WI.fillTextValue("save_").length() > 0){
	bolIsSaved = true;	
}


%>
<body bgcolor="#D2AE72" <%if(bolIsSaved){%> onLoad="ScoreSetFocus();" <%}%> >
<form name="form_" action="./scaled_score_conversion_chart.jsp" method="post">
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          SCALED SCORE CONVERSION CHART ::::</strong></font></div></td>
    </tr>
    <tr><td height="25" colspan="6">&nbsp; &nbsp; &nbsp; <strong><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">	
	
	<%if(strExamMainIndex.length() > 0){%>
	<tr>
		<td height="25" width="5%">&nbsp;</td>
		<td width="15%">Exam Category</td>		
		
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
		<select name="exam_catg" onChange="document.form_.submit();" >
			<option value="">Select Any</option>
			<%=dbOP.loadCombo("exam_catg_index","catg_name", strTemp2, strTemp, false)%>
		</select>
		</td>
	</tr>
	
	
	
	<%if(WI.fillTextValue("exam_catg").length() > 0){%>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Exam Details</td>		
		<%
		strTemp = WI.fillTextValue("exam_dtls");
		if(vEditInfo != null && vEditInfo.size() > 0){
			strExamMainIndex = (String)vEditInfo.elementAt(1);//this is iq_exam_index
			strTemp3 = (String)vEditInfo.elementAt(2);//this is exam_catg_index
			strTemp  = (String)vEditInfo.elementAt(3);//this is exam_catg_dtls_index
			
			strTemp2 = " from CDD_EXAM_CATG_DTLS where is_valid = 1 and EXAM_MAIN_INDEX = "+strExamMainIndex+
			  " and EXAM_CATG_INDEX = "+strTemp3+" and exam_catg_dtls_index = "+strTemp+" order by EXAM_CATG_NAME ";
		
		}else{
			strTemp2 = " from CDD_EXAM_CATG_DTLS where is_valid = 1 and EXAM_MAIN_INDEX = "+strExamMainIndex+
			  " and EXAM_CATG_INDEX = "+WI.fillTextValue("exam_catg")+" order by EXAM_CATG_NAME ";		
		}
		
		%>
		
		<td>
		<select name="exam_dtls" onChange="LoadExamName();" >
			<option value="">Select Any</option>
			<%=dbOP.loadCombo("EXAM_CATG_DTLS_INDEX","EXAM_CATG_NAME", strTemp2, strTemp, false)%>
		</select>
		</td>
	</tr>
	<%}%>
	
	<%if(WI.fillTextValue("exam_dtls").length() > 0){%>
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Raw Score</td>
		<%
		strTemp = WI.fillTextValue("raw_score");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(4);
		%>
		<td>
		<input type="text" name="raw_score" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','raw_score');style.backgroundColor='white';" 
					onkeyup="AllowOnlyInteger('form_','raw_score')" size="5" maxlength="5" value="<%=strTemp%>" />
		</td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Scaled Score</td>
		<%
		strTemp = WI.fillTextValue("scaled_score");
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(5);
		%>
		<td>
		<input type="text" name="scaled_score" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyInteger('form_','scaled_score');style.backgroundColor='white';" 
					onkeyup="AllowOnlyInteger('form_','scaled_score')" size="5" maxlength="5" value="<%=strTemp%>" />
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
				<img src="../../../../images/save.gif" border="0"></a>		
				<font size="1">Click to save conversion</font>
			<%}else if(strPrepareToEdit.length() > 0 && vEditInfo != null && vEditInfo.size() > 0){%>
				<a href="javascript:PageAction('2','<%=(String)vEditInfo.elementAt(0)%>');">
				<img src="../../../../images/edit.gif" border="0"></a>		
				<font size="1">Click to update conversion</font>
			<%}%>			
			<a href="javascript:ReloadPage();">
			<img src="../../../../images/cancel.gif" border="0"></a>		
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
	<tr><td height="25" colspan="3" align="center" class="thinborder"><%=WI.fillTextValue("exam_details_name")%></td></tr>
	<tr>
		<td class="thinborder" align="center" height="25" width="30%"><strong>RAW SCORE</strong></td>
		<td class="thinborder" align="center" height="25" width="30%"><strong>SCALED SCORE</strong></td>
		<td class="thinborder" align="center" height="25"><strong>OPTION</strong></td>
	</tr>
	
	<%
	for(int i = 0; i < vRetResult.size(); i += 6){
	%>
	<tr>
		<td class="thinborder" align="center" height="25"><%=(String)vRetResult.elementAt(i+4)%></td>
		<td class="thinborder" align="center" height="25"><%=(String)vRetResult.elementAt(i+5)%></td>
		<td class="thinborder" align="center">
			<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
			<img src="../../../../images/edit.gif" border="0"></a>
			
			<%if(iAccessLevel == 2){%>
			<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
			<img src="../../../../images/delete.gif" border="0"></a>
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
<input type="hidden" name="exam_details_name" value="<%=WI.fillTextValue("exam_details_name")%>" />
<input type="hidden" name="exam_main_index" value="<%=strExamMainIndex%>" />
<input type="hidden" name="save_" />

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
