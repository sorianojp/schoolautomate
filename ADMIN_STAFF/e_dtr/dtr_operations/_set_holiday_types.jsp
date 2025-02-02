<%@ page language="java" import="utility.*,java.util.Vector,eDTR.Holidays" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[0]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script>
<!--

function AddRecord(){
	document.dtr_op.page_action.value ="1";
	document.dtr_op.submit();
}
function DeleteRecord(strTargetIndex)
{
	document.dtr_op.info_index.value = strTargetIndex;
	document.dtr_op.page_action.value = "3";
	document.dtr_op.submit();
}
function EditRecord(){
	document.dtr_op.page_action.value = "2";
	document.dtr_op.submit();
}

function PrepareToEdit(strIndex){
	document.dtr_op.prepareToEdit.value = "1";
	document.dtr_op.info_index.value = strIndex;
	document.dtr_op.submit();
}

function CloseWindow()
{
	window.opener.document.dtr_op.submit()
	window.opener.focus();
	self.close();
}

function CancelRecord(){
	location = "./set_holiday_types.jsp";
}
-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strPrepareToEdit = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-DTR OPERATIONS","set_holiday_types.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"set_holiday_types.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = new Vector();
Vector vRetEditResult= new Vector();
Holidays hol = new Holidays();
boolean bolFatalErr = true;
String strPageAction = WI.fillTextValue("page_action");
strPrepareToEdit = WI.fillTextValue("prepareToEdit");

int iPageAction = Integer.parseInt(WI.getStrValue(strPageAction,"0"));

switch (iPageAction){
  case 1: {vRetResult = hol.operateOnHolidayType(dbOP,request,iPageAction);
			if (vRetResult != null){
				strErrMsg = " Holiday type added successfully ";
			}else{
				strErrMsg = hol.getErrMsg();
				vRetResult = hol.operateOnHolidayType(dbOP,request,0);
			}
			break;
		  }
 case 2: {
 			vRetResult = hol.operateOnHolidayType(dbOP,request,iPageAction);
			if (vRetResult != null){
				strErrMsg = " Holiday type edited successfully ";
				strPrepareToEdit = "0";
			}else{
				strErrMsg = hol.getErrMsg();
				vRetResult = hol.operateOnHolidayType(dbOP,request,0);
			}
			break;
		 }
 case 3:{
			vRetResult = hol.operateOnHolidayType(dbOP,request,iPageAction);

			if (vRetResult != null){
				strErrMsg = " Holiday type removed successfully ";
			}else{
				strErrMsg = hol.getErrMsg();
				vRetResult = hol.operateOnHolidayType(dbOP,request,0);
			}
			break;
		}
 default : vRetResult = hol.operateOnHolidayType(dbOP,request,0);
}

if (strPrepareToEdit.compareTo("1") == 0){
	vRetEditResult = hol.getHolidayType(dbOP, WI.fillTextValue("info_index"));

	if (vRetEditResult == null){
		strErrMsg = hol.getErrMsg();
	}else{
		bolFatalErr = false;
	}
}

%>
<form action="./set_holiday_types.jsp" method="post" name="dtr_op">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" ><strong>::::
      HOLIDAY TYPES MAINTENANCE PAGE ::::</strong></font></td>
    </tr>
    <tr>
      <td height="25"><font size=3><strong><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a><%=WI.getStrValue(strErrMsg,"")%></strong></font></td>
    </tr>
  </table>

  <%
	if (!bolFatalErr){
		strTemp   = (String)vRetEditResult.elementAt(0);
		if (((String)vRetEditResult.elementAt(1)).compareTo("Percentage")==0)
			strTemp2 = "0";
		else
			strTemp2 = "1";
	}else{
		strTemp  = WI.fillTextValue("HolidayType");
		strTemp2 = WI.fillTextValue("rate_unit");
	}
%>
  <table width="100%" border="0" align="center" bgcolor="#FFFFFF">
    <tr>
      <td width="65" height="25">&nbsp;</td>
      <td width="114"> Holiday Type</td>
      <td width="506"><input name="HolidayType" type="text" class="textbox" id="HolidayType" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="45"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Rate/Unit</td>
      <td> <select name="rate_unit" id="rate_unit">
          <option value="0">Percentage</option>
<%if (strTemp2.equals("1")){%>
          <option value="1" selected>Specific Amount</option>
<%}else{%>
          <option value="1">Specific Amount</option>
<%}

	if (!bolFatalErr)
		strTemp = (String)vRetEditResult.elementAt(2);
	else
		strTemp = WI.fillTextValue("rate_amount");
%>
        </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Rate/Amount</td>
      <td><strong>
        <input name="rate_amount" type="text" class="textbox" id="rate_amount" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="6" maxlength="6">
        </strong></td>
    </tr>
    <tr>
      <td colspan="3"> <div align="center">
          <%
if(strPrepareToEdit.compareTo("1") == 0)
{%>
          <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a><font size="1">click
          to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" width="51" height="26" border="0"></a>
          <font size="1">click to cancel or go previous</font>
<%}else{%>
          <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a><font size="1">click
          to add</font>
<%}%>
        </div></td>
    </tr>
    <tr>
      <td colspan="3"><hr size="1"></td>
    </tr>
  </table>

<%if (vRetResult!=null && vRetResult.size()>0) {%>
  <table width="100%" border="0" align="center" cellpadding="3" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="21" colspan="4" bgcolor="#B9B292"><div align="center"><strong>LIST OF HOLIDAY
          TYPES </strong></div></td>
    </tr>
    <tr>
      <td width="29%"><strong><font size="1">HOLIDAY TYPE</font></strong></td>
      <td width="26%"><strong><font size="1">RATE/UNIT</font></strong></td>
      <td width="20%"><strong><font size="1">AMOUNT</font></strong></td>
      <td width="25%"><strong><font size="1">EDIT/DELETE</font></strong></td>
    </tr>
<% 	for (int i  = 0 ; i < vRetResult.size(); i+=4) {

	strTemp = (String)vRetResult.elementAt(i+1);
	strTemp2 = CommonUtil.formatFloat((String)vRetResult.elementAt(i+2),true);

	if (strTemp.compareTo("Percentage") == 0){
		strTemp2 = strTemp2 + "%";
	}else{
		strTemp2 = "Php " + strTemp2;
	}
%>
    <tr>
      <td><p><%=(String)vRetResult.elementAt(i)%><br>
         </p></td>
      <td><%=strTemp%></td>
      <td><%=strTemp2%></td>
      <td> <font size="1">
<%if(iAccessLevel > 1){%>
             <a href='javascript:PrepareToEdit("<%=vRetResult.elementAt(i+3)%>");'><image src="../../../images/edit.gif" border="0"></a>
<%if(iAccessLevel ==2){%>
              <a href='javascript:DeleteRecord("<%=vRetResult.elementAt(i+3)%>")'><img src="../../../images/delete.gif" border="0"></a>
<%}}%>&nbsp;
</font></td>
    </tr>
<%} // end for loop %>
    <tr>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
  </table>
<%} // if vRetResult != null%>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="24"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>


