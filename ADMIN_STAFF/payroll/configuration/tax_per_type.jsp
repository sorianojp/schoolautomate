<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Tax per Salary Types</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<%response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache");
%>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

  TD.thinborder {
  border-left: solid 1px #000000;
  border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }

  TD.NoBorder {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
    }
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
//called for add or edit.
function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	if(strAction == 1) 
		document.form_.save.disabled = true;
		//document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function PrepareToEdit(strInfoIndex) {
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = strInfoIndex;
	document.form_.submit();
}
function ReloadPage(){
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "";
	document.form_.submit();
}

function CancelRecord(){
	location = "./tax_per_type.jsp?salary_type="+document.form_.salary_type.value;
}

function PrintPg()
{
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	if (WI.fillTextValue("print_page").equals("1")){ %>
	<jsp:forward page="./tax_per_type_print.jsp" />
<% return;	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-Tax Table per Type","tax_per_type.jsp");
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
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"tax_per_type.jsp");
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

	PayrollConfig prConfig = new PayrollConfig();
	Vector vEditInfo  = null;
	Vector vRetResult = null;
 	String[] astrSalaryType = {"D A I L Y ","W E E K L Y","SEMI-MONTHLY","MONTHLY"}; 
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0) {
		if(prConfig.operateOnTaxPerSalaryType(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = prConfig.getErrMsg();
		else {
			strPrepareToEdit = "0";
			if(strTemp.compareTo("1") == 0)
				strErrMsg = "Tax table information successfully added.";
			if(strTemp.compareTo("2") == 0)
				strErrMsg = "Tax table information successfully edited.";
			if(strTemp.compareTo("0") == 0)
				strErrMsg = "Tax table information successfully removed.";
		}
	}
 	
	//get vEditInfoIf it is called.
	if(strPrepareToEdit.compareTo("1") == 0) {
		vEditInfo = prConfig.operateOnTaxPerSalaryType(dbOP, request,3);
		if(vEditInfo == null)
			strErrMsg = prConfig.getErrMsg();
	}

	vRetResult  = prConfig.operateOnTaxPerSalaryType(dbOP, request,4);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prConfig.getErrMsg();
		
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./tax_per_type.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
      PAYROLL: TAX TABLE PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr>
      <td width="4%" height="23">&nbsp;</td>
      <td width="21%">Salary Type </td>
      <td width="75%"><select name="salary_type" onChange="ReloadPage();">
        <option value="0">Daily</option>
        <%
	if(vEditInfo != null && vEditInfo.size() > 0)
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = WI.fillTextValue("salary_type");
	if(strTemp == null)
		strTemp = "";
	if(strTemp.equals("1")){%>
        <option value="1" selected>Weekly</option>
        <%}else{%>
        <option value="1">Weekly</option>
        <%}if(strTemp.equals("2")) {%>
        <option value="2" selected>Semi-monthly</option>
        <%}else{%>
        <option value="2">Semi-monthly</option>
        <%}if(strTemp.equals("3")) {%>
        <option value="3" selected>Monthly</option>
        <%}else{%>
        <option value="3">Monthly</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>Fixed Amount </td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(2);
				else
					strTemp = WI.fillTextValue("fixed_amount");
			%>
      <td><strong>
        <input type="text" name="fixed_amount" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" maxlength="10" size="10"
	  onKeyPress="">
      </strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>Percentage over base </td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(3);
				else
					strTemp = WI.fillTextValue("percentage");
			%>
      <td><strong>
        <input type="text" name="percentage" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" maxlength="10" size="10"
	  onKeyPress="">
      </strong></td>
    </tr>
    <tr>
      <td height="16" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
    <tr>
      <td width="4%" height="23">&nbsp;</td>
      <td colspan="2"><strong>&nbsp;STATUS</strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td width="21%">&nbsp;Zero</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(4);
				else
					strTemp = WI.fillTextValue("zero");
			%>
      <td width="75%"><strong>
        <input type="text" name="zero" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" maxlength="10" size="10"
	  onKeyPress="">
      </strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;Single</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(5);
				else
					strTemp = WI.fillTextValue("single");
			%>
      <td><strong>
        <input type="text" name="single" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" maxlength="10" size="10"
	  onKeyPress="">
      </strong></td>
    </tr>
    
    <tr>
      <td height="23">&nbsp;</td>
      <td> &nbsp;Head of the Family </td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(6);
				else
					strTemp = WI.fillTextValue("head");
			%>			
      <td><strong>
        <input type="text" name="head" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" maxlength="10" size="10"
	  onKeyPress="">
      </strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;Married</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(7);
				else
					strTemp = WI.fillTextValue("married");
			%>						
      <td><strong>
        <input type="text" name="married" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" maxlength="10" size="10"
	  onKeyPress="">
      </strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td colspan="2"> For heads of family with dependent child(ren) </td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;1 dependent </td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(8);
				else
					strTemp = WI.fillTextValue("HF1");
			%>
      <td><strong>
        <input type="text" name="HF1" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" maxlength="10" size="10"
	  onKeyPress="">
      </strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;2 dependents</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(9);
				else
					strTemp = WI.fillTextValue("HF2");
			%>			
      <td><strong>
        <input type="text" name="HF2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" maxlength="10" size="10"
	  onKeyPress="">
      </strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;3 dependents</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(10);
				else
					strTemp = WI.fillTextValue("HF3");
			%>
      <td><strong>
        <input type="text" name="HF3" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" maxlength="10" size="10"
	  onKeyPress="">
      </strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;4&nbsp;dependents</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(11);
				else
					strTemp = WI.fillTextValue("HF4");
			%>			
      <td><strong>
        <input type="text" name="HF4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" maxlength="10" size="10"
	  onKeyPress="">
      </strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td colspan="2">For married employee with qualified dependent child(ren) </td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;1 dependent</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(12);
				else
					strTemp = WI.fillTextValue("ME1");
			%>			
      <td><strong>
        <input type="text" name="ME1" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" maxlength="10" size="10"
	  onKeyPress="">
      </strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;2 dependents</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(13);
				else
					strTemp = WI.fillTextValue("ME2");
			%>						
      <td><strong>
        <input type="text" name="ME2" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" maxlength="10" size="10"
	  onKeyPress="">
      </strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;3 dependents</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(14);
				else
					strTemp = WI.fillTextValue("ME3");
			%>									
      <td><strong>
        <input type="text" name="ME3" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" maxlength="10" size="10"
	  onKeyPress="">
      </strong></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td>&nbsp;4 dependents</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(15);
				else
					strTemp = WI.fillTextValue("ME4");
			%>												
      <td><strong>
        <input type="text" name="ME4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'"  value="<%=strTemp%>" maxlength="10" size="10"
	  onKeyPress="">
      </strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
	<% if(iAccessLevel > 1){%>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="9%" height="25">&nbsp;</td>
      <td width="65%" height="25"><font size="1">
        <%if(strPrepareToEdit.compareTo("1") != 0) {%>        
        <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');"> 
        Click to save entries 
        <%}else{%>
        <input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2', '');">
        Click to save changes 
        <%}%>
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
        Click to clear entries </font></td>
      <td width="24%" height="25">&nbsp;</td>
    </tr>
	<%}%>
  </table>
 <%
 if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" align="right"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0"></a><font size="1">click 
      to print result</font></td>
    </tr>
  </table>
  <table width="100%" height="24" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292"> 
      <td height="20" align="center" class="thinborder"><font color="#FFFFFF"><strong>TAX 
          TABLE ENTRIES </strong></font></td>
    </tr>
  </table>
	 
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr>
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("salary_type"),"0");
				strTemp = astrSalaryType[Integer.parseInt(strTemp)];
			%>
      <td height="25" align="center" class="thinborder"><%=strTemp%></td>
			<% int iCount = 1;
				for(int i = 0; i < vRetResult.size() ; i += 16, iCount++){
				strTemp = Integer.toString(iCount);
				strTemp += "<br>" + (String)vRetResult.elementAt(i + 2);
				strTemp += "<br>+" + (String)vRetResult.elementAt(i + 3) + "% over"; 
			%>
      <td rowspan="2" align="center" class="thinborder">&nbsp;
			<%if(iAccessLevel > 1){%>
			<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');"><%=strTemp%></a>
			<%}else{%>
			<%=strTemp%>
			<%}%>
			<br>
      <br>
			<%if(iAccessLevel == 2){%>
			<a href="javascript:PageAction('0','<%=(String)vRetResult.elementAt(i)%>');">DELETE</a>
			<%}%>
			</td>
      <%}%>
    </tr>
    <tr> 
      <td width="14%" height="25" align="center" class="thinborder">Status</td>
    </tr>
    <tr>
      <td height="25" colspan="<%= 1 + (vRetResult.size()/16)%>" class="thinborder">A. Without dependent children </td>
    </tr>
    <tr>
      <td height="25" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        
        <tr>
          <td height="20" class="NoBorder">1.) Z </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">2.) S &nbsp;</td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">3.) HF </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">4.) ME </td>
        </tr>
        
      </table></td>
			<%for(int i = 0; i < vRetResult.size() ; i += 16, iCount++){%>
      <td height="25" class="thinborder">
			  <table width="100%" border="0" cellspacing="0" cellpadding="0">        
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 4)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 5)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 6)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 7)%>&nbsp;</td>
        </tr>        
      </table></td>
			<%}%>
    </tr>
    <tr>
      <td height="25" colspan="<%= 1 + (vRetResult.size()/16)%>" class="thinborder">B. Head of family with dependent child(ren) </td>
    </tr>
    <tr>
      <td height="25" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        
        <tr>
          <td height="20" class="NoBorder">1.) HF 1 </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">2.) HF 2 </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">3.) HF 3 </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">4.) HF 4 </td>
        </tr>
        
      </table></td>
			<%for(int i = 0; i < vRetResult.size() ; i += 16, iCount++){%>
      <td height="25" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 8)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 9)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 10)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 11)%>&nbsp;</td>
        </tr>        
      </table></td>
			<%}%>
    </tr>
    <tr>
      <td height="25" colspan="<%= 1 + (vRetResult.size()/16)%>" class="thinborder">B. Married employee with dependent child(ren) </td>
    </tr>
    <tr>
      <td height="25" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        
        
        <tr>
          <td height="20" class="NoBorder">1.) ME 1 </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">2.) ME 2 </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">3.) ME 3 </td>
        </tr>
        <tr>
          <td height="20" class="NoBorder">4.) ME 4 </td>
        </tr>
      </table></td>
			<%for(int i = 0; i < vRetResult.size() ; i += 16, iCount++){%>
      <td height="25" class="thinborder"><table width="100%" border="0" cellspacing="0" cellpadding="0">
        
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 12)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 13)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 14)%>&nbsp;</td>
        </tr>
        <tr>
          <td height="20" align="right" class="NoBorder"><%=(String)vRetResult.elementAt(i + 15)%>&nbsp;</td>
        </tr>
      </table></td>
			<%}%>
    </tr>
  </table>
 <%}//if vRetResult is not null%>
 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
