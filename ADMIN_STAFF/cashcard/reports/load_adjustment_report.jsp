<%@ page language="java" import="utility.*,cashcard.ReportManagement,java.util.Vector"%>
<%
	WebInterface WI  = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Load Adjustment</title>
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js" ></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">
	function GenerateReport(){
		document.form_.generate_report.value = "1";
		document.form_.print_page.value = "";
		document.form_.submit();
	}
	function PrintPg(){			
		document.form_.print_page.value = "1";
		document.form_.submit();
	}
	
	function AjaxMapName() {
		var strCompleteName;
		strCompleteName = document.form_.stud_id.value;
		if(strCompleteName.length < 3)
			return;
		
		var objCOAInput;
		objCOAInput = document.getElementById("coa_info");
			
		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=-1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
	}
	
	function UpdateID(strID, strUserIndex) {
		/** do not do anything **/
		document.form_.stud_id.value = strID;
		this.ViewLedger();
	}
	
	function UpdateName(strFName, strMName, strLName) {
		//var strName = strLName.toUpperCase() +", "+strFName+" "+strMName.charAt(0);
		//document.form_.charge_to_name.value = strName;
	}
	
	function UpdateNameFormat(strName) {
		document.getElementById("coa_info").innerHTML = "";
	}

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./load_adjustment_report_print.jsp"></jsp:forward>	
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
								"Admin/staff-Cash Card-Reports","load_adjustment_report.jsp");	
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
	
	ReportManagement reportMgt = new ReportManagement();
	Vector vRetResult = null;
	if(WI.fillTextValue("generate_report").length() > 0){
		vRetResult = reportMgt.getLoadAdjustmentReport(dbOP, request);
		if(vRetResult == null)
			strErrMsg = reportMgt.getErrMsg();		
	}
%>		
<body bgcolor="#D2AE72">
<form name="form_" action="./load_adjustment_report.jsp" method="post">

	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable1">
		<tr bgcolor="#A49A6A">
			<td height="25" colspan="3" align="center"><font color="#FFFFFF">
				<strong>:::: LOAD ADJUSTMENT REPORT ::::</strong></font></td>
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
		   <td height="25">ID Number :</td>			
		   <td>
				<input name="stud_id" type="text" class="textbox" onfocus="style.backgroundColor='#D3EBFF'" 
					onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName();" value="<%=WI.fillTextValue("stud_id")%>" size="16">
					&nbsp;&nbsp;&nbsp;
				<label id="coa_info" style="width:300px; position:absolute"></label>
			</td>
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
	<%
	strTemp = " FOR " + WI.fillTextValue("date_fr") + WI.getStrValue(WI.fillTextValue("date_to")," TO ","","");
	%>
	<tr><td align="center"><strong>
		<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
		<%=SchoolInformation.getAddressLine1(dbOP,false,true)%><br>
		LOAD ADJUSTMENT REPORT<br><%=strTemp%>
	</strong></td></tr>
</table>
<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
	<tr>
		<td align="center" class="thinborder"><strong>Name</strong></td>
		<td width="15%" height="25" align="center" class="thinborder"><strong>Date</strong></td>		
		<td width="20%" align="center" class="thinborder"><strong>Debit</strong></td>
		<td width="20%" align="center" class="thinborder"><strong>Credit</strong></td>		
	</tr>
	<%
	String strDebit = null;
String strCredit = null;
String strUserIndex = "";
String strPrevUserIndex = "";
	for(int i = 0; i < vRetResult.size(); i+=7){
		strUserIndex = (String)vRetResult.elementAt(i);
	%>
		<tr>
		
			<%
			strTemp = "&nbsp;";
			if(!strPrevUserIndex.equals(strUserIndex))
				strTemp = (String)vRetResult.elementAt(i + 2)+WI.getStrValue((String)vRetResult.elementAt(i+1)," (",")","") + 
					WI.getStrValue((String)vRetResult.elementAt(i + 3), " - ", "", "");
			%>				
			<td class="thinborder"><%=strTemp%></td>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td> <!-- DATE -->
			<%
			strDebit = null;
			strCredit = null;
			
			strTemp = (String)vRetResult.elementAt(i + 6);
			if(strTemp.equals("1"))
				strDebit = (String)vRetResult.elementAt(i + 4);
			else
				strCredit = (String)vRetResult.elementAt(i + 4);
			%>
			<td class="thinborder" align="right"><%=WI.getStrValue(strDebit,"&nbsp;")%></td><!---DEBIT-->
			<td class="thinborder" align="right"><%=WI.getStrValue(strCredit,"&nbsp;")%></td><!---CREDIT--->
			
			
		</tr>
	<%
	strPrevUserIndex = strUserIndex;
	}%>
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