<%@ page language="java" import="utility.*,Accounting.Transaction,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements())
		strFormName = strToken.nextToken();		
	
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language='JavaScript'>

function ProceedClicked(){
	document.form_.proceedClicked.value = "1";
	this.SubmitOnce('form_');
}

function ReloadPage(){	    
 	this.SubmitOnce('form_');
}

function PrintPage(){
	this.SubmitOnce('form_');
}
<%
if(WI.fillTextValue("opner_info").length() > 0){%>
function CopyID(strID)
{
	window.opener.document.<%=strFormName%>.proceedClicked.value=1;
	window.opener.document.<%=WI.fillTextValue("opner_info")%>.value=strID;	
	window.opener.focus();
	<%
	if(strFormName != null){%>	
	window.opener.document.<%=strFormName%>.submit();	
	<%}%>	
	self.close();
}
<%}%>

function UpdatePettyCash(strVoucherNo) {
	var pgLoc = "./petty_cash_encode.jsp?from_main=1&proceedClicked=1&voucher_no="+strVoucherNo;
	var win=window.open(pgLoc,"EncodePettyCash",'width=600,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewPettyCash(strVoucherNo) {
	var pgLoc = "./petty_cash_view_dtls.jsp?proceedClicked=1&voucher_no="+strVoucherNo;
	var win=window.open(pgLoc,"ViewPettyCash",'width=650,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function printVoucher(strVoucherNo){
	var pgLoc = "./petty_cash_print.jsp?proceedClicked=1&voucher_no="+strVoucherNo;
	var win=window.open(pgLoc,"PrintPettyCash",'width=650,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#D2AE72">
<%
	String strErrMsg = null;
	String strTemp = null;
 	
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
								"Admin/staff-ACCOUNTING-TRANSACTION-Petty Cash","petty_cash_summary.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
 	}//end of authenticaion code.
	
	Transaction PCV = new Transaction();

	Vector vRetResult = null;
	int i = 0;
	int iSearch = 0;
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	String[] astrSortByName    = {"Voucher No.","Voucher Date","Payee Name","Receive Cash Date"};
	String[] astrSortByVal     = {"voucher_no","voucher_date","payee_name","date_given"};	
	String[] astrDateOption = {"Specific Date","Date Range","Year"};	
	String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
								"September","October","November","December"};
	if (WI.fillTextValue("proceedClicked").length() > 0){
	  vRetResult = PCV.searchPettyCashSummary(dbOP,request);
	  if(vRetResult == null || vRetResult.size() == 0){
	  	strErrMsg = PCV.getErrMsg();
	  }else{
	  	iSearch = PCV.getSearchCount();
	  }
	}
								
%>
<form name="form_" method="post" action="petty_cash_summary.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          SEARCH PETTY CASH VOUCHER(S) PAGE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" style="font-size:13px; color:#FF0000; font-weight:bold">
	  <%if(WI.fillTextValue("opner_info").length() == 0) {%>
	  <a href="petty_cash.jsp"><img src="../../../../images/go_back.gif" border="0"></a>
	  <%}%>
	  &nbsp; 
        &nbsp;&nbsp; <%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="24%">Payee Name</td>
      <td colspan="4"> <select name="payee_select">
          <%=PCV.constructGenericDropList(WI.fillTextValue("payee_select"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  <input type="text" name="payee" class="textbox" value="<%=WI.fillTextValue("payee")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">      </td>
    </tr>

    <tr> 
      <td height="26">&nbsp;</td>
      <td height="25">Voucher No.</td>
      <td colspan="4"> <select name="voucher_no_select">
          <%=PCV.constructGenericDropList(WI.fillTextValue("voucher_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  <input type="text" name="voucher_no" class="textbox" value="<%=WI.fillTextValue("voucher_no")%>"
	  	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
<!--
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Requisition No.</td>
      <td colspan="4"> <select name="req_no_select">
          <%=PCV.constructGenericDropList(WI.fillTextValue("req_no_select"),astrDropListEqual,astrDropListValEqual)%> </select> 
		  <input type="text" name="req_no" class="textbox" value="<%=WI.fillTextValue("req_no")%>"
	      onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
-->    <tr> 
      <td height="26">&nbsp;</td>
      <td>Petty Cash Voucher Status</td>
      <td colspan="4"><select name="pc_voucher_stat">
          <option value="">All</option>
          <%if(WI.fillTextValue("pc_voucher_stat").equals("0")){%>
          <option value="0" selected>Payment Still in Cashier</option>
          <option value="1">Payment given to payee</option>
          <%}else if(WI.fillTextValue("pc_voucher_stat").equals("1")){%>
          <option value="0">Payment Still in Cashier</option>
          <option value="1" selected>Payment given to payee</option>
          <%}else{%>
          <option value="0">Payment Still in Cashier</option>
          <option value="1">Payment given to payee</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Voucher Date </td>
      <td colspan="4"> <%
		strTemp = WI.fillTextValue("voucher_option");
	  %> <select name="voucher_option" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if(strTemp.equals("0")){%>
          <option value="0" selected><%=astrDateOption[0]%></option>
          <option value="1"><%=astrDateOption[1]%></option>
          <option value="2"><%=astrDateOption[2]%></option>
          <%}else if(strTemp.equals("1")){%>
          <option value="0"><%=astrDateOption[0]%></option>
          <option value="1" selected><%=astrDateOption[1]%></option>
          <option value="2"><%=astrDateOption[2]%></option>
          <%}else if (strTemp.equals("2")){%>
          <option value="0"><%=astrDateOption[0]%></option>
          <option value="1"><%=astrDateOption[1]%></option>
          <option value="2" selected><%=astrDateOption[2]%></option>
          <%}else{%>
          <option value="0"><%=astrDateOption[0]%></option>
          <option value="1"><%=astrDateOption[1]%></option>
          <option value="2"><%=astrDateOption[2]%></option>
          <%}%>
        </select></td>
    </tr>
    <%if(WI.fillTextValue("voucher_option").length() > 0){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td colspan="4"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
          <%if(WI.fillTextValue("voucher_option").equals("1")){%>
          <tr> 
            <td> <%strTemp = WI.fillTextValue("voucher_date_fr");%> <input name="voucher_date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
              <a href="javascript:show_calendar('form_.voucher_date_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
              <img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              to 
              <%strTemp = WI.fillTextValue("voucher_date_to");%> <input name="voucher_date_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
              <a href="javascript:show_calendar('form_.voucher_date_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
              <img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>            </td>
          </tr>
          <%}else if(WI.fillTextValue("voucher_option").equals("2")){%>
          <tr> 
            <td> <select name="voucher_year" onChange="ReloadPage();">
                <%=dbOP.loadComboYear(WI.fillTextValue("voucher_year"),2,1)%> </select> <%
				strTemp = WI.fillTextValue("voucher_month");
			  %> <select name="voucher_month">
                <option value="">All</option>
                <%for(i = 0; i < 12; ++i){%>
                <%if(strTemp.equals(Integer.toString(i+1))){%>
                <option value="<%=i+1%>" selected><%=astrConvertMonth[i]%></option>
                <%}else{%>
                <option value="<%=i+1%>"><%=astrConvertMonth[i]%></option>
                <%}%>
                <%}%>
              </select></td>
          </tr>
          <%}else if(WI.fillTextValue("voucher_option").equals("0")){%>
          <tr> 
            <td> <%strTemp = WI.fillTextValue("voucher_date_fr");%> <input name="voucher_date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
			 onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
              <a href="javascript:show_calendar('form_.voucher_date_fr');" title="Click to select date" 
			  onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
              <img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>            </td>
          </tr>
          <%}%>
        </table></td>
    </tr>
    <%}%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26" valign="bottom">Received Payment Date </td>
      <%
		strTemp = WI.fillTextValue("receive_option");
	  %>
      <td height="26" colspan="4" valign="bottom"> <select name="receive_option" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if(strTemp.equals("0")){%>
          <option value="0" selected><%=astrDateOption[0]%></option>
          <option value="1"><%=astrDateOption[1]%></option>
          <option value="2"><%=astrDateOption[2]%></option>
          <%}else if(strTemp.equals("1")){%>
          <option value="0"><%=astrDateOption[0]%></option>
          <option value="1" selected><%=astrDateOption[1]%></option>
          <option value="2"><%=astrDateOption[2]%></option>
          <%}else if (strTemp.equals("2")){%>
          <option value="0"><%=astrDateOption[0]%></option>
          <option value="1"><%=astrDateOption[1]%></option>
          <option value="2" selected><%=astrDateOption[2]%></option>
          <%}else{%>
          <option value="0"><%=astrDateOption[0]%></option>
          <option value="1"><%=astrDateOption[1]%></option>
          <option value="2"><%=astrDateOption[2]%></option>
          <%}%>
        </select></td>
    </tr>
    <%if(WI.fillTextValue("receive_option").length() > 0){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td height="26" colspan="4" valign="bottom"><table width="100%" border="0" cellspacing="0" cellpadding="0">
          <%if(WI.fillTextValue("receive_option").equals("1")){%>
          <tr> 
            <td> <%strTemp = WI.fillTextValue("given_date_fr");%> <input name="given_date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
              <a href="javascript:show_calendar('form_.given_date_fr');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
              <img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              to 
              <%strTemp = WI.fillTextValue("given_date_to");%> <input name="given_date_to" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
              <a href="javascript:show_calendar('form_.given_date_to');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
              <img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>            </td>
          </tr>
          <%}else if(WI.fillTextValue("receive_option").equals("2")){%>
          <tr> 
            <td> <select name="given_year" onChange="ReloadPage();">
                <%=dbOP.loadComboYear(WI.fillTextValue("given_year"),2,1)%> </select> <%
				strTemp = WI.fillTextValue("given_month");
			  %> <select name="given_month">
                <option value="">All</option>
                <%for(i = 0; i < 12; ++i){%>
                <%if(strTemp.equals(Integer.toString(i+1))){%>
                <option value="<%=i+1%>" selected><%=astrConvertMonth[i]%></option>
                <%}else{%>
                <option value="<%=i+1%>"><%=astrConvertMonth[i]%></option>
                <%}%>
                <%}%>
              </select></td>
          </tr>
          <%}else if(WI.fillTextValue("receive_option").equals("0")){%>
          <tr> 
            <td> <%strTemp = WI.fillTextValue("given_date_fr");%> <input name="given_date_fr" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
			 onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly> 
              <a href="javascript:show_calendar('form_.given_date_fr');" title="Click to select date" 
			  onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
              <img src="../../../../images/calendar_new.gif" width="20" height="16" border="0"></a>            </td>
          </tr>
          <%}%>
        </table></td>
    </tr>
    <%}%>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" valign="bottom"><strong><u>SORT</u></strong> </td>
      <td height="18" colspan="4" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="38">&nbsp;</td>
      <td height="38" colspan="2"> <select name="sort_by1">
          <option value="">N/A</option>
          <%=PCV.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
      <td width="63%" height="38" colspan="3"> <select name="sort_by2">
          <option value="">N/A</option>
          <%=PCV.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="38">&nbsp;</td>
      <td height="38" colspan="2"> <select name="sort_by3">
          <option value="">N/A</option>
          <%=PCV.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
      <td height="38" colspan="3"> <select name="sort_by4">
          <option value="">N/A</option>
          <%=PCV.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> </select> <select name="sort_by4_con">
          <option value="asc">Ascending</option>
          <%
			if(WI.fillTextValue("sort_by4_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25"><div align="center"><font size="1"></font></div></td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="4" valign="bottom"><font size="1"><a href="javascript:ProceedClicked();"><img src="../../../../images/form_proceed.gif" border="0" ></a> 
        </font></td>
    </tr>
    <tr> 
      <td height="28" colspan="6"><div align="right"></div></td>
    </tr>
  </table>
  
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="6" bgcolor="#B9B292"><div align="center"><font color="#FFFFFF"><strong>:: 
          SEARCH RESULT :: </strong></font></div></td>
    </tr>
    <tr> 
      <td height="23" colspan="3"><font size="1"><strong>TOTAL VOUCHER(S) : </strong></font><strong></strong></td>
     <%
		int iPageCount = iSearch/PCV.defSearchSize;
		double dTotalItems = 0d;
		double dTotalAmount = 0d;
		if(iSearch % PCV.defSearchSize > 0) ++iPageCount;				
		%>
      <td height="23" colspan="3"><div align="right">&nbsp;
	      <%if(iPageCount > 1){%>
		  Jump to page: 
          <select name="jumpto" onChange="ProceedClicked();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
				}
			}
		%>
          </select>
          <%}%>
        </div></td>
    </tr>
    <tr> 
      <td width="7%" height="25"><div align="center"><font size="1"><strong>VOUCHER 
          NO.</strong></font></div></td>
      <td width="8%"><div align="center"><font size="1"><strong>VOUCHER DATE</strong></font></div></td>
      <td width="19%"><div align="center"><strong><font size="1">PAYEE NAME</font></strong></div></td>
      <td width="32%"><div align="center"><strong><font size="1">PARTICULARS</font></strong></div></td>
      <td width="10%"><div align="center"><strong><font size="1">AMOUNT</font></strong></div></td>
	  <%if(WI.fillTextValue("opner_info").length() == 0) {%>
      <td width="14%"><font size="1">&nbsp;</font></td>
	  <%}%>
    </tr>
    <%for(i = 0;i< vRetResult.size(); i+=6){%>
    <tr> 
      <td height="25"><font size="1">&nbsp;
         <%if(WI.fillTextValue("opner_info").length() > 0) {%>
         <a href="javascript:CopyID('<%=(String)vRetResult.elementAt(i+1)%>');"> 	  
	     <%=(String)vRetResult.elementAt(i+1)%></a>
		 <%}else{%>
         <%=(String)vRetResult.elementAt(i+1)%>
         <%}%>
	  </font></td>
      <td><div align="right"><font size="1"><%=(String)vRetResult.elementAt(i+2)%>&nbsp;</font></div></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+3))%></font></td>
      <td><font size="1">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i+4))%></font></td>
      <td><div align="right"><font size="1"><%=(String)vRetResult.elementAt(i+5)%>&nbsp;</font></div></td>
	  <%if(WI.fillTextValue("opner_info").length() == 0) {%>
      <td><a href="javascript:printVoucher('<%=(String)vRetResult.elementAt(i+1)%>');"> 
        </a> <a href="javascript:UpdatePettyCash('<%=(String)vRetResult.elementAt(i+1)%>');"> 
        <img src="../../../../images/edit.gif" border="0"></a> <a href="javascript:ViewPettyCash('<%=(String)vRetResult.elementAt(i+1)%>');"> 
        <img src="../../../../images/view.gif" border="0"></a></td>
	   <%}%>
    </tr>
    <%}%>
  </table>
  <%}%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="proceedClicked" value="">
  <input type="hidden" name="opner_info" value="<%=WI.fillTextValue("opner_info")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>