<%@ page language="java" import="utility.*, visitor.VisitLog, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Visitor Log</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css"></head>
<script language="javascript" src="../../Ajax/ajax.js"></script>
<script language="javascript" src="../../jscript/date-picker.js"></script>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function PrintPg(){
		document.form_.print_page.value = "1";
		document.form_.search_log.value = "";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.print_page.value = "";
		document.form_.search_log.value = "";
		document.form_.submit();
	}
	
	function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		document.form_.emp_id.value = strID;
		//document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
		document.getElementById("coa_info").innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function SearchLog(){
		document.form_.search_log.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
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
		var strURL = "../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+"&sel_name=d_index&all=1";
		//alert(strURL);
		this.processRequest(strURL);
}
</script>
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	if (WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./search_visitor_log_print.jsp" />
	<% 
		return;}
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Visitor Management-Search Visitor Log","search_visitor_log.jsp");
	}
	catch(Exception exp) {
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
															"Visitor Management","Search Visitor Log",request.getRemoteAddr(),
															"search_visitor_log.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	//end of authenticaion code.
	
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	
	int iSearchResult = 0;
	Vector vRetResult = null;
	VisitLog visitLog = new VisitLog();
	
	if(WI.fillTextValue("search_log").length() > 0){
		vRetResult = visitLog.searchVisitLogs(dbOP, request);
		if(vRetResult == null)
			strErrMsg = visitLog.getErrMsg();
		else
			iSearchResult = visitLog.getSearchCount();
	}
%>
<body bgcolor="#D2AE72" topmargin="0">
<form name="form_" method="post" action="search_visitor_log.jsp">
<jsp:include page="./tabs.jsp?pgIndex=2"></jsp:include>

	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">RF Card No.: </td>
			<td width="80%">
			<input name="rf_id_no" type="text" size="32" value="<%=WI.fillTextValue("rf_id_no")%>" class="textbox" 
					maxlength="32" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Date:</td>
		  	<td>
				<%
					strErrMsg = WI.getStrValue(WI.fillTextValue("date_type"), "0");
				%>
				<select name="date_type" onChange="ReloadPage()">
				<%if (strErrMsg.equals("0")){%>
					<option value="0" selected>Specific Date</option>
				<%}else{%>
					<option value="0">Specific Date</option>
				
				<%}if (strErrMsg.equals("1")){%>
					<option value="1" selected>Date Range</option>
				<%}else{%>
					<option value="1">Date Range</option>
				
				<%}if (strErrMsg.equals("2")){%>
					<option value="2" selected>Month</option>
				<%}else{%>
					<option value="2">Month</option>
					
				<%}if (strErrMsg.equals("3")){%>
					<option value="3" selected>Year</option>
				<%}else{%>
					<option value="3">Year</option>
				<%}%>
				</select>
				&nbsp;&nbsp;
			<%	strErrMsg = WI.getStrValue(WI.fillTextValue("date_type"), "0");				
				if (strErrMsg.equals("0") || strErrMsg.equals("1")){%>
				<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
					<img src="../../images/calendar_new.gif" border="0"></a>
				<%if(strErrMsg.equals("1")){%>
				<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_to")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp; 
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
				<img src="../../images/calendar_new.gif" border="0"></a>
				<%}
				}else{
					if(strErrMsg.equals("2")){%>
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
		  	<td>Time:</td>
		  	<td>
				<%
					strTemp = WI.fillTextValue("time_fr");
				%>
				<select name="time_fr">
				<%if(strTemp.equals("6")){%>
					<option value="6" selected>6 AM</option>
				<%}else{%>
					<option value="6">6 AM</option>					
				<%}if(strTemp.length() == 0 || strTemp.equals("7")){%>
					<option value="7" selected>7 AM</option>
				<%}else{%>
					<option value="7">7 AM</option>
				<%}if(strTemp.equals("8")){%>
					<option value="8" selected>8 AM</option>
				<%}else{%>
					<option value="8">8 AM</option>
				<%}if(strTemp.equals("9")){%>
					<option value="9" selected>9 AM</option>
				<%}else{%>
					<option value="9">9 AM</option>
				<%}if(strTemp.equals("10")){%>
					<option value="10" selected>10 AM</option>
				<%}else{%>
					<option value="10">10 AM</option>					
				<%}if(strTemp.equals("11")){%>
					<option value="11" selected>11 AM</option>
				<%}else{%>
					<option value="11">11 AM</option>					
				<%}if(strTemp.equals("12")){%>
					<option value="12" selected>12 NN</option>
				<%}else{%>
					<option value="12">12 NN</option>
				<%}if(strTemp.equals("13")){%>
					<option value="13" selected>1 PM</option>
				<%}else{%>
					<option value="13">1 PM</option>
				<%}if(strTemp.equals("14")){%>
					<option value="14" selected>2 PM</option>
				<%}else{%>
					<option value="14">2 PM</option>
				<%}if(strTemp.equals("15")){%>
					<option value="15" selected>3 PM</option>
				<%}else{%>
					<option value="15">3 PM</option>
				<%}if(strTemp.equals("16")){%>
					<option value="16" selected>4 PM</option>
				<%}else{%>
					<option value="16">4 PM</option>
				<%}if(strTemp.equals("17")){%>
					<option value="17" selected>5 PM</option>
				<%}else{%>
					<option value="17">5 PM</option>
				<%}if(strTemp.equals("18")){%>
					<option value="18" selected>6 PM</option>
				<%}else{%>
					<option value="18">6 PM</option>
				<%}if(strTemp.equals("19")){%>
					<option value="19" selected>7 PM</option>
				<%}else{%>
					<option value="19">7 PM</option>
				<%}if(strTemp.equals("20")){%>
					<option value="20" selected>8 PM</option>
				<%}else{%>
					<option value="20">8 PM</option>
				<%}if(strTemp.equals("21")){%>
					<option value="21" selected>9 PM</option>
				<%}else{%>
					<option value="21">9 PM</option>
				<%}%>
				</select>
				&nbsp;to&nbsp;
				<%
					strTemp = WI.fillTextValue("time_to");
				%>
				<select name="time_to">
				<%if(strTemp.equals("6")){%>
					<option value="6" selected>6 AM</option>
				<%}else{%>
					<option value="6">6 AM</option>					
				<%}if(strTemp.equals("7")){%>
					<option value="7" selected>7 AM</option>
				<%}else{%>
					<option value="7">7 AM</option>
				<%}if(strTemp.equals("8")){%>
					<option value="8" selected>8 AM</option>
				<%}else{%>
					<option value="8">8 AM</option>
				<%}if(strTemp.equals("9")){%>
					<option value="9" selected>9 AM</option>
				<%}else{%>
					<option value="9">9 AM</option>
				<%}if(strTemp.equals("10")){%>
					<option value="10" selected>10 AM</option>
				<%}else{%>
					<option value="10">10 AM</option>					
				<%}if(strTemp.equals("11")){%>
					<option value="11" selected>11 AM</option>
				<%}else{%>
					<option value="11">11 AM</option>					
				<%}if(strTemp.equals("12")){%>
					<option value="12" selected>12 NN</option>
				<%}else{%>
					<option value="12">12 NN</option>
				<%}if(strTemp.equals("13")){%>
					<option value="13" selected>1 PM</option>
				<%}else{%>
					<option value="13">1 PM</option>
				<%}if(strTemp.equals("14")){%>
					<option value="14" selected>2 PM</option>
				<%}else{%>
					<option value="14">2 PM</option>
				<%}if(strTemp.equals("15")){%>
					<option value="15" selected>3 PM</option>
				<%}else{%>
					<option value="15">3 PM</option>
				<%}if(strTemp.equals("16")){%>
					<option value="16" selected>4 PM</option>
				<%}else{%>
					<option value="16">4 PM</option>
				<%}if(strTemp.length() == 0 || strTemp.equals("17")){%>
					<option value="17" selected>5 PM</option>
				<%}else{%>
					<option value="17">5 PM</option>
				<%}if(strTemp.equals("18")){%>
					<option value="18" selected>6 PM</option>
				<%}else{%>
					<option value="18">6 PM</option>
				<%}if(strTemp.equals("19")){%>
					<option value="19" selected>7 PM</option>
				<%}else{%>
					<option value="19">7 PM</option>
				<%}if(strTemp.equals("20")){%>
					<option value="20" selected>8 PM</option>
				<%}else{%>
					<option value="20">8 PM</option>
				<%}if(strTemp.equals("21")){%>
					<option value="21" selected>9 PM</option>
				<%}else{%>
					<option value="21">9 PM</option>
				<%}%>
			</select></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>RF Card Return Status: </td>
		  	<td>
				<%
					strErrMsg = WI.fillTextValue("rf_status");
					if(strErrMsg.length() == 0)
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="radio" name="rf_status" value="" <%=strTemp%>>Show All&nbsp;
				<%
					if(strErrMsg.equals("0"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="radio" name="rf_status" value="0" <%=strTemp%>>Unreturned&nbsp;
				<%
					if(strErrMsg.equals("1"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="radio" name="rf_status" value="1" <%=strTemp%>>OK&nbsp;
				<%
					if(strErrMsg.equals("2"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="radio" name="rf_status" value="2" <%=strTemp%>>Lost&nbsp;
				<%
					if(strErrMsg.equals("3"))
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="radio" name="rf_status" value="3" <%=strTemp%>>Damaged
			</td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Visitor Last Name: </td>
		  	<td>
				<select name="v_lname_con">
					<%=visitLog.constructGenericDropList(WI.fillTextValue("v_lname_con"),astrDropListEqual,astrDropListValEqual)%>
				</select>
				<input name="v_lname" type="text" size="32" value="<%=WI.fillTextValue("v_lname")%>" class="textbox" 
					maxlength="32" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Visitor First Name: </td>
		  	<td>
				<select name="v_fname_con">
					<%=visitLog.constructGenericDropList(WI.fillTextValue("v_fname_con"),astrDropListEqual,astrDropListValEqual)%>
				</select>
				<input name="v_fname" type="text" size="32" value="<%=WI.fillTextValue("v_fname")%>" class="textbox" 
					maxlength="32" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
	  	</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Person Visited (ID): </td>
		  	<td>
				<select name="emp_id_con">
					<%=visitLog.constructGenericDropList(WI.fillTextValue("emp_id_con"),astrDropListEqual,astrDropListValEqual)%>
				</select>
				<input name="emp_id" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);" value="<%=WI.fillTextValue("emp_id")%>" size="16">&nbsp;
				<label id="coa_info" style="position:absolute; width:350px"></label></td>
	  	</tr>
		
		
		
		
		<tr> 
            <td height="25">&nbsp;</td>
            <td height="25" valign="bottom">College</td>
            <td width="68%" height="25"><select name="c_index" onChange="loadDept();" style="width:300px;">
                <option value="0">N/A</option>
<% 
	strTemp = WI.fillTextValue("c_index");	
%>           <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> </select>			</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" valign="bottom">Office/Department</td>
            <td height="25"> 
			 <label id="load_dept" style="position:absolute; width:200px;">
			 <select name="d_index" style="width:200px;">
			 <option value="">N/A</option>
<%
strErrMsg = WI.fillTextValue("d_index");		
if (strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") == 0) strTemp = " and (c_index = 0 or c_index is null) ";
	else strTemp = " and c_index = " +  strTemp;
%>
               <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",strErrMsg, false)%> </select>
			  </label>
              &nbsp; </td>
          </tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Event Name: </td>
			<td width="80%">
			<select name="event_index" style="width:300px;">
				<option value=""></option>	
				<%=dbOP.loadCombo("event_index","event_name, venue"," from visit_event where is_valid = 1 order by event_name",WI.fillTextValue("event_index"),false)%>
			</select>			
			</td>
		</tr>
		
		<tr>
			<td height="40" colspan="2">&nbsp;</td>
			<td valign="middle">
				<a href="javascript:SearchLog();"><img src="../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to search visitor log.</font></td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
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
				<a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a>
				<font size="1">Click to print search results.</font></td>
		</tr>
	</table>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<tr>
			<td height="20" colspan="11" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: SEARCH RESULTS :::</strong></div></td>
	 	</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="7">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(visitLog.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="4"> &nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResult/visitLog.defSearchSize;		
				if(iSearchResult % visitLog.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+visitLog.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="ViewSummary();">
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
			<td height="25" align="center" class="thinborder" width="9%"><strong>DATE</strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>TIME-IN</strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>TIME-OUT</strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>ENCODED BY </strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>VISITOR'S RF CARD NO. </strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>VISITOR'S NAME </strong></td>
		    <td align="center" class="thinborder" width="9%"><strong> PICTURE </strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>ID PRESENTED </strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>VISITED </strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>PURPOSE</strong></td>
		    <td align="center" class="thinborder" width="10%"><strong>REMARK</strong></td>
		</tr>
	<%	double dTemp = 0d;
		for(int i = 0; i < vRetResult.size(); i += 20){%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		    <td class="thinborder"><%=CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vRetResult.elementAt(i+2)))%></td>
			<%
				dTemp = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i+3), "0"));
				if(dTemp == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.convert24HRTo12Hr(dTemp);
			%>
		    <td class="thinborder"><%=strTemp%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
		    <td class="thinborder">
			<%=WebInterface.formatName((String)vRetResult.elementAt(i+6), (String)vRetResult.elementAt(i+7), (String)vRetResult.elementAt(i+8), 4)%></td>
		    <%
				strTemp = "../../upload_img/visitor/"+(String)vRetResult.elementAt(i+16)+".jpg";
			%>
			<td class="thinborder" align="center"><img src="<%=strTemp%>" width="50" height="50" border="1"></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+9)%></td>
			<%
			strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+11), (String)vRetResult.elementAt(i+12), (String)vRetResult.elementAt(i+13), 4);
			if(strTemp == null || strTemp.length() == 0)
				strTemp = (String)vRetResult.elementAt(i+18);
			if(strTemp == null || strTemp.length() == 0)
				strTemp = (String)vRetResult.elementAt(i+19);

			%>
		    <td class="thinborder">
			<%=strTemp%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+14)%></td>
		    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+15), "&nbsp;")%></td>
		</tr>
	<%}%>
	</table>
<%}%>

	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		</tr>
		<tr> 
			<td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="search_log">
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>