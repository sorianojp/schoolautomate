<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoExitInterview,hr.HRInfoServiceRecord"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="Javascript">

function AddRecord(){
	document.staff_profile.page_action.value="6";
	document.staff_profile.donot_call_close_wnd.value = "1";
	document.staff_profile.hide_save.src = "";
	document.staff_profile.submit();
}

function CloseWindow(){
	document.staff_profile.close_wnd_called.value = "1";
	window.opener.document.staff_profile.submit();
	window.opener.focus();
	self.close();
}

function ReloadParentWnd() {

	if(document.staff_profile.donot_call_close_wnd.value.length >0)
		return;

	if(document.staff_profile.close_wnd_called.value == "0") {
		window.opener.document.staff_profile.submit();
		window.opener.focus();
	}
}



</script>


<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_rehire_employee.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_rehire_employee.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp == null) 
	strTemp = "";
//

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

HRInfoExitInterview hrPx = new HRInfoExitInterview();

Vector vRetResult = null;


if (WI.fillTextValue("page_action").equals("6")){

	if (hrPx.operateOnRehire(dbOP,request,6) != null) {
		strErrMsg = " Employee Rehire Corfirmed";
	}else{
		strErrMsg = hrPx.getErrMsg();
	}
} 

vRetResult = hrPx.operateOnRehire(dbOP,request,3);

if (vRetResult == null && strErrMsg == null){
	strErrMsg = hrPx.getErrMsg();
}


%>
<body  onUnload="ReloadParentWnd();">
<form action="./hr_rehire_emp_confirm.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="83%" height="25">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
      <td width="17%" height="25"><a href="javascript:CloseWindow()"><img src="../../../images/close_window.gif" width="71" height="32" border="0"></a></td>
    </tr>
    <tr>
      <td height="25" colspan="2" bgcolor="#F8EAE0"><div align="center"><strong>::::
      EMPLOYEE RE-HIRE CONFIRMATION PAGE::::</strong></div></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="100%"><table width="100%" border="0" align="center" cellpadding="2" cellspacing="0">
          <tr>
            <td height="30">Employee Name :  </td>
            <td height="25"><font color="#FF0000" size="3"><strong> <%=(String)vRetResult.elementAt(1)%></strong></font>
			<input type="hidden" name="emp_index" value="<%=(String)vRetResult.elementAt(0)%>">			</td>
          </tr>
          <tr> 
            <td width="22%" height="30">Date of Re-hire : </td>
            <td width="78%"> 
			<input name="date_rehire" type="text" class="textbox"  size="10"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="AllowOnlyIntegerExtn('staff_profile','date_rehire','/')" 
			value="<%=WI.getStrValue((String)vRetResult.elementAt(2))%>"> 
			
            <a href="javascript:show_calendar('staff_profile.date_rehire');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
            &nbsp;</td>
          </tr>
          <tr> 
            <td height="30">Interviewed by : </td>
            <td> <%=WI.getStrValue((String)vRetResult.elementAt(5))%></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td>&nbsp;</td>
          </tr>
  
          <tr>
            <td height="15">Remarks / Notes : </td>
            <td height="15"><%=WI.getStrValue((String)vRetResult.elementAt(6), "NONE")%></td>
          </tr>
        </table>
        <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0">
          <tr> 
            <td height="15" colspan="2" valign="bottom">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="2"><div align="center"> 
                <% if (iAccessLevel > 1 && ((String)vRetResult.elementAt(3)).equals("0")){%>
                <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
                <font size="1">click to save confirmation </font> 
                <%} // if iAccessLevel > 1%>
              </div></td>
          </tr>
        </table>
        </td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action" >
  
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
