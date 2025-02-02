<%@ page language="java" import="utility.*,java.util.Vector,hr.HRClearance" %>
<%
	WebInterface WI = new WebInterface(request);
	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Clear Clearances</title>
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
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">

function ReloadPage() {
	document.form_.searchEmployee.value="";
	document.form_.submit();
}

function SearchEmployee() {	
	if(document.form_.emp_id.value == '') {
		alert("Please enter employee ID.");
		return;
	} 
	document.form_.searchEmployee.value="1";
	document.form_.submit();
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
	var bolIsSelAll = document.form_.selAllSave.checked;
	for(var i =1; i< maxDisp; ++i)
		eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
}

function DeleteClearances() {
	var vProceed = confirm('Remove selected clearances?');
	if(vProceed){
		document.form_.page_action.value = "0";
		document.form_.searchEmployee.value = "1";
		document.form_.submit();
	}	
}

function ClearClearances() {
	document.form_.page_action.value = "1";
	document.form_.searchEmployee.value = "1";
	document.form_.submit();
}

function CancelOperation() {
	document.form_.page_action.value = "";
	document.form_.submit()
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
	//document.dtr_op.submit();
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}

function UpdateNameFormat(strName) {
	//do nothing.
}

</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT-CLEARANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
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
			"Admin/staff-HR Management-Clearance-Search Clearance","hr_clearance_search.jsp");
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

	Vector vRetResult = null;
	Vector vUserInfo = null;
	HRClearance hrc = new HRClearance();
	int iSearchResult = 0;
	int i = 0;
	
	enrollment.Authentication auth = new enrollment.Authentication();
    request.setAttribute("emp_id", WI.fillTextValue("emp_id"));
    if(WI.fillTextValue("emp_id").length() > 0)
		vUserInfo = auth.operateOnBasicInfo(dbOP, request, "0");
	if(vUserInfo == null)
		strErrMsg = auth.getErrMsg();
	else{
		strTemp = WI.fillTextValue("page_action");
		if(strTemp.length() > 0){
			if(hrc.OperateOnClearClearance(dbOP, request, Integer.parseInt(strTemp), (String)vUserInfo.elementAt(0)) == null){
				strErrMsg = hrc.getErrMsg();
			} else {
				if(strTemp.equals("1"))
					strErrMsg = "Clearance successfully cleared.";
				if(strTemp.equals("0"))
					strErrMsg = "Clearance successfully removed.";
			}
		}
		
		if(WI.fillTextValue("searchEmployee").length() > 0){
			vRetResult = hrc.OperateOnClearClearance(dbOP,request, 4, (String)vUserInfo.elementAt(0));
			if(vRetResult == null && strTemp.length() == 0)
				strErrMsg = hrc.getErrMsg();
			else
				iSearchResult = hrc.getSearchCount();
		}	
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic" onLoad="document.form_.emp_id.focus();">
<form action="hr_clearance_clear.jsp" method="post" name="form_">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="5" align="center" class="footerDynamic">
				<font color="#FFFFFF" ><strong>:::: CLEARANCE MANAGEMENT PAGE ::::</strong></font>
			</td>
		</tr>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="4"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr> 
			<td width="4%" height="25">&nbsp;</td>
			<td width="16%">Employee ID </td>
			<td width="25%">
				<input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyUp="AjaxMapName('emp_id','emp_id_');" class="textbox">
			<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></td>
			<td colspan="2"><label id="emp_id_"></label></td>
		</tr>
<%if(vRetResult!=null && vRetResult.size() > 0 && (WI.fillTextValue("clearance_cleared").equals("0") || WI.fillTextValue("clearance_cleared").length() == 0)){%>
		<tr>
			<td width="4%" height="25">&nbsp;</td>
			<td width="16%">Remark*</td>
			<td colspan="3">
				<textarea name="remark" cols="65" rows="6" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				  style="font-size:12px" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("remark")%></textarea></td>
		</tr>
		<tr>
			<td width="4%" height="25">&nbsp;</td>
			<td width="16%">Date Cleared*</td>
			<%
				strTemp = WI.fillTextValue("date_cleared"); 
				if(strTemp.length() == 0)
					strTemp = WI.getTodaysDate(1);
			%>
			<td colspan="3">
				<input name="date_cleared" type="text" size="16" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">&nbsp; 
				<a href="javascript:show_calendar('form_.date_cleared');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td width="4%" height="25">&nbsp;</td>
			<td width="16%">Cleared By*</td>
			<td>
			<input name="cleared_by" type="text" size="16" value="<%=WI.fillTextValue("cleared_by")%>" class="textbox"
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
				onKeyUp="AjaxMapName('cleared_by','cleared_by_');">
			<a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a>			</td>
		    <td colspan="2">&nbsp;<label id="cleared_by_"></label></td>
		</tr>
<%}%>
		<tr> 
			<td height="10" colspan="6"><hr size="1" color="#000000"></td>
		</tr>
		<tr>
			<td height="10" colspan="6">OPTION:</td>
		</tr>
		<tr> 
			<td height="10">&nbsp;</td>
		  <td height="10" colspan="5">
	<%
		strTemp = WI.getStrValue(WI.fillTextValue("clearance_cleared"),"1");
		if(strTemp.compareTo("1") == 0) {
			strTemp = " checked";
			strErrMsg = "";
		}
		else {
			strTemp = "";	
			strErrMsg = " checked";
		}
	%>
    <input type="radio" name="clearance_cleared" value="1"<%=strTemp%> onClick="ReloadPage();"> View Cleared Clearances
	<input type="radio" name="clearance_cleared" value="0"<%=strErrMsg%> onClick="ReloadPage();"> View Uncleared Clearances </td>
	</tr>
	<tr>
		<td height="10">&nbsp;</td>
		<td colspan="5">
		<%
			if(WI.fillTextValue("view_all").length() > 0)
				strTemp = " checked";				
			else
				strTemp = "";
		%>
		<input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();"> 
		View ALL</td>
	</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="3%" height="10">&nbsp;</td>
			<td width="11%" height="10">&nbsp;</td>
			<td height="10">&nbsp;</td>
		</tr>
		<tr> 
			<td height="10">&nbsp;</td>
			<td height="10">&nbsp;</td>
			<td height="10">
			<input type="button" name="proceed_btn" value=" Proceed " onClick="javascript:SearchEmployee();"
				style="font-size:11px; height:28px;border:1px solid #FF0000;">
			<font size="1">click to display employee list to print.</font></td>
		</tr>
  	</table>    
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr>
		<tr>
		<%
			int iPageCount = 1;
			if(vRetResult!=null && vRetResult.size() > 0){
				if(WI.fillTextValue("view_all").length() == 0){
					iPageCount = iSearchResult/hrc.defSearchSize;		
					if(iSearchResult % hrc.defSearchSize > 0) 
						++iPageCount;
					strTemp = " - Showing("+hrc.getDisplayRange()+")";
				}
				else
					strTemp = " - Showing All";
		%>
			<td><strong>TOTAL RESULT: <%=iSearchResult%><%=strTemp%></strong></td>
		<%}
			if(iPageCount > 1){
		%>
		    <td><div align="right"><font size="2">Jump To page:
				<select name="jumpto" onChange="SearchEmployee();">
				<%
					strTemp = request.getParameter("jumpto");
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
				</select>
				</font></div></td>
		</tr>
		<%}%>
	</table>
	
<%if(vUserInfo!=null && vRetResult!= null && vRetResult.size() > 0 && vUserInfo.size() > 0){%>
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="10" colspan="6"><hr size="1" color="#000000"></td>
		</tr>
		<tr>
        	<td height="25" colspan="2">Employee Information: </td>
	    	<td colspan="3">&nbsp;</td>
      	</tr>
		<tr> 
			<td width="5%" height="25">&nbsp;</td>
			<td width="18%">Employee ID:</td>
			<td width="77%" colspan="3"><%=WI.fillTextValue("emp_id")%></td>
	    </tr>
		<tr>
			<td width="5%" height="25">&nbsp;</td>
			<td width="18%">Name:</td>
		    <td colspan="3"><%=WebInterface.formatName((String)vUserInfo.elementAt(1), (String)vUserInfo.elementAt(2), (String)vUserInfo.elementAt(3), 4)%></td>
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
		  <td colspan="3">
		  <%=WI.getStrValue((String)vUserInfo.elementAt(13),"")%>
		  <%=strTemp%>
		  <%=WI.getStrValue((String)vUserInfo.elementAt(14),"")%> 
		  </td>
	  </tr>
	  <tr>
	  	<td colspan="3">&nbsp;</td>
	  </tr>
  	</table>
<%} if (vRetResult != null &&  vRetResult.size() > 0) {
	boolean boIsClearanceCleared = WI.fillTextValue("clearance_cleared").equals("1");
%>
  	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<%
				if(WI.fillTextValue("clearance_cleared").equals("0") || WI.fillTextValue("clearance_cleared").length() == 0)
					strTemp = "UNCLEARED";
				else
					strTemp = "CLEARED";
			%>
		  	<td height="20" colspan="7" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>LIST OF <%=strTemp%> CLEARANCES </strong></div></td>
		</tr>
    	<tr>
			<%
				if(WI.fillTextValue("clearance_cleared").equals("0") || WI.fillTextValue("clearance_cleared").length() == 0){
					strTemp = "POSTED BY";
					strErrMsg = "DATE POSTED";
				}
				else{
					strTemp = "CLEARED BY";
					strErrMsg = "DATE CLEARED";
				}
			%>
			<td width="5%" height="23" class="thinborder">&nbsp;</td>
			<td width="22%" align="center" class="thinborder"><strong><font size="1">CLEARANCE NAME</font></strong></td>
			<td width="21%" align="center" class="thinborder"><strong><font size="1">REMARK</font></strong></td>
			<td width="21%" align="center" class="thinborder"><strong><font size="1"><%=strTemp%></font></strong></td>
			<td width="21%" align="center" class="thinborder"><strong><font size="1"><%=strErrMsg%></font></strong></td>
			<td width="10%" align="center" class="thinborder">
			<font size="1"><strong>SELECT ALL<br></strong>
        	<input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked></font>			</td>
    	</tr>
    	<% 
			int iCount = 1;
	   		for (i = 0; i < vRetResult.size(); i+=9,iCount++){
		%>
    	<tr>
      		<td height="25" class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
				<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
				<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2), "&nbsp;")%></td>
				<td class="thinborder">
				<%=WebInterface.formatName((String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4), (String)vRetResult.elementAt(i+5), 7)%>
				</td>
      			<td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
				<input type="hidden" name="info_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
				<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+7)%>">
				<input type="hidden" name="cleared_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+8)%>">
     		<td align="center" class="thinborder">        
				<input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1"></td>
    	</tr>
    	<%} //end for loop%>
	</table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    	<tr>
      		<td height="25">&nbsp;</td>
   		</tr>
    	<tr>
      		<td height="25"><div align="center">
				<%if(!boIsClearanceCleared && iAccessLevel > 1){%>
					<a href="javascript:ClearClearances();"><img src="../../../images/clear.gif" border="0"></a> 
					<font size="1">Click to clear entries</font>
            	<%}if(boIsClearanceCleared && iAccessLevel == 2){%>
					<a href="javascript:DeleteClearances();"><img src="../../../images/delete.gif" border="0"></a> 
					<font size="1">Click to delete selected </font>
          		<%}%>
				<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0"></a> 
				<font size="1"> click to cancel or go previous</font></div></td>
		</tr>
		<input type="hidden" name="emp_count" value="<%=iCount%>">
	</table>
	<% } // end vRetResult != null && vRetResult.size() > 0 %>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>

	<input type="hidden" name="searchEmployee" > 
	<input type="hidden" name="page_action">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>