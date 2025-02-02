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
<title>Update Loan Schedule</title>
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
  
function ReloadPage(){
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce("form_");
}

function CancelRecord(strLoanType){
	document.form_.donot_call_close_wnd.value = "1";
	this.SubmitOnce("form_");
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

function SaveList(){
	document.form_.donot_call_close_wnd.value = "1";
	document.form_.savelist.value="1";
	this.SubmitOnce("form_");
}

function checkAllSave() {
	var maxDisp = document.form_.recordcount.value;
	//unselect if it is unchecked.
	if(!document.form_.selAllSave.checked) {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=false');
	}
	else {
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked=true');
	}
}

function CopyPrincipal(){
	var vItems = document.form_.recordcount.value;
	if (vItems.length == 0)
		return;	
 
		for (var i = 1 ; i < eval(vItems);++i)
			eval('document.form_.principal_amt_'+i+'.value=document.form_.principal_amt_1.value');			
}

function CopyInterest(){
	var vItems = document.form_.recordcount.value;
	if (vItems.length == 0)
		return;	
 
		for (var i = 1 ; i < eval(vItems);++i)
			eval('document.form_.interest_amt_'+i+'.value=document.form_.interest_amt_1.value');			
}

function copyOld(strValue, strRow, strPrincipal){
	if(strPrincipal == '1')
		eval('document.form_.principal_amt_'+strRow+'.value='+strValue);			
	else
		eval('document.form_.interest_amt_'+strRow+'.value='+strValue);			
}
-->
</script>
<body bgcolor="#D2AE72" onUnload="ReloadParentWnd();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp  = null;
	String strTemp2 = null;
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
								"Admin/staff-RETIREMENT-ENCODE_LOADNS-Create Loans","sched_total_monthly_payments.jsp");
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
	String strTypeName = "Company";
	boolean bolAllowUpdate = false;
	
	double dOldPrincipal = 0d;
	double dOldInterest = 0d;
	double dNewPrincipal = 0d;
	double dNewInterest = 0d;
	double dTemp = 0d;	
	int iCount = 1;

	if(WI.fillTextValue("savelist").length() > 0){
		if(PRRetLoan.operateOnLoadSchedule(dbOP, request, 1) == null)
			strErrMsg = PRRetLoan.getErrMsg();
	}
 
	vRetResult = PRRetLoan.operateOnLoadSchedule(dbOP,request,4);	
	if (vRetResult != null && strErrMsg == null){
		strErrMsg = PRRetLoan.getErrMsg();	
	}
%>
<form name="form_" method="post" action="./update_loan_schedule.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <%if(strLoanType.equals("3")){
		strTypeName = "SSS";		
	%>
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
        PAYROLL : LOANS : ENCODE SSS LOAN AMORTIZATION SCHEDULE PAGE ::::</strong></font></td>
    </tr>
    <%}else if(strLoanType.equals("4")){
		strTypeName = "PAG-IBIG";
	%>
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong> :::: PAYROLL : LOANS : ENCODE PAG-IBIG LOAN AMORTIZATION SCHEDULE PAGE 
        ::::</strong></font></td>
    </tr>
    <%}else if(strLoanType.equals("5")){
		strTypeName = "PERAA";
	%>
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong> :::: PAYROLL : LOANS : ENCODE PERAA LOAN AMORTIZATION SCHEDULE PAGE 
        ::::</strong></font></td>
    </tr>
    <%}%>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1"><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" width="71" height="32" border="0"></a></font>click 
        to close window</td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
   <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
     <tr>
		 	 <%
			 	strTemp = WI.fillTextValue("show_all");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			 %>
       <td><input type="checkbox" name="show_all" value="1" <%=strTemp%> onClick="ReloadPage();">show complete schedule</td>
     </tr>
   </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#99CCFF"> 
      <td height="25" colspan="6" align="center" class="BorderAll"><strong>:: 
        AMORTIZATION SCHEDULE FOR <%=strTypeName%> LOAN ::</strong></td>
    </tr>
    <tr> 
      <td width="13%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1">DATE</font></strong></td>
      <td width="16%" align="center" class="BorderBottomLeft"><strong><font size="1">OLD PRINCIPAL</font></strong></td>
      <td width="15%" align="center" class="BorderBottomLeft"><strong><font size="1">OLD INTEREST</font></strong></td>
      <td width="22%" align="center" class="BorderBottomLeft"><strong><font size="1">NEW PRINCIPAL<br>
      <a href="javascript:CopyPrincipal();">COPY</a></font></strong></td>
      <td width="20%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1">NEW INTEREST<br>
        <a href="javascript:CopyInterest();">COPY</a></font></strong></td>
      <!--
	  <td width="22%" height="24" class="BorderBottomLeft"><div align="center"><strong><font size="1">PRINCIPAL</font></strong></div></td>	  
      <td width="27%" class="BorderBottomLeft"><div align="center"><strong><font size="1">INTEREST</font></strong></div></td>
	  -->
      <td width="14%" align="center" class="BorderBottomLeftRight">
		   <strong>
	     <font size="1">OPTION</font>		   </strong>		   <!--<br><a href="javascript:PageAction('5', '','')">DELETE ALL</a>-->		 <br>
	     <font size="1">
			 <%
			 	strTemp = WI.fillTextValue("selAllSave");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			 %>
	     <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" <%=strTemp%>>
       </font></td>
    </tr>
    <%for(int i = 0; i < vRetResult.size() ; i+=8,iCount++){
			if(ConversionTable.compareDate(WI.getTodaysDate(1), (String)vRetResult.elementAt(i+1)) < 0)
				 bolAllowUpdate = true;
		%>
    <tr> 
			<input type="hidden" name="schedule_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
      <td class="BorderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3));
				dTemp = Double.parseDouble(strTemp);
				dOldPrincipal += dTemp;
			%>
      <td align="right" class="BorderBottomLeft"><a href="javascript:copyOld('<%=strTemp%>', '<%=iCount%>', '1');"><%=strTemp%></a>&nbsp;</td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4));
				dTemp = Double.parseDouble(strTemp);
				dOldInterest += dTemp;
			%>			
      <td align="right" class="BorderBottomLeft"><a href="javascript:copyOld('<%=strTemp%>', '<%=iCount%>', '0');"><%=strTemp%></a>&nbsp;</td>
			<%
				strTemp2 = WI.fillTextValue("principal_amt_"+iCount);
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6), true);
				strTemp = ConversionTable.replaceString(strTemp, ",", "");
				if(strTemp2.length() == 0)
					strTemp2 = strTemp;
				dTemp = Double.parseDouble(strTemp);
				dNewPrincipal += dTemp;				
				
			%>
      <td align="right" class="BorderBottomLeft"><%=strTemp%><strong>
        <input name="principal_amt_<%=iCount%>" type="text" class="textbox" size="7" maxlength="10" 
				onfocus="style.backgroundColor='#D3EBFF'"
				onblur="AllowOnlyFloat('form_','principal_amt_<%=iCount%>');style.backgroundColor='white'" 
				onKeyUp="AllowOnlyFloat('form_','principal_amt_<%=iCount%>');"
				value="<%=strTemp2%>" style="text-align:right;font-size:11px;">
      </strong>&nbsp;</td>
			<%
				strTemp2 = WI.fillTextValue("interest_amt_"+iCount);
				
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+7), true);
				strTemp = ConversionTable.replaceString(strTemp, ",", "");
				
				if(strTemp2.length() == 0)
					strTemp2 = strTemp;
					
				dTemp = Double.parseDouble(strTemp);
				dNewInterest += dTemp;
			%>
      <td height="29" align="right" class="BorderBottomLeft"><%=strTemp%>        
				<input name="interest_amt_<%=iCount%>" type="text" class="textbox" size="7" maxlength="10" 
				onfocus="style.backgroundColor='#D3EBFF'"
				onblur="AllowOnlyFloat('form_','interest_amt_<%=iCount%>');style.backgroundColor='white'" 
				onKeyUp="AllowOnlyFloat('form_','interest_amt_<%=iCount%>');"
				value="<%=strTemp2%>" style="text-align:right">
				</td>
      <!--
	  <td height="29" class="BorderBottomLeft"><div align="right"><%=(String)vRetResult.elementAt(i+3)%>&nbsp;</div></td>	  
      <td class="BorderBottomLeft"><div align="right"><%=(String)vRetResult.elementAt(i+4)%>&nbsp;</div></td>
	  -->
      <td align="center" class="BorderBottomLeftRight">
        <%if(bolAllowUpdate){%>
				<%if(WI.fillTextValue("save_"+iCount).length() > 0)
						strTemp = "checked";
					else
						strTemp = "";
				%>
				<input type="checkbox" name="save_<%=iCount%>" value="1" <%=strTemp%> tabindex="-1">
				<%}else{%>
				<input type="hidden" name="save_<%=iCount%>">
				&nbsp;
				<%}%>
      </td>
    </tr>
    <%}%>
		<input type="hidden" name="recordcount" value="<%=iCount%>">
    <tr> 
      <td height="19" colspan="6"><hr size="1"></td>
    </tr>
    <tr> 
      <td>TOTALS :</td>
      <td align="right"><%=CommonUtil.formatFloat(dOldPrincipal, true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dOldInterest, true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dNewPrincipal, true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dNewInterest, true)%>&nbsp;</td>
      <td height="24">&nbsp;</td>
    </tr>
    <tr>
			<%
				strTemp = "";
				if(dOldPrincipal != dNewPrincipal)
					strTemp = "There is a difference in the total of the Principal Schedules";

				if(dOldInterest != dNewInterest){
					if(strTemp.length() > 0)
						strTemp += "<br>";
					strTemp += "There is a difference in the total of the Interest Schedules";
				}
			%>
      <td height="24" colspan="6"><strong><font size="3" color="#FF0000"><%=strTemp%></font></strong></td>
    </tr>
    <tr>
      <td height="24" colspan="6" align="center"><font size="1">
      <input type="button" name="122" value=" Save " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SaveList();">
click to save/edit selected schedules
<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
			onClick="javascript:CancelRecord();">
click to cancel</font></td>
    </tr>
  </table>
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <!-- this is used to reload parent if Close window is not clicked. -->
  <input type="hidden" name="close_wnd_called" value="0">
  <input type="hidden" name="donot_call_close_wnd">
  <!-- this is very important - onUnload do not call close window -->
  <input type="hidden" name="show_close" value="<%=WI.fillTextValue("show_close")%>">
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
    <input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
  <input type="hidden" name="code_index" value="<%=WI.fillTextValue("code_index")%>">
  <input type="hidden" name="loan_type" value="<%=WI.fillTextValue("loan_type")%>">
	<input type="hidden" name="ret_loan_index" value="<%=WI.fillTextValue("ret_loan_index")%>">	
	<input type="hidden" name="savelist">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>