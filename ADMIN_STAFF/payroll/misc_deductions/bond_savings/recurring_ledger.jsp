<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRMiscDeduction, payroll.PReDTRME" buffer="16kb" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
///added code for HR/companies.

boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
	String strEmpID = null;	
//add security here.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Detailed Recurring deductions Payment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--  

function ReloadPage()
{
 	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
 
function PrintPg(){
 	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
} 

function checkKeyPress(strFormName, strFieldName, strExtn, strKeyCode){
	/*
		strKeyCodes
			35 = end, 36 = home, 37 = left, 38 = up, 39 = right, 40 = down
			8 = backspace, 46 = delete
			96 - 105 - numpad
			48 - 57 - kanang sa taas na numbers
			110 - period sa main
			190 - period sa numpad
			111 - / sa keypad
			191 - / sa main
	*/
	//alert("strKeyCode - " + strKeyCode);
 	if((strKeyCode >= 35 && strKeyCode <= 40)		
		|| (strKeyCode >= 48	&& strKeyCode <= 57)
		|| (strKeyCode >= 96	&& strKeyCode <= 105)
		|| strKeyCode == 8	|| strKeyCode == 46)
		return;
	
	AllowOnlyFloat(strFormName, strFieldName);
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
	var strCompleteName = document.form_.emp_id.value;
	var objCOAInput = document.getElementById("coa_info");
	
	if(strCompleteName.length <=2) {
		objCOAInput.innerHTML = "";
		return ;
	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
		escape(strCompleteName);

	this.processRequest(strURL);
}

function UpdateID(strID, strUserIndex) {
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.form_.submit();
}

function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}

function UpdateNameFormat(strName) {
	//do nothing.
}

function AddRecord(){
	document.form_.donot_call_close_wnd.value="0";
	document.form_.page_action.value = "1";
	document.form_.print_page.value="";	
	document.form_.save.disabled = true;
	document.form_.submit();
//	this.SubmitOnce("form_");
} 

function DeleteRecord(strInfoIndex){
	if(!confirm('Continue with delete transaction?'))
		return;
	
	document.form_.donot_call_close_wnd.value="0";
	document.form_.page_action.value = "0";
	document.form_.info_index.value = strInfoIndex;
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
 

function CancelRecord(){
	document.form_.donot_call_close_wnd.value="0";
	
		location ="./recurring_ledger.jsp?popup="+document.form_.popup.value+
							"&emp_id="+document.form_.emp_id.value+
							"&misc_ded_index="+document.form_.misc_ded_index.value+
							"&view_all="+document.form_.view_all.value;
}

function finalize(strObj, strInfoIndex) {
 	var objCOAInput = document.getElementById(strObj);
 
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=308&r_index="+strInfoIndex;

	this.processRequest(strURL);
}
</script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
 
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="recurring_ledger_print.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions (Per Employee)","recurring_ledger.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
 	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"recurring_ledger.jsp");

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vPersonalDetails = null;
Vector vRetResult = null;
Vector vEmpList = null;
Vector vDate = null;
double dTemp = 0d;
double dTotal = 0d;

	PRMiscDeduction prd = new PRMiscDeduction(request);
	String strPageAction = WI.fillTextValue("page_action");
	
	String strSchCode = dbOP.getSchoolIndex();
	String strReadOnly = "";
	boolean bolPopUp = false;
	if(WI.fillTextValue("popup").length() > 0){
		bolPopUp = true;
		strReadOnly = " readonly";
	}
	int iSearchResult = 0;
	int i = 0;

	enrollment.Authentication authentication = new enrollment.Authentication();
	vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	
	if(strPageAction.length() > 0){
		vRetResult = prd.operateOnBondSavingsReleasing(dbOP, request, Integer.parseInt(strPageAction));
		if(vRetResult == null && strErrMsg == null)
			strErrMsg = prd.getErrMsg();
	}

 	vRetResult = prd.generateMiscDedLedger(dbOP, request);
	if(vRetResult == null && strErrMsg == null)
		strErrMsg = prd.getErrMsg();
	else{
		iSearchResult = prd.getSearchCount();
	}
	
	
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="recurring_ledger.jsp" method="post" name="form_">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
    <tr>
      <td height="23" colspan="4"><font size="1"><a href="./bond_savings_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
    <tr>
      <td height="23" colspan="4"><strong><font size="3">&nbsp;<%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>		
</table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">		
  <tr>
    <td width="4%">&nbsp;</td>
    <td width="14%">Employee ID </td>
			<%
				if(strReadOnly.length() == 0)
					strReadOnly = "onKeyUp = AjaxMapName();";
			%>		
    <td width="31%"><input name="emp_id" type="text" class="textbox" <%=strReadOnly%> 
	    onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			value="<%=WI.fillTextValue("emp_id")%>" size="16"></td>
    <td width="51%"><div style="position:absolute;" ><label id="coa_info"></label></div></td>
  </tr>
	<%if(bolPopUp){%>
	<input type="hidden" name="misc_ded_index" value="<%=WI.fillTextValue("misc_ded_index")%>">			
	<%}else{%>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
		<%
			strTemp = WI.fillTextValue("misc_ded_index");
			strTemp = WI.getStrValue(strTemp, "0");
		%>
    <td>
			<select name="misc_ded_index" onChange="ReloadPage();">			
      <option value="">Select Deduction Name</option>			
      <%=dbOP.loadCombo("PRE_DEDUCT_INDEX","PRE_DEDUCT_NAME", " from preload_deduction " +
													" where is_savings_type = 1 order by pre_deduct_name", strTemp, false)%>			
			</select>
    </td>
    <td>&nbsp;</td>
  </tr>	
  <tr>
    <td height="21">&nbsp;</td>
    <td>&nbsp;</td>
    <td><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();"></td>
    <td>&nbsp;</td>
  </tr>
	<%}%>
</table>
<% if (vPersonalDetails !=null && vPersonalDetails.size() > 0){ %>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="4%" height="28">&nbsp;</td>
      <td height="28" colspan="2">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="29" colspan="2"><%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="46%">Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%>
        </strong></td>
      <td width="50%" height="29">Employment Status : <strong><%=(String)vPersonalDetails.elementAt(16)%>
        </strong></td>
    </tr> 
    <tr>
      <td height="15" colspan="3"><hr size="1" noshade></td>
    </tr>
  </table>
		
  <% if (vRetResult != null &&  vRetResult.size() > 1) { %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="10" colspan="2" align="right"><font size="2">Number of  rows Per 
        Page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(i = 10; i <=40 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}}%>
        </select>
      <font size="1"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0" ></a> click to print</font>&nbsp;</td>
    </tr>    
    <%
		if(WI.fillTextValue("view_all").length() == 0){
		int iPageCount = iSearchResult/prd.defSearchSize;		
		if(iSearchResult % prd.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
    <tr>
      <td height="10" colspan="2"><div align="right">Jump To page:
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}
			%>
          </select>
      </div></td>
    </tr>
		<%}
		}%>
  </table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
  <tr>
    <td align="center"><table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
      <tr>
        <td height="26" colspan="5" align="center" bgcolor="#B9B292" class="thinborder"><strong><%=WI.fillTextValue("deduction_name").toUpperCase()%> DEDUCTIONS</strong></td>
      </tr>
      <tr>
        <td width="7%" height="28" align="center" class="thinborder">&nbsp;</td>
        <td width="24%" align="center" class="thinborder"><font size="1"><strong>TRANSACTION DATE </strong></font></td>
        <td width="32%" align="center" class="thinborder"><font size="1"><strong>DESCRIPTION</strong></font></td>
        <td width="15%" align="center" class="thinborder"><font size="1"><strong>AMOUNT</strong></font></td>
        <td width="22%" align="center" class="thinborder">&nbsp;</td>
      </tr>
      <% 
			int iCount = 1;
 			for (i = 0; i < vRetResult.size(); i+=10,iCount++){%>
      <tr>
        <td height="25" class="thinborder" align="center"><%=iCount%>&nbsp;</td>
        <td width="24%" align="center" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i)%></font></td>
				<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+4)%></td>
				<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+1),true);
				strTemp = ConversionTable.replaceString(strTemp, ",","");
				strTemp2 = (String)vRetResult.elementAt(i+3);
				
				if(WI.getStrValue(strTemp2).equals("1"))					
					dTotal += Double.parseDouble(strTemp);				
				else
					dTotal -= Double.parseDouble(strTemp);				
				%>
        <td align="right" class="thinborder"><font size="1"><%=strTemp%>&nbsp;</font></td>
        <td align="center" class="thinborder">
				<label id="finalize_<%=iCount%>">
				<%
					strTemp = (String)vRetResult.elementAt(i+5);
					strTemp = WI.getStrValue(strTemp, "0");
					if(strTemp.equals("0")){						
				%>
				<a href="javascript:finalize('finalize_<%=iCount%>', '<%=vRetResult.elementAt(i+6)%>');">
				FINALIZE
				</a>
				&nbsp;&nbsp;
				<a href="javascript:DeleteRecord('<%=vRetResult.elementAt(i+6)%>');">
				DELETE
				</a>
				<%}else{%>
					--
				<%}%>
				</label>
				</td>
      </tr>
      <%} //end for loop%>
			<tr>
        <td height="25" colspan="2" align="right" class="thinborder">BALANCE : </td>        
        <td align="right" class="thinborder">&nbsp;</td>
        <td align="right" class="thinborder"><%=CommonUtil.formatFloat(dTotal, true)%>&nbsp;</td>
        <td align="right" class="thinborder">&nbsp;</td>
			</tr>      
    </table></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>
    <td width="4%">&nbsp;</td>
    <td width="18%">&nbsp;</td>
    <td width="78%">&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>Release Amount </td>
		<%
			strTemp = WI.fillTextValue("released_amt");
			if(strTemp.length() == 0)
				strTemp = CommonUtil.formatFloat(dTotal, 2);
		%>
    <td><strong>
      <input  type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
		onblur="style.backgroundColor='white'"  name="released_amt" value="<%=strTemp%>" size="10" 
		title="Amount to release to employee" maxlength="10" style="text-align:right"
		onKeyUp="checkKeyPress('form_','released_amt',event.keyCode);">
    </strong></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>Date of Release </td>
		<%
			strTemp = WI.fillTextValue("release_date");
			if(strTemp.length() == 0)
				strTemp = WI.getTodaysDate(1);
		%>
    <td><input name="release_date" type="text" size="12" maxlength="12" readonly value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <a href="javascript:show_calendar('form_.release_date');" title="Click to select date" 
			onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;">
			<img src="../../../../images/calendar_new.gif" border="0"></a></td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td>&nbsp;</td>
    <td colspan="2" align="center">
      <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
      <font size="1">click to add</font>
      <input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelRecord();">
      <font size="1">click to cancel or go previous</font></td>
    </tr>
</table>

  <% } // end vRetResult != null && vRetResult.size() > 0

}// end if Employee ID is null %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
	<input type="hidden" name="user_index" value="<%=WI.fillTextValue("user_index")%>">
	<input type="hidden" name="deduction_name" value="<%=WI.fillTextValue("deduction_name")%>">
	<input type="hidden" name="print_page">
	<input type="hidden" name="view_all" value="1">
	<input type="hidden" name="close_wnd_called" value="0">
	<input type="hidden" name="donot_call_close_wnd">
	<input type="hidden" name="page_action">	
	<input type="hidden" name="info_index">	
	<input type="hidden" name="popup" value="<%=WI.fillTextValue("popup")%>">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
