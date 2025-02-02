<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
								"Admin/staff-Fee Assessment & Payments-FEE MAINTENANCE-add drop fee","search.jsp");
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
														"search.jsp");
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
if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = FFM.listAddDropFeeCharged(dbOP, request);
	if(vRetResult == null)
		strErrMsg = FFM.getErrMsg();
	//System.out.println(vRetResult);
	//System.out.println(strErrMsg);
}
%>
<body>
<form name="form_" method="post" action="search.jsp">
  <table border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2">
	  <jsp:include page="./inc.jsp?pgIndex=2"></jsp:include>
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
	  <td width="17%" >SY From/Term </td>
	  <td width="81%" >
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 	
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>	  
			<input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
	  - 
<%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 	
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
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
        </select>			</td>
	</tr>
	<tr>
	  <td >&nbsp;</td>
	  <td >Search ID/Name </td>
	  <td >
	  <input name="id_num" type="text" size="32" maxlength="32" value="<%=WI.fillTextValue("id_num")%>" class="textbox"			  
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white';">	  </td>
	</tr>
	<tr>
	  <td width="2%" >&nbsp;</td>
	  <td colspan="2" >
<%
strTemp = WI.fillTextValue("show_con");
if(strTemp.length() == 0 || strTemp.equals("0"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con" value="0" <%=strErrMsg%>> Show All 
<%
if(strTemp.equals("1"))
	strErrMsg = " checked";
else	
	strErrMsg = "";
%>
	  <input type="radio" name="show_con" value="1" <%=strErrMsg%>> Show Student Not yet Paid	  </td>
    </tr>
<!--	<tr>
	  <td >&nbsp;</td>
	  <td >Drop Fee Name </td>
	  <td >
<%
if(vRetResult != null && vRetResult.size() > 0)		
	strTemp = (String)vRetResult.elementAt(4);		
else
	strTemp = "";
%>
	  <select name="drop_fee_name" >
          <option value=""></option>
          <%=dbOP.loadCombo("distinct FEE_NAME","fee_name"," from fa_oth_sch_fee where is_valid=1 and fee_name like 'add%' order by fee_name asc", strTemp, false)%> </select>
	  </td>
    </tr>
-->
	<tr>
	  <td height="21" >&nbsp;</td>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
	  </tr>
	<tr>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
	  <td >
      	<input type="submit" name="refresh" value=" Refresh Page " style="font-size:11px; height:26px;border: 1px solid #FF0000;">	  </td>
	  </tr>
	<tr>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
	  <td >&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">		
	<tr>
	  <td height="25" align="center" style="font-weight:bold; font-size:11px;">List Of Students </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">		
	<tr align="center" style="font-weight:bold" bgcolor="#FFFFCC">
	  <td height="25" width="5%" class="thinborder">count</td>
	  <td width="15%" class="thinborder">ID Number</td>
	  <td width="20%" class="thinborder">Student Name</td>
	  <td width="10%" class="thinborder">No Of Transaction</td>
	  <td width="10%" class="thinborder">Total Payable</td>
	  <td width="10%" class="thinborder">Total Payment</td>
	  <td width="10%" class="thinborder">Balance</td>
    </tr>
<%
int iCount = 0; 
for(int i = 0; i < vRetResult.size(); i += 7) {%>
	<tr>
	  <td height="25" class="thinborder"><%=++iCount%>. </td>
	  <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
	  <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
	  <td class="thinborder"><%=vRetResult.elementAt(i + 4)%></td>
	  <td class="thinborder"><%=vRetResult.elementAt(i + 3)%></td>
	  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5), "0.00")%></td>
	  <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 6), "0.00")%></td>
    </tr>
<%}%>
  </table>
<%}%>
</form>
</body>
</html>

<%
if(dbOP!=null)
	dbOP.cleanUP();
%>

