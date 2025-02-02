<%@ page language="java" import="utility.*,hmsOperation.RestPOS,java.util.Vector"%>
<%
	WebInterface WI  = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Floating Orders</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	function GenerateReport(){
		document.form_.generate_report.value = "1";
		document.form_.submit();
	}
	

	var objCOA;
	var objCOAInput;
	function AjaxMapName() {
		var strIDNumber = document.form_.id_number.value;
		objCOAInput = document.getElementById("coa_info");
		eval('objCOA=document.form_.id_number');
		if(strIDNumber.length < 3) {
			objCOAInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?is_faculty=-1&methodRef=2&search_id=1&name_format=4&complete_name="+escape(strIDNumber);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		objCOA.value = strID;
		objCOAInput.innerHTML = "";		
	}	
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function navRollOver(obj, state) {
	  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
	}
	function checkAllSaveItems() {

		var maxDisp = document.form_.item_count.value;
		var bolIsSelAll = document.form_.selAllSaveItems.checked;


		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function UpdateFloatingOrders(){
		document.form_.update_floating_orders.value = "1";
		document.form_.submit();
	}

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-REPORTS"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD"),"0"));
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-Reports","floating_orders.jsp");	
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
	
	String[] astrSortByName    = {"ID Number","Last Name","First Name","Order Date"};
	String[] astrSortByVal     = {"id_number","lname","fname","salesMain.create_date"};
	
	RestPOS resPOS = new RestPOS();
	Vector vRetResult = null;
	
	if(WI.fillTextValue("update_floating_orders").length() > 0){
		if(resPOS.operateOnFloatingOrders(dbOP, request, 1) == null)
			strErrMsg = resPOS.getErrMsg();
	}
	
	if(WI.fillTextValue("generate_report").length() > 0){
		vRetResult = resPOS.operateOnFloatingOrders(dbOP, request, 4);
		if(vRetResult == null)
			strErrMsg = resPOS.getErrMsg();		
	}
%>		
<body bgcolor="#D2AE72">
<form name="form_" action="./floating_orders.jsp" method="post">

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable1">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" align="center"><font color="#FFFFFF">
				<strong>:::: FLOATING ORDERS MANAGEMENT ::::</strong></font></td>
		</tr>		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>	
		
		<tr>
			<td height="25">&nbsp;</td>
			<td width="14%">Transaction Date: </td>
			<td width="83%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
				%>
				<select name="date_type" onchange="document.form_.submit();">		
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
				<img src="../../../images/calendar_new.gif" border="0"></a>
			<%if(strTemp.equals("2")){%>
				to 
    			<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
					value="<%=WI.fillTextValue("date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'">
    			<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
		  			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
		  <%}%></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>ID Number:</td>
		  	<td>
				<input name="id_number" type="text" class="textbox" size="16" value="<%=WI.fillTextValue("id_number")%>" 
					onKeyUp="AjaxMapName();" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp;&nbsp;&nbsp;
				<label id="coa_info" style="width:300px; position:absolute; "></label></td>
	  	</tr>
		
	</table>
	
	<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="" id="myTable5">
	<tr><td height="10" colspan="3"></td></tr>
	<tr>
          	<td height="25" width="3%">&nbsp;</td>
		  	<td width="17%">Sort by: </td>
		  	<td width="20%">
				<select name="sort_by1">
					<option value="">N/A</option>
					<%=resPOS.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="20%">
				<select name="sort_by2">
              		<option value="">N/A</option>
             		<%=resPOS.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%>
				</select></td>
		    <td width="40%">
				<select name="sort_by3">
					<option value="">N/A</option>
              		<%=resPOS.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%>
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
		<tr><td height="10" colspan="7"></td></tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td colspan="6"><a href="javascript:GenerateReport();"><img src="../../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to generate floating orders.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="7">&nbsp;</td>
		</tr>
		</table>
	
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable2">	
	<tr><td align="center"><strong>
		<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
		<%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
		FLOATING ORDERS <%=WI.fillTextValue("date_fr")%><%=WI.getStrValue(WI.fillTextValue("date_to"),"-","","")%>
	</strong></td></tr>
</table>
<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
	<tr>
		<td width="11%" align="center" class="thinborder"><strong>ID Number</strong></td>
		<td width="22%" align="center" class="thinborder"><strong>Name</strong></td>
		<td width="10%" align="center" class="thinborder"><strong>Card Balance</strong></td>
		<td width="14%" align="center" class="thinborder"><strong>Ordered Terminal</strong></td>
		<td width="8%" height="25" align="center" class="thinborder"><strong>Date</strong></td>		
		<td width="30%" align="center" class="thinborder"><strong>Item List</strong></td>
		<td width="5%" height="25" align="center" class="thinborder"><strong>Select All<br>
		<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();">
	  </strong></td>		
	</tr>
	<%
	Vector vTemp = new Vector();
	int iCount = 1;
	for(int i = 0; i < vRetResult.size(); i+=10){		
	%>
		<tr>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+2)%></td>								
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>		
			<td height="25" class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true)%> &nbsp; </td>
			<td class="thinborder" align="">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder" align=""><%=(String)vRetResult.elementAt(i+5)%></td>
			<%
			vTemp = (Vector)vRetResult.elementAt(i+8);
			if(vTemp == null)
				vTemp = new Vector();
			%>
			<td align="" valign="top" class="thinborder">
				<table width="100%" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
					<%for(int x = 0; x < vTemp.size(); x+=3){%>
					<tr>
						<td width="50%"><font size="1"><%=(String)vTemp.elementAt(x)%></font></td>
						<td width="20%"><font size="1"><%=(String)vTemp.elementAt(x+1)%></font></td>
						<td width="30%"><font size="1"><%=CommonUtil.formatFloat((String)vTemp.elementAt(x+2),true)%></font></td>		
									
					</tr>
					<%}%>
				</table>
			</td>
			<td class="thinborder" align="center">				
				<input type="checkbox" name="save_<%=iCount++%>" value="<%=(String)vRetResult.elementAt(i)%>"></td>	
		</tr>
		
	<%}%>
	<input type="hidden" name="item_count" value="<%=iCount%>" />
</table>
<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td align="center">
		<a href="javascript:UpdateFloatingOrders();"><img src="../../../images/save.gif" border="0" /></a>
			<font size="1">Click to update floating orders</font>
		</td>
	</tr>
</table>
<%}%>

	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable4"> 
		<tr bgcolor="#FFFFFF">
			<td height="25"></td>
		</tr> 
		<tr bgcolor="#A49A6A"> 
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	<input type="hidden" name="generate_report" />
	<input type="hidden" name="update_floating_orders" value=""  />
</form>		
</body>
</html>
<%
dbOP.cleanUP();
%>