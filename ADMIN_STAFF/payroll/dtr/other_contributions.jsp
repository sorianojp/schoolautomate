<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRSalary"%>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
	///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
	
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
function SaveData(){
	document.form_.saveothercons.value = "1";
	this.SubmitOnce("form_");
	document.form_.close_wnd_called.value = "1";
	
<% if (WI.fillTextValue("opner_form_field").length() != 0){%>
		window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>[window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>.selectedIndex].value = 
		document.form_.opner_form_field_value.value;
<% }%>	
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();
}

function ReloadMain(){
<% if (WI.fillTextValue("opner_form_field").length() != 0){%>
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>[window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.<%=WI.fillTextValue("opner_form_field")%>.selectedIndex].value = 
		document.form_.opner_form_field_value.value;
<% }%>

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
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Other Contributions","other_contributions.jsp");
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
														"Payroll","DTR",request.getRemoteAddr(),
														"other_contributions.jsp");
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
Vector vPersonalDetails = null;
Vector vRetResult = null;

PRSalary Salary = new PRSalary();

if (WI.fillTextValue("emp_id").length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	if (vPersonalDetails == null || vPersonalDetails.size()==0){
		strErrMsg = authentication.getErrMsg();
		vPersonalDetails = null;
	}
}

String strSaveCons = WI.fillTextValue("saveothercons");
if (strSaveCons.equals("1")){
	vRetResult = Salary.operateOnContributions(dbOP,request);	
}else{
	vRetResult = Salary.getPeriodOtherCons(dbOP,WI.fillTextValue("sal_index"));
}

%>

<body bgcolor="#D2AE72" onUnload="ReloadMain();" class="bgDynamic">
<form name="form_" method="post" action="./other_contributions.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL : OTHER CONTRIBUTIONS PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="14%" colspan="4"><strong>&nbsp;&nbsp;</strong> <strong></strong></td>
    </tr>
  </table>

<% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails!=null && vPersonalDetails.size() > 0){ %>

	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="10" colspan="2"><hr size="1"></td>
    </tr>
    <tr> 
      <td width="6%" height="29">&nbsp;</td>
      <td height="29">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong> </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29">Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="29"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Department/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td>Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>

    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td width="94%">Employment Status<strong> : <%=(String)vPersonalDetails.elementAt(16)%> </strong></td>

    </tr>
    <tr> 
      <td height="25" colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
  <% 
  if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10"><div align="right"></div></td>
    </tr>
  </table>
  
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" align="center" bgcolor="#B9B292"><font color="#000000" ><strong>OTHER 
      CONTRIBUTIONS</strong></font></td>
    </tr>
    <tr> 
      <td height="30" align="center"><strong><font size="1">CONTRIBUTION</font></strong></td>
      <td width="41%" align="center"><font size="1"><strong>EMPLOYEE SHARE</strong></font></td>
      <td width="19%" align="center"><font size="1"><strong>PAYMENT</strong></font></td>
    </tr>
    <% int iCount = 1;
		for (int i = 0; i < vRetResult.size() ; i+=4, iCount++){
			strTemp = (String)vRetResult.elementAt(i+2);			
	%>
    <tr> 
      <td height="25" align="center"><%=(String)vRetResult.elementAt(i + 1)%>        <input name="deduction_index<%=iCount%>" type="hidden" value="<%=WI.getStrValue(strTemp,"0")%>"></td>
      <td align="center">      <font size="1"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+3),true)%></font></td>
      <td align="center"><strong> 
        <input name="amount_to_pay<%=iCount%>" type="text" class="textbox" value="<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i),true)%>"
	    onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
		size="10" maxlength="10">
        <input name="old_amount<%=iCount%>" type="hidden" value="<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i),true)%>">
        </strong></td>
    </tr>
    <%}//end for%>
    <input type="hidden" name="num_cons" value="<%=iCount%>">
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" align="center" bgcolor="#FFFFFF"><font size="1">
        <a href='javascript:SaveData();'>
        <img src="../../../images/save.gif" border="0" id="hide_save">        </a>click to save entries</font></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
 <%}}%> 
<input type="hidden" name="saveothercons">
<input name="emp_id" type="hidden" value="<%=WI.fillTextValue("emp_id")%>"> 
<input name="sal_index" type="hidden" value="<%=WI.fillTextValue("sal_index")%>"> 
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