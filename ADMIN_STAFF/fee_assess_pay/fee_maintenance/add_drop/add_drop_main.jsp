<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript">	
	function PageAction(strAction) {		
		document.form_.page_action.value = strAction;
		if(strAction == '0') {
			if(confirm("Are you sure you want to delete this record?")){
				document.form_.page_action.value ='0';								
			}	
		}
		document.form_.submit();
	}

</script>
<%@ page language="java" import="utility.*,java.util.Vector, enrollment.FAFeeMaintenance " %>
<%
	DBOperation dbOP  = null;
	WebInterface WI   = new WebInterface(request);
	Vector vRetResult = null;
	String strErrMsg  = null;
	String strTemp    = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-add drop fee","add_drop_main.jsp");
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
	
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Fee Assessment & Payments","FEE MAINTENANCE",request.getRemoteAddr(),
														"add_drop_main.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}
FAFeeMaintenance FFM = new FAFeeMaintenance();
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(FFM.operateOnADDDropFee(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = FFM.getErrMsg();
	else	
		strErrMsg = "Operation successful.";
}
vRetResult = FFM.operateOnADDDropFee(dbOP, request, 4);
%>
<body>
<form name="form_" method="post" action="add_drop_main.jsp">
  <table border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">
	  <jsp:include page="./inc.jsp?pgIndex=1"></jsp:include>
	  </td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center"><font color="#FFFFFF" size="2"><strong>:::: ADD/DROP MAIN PAGE ::::</strong></font></td>
    </tr>    
		<tr bgcolor="#FFFFFF">
      <td height="30"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></font></td>
    </tr>	
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
	<tr>
	  <td height="25">&nbsp;</td>
	  <td >SY From/Term </td>
	  <td >
<%
if(vRetResult != null && vRetResult.size() > 0)		
	strTemp = (String)vRetResult.elementAt(0);		
else
	strTemp = "";
%>
			<input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
	  - 
<%
if(vRetResult != null && vRetResult.size() > 0)		
	strTemp = (String)vRetResult.elementAt(1);		
else
	strTemp = "";
%> <select name="semester">
   <option value="0">Summer</option>
<%
if(strTemp.compareTo("1") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="1"<%=strErrMsg%>>1st Sem</option>
<%
if(strTemp.compareTo("2") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>2nd Sem</option>
<%
if(strTemp.compareTo("3") ==0)
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3"<%=strErrMsg%>>3rd Sem</option>
        </select>
			</td>
	</tr>
	<tr>
	  <td >&nbsp;</td>
	  <td >Add/Drop Start Date </td>
	  <td >
<%
if(vRetResult != null && vRetResult.size() > 0)		
	strTemp = (String)vRetResult.elementAt(2);		
else
	strTemp = "";
%>
        <input name="start_date" type="text" size="10" maxlength="10"
			  value="<%=WI.getStrValue(strTemp)%>" class="textbox"			  
			  onfocus="style.backgroundColor='#D3EBFF'"
			  onblur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','start_date','/')" />
        <a href="javascript:show_calendar('form_.start_date');" title="Click to select date" 
						onmouseover="window.status='Select date';return true;" 
						onmouseout="window.status='';return true;"> <img src="../../../../images/calendar_new.gif" border="0" /></a></td>
	</tr>
	<tr>
	  <td width="2%" >&nbsp;</td>
	  <td width="17%" >Add/Drop Fee Name </td>
	  <td width="81%" >
<%
if(vRetResult != null && vRetResult.size() > 0)		
	strTemp = (String)vRetResult.elementAt(3);		
else
	strTemp = "";
%>
	  <select name="add_fee_name" >
          <option value=""></option>
          <%=dbOP.loadCombo("distinct fa_oth_sch_fee.FEE_NAME","fa_oth_sch_fee.fee_name"," from fa_oth_sch_fee where is_valid=1 and (fa_oth_sch_fee.fee_name like 'add%' or fa_oth_sch_fee.fee_name like '%com') order by fa_oth_sch_fee.fee_name asc", strTemp, false)%> </select>
	  </td>
    </tr>
	<tr>
	  <td height="21" >&nbsp;</td>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
	  </tr>
	<tr>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
	  <td >
	  <%if(vRetResult != null && vRetResult.size() > 0) {%>
      <input type="button" name="update" value=" Update " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2');" />
	  
	  &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  
      <input type="button" name="del" value=" Delete " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('0');" />
	  
	  <%}else{%>
      	<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1');" />
	  	<font size="1">click to save entries</font>
	  <%}%>
      
       </td>
	  </tr>
  </table>
	<input type="hidden" name="page_action">
</form>
</body>
</html>

<%
if(dbOP!=null)
	dbOP.cleanUP();
%>

