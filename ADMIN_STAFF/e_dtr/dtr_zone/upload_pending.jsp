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

	function DeleteRecords(){
		var vStatus = false;
		var vRecords = document.form_.upload_count.value;
		for(var i = 1; i < vRecords; ++i){
			if(vStatus == true)
				break;
			if(eval('document.form_.upload_'+i+'.checked') == true)
				vStatus = true;
		}
		
		if(!vStatus){
			alert("No record selected.");
			return;
		}
		
		if(!confirm("Are you sure you want to delete these records?"))		
			return;
		document.form_.delete_records.value = "1";
		document.form_.upload_records.value = "";
		this.GetPendingList();
	}
	
	function UploadRecords(){
		var vStatus = false;
		var vRecords = document.form_.upload_count.value;
		for(var i = 1; i < vRecords; ++i){
			if(vStatus == true)
				break;
			if(eval('document.form_.upload_'+i+'.checked') == true)
				vStatus = true;
		}
		
		if(!vStatus){
			alert("No record selected.");
			return;
		}
		
		if(!confirm("Are you sure you want to retry uploading these records?"))		
			return;
		document.form_.upload_records.value = "1";
		document.form_.delete_records.value = "";
		this.GetPendingList();
	}
	
	function GetPendingList(){
		document.form_.print_page.value = "";
		document.form_.get_pending_list.value = "1";
		document.form_.submit();
	}
	
	function checkAllRecords(){
		var vRecords = document.form_.upload_count.value;
		var bolIsSelAll = document.form_.selAllRecords.checked;
		for(var i = 1; i < vRecords; ++i)
			eval('document.form_.upload_'+i+'.checked='+bolIsSelAll);
	}
	
	function GoBack(){
		location = "./upload_main.jsp";
	}
	
</script>
<%
	DBOperation dbOP = null;	
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./upload_pending_print.jsp" />
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
			"Admin/staff-eDaily Time Record-DTR ZONING-Upload Pending","upload_pending.jsp");
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
	
	if(WI.fillTextValue("delete_records").length() > 0){
		if(dtrz.getPendingList(dbOP, request, 0) == null)
			strErrMsg = dtrz.getErrMsg();
		else
			strErrMsg = "Pending upload records succesfully removed.";
	}
	
	if(WI.fillTextValue("upload_records").length() > 0){
		if(dtrz.getPendingList(dbOP, request, 5) == null)
			strErrMsg = dtrz.getErrMsg();
		else
			strErrMsg = "Pending upload records succesfully uploaded.";
	}	
	
	if(WI.fillTextValue("get_pending_list").length() > 0){
		vRetResult = dtrz.getPendingList(dbOP, request, 4);
		if(vRetResult == null && WI.fillTextValue("delete_records").length() == 0)
			strErrMsg = dtrz.getErrMsg();
		else
			iSearchResult = dtrz.getSearchCount();
	}
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./upload_pending.jsp" method="post">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    	<tr bgcolor="#A49A6A">
      		<td height="25" colspan="4" align="center" bgcolor="#A49A6A"><font color="#FFFFFF">
				  <strong>:::: UPLOAD PENDING LIST ::::</strong></font></td>
    	</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		    <td align="right"><a href="javascript:GoBack();"><img src="../../../images/go_back.gif" border="0" /></a>&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>eDTR Location: </td>
			<td colspan="2">
				<select name="loc_index" onchange="CopyName();">
          			<option value="">ALL</option>
          			<%=dbOP.loadCombo("loc_index","loc_name", " from edtr_location where is_valid = 1 and db_property is not null", WI.fillTextValue("loc_index"),false)%> 
        		</select>
			</td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		    <td colspan="2"><a href="javascript:GetPendingList();"><img src="../../../images/form_proceed.gif" border="0"/></a>
				<font size="1">Click to view upload pending list.</font></td>
		</tr>
		<tr>
			<td height="15" width="3%">&nbsp;</td>
		    <td width="17%">&nbsp;</td>
		    <td width="70%">&nbsp;</td>
		    <td width="10%">&nbsp;</td>
		</tr>
  	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" align="right">
				<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
				<font size="1">Click to print search results.</font>
				&nbsp;
				<a href="javascript:DeleteRecords();"><img src="../../../images/delete.gif" border="0" /></a>
				<font size="1">Click to delete selected records.</font>
				&nbsp;
				<a href="javascript:UploadRecords();"><img src="../../../images/execute_query.gif" border="0" /></a>
				<font size="1">Click to upload selected records.</font></td>
		</tr>
	</table>

	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0" class="thinborder">
		<tr> 
		  	<td height="20" colspan="7" align="center" bgcolor="#B9B292" class="thinborder">
			    <strong>::: SEARCH RESULTS ::: </strong></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOM" colspan="5">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=dtrz.getDisplayRange()%></strong>)</strong></td>
			<td height="25" colspan="2" align="right" class="thinborderBOTTOM"> &nbsp;
			<%
				int iPageCount = 1;
				iPageCount = iSearchResult/dtrz.defSearchSize;		
				if(iSearchResult % dtrz.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+dtrz.getDisplayRange()+")";
				
				if(iPageCount > 1){%>
					Jump To page:
				<select name="jumpto" onChange="GetPendingList();">
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
				</select>
				<%}%></td>
		</tr>
		<tr>
			<td height="25" width="5%" align="center" class="thinborder"><strong>Count</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>ID Number</strong></td>
			<td width="17%" align="center" class="thinborder"><strong>Time In </strong></td>
			<td width="18%" align="center" class="thinborder"><strong>Time Out</strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Location</strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Failed Reason</strong></td>
			<td width="5%" align="center" class="thinborder"><strong>Select<br />All<br /></strong>
				<input type="checkbox" name="selAllRecords" value="0" onClick="checkAllRecords();"></td>
		</tr>
		<%	int iCount = 1;
			for(i = 0; i < vRetResult.size(); i+=7, iCount++){%>
		<tr>
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<%
				if(vRetResult.elementAt(i+2) == null)
					strTemp = "&nbsp;";
				else
					strTemp = WI.getTodaysDateTime(Long.parseLong((String)vRetResult.elementAt(i+2)));
			%>
		    <td class="thinborder"><%=strTemp%></td>
			<%
				if(vRetResult.elementAt(i+3) == null)
					strTemp = "&nbsp;";
				else
					strTemp = WI.getTodaysDateTime(Long.parseLong((String)vRetResult.elementAt(i+3)));
			%>
			<td class="thinborder"><%=strTemp%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%><br /><%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+6)%></td>
			<td align="center" class="thinborder">
				<input type="checkbox" name="upload_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" tabindex="-1"></td>
		</tr>
		<%}%>
		<input type="hidden" name="upload_count" value="<%=iCount%>" />
	</table>
	
	<table width="100%" bgcolor="#FFFFFF" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" align="center">
				<a href="javascript:DeleteRecords();"><img src="../../../images/delete.gif" border="0" /></a>
				<font size="1">Click to delete selected records.</font></td>
		</tr>
	</table>
<%}%>
	
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr>
			<td height="24"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="get_pending_list" />
	<input type="hidden" name="delete_records" />
	<input type="hidden" name="upload_records" />
	<input type="hidden" name="print_page" />
	<input type="hidden" name="loc_name" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>