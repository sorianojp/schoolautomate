<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction,payroll.PRSalary" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
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
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript">
<!--
function CloseWindow(){
//	if(document.form_.opner_form_name.value == "form_1"){
//		window.opener.document.form_1.donot_call_close_wnd.value="1";
//	}
	window.opener.document.<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"form_")%>.submit();
	window.opener.focus();
	self.close();		
}
function SaveData(){
	document.form_.savemisc.value = "1";
	this.SubmitOnce("form_");

	document.form_.close_wnd_called.value = "1";
	
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
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="post_ded_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","post_ded.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"post_ded.jsp");
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

String strSaveMisc = WI.fillTextValue("savemisc");
String strEmpID = WI.fillTextValue("emp_id");
if (strSaveMisc.equals("1")){
	vRetResult = Salary.operateOnMisc(dbOP,request);	
}else{
	vRetResult = Salary.getPeriodMisc(dbOP,strEmpID);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = Salary.getErrMsg();
}
%>
<body bgcolor="#D2AE72" onUnload="ReloadMain();" class="bgDynamic">
<form action="view_bonus_pay_misc.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PAYROLL: MISC. DEDUCTIONS : POST DEDUCTIONS PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="770" height="10">&nbsp;</td>
    </tr>
  </table>
<% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails!=null && vPersonalDetails.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="28" colspan="2"><%=WI.getStrValue(strErrMsg,"")%></td>
      <td width="16%"><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td width="5%" height="28">&nbsp;</td>
      <td height="28" colspan="2">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong> </td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29" colspan="2">Employee ID :<strong><%=WI.fillTextValue("emp_id")%></strong></td>
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
      <td height="29" colspan="2"><%if(bolIsSchool){%>
        College <%}else{%>
        Division <%}%>
        /Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29" colspan="2">Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29" colspan="2">Employment Status : <strong><%=(String)vPersonalDetails.elementAt(16)%></strong></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>

  <% if (vRetResult != null &&  vRetResult.size() > 0) {
	String strTDColor = null;//grey if already deducted.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="26" colspan="4" bgcolor="#B9B292" class="thinborder"><div align="center"><strong>LIST 
          OF POSTED MISCELLANEOUS DEDUCTIONS</strong></div></td>
    </tr>
    <tr> 
      <td width="18%" height="28" class="thinborder"><div align="center"><strong><font size="1">DEDUCTION 
          NAME</font></strong></div></td>
      <td width="3%" class="thinborder"><div align="center"><font size="1"><strong>AMOUNT</strong></font></div></td>
      <td width="4%" class="thinborder"><div align="center"><font size="1"><strong>AMOUNT 
          PAYABLE</strong></font></div></td>
      <td width="7%" class="thinborder"><div align="center"><font size="1"><strong>AMOUNT 
          TO PAY</strong></font></div></td>
    </tr>
    <% 	int iCount = 1;
	for (int i = 0; i < vRetResult.size(); i+=5,iCount++){
		strTemp = (String)vRetResult.elementAt(i+4);
	%>
    <tr> 
      <td height="25" class="thinborder"><font size="1">&nbsp;<%=(String)vRetResult.elementAt(i+3)%> 
        <input name="deduction_index<%=iCount%>" type="hidden" value="<%=WI.getStrValue(strTemp,"0")%>">
        </font></td>
      <td class="thinborder"><div align="center"><font size="1"> <%=(String)vRetResult.elementAt(i+2)%>&nbsp;</font></div></td>
      <td class="thinborder"><div align="right"><font size="1"><%=(String)vRetResult.elementAt(i+1)%> 
          <input name="balance<%=iCount%>" type="hidden" value="<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+1),true)%> ">
          </font></div></td>
      <td class="thinborder"><div align="center"><strong> 
          <input name="amount_to_pay<%=iCount%>" type="text" class="textbox" value="<%=WI.getStrValue((String)vRetResult.elementAt(i),"0")%>"
	    onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;" size="10" maxlength="10">
          <input name="old_amount<%=iCount%>" type="hidden" value="<%=WI.getStrValue((String)vRetResult.elementAt(i),"0")%>">
          </strong></div></td>
    </tr>
    <%} //end for loop%>
    <input type="hidden" name="num_misc" value="<%=iCount%>">
  </table>
  
<% } // end vRetResult != null && vRetResult.size() > 0

}// end if Employee ID is null %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF"><div align="center">
	    <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
		   <a href='javascript:SaveData();'>
			<img src="../../../images/save.gif" border="0" id="hide_save">
		   </a>
	  <font size="1">click to save entries</font>
	  <%}%>
	  </div></td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="savemisc">
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