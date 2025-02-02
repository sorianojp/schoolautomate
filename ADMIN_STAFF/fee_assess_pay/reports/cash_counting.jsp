<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>
<script language="JavaScript">
function UpdateDenomination()
{
	location = "./update_denomination.jsp?emp_id="+escape(document.daily_cash.emp_id.value)+"&date_of_col="+
	escape(document.daily_cash.date_of_col.value);
}
function GoBack()
{
	location = "./daily_cash_col.jsp?emp_id="+escape(document.daily_cash.emp_id.value)+"&date_of_col="+
		escape(document.daily_cash.date_of_col.value);
}
function CalculateSum()
{
	document.daily_cash.denom_temp.value = document.daily_cash.denom_index[document.daily_cash.denom_index.selectedIndex].text;

	if(document.daily_cash.qty.value.length ==0)
		document.daily_cash.denom_peso.value = 0;
	else
		document.daily_cash.denom_peso.value = eval(document.daily_cash.denom_index[document.daily_cash.denom_index.selectedIndex].text)*
												eval(document.daily_cash.qty.value);

	document.daily_cash.denom_peso.value = truncateFloat(document.daily_cash.denom_peso.value,2,true);

}

function PageAction(strAction)
{
	document.daily_cash.page_action.value = strAction;
}
function PrepareToEdit(strInfoIndex)
{
	document.daily_cash.page_action.value ="";
	document.daily_cash.prepareToEdit.value = 1;
	document.daily_cash.info_index.value = strInfoIndex;
	document.daily_cash.submit();
}

function DeleteRecord(strInfoIndex)
{
	document.daily_cash.page_action.value="0";
	document.daily_cash.prepareToEdit.value ="";
	document.daily_cash.info_index.value=strInfoIndex;

	document.daily_cash.submit();
}
function Refresh()
{
	document.daily_cash.page_action.value="";
	document.daily_cash.submit();
}
function CancelRecord()
{
	document.daily_cash.page_action.value="";
	document.daily_cash.prepareToEdit.value ="";
	document.daily_cash.info_index.value="";
	document.daily_cash.submit();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,EnrlReport.DailyCashCollection,enrollment.Authentication,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	String strPrepareToEdit=WI.getStrValue(request.getParameter("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-REPORTS","cash_counting.jsp");
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
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","Reports",request.getRemoteAddr(),
														"cash_counting.jsp");
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

//end of authenticaion code.
Vector vEmployeeInfo = null;
Authentication auth = new Authentication();
DailyCashCollection DC = new DailyCashCollection();

Vector vCollectionInfo = null;
Vector vEditInfo       = null;

vEmployeeInfo = auth.operateOnBasicInfo(dbOP, request,"0");
if(vEmployeeInfo == null)
	strErrMsg = auth.getErrMsg();
else
{
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0)
	{
		vCollectionInfo = DC.operateOnCashCounting(dbOP,request,Integer.parseInt(strTemp));
		if(vCollectionInfo != null)
			strPrepareToEdit = "0";
		else
			strErrMsg = DC.getErrMsg();
	}

}
//for first time, I have to keep the teller index in attribute.
if(WI.fillTextValue("teller_index").length() ==0)
	request.setAttribute("teller_index",vEmployeeInfo.elementAt(0));
vCollectionInfo =	DC.operateOnCashCounting(dbOP,request,4);
if((vCollectionInfo == null || vCollectionInfo.size() ==0) && strErrMsg == null)
	strErrMsg = DC.getErrMsg();
if(strPrepareToEdit != null && strPrepareToEdit.compareTo("1") ==0)
{
	vEditInfo = DC.operateOnCashCounting(dbOP,request,3);
	if(vEditInfo == null)
		strErrMsg = DC.getErrMsg();
}
if(strErrMsg == null) strErrMsg = "";
%>

<form name="daily_cash" method="post" action="./cash_counting.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>::::
          DAILY CASH COUNTING PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="4"><a href="javascript:self.close();"><img src="../../../images/close_window.gif" border="0"></a>Click
        to close window
		&nbsp;&nbsp;&nbsp;<a href="javascript:Refresh()"><img src="../../../images/refresh.gif" border="0"></a>
		Click to refresh window</td>
    </tr>
    <tr>
      <td height="25" colspan="4"><div align="center"><strong>CASH COUNTING FOR
          DATE: <%=WI.fillTextValue("date_of_col")%></strong></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Emplolyee ID&nbsp;</td>
      <td width="38%" height="25"><strong><%=WI.fillTextValue("emp_id")%></strong></td>
      <td width="12%">Emp status</td>
      <td width="33%"><strong><%=WI.getStrValue((String)vEmployeeInfo.elementAt(16))%></strong></td>
    </tr>
    <tr>
      <td  width="2%" height="25">&nbsp;</td>
      <td width="15%" height="25">Employee Name</td>
      <td height="25"><strong><%=WI.formatName((String)vEmployeeInfo.elementAt(1),(String)vEmployeeInfo.elementAt(2),(String)vEmployeeInfo.elementAt(3),1)%></strong></td>
      <td height="25">Job Title</td>
      <td height="25"><strong><%=(String)vEmployeeInfo.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"><font size="1">Click here to update DENOMINATIONS</font>
        <a href="javascript:UpdateDenomination();"><img src="../../../images/update.gif" border="0"></a>
      </td>
      <td height="25" colspan="2">
<%
strTemp = WI.fillTextValue("is_check");
if(strTemp.compareTo("1") ==0)
	strTemp = "checked";
else
	strTemp = "";
%>
	  <input type="checkbox" name="is_check" value="1" onClick="Refresh();" <%=strTemp%>>
        Click for check entries (uncheck indicates entries are for cash breakdown)</td>
    </tr>
	<tr>
	  <td>&nbsp;</td>
      <td colspan="4" height="25"><font size="3"><strong><%=strErrMsg%></strong></font></td>
    </tr>

    <tr>
      <td colspan="5" height="25"><hr size="1"></td>
    </tr>
  </table>
<%
if(WI.fillTextValue("is_check").compareTo("1") !=0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4" bgcolor="#B9B292"><div align="center">CASH BREAKDOWN(EDIT/ADD)</div></td>
    </tr>
    <tr>
      <td width="27%" height="25"><div align="center"><strong><font size="1">DENOMINATION
          (Php) </font></strong></div></td>
      <td width="24%"><div align="center"><strong><font size="1">NO. OF PCS.</font></strong></div></td>
      <td width="29%"><div align="center"><strong><font size="1">PESOS</font></strong></div></td>
      <td width="20%" align="center"><strong><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0){%>
        SAVE
        <%}else{%>
        EDIT/CANCEL
        <%}%>
        </font></strong></td>
    </tr>
    <tr>
      <td height="25" align="center"> <select name="denom_index" onChange="CalculateSum();">
<%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = WI.fillTextValue("denom_index");
%>
         <%=dbOP.loadCombo("DENOM_INDEX","DENOMINATION",
		  " from CR_DENOMINATION where IS_DEL=0 order by DENOMINATION desc",strTemp, false)%> </select></td>
      <td align="center">
<%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = WI.fillTextValue("qty");
%>

          <input name="qty" type="text" size="5" maxlength="5" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" onKeyUp='CalculateSum();'
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        </td>
      <td align="center">
<%
float fAmt = 0f;
if(vEditInfo != null && vEditInfo.size() > 0)
	fAmt = Float.parseFloat((String)vEditInfo.elementAt(4));
else if(WI.fillTextValue("qty").length() > 0)
{
	strTemp = WI.getStrValue(WI.fillTextValue("denom_temp"),"1000");
	fAmt = Integer.parseInt(WI.fillTextValue("qty"))*Float.parseFloat(strTemp);
}%>

	 <input name="denom_peso" type="text" size="18" class="textbox_noborder" readonly="yes" value="<%=CommonUtil.formatFloat(fAmt,true)%>"></td>
      <td align="center">
	  <%
	if(iAccessLevel > 1)
	{
		if(strPrepareToEdit.compareTo("0") == 0)
		{%>
			<input type="image" src="../../../images/add.gif" onClick="PageAction(1);">
		<%}else{%>
			<input type="image" src="../../../images/edit.gif" onClick="PageAction(2);">&nbsp;&nbsp;&nbsp;
		<a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
			to cancel edit</font>
		<%}
	}else{%>N/A
	<%}%>
	</td>
    </tr>
  </table>
<%}else{%>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="6" bgcolor="#B9B292"><div align="center">CHECK
          BREAKDOWN(EDIT/ADD)</div></td>
    </tr>
    <tr>
      <td width="29%"><div align="center"><strong><font size="1">BANK NAME</font></strong></div></td>
      <td width="27%" height="25"><div align="center"><strong><font size="1">BRANCH
          </font></strong></div></td>
      <td width="14%"><div align="center"><strong><font size="1">ACCOUNT NO.</font></strong></div></td>
      <td width="13%"><div align="center"><strong><font size="1">CHECK NO.</font></strong></div></td>
      <td width="10%"><div align="center"><strong><font size="1">AMOUNT</font></strong></div></td>
      <td width="7%" align="center"><strong><font size="1">
	  <%if(strPrepareToEdit.compareTo("1") != 0){%>
	  SAVE
	  <%}else{%>
	  EDIT/CANCEL
	  <%}%></font></strong></td>
    </tr>
    <tr>
      <td><div align="center">
<%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(9);
	else
		strTemp = WI.fillTextValue("bank_name");
%>
          <input name="bank_name" type="text" size="26" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </div></td>
      <td height="25"><div align="center">
 <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(10);
	else
		strTemp = WI.fillTextValue("bank_branch");
%>         <input name="bank_branch" type="text" size="26" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </div></td>
      <td><div align="center">
<%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(11);
	else
		strTemp = WI.fillTextValue("acc_no");
%>          <input name="acc_no" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </div></td>
      <td><div align="center">
 <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(7);
	else
		strTemp = WI.fillTextValue("check_no");
%>         <input name="check_no" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </div></td>
      <td><div align="center">
 <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(4);
	else
		strTemp = WI.fillTextValue("amount");
%>         <input name="amount" type="text" size="10" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        </div></td>
      <td align="center">
	  <%
	if(iAccessLevel > 1)
	{
		if(strPrepareToEdit.compareTo("0") == 0)
		{%>
			<input type="image" src="../../../images/add.gif" onClick="PageAction(1);">
		<%}else{%>
			<input type="image" src="../../../images/edit.gif" onClick="PageAction(2);">&nbsp;&nbsp;&nbsp;
		<a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
			to cancel edit</font>
		<%}
	}else{%>N/A
	<%}%>
	</td>
    </tr>
	<input type="hidden" name="qty" value="1">
  </table>
<%}
float fSubTotalCash  = 0f;
float fSubTotalCheck = 0f;
if(vCollectionInfo != null && vCollectionInfo.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" height="25" align="center" bgcolor="#B9c7C2">CASH BREAKDOWN(VIEW)</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="5%">&nbsp;</td>
      <td height="25" width="25%"><strong><font size="1">DENOMINATION (Php) </font></strong></td>
      <td height="25" width="25%"><strong><font size="1">NO. OF PCS.</font></strong></td>
      <td height="25" width="25%"><strong><font size="1">AMOUNT</font></strong></td>
      <td height="25" width="10%"><strong><font size="1">EDIT</font></strong></td>
      <td height="25" width="10%"><font size="1"><strong>DELETE</strong></font><strong></strong></strong></td>
    </tr>
<%int i=0;
for(; i< vCollectionInfo.size(); ++i){
if( ((String)vCollectionInfo.elementAt(i+5)).compareTo("1") ==0)//check -- break here.
	break;
fSubTotalCash += Float.parseFloat((String)vCollectionInfo.elementAt(i+4));
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25"><%=(String)vCollectionInfo.elementAt(i+2)%></td>
      <td height="25"><%=(String)vCollectionInfo.elementAt(i+3)%></td>
      <td height="25"><%=CommonUtil.formatFloat((String)vCollectionInfo.elementAt(i+4),true)%></td>
      <td height="25">
	  <%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vCollectionInfo.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
<%}%></td>
      <td height="25">
	  <%if(iAccessLevel ==2){%>
  		<a href='javascript:DeleteRecord("<%=(String)vCollectionInfo.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
	<%}else{%>N/A<%}%>
	</td>
    </tr>
<%i = i+11;
}
for(;i>0;--i)
	vCollectionInfo.removeElementAt(0);
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">SUB TOTAL : <%=CommonUtil.formatFloat(fSubTotalCash,true)%></td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="100%" height="25" align="center" bgcolor="#B9c7C2">CHECK BREAKDOWN(VIEW)</td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="5%">&nbsp;</td>
      <td width="25%"><strong><font size="1">BANK NAME</font></strong></td>
      <td width="19%"><strong><font size="1">BRANCH</font></strong></td>
      <td width="14%"><strong><font size="1">ACCOUNT NO.</font></strong></td>
      <td width="13%"><font size="1"><strong>CHECK NO.</strong></font></td>
      <td width="10%"><font size="1"><strong>AMOUNT</strong></font></td>
      <td width="6%"><strong><font size="1">EDIT</font></strong></td>
      <td width="8%"><font size="1"><strong>DELETE</strong></font><strong></strong></strong></td>
    </tr>
<%
for(i=0; i< vCollectionInfo.size(); ++i){
fSubTotalCheck += Float.parseFloat((String)vCollectionInfo.elementAt(i+4));
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td><%=(String)vCollectionInfo.elementAt(i+9)%></td>
      <td><%=(String)vCollectionInfo.elementAt(i+10)%></td>
      <td><%=(String)vCollectionInfo.elementAt(i+11)%></td>
      <td><%=(String)vCollectionInfo.elementAt(i+7)%></td>
      <td><%=CommonUtil.formatFloat((String)vCollectionInfo.elementAt(i+4),true)%></td>
      <td>
	<%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vCollectionInfo.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
	<%}%>
	</td>
      <td>
	  <%if(iAccessLevel ==2){%>
  		<a href='javascript:DeleteRecord("<%=(String)vCollectionInfo.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a>
	<%}else{%>N/A<%}%>
	</td>
    </tr>
<%i = i+11;
}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">SUB TOTAL : <%=CommonUtil.formatFloat(fSubTotalCheck,true)%></td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="5%">&nbsp;</td>
      <td>TOTAL AMOUNT COLLECTED FOR DAY(CASH+CHECK) : <%=CommonUtil.formatFloat(fSubTotalCheck+fSubTotalCash,true)%> PESOS</td>
    </tr>
  </table>
<%}%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
   <tr>
      <td height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">

<%if(vEmployeeInfo != null && vEmployeeInfo.size() > 0){%>
 <input type="hidden" name="teller_index" value="<%=(String)vEmployeeInfo.elementAt(0)%>">
<%}%>

<input type="hidden" name="date_of_col" value="<%=WI.fillTextValue("date_of_col")%>">

<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">

<!-- temporary denomination -->
<%
strTemp = WI.getStrValue(WI.fillTextValue("denom_temp"),"1000");
//if is_check = 1, force the value to 1000;
if(WI.fillTextValue("is_check").compareTo("1") ==0)
	strTemp = "1000";
%>
<input type="hidden" name="denom_temp" value="<%=strTemp%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
