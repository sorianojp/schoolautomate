<%@ page language="java" import="utility.*,java.util.Vector,osaGuidance.ProgramOfActivity"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript">
function CloseWindow()
{
	window.opener.document.form_.submit()
	window.opener.focus();
	self.close();
}
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
</script>
<body bgcolor="#D2AE72">

<%
	DBOperation dbOP = null;

	String strErrMsg = null;
	String strTemp = null;
	String strTempCond = null;
	String[] astrMonthList = {"January","February","March","April","May","June","July","August",
	"September","October","November","December"};
	strTemp = WI.fillTextValue("page_action");

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Student Affairs-PROGRAM OF ACTIVTIES","prog_act_create.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Student Affairs","PROGRAM OF ACTIVTIES",request.getRemoteAddr(),
														"prog_act_create.jsp");
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
Vector vRetResult = null;
Vector vActDtls = null;
ProgramOfActivity POA = new ProgramOfActivity();
//collect information for view.

vActDtls = POA.operateOnActivity(dbOP,request,3);
if (vActDtls!= null){
	
	if(strTemp.length() > 0) {
		if(POA.operateOnAssignObjective(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			strErrMsg = "Operation successful.";
		else
			strErrMsg = POA.getErrMsg();
	}

	vRetResult = POA.operateOnAssignObjective(dbOP, request,4);
	if (vRetResult == null && strErrMsg== null)
		POA.getErrMsg();
}
%>
<form action="./prog_act_update.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
          PROGRAM OF ACTIVITIES - UPDATE ACTIVITIES PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td width="5%" height="25">&nbsp;</td>
      <td width="95%">
	  <a href="javascript:CloseWindow();">
	  <img src="../../../images/close_window.gif" width="71" height="32" border="0"></a></td>
    </tr>
  </table>
<%if (vActDtls!=null && vActDtls.size()>0){%>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td colspan="6" height="25"><strong><%=WI.getStrValue(strErrMsg,"&nbsp;")%></strong></td>
	</tr>
	<tr>
		<td width="5%" height="10">&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="25%">&nbsp;</td>
		<td width="20%">&nbsp;</td>
		<td width="25%">&nbsp;</td>
		<td width="5%">&nbsp;</td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td><strong>Activity: </strong></td>
		<td><%=(String)vActDtls.elementAt(3)%></td>
		<td><strong>Date: </strong></td>
		<td><%=(String) vActDtls.elementAt(4)%> 
		  <%=WI.getStrValue((String) vActDtls.elementAt(5), " - ","","")%></td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td><strong>Venue: </strong></td>
		<td><%=(String)vActDtls.elementAt(7)%></td>
		<td><strong>Time Frame: </strong></td>
		<td><%=(String)vActDtls.elementAt(6)%></td>
		<td>&nbsp;</td>
	</tr>
	<tr>
		<td height="10" colspan="6">&nbsp;</td>
	</tr>
	<tr>
		<td height="25">&nbsp;</td>
		<td><strong>Objective: </strong></td>
		<td colspan="4">
		<%strTemp = WI.fillTextValue("obj_index");
		strTempCond = " from osa_poa_objective where sy_from = "+WI.fillTextValue("sy_from")+
		" and sy_to = "+WI.fillTextValue("sy_to")+" and is_valid = 1 and is_del = 0 order by obj_sl_no";%>
	 <select name="obj_index">
          <option value="">Select objective</option>
		<%=dbOP.loadCombo("poa_obj_index","objective", strTempCond, strTemp, false)%>
	 </select>
		</td>
	</tr>
	<tr>
		<td height="30" colspan="2">&nbsp;</td>
		<td colspan="4" valign="middle">
		<a href='javascript:PageAction(1,"");'>
		<img src="../../../images/assign.gif" border="0" name="hide_save"></a>
	    <font size="1">click to assign objective</font>
		</td>
	</tr>
   </table>
<%if (vRetResult!=null && vRetResult.size()>0) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr bgcolor="#B9B292">
      <td height="25" colspan="3" align="center"><font color="#FFFFFF">
      <strong>OBJECTIVES OF <%=(String)vActDtls.elementAt(3)%></strong></font></td>
    </tr>
    <tr>
    	<td width="10%" align="center" height="25" valign="middle"><font size="1"><strong>ORDER</strong></font></td>
    	<td width="70%" align="left" valign="middle"><font size="1"><strong>&nbsp;OBJECTIVE</strong></font></td>
    	<td width="20%">&nbsp;</td>
    </tr>
<%for (int i = 0; i < vRetResult.size(); i+=3) {%>
    <tr>
    	<td height="20" align="center"><strong><%=(String)vRetResult.elementAt(i+1)%></strong></td>
    	<td>&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
    	<td>&nbsp;<a href='javascript:PageAction(0, "<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
<%}%>
  </table>
   <%
   }//if a result exists
   }//if activity is found
   %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25" colspan="9">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" colspan="9" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
<input name = "act_index" type = "hidden"  value="<%=WI.fillTextValue("act_index")%>">
<input type="hidden" name="sy_from" value="<%=WI.fillTextValue("sy_from")%>">
<input type="hidden" name="sy_to" value="<%=WI.fillTextValue("sy_to")%>">
<input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>