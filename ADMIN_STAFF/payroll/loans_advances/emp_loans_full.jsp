<%@ page language="java" import="utility.*,java.util.Vector, payroll.PRRetirementLoan, payroll.PRMiscDeduction" %>
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
<title>Set Loan to Zero</title>
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
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function focusID()
{
	document.form_.emp_id.focus();
}

function ReloadPage(){
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
}

function CopyID(strID){
	document.form_.print_page.value = "";
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");

}

function PageAction(strPageAction){	
	document.form_.page_action.value = strPageAction;
	document.form_.print_page.value = "";
	this.SubmitOnce("form_");
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
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
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
function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	String strEmpID = null;

if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./emp_loans_full_print.jsp" />
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

		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));		
		
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES-SETTOZERO"),"0"));
	}
	
	strEmpID = WI.fillTextValue("emp_id");
	if(strEmpID.length() == 0)
		strEmpID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
	strEmpID = WI.getStrValue(strEmpID, "");

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
								"Admin/staff-Payroll-LOANS-Set Loan to Zero","emp_loans_full.jsp");
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
	Vector vPersonalDetails = null;
	Vector vLoanInfo = null;
	Vector vRetResult = null;
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	PRMiscDeduction prd = new PRMiscDeduction(request);
	payroll.PRConfidential prCon = new payroll.PRConfidential();

	int iDefault  = 0;
	
	String strPageAction = WI.fillTextValue("page_action");
	String strCodeIndex = null;
	int iSearchResult = 0;
	String strEmpIndex = null;

	Vector vEmpList = null;
	int i = 0;
	String[] astrTermUnit = {"Months","Years"};
	boolean bolCheckAllowed = (prCon.checkIfEmpIsProcessor(dbOP, request, WI.fillTextValue("emp_id"), true) == 1);

	if (WI.fillTextValue("emp_id").length() > 0) {
		if(bolCheckAllowed){
			enrollment.Authentication authentication = new enrollment.Authentication();
			vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	
			if (vPersonalDetails == null || vPersonalDetails.size()==0){
				strErrMsg = authentication.getErrMsg();
				vPersonalDetails = null;
			}
			strEmpIndex = dbOP.mapUIDToUIndex(WI.fillTextValue("emp_id"));
			
			if(strPageAction.length() > 0){
				if(PRRetLoan.setLoanFullPaid(dbOP, 1) == null){
					strErrMsg = PRRetLoan.getErrMsg();				
				}
			}
	
			if(WI.fillTextValue("code_index").length() > 0){
				vLoanInfo = PRRetLoan.setLoanFullPaid(dbOP, 5);
				if(vLoanInfo == null)
					strErrMsg = PRRetLoan.getErrMsg();
					
				//if(PRRetLoan.fixLoanPayable(dbOP, request) == false)
				//	strErrMsg = PRRetLoan.getErrMsg();			
			}
	
			vRetResult = PRRetLoan.setLoanFullPaid(dbOP, 4);
			if(vRetResult != null)
				iSearchResult = PRRetLoan.getSearchCount();				
			else
				strErrMsg = PRRetLoan.getErrMsg();
			
			vEmpList = prd.getEmployeesList(dbOP);
		}else
			strErrMsg = prCon.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
<form name="form_" method="post" action="emp_loans_full.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
      PAYROLL : UPDATE LOANS  PAGE ::::</strong></font></td>
    </tr>
     <tr bgcolor="#FFFFFF">
      <td width="60%" height="25"><font size="3"><%=WI.getStrValue(strErrMsg,"")%></font></td>
      <td width="40%" align="right"><%
	  		if (vEmpList != null && vEmpList.size() > 0){
			  %>
        <%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.indexOf((String)vEmpList.elementAt(0))){%>
        <a href="javascript:CopyID('<%=vEmpList.elementAt(0)%>');">FIRST</a>
        <%}else{%>
FIRST
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) > 0){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) - 1)%>');"> PREVIOUS</a>
<%}else{%>
PREVIOUS
<%}%>
<%
				if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) < vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=vEmpList.elementAt(vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) + 1)%>');"> NEXT</a>
<%}else{%>
NEXT
<%}%>
<%if (vEmpList.indexOf(WI.fillTextValue("emp_id").toUpperCase()) != vEmpList.size()-1){%>
<a href="javascript:CopyID('<%=((String)vEmpList.elementAt(vEmpList.size()-1)).toUpperCase()%>');">LAST</a>
<%}else{%>
LAST
<%}%>
<%}// if (vEmpList != null && vEmpList.size() > 0)%></td>
    </tr>
     <tr bgcolor="#FFFFFF">
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
     <tr>
      <td width="3%">&nbsp;</td>
      <td width="21%" height="27"><br>
        Employee ID :</td>
      <td width="76%" height="27"> <font size="1">
        <input name="emp_id" type="text" class="textbox" onKeyUp="AjaxMapName(1);"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16">
        <strong><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" width="37" height="30" border="0"></a></strong>
        <input type="submit" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #999999;">
        </font><label id="coa_info"></label></td>
    </tr> 
  </table>
    <% if (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">&nbsp;Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">&nbsp;Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
    </tr>
    <tr>
      <td height="30">&nbsp;</td>
      <%
	strTemp = (String)vPersonalDetails.elementAt(13);
	if (strTemp == null){
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	}else{
		strTemp += WI.getStrValue((String)vPersonalDetails.elementAt(14)," :: ","","");
	}
%>
      <td height="30">&nbsp;<%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>&nbsp;Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="97%">&nbsp;Employment Status<strong> : <%=(String)vPersonalDetails.elementAt(16)%> </strong></td>
    </tr>
    <tr>
      <td height="19" colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    
    <tr>
      <td width="3%">&nbsp;</td>
      <%
	  	strTemp = WI.fillTextValue("code_index");
	  %>
      <td width="18%" height="26">&nbsp;Loan Code :</td>
	  <%strCodeIndex = WI.fillTextValue("code_index");%>
      <td height="26" colspan="3"><font size="1"><strong>
        <select name="code_index" onChange="ReloadPage();">
          <option value="">Select Loan</option>
          <%=dbOP.loadCombo("code_index","loan_name, loan_code",
		                    " from ret_loan_code where is_valid = 1 and loan_type > 1 " +
												" and exists(select * from retirement_loan " +
												"     where user_index = " + strEmpIndex + 
												"    and retirement_loan.code_index = ret_loan_code.code_index " +
												"    and retirement_loan.is_valid = 1 and payable_bal > 0) "
												//" and exists(select * from retirement_loan where payable_bal > 0 " +
												//"    and user_index = " + strEmpIndex + 
												//"    and retirement_loan.code_index = ret_loan_code.code_index) " 
												//+ " and exists(select * from ret_loan_schedule where user_index = " + strEmpIndex + 
										    // " and ret_loan_schedule.code_index = ret_loan_code.code_index)"
												, strCodeIndex ,false)%>
        </select>
      </strong></font></td>
    </tr>
    <tr>
      <td height="17" colspan="5"><hr size="1"></td>
    </tr>
	<%if(vLoanInfo != null && vLoanInfo.size() > 0){%>
		<input type="hidden" name="ret_loan_index" value="<%=(String)vLoanInfo.elementAt(0)%>">
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Amount Loaned : <font size="1"><strong> </strong></font></td>
      <td width="36%">&nbsp;<%=(String)vLoanInfo.elementAt(1)%></td>
      <td width="15%" height="27">&nbsp;Terms : <strong><font size="1"> </font></strong></td>
      <td width="28%">&nbsp;<%=(String)vLoanInfo.elementAt(2)%> <%=astrTermUnit[Integer.parseInt(WI.getStrValue((String)vLoanInfo.elementAt(5),"0"))]%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Release Date :<strong> </strong></td>
      <td>&nbsp;<%=WI.getStrValue((String)vLoanInfo.elementAt(3),"")%></td>
      <td height="27">&nbsp;First Payment : </td>
      <td>&nbsp;<%=(String)vLoanInfo.elementAt(4)%></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Payable Balance: </td>
      <td>&nbsp;<%=WI.getStrValue((String)vLoanInfo.elementAt(6),"")%><input type="hidden" name="payable" value="<%=(String)vLoanInfo.elementAt(6)%>"></td>
      <td height="27">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27"> &nbsp;Reason for update : </td>
      <td height="27" colspan="3"><font size="1">
        <input name="reason" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("reason")%>" size="40" maxlength="256">
      </font></td>
    </tr>
	<%}%>
    <tr>
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
    <tr>
      <td height="10" colspan="5" align="center"><font size="1">
        <a href='javascript:PageAction(1);'><img src="../../../images/update.gif" name="hide_save" width="60" height="26" border="0"></a><font size="1"> click to set loan to zero <a href="emp_loans_full.jsp?emp_id=<%=WI.fillTextValue("emp_id")%>"><img src="../../../images/cancel.gif" border="0"></a></font>click
      to cancel/clear entries </font></td>
    </tr>
  </table>	
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="9" align="right">Number of records per page 
          <select name="num_rows">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rows"),"20"));
				for(i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
        <a href="javascript:PrintPg();"> <img src="../../../images/print.gif" width="58" height="26" border="0"></a> 
        <font size="1">click to print list</font></td>
    </tr>
    <%		
		if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/PRRetLoan.defSearchSize;		
	if(iSearchResult % PRRetLoan.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr> 
      <td height="25" colspan="9" align="right">Jump To page: 
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
          </select>      </td>
    </tr>
    <%}
		}%>
    <tr>
      <td height="15" colspan="9" class="BorderBottom">&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="25" align="center" class="BorderBottomLeft">&nbsp;</td>
      <td width="10%" align="center" class="BorderBottomLeft"><strong><font size="1">REF # </font></strong></td>
      <td width="12%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN CODE </font></strong></td>
			<td width="8%" align="center" class="BorderBottomLeft"><strong><font size="1">DATE AVAILED </font></strong></td>
      <td width="10%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">AMOUNT       LOAN </font></strong></td>
			<td width="10%" align="center" class="BorderBottomLeft"><strong><font size="1">ADJUSTMENT</font></strong></td>
			<td width="24%" align="center" class="BorderBottomLeft"><strong><font size="1">REASON</font></strong></td>
      <td width="23%" align="center" class="BorderBottomLeftRight"><strong><font size="1">ADJUSTED BY </font></strong></td>
    </tr>
    <%
	int iCount = 1;
	for(i = 0; i < vRetResult.size(); i+=35, iCount++){
	%>
    <tr> 
      <td height="24" align="right" class="BorderBottomLeft"><%=iCount%>&nbsp;</td>
      <td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+22),"&nbsp;")%></td>
      <td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+23),"&nbsp;")%></td>
			<td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%></td>
      <%	
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+3),true);
			%>							
      <td height="24" align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>
     <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+14),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
 		%>      
	  <td align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
		<%	
		strTemp = (String)vRetResult.elementAt(i+15);
	  %>	
    <td class="BorderBottomLeft">&nbsp;<%=strTemp%></td>
		<%	
		strTemp = (String)vRetResult.elementAt(i+32);
	  %>			
    <td class="BorderBottomLeftRight">&nbsp;<%=strTemp%></td>
    </tr>
    <%
		}// end for loop %>
  </table>	
  <%}
	}// largest if... (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="page_action">
	<input type="hidden" name="print_page">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>