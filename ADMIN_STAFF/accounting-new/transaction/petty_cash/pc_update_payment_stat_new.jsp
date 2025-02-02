<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function PageAction(strAction) {
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}

function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}

function searchVoucher(strPCIndex,strTotalAmount) {
	var pgLoc = "./petty_cash_summary.jsp?opner_info=form_.voucher_no";
	var win=window.open(pgLoc,"SearchWindow",'width=700,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*, Accounting.Transaction,Accounting.JvCD, java.util.Vector"%>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	WebInterface WI = new WebInterface(request);
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");	

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-TRANSACTION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
								"Admin/staff-Payroll-DTR-DTR Entry (Manual)","pc_update_payment_stat_new.jsp");
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
		
	Transaction transaction = new Transaction();
	String strPageAction = WI.fillTextValue("page_action");
	String strProceedClicked = WI.getStrValue(WI.fillTextValue("proceedClicked"),"0");
	String strPCIndex = null;	
	Vector vRetResult = null;
	
	if(strPageAction.length() > 0){
	  if(transaction.operateOnPettyCashEntry(dbOP,request,Integer.parseInt(strPageAction)) == null){
	  	strErrMsg = transaction.getErrMsg();		
	  }	  
	  else
	  	strErrMsg = "Status updated successfully.";
	}
	
int iVoucherType = 0;//0 = jv, 1 = cd, 2 = petty cash.
Vector vJVDetail  = null; //to show detail at bottom of page. 
Vector vJVInfo    = null;
Vector vGroupInfo = null;

String strPCNumber = WI.fillTextValue("voucher_no");

if(strPCNumber.length() > 0) {
	JvCD jvCD = new JvCD();
	vJVDetail = jvCD.viewDetailJV(dbOP, strPCNumber);
	if(vJVDetail == null)
		strErrMsg = jvCD.getErrMsg();
	else {
	    vJVInfo    = (Vector)vJVDetail.remove(0);//[0]=JV_INDEX,[1]=JV_DATE, [2] = jv_type, [3] = is_cd,[4] lock_date, [5] = payee name.
	    vGroupInfo = (Vector)vJVDetail.remove(0);//[0]=group number, [1]=Explanation, [2]=remarks.
    	vJVDetail  = (Vector)vJVDetail.remove(0);//[0]=coa_number,[1]=PARTICULAR,[2]=AMOUNT,[3]=GROUP_NUMBER,[4]=is_debit
	
		strPCIndex = (String)vJVInfo.elementAt(0);
		
		iVoucherType = Integer.parseInt((String)vJVInfo.elementAt(3));
		if(iVoucherType != 2) {
			strErrMsg = "Petty cash voucher number not found.";
			vJVDetail = null;
		}
	}
}
else 
	strErrMsg = "Please enter voucher number";

boolean bolIsStatusUpdated = false;
String strDateGivenInfo    = null;
if(vJVInfo != null) {
	strDateGivenInfo = "select date_given from ac_pc_voucher where pc_index = "+strPCIndex+" and pc_voucher_stat = 1";
	strDateGivenInfo = dbOP.getResultOfAQuery(strDateGivenInfo,0);
	if(strDateGivenInfo != null) {
		bolIsStatusUpdated = true;
		strDateGivenInfo = strDateGivenInfo.substring(0,11);
	}
}	
%>
<form name="form_" method="post" action="./pc_update_payment_stat_new.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          PETTY CASH VOUCHER - UPDATE PAYMENT RECEIVED STATUS PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:13px; color:#FF0000; font-weight:bold"><a href="petty_cash.jsp"><img src="../../../../images/go_back.gif" border="0"></a>&nbsp; 
        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="15%">Voucher No.</td>
      <td width="18%"><input name="voucher_no" type="text" size="16" value="<%=WI.fillTextValue("voucher_no")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly>      </td>
      <td width="9%"><font size="1"><a href="javascript:searchVoucher();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></font></td>
      <td width="54%"><font size="1"><a href="javascript:ProceedClicked();"><img src="../../../../images/form_proceed.gif" border="0"></a></font></td>
    </tr>
     <tr>
      <td height="26">&nbsp;</td>
      <td>Pending Voucher </td>
      <td colspan="3">
	  <table cellpadding="0" cellspacing="0" class="thinborder" width="90%">
<%
java.sql.ResultSet rs = dbOP.executeQuery("select VOUCHER_NO from AC_PC_VOUCHER where PC_VOUCHER_STAT = 0 order by voucher_no");
while(rs.next()) {%>
		  	<tr>
				<td class="thinborder" width="50%"><a href="./pc_update_payment_stat_new.jsp?proceedClicked=1&voucher_no=<%=rs.getString(1)%>"><%=rs.getString(1)%></a></td>
				<td class="thinborder" width="50%">
					<%if(rs.next()){%>
						<a href="./pc_update_payment_stat_new.jsp?proceedClicked=1&voucher_no=<%=rs.getString(1)%>"><%=rs.getString(1)%></a>
					<%}else{%>&nbsp;<%}%>			  </td>
			</tr>
<%}
rs.close();
%>		
		</table>	  </td>
    </tr>
   <tr> 
      <td height="10" colspan="5"><hr size="1"></td>
    </tr>
  </table>
<%if(vJVDetail != null && vJVDetail.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td style="font-size:13px; font-weight:bold" width="3%">&nbsp;</td> 
      <td height="25" style="font-size:13px; font-weight:bold" width="67%"><u>DEBIT</u></td>
      <td style="font-size:13px; font-weight:bold" width="15%">&nbsp;</td>
      <td style="font-size:11px;" width="15%" align="right">Amount&nbsp;&nbsp;</td>
    </tr>
<%boolean bolPrintGroup = false;
String strBGRed = null;
for(int i =0; i < vGroupInfo.size(); i += 4){
	if(vGroupInfo.elementAt(i + 3).equals("0") && vJVInfo.elementAt(3).equals("0"))//coloring is for jv only , for cd - none.
		strBGRed = " bgcolor=red";
	else	
		strBGRed = "";
	strTemp = (String)vGroupInfo.elementAt(i);//group number;
	bolPrintGroup = true;%>
	<%for(int p = 0; p < vJVDetail.size(); p += 5) {
		if(!vJVDetail.elementAt(p + 3).equals(strTemp) )
			continue;
		if(vJVDetail.elementAt(p + 4).equals("0"))//if not debit or if not belong to same group.. continue.
			continue;%>
    <tr<%=strBGRed%>>
      <td style="font-size:11px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>. 
      <%}%></td>
      <td height="25" style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(p + 1)%></td>
      <td style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(p + 0)%></td>
      <td style="font-size:11px;" align="right" valign="top"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(p + 2), true)%>&nbsp;</td>
    </tr>
	<%vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	vJVDetail.removeElementAt(p);vJVDetail.removeElementAt(p);
	p -= 5;}//end of while loop. 
}//end of for loop to print all debit.%>
    <tr>
      <td height="10" colspan="4" style="font-size:11px;"><hr size="1"></td>
    </tr>
    <tr>
      <td style="font-size:13px; font-weight:bold">&nbsp;</td> 
      <td height="25" style="font-size:13px; font-weight:bold"><u>CREDIT</u></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
<%
for(int i =0; i < vGroupInfo.size(); i += 4){
	if(vGroupInfo.elementAt(i + 3).equals("0") && vJVInfo.elementAt(3).equals("0") )//coloring is for jv only , for cd - none.
		strBGRed = " bgcolor=red";
	else	
		strBGRed = "";
	strTemp = (String)vGroupInfo.elementAt(i);//group number;
	bolPrintGroup = true;%>
	<%while(vJVDetail.size() > 0) {
		if(!vJVDetail.elementAt(3).equals(strTemp))//if not belong to same group.. break.
			break;%>
    <tr<%=strBGRed%>>
      <td style="font-size:11px;" valign="top"><%if(bolPrintGroup){bolPrintGroup = false;%><%=strTemp%>.<%}%></td>
      <td height="25" style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(1)%></td>
      <td style="font-size:11px;" valign="top"><%=vJVDetail.elementAt(0)%></td>
      <td style="font-size:11px;" align="right" valign="top"><%=CommonUtil.formatFloat((String)vJVDetail.elementAt(2), true)%>&nbsp;</td>
    </tr>
	<%
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);
	vJVDetail.removeElementAt(0);vJVDetail.removeElementAt(0);}//end of while loop. 
}//end of for loop to print all debit.%>

    <tr>
      <td height="10" colspan="4" style="font-size:11px;"><hr size="1"></td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:11px;">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:11px;">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="4" style="font-size:13px; font-weight:bold"><u>EXPLANATION</u></td>
    </tr>
<%
for(int i =0; i < vGroupInfo.size(); i += 4){%>
    <tr>
      <td style="font-size:11px;" valign="top"><%=vGroupInfo.elementAt(i)%>.</td>
      <td height="25" colspan="3" valign="top"><%=vGroupInfo.elementAt(i + 1)%></td>
    </tr>
<%}%>
    <tr>
      <td height="10" colspan="4" style="font-size:11px;"><hr size="1"></td>
    </tr>
  </table>


  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
<%if(!bolIsStatusUpdated){%>
    <tr> 
      <td width="4%" height="50">&nbsp;</td>
      <td width="14%">&nbsp;</td>
      <td width="26%">Status : 
        <%
			strTemp = WI.fillTextValue("voucher_stat");
		%> <select name="voucher_stat">
          <!--<option value="0">Payment Still in Cashier</option>-->
          <%if(strTemp.equals("1")){%>
          <option value="1" selected>Payment Given to Payee </option>
          <%}else{%>
          <option value="1">Payment Given to Payee </option>
          <%}%>
        </select> </td>
      <td width="56%">Date Payment Given to Payee : 
	  	<%	
			if(WI.fillTextValue("date_given").length() > 0)
				strTemp = WI.fillTextValue("date_given");
			else
				strTemp = WI.getTodaysDate(1);
		%>
        <input name="date_given" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
        <a href="javascript:show_calendar('form_.date_given');" title="Click to select date" 
		onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        <img src="../../../../images/calendar_new.gif" border="0"></a></td>
    </tr>
<%}//show only if not yet given to payee.%>
    <tr> 
      <td height="50" colspan="4"> <div align="center"> 
          <%if(!bolIsStatusUpdated){%>
          <a href="javascript:PageAction(5,'');"><img src="../../../../images/save.gif" border="0"></a> 
          <font size="1">click to save update</font> 
          <a href="pc_update_payment_stat_new.jsp"><img src="../../../../images/cancel.gif" border="0"></a> 
          <font size="1">click to cancel/clear update</font>
		  <%}else{%>
		  	<font style="font-size:14px; color:#FF0000">Already updated . Date given : <%=strDateGivenInfo%>.</font>
		  <%}%>	  
	   </div></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2"><div align="left"></div></td>
    </tr>
  </table>
  <%}// end if strProceedClicked == 1%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25"><div align="left"></div></td>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="2" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=strPCIndex%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="proceedClicked" value="<%=WI.fillTextValue("proceedClicked")%>">	

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>