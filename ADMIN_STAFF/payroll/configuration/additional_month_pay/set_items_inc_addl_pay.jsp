<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>PAYROLL: SET ADDITIONAL MONTH PAY PARAMETERS : NUMBER OF MONTHS FOR ADDITIONAL MONTH PAY PAGE</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--

function AddRecord(){
	document.form_.donot_call_close_wnd.value = "0";
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
	document.form_.donot_call_close_wnd.value = "0";
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function CancelRecord(){
	document.form_.donot_call_close_wnd.value = "0";
	location ="./set_items_inc_addl_pay.jsp?year="+document.form_.year.value+
			  "&salary_type=0&pay_index="+document.form_.pay_index.value;
}

function ReloadPage()
{
	document.form_.donot_call_close_wnd.value = "0";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function CloseWindow(){
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();		
}

function ReloadMain(){
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();

		window.opener.focus();
	}
}

-->
</script>
<%

	DBOperation dbOP = null;	
	String strErrMsg = "";
	String strTemp = null;
//add security here.

if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="set_items_included_comp_adtl_pay_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Set Additional Month  Pay Parameters","set_num_of_mths_pay.jsp");
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"set_num_of_mths_pay.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
Vector vEditInfo = null;

PayrollConfig pr = new PayrollConfig();

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");

if (strPageAction.length() > 0){
	if (strPageAction.compareTo("0")==0) {
		if (pr.operateOnMonthPayComp(dbOP,request,0) != null){
			strErrMsg = "  Item removed successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("1") == 0){
		if (pr.operateOnMonthPayComp(dbOP,request,1) != null){
			strErrMsg = " Item posted successfully ";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}else if(strPageAction.compareTo("2") == 0){
		if (pr.operateOnMonthPayComp(dbOP,request,2) != null){
			strErrMsg = " Item updated successfully ";
			strPrepareToEdit = "";
		}else{
			strErrMsg = pr.getErrMsg();
		}
	}
}

vRetResult = pr.operateOnMonthPayComp(dbOP,request,4);
if (vRetResult != null && strErrMsg == null){
	strErrMsg = pr.getErrMsg();	
}

String[] astrTypeLabel = {"Basic Salary","Gross Salary","Net Salary",""};
String[] astrOBI = {"Benefit", "Incentive", "Overtime",""};


%>

<body bgcolor="#D2AE72" onUnload="ReloadMain();" class="bgDynamic">
<form action="./set_items_inc_addl_pay.jsp" method="post" name="form_" id="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="29" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL:  BONUS PARAMETERS : ITEMS INCLUDED IN ADDITIONAL 
      PAY COMPUTATION PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
      <td><a href="javascript:CloseWindow();"><img src="../../../../images/close_window.gif" width="71" height="32" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;plus (+) <font color="#FF0000" size="1">&nbsp;</font> 
        &nbsp;&nbsp;&nbsp; Item 2 : &nbsp;&nbsp;&nbsp; <% strTemp = WI.fillTextValue("obi");%> 
		<select name="obi" onChange="ReloadPage()">
          <option value="">N/A</option>
          <% if (strTemp.compareTo("0") == 0) {%>
          <option value="0" selected>Benefits</option>
          <%}else{%>
          <option value="0">Benefits</option>
          <%}if (strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>Incentives</option>
          <%}else{%>
          <option value="1" >Incentives</option>
          <%}if (strTemp.compareTo("2") == 0) {%>
          <option value="2" selected>Overtime</option>
          <%}else{%>
          <option value="2" >Overtime</option>
          <%}%>
        </select> <% if (strTemp.compareTo("0") == 0 || strTemp.compareTo("1") == 0){%> <select name="benefit_index">
          <%=dbOP.loadCombo("distinct benefit_index","sub_type"," from hr_benefit_incentive where is_benefit = " + strTemp + " and is_del = 0",WI.fillTextValue("benefit_index"),false)%> </select> <%}%> </td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20" valign="bottom">&nbsp;</td>
      <td height="20" valign="bottom">&nbsp;</td>
      <td height="20" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="34">&nbsp;</td>
      <td width="17%" height="34">&nbsp;</td>
      <td width="62%" height="34"><a href="javascript:AddRecord()"><img src="../../../../images/add.gif" width="42" height="32" border="0"></a><font size="1">click 
        to save entries <a href="javascript:CancelRecord()"><img src="../../../../images/cancel.gif" border="0" ></a>click 
        to cancel / clear entries</font></td>
      <td width="19%" height="34"><font size="1">&nbsp;</font></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
  <% if (vRetResult != null) {  %>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2" align="center" bgcolor="#B9B292">LIST OF 
          ITEMS INCLUDED IN THE COMPUTATION OF ADDITIONAL MONTH PAY</td>
    </tr>
    <tr> 
      <td width="89%" height="27" align="center"><strong><font size="1">ITEMS</font></strong></td>
      <td width="11%" align="center"><strong><font size="1">OPTIONS</font></strong></td>
    </tr>
    <%  int j = 0 ; boolean bolShowHeaders = true;
	for (int i = 0; i < vRetResult.size(); i+=6 ){
		if ((String)vRetResult.elementAt(i+1) != null){
			bolShowHeaders = true; 	j = i;
		}
	if (bolShowHeaders) {
%>
    <tr> 
      <td height="25" colspan="2"> &nbsp; 
        <% for (;j < vRetResult.size(); j+=6){
		if (vRetResult.elementAt(j+1) != null && j != i){	
			bolShowHeaders = false;
			break;
	    }else{%>
        <font color="#0000FF"><strong><%=WI.getStrValue((String)vRetResult.elementAt(j+1), ""," :: " ,"")/*year*/%><%=astrTypeLabel[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(j+2),"3"))]/* salary type*/%></strong> 
        </font> <%}//end if else  inner loop
	}// end innner for loop 
	bolShowHeaders = false;
	%>
       </td>
    </tr>
    <%} //end bolShowHeaders%>
    <tr> 
      <td height="25"> &nbsp;++ 
        <% strTemp =(String)vRetResult.elementAt(i+5);
	   	if (strTemp == null)
			strTemp = astrOBI[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+3),"3"))]/* O B I */ + WI.getStrValue((String)vRetResult.elementAt(i+5)," (",")","")/*sub - type*/;
		if (strTemp.length() == 0)
			strTemp = "(" + astrTypeLabel[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+2),"3"))] + ")";%> <%=strTemp%></td>
      <td align="center"><a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/delete.gif" width="55" height="28" border="0"></a></td>
    </tr>
    <% } //end for int i = 0 loop%>
  </table>
<%} //  vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  
	<input type="hidden" name="year" value="<%=WI.fillTextValue("year")%>">  
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="print_page">
	<input type="hidden" name="pay_index" value="<%=WI.fillTextValue("pay_index")%>">
	<input type="hidden" name="salary_type" value="<%=WI.fillTextValue("salary_type")%>">
  <!-- this is used to reload parent if Close window is not clicked. -->
    <input type="hidden" name="close_wnd_called" value="0">
    <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
	
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>