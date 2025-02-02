<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/common.js"></script>
<script language="JavaScript">
function PrepareToEdit(strInfoIndex)
{
	document.oth_sfee.editRecord.value = 0;
	document.oth_sfee.deleteRecord.value = 0;
	document.oth_sfee.addRecord.value = 0;
	document.oth_sfee.prepareToEdit.value = 1;
	document.oth_sfee.info_index.value = strInfoIndex;
	document.oth_sfee.submit();

}
function AddRecord()
{
	if(document.oth_sfee.prepareToEdit.value == 1)
	{
		EditRecord(document.oth_sfee.info_index.value);
		return;
	}
	document.oth_sfee.editRecord.value = 0;
	document.oth_sfee.deleteRecord.value = 0;
	document.oth_sfee.addRecord.value = 1;

	document.oth_sfee.submit();
}
function EditRecord(strTargetIndex)
{
	document.oth_sfee.editRecord.value = 1;
	document.oth_sfee.deleteRecord.value = 0;
	document.oth_sfee.addRecord.value = 0;

	document.oth_sfee.info_index.value = strTargetIndex;

	document.oth_sfee.submit();
}

function DeleteRecord(strTargetIndex)
{
	if(!confirm('Are you sure you want to delete this record.'))
		return;
	document.oth_sfee.editRecord.value = 0;
	document.oth_sfee.deleteRecord.value = 1;
	document.oth_sfee.addRecord.value = 0;

	document.oth_sfee.info_index.value = strTargetIndex;
	document.oth_sfee.prepareToEdit.value == 0;

	document.oth_sfee.submit();
}
function CancelRecord()
{
	var strSYFrom = document.oth_sfee.sy_from.value;
	var strSYTo = document.oth_sfee.sy_to.value;

	location = "./fm_other_sch_fee.jsp?sy_from="+strSYFrom+"&sy_to="+strSYTo+"&year_level="+document.oth_sfee.year_level[document.oth_sfee.year_level.selectedIndex].value;
}

</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
//add security here.

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-other sch fee","fm_other_sch_fee.jsp");
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
														"fm_other_sch_fee.jsp");
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

FAFeeMaintenance FA = new FAFeeMaintenance();
boolean bolProceed = true;

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	strPrepareToEdit="0";

	//add it here and give a message.
	if(FA.addOthSchFee(dbOP,request))
		strErrMsg = "Other School Fee added successfully.";
	else
	{
		bolProceed = false;
		strErrMsg = FA.getErrMsg();
	}
}
else //either it is edit or delete -- this page handles add/edit/delete/viewall :-)
{
	String strInfoIndex = request.getParameter("info_index"); //required for delete / edit

	strTemp = request.getParameter("editRecord");
	if(strTemp != null && strTemp.compareTo("1") == 0)
	{
		if(FA.editOthSchFee(dbOP,request))
		{
			strErrMsg = "Other School Fee edited successfully.";
			strPrepareToEdit="0";
		}
		else
		{
			bolProceed = false;
			strErrMsg = FA.getErrMsg();
		}
	}
	else
	{
		strTemp = request.getParameter("deleteRecord");
		if(strTemp != null && strTemp.compareTo("1") == 0)
		{
			strPrepareToEdit="0";

			if(FA.delOthSchFee(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
				strErrMsg = "Other School Fee deleted successfully.";
			else
			{
				bolProceed = false;
				strErrMsg = FA.getErrMsg();
			}
		}
	}
}

//get all levels created.
Vector vRetResult = new Vector();
Vector vEditInfo = new Vector();

if(bolProceed)
{
	vRetResult = FA.viewOthSchFee(dbOP, null, request.getParameter("year_level"), request.getParameter("sy_from"), request.getParameter("sy_to"),true);//to view all
	//if(vRetResult ==null)
	//{
	//	bolProceed = false;
	//	strErrMsg = FA.getErrMsg();
	//}
}

if(bolProceed && strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo = FA.viewOthSchFee(dbOP,request.getParameter("info_index"),null,null,null, false);//view all is false
	if(vEditInfo == null || vEditInfo.size() == 0)
	{
		bolProceed = false;
		strErrMsg = FA.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "Edit information not found. Please refresh page and edit again.";
	}
}

dbOP.cleanUP();


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsSWU = strSchCode.startsWith("SWU");

//do not proceed is bolProceed = false;
if(!bolProceed)
{
	%>
	<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="2">
	<b><%=strErrMsg%></b></font></p>
	<%
	return;
}
%>


<form name="oth_sfee" action="./fm_other_sch_fee.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          OTHER SCHOOL FEES MAINTENANCE PAGE ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="12%">School Year </td>
      <td width="30%">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(0);
	else
		strTemp = request.getParameter("sy_from");
if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
	%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("oth_sfee","sy_from","sy_to")'>
        to
        <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = request.getParameter("sy_to");
if(strTemp == null || strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
	%>
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"></td>
      <td width="55%">Year level
        <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = request.getParameter("year_level");
	if(strTemp == null) strTemp = "";
	%>
        <select name="year_level">
          <%if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>All</option>
          <%}else{%>
          <option value="0">All</option>
          <%}if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st</option>
          <%}else{%>
          <option value="1">1st</option>
          <%}if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.compareTo("5") ==0){%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0){%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}if(strTemp.compareTo("7") ==0){%>
          <option value="7" selected>7th</option>
          <%}else{%>
          <option value="7">7th</option>
          <%}%>
        </select> 
		<a href="javascript:CancelRecord();"><img src="../../../images/view.gif" border="0"></a> <font size="1">enter
        SY and year level to view list fees</font></td>
    </tr>
<%if(bolIsSWU){
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(7);
	else
		strTemp = request.getParameter("is_ustore");
	if(strTemp == null) 
		strTemp = "";
	if(strTemp.equals("1"))
		strTemp = " checked";
	else	
		strTemp = "";
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" style="font-size:11px; font-weight:bold; color:#0000FF">
	  <input type="checkbox" name="is_ustore" value="1" <%=strTemp%>> Is U Store Fee </td>
    </tr>
<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee name </td>
      <td  colspan="2">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("fee_name");
	if(strTemp == null) strTemp = "";
	%>
        <input name="fee_name" type="text" size="64" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Fee rate </td>
      <td>
        <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(4);
	else
		strTemp = request.getParameter("amount");
	if(strTemp == null) strTemp = "";
	%>
        <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(5);
	else
		strTemp = request.getParameter("currency");
	if(strTemp == null) strTemp = "";
	%>
        <select name="currency">
          <%if(strTemp.compareToIgnoreCase("PHP") ==0){%>
          <option value="Php" selected>Php</option>
          <%}else{%>
          <option value="Php">Php</option>
          <%}if(strTemp.compareToIgnoreCase("US$") ==0){%>
          <option value="US$" selected>US$</option>
          <%}else{%>
          <option value="US$">US$</option>
          <%}%>
        </select> </td>
      <td width="55%">Remarks &nbsp;
        <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(6);
	else
		strTemp = request.getParameter("remark");
	if(strTemp == null) strTemp = "";
	%>
        <input name="remark" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> </td>
    </tr>
<%if(iAccessLevel > 1){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp; </td>
      <td colspan="2">&nbsp;
        <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click
        to add</font>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}%>      </td>
    </tr>
    <%}//if iAccessLevel > 1
if(strErrMsg != null)
{%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3"><b><%=strErrMsg%></b></td>
    </tr>
    <%}//this shows the edit/add/delete success info%>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(vRetResult != null && vRetResult.size() > 0)
{%>
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5" bgcolor="#B9B292"><div align="center">LIST
          OF OTHER SCHOOL FEES - FOR SCHOOL YEAR <%=request.getParameter("sy_from")%>-<%=request.getParameter("sy_to")%></div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="45%" height="25"><div align="center"><strong><font size="1">FEE
          NAME</font></strong></div></td>
      <td width="15%"><div align="center"><strong><font size="1">FEE (Php/$) </font></strong></div></td>
      <td width="15%"><div align="center"><strong><font size="1">YEAR LEVEL</font></strong></div></td>
<%if(bolIsSWU){%>
      <td width="10%" align="center" style="font-weight:bold; font-size:9px;">Is U-Store </td>
<%}%>
      <td width="8%" align="center"><font size="1"><strong>EDIT</strong></font></td>
      <td width="7%" align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%
String[] convertYearLevel = {"All","1st","2nd","3rd","4th","5th","6th","7th","8th"};
for(int i = 0 ; i< vRetResult.size() ; i += 6)
{%>
    <tr>
      <td height="25"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+2)%> <%=(String)vRetResult.elementAt(i+3)%></td>
      <td align="center"><%=convertYearLevel[Integer.parseInt(request.getParameter("year_level"))]%></td>
<%if(bolIsSWU){
strTemp = WI.getStrValue(vRetResult.elementAt(i + 5));
if(strTemp.equals("1"))
	strTemp = "<font style='font-size:16px; font-weight:bold'>Y</font>";
else	
	strTemp = "&nbsp;";
%>
      <td align="center"><%=strTemp%></td>
<%}%>
      <td align="center">
        <%if(iAccessLevel > 1){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
        <%}else{%>
        Not authorized
        <%}%>      </td>
      <td align="center">
        <%if(iAccessLevel ==2 ){%>
        <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
        <%}else{%>
        Not authorized
        <%}%>      </td>
    </tr>
    <% 
	}//end of displaying levels
}//end of displaying existing question level
%>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="addRecord" value="0">
<input type="hidden" name="editRecord" value="0">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="deleteRecord" value="0">

</form>
</body>
</html>
