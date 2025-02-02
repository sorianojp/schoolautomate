<%@ page language="java" import="utility.*, enrollment.PersonalInfoManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Link Sibling</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
	
function UpdateAdditionalInfo() {
	if(document.form_.stud_id.value.length ==0) {
		alert("Please enter Student ID.");
		return;
	}
	var pgLoc = "../../admission/stud_personal_info_page2.jsp?stud_id="+document.form_.stud_id.value+
		"&parent_wnd=form_";
	var win=window.open(pgLoc,"EditWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
	function CancelOperation(strStudID){
		location = "./link_sibling.jsp?view_parent_info=1&stud_id="+strStudID;
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete sibling info?'))
				return;
		}
		document.form_.page_action.value = strAction;
		document.form_.view_parent_info.value = "1";
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	var objCOA;
	var objCOAInput;
	function AjaxMapName(strFieldName, strLabelID) {
		objCOA=document.getElementById(strLabelID);
		var strCompleteName = eval("document.form_."+strFieldName+".value");
		eval('objCOAInput=document.form_.'+strFieldName);
		if(strCompleteName.length <= 2) {
			objCOA.innerHTML = "";
			return ;
		}		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
	
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&name_format=4&complete_name="+escape(strCompleteName);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		objCOAInput.value = strID;
		objCOA.innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function ViewParentInfo(){
		document.form_.view_parent_info.value = "1";
		document.form_.submit();
	}
	
	function GoBack(){
		location = "./main_sibling.jsp";
	}
	
</script>
<body bgcolor="#8C9AAA">
<form name="form_" action="./link_sibling.jsp" method="post">
<%
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-Sibling Management","link_sibling.jsp");
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
															"Guidance & Counseling","Student Tracker",request.getRemoteAddr(),
															"link_sibling.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../admin_staff/admin_staff_home_button_content.htm");
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
	
	Vector vRetResult = null;
	Vector vParentInfo = null;
	
	PersonalInfoManagement pim = new PersonalInfoManagement();
	
	if(WI.fillTextValue("view_parent_info").length() > 0){
		vParentInfo = pim.getParentInformation(dbOP, request);
		if(vParentInfo == null)
			strErrMsg = pim.getErrMsg();
		else{
			strTemp = WI.fillTextValue("page_action");
	
			if(strTemp.length() > 0){
				if(pim.LinkSibling(dbOP, request, Integer.parseInt(strTemp), (String)vParentInfo.elementAt(0)) == null)
					strErrMsg = pim.getErrMsg();
				else{
					if(strTemp.equals("0"))
						strErrMsg = "Sibling removed successfully.";
					if(strTemp.equals("1")) {
						strErrMsg = "Sibling recorded successfully.";
						vParentInfo = pim.getParentInformation(dbOP, request);
					}
				}
			}
			
			vRetResult = pim.LinkSibling(dbOP, request, 4, (String)vParentInfo.elementAt(0));
		}
	}
	
%>	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr bgcolor="#697A8F">
			<td height="25" colspan="5" align="center"><font color="#FFFFFF">
				<strong>::::  LINK SIBLING ::::</strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		    <td align="right"><a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0"></a>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Student ID: </td>
		  	<td>
				<input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('stud_id','stud_id_');"></td>
			<td colspan="2"><label id="stud_id_" style="position:absolute; width: 400px"></label></td>
		</tr>
		<tr>
			<td height="15" colspan="5">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="3">
				<a href="javascript:ViewParentInfo()"><img src="../../../images/form_proceed.gif" border="0"></a>
					<font size="1">Click to view student parent information.</font>
				<%if(vParentInfo == null && strErrMsg != null && strErrMsg.equals("Parent information not found.")){%>
				&nbsp;&nbsp;
				<a href="javascript:UpdateAdditionalInfo();"><img src="../../../images/add.gif" border="0"></a>
					<font size="1">Click to add parent information.</font>
				<%}%>
			</td>
		</tr>
		<tr>
			<td height="15" width="3%">&nbsp;</td>
		    <td width="17%">&nbsp;</td>
		    <td width="22%">&nbsp;</td>
			<td width="48%">&nbsp;</td>
		    <td width="10%">&nbsp;</td>
		</tr>
	</table>

<%if(vParentInfo != null && vParentInfo.size() > 0){%>	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="4"><hr size="1"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3">
				<strong>PARENT INFORMATION</strong>
				<input type="hidden" name="parent_index" value="<%=(String)vParentInfo.elementAt(0)%>"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Father: </td>
			<td colspan="2"><%=WI.getStrValue((String)vParentInfo.elementAt(1), "-")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Occupation: </td>
			<td colspan="2">
				<%
					if((String)vParentInfo.elementAt(2) == null && (String)vParentInfo.elementAt(3) == null)
						strTemp = "-";
					else
						strTemp = WI.getStrValue((String)vParentInfo.elementAt(2)) + WI.getStrValue((String)vParentInfo.elementAt(3), " (", ")", "");
				%>
				<%=strTemp%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Mother: </td>
			<td colspan="2"><%=WI.getStrValue((String)vParentInfo.elementAt(7), "-")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Occupation: </td>
			<td colspan="2">
				<%
					if((String)vParentInfo.elementAt(8) == null && (String)vParentInfo.elementAt(9) == null)
						strTemp = "-";
					else
						strTemp = WI.getStrValue((String)vParentInfo.elementAt(8)) + WI.getStrValue((String)vParentInfo.elementAt(9), " (", ")", "");
				%>
				<%=strTemp%></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Sibling</td>
			<td width="22%">
				<input name="sibling_id" type="text" size="16" value="<%=WI.fillTextValue("sibling_id")%>" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					class="textbox" onKeyUp="AjaxMapName('sibling_id','sibling_id');"></td>
		    <td width="58%"><label id="sibling_id" style="position:absolute; width: 400px"></label></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="2">
				<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
	 			<a href="javascript:CancelOperation('<%=WI.fillTextValue("stud_id")%>');">
					<img src="../../../images/cancel.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
	</table>
	
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
		<tr bgcolor="#C4D0DD"> 
			<td height="25" colspan="5" align="center" class="thinborder">
				<strong>::: LIST SIBLINGS ::: </strong></td>
		</tr>
		<tr>
			<td height="25" width="8%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="18%" align="center" class="thinborder"><strong>ID Number</strong></td>
			<td width="50%" align="center" class="thinborder"><strong>Name</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Gender</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 4, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;
				<%
					strTemp = (String)vRetResult.elementAt(i+3);
					if(strTemp.equals("M"))
						strTemp = "Male";
					else
						strTemp = "Female";
				%><%=strTemp%></td>
			<td align="center" class="thinborder">	  
		  		<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
			<img src="../../../images/delete.gif" border="0"></a></td>
		</tr>
	<%}%>
	</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">	
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	<%}
}%>
	
	<input type="hidden" name="info_index">
	<input type="hidden" name="page_action">
	<input type="hidden" name="view_parent_info">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>