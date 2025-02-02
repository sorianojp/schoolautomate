<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script src="../../jscript/common.js"></script>
<script language="javascript">
function CheckCheckBox(strSelIndex) {
	var BugRef;
	var CheckBoxRef;
	eval('BugRef=document.form_.budget_'+strSelIndex);
	if(!BugRef)
		return;
	eval('CheckBoxRef=document.form_.course_'+strSelIndex);
	if(!CheckBoxRef)
		return;
	if(BugRef.value.length == 0)
		CheckBoxRef.checked = false;
	else	
		CheckBoxRef.checked = true;
}
</script>
<%@ page language="java" import="utility.*,lms.LmsAcquision,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; String strTemp = null;
	String strUserIndex  = null;
	Vector vBudgetSum  = new Vector();

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
Vector vRetResult   = null;
Vector vInsList     = null;

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(lmsAcq.operateOnBudgetEntry(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = lmsAcq.getErrMsg();
	else	
		strErrMsg = "Request processed successfully.";
}
//vBudgetSum = lmsAcq.viewBudgetSummary(dbOP, request);
vRetResult = lmsAcq.operateOnBudgetEntry(dbOP, request, 4);

//System.out.println("vRetResult "+vRetResult);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = lmsAcq.getErrMsg();

%>
<body bgcolor="#FAD3E0">
<form action="./budget_setup.jsp" method="post" name="form_" onSubmit="SubmitOnceButton(this);">
<A NAME="topView"><!-- --></A>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#0D3371">
      <td height="25" colspan="2"><div align="center"><font color="#FFFFFF" ><strong>::::
        ACQUISITION - BUDGET SETUP PAGE ::::</strong></font></div></td>
    </tr>
</table>
<jsp:include page="./inc.jsp?pgIndex=2"></jsp:include>
    <table width="100%" border="0" cellpadding="0" cellspacing="0">
       <tr>
        <td colspan="3" height="25" style="font-weight:bold; font-size:12px; color:#FF0000">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
      </tr>
      <tr>
        <td width="8%">School Yr </td>
        <td width="12%">
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp=" DisplaySYTo('form_','sy_from','sy_to')">
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>
        -
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">		</td>
        <td><input type="submit" name="_1" value="Reload Page" onClick="document.form_.page_action.value=''"></td>
		 <td align="right"><A HREF="./budget_setup.jsp#bottomView"><font color="#FF0000">Go to Bottom</font></A></td>
      </tr>
      <tr>
        <td colspan="4" height="10"><hr size="1"></td>
      </tr>
    </table>
<%
vInsList = lmsAcq.operateOnBudgetEntry(dbOP, request, 5);
int j = 0;
if(vInsList == null) {%>
      <table>
	  <tr>
        <td height="40" style="font-size:13px; font-weight:bold">&nbsp;&nbsp;&nbsp;<%=lmsAcq.getErrMsg()%></td>
      </tr>
    </table>
<%}else{%>

		<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#CCCCCC">
		  <tr bgcolor="#9DB6F4">
			<td width="65%" height="25" class="thinborder" align="center"><strong>Course<strong></strong></strong></td>
			<td width="25%" class="thinborder" align="center"><strong>Budget</strong></td>
			<td width="10%" class="thinborder" align="center"><strong>Select</strong></td>
		  </tr>
		<%for(int i =0; i < vInsList.size(); i += 4, ++j){
		if(vInsList.elementAt(i) != null) {%>
		  <tr bgcolor="#FFFFDD">
			<td height="20" colspan="3" class="thinborder">&nbsp;&nbsp;<%=vInsList.elementAt(i)%></td>
		  </tr>
		<%}%>
		  <tr>
			<td height="20" class="thinborder"> &nbsp;<%=vInsList.elementAt(i + 2)%></td>
			<td class="thinborder" align="center">
			<input name="budget_<%=j%>" type="text" size="16" maxlength="16" align="right" value="<%=WI.fillTextValue("budget_"+j)%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onKeyUp="AllowOnlyIntegerExtn('form_','budget_<%=j%>','.');"
			onBlur="AllowOnlyIntegerExtn('form_','budget_<%=j%>','.');CheckCheckBox('<%=j%>');style.backgroundColor='white'" style="font-size:12px;">
			</td>
			<td class="thinborder" align="center"><input type="checkbox" name="course_<%=j%>" value="<%=vInsList.elementAt(i + 3)%>" tabindex="-1"> </td>
		  </tr>
		<%}%>
		  <tr>
			<td height="20" colspan="3" class="thinborder" align="center"><input type="submit" name="_12" value="Save for Budget Information" onClick="document.form_.page_action.value='1';"></td>
		  </tr>
		<input type="hidden" name="max_disp_ins" value="<%=j%>">
		</table>

<%}//show if vList is not null%><br><br>

<A NAME="bottomView"><!-- --></A>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">	  
	  <tr bgcolor="#9DB6F4">
		<td width="50%" height="25" class="thinborder" align="center"><strong>Course</strong></strong></td>
		<td width="20%" class="thinborder" align="center"><strong>Budget Amount</strong></td>
		<td width="20%" class="thinborder" align="center"><strong>Consumed Amount</strong></td>
		<td width="10%" class="thinborder" align="center"><strong>Delete</strong></td>
	  </tr>
	<%
	int iTemp = 0; j = 0;
	String strTotalBudget   = "";		
	
	for(int i =0; i < vRetResult.size() ; i += 8, ++j){	
	//for(int i =0; i < vRetResult.size() ; i += 7, ++j){		
	
		strTotalBudget   = CommonUtil.formatFloat(((Double)vRetResult.elementAt(i + 7)).doubleValue(), true);
		
		//System.out.println("b "+strTotalBudget);
		
		iTemp = Integer.parseInt((String)vRetResult.elementAt(i + 6));
		if(iTemp == 0)
			strTemp = "";
		else if(iTemp == 1)
			strTemp = " bgcolor='red'";
		else	
			strTemp = " bgcolor='#dddddd'";
		//System.out.println(vRetResult.elementAt(i));
		if(vRetResult.elementAt(i) != null ) {%>
		  <tr bgcolor="#FFFFDD">
			<td height="20" colspan="" class="thinborder">&nbsp;&nbsp;<%=vRetResult.elementAt(i)%></td>			
			<td height="20" colspan="" class="thinborder" align="right"><%=strTotalBudget%>&nbsp;&nbsp;</td>
			<td height="20" colspan="" class="thinborderBOTTOMLEFT" align="right">&nbsp;</td>
			<td height="20" colspan="" class="thinborderBOTTOM" align="right">&nbsp;</td>
		  </tr>
		<%}%>
		  <tr<%=strTemp%>>
			<td height="20" class="thinborder">&nbsp;<%=vRetResult.elementAt(i + 3)%></td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 4), true)%>&nbsp;&nbsp;</td>
			<td class="thinborder" align="right"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 5), true)%>&nbsp;&nbsp;</td>
			<td class="thinborder" align="center"><input name="submit22" type="submit" style="font-size:11px; height:18px;border: 1px solid #FF0000;" value="Delete" onClick="document.form_.page_action.value='0'; document.form_.info_index.value='<%=vRetResult.elementAt(i + 1)%>'"></td>
		  </tr>
	  <%}%>
	</table>

<%}//only if vRetResult is not null..%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25">&nbsp;</td>
    <td width="49%" valign="middle">&nbsp;</td>
    <td width="50%" valign="middle">&nbsp;</td>
  </tr>
  <tr bgcolor="#0D3371">
    <td width="1%" height="25" colspan="3" align="right"><A HREF="./budget_setup.jsp#topView">Go to Top</A></td>
  </tr>  
</table>

<input type="hidden" name="page_action">
<input type="hidden" name="info_index">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
