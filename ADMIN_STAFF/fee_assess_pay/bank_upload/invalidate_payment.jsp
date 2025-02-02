<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null) {%>
		<p style="font-size:15px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
			You are already logged out. Please login again.
		</p>
	<%return;}
	if(strSchCode.startsWith("UB")) {
		response.sendRedirect("./invalidate_payment_ub.jsp");
		return;
	}
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Non-Posting Payments Mgmt</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript">
	
	function checkAllSave() {
		var maxDisp = document.form_.max_count.value;
		var bolIsSelAll = document.form_.selAllSave.checked;
		for(var i =0; i< maxDisp; ++i)
			eval('document.form_.invalidate_'+i+'.checked='+bolIsSelAll);
	}
	
	function DeletePayments(){
		document.form_.search_temp.value = "1";
		document.form_.delete_payments.value = "1";
		document.form_.submit();
	}
	
	function SearchTemp(){
		document.form_.search_temp.value = "1";
		document.form_.submit();
	}
	
	function ReloadPage(){
		document.form_.search_temp.value = "";
		document.form_.submit();
	}
function PrintPg() {
	document.bgColor = "#FFFFFF";

   	var oRows = document.getElementById('myADTable1').getElementsByTagName('tr');
	var iRowCount = oRows.length;
	while(iRowCount > 0) {
		document.getElementById('myADTable1').deleteRow(0);
		--iRowCount;
	}

   	document.getElementById('myADTable2').deleteRow(0);
   	
	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
//  about ajax - to display student list with same name.
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation();
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
boolean bolDelAllowed = false;
if(strSchCode.startsWith("FATIMA"))
	bolDelAllowed = true;
int iAccessLevel = 0;
CommonUtil comUtil = new CommonUtil();

	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","PAYMENT",request.getRemoteAddr(), null);
	if(iAccessLevel == 0) 
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","BANK UPLOAD",request.getRemoteAddr(), null);											
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Fee Assessment & Payments","VIEW BANK UPLOAD",request.getRemoteAddr(), null);
		bolDelAllowed = false;
	}											
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

	if(WI.fillTextValue("show_report").length() > 0) 
		bolDelAllowed = false;
		
	
	Vector vRetResult = null;
	String[] astrSemester = {"Summer", "1st Sem", "2nd Sem", "3rd Sem"};
	BankPosting bp = new BankPosting();	
	
	if(WI.fillTextValue("search_temp").length() > 0){
		
		if(WI.fillTextValue("delete_payments").length() > 0){
			if(!bp.invalidateBankUploadPayments(dbOP, request))
				strErrMsg = bp.getErrMsg();
			else
				strErrMsg = "Operation successful.";
		}
		
		vRetResult = bp.getPaymentsToInvalidate(dbOP, request);
		if(vRetResult == null && WI.fillTextValue("delete_payments").length() == 0)
			strErrMsg = bp.getErrMsg();
		
	}


boolean bolIsUB = strSchCode.startsWith("UB");

%>
<body bgcolor="#D2AE72">
<form action="invalidate_payment.jsp" method="post" name="form_">
	<table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
		<tr bgcolor="#A49A6A" >
			<td height="25" colspan="3">
				<div align="center"><font color="#FFFFFF"><strong>:::: PAYMENT INVALIDATION PAGE ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Posted by: </td>
		  <td><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
	  <label id="coa_info" style="position:absolute; width:350px;"></label>
	  </td>
	  </tr>
<%if(strSchCode.startsWith("FATIMA") || strSchCode.startsWith("UB")){%>
		<tr>
		  <td height="25">&nbsp;</td>
		  <td>Bank:</td>
		  <td>
				<select name="bank_index" onChange="ReloadPage();">
					<option value="">All Banks</option>
					<%if(strSchCode.startsWith("CIT") || strSchCode.startsWith("UB")){%>
						<%=dbOP.loadCombo("bank_index","bank_name, bank_code"," from fa_bank_list where is_used_bank_post = 1 order by bank_name", WI.fillTextValue("bank_index"), false)%>
					<%}else{%>
						<%=dbOP.loadCombo("bank_index","bank_name, bank_code"," from fa_upload_bank_list order by bank_name", WI.fillTextValue("bank_index"), false)%>
					<%}%>
          		</select>		  </td>
	  </tr>
<%}%>	  
		<tr>
			<td height="25">&nbsp;</td>
			<td>Payment Type: </td>
		    <td>
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("payment_type"), "1");
					if(strTemp.equals("1")){
						strTemp = "checked";
						strErrMsg = "";
					}
					else{
						strTemp = "";
						strErrMsg = "checked";
					}
				%>
				<input type="radio" name="payment_type" value="1" <%=strTemp%> onChange="ReloadPage();">Permanent
<%if(!bolIsUB){%>
				<input type="radio" name="payment_type" value="2" <%=strErrMsg%> onChange="ReloadPage();">Temporary</td>
<%}%>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td width="17%">Date Paid: </td>
		    <td width="80%">
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
				%>
				<select name="date_type" onChange="ReloadPage();">
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
				<%
					strTemp = WI.getStrValue(WI.fillTextValue("date_type"), "1");
					if(strTemp.equals("2")){
				%>
				to 
				<input name="date_to" type="text" size="10" maxlength="10" readonly="yes" class="textbox" 
					value="<%=WI.fillTextValue("date_to")%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				<a href="javascript:show_calendar('form_.date_to');" title="Click to select date" 
					onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0"></a>
				<%}%>
				
				<%if(strSchCode.startsWith("FATIMA")){%>
					  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					  <font size="1" style="font-weight:bold; color:#0000FF"><input type="checkbox" name="only_manual_post" value="checked" <%=WI.fillTextValue("only_manual_post")%>>
					  Show Only Manual Posting </font>	
					    
					  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					  <font size="1" style="font-weight:bold; color:#0000FF"><input type="checkbox" name="only_auto_post" value="checked" <%=WI.fillTextValue("only_auto_post")%>>
					  Show Only Uploads </font>	
					    
					  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					  <font size="1" style="font-weight:bold; color:#0000FF"><input type="checkbox" name="create_date" value="checked" <%=WI.fillTextValue("create_date")%>>
					  Consider Create Date </font>	  
				<%}%>

				
		  </td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		    <td height="15" colspan="2">
<%
int iDefLine = 50;
if(bolIsUB) {%>
				<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborderALL" bgcolor="#CCCCCC">
					<tr>
						<td width="50%" style="font-size:11px">Sort By: 
							<select name="sort_by" style="background:#cccccc">
							<%
							strTemp = WI.fillTextValue("sort_by");
							if(strTemp.equals("1"))
								strErrMsg = " selected";
							else	
								strErrMsg = "";
							%>
									<option value="1" <%=strErrMsg%>>Date Paid</option>
							<%
							if(strTemp.equals("2"))
								strErrMsg = " selected";
							else	
								strErrMsg = "";
							%>
								<option value="2" <%=strErrMsg%>>OR Number</option>
							</select>						</td>
					    <td width="50%">Rows Per Page: <select name="rows_per_page" style="background:#cccccc">
						<%
						if(WI.fillTextValue("rows_per_page").length() > 0) 
							iDefLine = Integer.parseInt(WI.fillTextValue("rows_per_page"));
						else
							iDefLine = 50;
							
						for(int i = 40; i < 80; ++i) {
							if(iDefLine == i)
								strErrMsg = " selected";
							else	
								strErrMsg = "";
						%>
						<option value="<%=i%>" <%=strErrMsg%>><%=i%></option>
						<%}%>
						</select>						</td>
					</tr>
				</table>
<%}%>			</td>
	    </tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		  	<td><a href="javascript:SearchTemp();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to search.</font></td>
	  	</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
<%if(bolDelAllowed) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="15" colspan="3"><hr size="1"></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td width="17%">Reason: </td>
			<td width="80%">
				<textarea name="reason" style="font-size:12px" cols="80" rows="3" class="textbox" 
					onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.fillTextValue("reason")%></textarea></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
			<td><a href="javascript:DeletePayments();"><img src="../../../images/delete.gif" border="0"></a>
				<font size="1">Click to invalidate payments payments.</font></td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>
<%}%>
<%if(bolIsUB || WI.fillTextValue("show_report").length() > 0) {%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable2">
		<tr>
		  	<td style="font-size:9px" align="right">
		  		<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  			click to print
	  		</td>
	  </tr>
		<tr>					
			<!--<td width="20%" align="right"><img src="../../../images/logo/<%=strSchCode%>.gif" width="75" height="75"></td>-->
			<td align="center" style="font-weight:bold; font-size:14px">
				<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
				<font style="font-size:9px; font-weight:normal"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%>	</font>			</td>					
		</tr>
		<tr>
			<td align="center" height="40" valign="middle"><strong>BANK COLLECTION REPORT</strong><br>
			<font style="font-size:9px; font-weight:normal">
				Date: <%=WI.fillTextValue("date_fr")%> <%=WI.getStrValue(WI.fillTextValue("date_to"), " to ", "", "")%>			</font>			</td>
		</tr>
	</table>
<%}else{%>		
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
		  	<td height="20" bgcolor="#B9B292" class="thinborderTOPLEFTRIGHT">
				<div align="center"><strong>::: SEARCH RESULT :::</strong></div></td>
		</tr>
	</table>
<%}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
			<td height="25" align="center" class="thinborder" width="13%" style="font-size:9px;"><strong>ID Number </strong></td>
		    <td align="center" class="thinborder" width="22%" style="font-size:9px;"><strong>Name</strong></td>
		    <td align="center" class="thinborder" width="15%" style="font-size:9px;"><strong>SY/Term</strong></td>
		    <td align="center" class="thinborder" width="12%" style="font-size:9px;"><strong>Date Paid</strong></td>
		    <td align="center" class="thinborder" width="10%" style="font-size:9px;"><strong>OR Number</strong> </td>
		    <td align="center" class="thinborder" width="13%" style="font-size:9px;"><strong>Amount</strong></td>
			<td align="center" class="thinborder" width="10%" style="font-size:9px;"><strong>Bank</strong></td>
			<td align="center" class="thinborder" width="10%"><font size="1"><strong>Created By</strong></font></td>
<%if(bolDelAllowed) {%>
			<td align="center" class="thinborder" width="5%"><font size="1"><strong>Select All<br></strong><input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();"></font></td>
<%}%>
		</tr>
	<%	int iCount = 0;
	String strBGColor = null;
		for(int i = 0; i < vRetResult.size(); i += 14, iCount++){
			if(((String)vRetResult.elementAt(i+4)).indexOf("<br>") > -1)
				strBGColor = " bgcolor='#cccccc'";
			else	
				strBGColor = "";
		%>
		<tr<%=strBGColor%>>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+11)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%>-<%=((String)vRetResult.elementAt(i+7)).substring(2)%>/
				<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+8))]%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+13)%></td>
		    <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i+5)%>&nbsp;</td>
		    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+10))%></td>
		    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+12))%></td>
<%if(bolDelAllowed) {%>
		    <td align="center" class="thinborder"><input type="checkbox" name="invalidate_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>"></td>
<%}%>
		</tr>
	<%}%>
	</table>
	<input type="hidden" name="max_count" value="<%=iCount%>">
<%}%>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable3">
		<tr>
			<td height="25">&nbsp;</td>
		</tr>
		<tr bgcolor="#A49A6A">
			<td height="25">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="delete_payments">
	<input type="hidden" name="search_temp">
	<input type="hidden" name="show_report" value="<%=WI.fillTextValue("show_report")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>