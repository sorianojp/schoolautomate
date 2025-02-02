<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function DeleteRecord(strTargetIndex)
{
	if(!confirm('Are you sure you want to delete this record.'))
		return;
	document.form_.page_action.value = 0;
	document.form_.info_index.value = strTargetIndex;
	document.form_.submit();
}</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeOperation,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-misc fee Multiple labfee","fm_misc_fee_multiple_labfee_tagged.jsp");
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
														"fm_misc_fee_multiple_labfee_tagged.jsp");
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

FAFeeOperation fOp = new FAFeeOperation();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(fOp.operateOnMultipleChargeFeeInfo(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = fOp.getErrMsg();
	else 
		strErrMsg = "Operation Successful.";		
}

Vector vRetResult = fOp.operateOnMultipleChargeFeeInfo(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = fOp.getErrMsg();

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = "";

//String strFeeName = null;
//String strMiscFeeIndex = WI.fillTextValue("fee_ref");
//strFeeName = "select fee_name from fa_misc_fee where misc_fee_index = "+strMiscFeeIndex;
//strFeeName = dbOP.getResultOfAQuery(strFeeName, 0);
//if(strFeeName == null)
//	strErrMsg = "Wrong fee reference. Fee Information not found.";


//for multiple OC mapping, 1, in sujbect category, create a category named Multiple Lab Fee with check box multiple_oc_map checked.
//now in MC or other chanrge, create hands on with that category, and then come to this link
// to add fees to this fee names.
%>
<form name="form_" action="./fm_misc_fee_multiple_labfee_tagged.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: Multiple Labfee Tagged ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">  
      <td height="25" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>  
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%">Fee Name</td>
      <td width="80%">
	  	<select name="fee_name" onChange="document.form_.page_action.value='';document.form_.submit();">
		<option value=""></option>
<%
strTemp = " from fa_misc_fee join subject_catg on (subject_catg.catg_index = fa_misc_fee.catg_index) "+
			" where fa_misc_fee.is_del=0 and subject_catg.multiple_oc_map=1 order by fa_misc_fee.fee_name";
%>					
<%=dbOP.loadCombo("distinct fee_name","fee_name",strTemp, WI.fillTextValue("fee_name"), false)%>
		</select>	  
	  </td>
    </tr>
<%if(WI.fillTextValue("fee_name").length() > 0) {%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Subject Category</td>
      <td>
	  	<select name="sub_catg">
<%=dbOP.loadCombo("catg_index","catg_name"," from subject_catg where IS_DEL=0 and multiple_oc_map = 0 and not exists "+
			"(select * from FA_FEE_OTHCHARGE_MULTIPLE where catg_index=sub_catg_index and othcharge_feename='"+
			WI.getStrValue(WI.fillTextValue("fee_name"),"0")+"') order by catg_name asc", WI.fillTextValue("sub_catg"), false)%>
		</select>	  
	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%if(iAccessLevel > 1) {%>
	  <input type="submit" name="12" value="&nbsp;&nbsp;Save Information&nbsp;&nbsp;" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'">
<%}%>
	  </td>
    </tr>
<%}%>

  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2" bgcolor="#dddddd"><div align="center"><strong>::: List of Multiple fee mapping ::: </strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
    <tr> 
      <td width="45%" height="25" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;Fee Name </td>
      <td width="45%" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;Subject Category </td>
      <td width="10%" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;Delete</td>
    </tr>
    
    <%
for(int i=0; i<vRetResult.size(); i+=3){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">
		<input type="submit" name="12" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="DeleteRecord('<%=vRetResult.elementAt(i)%>')">	  
	  </td>
    </tr>
    <%}%>
  </table>
<%}//end of display. %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
  </table>
  <!-- all hidden fields go here -->

<input type="hidden" name="info_index">
<input type="hidden" name="page_action">
<!--
<input type="hidden" name="fee_ref" value="<%//=WI.fillTextValue("fee_ref")%>">
<input type="hidden" name="fee_name" value="<%//=strFeeName%>">
-->
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
