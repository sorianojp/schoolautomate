<%@ page language="java" import="utility.*,java.util.Vector,payroll.PayrollConfig" %>
<%
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
	location ="./set_items_included_comp_adtl_pay.jsp?year="+document.form_.year.value;
}

function ShowAll() {
	var pgLoc = "./set_items_included_comp_adtl_pay_all.jsp";
	var win=window.open(pgLoc,"ShowAll",'dependent=yes,width=700,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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
if (strPrepareToEdit.length() > 0){
	vEditInfo = pr.operateOnMonthPayComp(dbOP,request,3);
	if (vEditInfo == null)
		strErrMsg = pr.getErrMsg();
}

vRetResult = pr.operateOnMonthPayComp(dbOP,request,4);
if (vRetResult != null && strErrMsg == null){
	strErrMsg = pr.getErrMsg();	
}

String[] astrTypeLabel = {"Basic Salary","Gross Salary","Net Salary",""};
String[] astrOBI = {"Benefit", "Incentive", "Overtime",""};


%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./set_items_included_comp_adtl_pay.jsp" method="post" name="form_" id="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL: BONUS PARAMETERS : ITEMS INCLUDED IN ADDITIONAL 
      PAY COMPUTATION PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="4"><a href="addtl_mth_pay_main.jsp"><img src="../../../../images/go_back.gif" border="0"></a> 
        &nbsp;&nbsp; &nbsp;<%=WI.getStrValue(strErrMsg,"<font size='3' color='#FF0000'><strong>","</strong></font>","")%></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="29%">Payroll Year Effectivity : 
        <input name="year" type="text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyInteger('form_','year')" value="<%=WI.fillTextValue("year")%>" size="4" maxlength="4"></td>
      <td width="13%"><a href="javascript:ReloadPage()"><img src="../../../../images/form_proceed.gif" border="0"></a></td>
      <td width="56%"><a href="javascript:ShowAll();"><img src="../../../../images/show_list.gif" border="0"></a><font size="1">click 
        to show all list of items for all payroll year</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<% if (WI.fillTextValue("year").length() == 4) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="10" colspan="4"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="2%" height="26">&nbsp;</td>
      <td colspan="3">Salary Type: &nbsp;&nbsp;&nbsp; <select name="salary_type" onChange="ReloadPage()">
          <% for(int i =2 ; i >= 0 ; i--) { 
	if (Integer.parseInt(WI.getStrValue(request.getParameter("salary_type"),"2")) == i){ %>
          <option value="<%=i%>" selected><%=astrTypeLabel[i]%></option>
          <%}else{%>
          <option value="<%=i%>" ><%=astrTypeLabel[i]%></option>
          <%}}%>
        </select> </td>
    </tr>
    <% if (WI.fillTextValue("salary_type").compareTo("0") == 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3">&nbsp;plus (+) <font color="#FF0000" size="1">&nbsp;</font> &nbsp;&nbsp;&nbsp; 
        Item 2 : &nbsp;&nbsp;&nbsp; 
        <% strTemp = WI.getStrValue(request.getParameter("obi"),"2");%> <select name="obi" onChange="ReloadPage()">
          <option value="2">Overtimes</option>
          <% if (strTemp.compareTo("0") == 0) {%>
          <option value="0" selected>Benefits</option>
          <%}else{%>
          <option value="0">Benefits</option>
          <%}if (strTemp.compareTo("1") == 0) {%>
          <option value="1" selected>Incentives</option>
          <%}else{%>
          <option value="1" >Incentives</option>
          <%}%>
        </select> <% if (strTemp.compareTo("2") != 0) {%> <select name="benefit_index">
          <%=dbOP.loadCombo("distinct benefit_index","sub_type"," from hr_benefit_incentive where is_benefit = " + strTemp + " and is_del = 0",WI.fillTextValue("benefit_index"),false)%> </select> <%}%> </td>
    </tr>
    <%}%>
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20" valign="bottom">&nbsp;</td>
      <td height="20" valign="bottom">&nbsp;</td>
      <td height="20" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="17%" height="25">&nbsp;</td>
      <td width="62%" height="25"><a href="javascript:AddRecord()"><img src="../../../../images/add.gif" width="42" height="32" border="0"></a><font size="1">click 
        to save entries <a href="javascript:CancelRecord()"><img src="../../../../images/cancel.gif" border="0" ></a>click 
        to cancel/clear entries</font></td>
      <td width="19%" height="25"><font size="1">&nbsp;</font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10" colspan="3"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td width="1%">&nbsp;</td>
      <td width="57%">&nbsp;</td>
      <td width="42%" height="10" align="right">&nbsp;
<%if (vRetResult != null) {%>	  
	  <font size="1"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0" ></a>click 
          to print list</font>
<%}%> </td>
    </tr>
  </table>
  <% if (vRetResult != null) {  %>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center">LIST OF 
          ITEMS INCLUDED IN THE COMPUTATION OF ADDITIONAL MONTH PAY</div></td>
    </tr>
    <tr> 
      <td width="572" height="27"><div align="center"><strong><font size="1">ITEMS</font></strong></div></td>
      <td width="64"><div align="center"><strong><font size="1">OPTIONS</font></strong></div></td>
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
			strTemp = "(" + astrTypeLabel[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+2),"3"))] + " only)";%> <%=strTemp%></td>
      <td><div align="center"><a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../../images/delete.gif" width="55" height="28" border="0"></a></div></td>
    </tr>
    <% } //end for int i = 0 loop%>
  </table>
<%} //  vRetResult != null 
} // end year length != 4%>
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