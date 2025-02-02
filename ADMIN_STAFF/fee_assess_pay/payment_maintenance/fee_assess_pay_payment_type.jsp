<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
function PrepareToEdit(strInfoIndex)
{
	document.fa_pmttype.editRecord.value = 0;
	document.fa_pmttype.deleteRecord.value = 0;
	document.fa_pmttype.addRecord.value = 0;
	document.fa_pmttype.prepareToEdit.value = 1;
	document.fa_pmttype.info_index.value = strInfoIndex;
	document.fa_pmttype.submit();

}
function AddRecord()
{
	if(document.fa_pmttype.prepareToEdit.value == 1)
	{
		EditRecord(document.fa_pmttype.info_index.value);
		return;
	}
	document.fa_pmttype.editRecord.value = 0;
	document.fa_pmttype.deleteRecord.value = 0;
	document.fa_pmttype.addRecord.value = 1;

	document.fa_pmttype.submit();
}
function EditRecord(strTargetIndex)
{
	document.fa_pmttype.editRecord.value = 1;
	document.fa_pmttype.deleteRecord.value = 0;
	document.fa_pmttype.addRecord.value = 0;

	document.fa_pmttype.info_index.value = strTargetIndex;

	document.fa_pmttype.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.fa_pmttype.editRecord.value = 0;
	document.fa_pmttype.deleteRecord.value = 1;
	document.fa_pmttype.addRecord.value = 0;

	document.fa_pmttype.info_index.value = strTargetIndex;
	document.fa_pmttype.prepareToEdit.value == 0;

	document.fa_pmttype.submit();
}
function CancelRecord()
{
	location = "./fee_assess_pay_payment_type.jsp";
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT MAINTENANCE-Payment Type","fee_assess_pay_payment_type.jsp");
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
														"Fee Assessment & Payments","PAYMENT MAINTENANCE",request.getRemoteAddr(),
														"fee_assess_pay_payment_type.jsp");
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

FAPmtMaintenance FA = new FAPmtMaintenance();
boolean bolProceed = true;

//check for add - edit or delete
strTemp = request.getParameter("addRecord");
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	strPrepareToEdit="0";

	//add it here and give a message.
	if(FA.addPmtType(dbOP,request))
		strErrMsg = "Payment Type added successfully.";
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
		if(FA.editPmtType(dbOP,request))
			strErrMsg = "Payment Type edited successfully.";
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

			if(FA.delPmtType(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
				strErrMsg = "Payment Type deleted successfully.";
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
	vRetResult = FA.viewPmtType(dbOP, null, true);//to view all
	if(vRetResult ==null)
	{
		bolProceed = false;
		strErrMsg = FA.getErrMsg();
	}
}

if(bolProceed && strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo = FA.viewPmtType(dbOP,request.getParameter("info_index"), false);//view all is false
	if(vEditInfo == null || vEditInfo.size() == 0)
	{
		bolProceed = false;
		strErrMsg = FA.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "Edit information not found. Please refresh page and edit again.";
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
%>

<form name="fa_pmttype" action="./fee_assess_pay_payment_type.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          PAYMENT TYPE PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      	<td width="2%">&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="25%">&nbsp;</td>
		<td width="23%">&nbsp;</td>
		<td width="30%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Payment Type Code</td>
	  <td >
    <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = request.getParameter("pmt_type_code");
	if(strTemp == null) strTemp = "";
	%>
	<input name="pmt_type_code" type="text" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td>Payment Type Name </td>
      <td >
	<%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("pmt_type");
	if(strTemp == null) strTemp = "";
	%>
	<input name="pmt_type" type="text" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
   </tr>
    <tr>
      <td height="25">&nbsp;</td>
	  <td>Remarks</td>
      <td colspan="3">
	  <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = request.getParameter("remark");
	if(strTemp == null) strTemp = "";
	%>
	<input name="remark" type="text" size="60" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
<%if(iAccessLevel > 1){%>
	<tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="4"><%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to add</font>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}%>
</td>
    </tr>
    <%}//if iAccessLevel > 1
if(strErrMsg != null)
{%>
    <tr>
      <td width="2%">&nbsp;</td>
      <td colspan="4"><b><%=strErrMsg%></b></td>
    </tr>
    <%}//this shows the edit/add/delete success info%>

  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(vRetResult.size() > 0)
{%>
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5"><div align="center">LIST OF PAYMENT
          TYPE</div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="22%" height="25"><div align="center"><font size="1"><strong>CODE</strong></font></div></td>
      <td width="21%"><div align="center"><font size="1"><strong>NAME</strong></font></div></td>
      <td width="40%"><div align="center"><font size="1"><strong>REMARKS</strong></font></div></td>
      <td width="7%" align="center"><font size="1"><strong>EDIT</strong></font></td>
      <td width="10%" align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size() ; ++i)
{%>
    <tr>
      <td height="25" align="center"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td><%=(String)vRetResult.elementAt(i+3)%></td>
      <td align="center">
<%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
<%}else{%>Not authorized<%}%>	  </td>
      <td align="center">
<%if(iAccessLevel ==2){%>
	  <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
<%}else{%>Not authorized<%}%>	  </td>
    </tr>
    <% i = i+3;
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
