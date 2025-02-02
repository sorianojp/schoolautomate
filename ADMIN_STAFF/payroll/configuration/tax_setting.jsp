<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>TAX SETTING OVERRIDE</title>
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
	location ="./tax_setting.jsp";
}

function ReloadPage()
{
	document.form_.page_reloaded.value = "1";
	document.form_.print_page.value= "";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
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
								"Admin/staff-Payroll-CONFIGURATION-COLA","tax_setting.jsp");
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
String strTemp2 = null;
String strEmpCatg = null;
String[] astrForCI = {"","Built in CI","Physician"};
String[] astrCategory = {"Staff","Faculty","Employees"};
String[] astrStatus = {"Part-Time","Full-Time","Built-in",""};
String[] astrPay = {"Basic rate","Gross Pay"};
boolean bolHasItems = false;
if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (pr.operateOnTaxOverride(dbOP,request,0) != null){
			strErrMsg = "Override Setting removed successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (pr.operateOnTaxOverride(dbOP,request,1) != null){
			strErrMsg = "Override Setting posted successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (pr.operateOnTaxOverride(dbOP,request,2) != null){
			strErrMsg = "Override Setting updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}
}
if (strPrepareToEdit.length() > 0 && WI.fillTextValue("page_reloaded").equals("0")){
	vEditInfo = pr.operateOnTaxOverride(dbOP,request,3);
	if (vEditInfo == null)
		strErrMsg = pr.getErrMsg();
}
vRetResult = pr.operateOnTaxOverride(dbOP,request,4);
if (vRetResult != null && strErrMsg == null){
	strErrMsg = pr.getErrMsg();	
}


%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./tax_setting.jsp" name="form_" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="right" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: TAX SETTING OVERRIDE PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td width="5%" height="24">&nbsp;</td>
      <td width="21%">Effective Date</td>
      <td width="74%"> <%	if(vEditInfo!=null) strTemp= (String)vEditInfo.elementAt(3);
	else strTemp= WI.fillTextValue("date_from");%> <input name="date_from" type="text" class="textbox" id="date_from"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="12" maxlength="12" readonly="yes"> 
      <a href="javascript:show_calendar('form_.date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" alt="Click to set " border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Percentage</td>
	  <%
	  	if(vEditInfo !=null && vEditInfo.size() > 0)
			strTemp = (String) vEditInfo.elementAt(4);
		else
		  	strTemp = WI.fillTextValue("percent");
	  %>
      <td><input name="percent" type="text" size="8" maxlength="10" value="<%=WI.getStrValue(strTemp)%>" 
		class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
        <!--
		<select name="percent_of">
          <option value="0">Basic Monthly Salary</option>
          <%
			//if(vEditInfo != null && vEditInfo.size() > 0) 
			//	strTemp = (String)vEditInfo.elementAt(5);
			//else	
			//	strTemp = WI.fillTextValue("percent_of");
		  %>          
          <%//if(strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>Gross Monthly Salary</option>
          <%//}else{%>
          <option value="1">Gross Monthly Salary</option>
          <%//}%>
        </select>
		-->	  </td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td colspan="2"><strong>Apply to:</strong></td>
    </tr>
    
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employment type</td>
			<%
				strTemp = WI.fillTextValue("work_type");
				strTemp = WI.getStrValue(strTemp,"0");
			%>
      <td><select name="work_type" onChange="ReloadPage();">
        <option value="0">&nbsp;Regular Employee</option>
        <%if(strTemp.equals("1")){%>
        <option value="1" selected>&nbsp;Built In CI</option>
        <option value="2">&nbsp;Physician</option>
        <%}else if(strTemp.equals("2")){%>
        <option value="1">&nbsp;Built In CI</option>
        <option value="2"selected>&nbsp;Physician</option>
        <%}else{%>
        <option value="1">&nbsp;Built In CI</option>
        <option value="2">&nbsp;Physician</option>
        <%}%>
      </select></td>
    </tr>
		<%// show only the additional options for regular employees
		if(strTemp.equals("0")){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <%
	  	if(vEditInfo !=null && vEditInfo.size() > 0)
			strTemp = (String) vEditInfo.elementAt(2);
		else
		  	strTemp = WI.fillTextValue("pt_ft");
	  %>	  
      <td><select name="pt_ft">
        <option value="3" selected>All</option>
        <%if (strTemp.equals("0")){%>
        <option value="0" selected>Part - time</option>
        <option value="1">Full - time</option>
        <%}else if (strTemp.equals("1")){%>
        <option value="0">Part - time</option>
        <option value="1" selected>Full - time</option>
        <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <%
	  	if(vEditInfo !=null && vEditInfo.size() > 0)
			strEmpCatg = (String) vEditInfo.elementAt(1);
		else
		  	strEmpCatg = WI.fillTextValue("employee_category");
	  %>
      <td><select name="employee_category">
          <option value="2">All</option>
          <%if(strEmpCatg.equals("0")){%>
          <option value="0" selected>Staff</option>
          <option value="1">Faculty</option>
          <%}else if(strEmpCatg.equals("1")){%>
          <option value="0">Staff</option>
          <option value="1" selected>Faculty</option>
          <%}else{%>
          <option value="0">Staff</option>
          <option value="1">Faculty</option>
          <%}%>
        </select></td>
    </tr>
    <%}%>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2"><font size="1">Note: if there are no valid tax setting override then tax computation would be based on the tax table.</font></td>
    </tr>
    <tr> 
      <td height="31">&nbsp;</td>
      <td height="31" colspan="2" valign="bottom"> <div align="center"> 
          <% if (iAccessLevel > 1) {
	  if (strPrepareToEdit.length() == 0) {%>
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
 <% if (vRetResult != null) {%>
 
  <table width="100%" border="1" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <%if(false){%>
    <tr> 
      <td height="25" colspan="5"><div align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0" ></a>click 
          to print table</font></div></td>
    </tr>
    <%}%>
    <tr> 
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center"><strong>LIST 
          OF TAX SETTING </strong></div></td>
    </tr>
    <tr> 
      <td width="16%" height="24" align="center"><font size="1"><strong>EFFECTIVITY 
      DATE</strong></font></td>
      <td width="47%" align="center"><font size="1"><strong>APPLY TO</strong></font></td>
      <td align="center"><strong><font size="1">SETTING</font></strong></td>
      <td colspan="2" align="center"><strong><font size="1">OPTIONS</font></strong></td>
    </tr>
    <%
	for (int i = 0; i< vRetResult.size() ; i+=6){%>
    <tr> 
      <td height="30"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></font></td>
      <%  
	  	strTemp = "All ";
						
			strTemp += astrStatus[Integer.parseInt((String)vRetResult.elementAt(i+2))];
			strTemp += " " + astrCategory[Integer.parseInt((String)vRetResult.elementAt(i+1))];

	  %>
      <td valign="top"><font size="1">&nbsp;<%=strTemp%></font></td>
	  <%  
	  	strTemp = (String)vRetResult.elementAt(i+4) + "% of taxable income ";
		//strTemp += astrPay[Integer.parseInt((String)vRetResult.elementAt(i+5))];
	  %>
      <td width="19%"><font size="1"><%=strTemp%></font></td>
      <td width="9%"> <div align="center"> 
          <% if (iAccessLevel > 1) {%>
          <a href='javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>);'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a> 
          <%}else{%>
          NA 
          <%}%>
        </div></td>
      <td width="9%"> <div align="center"> 
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
    <tr bgcolor="#A49A6A"> 
      <td height="25"  colspan="3" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_reloaded" value="0">
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
