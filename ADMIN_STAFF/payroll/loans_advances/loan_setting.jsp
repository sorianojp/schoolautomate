<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Internal loans setting</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.BorderBottomLeft{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottomLeftRight{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderAll{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.BorderBottom{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/formatFloat.js"></script>

<script language="JavaScript">
<!--
function PageAction(strPageAction, strInfoIndex,strCode){	
	document.form_.print_page.value = "";
	document.form_.donot_call_close_wnd.value = "1";
	if (strPageAction == 0){
		var vProceed = confirm('Delete '+strCode+' ?');
		if(vProceed){
			document.form_.page_action.value = strPageAction;
			document.form_.info_index.value = strInfoIndex;
			document.form_.prepareToEdit.value = "";
			this.SubmitOnce('form_');
		}		
	}else{
		document.form_.page_action.value = strPageAction;
		document.form_.info_index.value = strInfoIndex;
		document.form_.prepareToEdit.value = "";
		if (strPageAction == 1)
			document.form_.save.disabled = true;
		document.form_.submit();
		//this.SubmitOnce("form_");
	}	
}

function PrepareToEdit(strInfoIndex){
	document.form_.donot_call_close_wnd.value = "1";	
	document.form_.page_action.value = "";
	document.form_.print_page.value = "";
	document.form_.info_index.value=strInfoIndex;
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce("form_");
}

function ReloadPage(){
	document.form_.proceed.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
function CancelRecord(strLoanType){
	ClearFields();
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.prepareToEdit.value = "";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");	
}
function ClearFields(){
	document.form_.loan_code.value = "";
	document.form_.loan_name.value = "";
	if(document.form_.max_term)
		document.form_.max_term.value = "";
	if(document.form_.interest_val)
		document.form_.interest_val.value = "";
	if(document.form_.sy_from)
		document.form_.sy_from.value = "";
	if(document.form_.sy_to)
		document.form_.sy_to.value = "";
	
}

///////////////to reload parent window if this is closed //////////////
function CloseWindow(){
	document.form_.close_wnd_called.value = "1";
	
	window.opener.document.form_.submit();
	window.opener.focus();
	self.close();
}

function ReloadParentWnd() {
	if(document.form_.donot_call_close_wnd.value.length >0)
		return;

	if(document.form_.close_wnd_called.value == "0") {
		window.opener.document.form_.submit();
		window.opener.focus();
	}
}

-->
</script>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
//add security here.
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./loan_setting_print.jsp" />
<% return;}
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
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

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-LOANS-Loans setting","loan_setting.jsp");
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

	//end of authenticaion code.	
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	Vector vRetResult = null;
	Vector vEditInfo = null;
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	String strPageAction = WI.fillTextValue("page_action");
	String strInfoIndex = WI.fillTextValue("info_index");
	String[] astrTermUnit = {"months","years"};
	String strLoanType = WI.fillTextValue("loan_type");
	String[] astrInterestUnit = {"per year","per month"};

	if (strPageAction.length() > 0){
		if (strPageAction.compareTo("0")==0) {
			if (PRRetLoan.operateOnLoanCode(dbOP,request,0) != null){
				strErrMsg = "Loan code deleted successfully";
			}else{
				strErrMsg = PRRetLoan.getErrMsg();
			}
		}else if(strPageAction.compareTo("1") == 0){
			if (PRRetLoan.operateOnLoanCode(dbOP,request,1) != null){
				strErrMsg = " Loan code saved successfully";
			}else{
				strErrMsg = PRRetLoan.getErrMsg();
			}
		}else if(strPageAction.compareTo("2") == 0){
			if (PRRetLoan.operateOnLoanCode(dbOP,request,2) != null){
				strErrMsg = " Loan code updated successfully";
				strPrepareToEdit = "";
			}else{
				strErrMsg = PRRetLoan.getErrMsg();
			}
		}
	}
	
	if (strPrepareToEdit.length() > 0){
		vEditInfo = PRRetLoan.operateOnLoanCode(dbOP,request,3);
		if (vEditInfo == null)
			strErrMsg = PRRetLoan.getErrMsg();
	}
	
	vRetResult = PRRetLoan.operateOnLoanCode(dbOP,request,4);
	if (vRetResult != null && strErrMsg == null){
		strErrMsg = PRRetLoan.getErrMsg();	
	}	
%>
<form name="form_" method="post" action="./loan_setting.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
        PAYROLL : LOANS : LOAN(S) SETTING PAGE ::::</strong></font></td>
    </tr>    
	<%if(WI.fillTextValue("show_close").length() > 0){%>
	<tr bgcolor="#FFFFFF">
      <td height="25"><font size="1"><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" width="71" height="32" border="0"></a></font>click 
        to close window</td>
    </tr>	
	<%}%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25"><font size="1">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Loan Code</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(1);
		else
	  		strTemp = WI.fillTextValue("loan_code");
	  %>
      <td width="81%" colspan="2"><input name="loan_code" type="text" size="10" maxlength="10" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="15%">Loan Name</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(11);
		else
	  		strTemp = WI.fillTextValue("loan_name");
	  %>
      <td colspan="2"><input name="loan_name" type="text" size="24" maxlength="64" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
      </td>
    </tr>
	<%if(strLoanType.equals("2")){%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Maximum Term</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(12);
		else
	  		strTemp = WI.fillTextValue("max_term");
	  %>
      <td colspan="2"><strong><font size="1"> 
        <input name="max_term" type="text" class="textbox"onFocus="style.backgroundColor='#D3EBFF'" 
		value="<%=WI.getStrValue(strTemp,"")%>" size="4" maxlength="2" onKeyUp="AllowOnlyInteger('form_','max_term');"	 
	    onBlur="AllowOnlyInteger('form_','max_term');style.backgroundColor='white'">
        </font></strong><select name="term_unit">
          <option value="1">years</option>
         <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(13);
		else
			strTemp = WI.fillTextValue("term_unit");
			
		if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>months</option>
          <%}else{%>
          <option value="0">months</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Interest</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(6);
		else
	  		strTemp = WI.fillTextValue("interest_val");
	  %>	  
      <td colspan="2"><input name="interest_val" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        %
          <select name="interest_unit">
            <option value="0">per year</option>
            <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(7);
		else
			strTemp = WI.fillTextValue("interest_unit");
			
		if(strTemp.compareTo("1") ==0){%>
            <option value="1" selected>per month</option>
            <%}else{%>
            <option value="1">per month</option>
            <%}%>
          </select></td>
    </tr>
		<%if(bolIsSchool){%>
    <tr> 
      <td height="30">&nbsp;</td>
      <td height="30">Year</td>
      <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(2);
			else
				strTemp = WI.fillTextValue("sy_from");
				strTemp = WI.getStrValue(strTemp);
			%>
      <td height="30" colspan="2"><input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	   onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        to 
        <%
	  	if(vEditInfo != null && vEditInfo.size() > 0)
			strTemp = (String)vEditInfo.elementAt(3);
		else				
		    strTemp = WI.fillTextValue("sy_to");
				strTemp = WI.getStrValue(strTemp);
	  %> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes"></td>
    </tr>
		<%}%>
	<%}// for regular loans only%>
	<%if (iAccessLevel > 1) { %>
    <tr> 
      <td height="38" colspan="4" align="center"><%if(strPrepareToEdit.compareTo("1") != 0) {%>
        <!--
					<a href='javascript:PageAction(1, "","");'> <img src="../../../images/save.gif" border="0" id="hide_save"></a>
					-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1', '','');">
				<font size="1">click to save entries</font> 
        <%}else{%>
        <!--
					<a href="javascript:PageAction(2,'<%=strInfoIndex%>','');"><img src="../../../images/edit.gif"border="0"></a>
					-->
				<input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('2','<%=strInfoIndex%>','');">
				<font size="1"> click to save changes</font>
        <%}%>
				<!--
          <a href="javascript:CancelRecord('<%=strLoanType%>');"><img src="../../../images/cancel.gif" border="0"></a> 
					-->
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord('<%=strLoanType%>');">
        <font size="1"> click to clear fields </font></td>
    </tr>
		<%}//end if (iAccessLevel > 1) %>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
    <tr> 
      <td height="26" colspan="4" align="right"><font size="1"><a href="javascript:PrintPg()"><img src="../../../images/print.gif" border="0" ></a> 
      click to print</font></td>
    </tr>
  </table>	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr bgcolor="#B9B292"> 
      <td height="25" colspan="6" align="center" class="BorderAll"><font color="#FFFFFF"><strong>:: 
      LIST OF EXISTING LOANS IN RECORD ::</strong></font></td>
    </tr>
    <tr> 
      <%if(strLoanType.equals("2") && bolIsSchool){%>
      <td width="11%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">SCHOOL 
      YEAR </font></strong></td>
      <%}%>
      <td width="13%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN 
      CODE</font></strong></td>
      <td width="26%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN 
      NAME</font></strong></td>
      <%if(strLoanType.equals("2")){%>
      <td width="16%" align="center" class="BorderBottomLeft"><font size="1"><strong>MAXIMUM 
      TERM OF PAYMENT</strong></font></td>
      <td width="20%" align="center" class="BorderBottomLeft"><strong><font size="1">INTEREST</font></strong></td>
      <%}%>
      <td width="14%" align="center" class="BorderBottomLeftRight"><strong><font size="1">OPTION</font></strong></td>
    </tr>
    <%for(int i = 0; i < vRetResult.size();i+=14){%>
    <tr> 
      <%if(strLoanType.equals("2") && bolIsSchool){%>
      <td height="25" align="center" class="BorderBottomLeft"> <%=WI.getStrValue((String)vRetResult.elementAt(i+2))%><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"-","","&nbsp;")%> </td>
      <%}%>
      <td class="BorderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="BorderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+11)%></td>
      <%if(strLoanType.equals("2")){%>
      <td class="BorderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+12)%>&nbsp;<%=astrTermUnit[Integer.parseInt((String)vRetResult.elementAt(i+13))]%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i+6);
				if(Double.parseDouble(strTemp) == 0)
					strTemp = "";
			%>
      <td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue(strTemp,""," " +astrInterestUnit[Integer.parseInt((String)vRetResult.elementAt(i+7))],"")%></td>
      <%}%>
      <td align="center" class="BorderBottomLeftRight">
			<% if (iAccessLevel > 1){%>
			<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border=0 > </a> 
			<%}else{%>
				N/A
			  <%}%>
			  <% if (iAccessLevel ==2){%>
			  <a href="javascript:PageAction('0', '<%=(String)vRetResult.elementAt(i)%>','<%=(String)vRetResult.elementAt(i+1)%>')"><img src="../../../images/delete.gif" border="0"></a>
			  <%}else{%>
				N/A
			  <%}%>			</td>
    </tr>
    <%}// end for loop%>
  </table>
	<%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
	
 <input type="hidden" name="show_close" value="<%=WI.fillTextValue("show_close")%>">
  <input type="hidden" name="loan_type" value="<%=WI.fillTextValue("loan_type")%>">
  <input type="hidden" name="print_page">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>