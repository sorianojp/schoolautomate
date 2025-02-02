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
	document.fa_affInst.editRecord.value = 0;
	document.fa_affInst.deleteRecord.value = 0;
	document.fa_affInst.addRecord.value = 0;
	document.fa_affInst.prepareToEdit.value = 1;
	document.fa_affInst.info_index.value = strInfoIndex;
	document.fa_affInst.submit();

}
function AddRecord()
{
	if(document.fa_affInst.prepareToEdit.value == 1)
	{
		EditRecord(document.fa_affInst.info_index.value);
		return;
	}
	document.fa_affInst.editRecord.value = 0;
	document.fa_affInst.deleteRecord.value = 0;
	document.fa_affInst.addRecord.value = 1;

	document.fa_affInst.submit();
}
function EditRecord(strTargetIndex)
{
	document.fa_affInst.editRecord.value = 1;
	document.fa_affInst.deleteRecord.value = 0;
	document.fa_affInst.addRecord.value = 0;

	document.fa_affInst.info_index.value = strTargetIndex;

	document.fa_affInst.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.fa_affInst.editRecord.value = 0;
	document.fa_affInst.deleteRecord.value = 1;
	document.fa_affInst.addRecord.value = 0;

	document.fa_affInst.info_index.value = strTargetIndex;
	document.fa_affInst.prepareToEdit.value == 0;

	document.fa_affInst.submit();
}
function CancelRecord()
{
	location = "./fee_assess_pay_aff_inst_payee.jsp";
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
								"Admin/staff-Fee Assessment & Payments-PAYMENT MAINTENANCE-Affiliated Institutional Payee","fee_assess_pay_aff_inst_payee.jsp");
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
														"fee_assess_pay_aff_inst_payee.jsp");
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
	if(FA.addAffInst(dbOP,request))
		strErrMsg = "Affiliated Inst added successfully.";
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
		if(FA.editAffInst(dbOP,request))
			strErrMsg = "Affiliated Inst edited successfully.";
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

			if(FA.delAffInst(dbOP,request.getParameter("info_index"),(String)request.getSession(false).getAttribute("login_log_index")))
				strErrMsg = "Affiliated Inst deleted successfully.";
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
	vRetResult = FA.viewAffInst(dbOP, null, true);//to view all
	if(vRetResult ==null)
	{
		bolProceed = false;
		strErrMsg = FA.getErrMsg();
	}
}

if(bolProceed && strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo = FA.viewAffInst(dbOP,request.getParameter("info_index"), false);//view all is false
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

<form name="fa_affInst" action="./fee_assess_pay_aff_inst_payee.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          AFFILIATED INSTITUTIONAL PAYEE PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="6">&nbsp;</td>
    </tr>
    <tr>
      <td width="2%" height="25">&nbsp;</td>
      <td width="19%">Code</td>
      <td colspan="2">
    <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = request.getParameter("aff_inst_code");
	if(strTemp == null) strTemp = "";
	%>
        <input  tabindex="1"name="aff_inst_code" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </td>
      <td width="9%">Name</td>
      <td width="41%">
    <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = request.getParameter("aff_inst_name");
	if(strTemp == null) strTemp = "";
	%>
        <input  tabindex="2" name="aff_inst_name" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Contact
        person </td>
      <td colspan="2">
     <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = request.getParameter("con_per");
	if(strTemp == null) strTemp = "";
	%>
       <input tabindex="3" name="con_per" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </td>
      <td>Position
        </td>
      <td>
    <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(4);
	else
		strTemp = request.getParameter("con_per_pos");
	if(strTemp == null) strTemp = "";
	%>
        <input  tabindex="4"name="con_per_pos" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </td>
    </tr>
    <tr>
      <td height="32">&nbsp;</td>
      <td>Contact
        nos. </td>
      <td colspan="2">
    <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(5);
	else
		strTemp = request.getParameter("con_per_tel");
	if(strTemp == null) strTemp = "";
	%>
        <input  tabindex="5"name="con_per_tel" type="text" size="32" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        </td>
      <td valign="top">&nbsp;</td>
      <td valign="top">&nbsp;</td>
    </tr>
    <tr>
      <td height="32">&nbsp;</td>
      <td valign="top">Address</td>
      <td colspan="2" valign="top">
    <%
	if(vEditInfo != null && vEditInfo.size() > 1)
		strTemp = (String)vEditInfo.elementAt(6);
	else
		strTemp = request.getParameter("address");
	if(strTemp == null) strTemp = "";
	%>
        <textarea  tabindex="6"name="address" cols="32" rows="3" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"><%=strTemp%></textarea>
        </td>
      <td valign="bottom" colspan="2">
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
      <td colspan="5"><b><%=strErrMsg%></b></td>
    </tr>
<%}//this shows the edit/add/delete success info%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
<%
if(vRetResult.size() > 0)
{%>
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5"><div align="center">LIST
          OF AFFILIATED
          INSTITUTIONAL PAYEE</div></td>
    </tr>
  </table>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="10%" height="25"><div align="center"><font size="1"><strong>CODE</strong></font></div></td>
      <td width="17%"><div align="center"><font size="1"><strong>NAME</strong></font></div></td>
      <td width="15%"><div align="center"><font size="1"><strong>CONTACT PERSON
          </strong></font></div></td>
      <td width="11%"><div align="center"><font size="1"><strong>POSITION</strong></font></div></td>
      <td width="16%"><div align="center"><font size="1"><strong>CONTACT NOS.</strong></font></div></td>
      <td width="21%"><div align="center"><font size="1"><strong>ADDRESS</strong></font></div></td>
      <td width="5%" align="center"><font size="1"><strong>EDIT</strong></font></td>
      <td width="5%" align="center"><font size="1"><strong>DELETE</strong></font></td>
    </tr>
    <%
for(int i = 0 ; i< vRetResult.size() ; ++i)
{%>
    <tr>
      <td height="25" align="center"><%=(String)vRetResult.elementAt(i+1)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+2)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+3)%></td>
      <td align="center"><%=(String)vRetResult.elementAt(i+4)%></td>
      <td><%=(String)vRetResult.elementAt(i+5)%></td>
      <td><%=(String)vRetResult.elementAt(i+6)%></td>
      <td align="center">
	  <%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
	  <%}else{%>Not authorized<%}%></td>
      <td align="center">
	  <%if(iAccessLevel ==2 ){%>
	  <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
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
