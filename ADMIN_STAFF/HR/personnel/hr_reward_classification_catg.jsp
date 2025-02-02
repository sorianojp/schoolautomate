<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoResearchWork" %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="javascript" src="../../../jscript/td.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this sub-category?'))
				return;
		}
		document.staff_profile.donot_call_close_wnd.value = "1";
		document.staff_profile.page_action.value = strAction;
		if(strAction == '1') 
			document.staff_profile.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.staff_profile.info_index.value = strInfoIndex;
		document.staff_profile.submit();
	}
	
	function PrepareToEdit(strInfoIndex) {
		document.staff_profile.donot_call_close_wnd.value = "1";
		document.staff_profile.page_action.value = "";
		document.staff_profile.prepareToEdit.value = "1";
		document.staff_profile.info_index.value = strInfoIndex;
		document.staff_profile.submit();
	}
	
	function CancelOperation(){
		document.staff_profile.donot_call_close_wnd.value = "1";
		document.staff_profile.category_name.value = "";
		document.staff_profile.submit();
	}
	
	function FocusID(){
		document.staff_profile.category_name.focus();
	}
	
</script>
<%	
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
		
	//add security here
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null ) 
		strSchCode = "";
	boolean bolAUF = strSchCode.startsWith("AUF");

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_reward_classification_catg.jsp.jsp");		
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
															"HR Management","PERSONNEL",request.getRemoteAddr(),
															"hr_reward_classification_catg.jsp");
	// added for AUF
	strTemp = (String)request.getSession(false).getAttribute("userId");	
	if (strTemp == null) 
		strTemp = "";
	//
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
	
	String strClassificationIndex = WI.fillTextValue("classification_index");
	if(strClassificationIndex.length() == 0){%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">Classification reference not found. Please close this window and click update button from main page.</font></p>
	<%
		return;
	}

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vEditInfo = null;
	Vector vRetResult = null;
	HRInfoResearchWork hrIRW = new HRInfoResearchWork();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(hrIRW.operateOnClassificationCatg(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = hrIRW.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Classification category successfully removed.";
			else if(strTemp.equals("1"))
				strErrMsg = "Classification category successfully recorded.";
			else if(strTemp.equals("2"))
				strErrMsg = "Classification category successfully edited.";
			
			strPrepareToEdit = "0";
		}
	}
	
	vRetResult = hrIRW.operateOnClassificationCatg(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = hrIRW.getErrMsg();
	
	if(strPrepareToEdit.equals("1")){
		vEditInfo = hrIRW.operateOnClassificationCatg(dbOP, request, 3);
		if(vEditInfo == null)
			strErrMsg = hrIRW.getErrMsg();
	}	
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form name="staff_profile" method="post" action="./hr_reward_classification_catg.jsp">
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25" colspan="3" align="center" bgcolor="#A49A6A" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: CLASSIFICATION CATEGORY ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Classification Catg </td>
			<td width="80%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(1);
					else
						strTemp = WI.fillTextValue("category_name");
				%>
				<input name="category_name" type="text" value="<%=strTemp%>" class="textbox" size="64" maxlength="128"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
			<td height="25">
				<%if(iAccessLevel > 1){
					if(strPrepareToEdit.equals("0")) {%>
						<a href="javascript:PageAction('1', '');">
							<img src="../../../images/save.gif" border="0"></a>
					<%}else {
						if(vEditInfo!=null){%>
							<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
								<img src="../../../images/edit.gif" border="0"></a>
						<%}
					}%>
					<a href="javascript:CancelOperation();"><img src="../../../images/refresh.gif" border="0"></a>
					<font size="1">Click to refresh page.</font>
				<%}else{%>
					Not authorized to save classification category.
				    <%}%></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr bgcolor="#B9B292">
			<td height="20" colspan="3" class="thinborder"><div align="center"><strong>::: LIST OF CLASSIFICATION CATEGORIES :::</strong></div></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="75%" align="center" class="thinborder"><strong>Classification Category Name </strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 2, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td align="center" class="thinborder">
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../../images/delete.gif" border="0"></a>
					<%}
				}else{%>
					N/A
				<%}%>
			</td>
		</tr>
	<%}%>
	</table>
<%}%>
  
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
  	
	<input type="hidden" name="classification_index" value="<%=strClassificationIndex%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>">  
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
