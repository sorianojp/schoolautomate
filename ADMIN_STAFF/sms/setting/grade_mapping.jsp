<%
String strUserID = (String)request.getSession(false).getAttribute("userId");
if(request.getSession(false).getAttribute("userIndex") == null) {%>
	<p style="font-size:14px; color:red; font-weight:bold; font-family:Georgia, 'Times New Roman', Times, serif">You are logged out. Please login again.</p>
<%return;}%>

<%@ page language="java" import="utility.*,sms.SystemSetup,sms.utility.CommonInterface, java.util.Vector" %>
<%	
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function RefreshPage(){
		location = "./grade_mapping.jsp";
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this grade mapping?'))
				return;
		}
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
</script>

<body bgcolor="#D2AE72">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	try {
		dbOP = new DBOperation(strUserID,"SMS-Setting","grade_mapping.jsp");
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

	Vector vEditInfo = null;
	Vector vRetResult = null;
	String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"), "0");
	
	SystemSetup systemSetup = new SystemSetup();
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(systemSetup.operateOnGradeRefMapping(dbOP, request, Integer.parseInt(strTemp)) == null) 
			strErrMsg = systemSetup.getErrMsg();
		else {
			if(strTemp.equals("0"))
				strErrMsg = "Grade mapping successfully removed.";
			else if(strTemp.equals("1"))
				strErrMsg = "Grade mapping successfully recorded.";
			else
				strErrMsg = "Grade mapping successfully edited.";
			
			//strErrMsg = "Operation Successful.";			
			strPreparedToEdit = "0"; 
		}
	}
	
	if(strPreparedToEdit.equals("1"))
		vEditInfo = systemSetup.operateOnGradeRefMapping(dbOP, request, 3);
		
	vRetResult = systemSetup.operateOnGradeRefMapping(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = systemSetup.getErrMsg();
%>
<form action="./grade_mapping.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: GRADE MAPPING ::::</strong></font></div></td>
		</tr>
	</table>
			
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Reference Num: </td>
			<td width="80%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("reference"), "1");
				%>
				<select name="reference">
					<%for(int i = 1; i <= 10; i++){
						if(strTemp.equals(Integer.toString(i))){%>
							<option value="<%=i%>" selected><%=i%></option>
						<%}else{%>
							<option value="<%=i%>"><%=i%></option>
						<%}
					}%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Basic:</td>
			<td>
				<%
					strTemp = 
						" from fa_pmt_schedule where is_valid = 2 and is_del = 0 "+
						" and bsc_grading_name is not null order by exam_period_order ";
				%>
				<select name="pmi_basic">
					<option value="">N/A</option>
					<%=dbOP.loadCombo("pmt_sch_index","bsc_grading_name", strTemp, WI.fillTextValue("pmi_basic"), false)%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>College:</td>
			<td>
				<%
					strTemp = 
						" from fa_pmt_schedule where is_valid = 1 and is_del = 0 "+
						" order by exam_period_order ";
				%>
				<select name="pmi_college">
					<option value="">N/A</option>
					<%=dbOP.loadCombo("pmt_sch_index","exam_name", strTemp, WI.fillTextValue("pmi_college"), false)%>
				</select></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
				<font size="1">Click to save grade mapping info.</font>	  			
				&nbsp;
				<a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font>
			</td>				
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
  
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<tr> 
			<td height="20" colspan="4" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>
				<font color="#FFFFFF">LIST OF CREATED GRADE MAPPING </font></strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="40%" align="center" class="thinborder"><strong>Basic</strong></td>
			<td width="40%" align="center" class="thinborder"><strong>College</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Delete</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 3, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1), "N/A")%></td>
			<td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2), "N/A")%></td>
			<td align="center" class="thinborder">
				<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>')">
					<img src="../../../images/delete.gif" border="0"></a></td>
		</tr>
	<%}%>
	</table>
<%}//vRetResult is not null%>
  
	<table  bgcolor="#999900" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="info_index">
	<input type="hidden" name="page_action">
	<input type="hidden" name="prepareToEdit" value="<%=strPreparedToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>