<%@ page language="java" import="utility.*,payroll.PayrollConfig,java.util.Vector" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payslip/Payroll Sheet Setting</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
</style>
</head>
<script language="javascript"  src ="../../../jscript/common.js" ></script>
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
function ReloadPage() {
	document.form_.reloaded.value = "";
	document.form_.submit();
}
function CancelRecord(){
	location = "./payslip_setting.jsp?is_for_sheet="+document.form_.is_for_sheet.value;
}

function CopyGroupName(){
	if(document.form_.group_select.value)
	document.form_.group_name.value = document.form_.group_select[document.form_.group_select.selectedIndex].text;
}

function CopyIntName(){
	if(document.form_.interest_select.value)
		document.form_.interest_name.value = document.form_.interest_select[document.form_.interest_select.selectedIndex].text;
}

</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;

	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Configuration-Payslip/Register Setting","payslip_setting.jsp");
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
														"payslip_setting.jsp");
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
	Vector vRetResult = null;
	String strCodeIndex  = null;
	String strType = null;
	String strFieldType = null;
	int i = 0;
	
	String strPageAction = WI.fillTextValue("page_action");
	String strChecked = null;
	String strIsForSheet = WI.getStrValue(WI.fillTextValue("is_for_sheet"),"0");
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	int iMaxNumber = 26;
	if(strIsForSheet.equals("0"))
		iMaxNumber = 51;

	if(strPageAction.length() > 0){
		if(prConfig.operateOnGroupMapping(dbOP, request, Integer.parseInt(strPageAction)) == null)
			strErrMsg =  prConfig.getErrMsg();
	}
	
	vRetResult  = prConfig.operateOnGroupMapping(dbOP, request, 4);	
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="payslip_setting.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
			<%
				if(WI.fillTextValue("is_for_sheet").equals("1"))
					strTemp = "PAYROLL SHEET ";
				else	
					strTemp = "PAYSLIP ";					
			%>
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: PAYROLL: <%=strTemp%> SETTING PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
		<% 
 		if(!strSchCode.startsWith("AUF") || (strSchCode.startsWith("AUF") && strIsForSheet.equals("0"))){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Grouping</td>
      <td><font size="1">
        <select name="item_type" onChange="document.form_.dType.value='';ReloadPage();">
          <option value="0">EARNINGS</option>
          <%
					strFieldType = WI.fillTextValue("item_type");
					if(strFieldType.equals("1")) {%>
          <option value="1" selected>DEDUCTIONS</option>
          <%}else{%>
          <option value="1">DEDUCTIONS</option>
          <%}%>
					<%if(strFieldType.equals("2")) {%>
          <option value="2" selected>EARNINGS DEDUCTIONS</option>
          <%}else{%>
          <option value="2">EARNINGS DEDUCTION</option>
          <%}%>
        </select>
      </font></td>
    </tr>
		<%
			strFieldType = WI.fillTextValue("item_type");
			strFieldType = WI.getStrValue(strFieldType,"0");
		%>
		<%}else{
		//strType = 
		strFieldType = "1";
		%>
		<input type="hidden" name="item_type" value="1">
		<%}%>
		<%
		strType = WI.fillTextValue("dType");
		if(!strFieldType.equals("2")){%>
    <tr> 
      <td width="4%" height="25">&nbsp;</td>
      <td width="21%">Item Source </td>
      <td><font size="1">
        <select name="dType" onChange="ReloadPage();">
					<option value="">Select field</option>
				<%if(strFieldType.equals("1")){%>          
					<%if(strType.compareTo("1") == 0) {%>
          <option value="1" selected>Miscellaneous Deductions</option>
          <%}else{%>
					<option value="1">Miscellaneous Deductions</option>
          <%}%>
					<%if(strType.compareTo("2") == 0) {%>
          <option value="2" selected>Loans</option>
          <%}else{%>
          <option value="2">Loans</option>
          <%}%>
					<%if(strType.compareTo("3") == 0){%>
          <option value="3" selected>Contribution</option>
          <%}else{%>
          <option value="3">Contribution</option>
          <%}%>
        <%} else if(strFieldType.equals("0")) {%>
					<%if(strType.compareTo("5") == 0){%>
          <option value="5" selected>Misc. Earning</option>
					<%}else{%>
					<option value="5">Misc. Earning</option>
					<%}%>
          <%if(strType.compareTo("7") == 0){%>
          <option value="7" selected>Allowances</option>
          <%}else{%>
          <option value="7">Allowances</option>
					<%}%>
          <%if(strType.compareTo("9") == 0){%>
          <option value="9" selected>Incentives</option>
          <%}else{%>
          <option value="9">Incentives</option>
					<%}%>					
 			  <%}%>
        </select>
      </font></td>
    </tr>
		<%}else{%>
			<input type="hidden" name="dType" value="4">
		<%}%>
		
		<%if(strType.equals("1")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Miscellaneous Deduction </td>
      <td><select name="deduct_index">
        <%strTemp= WI.fillTextValue("deduct_index");%>
        <option value="">Select Deduction Name</option>
        <%=dbOP.loadCombo("pre_deduct_index","pre_deduct_name", " from preload_deduction " +
				" where not exists(select * from pr_group_map where misc_ded_index = pre_deduct_index " +
				"   and is_for_sheet = " + strIsForSheet + " and is_deduction = 1) order by pre_deduct_name", strTemp, false)%>
      </select></td>
    </tr>
		<%}else if(strType.equals("2")){%>		
    <tr>
      <td height="25">&nbsp;</td>
      <td>Loan</td>
			<%
				strCodeIndex = WI.fillTextValue("code_index");
			%>
	    <td>
			<select name="code_index">
          <option value="">Select Loan</option>
          <%=dbOP.loadCombo("code_index","loan_name, loan_code",
		                    " from ret_loan_code where is_valid = 1 and loan_type > 1 " +
												" and not exists(select * from pr_group_map where loan_index = code_index " +
												"   and is_for_sheet = " + strIsForSheet + " and is_interest = 1) " +
												" order by loan_code", strCodeIndex ,false)%>
        </select>
			</td>
    </tr>
    
		<%}else if(strType.equals("3")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Contribution</td>
      <td><select name="cont_index">
      <%=dbOP.loadCombo("BENEFIT_INDEX","BENEFIT_NAME,SUB_TYPE", " from HR_BENEFIT_INCENTIVE " +
			 " join HR_PRELOAD_BENEFIT_TYPE on (HR_PRELOAD_BENEFIT_TYPE.BENEFIT_TYPE_INDEX = "+
    	 " HR_BENEFIT_INCENTIVE.BENEFIT_TYPE_INDEX) where IS_INCENTIVE = 0 and COVERAGE_UNIT = 2 "+
       " and IS_BENEFIT = 0 and BENEFIT_NAME not in ('loans','loan') and is_valid = 1 " +
			 " and is_del = 0 and not exists(select * from pr_group_map " +
			 "     where cont_index = BENEFIT_INDEX and is_for_sheet = " + strIsForSheet + ")" +
			 " order by benefit_name",WI.fillTextValue("b_index"),false)%>
      </select></td>
    </tr>		
		<%}else if(strType.equals("5")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Misc Earning</td>
    	<td><select name="earning_index">
        <option value="">Select earning Name</option>
        <%=dbOP.loadCombo("earn_ded_index","earn_ded_name", " from preload_earn_ded " +
				 " where not exists(select * from pr_group_map " +
				 "     where pr_group_map.earning_index = preload_earn_ded.earn_ded_index " +				
				 "   and is_for_sheet = " + strIsForSheet + ") order by earn_ded_name", strTemp, false)%>
      </select>
   	  <input name="earning_scroll" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("earning_scroll")%>" size="8" maxlength="8"
	  onKeyUp = "AutoScrollList('form_.earning_scroll','form_.earning_index',true);" ></td>
    </tr>
		<%}else if(strType.equals("6")){%>
    <!--
		<tr>
      <td height="25">&nbsp;</td>
      <td>Adjustment Type </td>
      <td><select name="adjustment">
        <option value="">Select Adjustment Type</option>
        <%=dbOP.loadCombo("ot_type_index","code", " from pr_ot_mgmt where is_valid = 1 " +
				" and is_for_ot = 0 and not exists(select * from pr_group_map " +
				"     where ot_type_index = adjusment_index and is_for_sheet = " + strIsForSheet + ") " +
				" order by code", strTemp, false)%>
      </select></td>
    </tr>
		-->
		<%}else if(strType.equals("7")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Allowance</td>
      <td><select name="allowance_index">
        <option value="">Select Allowance</option>
        <%=dbOP.loadCombo("cola_ecola_index","allowance_name, sub_type", " from pr_cola_ecola " +
		  " where is_valid = 1 and is_cola = 0 and not exists(select * from pr_group_map " +
				"     where cola_ecola_index = allowance_index and is_for_sheet = " + strIsForSheet + ") " +
				" order by allowance_name", strTemp, false)%>
      </select><input name="allowance_scroll" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("allowance_scroll")%>" size="8" maxlength="8"
	  onKeyUp = "AutoScrollList('form_.allowance_scroll','form_.allowance_index',true);" >
		</td>
    </tr>		
		<%}else if(strType.equals("8")){%>
		<!--
    <tr>
      <td height="25">&nbsp;</td>
      <td>Overtime type </td>
      <td><select name="overtime">
        <option value="">Select Overtime Type</option>
        <%=dbOP.loadCombo("ot_type_index","code", " from pr_ot_mgmt where is_valid = 1 " +
				" and is_for_ot = 0 and not exists(select * from pr_group_map " +
				"   where ot_type_index = overtime_index) ", strTemp, false)%>
      </select></td>
    </tr>
		-->
		<%}else if(strType.equals("9")){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Incentives</td>
      <td><select name="incentive_index">
        <%=dbOP.loadCombo("BENEFIT_INDEX","BENEFIT_NAME,SUB_TYPE", " from HR_BENEFIT_INCENTIVE " +
			 " join HR_PRELOAD_BENEFIT_TYPE on (HR_PRELOAD_BENEFIT_TYPE.BENEFIT_TYPE_INDEX = "+
    	 " HR_BENEFIT_INCENTIVE.BENEFIT_TYPE_INDEX) where IS_INCENTIVE = 1 "+
       " and is_valid = 1 and is_del = 0 and not exists(select * from pr_group_map " +
			"     where incentive_index = BENEFIT_INDEX and is_for_sheet = " + strIsForSheet + ") " +
			 " order by benefit_name",WI.fillTextValue("incentive_index"), false)%>
      </select>
			</td>
    </tr>				
    <%}%>
		<%if(strFieldType.equals("2")){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Earning deduction</td>
      <td><select name="earn_ded_index">
        <option value="">Select earning Name</option>
        <%=dbOP.loadCombo("earn_ded_index","earn_ded_name", " from preload_earn_ded " +
				 " where not exists(select * from pr_group_map " +
				 "     where pr_group_map.earn_ded_index = preload_earn_ded.earn_ded_index " +
				 "   and is_for_sheet = " + strIsForSheet + " and is_deduction = 2) order by earn_ded_name",strTemp, false)%>
      </select></td>
    </tr>
		<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">
			<%
			if(WI.fillTextValue("is_for_sheet").equals("1") && strFieldType.equals("1")){
				strTemp = WI.fillTextValue("exclude");
				if(strTemp.length() > 0)
					strChecked = " checked";
				else
					strChecked = " ";
			%>
				<input name="exclude" type="checkbox" value="1"<%=strChecked%>>
        <font size="1">don't include selected item in the payroll sheet/register total. </font>
			<%}%>				</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Existing Group names </td>
      <td><select name="group_select" onChange="CopyGroupName();" onFocus="CopyGroupName();">
        <%=dbOP.loadCombo("distinct group_name","group_name"," from PR_GROUP_MAP " +
				" where is_deduction = " + strFieldType + " order by PR_GROUP_MAP.group_name",null, false)%>
      </select>
        <font size="1">select from the list the if group name is existing</font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Group name </td>
			<%
				strTemp = WI.fillTextValue("group_name");
			%>
      <td><input name="group_name" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>" size="32" maxlength="32"
	  onKeyUp = "AutoScrollList('form_.group_name','form_.group_select',true);" >
			<%
			if(WI.fillTextValue("is_for_sheet").equals("0")){
			strTemp = WI.fillTextValue("show_blank");
			if(strTemp.length() > 0)
				strChecked = " checked";
			else
				strChecked = " ";
			%>
      <input name="show_blank" type="checkbox" value="1"<%=strChecked%>>
      <font size="1">show group  even if blank or zero value </font>
			<%}%>			</td>
    </tr>
<tr>
      <td height="25">&nbsp;</td>
      <td>Order Number </td>
      <td><select name="order_no">
				<%for(i = 1;i < iMaxNumber; i++){%>
				<%if(WI.fillTextValue("order_no").equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=i%></option>
				<%}else{%>
				<option value="<%=i%>"><%=i%></option>
				<%}%>
				<%}%>
      </select></td>
    </tr>
		<%if(strType.equals("2")){%>		
    <tr bgcolor="#C6EAFB">
      <td height="25">&nbsp;</td>
      <td colspan="2" style="color:#FF0000"><strong>(For loan interest fields only)</strong></td>
    </tr>
    <tr bgcolor="#C6EAFB">
      <td height="25">&nbsp;</td>
      <td>Existing Group names</td>
      <td><select name="interest_select" onChange="CopyIntName();" onFocus="CopyIntName();">
        <%=dbOP.loadCombo("distinct group_name","group_name"," from PR_GROUP_MAP " +
				" where is_deduction = " + strFieldType + " order by group_name",null, false)%>
      </select>
        <font size="1">select from the list the if group name is existing</font></td>
    </tr>		
    <tr bgcolor="#C6EAFB">
      <td height="25">&nbsp;</td>
      <td>Group name (interest)</td>
			<%
				strTemp = WI.fillTextValue("interest_name");
			%>
      <td><input name="interest_name" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	  onBlur="style.backgroundColor='white'" value="<%=WI.getStrValue(strTemp)%>" size="32" maxlength="32"
	  onKeyUp = "AutoScrollList('form_.interest_name','form_.interest_select',true);" ></td>
    </tr>
    <tr bgcolor="#C6EAFB">
      <td height="25">&nbsp;</td>
      <td>Order Number (interest)</td>
      <td><select name="int_order_no">
				<%for(i = 1;i < iMaxNumber; i++){%>
				<%if(WI.fillTextValue("int_order_no").equals(Integer.toString(i))){%>
        <option value="<%=i%>" selected><%=i%></option>
				<%}else{%>
				<option value="<%=i%>"><%=i%></option>
				<%}%>
				<%}%>
      </select></td>
    </tr>
		<%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">Note:<font size="1"> Items that are not mapped will be considered as <strong>others</strong>. There  is no need to create an <strong>others</strong> group name. </font></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td width="75%" height="25">
				<%if(iAccessLevel > 1){%>
				<font size="1">        <!--
				<a href='javascript:PageAction(1,"");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
				-->
				<input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction('1','');">
        Click to save entries 
        <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">
      Click to clear </font>
				<%}%>
			</td>
    </tr>
  </table>
	<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td height="24" colspan="5" align="center" bgcolor="#B9B292" class="thinborder"><strong><font color="#FFFFFF">LIST OF 
          ITEM MAPPINGS </font></strong></td>
    </tr>
    <tr>
      <td width="11%" align="center" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">Order Number </span></td> 
      <td width="41%" height="25" align="center" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">Group name to display </span></td>
      <td width="36%" align="center" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">Field</span></td>
      <%if(WI.fillTextValue("is_for_sheet").equals("0")){%>
			<td width="12%" align="center" class="thinborder"><span class="thinborder" style="font-size:9px; font-weight:bold">Show Blank or Zero </span></td>
			<%}%>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">DELETE</font></strong></td>
    </tr>
		<%for(i = 0; i < vRetResult.size();i+=10){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td> 
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
      <%if(WI.fillTextValue("is_for_sheet").equals("0")){
				strTemp = (String)vRetResult.elementAt(i+4);
				if(strTemp.equals("1"))
					strTemp = "YES";
				else
					strTemp = "NO";
			%>
			<td class="thinborder" align="center">&nbsp;<%=strTemp%></td>
			<%}%>
      <td class="thinborder" align="center">&nbsp;
			<%if(iAccessLevel ==2){%>
		  <%if(!((String)vRetResult.elementAt(i+5)).equals("1")){%>
			<a href='javascript:PageAction("0","<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/delete.gif" border="0"></a>	  
			<%}%>
			<%}%>
			</td>
    </tr>
		<%}%>
  </table>
	<%}%>
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
<input type="hidden" name="reloaded" value="<%=WI.fillTextValue("reloaded")%>">
<input type="hidden" name="is_for_sheet" value="<%=WI.fillTextValue("is_for_sheet")%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
