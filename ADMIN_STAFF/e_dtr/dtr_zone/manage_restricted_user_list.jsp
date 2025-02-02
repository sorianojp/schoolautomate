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

	function CopyValues(){
		document.form_.loc_name.value = document.form_.loc_index[document.form_.loc_index.selectedIndex].text;
		if(document.form_.show_view_options && document.form_.show_view_options.checked){
			document.form_.emp_status.value = document.form_.pt_ft[document.form_.pt_ft.selectedIndex].text;
			document.form_.c_name.value = document.form_.c_index[document.form_.c_index.selecteIndex].text;
			document.form_.d_name.value = document.form_.d_index[document.form_.d_index.selectedIndex].text;
			document.form_.emp_id_number.value = document.form_.id_number.value;
			
			if(document.form_.employee_category)
				document.form_.emp_catg.value = document.form_.employee_category[document.form_.employee_category.selectedIndex].text;
		}
	}
	
	function ReloadPage(){
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	function CancelOperation(){
		location = "./manage_restricted_user_list.jsp?loc_index="+document.form_.loc_index[document.form_.loc_index.selectedIndex].value;
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to delete employees from location?'))
				return;
		}
		document.form_.print_page.value = "";
		document.form_.page_action.value = strAction;
		document.form_.submit();
	}
	
	function PrintPg(){
		CopyValues();
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
	function checkAllEmployees(){
		var maxDisp = document.form_.max_user_list.value;
		var bolIsSelAll = document.form_.selAllEmployees.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.user_list'+i+'.checked='+bolIsSelAll);
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
	function SynchronizeAgain(strEmpRef) {
		return SynchronizeUser(strEmpRef, '1');
	}
	function SynchronizeOnce(strEmpRef) {
		return SynchronizeUser(strEmpRef, '');
	}
	function SynchronizeALL() {
		var strOverWrite = '';
		if(document.form_.synchronize_all[1].checked)
			strOverWrite = "1";
		else if(!document.form_.synchronize_all[0].checked) {
			alert("Please select atleast one option to Synchronize all user.");
			return;
		}
		return SynchronizeUser('',strOverWrite);
	}
	function SynchronizeUser(strEmpRef, strOverWrite) {
		document.form_.sync_called.value = '1';
		document.form_.emp_ref.value = strEmpRef;
		document.form_.over_write.value = strOverWrite;
		
		document.form_.submit();
	}
	
	function AssignMultiple() {
		location = "./manage_restricted_user_list_batch.jsp";
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
			"Admin/staff-eDaily Time Record-DTR ZONING-Manage Restricted User List","manage_restricted_user_list.jsp");
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
	int iSearchResult = 0;
	Vector vRetResult = null;	
	DTRZoning dtrz = new DTRZoning();
	
	String strLocIndex = WI.fillTextValue("loc_index");
	Vector vLocInfo    = null; boolean bolIsStandAlone = false;
	if(strLocIndex.length() > 0) {
		request.setAttribute("loc_index", strLocIndex);
		vLocInfo = dtrz.createDTRZone(dbOP, request, 3);
		if(vLocInfo != null && vLocInfo.elementAt(3) != null)
			bolIsStandAlone = true;
	}
	
	
	if(WI.fillTextValue("loc_index").length() > 0){
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0){
			if(dtrz.operateOnDTRRestrictedUser(dbOP, request, Integer.parseInt(strTemp)) == null)
				strErrMsg = dtrz.getErrMsg();
			else{
				if(strTemp.equals("0"))
					strErrMsg = "Employee successfully removed from list.";
				else
					strErrMsg = "Employee successfully recorded to list.";
			}
		}
		//may be called to synchronized.. 
		if(WI.fillTextValue("sync_called").length() > 0) {
			if(dtrz.synchronizeUser(dbOP, request))
				strErrMsg = "Employee data synchronized.";
			else	
				strErrMsg = dtrz.getErrMsg();
		}
		
		
	
		vRetResult = dtrz.operateOnDTRRestrictedUser(dbOP, request, 4);
		if(vRetResult == null && WI.fillTextValue("page_action").length() == 0)
			strErrMsg = dtrz.getErrMsg();
		else
			iSearchResult = dtrz.getSearchCount();
	}
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./manage_restricted_user_list.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    	<tr bgcolor="#A49A6A">
      		<td height="25" colspan="3" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
				  <strong>:::: MANAGE RESTRICTED USER LIST ::::</strong></font></td>
    	</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">eDTR Location: </td>
			<td width="80%">
				<select name="loc_index" onChange="ReloadPage();">
          			<option value="">Select eDTR Location</option>
          			<%=dbOP.loadCombo("loc_index","loc_name", " from edtr_location where is_valid = 1", WI.fillTextValue("loc_index"),false)%> 
        		</select>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			
			<a href="javascript:AssignMultiple();">Click here to assign multiple Users at once</a>				
				</td>
		</tr>
  	</table>

<%if(WI.fillTextValue("loc_index").length() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Restriction From: </td>
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
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Emp ID: </td>
			<td width="17%">
				<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					class="textbox" onKeyUp="AjaxMapName('emp_id','emp_id_');"></td>
			<td width="63%" valign="top"><label id="emp_id_" style="position:absolute; width:350px"></label></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td colspan="2">
				<%if(iAccessLevel > 1){%>
				<img src="../../../images/form_proceed.gif" border="0" onclick="document.form_.print_page.value='';document.form_.page_action.value='';document.form_.submit();" /><a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0" /></a>
					<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0" /></a>
				<%}else{%>
					Not authroized to save eDTR user information.
				<%}%></td>
	    </tr>
		
		<tr>
			<td height="15">&nbsp;</td>
			<td colspan="3">
				<%
					if(WI.fillTextValue("show_view_options").length() > 0)
						strTemp = " checked";
					else
						strTemp = "";
				%>
				<input type="checkbox" name="show_view_options" value="1" <%=strTemp%> 
					onclick="javascript:ReloadPage();">Show View Options</td>
		</tr>
		<%if(WI.fillTextValue("show_view_options").length() > 0){
			String strCollegeIndex = WI.fillTextValue("c_index");%>
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
		<%}%>
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
		    <td>
				<input name="id_number" type="text" size="16" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('id_number','id_number_');"></td>
		    <td valign="top"><label id="id_number_" style="position:absolute; width:351px"></label></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td colspan="2">
				<img src="../../../images/form_proceed.gif" border="0" onclick="document.form_.print_page.value='';document.form_.page_action.value='';document.form_.submit();" />
				<font size="1">Click here to reload search results. </font></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<%}%>
	</table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
				<font size="1">Click to print search results.</font></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
		<tr> 
		  	<td height="20" colspan="6" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LOCATION USER LIST ::: </strong></div></td>
		</tr>
<%
if(strSchCode.startsWith("VMUF")){%>
		<tr> 
		  <td height="25" colspan="3" class="thinborderBOTTOM">&nbsp;&nbsp;&nbsp;&nbsp;
		  <!-- this is to synchronize all users -->
<%
strErrMsg = WI.fillTextValue("synchronize_all");
if(strErrMsg.equals("0"))
	strTemp= " checked";
else	
	strTemp="";
%>
		  <input type="radio" name="synchronize_all" value="0" <%=strTemp%>> Synchronize all users not yet synchronized
<%
if(strErrMsg.equals("0"))
	strTemp= " checked";
else	
	strTemp="";
%>
		  <input type="radio" name="synchronize_all" value="1" <%=strTemp%>> Synchronize all users with overwrite if data exists.
		  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		  <input type="button" name="12" value=" Synchronize " style="font-size:11px; height:22px;border: 1px solid #FF0000;" onclick="javascript:SynchronizeALL();" />
		</td>
	  </tr>
<%}%>
		<tr> 
			<td class="thinborderBOTTOM">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=dtrz.getDisplayRange()%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="-1"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/dtrz.defSearchSize;		
				if(iSearchResult % dtrz.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+dtrz.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="SearchCustomer();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i =1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}%></td>
		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="17%" align="center" class="thinborder"><strong>ID Number</strong></td>
			<td width="30%" align="center" class="thinborder"><strong>Employee Name</strong></td>
			<td width="16%" align="center" class="thinborder"><strong>Restriction From</strong></td>
			<%if(bolIsStandAlone){%>
				<td width="20%" align="center" class="thinborder"><strong>Synch Status</strong></td>
			<%}%>
			<td width="12%" align="center" class="thinborder"><strong>Select<br />All<br /></strong>
				<input type="checkbox" name="selAllEmployees" value="0" onClick="checkAllEmployees();"></td>
		</tr>
		<%	int iCount = 1;
			for(i = 0; i < vRetResult.size(); i += 8, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">
				<%=WebInterface.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5), 4)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
			<%if(bolIsStandAlone){
				if(((String)vRetResult.elementAt(i+7)).equals("1")) {
					strTemp = "Sycnronized";
					strErrMsg = "<a href='javascript:SynchronizeAgain("+(String)vRetResult.elementAt(i)+")'>Re-Synchronize</a>";
				}
				else {
					strTemp = "Not synchronized";
					strErrMsg = "<a href='javascript:SynchronizeOnce("+(String)vRetResult.elementAt(i + 1)+")'>Synchronize</a>";
				}
			  %>
				<td class="thinborder"><%=strTemp%>
				<br><%=strErrMsg%>
				</td>
			<%}%>
			<td align="center" class="thinborder">
				<input type="checkbox" name="user_list<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1"></td>
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
				<a href="javascript:PageAction('0', '');"><img src="../../../images/delete.gif" border="0" /></a>
				<font size="1">Click to delete employees from eDTR location list.</font></td>
		</tr>
	</table>
	<%}
}%>
	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr>
			<td height="24"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action" />
	<input type="hidden" name="print_page" />
	<input type="hidden" name="loc_name" />
	<input type="hidden" name="emp_status" />
	<input type="hidden" name="emp_catg" />
	<input type="hidden" name="c_name" />
	<input type="hidden" name="d_name" />
	<input type="hidden" name="emp_id_number" />
	
	<input type="hidden" name="sync_called" />
	<input type="hidden" name="emp_ref" />
	<input type="hidden" name="over_write" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>