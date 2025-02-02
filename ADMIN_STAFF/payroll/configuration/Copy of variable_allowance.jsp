<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
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
	location ="./variable_allowance.jsp";
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
								"Admin/staff-Payroll-CONFIGURATION-COLA","variable_allowance.jsp");
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
String[] astrDropList = {"Equal to","Less than","More than"};
String[] astrDropListVal = {"'='","'<'","'>'"};

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
<form action="./variable_allowance.jsp" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL: COLA/ECOLA PAGE ::::</strong></font></div></td>
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
	else strTemp= WI.fillTextValue("date_from");%> 
        <input name="date_from" type="text" class="textbox" id="date_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes"> 
        <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" alt="Click to set " border="0"></a> 
        to 
        <%	if(vEditInfo!=null) strTemp= WI.getStrValue((String)vEditInfo.elementAt(2));
	else strTemp= WI.fillTextValue("date_to");%> 
        <input name="date_to" type="text" class="textbox" id="date_to"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes"> 
        <a href="javascript:show_calendar('form_.date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>COLA/ECOLA Amount </td>
      <td width="74%"> <%	if(vEditInfo!=null) strTemp= WI.getStrValue((String)vEditInfo.elementAt(3));
			else strTemp= WI.fillTextValue("cola_month");%> <input onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" 
	  name="cola_month" type="text" id="cola_month" size="8" maxlength="8" class="textbox" onKeyUp="AllowOnlyFloat('form_','cola_month')">
        per Month </td>
    </tr>
    <tr> 
      <td width="5%" height="30">&nbsp;</td>
      <td width="21%" height="30">COLA/ECOLA Amount</td>
      <td height="30"> <%	if(vEditInfo!=null) strTemp= WI.getStrValue((String)vEditInfo.elementAt(4));
			else strTemp= WI.fillTextValue("cola_daily");%> <input onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" 
	  name="cola_daily" type="text" id="cola_daily" size="8" maxlength="8" class="textbox" onKeyUp="AllowOnlyFloat('form_','cola_daily')">
        per Day</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25"> <%	if(vEditInfo!=null) {
			if (((String)vEditInfo.elementAt(5)).compareTo("1") == 0)
				strTemp = "checked "; else strTemp = "";
		}else{
			if (WI.fillTextValue("deduct_absent").length() > 0)
				strTemp = "checked "; else strTemp = "";
		}
	%> <input name="deduct_absent" type="checkbox" id="deduct_absent" value="1" <%=strTemp%>> 
        <font   size="1"> <strong>Deduct per day amount when absent</strong></font></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td colspan="2"><strong>Apply to:</strong></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td><select name="employee_category" onChange="ReloadPage();">
          <option value="">All Employees</option>
          <%if(strTemp.equals("0")){%>
          <option value="0" selected>All Staff</option>
          <option value="1">All Faculty</option>
          <%}else if(strTemp.equals("1")){%>
          <option value="0">All Staff</option>
          <option value="1" selected>All Faculty</option>
          <%}else{%>
          <option value="0">All Staff</option>
          <option value="1">All Faculty</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td><select name="pt_ft" onChange="ReloadPage();">
          <option value="">All Employees</option>
          <%if(WI.fillTextValue("pt_ft").equals("0")){%>
          <option value="0" selected>All Part-time</option>
          <option value="1">All Full-time</option>
          <%}else if(WI.fillTextValue("pt_ft").equals("1")){%>
          <option value="0">All Part-time</option>
          <option value="1" selected>All Full-time</option>
          <%}else{%>
          <option value="0">All Part-time</option>
          <option value="1">All Full-time</option>
          <%}%>
        </select></td>
    </tr>
	<%if(WI.fillTextValue("employee_category").equals("1")){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Load Hour</td>
      <td><select name="load_hour_con">
          <%=searchLoans.constructGenericDropList(WI.fillTextValue("load_hour_con"),astrDropListGT,astrDropListValGT)%> 
        </select> 
        <input name="load_hour" type="text" class="textbox" value="<%=strTemp%>" size="8" maxlength="8"
		 onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  
		 onKeyUp="AllowOnlyFloat('form_','load_hour')">
      </td>
    </tr>
	<%}%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Rate Per Day</td>
      <td><select name="rate_con">
          <%=searchLoans.constructGenericDropList(WI.fillTextValue("rate_con"),astrDropListGT,astrDropListValGT)%> 
        </select> 
        <input name="rate" type="text" class="textbox" value="<%=strTemp%>" maxlength="8"
		 size="8" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  
		 onKeyUp="AllowOnlyFloat('form_','rate')">
      </td>
    </tr>
    <tr> 
      <td height="18" colspan="3">&nbsp;</td>
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
      <td height="25" colspan="7"><div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0" ></a>click 
          to print table</font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="7" bgcolor="#B9B292"><div align="center"><strong>LIST 
          OF COLA/ECOLA IMPLEMENTED</strong></div></td>
    </tr>
    <tr> 
      <td width="18%" height="26" rowspan="2"><div align="center"><font size="1"><strong>EFFECTIVITY 
          DATE</strong></font></div></td>
      <td colspan="2"><div align="center"><font size="1"><strong>COLA/ECOLA AMOUNT</strong></font></div></td>
      <td width="15%" rowspan="2"><div align="center"><strong><font size="1">DEDUCT 
          PER DAY WHEN ABSENT</font></strong></div></td>
      <td width="33%" rowspan="2">&nbsp;</td>
      <td colspan="2" rowspan="2"><div align="center"><strong><font size="1">OPTIONS</font></strong></div></td>
    </tr>
    <tr> 
      <td width="8%"><div align="center"><font size="1"><strong>Per Month</strong></font></div></td>
      <td width="10%"><div align="center"><font size="1"><strong>Per Day</strong></font></div></td>
    </tr>
    <% String[] astrDeductAbsent={"../../../images/x.gif","../../../images/tick.gif"};
	for (int i = 0; i< vRetResult.size() ; i+=6) {%>
    <tr> 
      <td height="30"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+1)%><%=WI.getStrValue((String)vRetResult.elementAt(i+2)," - ",""," - PRESENT")%></font></td>
      <td><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+3))%>&nbsp;</font></div></td>
      <td><div align="right"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+4))%>&nbsp;</font></div></td>
      <td><div align="center">&nbsp;<img src="<%=astrDeductAbsent[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+5),"0"))]%>" ></div></td>
      <td>&nbsp;</td>
      <td width="8%"> <div align="center"> 
          <% if (iAccessLevel > 1) {%>
          <a href='javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
          <%}else{%>
          NA 
          <%}%>
        </div></td>
      <td width="8%"> <div align="center"> 
          <% if (iAccessLevel == 2) {%>
          <a href='javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
          <%}else{%>
          NA 
          <%}%>
        </div></td>
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
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
