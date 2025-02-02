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
	document.fa_affbank.editRecord.value = 0;
	document.fa_affbank.deleteRecord.value = 0;
	document.fa_affbank.addRecord.value = 0;
	document.fa_affbank.prepareToEdit.value = 1;
	document.fa_affbank.info_index.value = strInfoIndex;
	document.fa_affbank.submit();

}
function AddRecord()
{
	if(document.fa_affbank.prepareToEdit.value == 1)
	{
		EditRecord(document.fa_affbank.info_index.value);
		return;
	}
	document.fa_affbank.editRecord.value = 0;
	document.fa_affbank.deleteRecord.value = 0;
	document.fa_affbank.addRecord.value = 1;

	document.fa_affbank.submit();
}
function EditRecord(strTargetIndex)
{
	document.fa_affbank.editRecord.value = 1;
	document.fa_affbank.deleteRecord.value = 0;
	document.fa_affbank.addRecord.value = 0;

	document.fa_affbank.info_index.value = strTargetIndex;

	document.fa_affbank.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.fa_affbank.editRecord.value = 0;
	document.fa_affbank.deleteRecord.value = 1;
	document.fa_affbank.addRecord.value = 0;

	document.fa_affbank.info_index.value = strTargetIndex;
	document.fa_affbank.prepareToEdit.value == 0;

	document.fa_affbank.submit();
}
function CancelRecord()
{
	location = "./fee_assess_pay_aff_banks.jsp";
}

</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT MAINTENANCE-Affiliated banks","fee_assess_pay_aff_banks.jsp");
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
														"fee_assess_pay_aff_banks.jsp");
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
	if(FA.addAffBank(dbOP,request))
		strErrMsg = "Affiliated bank added successfully.";
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
		if(FA.editAffBank(dbOP,request))
			strErrMsg = "Affiliated bank edited successfully.";
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

			if(FA.delAffBank(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
				strErrMsg = "Affiliated bank deleted successfully.";
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
	vRetResult = FA.viewAffBank(dbOP, null, true);//to view all
	if(vRetResult ==null)
	{
		bolProceed = false;
		strErrMsg = FA.getErrMsg();
	}
}

if(bolProceed && strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo = FA.viewAffBank(dbOP,request.getParameter("info_index"), false);//view all is false
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


<form name="fa_affbank" action="./fee_assess_pay_aff_banks.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" align="center"><font color="#FFFFFF"><strong>::::
          AFFILIATED BANKS PAGE ::::</strong></font></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="7">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="10%">Code</td>
      <td colspan="2">
    <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = request.getParameter("aff_bank_code");
	if(strTemp == null) strTemp = "";
	%>
	  <input name="aff_bank_code" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td colspan="2">Name</td>
      <td width="40%">
	  <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("aff_bank_name");
	if(strTemp == null) strTemp = "";
	%>
	<input name="aff_bank_name" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td>Account
        #</font></td>
      <td colspan="2">
	  <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = request.getParameter("account_no");
	if(strTemp == null) strTemp = "";
	%>
	<input name="account_no" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
      <td colspan="2">Account
        type</font></td>
      <td valign="top">
	  <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(4);
	else
		strTemp = request.getParameter("account_type");
	if(strTemp == null) strTemp = "";
	%>
	<input name="account_type" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="32" rowspan="2">&nbsp;</td>
      <td rowspan="2" valign="top">Address</font></td>
      <td colspan="2" rowspan="2" valign="top">
       <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(6);
	else
		strTemp = request.getParameter("address");
	if(strTemp == null) strTemp = "";
	%>
	 <textarea name="address" cols="28" rows="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=strTemp%></textarea>
        </font></td>
      <td height="27" colspan="2"><div align="left">Branch</font></div></td>
      <td valign="top">
       <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(5);
	else
		strTemp = request.getParameter("branch");
	if(strTemp == null) strTemp = "";
	%>
	 <input name="branch" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </td>
    </tr>
    <tr>
      <td colspan="3" valign="bottom">
	  <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{
if(iAccessLevel > 1){%>
        <a href="javascript:AddRecord();"><img src="../../../images/add.gif" border="0"></a><font size="1">click
        to add</font>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}
		}//if iAccessLevel > 1%></td>
    </tr>
    <%
if(strErrMsg != null)
{%>
	<tr>
      <td height="25">&nbsp;</td>
      <td colspan="6"><b><%=strErrMsg%></b></td>
    </tr>
    <%}//this shows the edit/add/delete success info%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(vRetResult.size() > 0)
{%>    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5"><div align="center">LIST
          OF AFFILIATED BANKS</div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="10%" height="25"><div align="center"><font size="1"><strong>CODE</strong></font></div></td>
      <td width="17%"><div align="center"><font size="1"><strong>NAME</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>ACCOUNT # </strong></font></div></td>
      <td width="12%"><div align="center"><font size="1"><strong>ACCOUNT TYPE
          </strong></font></div></td>
      <td width="20%"><div align="center"><font size="1"><strong>ADDRESS</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>BRANCH</strong></font></div></td>
      <td width="5%" align="center"><font size="1"><strong>EDIT</strong></font></td>
      <td width="6%" align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size() ; ++i)
{%>
    <tr>
      <td height="25" align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td><%=(String)vRetResult.elementAt(i+6)%></td>
      <td><%=(String)vRetResult.elementAt(i+5)%></td>
      <td align="center">
	  <%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
	  <%}else{%>Not authorized<%}%></td>
      <td align="center">
	  <%if(iAccessLevel ==2){%>
	  <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
	  <%}else{%>Not authorized<%}%></td>
    </tr>
    <% i = i+6;
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
