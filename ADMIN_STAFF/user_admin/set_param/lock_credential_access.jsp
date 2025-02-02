<%@ page language="java" import="utility.*, enrollment.SetParameter, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<title>Lock Credential Access</title></head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	var imgWnd;
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
	
	function ViewDetails(strInfoIndex){
		var pgLoc = "./view_lock_details.jsp?info_index="+strInfoIndex;	
		var win=window.open(pgLoc,"ViewDetails",'width=700,height=400,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function PageAction(strAction, strInfoIndex) {
		if(strAction == '0') {
			if(!confirm('Are you sure you want to unlock student credential?'))
				return;
				
			var vReason = prompt("Please enter unlock reason.", "");
			if(vReason.length == 0)
				return;
				
			document.form_.unblock_reason.value = vReason;
		}
		
		document.form_.page_action.value = strAction;
		if(strInfoIndex.length > 0)
			document.form_.info_index.value = strInfoIndex;
		document.form_.submit();
	}
	
	function RefreshPage() {
		location = "./lock_credential_access.jsp?jumpto="+document.form_.jumpto.value;
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Set Parameter","lock_credential_access.jsp");

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
															"System Administration","Set Parameters",request.getRemoteAddr(),
															"lock_credential_access.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}	
	//end of authenticaion code.
	
	int iSearchResult = 0;
	String[] astrSemester = {"Summer", "1st Sem", "2nd Sem", "3rd Sem"};
	String[] astrLockTarget = {"", "Grade Releasing", "Report Card", "TOR"};
	String[] astrLockView = {"Unlocked", "Lock All", "Lock Print Only"};
	Vector vRetResult = null;
	SetParameter sp = new SetParameter();
	
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(sp.operateOnLockCredential(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = sp.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Student credential successfully unlocked.";
			if(strTemp.equals("1"))
				strErrMsg = "Student credential successfully locked.";
		}
	}
	
	vRetResult = sp.operateOnLockCredential(dbOP, request, 4);
	if(vRetResult == null){
		if(strTemp.length() == 0)
			strErrMsg = sp.getErrMsg();
	}
	else
		iSearchResult = sp.getSearchCount();
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./lock_credential_access.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>::: LOCK CREDENTIAL ACCESS :::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
		  	<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">ID Number: </td>
	  	    <td width="80%">
				<input name="stud_id" type="text" size="16" value="<%=WI.fillTextValue("stud_id")%>" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('stud_id','stud_id_');">&nbsp;
				<label id="stud_id_" style="position:absolute; width: 300px"></label></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>SY/Term: </td>
	  	    <td>
				<input name="sy_from" type="text" size="4" maxlength="4" class="textbox"
					value="<%=WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"))%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
				-
				<input name="sy_to" type="text" size="4" maxlength="4" class="textbox"
					value="<%=WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"))%>" 
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
					onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					readonly="yes">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
				%>
				<select name="offering_sem">
				<%if(strTemp.equals("1")){%>
					<option value="1" selected>1st Sem</option>
				<%}else{%>
					<option value="1">1st Sem</option>
				
				<%}if(strTemp.equals("2")){%>
              		<option value="2" selected>2nd Sem</option>
              	<%}else{%>
              		<option value="2">2nd Sem</option>
					
				<%}if(strTemp.equals("3")){%>
              		<option value="3" selected>3rd Sem</option>
              	<%}else{%>
              		<option value="3">3rd Sem</option>
				
				<%}if(strTemp.equals("0")){%>
					<option value="0" selected>Summer</option>
				<%}else{%>
					<option value="0">Summer</option>
				<%}%>
				</select></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Lock Target: </td>
		  	<td>
				<%
					//1=GRADE RELEASING, 2 = REPORT CARD, 3 = TOR
					strTemp = WI.getStrValue(WI.fillTextValue("lock_target"), "1");
				%>
				<select name="lock_target">
				<%if(strTemp.equals("1")){%>
					<option value="1" selected>Grade Releasing</option>
				<%}else{%>
					<option value="1">Grade Releasing</option>
				
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>Report Card</option>
				<%}else{%>
					<option value="2">Report Card</option>
					
				<%}if(strTemp.equals("3")){%>
					<option value="3" selected>TOR</option>
				<%}else{%>
					<option value="3">TOR</option>
				<%}%>
			</select></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Lock View: </td>
		  	<td>
				<%
					//1 - Lock All, 2 - Lock Print Only
					strTemp = WI.getStrValue(WI.fillTextValue("lock_view"), "1");
				%>
				<select name="lock_view">
				<%if(strTemp.equals("1")){%>
					<option value="1" selected>Lock All</option>
				<%}else{%>
					<option value="1">Lock All</option>
				
				<%}if(strTemp.equals("2")){%>
					<option value="2" selected>Lock Print Only</option>
				<%}else{%>
					<option value="2">Lock Print Only</option>
				<%}%>
			</select></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Lock Reason:</td>
		  	<td>
				<textarea name="lock_reason" style="font-size:12px" cols="70" rows="2" class="textbox" 
					onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=WI.fillTextValue("lock_reason")%></textarea></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td><strong><u>VIEW OPTION</u></strong></td>
		    <td>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Show:</td>
		    <td>
				<%
					strErrMsg = WI.getStrValue(WI.fillTextValue("show_option"), "0");
					if(strErrMsg.equals("0"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="radio" name="show_option" value="0" <%=strTemp%>/>Show All
				<%
					if(strErrMsg.equals("1"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="radio" name="show_option" value="1" <%=strTemp%>/>Show Only Locked
				<%
					if(strErrMsg.equals("2"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="radio" name="show_option" value="2" <%=strTemp%>/>Show Only Unlocked
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>ID Number: </td>
		    <td>
				<input name="stud_id_view" type="text" size="16" value="<%=WI.fillTextValue("stud_id_view")%>" class="textbox"
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('stud_id_view','stud_id_view_');">&nbsp;
				<label id="stud_id_view_" style="position:absolute; width: 300px"></label></td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
		    <td height="25">
				<a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to reload results.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td>
				<%if(iAccessLevel > 1){%>
					<a href="javascript:PageAction('1', '');"><img src="../../../images/save.gif" border="0" /></a>
					<font size="1">Click to block student credential.</font>
					&nbsp;
					<a href="javascript:RefreshPage();"><img src="../../../images/refresh.gif" border="0" /></a>
					<font size="1">Click to refresh page.</font>
				<%}else{%>
					Not authorized to lock credential access.
		<%}%>		</tr>
	</table>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="100%" height="15">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="9" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LOCK CREDENTIAL ACCESS HISTORY :::</strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="6">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(sp.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="3"> &nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResult/sp.defSearchSize;		
				if(iSearchResult % sp.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+sp.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="ReloadPage();">
					<%
						strTemp = WI.fillTextValue("jumpto");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
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
				<%}}%></td>
		</tr>
		<tr>
			<td height="25" class="thinborder" align="center" width="16%"><strong>(ID Number)<br />Student Name</strong></td>
		    <td class="thinborder" align="center" width="10%"><strong>Lock Date</strong></td>
			<td class="thinborder" align="center" width="12%"><strong>Reason</strong></td>
			<td class="thinborder" align="center" width="11%"><strong><strong>SY/Term</strong></strong></td>
			<td class="thinborder" align="center" width="11%"><strong>Lock Target</strong></td>
			<td class="thinborder" align="center" width="11%"><strong>Lock View</strong></td>
		    <td class="thinborder" align="center" width="10%"><strong>Unlock Date</strong></td>
		    <td class="thinborder" align="center" width="12%"><strong>Reason</strong></td>
			<td class="thinborder" align="center" width="5%"><strong>View</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 24){%>
		<tr>
			<td height="25" class="thinborder">
				<%=(String)vRetResult.elementAt(i+2)%><br />
			(<%=WebInterface.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5), 4)%>)</td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+16)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+10)%></td>
			<td class="thinborder">
				<%=(String)vRetResult.elementAt(i+6)%>-<%=Integer.parseInt((String)vRetResult.elementAt(i+6))+ 1%>/
				<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+7))]%></td>
			<td class="thinborder"><%=astrLockTarget[Integer.parseInt((String)vRetResult.elementAt(i+8))]%></td>
			<td class="thinborder"><%=astrLockView[Integer.parseInt((String)vRetResult.elementAt(i+9))]%></td>
		    <td class="thinborder">
			<%
				strTemp = (String)vRetResult.elementAt(i+23);
				if(strTemp == null){%>
					<div align="center"><a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>');">
						<strong><font color="#FF0000">UNLOCK</font></strong></a></div>
				<%}else{%>
					<%=strTemp%>
			<%}%></td>
		    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+17), "&nbsp;")%></td>
			<td class="thinborder" align="center">
				<a href="javascript:ViewDetails('<%=(String)vRetResult.elementAt(i)%>')">
					<font color="#FF0000"><strong>VIEW</strong></font></a></td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action" />
	<input type="hidden" name="info_index"/>
	<input type="hidden" name="unblock_reason" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>