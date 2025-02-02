<%@ page language="java" import="utility.*, osaGuidance.*, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script>
function PageAction(strAction, strInfoIndex) {
	if(strInfoIndex.length > 0) 
		document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = strAction;
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
</script>
</head>
<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS","test_factors.jsp");
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	Vector vSlots = null;
	int i = 0;
	int iFreeSlots = 0;
	int iMaxCount = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit = null;
	int iSearchResult = 0;
	String strFinCol = null;
	
	GDPsychologicalTest PsychTest = new GDPsychologicalTest();
	
	strTemp = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	if(strTemp.length() > 0) {
		if(PsychTest.operateOnPsyTestFactors(dbOP, request, Integer.parseInt(strTemp)) != null ) 
		{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
		}
		else
			strErrMsg = PsychTest.getErrMsg();
	}
	
	vSlots = PsychTest.operateOnPsyTestFactors(dbOP, request, 6);
	if (vSlots==null)
		strErrMsg = PsychTest.getErrMsg();			
	else
	{
		iFreeSlots = Integer.parseInt((String)vSlots.elementAt(2));
		iMaxCount = Integer.parseInt((String)vSlots.elementAt(1));
	}

	if(strTemp.length() > 0) {
		if(PsychTest.operateOnPsyTestFactors(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
			}
		else
			strErrMsg = PsychTest.getErrMsg();
	}

	if (strPrepareToEdit.equals("1"))
	{
		vEditInfo = PsychTest.operateOnPsyTestFactors(dbOP, request, 3);
		if (vEditInfo == null && strErrMsg == null)
					strErrMsg = PsychTest.getErrMsg();
	}

	vRetResult = 	PsychTest.operateOnPsyTestFactors(dbOP, request, 4);
	if (vRetResult == null && strErrMsg == null)
		strErrMsg = PsychTest.getErrMsg();
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./test_factors.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING - PSYCHOLOGICAL TEST FACTORS::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
    </tr>
    <tr> 
      <td width="5%" height="30">&nbsp;</td>
      <td width="18%">Test Name</td>
      <td width="77%" valign="middle">
      <%strTemp = WI.fillTextValue("test_index");%>
		<select name="test_index" onChange="ReloadPage();">
          <option value="">Select test</option>
		<%=dbOP.loadCombo("test_name_index","test_name"," from gd_psytest_name where is_valid = 1 order by test_name", strTemp, false)%>
    </select>
      </td>
    </tr>
  </table>
  <%if (iFreeSlots>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#C78D8D"> 
      <td  height="25" colspan="4" align="center" ><font color="#FFFFFF"><strong>UNDEFINED FACTORS</strong></font></div></td>
    </tr>
	<tr>
		<td width="20%" height="25">&nbsp;</td>
		<td width="50%" align="center" valign="middle"><strong><font size="1">Trait Factor</font></strong></td>
		<td width="10%" align="center" valign="middle"><strong><font size="1">Factor Code</font></strong></td>
		<td width="20%">&nbsp;</td>
	</tr>
	<%for (i=1;i<=iFreeSlots; ++i){%>
	<tr>
		<td>&nbsp;</td>
		<td>
		<%strTemp = WI.fillTextValue("factor_name"+i);%>
		<input name="factor_name<%=i%>" value="<%=strTemp%>" type="text" size="48" maxlength="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		</td>
		<td> 
		<%strTemp = WI.fillTextValue("factor_code"+i);%>
       <input name="factor_code<%=i%>" value="<%=strTemp%>" type="text" class="textbox" size="10" maxlength="10"
	   onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
		<td>&nbsp;</td>
	</tr>
	<%}%>
	<tr>
		<td colspan="4" align="center">
		<%if (iAccessLevel > 1) {%>
		<a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a>
		<font size="1">Define Factors</font><%} else {%>&nbsp;<%}%></td>
	</tr>
	</table>
    <%}%>
	<%if (vRetResult!=null && vRetResult.size()>0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr bgcolor="#C78D8D"> 
      <td  height="25" colspan="4" align="center" ><font color="#FFFFFF"><strong>DEFINED FACTORS</strong></font></div></td>
    </tr>
    <%if (strPrepareToEdit.equals("1")){%>
	<tr>
    	<td width="12%" align="center"><font size="1"><strong>ORDER</strong></font></td>
    	<td width="40%" align="center"><font size="1"><strong>TRAIT FACTOR</strong></font></td>
		<td width="18%" align="center"><font size="1"><strong>FACTOR CODE</strong></font></td>
		<td width="30%" align="center">&nbsp;</td>
	</tr>
	<tr>
		<td align="center">
		<%if (vEditInfo != null && vEditInfo.size()>0)
		strTemp = (String)vEditInfo.elementAt(3);
		else
		strTemp = WI.fillTextValue("order");%>
		<select name="order">
		<%for (i=1;i<=iMaxCount;++i){
		if (strTemp.equals(Integer.toString(i))){%>
		<option value="<%=i%>" selected><%=i%></option>
		<%}else{%>
		<option value="<%=i%>"><%=i%></option>
		<%}}%>
		</select>
		</td>
		<td align="center">
		<%if (vEditInfo != null && vEditInfo.size()>0)
		strTemp = (String)vEditInfo.elementAt(1);
		else
		strTemp = WI.fillTextValue("name");%>
		<input name="name" value="<%=strTemp%>" type="text" size="32" maxlength="64" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		</td>
		<td align="center">
		<%if (vEditInfo != null && vEditInfo.size()>0)
		strTemp = (String)vEditInfo.elementAt(2);
		else
		strTemp = WI.fillTextValue("code");%>
		<input name="code" value="<%=strTemp%>" type="text" size="10" maxlength="10" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
		</td>
		<td align="left"><%if (iAccessLevel > 1){%>
		<a href='javascript:PageAction(2, "");'><img src="../../../images/save.gif" border="0"></a>
		&nbsp;<a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a>
		<%} else {%>&nbsp;<%}%></td>
	</tr>
	<%}%>
	</table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td colspan="4" height="28">
		<hr size="1">
		</td>
	</tr>
    <tr>
    	<td width="12%" align="center"><font size="1"><strong>ORDER</strong></font></td>
    	<td width="40%" align="center"><font size="1"><strong>TRAIT FACTOR</strong></font></td>
		<td width="18%" align="center"><font size="1"><strong>FACTOR CODE</strong></font></td>
		<td width="30%" align="center">&nbsp;</td>
    </tr>
	<%for (i=0; i<vRetResult.size(); i+=5){%>
    <%strTemp = (String)vRetResult.elementAt(i+4);
    if (strTemp.equals("0"))
    strFinCol = " bgcolor = '#EEEEEE'";
	else 
	strFinCol = " bgcolor = '#FFFFFF'";
    %>
    <tr <%=strFinCol%>>
    	<td align="center"><font size="1"><%=(String)vRetResult.elementAt(i+3)%></font></td>
    	<td align="left"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
		<td align="center"><font size="1"><%=(String)vRetResult.elementAt(i+2)%></font></td>
    	<td align="left">
    	<%if (strTemp.equals("1")){
      if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
		<%}else{%>&nbsp;<%} if (iAccessLevel == 2) {%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>&nbsp;<%}} else { 
        if (iAccessLevel==2){%><a href='javascript:PageAction("5","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/undelete.gif" border="0"></a>
        <%}else{%>&nbsp;<%}}%></td>
    </tr>
    <%}%>
  </table>
	<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
   <input name = "info_index" type = "hidden"  value="<%=WI.fillTextValue("info_index")%>">
    <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
    <input type="hidden" name="page_action">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>