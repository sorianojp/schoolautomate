<%@ page language="java" import="utility.*, inventory.InventoryMaintenance, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Gate Pass Search</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../../jscript/date-picker.js" ></script>
<script language="javascript"  src="../../../../Ajax/ajax.js"></script>
<script>

function ReloadPage()
{
	document.search_form_.show_data.value = "";
	document.search_form_.submit();
}





var strSearchType = "";
function AjaxMapName(strType) {
	strSearchType = strType;
	
	var strCompleteName = "";
	var objCOAInput = "";
	if(strType == "1"){
		strCompleteName = document.search_form_.requested_by.value;
	   objCOAInput = document.getElementById("lbl_request");
	}else if(strType == "2"){
		strCompleteName = document.search_form_.noted_by.value;
	   objCOAInput = document.getElementById("lbl_note");
	}else if(strType == "3"){
		strCompleteName = document.search_form_.approved_by.value;
	   objCOAInput = document.getElementById("lbl_approve");
	}else if(strType == "4"){
		strCompleteName = document.search_form_.issued_by.value;
	   objCOAInput = document.getElementById("lbl_issue");
	}else{
		strCompleteName = document.search_form_.encoded_by.value;
	   objCOAInput = document.getElementById("lbl_encode");
	}
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	
		
}
function UpdateName(strFName, strMName, strLName) {
	
}
function UpdateNameFormat(strName) {
	if(strSearchType == "1"){
		document.search_form_.requested_by.value = strName;
	   document.getElementById("lbl_request").innerHTML = "";
	}else if(strSearchType == "2"){
		document.search_form_.noted_by.value = strName;
	   document.getElementById("lbl_note").innerHTML = "";
	}else if(strSearchType == "3"){
		document.search_form_.approved_by.value = strName;
	   document.getElementById("lbl_approve").innerHTML = "";
	}else if(strSearchType == "4"){
		document.search_form_.issued_by.value = strName;
	   document.getElementById("lbl_issue").innerHTML = "";
	}else{
		document.search_form_.encoded_by.value = strName;
	   document.getElementById("lbl_encode").innerHTML = "";
	}
}

function ShowData(){
	document.search_form_.show_data.value = "1";
	document.search_form_.submit();
}

<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strID)
{
	
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strID;	
	window.opener.document.<%=WI.fillTextValue("opener_form_name")%>.proceed.value=1;
	window.opener.document.<%=WI.fillTextValue("opener_form_name")%>.print_page.value="";
	window.opener.document.<%=WI.fillTextValue("opener_form_name")%>.allow_print.value=1;
	window.opener.document.<%=WI.fillTextValue("opener_form_name")%>.submit();
	window.opener.focus();
	
	self.close();
}
<%}%>

</script>
</head>

<%
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	
	


	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-MAINTENANCE"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try
	{
	 	dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"INVENTORY-INVENTORY MAINTENANCE","gate_pass_mgmt.jsp");								

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}

String[] astrSortByName = {"Gate Pass No","Encoded By","Encoded Date", "Issued By", "Issued Date"};
String[] astrSortByVal = {"gp_no","ENCODED_BY","DATE_ENCODED","FINALIZED_BY", "FINALIZED_DATE"};	
	
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};	


InventoryMaintenance invMaintenance = new InventoryMaintenance();


Vector vRetResult = null;

if(WI.fillTextValue("show_data").length() > 0){
	vRetResult = invMaintenance.operateOnGatePass(dbOP, request, 4, null);
	if(vRetResult == null)
		strErrMsg = invMaintenance.getErrMsg();
}



%>

<body bgcolor="#D2AE72">
<form name="search_form_" action="gate_pass_search.jsp" method="post" >
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GATE PASS SEARCH PAGE ::::</strong></font></div></td>
    </tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="6"><font size="3" color="red"><strong><%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></font></td>
    </tr>    
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="15%">Gate Pass No.: </td>
      <td width="82%">
	  <select name="gate_pass_no_con">
          <%=invMaintenance.constructGenericDropList(WI.fillTextValue("gate_pass_no_con"),astrDropListEqual,astrDropListValEqual)%>
	  </select>
	  <input type="text" name="gate_pass_no_search" class="textbox" value="<%=WI.fillTextValue("gate_pass_no_search")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
       <td height="25">&nbsp;</td>
       <td>Origin</td>
       <td>
	  <select name="origin_con">
          <%=invMaintenance.constructGenericDropList(WI.fillTextValue("origin_con"),astrDropListEqual,astrDropListValEqual)%>
	  </select>
	  <input type="text" name="origin_search" class="textbox" value="<%=WI.fillTextValue("origin_search")%>" size="50"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	 <tr>
       <td height="25">&nbsp;</td>
       <td>Destination</td>
       <td>
	  <select name="destination_con">
          <%=invMaintenance.constructGenericDropList(WI.fillTextValue("destination_con"),astrDropListEqual,astrDropListValEqual)%>
	  </select>
	  <input type="text" name="destination_search" class="textbox" value="<%=WI.fillTextValue("destination_search")%>" size="50"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
	 <tr> 
      <td height="30">&nbsp;</td>
      <td>Encoded by :</td>
		<%
		strTemp = WI.fillTextValue("encoded_by_search");		
		%>
      <td height="30" colspan="2" valign="middle">
			 <select name="encoded_by_con">
          <%=invMaintenance.constructGenericDropList(WI.fillTextValue("encoded_by_con"),astrDropListEqual,astrDropListValEqual)%>
	  </select>
			<input name="encoded_by_search" type="text" size="32" maxlength="32" value="<%=strTemp%>" class="textbox" 
	      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('5');">
			&nbsp; &nbsp;
			<label id="lbl_encode" style="position:absolute; width:400px;"></label>
		</td>
    </tr>
	 <tr> 
      <td height="30">&nbsp;</td>
      <td>Requested by :</td>
		<%
		strTemp = WI.fillTextValue("requested_by_search");		
		%>
      <td height="30" colspan="2" valign="middle">
		 <select name="requested_by_con">
          <%=invMaintenance.constructGenericDropList(WI.fillTextValue("requested_by_con"),astrDropListEqual,astrDropListValEqual)%>
	  </select>
			<input name="requested_by_search" type="text" size="32" maxlength="32" value="<%=strTemp%>" class="textbox" 
	      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('1');">
			&nbsp; &nbsp;
			<label id="lbl_request" style="position:absolute; width:400px;"></label>
		</td>
    </tr>
	 
	 
	 <tr> 
      <td height="30">&nbsp;</td>
      <td>Noted by :</td>
		<%
		strTemp = WI.fillTextValue("noted_by_search");		
		%>
      <td height="30" colspan="2" valign="middle">
		 <select name="noted_by_con">
          <%=invMaintenance.constructGenericDropList(WI.fillTextValue("noted_by_con"),astrDropListEqual,astrDropListValEqual)%>
	  </select>
			<input name="noted_by_search" type="text" size="32" maxlength="32" value="<%=strTemp%>" class="textbox" 
	      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('2');">
			&nbsp; &nbsp;
			<label id="lbl_note" style="position:absolute; width:400px;"></label>
		</td>
    </tr>
	 
	 <tr> 
      <td height="30">&nbsp;</td>
      <td>Approved by :</td>
		<%
		strTemp = WI.fillTextValue("approved_by_search");		
		%>
      <td height="30" colspan="2" valign="middle">
		 <select name="approved_by_con">
          <%=invMaintenance.constructGenericDropList(WI.fillTextValue("approved_by_con"),astrDropListEqual,astrDropListValEqual)%>
	  </select>
			<input name="approved_by_search" type="text" size="32" maxlength="32" value="<%=strTemp%>" class="textbox" 
	      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('3');">
			&nbsp; &nbsp;
			<label id="lbl_approve" style="position:absolute; width:400px;"></label>
		</td>
    </tr>
	 
	 
	 <tr> 
      <td height="30">&nbsp;</td>
      <td>Issued by :</td>
		<%
		strTemp = WI.fillTextValue("issued_by_search");		
		%>
      <td height="30" colspan="2" valign="middle">
		 <select name="issued_by_con">
          <%=invMaintenance.constructGenericDropList(WI.fillTextValue("issued_by_con"),astrDropListEqual,astrDropListValEqual)%>
	  </select>
			<input name="issued_by_search" type="text" size="32" maxlength="32" value="<%=strTemp%>" class="textbox" 
	      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName('4');">
			&nbsp; &nbsp;
			<label id="lbl_issue" style="position:absolute; width:400px;"></label>
		</td>
    </tr>
</table>



<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25">&nbsp;</td>
			<td width="15%">Encoded Date: </td>
			<td colspan="4">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type_encode"), "1");
				%>
				<select name="date_type_encode" onChange="ReloadPage();">
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
				<input name="date_fr_encode" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr_encode")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('search_form_.date_fr_encode');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../../images/calendar_new.gif" border="0"></a>
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type_encode"), "1");
					if(strTemp.equals("2")){
				%>
				to 
				<input name="date_to_encode" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
					value="<%=WI.fillTextValue("date_to_encode")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('search_form_.date_to_encode');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../../images/calendar_new.gif" border="0"></a>
			<%}%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="15%">Issued Date: </td>
			<td colspan="4">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type_issue"), "1");
				%>
				<select name="date_type_issue" onChange="ReloadPage();">
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
				<input name="date_fr_issue" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr_issue")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('search_form_.date_fr_issue');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../../images/calendar_new.gif" border="0"></a>
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type_issue"), "1");
					if(strTemp.equals("2")){
				%>
				to 
				<input name="date_to_issue" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
					value="<%=WI.fillTextValue("date_to_issue")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('search_form_.date_to_issue');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../../images/calendar_new.gif" border="0"></a>
			<%}%></td>
		</tr>
		<tr>
          	<td height="25" width="3%">&nbsp;</td>
		  	<td width="15%">Sort by: </td>
		  	<td width="20%">
				<select name="sort_by1">
					<option value="">N/A</option>
					<%=invMaintenance.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
			</select></td>
		    <td width="21%">
				<select name="sort_by2">
              		<option value="">N/A</option>
             		<%=invMaintenance.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
			</select></td>
		    <td width="41%">
				<select name="sort_by3">
					<option value="">N/A</option>
              		<%=invMaintenance.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
     	   </select></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>&nbsp;</td>
		    <td>
				<select name="sort_by1_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by1_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
				</select></td>
			<td>
				<select name="sort_by2_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by2_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
            	</select></td>
			<td>
				<select name="sort_by3_con">
              		<option value="asc">Ascending</option>
              	<%if(WI.fillTextValue("sort_by3_con").equals("desc")){%>
              		<option value="desc" selected="selected">Descending</option>
              	<%}else{%>
              		<option value="desc">Descending</option>
              	<%}%>
            	</select></td>
		</tr>
		<tr>
		   <td height="25">&nbsp;</td>
		   <td>&nbsp;</td>
		   <td colspan="3"><a href="javascript:ShowData();"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
	   </tr>
	</table>	

<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center" height="22">LIST OF GATE PASS INFORMATION</td></tr>
</table>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
	<tr>
		<td width="14%" height="20" align="center" class="thinborder"><font size="1">GATE PASS NO</font></td>
		<td width="16%" align="center" class="thinborder"><font size="1">ENCODED BY</font></td>
		<td width="16%" align="center" class="thinborder"><font size="1">ISSUED BY</font></td>
		<td width="26%" align="center" class="thinborder"><font size="1">ORIGIN</font></td>
		<td width="28%" align="center" class="thinborder"><font size="1">DESTINATION</font></td>
	</tr>
	
	<%
	System.out.println(vRetResult);
	
	for(int i = 0; i < vRetResult.size(); i += 21){
	%>
	<tr>
		<td class="thinborder" height="18">
			<%if(WI.fillTextValue("opner_info").length() > 0) {%>
			<a href="javascript:CopyID('<%=vRetResult.elementAt(i+1)%>');"><%=vRetResult.elementAt(i+1)%></a>
			<%}else{%><%=vRetResult.elementAt(i+1)%><%}%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i+2)%></td>
		<td class="thinborder"><%=vRetResult.elementAt(i+12)%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+5),"&nbsp;")%></td>
		<td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
	</tr>
	<%}%>
	
</table>
<%}%>


<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
<tr><td height="25"  colspan="3">&nbsp;</td></tr>
<tr><td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td></tr>
</table>

<input type="hidden" name="show_data" >
<input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
<input type="hidden" name="opener_form_name" value="<%=WI.fillTextValue("opener_form_name")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>