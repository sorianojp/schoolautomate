<%@ page language="java" import="utility.*, java.util.Vector, eDTR.DTRZoning" %>
<%
	WebInterface WI = new WebInterface(request);
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
		
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Manage Restricted User List</title>
</head>

<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	
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
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}

	function ReloadPage(){
		document.form_.submit();
	}
	function CancelOperation(){
		location = "./manage_restricted_user_list.jsp?loc_index="+document.form_.loc_index[document.form_.loc_index.selectedIndex].value;
	}
	
	function PageAction(strAction, strInfoIndex) {
		document.form_.page_action.value = strAction;
		document.form_.submit();
	}
	
	function checkAllEmployees(){
		var maxDisp = document.form_.max_user_list.value;
		var bolIsSelAll = document.form_.selAllEmployees.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.user_i'+i+'.checked='+bolIsSelAll);
	}
	
	function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
		this.processRequest(strURL);
	}
	function GoBack() {
		location = "./manage_restricted_user_list.jsp";
	}
</script>
<%		
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./manage_restricted_user_list_print.jsp" />
	<% 
		return;}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("EDAILY TIME RECORD-DTR OPERATIONS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("EDAILY TIME RECORD"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-eDaily Time Record-DTR ZONING-Manage Restricted User List","manage_restricted_user_list_batch.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	int i = 0;
	Vector vRetResult = null;	
	DTRZoning dtrz = new DTRZoning();
	
	String strLocIndex = WI.fillTextValue("loc_index");
	if(WI.fillTextValue("loc_index").length() > 0 && WI.fillTextValue("restriction_fr").length() > 0){
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0){
			if(dtrz.operateOnDTRRestrictedUserBatch(dbOP, request, Integer.parseInt(strTemp)) == null)
				strErrMsg = dtrz.getErrMsg();
			else{
				if(strTemp.equals("0"))
					strErrMsg = "Employee successfully removed from list.";
				else
					strErrMsg = "Employee successfully recorded to list.";
			}
		}
		
	
		vRetResult = dtrz.operateOnDTRRestrictedUserBatch(dbOP, request, 4);
		if(vRetResult == null && WI.fillTextValue("page_action").length() == 0)
			strErrMsg = dtrz.getErrMsg();
	}
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./manage_restricted_user_list_batch.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    	<tr bgcolor="#A49A6A">
      		<td height="25" colspan="3" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
				  <strong>:::: MANAGE RESTRICTED USER LIST - BATCH::::</strong></font></td>
    	</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2">
			<a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0"></a>
			&nbsp;&nbsp;&nbsp;&nbsp;
			<strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">eDTR Location: </td>
			<td width="80%">
				<select name="loc_index" onChange="ReloadPage();">
          			<option value="">Select eDTR Location</option>
          			<%=dbOP.loadCombo("loc_index","loc_name", " from edtr_location where is_valid = 1", WI.fillTextValue("loc_index"),false)%> 
        		</select></td>
		</tr>
  	</table>

<%if(WI.fillTextValue("loc_index").length() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Restriction From: </td>
			<td colspan="2">
				<input name="restriction_fr" type="text" size="10" maxlength="10" 
					readonly="yes" class="textbox" value="<%=WI.fillTextValue("restriction_fr")%>" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.restriction_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="24">&nbsp;</td>
			<td>Status</td>
			<td colspan="2">
				<select name="pt_ft" onChange="ReloadPage();">
				<option value="">All</option>
				<%if (WI.fillTextValue("pt_ft").equals("0")){%>
					<option value="0" selected>Part-time</option>
				<%}else{%>
					<option value="0">Part-time</option>
					
				<%}if (WI.fillTextValue("pt_ft").equals("1")){%>
					<option value="1" selected>Full-time</option>
				<%}else{%>
					<option value="1">Full-time</option>
				<%}%>
				</select></td>
		</tr>
<%if(bolIsSchool){%>
		<tr>
			<td height="24">&nbsp;</td>
			<td>Emp Category</td>
			<td colspan="2">
				<select name="employee_category" onChange="ReloadPage();">          
				<option value="">All</option>
				<%if (WI.fillTextValue("employee_category").equals("0")){%>
					<option value="0" selected>Non-Teaching</option>
				<%}else{%>
					<option value="0">Non-Teaching</option>				
				<%}if (WI.fillTextValue("employee_category").equals("1")){%>
					<option value="1" selected>Teaching</option>
				<%}else{%>
					<option value="1">Teaching</option>
				<%}%>
				</select></td>
		</tr>
<%}
String strCollegeIndex = WI.fillTextValue("c_index");
%>
		<tr>
			<td height="25">&nbsp;</td>
			<td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
			<td colspan="2">
				<select name="c_index" onChange="loadDept();">
          			<option value="">ALL</option>
          			<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
        		</select></td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department: </td>
			<td colspan="2">
				<label id="load_dept">
				<select name="d_index">
         			<option value="">ALL</option>
          		<%if ((strCollegeIndex.length() == 0) || strCollegeIndex.equals("0")){%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          		<%}else{%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
         		 <%}%>
  	   			</select>
				</label></td>
        </tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Employee ID: </td>
		    <td width="17%">
				<input name="id_number" type="text" size="16" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('id_number','id_number_');"></td>
		    <td width="63%" valign="top"><label id="id_number_" style="position:absolute; width:351px"></label></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td colspan="2">
				<input type="image" src="../../../images/form_proceed.gif" border="0" onclick="document.form_.page_action.value=''" />
				<font size="1">Click here to reload search results. </font></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<%}%>
	</table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
		<tr> 
		  	<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LOCATION USER LIST ::: </strong></div></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="17%" align="center" class="thinborder"><strong>ID Number</strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Employee Name</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Division/Dept</strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Select<br />All<br /></strong>
				<input type="checkbox" name="selAllEmployees" value="0" onClick="checkAllEmployees();"></td>
		</tr>
		<%	int iCount = 1;
			for(i = 0; i < vRetResult.size(); i += 4, iCount++){%>
				<tr>
					<td height="25" align="center" class="thinborder"><%=iCount%></td>
					<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
					<td class="thinborder"><%=vRetResult.elementAt(i+2)%></td>
					<td align="center" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+3), "&nbsp;")%></td>
					<td align="center" class="thinborder"><input type="checkbox" name="user_i<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1"></td>
				</tr>
		<%}%>
		<input type="hidden" name="max_user_list" value="<%=iCount%>" />
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" align="center">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center">
				<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0" /></a>
				<font size="1">Click to save employees for this eDTR location</font></td>
		</tr>
	</table>
<%}//if loc_index > 0%>
	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr>
			<td height="24"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>