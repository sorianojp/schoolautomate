<%@ page language="java" import="utility.*, java.util.Vector, eDTR.DTRZoning" %>
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
<title>Upload Pending List</title>
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

	function CopyName(){
		document.form_.loc_name.value = document.form_.loc_index[document.form_.loc_index.selectedIndex].text;
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
	function GetPendingList(){
		document.form_.print_page.value = "";
		document.form_.get_pending_list.value = "1";
		document.form_.submit();
	}
	
	function checkAllEmployees(){
		var vRecords = document.form_.max_count.value;
		var bolIsSelAll = document.form_.selAllEmployees.checked;
		for(var i = 1; i < vRecords; ++i)
			eval('document.form_.res_user_'+i+'.checked='+bolIsSelAll);
	}
	
	function GoBack(){
		location = "./upload_main.jsp";
	}
	
	function SetUnsynchronized(){
		document.form_.set_unsynchronized.value = "1";
		this.GetPendingList();
	}
	
</script>
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./force_unsynchronize_print.jsp" />
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
			"Admin/staff-eDaily Time Record-DTR ZONING-Upload Pending","force_unsynchronize.jsp");
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
	
	int iSearchResult = 0;
	Vector vRetResult = null;
	DTRZoning dtrz = new DTRZoning();
	
	if(WI.fillTextValue("set_unsynchronized").length() > 0){
		if(dtrz.operateOnForceSynchronization(dbOP, request, 1) == null)
			strErrMsg = dtrz.getErrMsg();
		else
			strErrMsg = "Operation successful.";
	}
	
	if(WI.fillTextValue("get_pending_list").length() > 0){
		vRetResult = dtrz.operateOnForceSynchronization(dbOP, request, 4);
		if(vRetResult == null){
			if(WI.fillTextValue("set_unsynchronized").length() == 0)
				strErrMsg = dtrz.getErrMsg();
		}
		else
			iSearchResult = dtrz.getSearchCount();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./force_unsynchronize.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    	<tr bgcolor="#A49A6A">
      		<td height="25" colspan="4" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
				  <strong>:::: FORCE SYNCHRONIZATION ::::</strong></font></td>
    	</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">eDTR Location: </td>
			<td width="80%">
				<select name="loc_index" onChange="GetPendingList();">
          			<option value="">Select eDTR Location</option>
          			<%=dbOP.loadCombo("loc_index","loc_name", " from edtr_location where is_valid = 1 order by loc_name", WI.fillTextValue("loc_index"),false)%> 
        		</select>
			</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<%
				strTemp = WI.fillTextValue("view_all");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>
			<td><input type="checkbox" name="view_all" value="1" <%=strTemp%> />View All</td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td><a href="javascript:GetPendingList();"><img src="../../../images/form_proceed.gif" border="0"/></a>
				<font size="1">Click to get list of synchronized users.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
  	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="25" align="right">
				<input type="button" name="unsynchButton" value=" Set Status to Unsynchronized " style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
					onclick="javascript:SetUnsynchronized();" /></td>
		</tr>
	</table>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">	
		<tr> 
		  	<td height="20" colspan="2" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: SEARCH RESULTS::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" width="80%">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(dtrz.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" width="20%"> &nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResult/dtrz.defSearchSize;		
				if(iSearchResult % dtrz.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+dtrz.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="GetPendingList();">
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
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" width="20%" align="center" class="thinborder"><strong>ID Number</strong></td>
			<td width="70%" align="center" class="thinborder"><strong>Name</strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Select All<br /></strong>
				<input type="checkbox" name="selAllEmployees" value="0" onClick="checkAllEmployees();"></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 5, iCount++){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), 4)%></td>
			<td align="center" class="thinborder">
				<input type="checkbox" name="res_user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1"></td>
		</tr>
	<%}%>
		<input type="hidden" name="max_count" value="<%=iCount%>" />
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center">
				<input type="button" name="unsynchButton" value=" Set Status to Unsynchronized " style="font-size:11px; height:22px;border: 1px solid #FF0000;" 
					onclick="javascript:SetUnsynchronized();" /></td>
		</tr>
	</table>
<%}%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr>
			<td height="24"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="set_unsynchronized" />
	<input type="hidden" name="loc_name" />
	<input type="hidden" name="print_page" />
	<input type="hidden" name="get_pending_list" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>