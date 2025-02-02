<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	if(strAction.length == 0) { 
		document.form_.preparedToEdit.value = "";
		document.form_.info_index.value = "";
	}
}
function PreparedToEdit(strInfoIndex) {
//	alert("I am here.");
	document.form_.preparedToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,Accounting.Administration,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);

	String strTemp   = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration","setup_fiscal_year.jsp");
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
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-ADMINISTRATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
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
Administration adm = new Administration();
Vector vRetResult = null;
Vector vEditInfo  = null;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(adm.operateOnFiscalYear(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = adm.getErrMsg();
	else {
		strPreparedToEdit = "0";
		strErrMsg = "Operation successful.";
	}
}
vRetResult = adm.operateOnFiscalYear(dbOP, request, 4);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = adm.getErrMsg();
	
if(strPreparedToEdit.equals("1"))
	vEditInfo = adm.operateOnFiscalYear(dbOP, request, 3);


%>
<form action="./setup_fiscal_year.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          SETUP FISCAL YEAR PAGE ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="6" style="font-size:13px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="13%">Start month</td>
      <td width="21%">
	  <select name="start_month">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("start_month");
%> 
			<%=dbOP.loadComboMonth(strTemp)%>
	  </select></td>
      <td width="10%">Start Day</td>
      <td width="15%"><select name="start_day">
          <option value="1">1</option>
        </select></td>
      <td width="10%">Start year</td>
      <td width="28%">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("year_fr");
%> 
	  <input name="year_fr" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','year_fr');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('form_','year_fr');">      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>End month</td>
      <td><select name="end_month">
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("end_month");
%>	  
			<%=dbOP.loadComboMonth(strTemp)%>
        </select></td>
      <td>End Day</td>
      <td><select name="end_day">
          <option value="31">31</option>
        </select></td>
      <td>End year</td>
      <td>
<%
if(vEditInfo != null && vEditInfo.size() > 0) 
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("year_to");
%> 
	  <input name="year_to" type="text" size="4" maxlength="4" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','year_to');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyInteger('form_','year_to');">	  </td>
    </tr>
    <tr> 
      <td height="50">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="5">
<%if(iAccessLevel > 1) {
	if(strPreparedToEdit.equals("0")){%>
		<input type="submit" name="12" value=" Save Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('1','');"> &nbsp;&nbsp;&nbsp;&nbsp;
	<%}else{%>
		<input type="submit" name="12" value=" Edit Info " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('2','');">&nbsp;&nbsp;&nbsp;&nbsp;
	<%}
}%>	  
		<input type="submit" name="12" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
		 onClick="PageAction('','');document.form_.year_fr.value='';document.form_.year_to.value=''">
		
		</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="5">&nbsp;</td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="4" bgcolor="#B9B292" class="thinborder"><div align="center"><font color="#FFFFFF"><strong>EXISTING FISCAL YEAR </strong></font></div></td>
    </tr>
    <tr> 
      <td width="25%" height="31" class="thinborder"><div align="center"><strong><font size="1">RANGE</font></strong></div></td>
      <td width="43%" class="thinborder"><div align="center"><font size="1"><strong>YEAR OF EFFECTIVITY </strong></font></div></td>
      <td width="6%" class="thinborder">&nbsp;</td>
      <td width="7%" class="thinborder">&nbsp;</td>
    </tr>
<%
String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};
	for(int i =0; i< vRetResult.size(); i += 7){%>
    <tr> 
      <td height="25" class="thinborder">
	  	<%=astrConvertMonth[Integer.parseInt((String)vRetResult.elementAt(i + 1))] +" "+(String)vRetResult.elementAt(i + 2)%> to 
		<%=astrConvertMonth[Integer.parseInt((String)vRetResult.elementAt(i + 3))] +" "+(String)vRetResult.elementAt(i + 4)%>
	  </td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 5)%> - 
	  <%=WI.getStrValue(vRetResult.elementAt(i + 6)," Till date")%></td>
      <td class="thinborder">&nbsp;
	  <%if(iAccessLevel > 1) {%>
	  <input type="submit" name="12" value="Edit" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');"><%}%>
	  </td>
      <td class="thinborder">&nbsp;
	  <%if(iAccessLevel ==2 ) {%>
	  <input type="submit" name="12" value="Delete" style="font-size:11px; height:25px;border: 1px solid #FF0000;"
		 onClick="PageAction('0','<%=vRetResult.elementAt(i)%>');"><%}%>
	  </td>
    </tr>
<%}//end of for loop.%>
  </table>
<%}//show if vRetResult is not null.%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td height="25" width="1%">&nbsp;</td>
    <td width="49%">&nbsp;</td>
    <td width="50%">&nbsp;</td>
  </tr>
  <tr>
    <td height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    <td valign="middle"></tr>
  <tr bgcolor="#A49A6A">
    <td width="1%" height="25" colspan="3">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">
<input type="hidden" name="page_action" value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>