<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Allowance Maintenance Page.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function ShowHideAllowance()
{
	if(document.fa_allowance.allowance_.selectedIndex ==0)
	{
		document.fa_allowance.oth_allo_.disabled = false;
		showLayer('oth_');
	}
	else
	{
		hideLayer('oth_');
		document.fa_allowance.oth_allo_.disabled = true;
	}
}

function ReloadPage()
{
	document.fa_allowance.reloadPage.value="1";
	document.fa_allowance.submit();
}
function PrepareToEdit(strInfoIndex)
{
	document.fa_allowance.prepareToEdit.value = 1;
	document.fa_allowance.info_index.value = strInfoIndex;
	document.fa_allowance.submit();
}
function AddRecord()
{
	if(document.fa_allowance.prepareToEdit.value == 1)
	{
		EditRecord(document.fa_allowance.info_index.value);
		return;
	}
	document.fa_allowance.page_action.value = 1;
	document.fa_allowance.submit();
}
function EditRecord(strTargetIndex)
{
	document.fa_allowance.page_action.value = 2;
	document.fa_allowance.info_index.value = strTargetIndex;
	document.fa_allowance.submit();
}

function DeleteRecord(strTargetIndex)
{
	document.fa_allowance.page_action.value = 0;
	document.fa_allowance.info_index.value = strTargetIndex;
	document.fa_allowance.submit();
}
function CancelRecord()
{
	document.fa_allowance.page_action.value = "";
	document.fa_allowance.prepareToEdit.value =0;
	document.fa_allowance.info_index.value = "0";
	document.fa_allowance.submit();
}
</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAPmtMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	SessionInterface sessInt = new SessionInterface();
	MessageConstant mConst = new MessageConstant();
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolErrInEdit = false;

	String strPrepareToEdit=request.getParameter("prepareToEdit");
	if(strPrepareToEdit== null) strPrepareToEdit="0";

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-PAYMENT MAINTENANCE-Fee adjustment type","fee_adjustment_allowance_pop.jsp");
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
														"fee_adjustment_allowance_pop.jsp");
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

Vector vViewAllowance = null;
Vector vEditInfo = null;//if edit is clicked.

FAPmtMaintenance FA = new FAPmtMaintenance();
strTemp = WI.fillTextValue("page_action");//0->delete, 1->add new, 2-> edit, 3-> view all, 4->view one
if(strTemp != null && strTemp.compareTo("1") == 0)
{
	strPrepareToEdit="0";
	//add it here and give a message.
	if(FA.opOnAllowance(dbOP,request,1) != null)
		strErrMsg = "Allowance added successfully.";
	else
		strErrMsg = FA.getErrMsg();
}
else if(strTemp.compareTo("2") ==0) //edit
{
	if(FA.opOnAllowance(dbOP,request,2) != null)
	{
		strErrMsg = "Allowance edited successfully.";
		strPrepareToEdit="0";
	}
	else
	{
		strErrMsg = FA.getErrMsg();
		bolErrInEdit = true;
	}
}
else if(strTemp.compareTo("0") ==0)
{
	if(FA.opOnAllowance(dbOP,request,0) != null)
		strErrMsg = "Allowance deleted successfully.";
	else
		strErrMsg = FA.getErrMsg();
}

vViewAllowance = FA.opOnAllowance(dbOP,request,3);//level is zero.
if(vViewAllowance ==null)
{
	if(strErrMsg == null)
		strErrMsg = FA.getErrMsg();
}

if(strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0)
{
	vEditInfo = FA.opOnAllowance(dbOP,request,4);
	if(vEditInfo == null || vEditInfo.size() == 0)
		if(strErrMsg == null)
			strErrMsg = FA.getErrMsg();
}
if(strErrMsg == null) strErrMsg = "";
%>

<form name="fa_allowance" action="./fee_adjustment_allowance_pop.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          FEE ALLOWANCE TYPE PAGE ::::</strong></font></div></td>
    </tr>
	</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" width="1%">&nbsp;</td>
      <td colspan="3"><strong><%=strErrMsg%></strong></td>
    </tr>
	</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="1%" height="25">&nbsp;</td>
      <td width="10%">&nbsp;</td>
      <td width="8%">Type</td>
      <td width="81%">
<%
if(vEditInfo != null && !bolErrInEdit)
	strTemp = (String)vEditInfo.elementAt(1);
else
	strTemp = WI.fillTextValue("allowance_");
%>
	  <select name="allowance_" onChange="ShowHideAllowance();">
          <option value="0">Others(Pl specify)</option>
          <%=dbOP.loadCombo("ALLO_TYPE_INDEX","NAME"," from FA_FEE_ADJ_ALLO_TYPE where is_del=0 order by NAME asc",strTemp, true)%>
        </select>
<input type="text" name="oth_allo_" id="oth_" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>Amount </td>
      <td>
<%
if(vEditInfo != null && !bolErrInEdit)
	strTemp = (String)vEditInfo.elementAt(3);
else
	strTemp = WI.fillTextValue("amount");
%>
	  <input name="amount" type="text" size="16" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'">
        (Php)</td>
    </tr>
    <tr>
      <td colspan="4"><hr size="1"></td>
    </tr>
  </table>
<%if(iAccessLevel > 1){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td  width="1%"height="25">&nbsp;</td>
      <td width="99%">
        <%
strTemp = strPrepareToEdit;
if(strTemp == null) strTemp = "0";
if(strTemp.compareTo("0") == 0)
{%>
        <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to add</font>
        <%}else{%>
        <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1" face="Verdana, Arial, Helvetica, sans-serif">click
        to save changes</font> <a href="javascript:CancelRecord();"><img src="../../../images/cancel.gif" border="0"></a>
        <font size="1">click to cancel or go previous</font>
        <%}%>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
<%}//if iAccessLevel > 1%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#B9B292">
      <td width="100%" height="25" colspan="5"><div align="center">LIST
          OF MAIN FEE ADJUSTMENT TYPE</div></td>
    </tr>
  </table>
<%
if(vViewAllowance != null && vViewAllowance.size() > 0)
{%>
  <table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr >
      <td width="60%" height="25"><div align="center"><strong><font size="1">NAME</font></strong></div></td>
      <td width="20%"><div align="center"><strong><font size="1">AMOUNT</font></strong></div></td>
      <td width="10%" align="center"><strong><font size="1">EDIT</font></strong></td>
      <td width="10%" align="center"><strong><font size="1">DELETE</font></strong></td>
    </tr>
    <%
for(int i=0; i< vViewAllowance.size(); ++i){%>
    <tr >
      <td height="25" align="center"><%=(String)vViewAllowance.elementAt(i+2)%></td>
      <td align="center">&nbsp;<%=WI.getStrValue(vViewAllowance.elementAt(i+3))%></td>
      <td align="center">
	  <%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vViewAllowance.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
	  <%}else{%>Not authorized<%}%>
	  </td>
      <%if(iAccessLevel > 1){%>
	  <td align="center"> <a href='javascript:DeleteRecord("<%=(String)vViewAllowance.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>
	  <%}else{%>Not authorized<%}%></td>

	</tr>
    <% i = i+3;
}%>
    <tr >
  </table>
<%}
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
  <%
strTemp = request.getParameter("info_index");
if(strTemp == null) strTemp = "0";
%>
<input type="hidden" name="info_index" value="<%=strTemp%>">
<input type="hidden" name="fa_fa_index" value="<%=WI.fillTextValue("fa_fa_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="page_action">


<%
strTemp = WI.fillTextValue("allowance_");

if( (vEditInfo != null && !bolErrInEdit) || (strTemp != null && strTemp.length() > 0 && strTemp.compareTo("0") !=0) )//hide the other text box.
{%>
<script language="JavaScript">
ShowHideAllowance();
</script>
<%}%>

</form>
</body>
</html>
