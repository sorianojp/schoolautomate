
<%

String strAuthID = (String)request.getSession(false).getAttribute("userIndex");
if(strAuthID == null){%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">You are not authorized to manage evaluation settings.</font></p>
<%return;}

String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">

function PageAction(strAction, strInfoIndex){
	if(strAction == '0'){
		if(!confirm("Do you want to delete this entry?"))
			return;
	}
	
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
		
	document.form_.page_action.value =strAction;
	document.form_.submit();
}

function ManageEvalPeriod(strSYFrom,strSYTo,strIsActive){
	var strCriteriaIndex= document.form_.cIndex.value;
	if(strCriteriaIndex.length == 0 || strCriteriaIndex == "0"){
		alert("Please provide evaluation criteria.");
		return;
	}

	var loadPg = "./manage_eval_period.jsp?is_forwared=1&criteria_index="+strCriteriaIndex+
		"&sy_from="+strSYFrom+
		"&sy_to="+strSYTo+
		"&is_active="+strIsActive;
	var win=window.open(loadPg,"ManageEvalPeriod",'dependent=yes,width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.info_index.value = "";
	document.form_.submit();
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,hr.HREvaluationSheetExtn" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;




//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-ASSESSMENT AND EVALUATION-Evaluation Sheet","hr_evaluation_setting.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","ASSESSMENT AND EVALUATION",request.getRemoteAddr(),
														"hr_evaluation_setting.jsp");
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

Vector vRetResult = new Vector();

HREvaluationSheetExtn hrESExtn = new HREvaluationSheetExtn();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if( hrESExtn.operateOnEvaluationSetting(dbOP, request, Integer.parseInt(strTemp) ) == null )
		strErrMsg = hrESExtn.getErrMsg();
	else{
		if(strTemp.equals("0"))
			strErrMsg = "Entry successfully deleted.";
		if(strTemp.equals("1"))
			strErrMsg = "Entry successfully saved.";
	}
}


vRetResult = hrESExtn.operateOnEvaluationSetting(dbOP, request, 4 );
if(vRetResult == null && strErrMsg == null)	
	strErrMsg = hrESExtn.getErrMsg();

%>
<body bgcolor="#663300" class="bgDynamic">
<form action="./hr_evaluation_setting.jsp" method="post" name="form_">

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr bgcolor="#A49A6A">
		<td height="25" bgcolor="#A49A6A" class="footerDynamic">
			<div align="center"><font color="#FFFFFF" ><strong>:::: MANAGE EVALUATION SETTING PAGE ::::</strong></font></div></td>
	</tr>
	<tr>
		<td height="25"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
	</tr>
</table>

<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="3%" height="25">&nbsp;</td>
        <td width="19%" height="25">Evaluation Criteria</td>
        <td width="78%"> 
			<select name="cIndex" id="cIndex" onChange='ReloadPage();'>
				<option value="">Select Evaluation Criteria</option>
				<%=dbOP.loadCombo("CRITERIA_INDEX","CRITERIA_NAME"," FROM HR_EVAL_CRITERIA",WI.fillTextValue("cIndex"),false)%> 
			</select>		</td>
   </tr>
   <tr>
   		<td>&nbsp;</td>
		<td>Evaluation Year</td>
		<td>
			<input name="sy_from" type="text" class="textbox" id="sy_from"  
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="4" maxlength="4"
				value="<%=WI.fillTextValue("sy_from")%>"
			  	onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
	  		  	onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
              to
            <input name="sy_to" type="text" class="textbox" id="sy_to"  
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="4" maxlength="4"
			  	onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
			  	value="<%=WI.fillTextValue("sy_to")%>" readonly>		</td>
   </tr>
   <tr>
       <td>&nbsp;</td>
       <td>&nbsp;</td>
       <td>
	   	<a href="javascript:PageAction('1','');"><img src="../../../images/save.gif" border="0"></a>
		<font size="1">Click to save entry</font>
	   </td>
   </tr>
</table>

<%
if(vRetResult != null && vRetResult.size() > 0){


%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	    <td width="17%">&nbsp;</td>
		<td width="39%" height="25"><strong>Evaluation Year</strong></td>
		<td width="11%" align="center"><strong>Is Active</strong></td>
		<td width="15%" align="center"><strong>Delete</strong></td>
	    <td width="18%" align="center"><strong>Manage<br>Evaluation Period</strong></td>
	</tr>
	<%
	for(int i = 0; i < vRetResult.size(); i+=10){
	%>
	<tr>
	    <td>&nbsp;</td>
		<td height="25"><%=vRetResult.elementAt(i+2)%>-<%=vRetResult.elementAt(i+3)%></td>
		<%
		strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4),"0");
		if(strTemp.equals("0"))
			strTemp = "<img src='../../../images/x.gif' border='0'>";
		else
			strTemp = "<img src='../../../images/tick.gif' border='0'>";
		%>
	    <td align="center"><%=strTemp%></td>
		<td align="center">
			<a href="javascript:PageAction('0','<%=vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a>		</td>
		<td align="center">
			<a href="javascript:ManageEvalPeriod('<%=vRetResult.elementAt(i+2)%>','<%=vRetResult.elementAt(i+3)%>','<%=vRetResult.elementAt(i+4)%>')"><img src="../../../images/add.gif" border="0"></a>		</td>
	</tr>
	<%}%>
</table>
<%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td></tr>
</table>

<input type="hidden" name="page_action" >
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

