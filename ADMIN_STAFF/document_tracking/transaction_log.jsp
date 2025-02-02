<%@ page language="java" import="utility.*, docTracking.deped.DocumentTracking, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
	if(WI.fillTextValue("print_pg").length() > 0){%>
		<jsp:forward page="./transaction_log_print.jsp" />
	<%}
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/reportlink.css" rel="stylesheet" type="text/css">
<title>Transaction Log</title></head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">
	function PrintPg() {
		document.form_.print_pg.value='1';
		document.form_.view_all.checked = true;
		document.form_.submit();
	}
	function ViewTransactionLog(){
		document.form_.view_transaction_log.value = "1";
		document.form_.print_pg.value='';
		document.form_.submit();
	}
	
	function viewTracking(strBarcodeID){		
		var pgLoc = "./document_tracking.jsp?is_forwarded=3&barcode_id="+strBarcodeID;
		var win=window.open(pgLoc,"viewTracking",'width=900,height=500,top=110,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=yes,menubar=no');
		win.focus();
	}
	
	function loadSearchDept() {
		var objCOA=document.getElementById("load_search_dept");
 		var objCollegeInput = document.form_.search_college[document.form_.search_college.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=search_dept&all=1";
		this.processRequest(strURL);
	}
		
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here..
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"DOCUMENT TRACKING","transaction_log.jsp");
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
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING-MANAGE TRANSACTIONS"),"0"));
		if(iAccessLevel == 0) 
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("DOCUMENT TRACKING-REPORTS"),"0"));
	}
	
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
	
	int iSearchResult = 0;
	Vector vRetResult = null;
	DocumentTracking docTracking = new DocumentTracking();
	
	if(WI.fillTextValue("view_transaction_log").length() > 0){
		vRetResult = docTracking.getTransactionLog(dbOP, request);
		if(vRetResult == null)
			strErrMsg = docTracking.getErrMsg();
		else
			iSearchResult = docTracking.getSearchCount();
	}
%>
<body bgcolor="#D2AE72">
<form name="form_" action="transaction_log.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: TRANSACTION LOG ::::</strong></font></div></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Date Received: </td>
			<td>
				<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../images/calendar_new.gif" border="0"></a>
				to
				<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
					value="<%=WI.fillTextValue("date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="17%">Offce: </td>
			<td width="80%">
				<%
					String strCollegeCon = WI.fillTextValue("search_college");
				%>
				<select name="search_college" onChange="loadSearchDept();">
					<option value="0">ALL</option>
					<%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0 order by c_name", strCollegeCon, false)%> 
        		</select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Department: </td>
			<td>
				<%
					strTemp = WI.fillTextValue("search_dept");
				%>
				<label id="load_search_dept">
				<select name="search_dept">
         			<option value="">ALL</option>
          		<%if ((strCollegeCon.length() == 0) || strCollegeCon.equals("0")){%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null) order by d_name", strTemp, false)%> 
          		<%}else{%>
          			<%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeCon + " order by d_name ", strTemp, false)%> 
         		 <%}%>
  	   			</select></label></td>
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
			<td><input type="checkbox" name="view_all" <%=strTemp%> value="1"> View All</td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="javascript:ViewTransactionLog();"><img src="../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to view transaction log.</font></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
		<tr>
		  <td height="20" colspan="7" class="thinborder" align="right">
		  <a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0" /></a> Print Report &nbsp;
		  
		  </td>
	  </tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="7" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF EXISTING TRANSACTION(S) IN RECORD ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(docTracking.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="3"> &nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResult/docTracking.defSearchSize;		
				if(iSearchResult % docTracking.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+docTracking.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="ViewTransactionLog();">
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
			<td height="25" width="10%" align="center" class="thinborder"><strong>Office/Dept</strong></td>
			<td width="11%" align="center" class="thinborder"><strong>Barcode ID </strong></td>
			<td width="17%" align="center" class="thinborder"><strong>Received By </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Received Date/Time </strong></td>
			<td width="17%" align="center" class="thinborder"><strong>Released By </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Released Date/Time </strong></td>
			<td width="15%" align="center" class="thinborder"><strong>Action</strong></td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 25, iCount++){
	%>
		<tr>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3));
				strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+4));
				
				if(strTemp.length() > 0 && strErrMsg.length() > 0)
					strTemp += "/ ";
				strTemp += strErrMsg;
			%>
			<td height="25" class="thinborder">&nbsp;<%=strTemp%></td>
		  	<td class="thinborder">&nbsp;<strong><a href="javascript:viewTracking('<%=(String)vRetResult.elementAt(i+18)%>')" style="text-decoration:none"><%=(String)vRetResult.elementAt(i+18)%></a></strong></td>
			<td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+19), (String)vRetResult.elementAt(i+20), (String)vRetResult.elementAt(i+21), 4)%></td>			
			<td class="thinborder">&nbsp;<%=WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+7)), 4)%></td>
			<td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+22), (String)vRetResult.elementAt(i+23), (String)vRetResult.elementAt(i+24), 4)%></td>
			<%
				if((String)vRetResult.elementAt(i+11) == null)
					strTemp = "";
				else
					strTemp = WI.formatDateTime(Long.parseLong((String)vRetResult.elementAt(i+11)), 4);
			%>
			<td class="thinborder">&nbsp;<%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+13);
				if(strTemp == null)
					strTemp = "-In Process-";
				else if(strTemp.equals("1")){//forwarded
					strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15));
					strErrMsg = WI.getStrValue((String)vRetResult.elementAt(i+16));
					
					if(strTemp.length() > 0 && strErrMsg.length() > 0)
						strTemp += "/ ";
					strTemp += strErrMsg;
					strTemp = "FWD to "+strTemp+". (Resposible Personnel: "+(String)vRetResult.elementAt(i+14)+")";
				}
				else if(strTemp.equals("2"))//closed
					strTemp = "Completed";
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
	
	<input type="hidden" name="view_transaction_log">
	<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>