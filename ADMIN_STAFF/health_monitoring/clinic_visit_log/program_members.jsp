<%@ page language="java" import="utility.*, health.AUFHealthProgram, java.util.Vector " %>
<%
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(8);
	//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">

	function ViewDependentDetails(strInfoIndex, strUserIndex){
		var pgLoc = "./program_members_detail.jsp?info_index="+strInfoIndex+"&user_index="+strUserIndex;
		var win=window.open(pgLoc,"ViewDependentDetails",'width=600,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function RefreshPage(){
		var vEmpID = document.form_.emp_id.value;
		location = "./program_members.jsp?searchEmployee=1&emp_id="+vEmpID;
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete this dependent?'))
				return;
		}
		document.form_.page_action.value = strAction;
		if(strAction == '1') 
			document.form_.prepareToEdit.value='';
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		this.SearchEmployee();
	}

	function PrepareToEdit(strInfoIndex) {
		document.form_.page_action.value = "";
		document.form_.prepareToEdit.value = "1";
		document.form_.info_index.value = strInfoIndex;
		this.SearchEmployee();
	}

	function SearchEmployee() {	
		if(document.form_.emp_id.value == '') {
			alert("Please enter employee ID.");
			return;
		} 
		document.form_.searchEmployee.value="1";
		document.form_.submit();
	}
	
	function OpenSearch() {
		var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
		var win=window.open(pgLoc,"OpenSearch",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
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
	
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1"+
		"&name_format=4&complete_name="+escape(strCompleteName);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		objCOAInput.value = strID;
		objCOA.innerHTML = "";
		this.SearchEmployee();
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
</script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;	

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","program_members.jsp");
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
															"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
															"program_members.jsp");
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
	
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	Vector vUserInfo = null;
	Vector vRetResult = null;
	Vector vEditInfo = null;
	
	AUFHealthProgram hp = new AUFHealthProgram();
	
	enrollment.Authentication auth = new enrollment.Authentication();
    request.setAttribute("emp_id", WI.fillTextValue("emp_id"));
    if(WI.fillTextValue("emp_id").length() > 0)
		vUserInfo = auth.operateOnBasicInfo(dbOP, request, "0");
	if(vUserInfo == null)
		strErrMsg = auth.getErrMsg();
	
	if(WI.fillTextValue("searchEmployee").length() > 0 && vUserInfo != null){
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0){
			if(hp.operateOnHealthProgramMembers(dbOP, request, Integer.parseInt(strTemp), (String)vUserInfo.elementAt(0)) == null){
				strErrMsg = hp.getErrMsg();
			} else {				
				if(strTemp.equals("0"))
					strErrMsg = "Dependent record successfully removed.";
				else if(strTemp.equals("1"))
					strErrMsg = "Dependent record successfully recorded.";
				else
					strErrMsg = "Dependent record successfully edited.";
				
				strPrepareToEdit = "0";
			}
		}		
		
		vRetResult = hp.operateOnHealthProgramMembers(dbOP,request, 4, (String)vUserInfo.elementAt(0));
		if(vRetResult == null && strTemp.length() == 0)
			strErrMsg = hp.getErrMsg();
		
		if(strPrepareToEdit.equals("1")){
			vEditInfo = hp.operateOnHealthProgramMembers(dbOP,request, 3, (String)vUserInfo.elementAt(0));
			if(vEditInfo == null)
				strErrMsg = hp.getErrMsg();
		}
	}
%>
<body bgcolor="#8C9AAA" class="bgDynamic">
<form action="./program_members.jsp" method="post" name="form_">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#697A8F"> 
			<td height="25" class="footerDynamic" colspan="3"><div align="center"><font color="#FFFFFF">
				<strong>:::: HEALTH PROGRAM MEMBERS MAINTENANCE PAGE ::::</strong></font></div></td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Employee ID: </td>
			<td width="80%">
				<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('emp_id','emp_id_');" class="textbox">
				<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>
				&nbsp;&nbsp;
				<label id="emp_id_" style="width:300px; position:absolute"></label></td>
		</tr>
		<tr>
			<td height="40" colspan="2">&nbsp;</td>
			<td valign="middle">
				<a href="javascript:SearchEmployee();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to view employee dependent list.</font></td>
		</tr>
	</table>

<%if(vUserInfo != null && vUserInfo.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="10" colspan="3"><hr size="1" color="#000000"></td>
		</tr>
		<tr>
			<td height="25" colspan="3">&nbsp;<strong>Employee Information: </strong></td>
		</tr>
		<tr> 
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Employee ID:</td>
			<td width="80%"><%=WI.fillTextValue("emp_id")%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Name:</td>
			<td><%=WebInterface.formatName((String)vUserInfo.elementAt(1), (String)vUserInfo.elementAt(2), (String)vUserInfo.elementAt(3), 4)%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department/Office:</td>
			<%
				if((String)vUserInfo.elementAt(13)== null || (String)vUserInfo.elementAt(14)== null)
					strTemp = " ";			
				else
					strTemp = " - ";
			%>
			<td>
				<%=WI.getStrValue((String)vUserInfo.elementAt(13),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vUserInfo.elementAt(14),"")%></td>
		</tr>
		<tr>
			<td colspan="3" height="15"><hr size="1"></td>
		</tr>
  	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
		    <td>ID Number: </td>
		    <td colspan="3">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(15);
					else
						strTemp = WI.fillTextValue("dep_id_number");
				%>
				<input name="dep_id_number" type="text" size="16" value="<%=strTemp%>" class="textbox" maxlength="16"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	    </tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">First Name: </td>
			<td width="40%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(12);
					else
						strTemp = WI.fillTextValue("fname");
				%>
				<input name="fname" type="text" size="32" value="<%=strTemp%>" class="textbox" maxlength="32"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td width="15%">Date of Birth : </td>
			<td width="25%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(2);
					else
						strTemp = WI.fillTextValue("dob");
				%>
				<input name="dob" type="text" class="textbox" id="date" size="12" maxlength="12" readonly="true"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"> 
        		<a href="javascript:show_calendar('form_.dob');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Middle Name: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(13);
					else
						strTemp = WI.fillTextValue("mname");
				%>
				<input name="mname" type="text" size="32" value="<%=strTemp%>" class="textbox" maxlength="32"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>Gender:</td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(3);
					else
						strTemp = WI.getStrValue(WI.fillTextValue("gender"), "1");
				%>
				<select name="gender">
				<%if(strTemp.equals("1") || strTemp.length() == 0){%>
					<option value="1" selected>Male</option>
				<%}else{%>
					<option value="1">Male</option>
					
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>Female</option>
				<%}else{%>
					<option value="2">Female</option>
				<%}%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Last Name: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(14);
					else
						strTemp = WI.fillTextValue("lname");
				%>
				<input name="lname" type="text" size="32" value="<%=strTemp%>" class="textbox" maxlength="32"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
			<td>Civil Status: </td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(4);
					else
						strTemp = WI.getStrValue(WI.fillTextValue("civil_status"), "1");
				%>
				<select name="civil_status">
				<%if(strTemp.equals("1") || strTemp.length() == 0){%>
					<option value="1" selected>Single</option>
				<%}else{%>
					<option value="1">Single</option>
					
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>Married</option>
				<%}else{%>
					<option value="2">Married</option>
					
				<%}if(strTemp.equals("3")){%>
					<option value="3" selected>Widowed/Widower</option>
				<%}else{%>
					<option value="3">Widowed/Widower</option>
					
				<%}if(strTemp.equals("4")){%>
					<option value="4" selected>Separated</option>
				<%}else{%>
					<option value="4">Separated</option>
				<%}%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Contact Number: </td>
			<td colspan="3">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(5);
					else
						strTemp = WI.fillTextValue("contact_num");
				%>
				<input name="contact_num" type="text" size="32" value="<%=strTemp%>" class="textbox" maxlength="32" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Address: </td>
			<td colspan="3">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(6);
					else
						strTemp = WI.fillTextValue("address");
				%>
				<textarea name="address" cols="80" rows="2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				  style="font-size:12px" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Relationship: </td>
			<td colspan="3">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(9);
					else
						strTemp = WI.fillTextValue("relationship");
				%>
				<input name="relationship" type="text" size="32" value="<%=strTemp%>" class="textbox" maxlength="32"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Validity: </td>
			<td colspan="3">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(10);
						strErrMsg = WI.getStrValue((String)vEditInfo.elementAt(11));
					}
					else{
						strTemp = WI.fillTextValue("date_fr");
						strErrMsg = WI.fillTextValue("date_to");
					}
				%>
				<input name="date_fr" type="text" class="textbox" id="date" size="12" maxlength="12" readonly="true"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>"> 
        		<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
				-
				<input name="date_to" type="text" class="textbox" id="date" size="12" maxlength="12" readonly="true"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strErrMsg%>"> 
        		<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
		</tr>
		<tr>
			<td height="40" valign="middle" colspan="5" align="center">
			<%if(iAccessLevel > 1){
				if(strPrepareToEdit.equals("0")) {%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0"></a>
					<font size="1">Click to save dependent info.</font>
				<%}else {%>
					<a href="javascript:PageAction('2', '<%=(String)vEditInfo.elementAt(0)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<font size="1">Click to edit dependent info.</font>					
				<%}%>
				
				<a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0"></a>
				<font size="1">Click to refresh page.</font>
			<%}else{%>
				Not allowed to save employee dependent information.
			<%}%></td>
		</tr>
	</table>
<%}

if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    	<tr bgcolor="#FFFF9F"> 
      		<td height="25" colspan="7" align="center" class="thinborder">
				<font size="2"><strong>LIST OF DEPENDENTS</strong></font></td>
    	</tr>
		<tr>
			<td height="25" width="35%" align="center" class="thinborder"><strong>Name</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Relationship</strong></td>
			<td width="20%" align="center" class="thinborder"><strong>Date Covered</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Details</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Options</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 16){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+9)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+10)%> - 
				<%=WI.getStrValue((String)vRetResult.elementAt(i+11), "to date")%></td>
			<td align="center" class="thinborder">&nbsp;
				<a href="javascript:ViewDependentDetails('<%=(String)vRetResult.elementAt(i)%>', '<%=(String)vUserInfo.elementAt(0)%>')">
					<img src="../../../images/view.gif" border="0"></a></td>
			<td align="center" class="thinborder">&nbsp;
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');">
						<img src="../../../images/edit.gif" border="0"></a>
					<%if(iAccessLevel == 2){%>
						<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">
							<img src="../../../images/delete.gif" border="0"></a>
					<%}
				}else{%>
					Not allowed.
				<%}%></td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="10">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
  	<input type="hidden" name="searchEmployee">
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
