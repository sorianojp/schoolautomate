<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.update_schfac.fee_name_val.value = document.update_schfac.fee_name[document.update_schfac.fee_name.selectedIndex].text;
	document.update_schfac.submit();
}
function ChangeFeeRate()
{
	if(document.update_schfac.fee_.selectedIndex ==0) //no change.
		document.update_schfac.amount.value = document.update_schfac.amount_prev.value;
	else
		document.update_schfac.amount.value = "";
}
function CheckAmount()
{
	if(document.update_schfac.fee_.selectedIndex ==0) //no change.
	{
		if(document.update_schfac.amount.value != document.update_schfac.amount_prev.value)
		{
			alert("Previous and new amount is same. Please select specific amount to change new fee rate.");
			document.update_schfac.amount.value == document.update_schfac.amount_prev.value;
		}
	}
}
function PageAction(strAction)
{
	document.update_schfac.page_action.value=strAction;
	document.update_schfac.submit();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FASchoolFacility,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strMultipleCharge = "";

	String strPrepareToEdit=WI.fillTextValue("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
	String strAmount = null;
	boolean bolShowDetail = false;
	if( WI.fillTextValue("sy_from_prev").length() > 0 && WI.fillTextValue("sy_to_prev").length() > 0)
		bolShowDetail = true;


//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-update sch facility fee","update_sch_facil_fee.jsp");
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
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"update_sch_facil_fee.jsp");
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

FASchoolFacility schFacility = new FASchoolFacility();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0)
{ //add here.
	//either add single or add multiple fee types.
	if(!schFacility.updateSchFacFee(dbOP,request,Integer.parseInt(strTemp)))
		strErrMsg = schFacility.getErrMsg();
	else
		strErrMsg = "Fee copied successfully.";
}

Vector vSingleFeeList = schFacility.opOnSchFacTypeSingleFee(dbOP, request,3);//view all - current year.
strTemp = WI.fillTextValue("sy_from_prev");
strTemp2= WI.fillTextValue("sy_to_prev");
if(strTemp.length() ==0) strTemp = "0";
if(strTemp2.length() == 0) strTemp2 = "0";

Vector vSingleFeeListPrev = schFacility.opOnSchFacTypeSingleFee(dbOP, request,3,strTemp,strTemp2);//System.out.println(schFacility.getErrMsg());
//keep the parent index in request object .
request.setAttribute("parent_index",request.getParameter("fee_name"));
Vector vMulFeeList 	  = schFacility.opOnSchFacTypeMultipleFee(dbOP,request,3);//view all multiple type fees.
boolean bolProceed = true;

if(strErrMsg == null) strErrMsg = "";
//check for add - edit or delete
%>
<form name="update_schfac" action="./update_sch_facil_fee.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          UPDATE SCHOOL FACILITIES FEES MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="5">&nbsp;&nbsp;&nbsp;<strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="20%">School Year(previous)</td>
      <td  colspan="2"> <input name="sy_from_prev" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from_prev")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("update_schfac","sy_from_prev","sy_to_prev")'>
        to
        <input name="sy_to_prev" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to_prev")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
      </td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>New Updated SY</td>
      <td  colspan="3"> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("update_schfac","sy_from","sy_to")'>
        to
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"
	  readonly="yes">
        <input type="image" src="../../../images/view.gif">
        <font size="1"><em>View fees detail for this year </em> <strong>(OR)</strong>
        <%
		if(iAccessLevel > 1){%>
		<a href='javascript:PageAction("1");'><img src="../../../images/copy_all.gif" border="0"></a>copy
        all fee from prev. school year.
		<%}%></font> </td>
    </tr>
<%
if(bolShowDetail){//only if it is having any valid year entry.
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>School Facility Fee Name </td>
      <td  colspan="3"> <select name="fee_name" onChange="ReloadPage();">
          <option value="0">Select a fee</option>
<%
strTemp = WI.fillTextValue("sy_from_prev");
strTemp2 = WI.fillTextValue("sy_to_prev");
if(strTemp.length() ==0) strTemp = "0";
if(strTemp2.length() ==0) strTemp2 = "0";
strTemp = " from FA_SCH_FACILITY join FA_SCHYR on (FA_SCH_FACILITY.sy_index=FA_SCHYR.sy_index) "+
				"where is_del=0 and is_valid=1 and sy_from="+strTemp+" and sy_to="+strTemp2+" order by fee_name,facility_type asc";
%>

<%=dbOP.loadCombo("SCH_FAC_FEE_INDEX","FEE_NAME",strTemp, WI.fillTextValue("fee_name"), false)%>
        </select>
        <select name="multiple_charge_name">
<%
strTemp = WI.fillTextValue("fee_name");
if(strTemp.length() ==0) strTemp = "0";
strTemp = " from FA_SCH_FACILITY_VAR_PAYABLE where is_del=0 and SCH_FAC_FEE_INDEX="+strTemp+" order by fee_name asc";
strMultipleCharge = dbOP.loadCombo("VAR_PAYABLE_INDEX","FEE_NAME",strTemp, WI.fillTextValue("multiple_charge_name"), false);
%>

<%=strMultipleCharge%>

        </select> <font size="1"><em>(fees available for year <%=WI.fillTextValue("sy_from_prev")%>-<%=WI.fillTextValue("sy_to_prev")%>
        to add to new school year)</em></font></td>
    </tr>
<%//only if fee name is selected and the fee name is not multiple charges type.
if(WI.fillTextValue("fee_name").length() >0 && WI.fillTextValue("fee_name").compareTo("0") != 0){
	if( strMultipleCharge.length() == 0){%>
   <tr>
      <td height="25">&nbsp;</td>
      <td>Fee Rate (prev)</td>
      <td  colspan="2">
<%
strTemp = WI.fillTextValue("fee_name");
if(strTemp.length() ==0) strTemp = "0";
strAmount = dbOP.mapOneToOther("FA_SCH_FACILITY","SCH_FAC_FEE_INDEX",strTemp,"amount",null);
if(strAmount != null){%>
<%=strAmount%> Php
<input type="hidden" name="amount_prev" value="<%=strAmount%>">
<%}%>
	  </td>
      <td width="51%">&nbsp; </td>
    </tr>
<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee Amount</td>
      <td  colspan="3"> <select name="fee_" onChange="ChangeFeeRate();">
          <option value="0">No change</option>
          <option value="1">Specific amount</option>
        </select>
<input name="amount" type="text" size="16" onChange="CheckIfLegal();" value="<%=WI.fillTextValue("amount")%>" onKeyUp="CheckAmount();">
      </td>
    </tr> -->
<%}//only if  strMultipleCharge.length() == 0%>
<!--    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp; </td>
      <td colspan="3"> <a href='javascript:PageAction("0");'><img src="../../../images/add.gif" border="0"></a><font size="1">click
        to add fee one by one</font></td>
    </tr> -->
<%	}//only if there is a prev year fee selected.
}//end of displaying detail if bolShowDetail = true
%>
<tr>
      <td>&nbsp;</td>
      <td>&nbsp; </td>
      <td colspan="3">&nbsp; </td>
    </tr>
  </table>
<%
if(vSingleFeeList != null && vSingleFeeList.size() > 0 && strMultipleCharge.length() ==0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5" bgcolor="#B9B292"><div align="center">UPDATED
          FEE LIST FOR YEAR - <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="40%" height="25" align="center"><font size="1"><strong>SCHOOL
        FACILITY FEE NAME</strong></font></td>
      <td width="12%" align="center"><font size="1"><strong>RATE FOR PREV. YR</strong></font></td>
      <td width="12%" align="center"><font size="1"><strong>INCREASED AMOUNT</strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>NEW RATE (<%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>)</strong></font></td>
    </tr>
<%
float fPrevRate = 0;
float fIncrAmt = 0;
int iIndex = 0;

for(int i=0; i<vSingleFeeList.size();++i){
	if(vSingleFeeListPrev != null && (iIndex = vSingleFeeListPrev.indexOf(vSingleFeeList.elementAt(i))) != -1 &&
		vSingleFeeList.elementAt(i+1) != null)
	{
		fPrevRate = Float.parseFloat((String)vSingleFeeListPrev.elementAt(iIndex+1));
		fIncrAmt  = fPrevRate - Float.parseFloat((String)vSingleFeeList.elementAt(i+1));//System.out.println(vSingleFeeListPrev.elementAt(iIndex+1));
	}
	else
	{fPrevRate = 0;fIncrAmt = 0;}
 %>
    <tr>
      <td height="25" align="center"><%=(String)vSingleFeeList.elementAt(i)%></td>
      <td align="center"><%=fPrevRate%></td>
      <td align="center"><%=fIncrAmt%></td>
      <td align="center">&nbsp;<%=WI.getStrValue(vSingleFeeList.elementAt(i+1))%></td>
    </tr>
<%
i = i+5;
}%>
  </table>
<%}
else if(vMulFeeList != null && vMulFeeList.size() > 0){%>

   <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5" bgcolor="#B9B292"><div align="center">UPDATED
          LIST OF CHARGES FOR FEE <strong><%=request.getParameter("fee_name_val").toUpperCase()%></strong> FOR YEAR - <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="34%" height="25" align="center"><font size="1"><strong>CHARGES</strong></font></td>
      <td width="30%" align="center"><font size="1"><strong>UNIT</strong></font></td>
    </tr>
<%
for(int i=0; i< vMulFeeList.size(); ++i){%>
    <tr>
      <td height="25" align="center"><%=(String)vMulFeeList.elementAt(i)%></td>
      <td align="center"><%=(String)vMulFeeList.elementAt(i+1)%></td>
    </tr>
<%
i = i+3;
}%>
  </table>
 <%}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <input type="hidden" name="fee_name_val">
  <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
