<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>

<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReceivePmt(strTellerID,strSaveIndex) {
	document.daily_cc.teller_id.value = strTellerID;
	document.daily_cc.save_index.value = strSaveIndex;
	document.daily_cc.page_action.value = "1";
	eval('document.submit_once'+strSaveIndex+'.src = \"../../../images/blank.gif\"');
	document.daily_cc.submit();
}
function ReloadPage() {
	document.daily_cc.page_action.vlaue ="";
	document.daily_cc.submit();
}
function DeleteInformation(strInfoIndex)
{
	document.daily_cc.page_action.value = "0";
	document.daily_cc.info_index.value  = strInfoIndex;
	document.daily_cc.submit();
}
function CancelRecord()
{
	location = "./cash_fr_teller.jsp";
}
</script>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.FADailyCashCollectionDtls,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vTemp   = null;
	String strPrepareToEdit=WI.getStrValue(request.getParameter("prepareToEdit"),"0");

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & Payments-Daily cash collection mgmt-Set cutoff time","setup_cutoff_time.jsp");
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
														"Fee Assessment & Payments","DAILY CASH COLLECTION MGMT",request.getRemoteAddr(),
														"setup_cutoff_time.jsp");
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
FADailyCashCollectionDtls DCCDtls = new FADailyCashCollectionDtls();
String strCutOffTime = null;
Vector vTellerToRemitInfo = null;//to be received by head accountant
Vector vTellerRemittedInfo = null;//already received by head accountant.
Vector vRetResult = null;


strTemp = WI.fillTextValue("requested_date");
if(strTemp.length() ==0)	
	strTemp = WI.getTodaysDate(1);

	vRetResult = DCCDtls.viewCutoffTime(dbOP,strTemp,true);
	if(vRetResult == null)
		strCutOffTime = " complete DAY";
	else	
		strCutOffTime = (String)vRetResult.elementAt(0);


strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0){
	if(DCCDtls.operateOnCashRemittedByTeller(dbOP,request,Integer.parseInt(strTemp))== null)
		strErrMsg = DCCDtls.getErrMsg();
	else
		strErrMsg = "Operation is successful.";	
}

strTemp = WI.fillTextValue("requested_date");
if(strTemp.length() > 0) {
	vTellerToRemitInfo = DCCDtls.viewDCCByTellerToBeRemitted(dbOP,strTemp);
	if(vTellerToRemitInfo == null)
		strErrMsg = DCCDtls.getErrMsg();
}
%>

<form name="daily_cc" method="post" action="./cash_fr_teller.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          SET DAILY CASH COLLECTION CUT-OFF TIME ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="22">&nbsp;</td>
      <td width="14%">Remittance date</td>
      <td width="22%"> 
        <%
strTemp =WI.fillTextValue("requested_date");
if(strTemp.length() ==0)
	strTemp =WI.getTodaysDate(1);
%>
        <input name="requested_date" type="text" size="12" maxlength="12" readonly="yes" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'"> 
        &nbsp;&nbsp; <a href="javascript:show_calendar('daily_cc.requested_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
      <td width="62%"><a href="javascript:ReloadPage()"><img name="refresh_page" src="../../../images/refresh.gif" border="0" ></a> 
        Click to refresh page.</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><font color="#0000FF">Cut-off time:<strong> <%=WI.getStrValue(strCutOffTime)%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3"><font color="#0000FF"><strong>NOTE:</strong> If cutoff time 
        is not set, Cash collected for a specific day is considered cash collected 
        for that day!</font></td>
    </tr>
    <%if(iAccessLevel > 1){%>
    <%}//if iAccessLevel > 1%>
    <tr> 
      <td colspan="4" height="25"><hr size="1" color="red"></td>
    </tr>
  </table>
    <%
if(vTellerToRemitInfo != null && vTellerToRemitInfo.size() > 0)
{%>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="7" bgcolor="#B9B292"><div align="center">DETAIL 
          OF TELLER CASH COLLECTION FOR DATE <%=WI.fillTextValue("requested_date")%></div></td>
    </tr>
    <tr> 
      <td width="15%" align="center"><font size="1"><strong>TELLER ID</strong></font></td>
      <td width="30%" height="25" align="center"><font size="1"><strong> NAME(FNAME,MI,LNAME) 
        </strong></font></td>
      <td width="15%" align="center"><strong><font size="1">TOTAL AMOUNT COLLECTED 
        BY TELLER(1)</font></strong></td>
      <td width="20%" align="center"><strong><font size="1">TOTAL AMOUNT DEPOSITED 
        BY TELLER FOR ABOVE REMITTANCE DATE(2)</font></strong></td>
      <td width="10%" align="center"><font size="1"><strong>AMOUNT RECEIVED(1 
        - 2)</strong></font></td>
      <td width="10%"><div align="center"><strong><font size="1">CLICK TO RECEIVE</font></strong></div></td>
    </tr>
    <%
 for(int i = 0,j=0; i< vTellerToRemitInfo.size(); i += 5,++j){%>
     <tr> 
      <td align="center"><%=(String)vTellerToRemitInfo.elementAt(i)%></td>
      <td height="25" align="center"><%=(String)vTellerToRemitInfo.elementAt(i+1)%></td>
      <td align="center"><%=CommonUtil.formatFloat((String)vTellerToRemitInfo.elementAt(i+2),true)%></td>
      <td align="center"><%=CommonUtil.formatFloat((String)vTellerToRemitInfo.elementAt(i+3),true)%></td>
      <td align="center">
	  <input name="amount_paid<%=j%>" type="text" size="12" maxlength="12" value="<%=(String)vTellerToRemitInfo.elementAt(i+4)%>" 
	  	class="textbox" onfocus="style.backgroundColor='#D3EBFF'" onblur="style.backgroundColor='white'" > </td>
      <td align="center"><a href='javascript:ReceivePmt("<%=(String)vTellerToRemitInfo.elementAt(i)%>","<%=j%>")'> 
        <img name="submit_once<%=j%>" src="../../../images/save.gif" border="0"></a></td>
    </tr>
    <%}//end of for loop%>
  </table>
    <%}//end of display list of remittance.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td  colspan="6" height="25"><hr size="1" color="blue"></td>
    </tr>
</table>  
    <%
	//get the already remitted information.
vTellerRemittedInfo = DCCDtls.operateOnCashRemittedByTeller(dbOP,request,4);
if(vTellerRemittedInfo == null || vTellerRemittedInfo.size() == 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
	  <td width="2%"></td>
      <td height="25"><strong><%=DCCDtls.getErrMsg()%></strong></td>
    </tr>
</table>  
<%}else {%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="5" bgcolor="#B9B292"><div align="center">DETAIL 
          OF CASH COLLECTED FROM TELLERS</div></td>
    </tr>
    <tr> 
      <td width="1%" align="center">&nbsp;</td>
      <td width="18%" align="center"><font size="1"><strong>TELLER ID</strong></font></td>
      <td width="50%" height="25" align="center"><font size="1"><strong> NAME 
        (FNAME,MI,LNAME) </strong></font></td>
      <td width="20%" align="center"><strong><font size="1">AMOUNT DEPOSITED</font></strong></td>
      <td width="10%"><div align="center"><strong><font size="1">DELETE ENTRY</font></strong></div></td>
    </tr>
    <%
 for(int i = 0; i< vTellerRemittedInfo.size(); i += 4){%>
     <tr> 
      <td align="center">&nbsp;</td>
      <td align="center"><%=(String)vTellerRemittedInfo.elementAt(i+1)%></td>
      <td height="25" align="center"><%=(String)vTellerRemittedInfo.elementAt(i+2)%></td>
      <td align="center"><%=(String)vTellerRemittedInfo.elementAt(i+3)%></td>
      <td align="center"><a href='javascript:DeleteInformation("<%=(String)vTellerRemittedInfo.elementAt(i)%>")'>
	  					<img src="../../../images/delete.gif" border="0"></a></td>
    </tr>
    <%}//end of for loop%>
  </table>
    <%}//end of display list of remittance.%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="15%" height="25" colspan="8">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1">
      <td height="25" colspan="8" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <!-- all hidden fields go here -->
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="teller_id">
<input type="hidden" name="save_index">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
