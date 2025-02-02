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
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FAFeeMaintenance,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-map oth sch fee as tuition fee","set_oth_sch_fee_as_tuition.jsp");
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
														"set_oth_sch_fee_as_tuition.jsp");
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

FAFeeMaintenance feeM = new FAFeeMaintenance();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(feeM.operateOnOthSchFeeTuition(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = feeM.getErrMsg();
	else 
		strErrMsg = "Operation Successful.";		
}

Vector vRetResult = feeM.operateOnOthSchFeeTuition(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = feeM.getErrMsg();

%>
<form name="form_" action="./set_oth_sch_fee_as_tuition.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25"><div align="center"><font color="#FFFFFF"><strong>:::: Define Other School Fee As Tuition ::::</strong></font></div></td>
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
	  	<select name="fee_name">
<%
strTemp = " from fa_oth_sch_fee where is_valid = 1 and not exists (select * from FA_OTH_SCH_FEE_TUITION where FEE_NAME_T = fee_name) "+
			" order by fa_oth_sch_fee.fee_name";
%>					
<%=dbOP.loadCombo("distinct fa_oth_sch_fee.fee_name","fa_oth_sch_fee.fee_name",strTemp, WI.fillTextValue("fee_name"), false)%>
		</select>	  </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td>
<%if(iAccessLevel > 1) {%>
	  <input type="submit" name="12" value="&nbsp;&nbsp;Save Information&nbsp;&nbsp;" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='1'">
<%}%>	  </td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="2" bgcolor="#dddddd"><div align="center"><strong>::: List of Other School Fee set as Tuition ::: </strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
    <tr> 
      <td width="88%" height="25" class="thinborder" style="font-size:9px; font-weight:bold" align="center">&nbsp;Fee Name </td>
      <td width="12%" class="thinborder" style="font-size:9px; font-weight:bold">&nbsp;Delete</td>
    </tr>
    
    <%
for(int i=0; i<vRetResult.size(); i+=2){%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">
		<input type="submit" name="12" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;" onClick="document.form_.page_action.value='0';document.form_.info_index.value='<%=vRetResult.elementAt(i)%>'">	  </td>
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
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
