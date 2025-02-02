<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function goBack()
{
	location = "fm_sch_facil_fee.jsp?sy_from="+document.schfac_fee.sy_from.value+"&sy_to="+document.schfac_fee.sy_to.value+
		"&fee_name="+escape(document.schfac_fee.fee_name.value)+"&account_type="+document.schfac_fee.account_type.value+
		"&facility_type=1";
}
function PrepareToEdit(strInfoIndex)
{
	document.schfac_fee.prepareToEdit.value = 1;
	document.schfac_fee.reloadPage.value = "0";
	document.schfac_fee.info_index.value = strInfoIndex;
	document.schfac_fee.submit();

}
function AddRecord()
{
	if(document.schfac_fee.prepareToEdit.value == 1)
	{
		EditRecord(document.schfac_fee.info_index.value);
		return;
	}
	document.schfac_fee.page_action.value = "1";
	document.schfac_fee.submit();
}
function EditRecord(strTargetIndex)
{
	document.schfac_fee.page_action.value = "2";
	document.schfac_fee.info_index.value = strTargetIndex;
	document.schfac_fee.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.schfac_fee.page_action.value = "0";
	document.schfac_fee.info_index.value = strTargetIndex;
	document.schfac_fee.submit();
}
function CancelRecord()
{
	document.schfac_fee.page_action.value= "";
	document.schfac_fee.info_index.value = "";
	document.schfac_fee.prepareToEdit.value = "0";
	document.schfac_fee.submit();
}
function ReloadPage()
{
	document.schfac_fee.reloadPage.value="1";
	document.schfac_fee.submit();
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
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
	boolean bolIsReloadCalled = false;
	if(WI.fillTextValue("reloadPage").compareTo("1") ==0)
		bolIsReloadCalled = true;
	String strFeeType = null;//single charge or multiple charge. - for multiple charge proceed.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-sch multiple fee","fm_schl_fees_multiple_fee.jsp");
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
														"fm_schl_fees_multiple_fee.jsp");
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
boolean bolProceed = true;

//check for add - edit or delete
strTemp = WI.fillTextValue("page_action");
if(strTemp.compareTo("1") == 0)
{
	strPrepareToEdit="0";
	//add it here and give a message.
	if(schFacility.opOnSchFacTypeMultipleFee(dbOP,request,1) != null)
		strErrMsg = "School facility fee(Multiple type) added successfully.";
	else
	{
		bolProceed = false;
		strErrMsg = schFacility.getErrMsg();
	}
}
else if(strTemp.compareTo("2") ==0)
{
	if(schFacility.opOnSchFacTypeMultipleFee(dbOP,request,2) != null)
	{
		strPrepareToEdit = "0"; //only if there is an error.
		strErrMsg = "School facility fee(Multiple type) edited successfully.";
	}
	else
	{
		bolProceed = false;
		strErrMsg = schFacility.getErrMsg();
	}
}
else if(strTemp.compareTo("0") ==0)
{
	strPrepareToEdit="0";
	if(schFacility.opOnSchFacTypeMultipleFee(dbOP,request,0) != null)
		strErrMsg = "School facility fee(Multiple type) deleted successfully.";
	else
	{
		bolProceed = false;
		strErrMsg = schFacility.getErrMsg();
	}
}

//get all levels created.
Vector vRetResult = new Vector();
Vector vEditInfo = new Vector();
//get here index of the parent school facility type to which these facilities will be tagged.
String strParentIndex = request.getParameter("parent_index");
if(strParentIndex == null || strParentIndex.trim().length() ==0)
{
	strParentIndex = schFacility.getSchFacSingleEntryIndex(dbOP, request,true);
	if(strParentIndex == null)
	{
		strErrMsg = schFacility.getErrMsg();
		bolProceed = false;
	}
	else
		request.setAttribute("parent_index",strParentIndex);
}


if(bolProceed)
	vRetResult = schFacility.opOnSchFacTypeMultipleFee(dbOP,request,3);//to view all

if(bolProceed && strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo =  schFacility.opOnSchFacTypeMultipleFee(dbOP,request,4);//to view one
	if(vEditInfo == null || vEditInfo.size() == 0)
	{
		bolProceed = false;
		strErrMsg = schFacility.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "Edit information not found. Please try again.";
	}
}


dbOP.cleanUP();

//do not proceed is bolProceed = false;
if(!bolProceed)
{
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="2">
	<b><%=strErrMsg%></b></font></p>
	<%
	return;
}
if(strErrMsg == null) strErrMsg = "";
String[] astrConvertAccountType = {"Internal","External","both"};
%>


<form name="schfac_fee" action="./fm_schl_fees_multiple_entry.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="30" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          SCHOOL FACILITIES FEES MAINTENANCE PAGE ::::<br>
          <font size="1">MULTIPLE CHARGES ENTRY</font></strong></font></div></td>
    </tr>
	</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4"><a href="javascript:goBack();"><img src="../../../images/go_back.gif" border="0"></a>
        &nbsp;&nbsp;&nbsp; <strong><%=strErrMsg%></strong></td>
    </tr>
    <tr>
      <td width="5%" height="26">&nbsp;</td>
      <td width="34%">Fee name : <strong><%=request.getParameter("fee_name")%></strong></td>
      <td width="31%">School Year : <strong><%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong></td>
      <td width="30%">Accounts : <strong><%=astrConvertAccountType[Integer.parseInt(request.getParameter("account_type"))]%></strong></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>
  </table>


  <table  bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="5%" height="25" >&nbsp;</td>
      <td width="14%" >Charges name </td>
      <td width="37%" >
<%
	if(vEditInfo != null && vEditInfo.size() > 1 && !bolIsReloadCalled)
		strTemp = (String)vEditInfo.elementAt(0);
	else
		strTemp = WI.fillTextValue("name");
%>
	  <input name="name" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td width="5%" >Unit</td>
      <td width="39%" ><select name="usage_unit">
          <option>per hour</option>
          <%
	if(vEditInfo != null && vEditInfo.size() > 1 && !bolIsReloadCalled)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = WI.fillTextValue("usage_unit");
	if(strTemp.compareTo("per day") ==0){%>
          <option selected>per day</option>
          <%}else{%>
          <option>per day</option>
          <%}if(strTemp.compareTo("per week") ==0){%>
          <option selected>per week</option>
          <%}else{%>
          <option>per week</option>
          <%}if(strTemp.compareTo("per month") ==0){%>
          <option selected>per month</option>
          <%}else{%>
          <option>per month</option>
          <%}if(strTemp.compareTo("per request") == 0){%>
          <option selected>per request</option>
          <%}else{%>
          <option>per request</option>
          <%}if(strTemp.compareTo("per card") ==0){%>
          <option selected>per card</option>
          <%}else{%>
          <option>per card</option>
          <%}%>
        </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
<%if(iAccessLevel > 1){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;
        <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a><font size="1">click
        to save entry</font>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}%>
      </td>
    </tr>
	<%}//if iAccessLevel > 1%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="4"><div align="center"><font size="2">LIST OF CHARGES
          UNDER THIS SCHOOL FACILITIES FEE</font></div></td>
	 </tr>
</table>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="43%" height="24"><div align="center"><font size="1"><strong>CHARGES
          NAME </strong></font></div></td>
      <td width="21%"><div align="center"><font size="1"><strong>UNIT</strong></font></div></td>
      <td width="10%"><div align="center"><strong>EDIT</strong></div></td>
      <td width="26%"><strong>DELETE</strong></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size() ; ++i)
{%>
    <tr>
      <td height="25" align="center"><font size="1"><%=(String)vRetResult.elementAt(i)%></font></td>
      <td align="center"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
 <td align="center">
  <%if(iAccessLevel > 1){%>
      <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i+2)%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
  <%}else{%>Not authorized<%}%>
	  </td>
   <td>
   <%if(iAccessLevel== 2){%>
       <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i+2)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
   <%}else{%>Not authorized<%}%>
	  </td>
    </tr>
    <% i = i+3;
	}//end of displaying levels
%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
   <!-- all hidden fields go here -->
  <%
strTemp = WI.fillTextValue("info_index");
if(strTemp.length() ==0) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="reloadPage" value="<%=WI.fillTextValue("reloadPage")%>">

 <!-- from previous page -->
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input type="hidden" name="fee_name" value="<%=WI.fillTextValue("fee_name")%>">
<input type="hidden" name="account_type" value="<%=WI.fillTextValue("account_type")%>">
<input type="hidden" name="parent_index" value="<%=strParentIndex%>">
</form>
</body>
</html>
