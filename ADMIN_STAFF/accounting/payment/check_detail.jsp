<%@ page language="java" import="utility.*,java.util.Vector, Accounting.SalesPayment" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Check Detail</title>

<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../jscript/date-picker.js"></script>
<script language="javascript">

	function AddCheckDetail(){	
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.add_chk_dtl.value = "1";
		document.form_.submit();
	}

	function ReloadParentWnd() {
		if(document.form_.donot_call_close_wnd.value.length > 0)
			return;
		
		if(document.form_.close_wnd_called.value == "0") 
			window.opener.ReloadPageCheck(document.form_.check_csv.value);
	}
	
	function ReloadPage(){
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.reloadPage.value = "1";
		document.form_.submit();
	}
	
	function UpdateBanks() {
		var pgLoc = "check_banks.jsp?opner_form_name=form_";
		var win=window.open(pgLoc,"check_banks",'width=650,height=300,top=40,left=30,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	
	function DeleteFromCSV(index){
		document.form_.page_action.value = index;
		document.form_.donot_call_close_wnd.value = "1";
		document.form_.submit();
	}

</script>
</head>
<%
	DBOperation dbOP = null;
	String strTemp = null;
	String strErrMsg = null;
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else{
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-BILLING"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Customer-Sales","check_detail.jsp");
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
	
	SalesPayment sp = new SalesPayment();	
	String strCheckCSV = WI.fillTextValue("check_csv");
		
	if(WI.fillTextValue("add_chk_dtl").length() > 0){
		strTemp = sp.noteCheckPayment(dbOP, request);
		if(strTemp == null)
			strErrMsg = sp.getErrMsg();
		else{
			if(strCheckCSV.length() == 0)
				strCheckCSV = strTemp;
			else
				strCheckCSV += ", " + strTemp;
			
			strErrMsg = "Check detail noted.";
		}
	}
	
	Vector vRetResult = CommonUtil.convertCSVToVector(strCheckCSV);
	if(WI.fillTextValue("page_action").length() > 0){
		int iTemp = Integer.parseInt(WI.fillTextValue("page_action"));
		vRetResult.remove(iTemp);
		vRetResult.remove(iTemp);
		vRetResult.remove(iTemp);
		vRetResult.remove(iTemp);
		strErrMsg = "Check detail removed successfully.";
	}
	
	double dSum = 0d;
	if(vRetResult != null){
		for(int i = 0; i < vRetResult.size(); i += 4){
			dSum = dSum + Double.parseDouble((String)vRetResult.elementAt(i+2));
		}
	}
	
 %>
<body bgcolor="#D2AE72" topmargin="0" onUnload="ReloadParentWnd();">
<form name="form_" method="post" action="./check_detail.jsp">  
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">
				<div align="center"><strong><font color="#FFFFFF">::: PAYMENT  INFORMATION :::</font></strong></div></td>
	  	</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td colspan="2"><strong><i>Check Information</i></strong></td>
		</tr>
		<tr>
			<td width="3%" height="25">&nbsp;</td>
			<td width="17%">Bank :</td>
			<td width="80%">
				<%
					strTemp = " from fa_bank_list where is_valid = 1 and is_del = 0 order by bank_name asc ";
				%>
				<select name="bank_index">
					<option value="">Select Bank</option>
					<%=dbOP.loadCombo("bank_index","bank_name", strTemp, WI.fillTextValue("bank_index"), false)%>
				</select>
				
				<%if(iAccessLevel > 1){%>
					<a href="javascript:UpdateBanks();"><img src="../../../images/update.gif" border="0"/></a>
				<%}%></td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
			<td>Check #  :</td>
			<td>
				<input name="number" type="text" size="10"  maxlength="10" value="<%=WI.fillTextValue("number")%>" 
					class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"/></td>
		</tr>
		<tr>
          	<td height="25">&nbsp;</td>
		  	<td>Amount : </td>
		  	<td>
              	<input name="amount" type="text" size="16"  maxlength="12" 
			  		value="<%=ConversionTable.replaceString(WI.fillTextValue("amount"), ",", "")%>" 
					class="textbox" onblur="style.backgroundColor='white';AllowOnlyFloat('form_','amount')"
					onfocus="style.backgroundColor='#D3EBFF'" onkeyup="AllowOnlyFloat('form_','amount');"/></td>
	  	</tr>		
		<tr>
			<td height="25">&nbsp;</td>
			<td>Check Date: </td>
			<td>
				<input name="check_date" type="text" size="10" maxlength="10" readonly="yes" 
					value="<%=WI.getStrValue(WI.fillTextValue("check_date"), WI.getTodaysDate(1))%>" 
					class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" />
				&nbsp; 
				<a href="javascript:show_calendar('form_.check_date');" title="Click to select date" 
					onmouseover="window.status='Select date';return true;" onmouseout="window.status='';return true;">
				<img src="../../../images/calendar_new.gif" border="0" /></a></td>
	  	</tr>
		<tr>
			<td height="25">&nbsp;</td>
		    <td>Sum: </td>
		    <td><strong><%=CommonUtil.formatFloat(dSum, true)%></strong></td>
		</tr>
		<tr>
			<td colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="2" align="center">&nbsp;</td>
		    <td>
				<%if(iAccessLevel > 1){%>
					<input type="button" name="add" value=" Add Detail " onclick="javascript:AddCheckDetail();" 
						style="font-size:11px; height:26px;border: 1px solid #FF0000;" />
				<%}else{%>
					Not authorized to add check detail.
				<%}%>			</td>
		</tr>
		<tr>
			<td height="15" colspan="3">&nbsp;</td>
		</tr>
	</table>	
	
<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="5" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>LIST OF NOTED CHECK DETAILS </strong></div></td>
		</tr>
		<tr style="font-weight:bold">
			<td height="25" class="thinborder" width="10%" align="center">Count</td>
			<td width="30%" align="center" class="thinborder">Check # </td>
			<td width="30%" align="center" class="thinborder">Check Date</td>
			<td width="30%" align="center" class="thinborder">Amount</td>
		    <td width="30%" align="center" class="thinborder">Delete</td>
		</tr>
	<%	int iCount = 1;
		for(int i = 0; i < vRetResult.size(); i += 4, iCount++){%>
		<tr> 
			<td height="25" align="center" class="thinborder"><%=iCount%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
			<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
			<td class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+2), false)%></td>
		    <td align="center" class="thinborder"><a href="javascript:DeleteFromCSV('<%=i%>')">
				<img src="../../../images/delete.gif" border="0" /></a></td>
		</tr>
	<%}%>
	</table>
<%}%>
	
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="20" bgcolor="#A49A6A" colspan="3">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="check_csv" value="<%=CommonUtil.convertVectorToCSV(vRetResult)%>" />
	<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>">  	
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="reloadPage" value="0">
	<input type="hidden" name="add_chk_dtl" />
	<input type="hidden" name="page_action" />
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>