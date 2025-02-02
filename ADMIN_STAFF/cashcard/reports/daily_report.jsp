<%@ page language="java" import="utility.*,cashcard.CardManagement,java.util.Vector"%>
<%
	WebInterface WI  = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Daily Report</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	
	function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objInput = document.getElementById("emp_id_");
		
		if(strCompleteName.length <=2) {
			objInput.innerHTML = "";
			return ;
		}
		this.InitXmlHttpObject(objInput, 2);//I want to get innerHTML in this.retObj
			if(this.xmlHttp == null) {
				alert("Failed to init xmlHttp.");
				return;
			}
			
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);
		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		document.form_.emp_id.value = strID;
		document.getElementById("emp_id_").innerHTML = "";
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//do nothing.
	}
	
	function UpdateNameFormat(strName) {
		//do nothing.
	}
	
	function GenerateReport(){
		document.form_.print_page.value ="";
		document.form_.generate_report.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.print_page.value ="";
		document.form_.submit();
	}
	
	function PrintPg(){
/*
	document.bgColor = "#FFFFFF";

	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	document.getElementById("myADTable1").deleteRow(0);
	
	document.getElementById("myADTable2").deleteRow(0);
	
	document.getElementById("myADTable3").deleteRow(0);
	document.getElementById("myADTable3").deleteRow(0);
	
	document.getElementById("myADTable4").deleteRow(0);
	document.getElementById("myADTable4").deleteRow(0);

	window.print();
*/
	document.form_.print_page.value ="1";
	document.form_.submit();
}

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./daily_report_print.jsp"></jsp:forward>	
<%	return;}
	
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
								"Admin/staff-Cash Card-Reports","daily_report.jsp");	
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
	
	int iSearchResult = 0;
	Vector vRetResult = null;
	CardManagement cm = new CardManagement();
	
	if(WI.fillTextValue("generate_report").length() > 0){
		vRetResult = cm.generateDailyReport(dbOP, request);
		if(vRetResult == null)
			strErrMsg = cm.getErrMsg();
		else
			iSearchResult = cm.getSearchCount();
	}
%>		
<body bgcolor="#D2AE72">
<form name="form_" action="./daily_report.jsp" method="post">

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable1">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" align="center"><font color="#FFFFFF">
				<strong>:::: GENERATE DAILY REPORT ::::</strong></font></td>
		</tr>		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="3"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
		
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Transaction Date: </td>
			<td width="80%">			
				<input name="date_fr" type="text" size="10" maxlength="10" readonly="yes" value="<%=WI.fillTextValue("date_fr")%>" 
					class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_fr');" title="Click to select date" 
		  			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a></td>
		</tr>
		<tr>
		  	<td height="25">&nbsp;</td>
		  	<td>Cashier:</td>
		  	<td>
				<input name="emp_id" type="text" class="textbox" size="16" value="<%=WI.fillTextValue("emp_id")%>" 
					onKeyUp="AjaxMapName();" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				&nbsp;&nbsp;&nbsp;
				<label id="emp_id_" style="font-size:11px;position:absolute;width:300px"></label></td>
	  	</tr>
		<tr>
			<td colspan="2" height="22">&nbsp;</td>
			<%
			strTemp = WI.fillTextValue("view_all");
			if(strTemp.equals("1"))
				strTemp = "checked";
			else
				strTemp = "";
			%>
			<td>
				<input type="checkbox" name="view_all" value="1" <%=strTemp%> onclick="GenerateReport();"/>View All
			</td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="javascript:GenerateReport();"><img src="../../../images/form_proceed.gif" border="0" /></a>
				<font size="1">Click to generate daily report.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable2">
	<tr><td align="right">
	 Rows Per Page: 
	  <select name="rows_per_pg">
<%
int iDefVal = 26;
if(WI.fillTextValue("rows_per_pg").length() > 0) 
	iDefVal = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
for(int i =25; i < 60; ++i) {
	if(iDefVal == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>
	  <option value="<%=i%>" <%=strTemp%>><%=i%></option>
<%}%>
	  </select>
	  &nbsp;&nbsp;&nbsp;
	<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0" /></a>
		<font size="1">Click to print report</font>
	</td></tr>
	<tr><td align="center"><strong>
		<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
		<%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
		CASH CARD DAILY REPORT <%=WI.fillTextValue("date_fr")%>
	</strong></td></tr>
</table>
	<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF" id="myADTable3">
		<tr> 
		  	<td height="20" colspan="7" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: LIST OF TERMINAL TRANSACTIONS ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOMLEFT" colspan="4">
				<strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=WI.getStrValue(cm.getDisplayRange(), ""+iSearchResult)%></strong>)</strong></td>
			<td height="25" colspan="3" class="thinborderBOTTOM">
			<%
				int iPageCount = 1;
				if(cm.defSearchSize > 0){
					iPageCount = iSearchResult/cm.defSearchSize;		
					if(iSearchResult % cm.defSearchSize > 0)
						++iPageCount;
				}
				
				strTemp = " - Showing("+cm.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto" onChange="GenerateReport();">
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
		  		<%}%></td>
		</tr>
		<tr> 
			<td height="25" width="12%" align="center" class="thinborder"><strong>ID Number </strong></td> 
			<td width="20%" align="center" class="thinborder"><strong>Name</strong></td> 
			<td width="12%" align="center" class="thinborder"><strong>Reference # </strong></td> 
			<td width="20%" align="center" class="thinborder"><strong>Particulars</strong></td> 
			<td width="12%" align="center" class="thinborder"><strong>Posted by </strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Transaction Date </strong></td>
			<td width="12%" align="center" class="thinborder"><strong>Amount</strong></td>
		</tr>
	<%for(int i = 0; i < vRetResult.size(); i += 10){%>
		<tr> 
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
			<td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), 4)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+5)%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i+9), " (", ")", "")%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%></td>
			<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
			<td align="right" class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+8), true)%>&nbsp;</td>
		</tr>
	<%}%>
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
	<input type="hidden" name="print_page" />
</form>		
</body>
</html>
<%
dbOP.cleanUP();
%>