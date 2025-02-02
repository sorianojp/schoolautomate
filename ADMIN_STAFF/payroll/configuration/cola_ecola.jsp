<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Cola Management</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function AddRecord(){
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.page_action.value = "2";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrepareToEdit(strInfoIndex,strPayable){
	document.form_.print_page.value="";
	document.form_.page_action.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	location ="./cola_ecola.jsp?is_cola=1";
}

function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}


function focusID() {
	document.form_.emp_id.focus();
}

-->
</script>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="cola_ecola_print.jsp" />
<% return;}

//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-CONFIGURATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
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

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-COLA","cola_ecola.jsp");
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

//end of authenticaion code.
Vector vRetResult = null;
Vector vEditInfo = null;

PayrollConfig pr = new PayrollConfig();

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");
String strCheck = null;

if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (pr.operateOnColaEcola(dbOP,request,0) != null){
			strErrMsg = " COLA removed successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (pr.operateOnColaEcola(dbOP,request,1) != null){
			strErrMsg = " COLA posted successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (pr.operateOnColaEcola(dbOP,request,2) != null){
			strErrMsg = " COLA updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}
}
if (strPrepareToEdit.length() > 0){
	vEditInfo = pr.operateOnColaEcola(dbOP,request,3);
	if (vEditInfo == null)
		strErrMsg = pr.getErrMsg();
}

vRetResult = pr.operateOnColaEcola(dbOP,request,4);
if (vRetResult != null && strErrMsg == null){
	strErrMsg = pr.getErrMsg();	
}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./cola_ecola.jsp" name="form_" id="form_" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: COLA/ECOLA PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Effectivity Date</td>
      <td> <%	if(vEditInfo!=null) strTemp= (String)vEditInfo.elementAt(1);
	else strTemp= WI.fillTextValue("date_from");%> <input name="date_from" type="text" class="textbox" id="date_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes"> 
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" alt="Click to set " border="0"></a> 
        to 
        <%	if(vEditInfo!=null) strTemp= WI.getStrValue((String)vEditInfo.elementAt(2));
	else strTemp= WI.fillTextValue("date_to");%> <input name="date_to" type="text" class="textbox" id="date_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Amount per Month </td>
      <td width="74%">
        <%	if(vEditInfo!=null) strTemp= WI.getStrValue((String)vEditInfo.elementAt(3));
			else strTemp= WI.fillTextValue("cola_month");%>	  
	  <input onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" 
	  name="cola_month" type="text" id="cola_month" size="8" maxlength="8" class="textbox" onKeyUp="AllowOnlyFloat('form_','cola_month')"></td>
    </tr>
    <tr> 
      <td width="5%" height="24">&nbsp;</td>
      <td width="21%" height="24"> Amount per Day</td>
      <td height="24"> 
        <%
		  if(vEditInfo!=null) 
			strTemp= WI.getStrValue((String)vEditInfo.elementAt(4));
		  else 
		  	strTemp= WI.fillTextValue("cola_daily");
		%>	  
	  <input onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" 
	  name="cola_daily" type="text" id="cola_daily" size="8" maxlength="8" class="textbox" onKeyUp="AllowOnlyFloat('form_','cola_daily')"></td>
    </tr>
    <tr>
      <td height="24">&nbsp;</td>
      <td height="24">Amount
per Hour</td>
      <td height="24">
	    <%
		  if(vEditInfo!=null) 
			strTemp= WI.getStrValue((String)vEditInfo.elementAt(10));
		  else 
		  	strTemp= WI.fillTextValue("cola_hourly");
		%>
        <input onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" 
	  name="cola_hourly" type="text" id="cola_hourly" size="8" maxlength="8" class="textbox" onKeyUp="AllowOnlyFloat('form_','cola_hourly')"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Option (when employee is absent)</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
	  <%
		if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(5);
		else	
			strTemp = WI.fillTextValue("deduct_absent");
		strTemp = WI.getStrValue(strTemp,"0");
		if(strTemp.compareTo("0") == 0) 
			strCheck = " checked";
		else	
			strCheck = "";	
	  %>
        <input type="radio" name="deduct_absent" value="0"<%=strCheck%>>
		No Deduction
		<%
		if(strTemp.compareTo("1") == 0) 
			strCheck = " checked";
		else
			strCheck = "";
		%>
		<input type="radio" name="deduct_absent" value="1"<%=strCheck%>>
		Deduct per day only 
		<%
		if(strTemp.compareTo("2") == 0) 
			strCheck = " checked";
		else
			strCheck = "";
		%>
        <input type="radio" name="deduct_absent" value="2"<%=strCheck%>>
Deduct per day/hour </td>
    </tr>
    <tr> 
      <td height="35">&nbsp;</td>
      <td height="35" colspan="2" valign="bottom"> <div align="center"> 
          <% if (iAccessLevel > 1) {
	  if (vEditInfo == null) {%>
          <a href="javascript:AddRecord()"><img src="../../../images/save.gif" width="48" height="28"  border="0"></a><font size="1">click 
          to save entries </font> 
          <%}else{%>
          <a href="javascript:EditRecord()"><img src="../../../images/edit.gif" width="40" height="26"  border="0"></a><font size="1">click 
          to change entries </font> 
          <%} // end else if vEditInfo == null %>
          <a href="javascript:CancelRecord()"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
          to cancel/clear entries</font> 
          <%} // end iAccessLevel > 1%>
        </div></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
      <td height="10" valign="bottom">&nbsp;</td>
    </tr>
  </table>
 <% if (vRetResult != null) { %>
 
  <table width="100%" border="1" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="7" align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0" ></a>click 
          to print table</font></td>
    </tr>
    <tr> 
      <td height="25" colspan="7" align="center" bgcolor="#B9B292"><strong>LIST 
      OF COLA/ECOLA IMPLEMENTED</strong></td>
    </tr>
    <tr> 
      <td width="34%" height="26" rowspan="2" align="center"><font size="1"><strong>EFFECTIVITY 
      DATE</strong></font></td>
      <td colspan="3" align="center"><font size="1"><strong>COLA/ECOLA AMOUNT</strong></font></td>
      <td width="20%" rowspan="2" align="center"><strong><font size="1">DEDUCT WHEN ABSENT</font></strong></td>
      <td colspan="2" rowspan="2" align="center"><strong><font size="1">OPTIONS</font></strong></td>
    </tr>
    <tr> 
      <td width="15%" align="center"><font size="1"><strong>Per Month</strong></font></td>
      <td width="15%" align="center"><font size="1"><strong>Per Day</strong></font></td>
      <td width="15%" align="center"><font size="1"><strong>Per Hour </strong></font></td>
    </tr>
    <% String[] astrDeductAbsent={"../../../images/x.gif","../../../images/tick.gif"};
	for (int i = 0; i< vRetResult.size() ; i+=20) {%>
    <tr> 
      <td height="30"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%><%=WI.getStrValue((String)vRetResult.elementAt(i+2)," - ",""," - PRESENT")%></font></td>
      <td align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+3))%>&nbsp;</font></td>
      <td align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+4))%>&nbsp;</font></td>
      <td align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+10))%>&nbsp;</font></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5),"0");
				if(!strTemp.equals("0"))
						strTemp = "1";
			%>
      <td align="center">&nbsp;<img src="<%=astrDeductAbsent[Integer.parseInt(strTemp)]%>" ></td>
      <td width="8%" align="center"> 
        <% if (iAccessLevel > 1) {%>
        <a href='javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
        <%}else{%>
        NA
        <%}%>        </td>
      <td width="8%" align="center"> 
        <% if (iAccessLevel == 2) {%>
        <a href='javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}else{%>
        NA
        <%}%>        </td>
    </tr>
    <%}// end for loop%>
  </table>
<%}//end vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="print_page">
<input type="hidden" name="is_cola" value="<%=WI.getStrValue(WI.fillTextValue("is_cola"),"1")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>