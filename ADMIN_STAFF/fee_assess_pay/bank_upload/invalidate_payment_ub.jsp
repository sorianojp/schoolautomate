<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null) {%>
		<p style="font-size:15px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000">
			You are already logged out. Please login again.
		</p>
	<%return;}
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
<script language="javascript">
	
	
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

   	/**
	var oRows = document.getElementById('myADTable1').getElementsByTagName('tr');
	var iRowCount = oRows.length;
	while(iRowCount > 0) {
		document.getElementById('myADTable1').deleteRow(0);
		--iRowCount;
	}
	**/
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);
   	document.getElementById('myADTable1').deleteRow(0);

   	document.getElementById('myADTable2').deleteRow(0);
   	
	document.getElementById('myADTable3').deleteRow(0);
   	document.getElementById('myADTable3').deleteRow(0);

   	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
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

boolean bolDelAllowed = false;
if(strSchCode.startsWith("FATIMA"))
	bolDelAllowed = true;

boolean bolIsUB = strSchCode.startsWith("UB");

%>
<body bgcolor="#D2AE72">
<form action="invalidate_payment_ub.jsp" method="post" name="form_">
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
		  <td>Bank</td>
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
				<%}%></td>
		</tr>
		<tr>
			<td height="15">&nbsp;</td>
		    <td height="15" colspan="2">
<%
int iDefLine = 50;%>
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
						</select>
						</td>
					</tr>
				</table>
			</td>
	    </tr>
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		  	<td><a href="javascript:SearchTemp();"><img src="../../../images/form_proceed.gif" border="0"></a>
				<font size="1">Click to search.</font></td>
	  	</tr>
	</table>
	
<%
double dTotalCollection = 0d;
if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myADTable2">
		<tr>
		  	<td style="font-size:9px" align="right">
		  		<a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>
	  			click to print
	  		</td>
	  </tr>
	</table>
<%
int iCount = 0;
int iRowCount = 1; 
for(int i = 0; i < vRetResult.size();){
	iRowCount = 0;
	if(i > 0) {%>
		<DIV style="page-break-before:always">&nbsp;</DIV>
	<%}%>
		<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>					
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
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
		<tr>
		  <td align="center" class="thinborder" width="4%"><strong>COUNT</strong></td>
			<td height="25" align="center" class="thinborder" width="13%"><strong>ID Number </strong></td>
		    <td align="center" class="thinborder" width="22%"><strong>Name</strong></td>
		    <td align="center" class="thinborder" width="15%"><strong>SY/Term</strong></td>
		    <td align="center" class="thinborder" width="12%"><strong>Date Paid</strong></td>
		    <td align="center" class="thinborder" width="10%"><strong>OR Number</strong> </td>
		    <td align="center" class="thinborder" width="13%"><strong>Amount</strong></td>
			<td align="center" class="thinborder" width="10%"><strong>Bank</strong></td>
			<td align="center" class="thinborder" width="10%"><font size="1"><strong>Created By</strong></font></td>
		</tr>
	<%	
		for(; i < vRetResult.size(); i += 14, ++iRowCount){
			if(iRowCount >= iDefLine)
				break;
				
				dTotalCollection += Double.parseDouble(ConversionTable.replaceString((String)vRetResult.elementAt(i+5), ",",""));
		%>
		<tr>
		  <td class="thinborder"><%=++iCount%></td>
			<td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+11)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+6)%>-<%=((String)vRetResult.elementAt(i+7)).substring(2)%>/
				<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+8))]%></td>
		    <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+13)%></td>
		    <td class="thinborder" align="right"><%=(String)vRetResult.elementAt(i+5)%>&nbsp;</td>
		    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+10))%></td>
		    <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+12))%></td>
		</tr>
	<%}%>
	</table>
<%}
}if(dTotalCollection > 0d) {%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr>
			<td width="100%" height="25" align="right" style="font-weight:bold">Total Collection: <%=CommonUtil.formatFloat(dTotalCollection, true)%></td>
		    <td width="0%" align="right" style="font-weight:bold"></td>
		</tr>
	</table>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>