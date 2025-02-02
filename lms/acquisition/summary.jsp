<%@ page language="java" import="utility.*,lms.LmsAcquision,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; String strTemp = null;
	String strUserIndex  = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Acquisition".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}

//end of authenticaion code.

	try {
		dbOP = new DBOperation();
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

LmsAcquision lmsAcq = new LmsAcquision();
Vector vRetResult     = null; 
Vector vInsList = null;

vRetResult = lmsAcq.viewBudgetSummary(dbOP, request);

if(vRetResult == null && strErrMsg == null)
	strErrMsg = lmsAcq.getErrMsg();

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<script src="../../jscript/common.js"></script>
<script language="javascript">
function ViewDetail(strSYFrom,strCollegeIndex, strBudget, strConsumed, strBalance) {
	var loadPg = "./summary_viewdtls.jsp?sy_from="+strSYFrom+"&college="+strCollegeIndex+"&budget="+strBudget+"&consumed="+strConsumed+"&balance="+strBalance;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();

}
</script>
<body bgcolor="#FAD3E0">
<form action="./summary.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#0D3371">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>:::: ACQUISITION - SUMMARY  PAGE ::::</strong></font></div></td>
    </tr>
</table>
<jsp:include page="./inc.jsp?pgIndex=1"></jsp:include>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
      <tr>
        <td colspan="3" style="font-size:14px; color:#FF0000; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
      </tr>
      <tr>
        <td width="10%"><font size="1">School Year </font></td>
        <td width="13%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">		</td>
        <td>&nbsp;&nbsp;&nbsp;
          <input type="submit" name="Proceed" value="Proceed >>">		</td>
      </tr>
      
<!--
      <tr>
        <td>SORT:<font size="1">&nbsp; </font></td>
        <td colspan="2"><select name="select">
          <option>N/A</option>
          <option>College</option>
          <option>Course</option>
          <option>Amount</option>
          <option>Budget Balance</option>
        </select>
          <select name="select2">
            <option>Ascending</option>
            <option>Descending</option>
                    </select>
          <select name="select6">
            <option>N/A</option>
            <option>College</option>
            <option>Course</option>
            <option>Amount</option>
            <option>Budget Balance</option>
          </select>
          <select name="select3">
            <option>Ascending</option>
            <option>Descending</option>
          </select>
          <select name="select7">
            <option>N/A</option>
            <option>College</option>
            <option>Course</option>
            <option>Amount</option>
            <option>Budget Balance</option>
          </select>
          <select name="select4">
            <option>Ascending</option>
            <option>Descending</option>
          </select>
          <select name="select8">
            <option>N/A</option>
            <option>College</option>
            <option>Course</option>
            <option>Amount</option>
            <option>Budget Balance</option>
          </select>
          <select name="select5">
            <option>Ascending</option>
            <option>Descending</option>
          </select></td>
      </tr>
-->
      <tr>
        <td colspan="3">&nbsp;</td>
      </tr>
    </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr bgcolor="#9DB6F4" align="center" style="font-weight:bold">
    <td width="45%" height="20" class="thinborder">College</td>
    <td width="5%" class="thinborder">Quantity</td>
    <td width="15%" class="thinborder">Budget Amout </td>
    <td width="15%" class="thinborder">Consumed Amount </td>
    <td width="15%" class="thinborder">Balance Amount </td>
    <td width="5%" class="thinborder">View Dtls </td>
  </tr>
<%String strBGColor     = null;
String strTotalBudget   = null;
String strTotalConsumed = null;
String strTotalBalance  = null;

for(int i = 0; i < vRetResult.size(); i += 7){

if(vRetResult.elementAt(i + 4).equals("1"))
	strBGColor = " bgcolor='red'";
else	
	strBGColor = "";

strTotalBudget   = CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 1)).doubleValue(), true);
strTotalConsumed = CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 2)).doubleValue(), true);
strTotalBalance  = CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 3)).doubleValue(), true);
%>
  <tr<%=strBGColor%>>
    <td height="20" class="thinborder">&nbsp;<%=vRetResult.elementAt(i)%></td>
    <td class="thinborder" align="center">&nbsp;<%=vRetResult.elementAt(i + 5)%></td>
    <td class="thinborder" align="right"><%=strTotalBudget%>&nbsp;</td>
    <td class="thinborder" align="right"><%=strTotalConsumed%>&nbsp;</td>
    <td class="thinborder" align="right"><%=strTotalBalance%>&nbsp;</td>
    <td class="thinborder" align="center"><input name="submit2" type="button" style="font-size:11px; height:18px;border: 1px solid #FF0000;" value="VIEW" 
		onClick="ViewDetail('<%=WI.fillTextValue("sy_from")%>','<%=vRetResult.elementAt(i + 6)%>','<%=strTotalBudget%>','<%=strTotalConsumed%>','<%=strTotalBalance%>');"></td>
  </tr>
<%}%>
</table>
<%}//end of if condition.. %>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td width="1%" height="25">&nbsp;</td>
    <td valign="middle">&nbsp;</td>
    </tr>
  <tr bgcolor="#0D3371">
    <td height="25" colspan="2">&nbsp;</td>
  </tr>
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index">
<input type="hidden" name="preparedToEdit" value="">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>