<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRAddlPay" %>
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
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
	this.SubmitOnce("form_");
}
function EditRecord(){
	document.form_.page_action.value = "2";
	this.SubmitOnce("form_");
}

function DeleteRecord(strInfoIndex){
	document.form_.donot_call_close_wnd.value = "0";
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function CancelRecord(){
	document.form_.donot_call_close_wnd.value = "0";
	location ="./set_sub_bonus.jsp?year_of="+document.form_.year_of.value+
			  "&pay_index="+document.form_.pay_index.value;
}

function ReloadPage()
{
	document.form_.donot_call_close_wnd.value = "0";
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
 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Set Additional Month  Pay Parameters","set_sub_bonus.jsp");
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
														"set_sub_bonus.jsp");
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

PRAddlPay pr = new PRAddlPay();

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strPageAction = WI.fillTextValue("page_action");
if(strPageAction.length() > 0){
	if(pr.operateOnSubAddlPay(dbOP,request,Integer.parseInt(strPageAction)) == null)
		strErrMsg = pr.getErrMsg();
}

vRetResult = pr.operateOnSubAddlPay(dbOP,request,4);
if (vRetResult != null && strErrMsg == null){
	strErrMsg = pr.getErrMsg();	
}

%>

<body bgcolor="#D2AE72" onUnload="ReloadMain();" class="bgDynamic">
<form action="./set_sub_bonus.jsp" method="post" name="form_" id="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="29" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: SUBTRACT RELEASED ADDITIONAL PAY PAGE ::::</strong></font></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="2">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></td>
      <td><a href="javascript:CloseWindow();"><img src="../../../../images/close_window.gif" width="71" height="32" border="0"></a></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="23%">Additional month name :</td>
			<%
				strTemp = WI.fillTextValue("sub_index");
			%>
      <td width="56%"><select name="sub_index">
        <option value="">Select Additional Pay </option>
        <%=dbOP.loadCombo("pay_index","pay_name", " from pr_addl_pay_mgmt " +
					" where is_valid = 1 and year = " + WI.getStrValue(WI.fillTextValue("year_of"),"0") +
					" and pay_index <> " + WI.fillTextValue("pay_index") +
					" and not exists(select * from pr_addl_pay_sub where sub_pay_index = pay_index " +
					"     or main_pay_index = pay_index)", strTemp,false)%>
      </select></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20" valign="bottom">&nbsp;</td>
      <td height="20" valign="bottom">&nbsp;</td>
      <td height="20" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="34">&nbsp;</td>
      <td height="34" colspan="2" align="center"><a href="javascript:AddRecord()"><img src="../../../../images/add.gif" width="42" height="32" border="0"></a><font size="1">click 
        to save entries <a href="javascript:CancelRecord()"><img src="../../../../images/cancel.gif" border="0" ></a>click 
      to cancel / clear entries</font></td>
      <td width="19%" height="34"><font size="1">&nbsp;</font></td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="100%" height="10" colspan="3" align="center">
			<table width="75%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
        <tr bgcolor="#B9B292">
          <td height="25" colspan="2" align="center" class="thinborder"><font color="#FFFFFF"><strong>:: 
            List of Valid additional month pay :: </strong></font></td>
        </tr>
        <tr>
          <td width="83%" height="27" class="thinborderBOTTOMLEFT"><font size="1"><strong>ADDITIONAL 
            PAY NAME</strong></font></td>
          <td width="17%" height="27" class="thinborder">&nbsp;</td>
        </tr>
        <%for(int k = 0; k < vRetResult.size(); k+=2){%>
        <tr>
          <td height="26" class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(k+1)%></td>
          <td class="thinborder"><div align="center"> <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(k)%>");'> <img src="../../../../images/delete.gif" width="55" height="28" border="0"></a></div></td>
        </tr>
        <%		
				}// end for loop%>
      </table></td>
    </tr>
  </table>
	<%}%>
   <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  
	<input type="hidden" name="page_action">	
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="pay_index" value="<%=WI.fillTextValue("pay_index")%>">
	<input type="hidden" name="year_of" value="<%=WI.fillTextValue("year_of")%>">
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