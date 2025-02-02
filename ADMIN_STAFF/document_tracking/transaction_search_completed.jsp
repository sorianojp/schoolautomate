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
<title>Search Completed Transactions</title></head>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function viewTracking(strBarcodeID){
		location = "document_tracking.jsp?is_forwarded=2&barcode_id="+strBarcodeID;
	}
	
	function SearchTransaction(){
		document.form_.search_transaction.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	
	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.search_transaction.value = "";
		document.form_.submit();
	}
	
	function ShowHideInfo(strShow, strDivName){
		if(strShow == "1")
			document.getElementById(strDivName).style.visibility = "visible";		
		else
			document.getElementById(strDivName).style.visibility = "hidden";		
	}
	
	function ReloadPage(){
		document.form_.search_transaction.value = "";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
		
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./transaction_search_completed_print.jsp" />
	<% 
		return;}
	
	//add security here..
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"DOCUMENT TRACKING","transaction_search_completed.jsp");
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
		vRetResult = dts.searchCompletedTransactions(dbOP, request);
		if(vRetResult == null)
			strErrMsg = dts.getErrMsg();
		else
			iSearchResult = dts.getSearchCount();
	}
	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="transaction_search_completed.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: SEARCH COMPLETED TRANSACTIONS ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
		  	<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">Search Type: </td>
	  	    <td width="80%">
				<select name="search_type" onchange="ReloadPage()">
				<%if (WI.fillTextValue("search_type").equals("0")){%>
					<option value="0" selected>Specific Date</option>
				<%}else{%>
					<option value="0">Specific Date</option>
				
				<%}if (WI.fillTextValue("search_type").equals("1")){%>
					<option value="1" selected>Month</option>
				<%}else{%>
					<option value="1">Month</option>
					
				<%}if (WI.fillTextValue("search_type").equals("2")){%>
					<option value="2" selected>Year</option>
				<%}else{%>
					<option value="2">Year</option>
				<%}%>
				</select>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<%if (WI.fillTextValue("search_type").equals("0") || WI.fillTextValue("search_type").length() == 0){
					strTemp = WI.fillTextValue("date_completed");
					if(strTemp.length() == 0) 
						strTemp = WI.getTodaysDate(1);
				%>
				<input name="date_completed" type="text" size="10" maxlength="10" readonly="yes" value="<%=strTemp%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date_completed');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
					<img src="../../images/calendar_new.gif" border="0"></a>
				<%}else{
					if(WI.fillTextValue("search_type").equals("1")){%>
						<select name="month">
							<%=dbOP.loadComboMonth(WI.fillTextValue("month"))%>
						</select>
					<%}%>
					<select name="year" size="1" id="year">
						<%=dbOP.loadComboYear(WI.fillTextValue("year"), 1, 1)%>
					</select>
				<%}%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>&nbsp;</td>
	      <td>
				<%
					strTemp = WI.fillTextValue("view_all");
					if(strTemp.length() > 0)
						strTemp = "checked";
				%>
				<input type="checkbox" name="view_all" value="1" <%=strTemp%> />View All</td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
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
		  	<td height="20" colspan="9" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF TRANSACTIONS ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="5">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(dts.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="4"> &nbsp;
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
			<td width="10%" rowspan="2" align="center" class="thinborder"><strong> DATE </strong></td>
			<td width="5%" rowspan="2" align="center" class="thinborder"><strong>Ref.<br />No.</strong></td>
			<td width="40%" rowspan="2" align="center" class="thinborder"><strong>PARTICULARS</strong></td>
			<td width="15%" rowspan="2" align="center" class="thinborder"><strong>RERERRED TO </strong></td>
			<td width="10%" rowspan="2" align="center" class="thinborder"><strong>ACTION TAKEN </strong></td>
			<td height="20" colspan="4" align="center" class="thinborder"><strong>NO. OF DAYS ACTED </strong></td>
		</tr>
		<tr>
			<td width="5%" height="20" align="center" class="thinborder"><strong>1-4</strong></td>
			<td align="center" class="thinborder" width="5%"><strong>5-9</strong></td>
			<td align="center" class="thinborder" width="5%"><strong>10-14</strong></td>
			<td align="center" class="thinborder" width="5%"><strong>15+</strong></td>
		</tr>
	<%	int iDiff = 0;
		String strCurrentDate = "";
		String strReleaseDate = null;
		for(int i = 0; i < vRetResult.size(); i += 7){
			strReleaseDate = (String)vRetResult.elementAt(i);
				
			if(strCurrentDate.equals(strReleaseDate)){
				strTemp = "";
			}
			else{
				strCurrentDate = strReleaseDate;
				strTemp = strCurrentDate;
			}
				
			iDiff = ConversionTable.differenceInDays(Long.parseLong((String)vRetResult.elementAt(i+5)), Long.parseLong((String)vRetResult.elementAt(i+6)));
	%>
		<tr>
			<td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder">&nbsp;<strong><%=(String)vRetResult.elementAt(i+2)%></strong><br />&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">&nbsp;</td>
			<%
				if(iDiff <= 4)
					strTemp = Integer.toString(iDiff);
				else
					strTemp = "";
			%>
			<td class="thinborder" align="center"><%=strTemp%></td>
			<%
				if(iDiff > 4 && iDiff <= 9)
					strTemp = Integer.toString(iDiff);
				else
					strTemp = "";
			%>
			<td class="thinborder" align="center"><%=strTemp%></td>
			<%
				if(iDiff > 9 && iDiff <= 14)
					strTemp = Integer.toString(iDiff);
				else
					strTemp = "";
			%>
			<td class="thinborder" align="center"><%=strTemp%></td>
			<%
				if(iDiff > 14)
					strTemp = Integer.toString(iDiff);
				else
					strTemp = "";
			%>
			<td class="thinborder" align="center"><%=strTemp%></td>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>

