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
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function ReloadPage()
{
	this.SubmitOnce('form_');
	document.form_.print_pg.value = "";
}
function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function Cancel() 
{
	document.form_.info_index.value = "";
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}
function PrintPage(){
	document.form_.print_pg.value = "1";
	this.SubmitOnce("form_");
}

</script>
</head>
<%
	if(WI.fillTextValue("print_pg").compareTo("1") == 0) {%>
		<jsp:forward page="./create_tests_print.jsp" />
	<%}
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
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS","create_tests.jsp");
	
	Vector vRetResult = null;
	Vector vEditInfo = null;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;
	String strPrepareToEdit = null;
	int iSearchResult = 0;
	
	GDPsychologicalTest PsychTest = new GDPsychologicalTest();
	
	strTemp = WI.fillTextValue("page_action");
	strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
	
	if(strTemp.length() > 0) {
		if(PsychTest.operateOnPsyTestName(dbOP, request, Integer.parseInt(strTemp)) != null ) 
			{
			strErrMsg = "Operation successful.";
			strPrepareToEdit = "0";
			}
		else
			strErrMsg = PsychTest.getErrMsg();
	}
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = PsychTest.operateOnPsyTestName(dbOP, request, 3);
	
	if(vEditInfo == null && strErrMsg == null ) 
			strErrMsg = PsychTest.getErrMsg();
	}

	vRetResult = PsychTest.operateOnPsyTestName(dbOP, request, 4);
	if (vRetResult == null && strErrMsg == null )
		strErrMsg = PsychTest.getErrMsg();
	else
		iSearchResult = PsychTest.getSearchCount();

%>
<body bgcolor="#D2AE72">
<form name="form_" action="./create_tests.jsp" method="post">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          GUIDANCE &amp; COUNSELING - ADD/CREATE PSYCHOLOGICAL TESTS PAGE::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="25" colspan="3"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
    </tr>
    <tr> 
      <td width="5%" height="30">&nbsp;</td>
      <td width="22%">Test Name</td>
      <td width="73%" valign="middle">
      <%if (vEditInfo != null && vEditInfo.size()>0)
	      strTemp = (String)vEditInfo.elementAt(1);
      else
	      strTemp = WI.fillTextValue("test_name");%>
	      <input name="test_name" type="text" size="32" maxlength="64" value="<%=strTemp%>" 
	    class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>No. of Test Factors/Values</td>
      <td height="30" valign="middle">
       <%if (vEditInfo != null && vEditInfo.size()>0)
	      strTemp = (String)vEditInfo.elementAt(2);
      else
	       strTemp = WI.fillTextValue("test_factor");%> 
       <input name="test_factor" type="text" class="textbox" value="<%=strTemp%>" size="4" maxlength="4"
	   onKeyUp= 'AllowOnlyInteger("form_","test_factor")' onFocus="style.backgroundColor='#D3EBFF'"
		onblur='AllowOnlyInteger("form_","test_factor");style.backgroundColor="white"'>
      </td>
    </tr>
    <tr> 
      <td height="30">&nbsp;</td>
      <td>Result General Name</td>
      <td valign="middle">
      <%if (vEditInfo != null && vEditInfo.size()>0)
	      strTemp = (String)vEditInfo.elementAt(3);
      else
    	  strTemp = WI.fillTextValue("gen_name");%>
	      <input name="gen_name" type="text" size="32" maxlength="64" value="<%=strTemp%>" 
	    class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      </td>
    </tr>
    <tr> 
      <td height="39">&nbsp;</td>
      <td>&nbsp;</td>
      <td height="39" valign="middle">
	  <%if (iAccessLevel >= 1) {%>
      <font size="1"><%if(strPrepareToEdit.compareTo("1") != 0) {%> <a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        Click to add entry 
        <%}else{%> <a href='javascript:PageAction(2, "");'><img src="../../../images/edit.gif" border="0"></a> 
        Click to edit entry <a href="javascript:Cancel();"><img src="../../../images/cancel.gif" border="0"></a> 
        Click to clear entries 
        <%}%></font><%} else {%>&nbsp;<%}%>
      </td>
    </tr>
  <%if (vRetResult!=null && vRetResult.size()>0){%>
    <tr> 
      <td height="25" colspan="3" align="right">
      <font size="1"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a>click to print list</font>
      </td>
    </tr>
    <%}%>
  </table>
  <%if (vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#C78D8D"> 
      <td  height="25" colspan="4" align="center" class="thinborder"><font color="#FFFFFF"><strong>LIST 
          OF PSYCHOLOGICAL TESTS</strong></font></div></td>
    </tr>
    <tr> 
      <td width="34%" height="28" align="center" class="thinborder"><font size="1"><strong>TEST 
          NAME </strong></font></td>
      <td width="15%" align="center" class="thinborder"><font size="1"><strong>NO. OF TEST FACTORS/VALUES</strong></font></td>
      <td width="35%" align="center" class="thinborder"><font size="1"><strong>Type of Test</strong></font></td>
      <td width="16%" align="center" class="thinborder">&nbsp;</td>
    </tr>
	<%for (i=0; i < vRetResult.size(); i+=4){%>
    <tr> 
      <td  height="26" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td class="thinborder">
      <%if(iAccessLevel ==2 || iAccessLevel == 3){%>
        <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a> 
		<%}else{%>&nbsp;<%} if (iAccessLevel == 2) {%>
        <a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>")'><img src="../../../images/delete.gif" border="0"></a> 
        <%}else{%>&nbsp;<%}%></td>
    </tr>
    <%}%>
    <tr> 
      <td  height="25" colspan="2" align="left" class="thinborderBOTTOMLEFT"><font size="1"><strong>TOTAL 
          PYSCHOLOGICAL TESTS: &nbsp;&nbsp;<%=iSearchResult%></strong></font></td>
      <td colspan="2" align="right" class="thinborderBOTTOM"><%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/PsychTest.defSearchSize;
		if(iSearchResult % PsychTest.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1){%><select name="jumpto" onChange="ReloadPage();" style="font-size:11px">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%	}
			}// end page printing
			%>
          </select>
          <%} else {%>&nbsp;<%} //if no pages %></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td colspan="4" height="25">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" colspan="3" align="center">
      <font size="1"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a>click to print list</font>
      </td>
    </tr>
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
   	<input type="hidden" name="print_pg">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>