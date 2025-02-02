<%@ page language="java" import="utility.*, docTracking.deped.DocumentTracking, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css" />
<title>Search Transaction</title></head>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function viewTracking(strBarcodeID){
		if(document.form_.opner_info.value.length > 0) {			
			var opnerObj;
			eval('opnerObj=window.opener.document.'+document.form_.opner_info.value);
			opnerObj.value=strBarcodeID;
			window.opener.document.form_.submit();
			window.close();
			return;
		}
	
	
		location = "document_tracking.jsp?is_forwarded=2&barcode_id="+strBarcodeID;
	}
	
	function SearchTransaction(){
		document.form_.search_transaction.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.search_transaction.value = "1";
		document.form_.submit();
	}
	
	function ShowHideInfo(strShow, strDivName){
		if(strShow == "1")
			document.getElementById(strDivName).style.visibility = "visible";		
		else
			document.getElementById(strDivName).style.visibility = "hidden";		
	}
	
	function ReloadPage(){
		document.form_.submit();
	}
		
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./transaction_search_print.jsp" />
	<% 
		return;}
	
	//add security here..
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"DOCUMENT TRACKING","transaction_search.jsp");
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
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING-SEARCH"),"0"));
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	String[] astrDropListEqual = {"Any Keywords","All Keywords","Equal to"};
	String[] astrDropListValEqual = {"any","all","equals"};
	String[] astrSortByName = {"Barcode ID", "Transaction Date", "Document Name", "Origin/Owner"};
	String[] astrSortByVal  = {"barcode_id", "create_time", "document_name", "origin"};
	
	int iSearchResult = 0;
	Vector vRetResult = null;
	DocumentTracking dts = new DocumentTracking();
	
	if(WI.fillTextValue("search_transaction").length() > 0){
		vRetResult = dts.searchTransaction(dbOP, request);
		if(vRetResult == null)
			strErrMsg = dts.getErrMsg();
		else
			iSearchResult = dts.getSearchCount();
	}
	
	boolean bolIsAuthRestricted = dts.bolIsUserRestricted(dbOP, (String)request.getSession(false).getAttribute("userIndex"));
%>
<body bgcolor="#D2AE72">
<form name="form_" action="transaction_search.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="4" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SEARCH TRANSACTIONS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		    <td style="font-size:14px; font-weight:bold; color:#FF0000;" width="34%">
			<%if(bolIsAuthRestricted) {%>
				Authentication is Restricted
			<%}%>
			</td>
		</tr>
		<tr>
		  	<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">Document Category: </td>
			<%
				String strCategory = WI.fillTextValue("catg_index");
			%>
	  	    <td colspan="2">				
				<select name="catg_index">
					<option value="">Select Category</option>
					<%=dbOP.loadCombo("catg_index", "catg_name", " from doc_deped_catg where is_valid = 1 order by catg_name", strCategory, false)%>
				</select></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Origin/Owner:</td>
			<td colspan="2">
				<select name="origin_con">
              		<%=dts.constructGenericDropList(WI.fillTextValue("origin_con"),astrDropListEqual,astrDropListValEqual)%>
            	</select>
				<input type="text" name="origin" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="64" maxlength="256" value="<%=WI.fillTextValue("origin")%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Document Name: </td>
			<td colspan="2">
				<select name="doc_name_con">
              		<%=dts.constructGenericDropList(WI.fillTextValue("doc_name_con"),astrDropListEqual,astrDropListValEqual)%>
            	</select>
				<input type="text" name="doc_name" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="64" maxlength="256" value="<%=WI.fillTextValue("doc_name")%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Responsible Personnel: </td>
			<td colspan="2">
				<select name="resp_personnel_con">
              		<%=dts.constructGenericDropList(WI.fillTextValue("resp_personnel_con"),astrDropListEqual,astrDropListValEqual)%>
            	</select>
				<input type="text" name="resp_personnel" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="64" maxlength="128" value="<%=WI.fillTextValue("resp_personnel")%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Barcode No.: </td>
			<td colspan="2">
				<!--if this is filled up, then we will use the equals condition-->
				<input type="text" name="barcode_id" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onblur="style.backgroundColor='white'" size="32" maxlength="32" value="<%=WI.fillTextValue("barcode_id")%>"/></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Process Status:</td>
			<%
				strTemp = WI.fillTextValue("trans_status");
			%>
		    <td colspan="2">
				<select name="trans_status">
					<option value="">Select Status</option>
				<%if(strTemp.equals("0")){%>
					<option value="0" selected>Pending</option>
				<%}else{%>
					<option value="0">Pending</option>
					
				<%}if(strTemp.equals("1")){%>
					<option value="1" selected>Completed</option>
				<%}else{%>
					<option value="1">Completed</option>
				<%}%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Release Status:</td>
			<%
				strTemp = WI.fillTextValue("release_status");
			%>
		    <td colspan="2">
				<select name="release_status">
					<option value="">Select Status</option>
				<%if(strTemp.equals("0")){%>
					<option value="0" selected>Unreleased</option>
				<%}else{%>
					<option value="0">Unreleased</option>
					
				<%}if(strTemp.equals("1")){%>
					<option value="1" selected>Released</option>
				<%}else{%>
					<option value="1">Released</option>
				<%}%>
				</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Transaction Date: </td>
	      	<td colspan="2">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "2");
				%>
				<select name="date_type" onchange="ReloadPage();">		
					<%if (strTemp.equals("1")){%>
						<option value="1" selected>Specific Date</option>
					<%}else{%>
						<option value="1">Specific Date</option>
					
					<%}if (strTemp.equals("2")){%>
						<option value="2" selected>Date Range</option>
					<%}else{%>
						<option value="2">Date Range</option>
					<%}%>
				</select>

				<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../images/calendar_new.gif" border="0"></a>
				<%
					if(strTemp.equals("2")){
				%>
				to 
				<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
					value="<%=WI.fillTextValue("date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../images/calendar_new.gif" border="0"></a>
				<%}%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>&nbsp;</td>
	      	<td colspan="2">
				<%
					strTemp = WI.fillTextValue("view_all");
					if(strTemp.length() > 0)
						strTemp = "checked";
				%>
				<input type="checkbox" name="view_all" value="1" <%=strTemp%> />View All</td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
	</table>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25" width="20%" align="right"><strong><u>SORT BY: </u></strong>&nbsp; </td>
			<td width="16%">
				<select name="sort_by1">
					<option value="">N/A</option>
					<%=dts.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
				</select></td>
			<td width="17%">
				<select name="sort_by2">
					<option value="">N/A</option>
					<%=dts.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
				</select></td>
			<td>
				<select name="sort_by3">
					<option value="">N/A</option>
					<%=dts.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
				</select></td>
		</tr>
		<tr>
			<td height="25" align="right">&nbsp;</td>
			<td>
				<select name="sort_by1_con">
					<option value="asc">Ascending</option>
					<%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
						<option value="desc" selected>Descending</option>
					<%}else{%>
						<option value="desc">Descending</option>
					<%}%>
				</select></td>
			<td>
				<select name="sort_by2_con">
					<option value="asc">Ascending</option>
					<%if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
						<option value="desc" selected>Descending</option>
					<%}else{%>
						<option value="desc">Descending</option>
					<%}%>
				</select>			</td>
			<td>
				<select name="sort_by3_con">
					<option value="asc">Ascending</option>
					<%if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
						<option value="desc" selected>Descending</option>
					<%}else{%>
						<option value="desc">Descending</option>
					<%}%>
				</select></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="3">
				<a href="javascript:SearchTransaction();"><img src="../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to search document transaction.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="4">&nbsp;</td>
		</tr>
	</table>

<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">
				<font size="2">Number of Rows Per Page :</font>
				<select name="num_rec_page">
				<% 
				int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
				for(int i = 10; i <=40 ; i++) {
					if ( i == iDefault) {%>
						<option selected value="<%=i%>"><%=i%></option>
					<%}else{%>
						<option value="<%=i%>"><%=i%></option>
					<%}
				}%>
				</select>
				&nbsp;
				<a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0" /></a>
				<font size="1">click to print results</font>
			</td>
		</tr>
	</table>

	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="7" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF TRANSACTIONS ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(dts.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="3"> &nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResult/dts.defSearchSize;		
				if(iSearchResult % dts.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+dts.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="SearchTransaction();">
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
			<td height="25" align="center" class="thinborder" width="14%"><strong>Transaction Date</strong></td>
			<td align="center" class="thinborder" width="18%"><strong>Document Name</strong></td>
			<td align="center" class="thinborder" width="16%"><strong>Origin/Owner</strong></td>
			<td align="center" class="thinborder" width="12%"><strong>Category</strong></td>
			<td align="center" class="thinborder" width="12%"><strong>Barcode ID</strong></td>
			<td align="center" class="thinborder" width="16%"><strong>Responsible<br />Personnel </strong></td>
			<td align="center" class="thinborder" width="12%"><strong>Status</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 11, iCount++){%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+8)), 4)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+3);
				if(strTemp.length() > 17){
					strErrMsg = strTemp.substring(0, 17);
					if(strTemp.length() > 0)
						strErrMsg += "...";
						
					strTemp = "1";
				}
				else{
					strErrMsg = strTemp;
					strTemp = "";
				}
			%>
			<td class="thinborder">&nbsp;<%=strErrMsg%>
				<%if(strTemp.equals("1")){%>
					<a href="javascript:ShowHideInfo('1', 'info_<%=iCount%>');"><font color="#FF0000">[<u>more</u>]</font></a>
				<%}%>
				<div id="info_<%=iCount%>" style="position:absolute; visibility:hidden; width:600px; overflow:auto">
					<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFF99">
					<tr>
						<td width="88%"><strong><%=(String)vRetResult.elementAt(i+3)%></strong>&nbsp;</td>
						<td width="12%" align="center">
							<a href="javascript:ShowHideInfo('0', 'info_<%=iCount%>');">
							<strong><font size="2" color="#FF0000">CLOSE</font></strong></a></td>
					</tr>
					</table>
				</div></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborder">&nbsp;<a href="javascript:viewTracking('<%=(String)vRetResult.elementAt(i+5)%>')" style="text-decoration:none"><%=(String)vRetResult.elementAt(i+5)%></a></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+6);
				if(strTemp.equals("1")){
					strTemp = "Completed/";
					if(((String)vRetResult.elementAt(i+7)).equals("1"))
						strTemp += "Released";
					else
						strTemp += "Unreleased";
				}
				else
					strTemp = "In Process";
			%>
			<td class="thinborder">&nbsp;<%=strTemp%></td>
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
	
	<input type="hidden" name="print_page" />
	<input type="hidden" name="search_transaction" />
	
	<!-- called from search page -->
	<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>

