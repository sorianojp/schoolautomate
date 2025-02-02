<%@ page language="java" import="utility.*,osaGuidance.StudentPersonalDataCIT,java.util.Vector " %>
<%
	WebInterface WI = new WebInterface(request);
	
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;
	
	//add security here.
	try	{
		dbOP = new DBOperation();
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
															"Registrar Management","STUDENT PERSONAL DATA-OTHER INFO",request.getRemoteAddr(),
															null);
	if(iAccessLevel == 0)
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Guidance & Counseling","STUDENT PERSONAL DATA-OTHER INFO",request.getRemoteAddr(), null);														
																
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
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Student Personal Data</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">

	function AjaxUpdateOthers(strIndexName, strIndex, strTableName, strFieldName, strIsString, objCOA){
		<%if(iAccessLevel == 1){%>
			return;
		<%}%>
		//var objCOA=eval('document.form_.'+strFieldName);
		this.InitXmlHttpObject(objCOA, 1);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=20401&table_name="+strTableName+"&field_name="+strFieldName+"&table_index="+strIndex+"&is_string="+strIsString+"&field_value="+escape(objCOA.value)+"&"+strFieldName+"="+escape(objCOA.value)+"&index_name="+strIndexName;
		this.processRequest(strURL);
	}
	
	function GoBack(){
		location = "./student_personal_data.jsp?get_student_info=1&stud_id="+document.form_.stud_id.value;
	}
	
</script>
<%	
	String strUserIndex = WI.fillTextValue("stud_index");
	if(strUserIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Student reference is not found. Please close this window and click on the Part II link to try again..</p>
	<%return;}
	
	StudentPersonalDataCIT spd = new StudentPersonalDataCIT();	
	Vector vRetResult = spd.getOtherInfo(dbOP, request, strUserIndex);
	if(vRetResult == null)
		strErrMsg = spd.getErrMsg();
%>
<body bgcolor="#D2AE72">
<form name="form_" action="other_info.jsp" method="post">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4"><div align="center"><font color="#FFFFFF"><strong>:::: OTHER INFORMATION ::::</strong></font></div></td>
		</tr>
		<tr> 
			<td width="90%" height="25"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
			<td width="10%" align="right">
				<a href="javascript:GoBack();"><img src="../../../../images/go_back.gif" border="0"></a></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25"><strong>I. PSYCHOLOGICAL TEST TAKEN </strong></td>
					</tr>
					<tr>
						<td>&nbsp;
							<textarea name="psych_test_taken" style="font-size:12px" cols="120" rows="6" class="textbox" 
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','psych_test_taken','1', document.form_.psych_test_taken);"><%=WI.getStrValue((String)vRetResult.elementAt(0))%></textarea></td>
					</tr>
				</table>
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr>
			<td>
				<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<tr>
						<td height="25"><strong>II. NOTES</strong></td>
					</tr>
					<tr>
						<td>&nbsp;
							<textarea name="notes" style="font-size:12px" cols="120" rows="6" class="textbox" 
								onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';javascript:AjaxUpdateOthers('user_index', '<%=strUserIndex%>','INFO_SPIS_CIT','notes','1', document.form_.notes);"><%=WI.getStrValue((String)vRetResult.elementAt(1))%></textarea></td>
					</tr>
				</table>
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
	
	<input type="hidden" name="stud_index" value="<%=strUserIndex%>">
	<input type="hidden" name="stud_id" value="<%=WI.fillTextValue("stud_id")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>