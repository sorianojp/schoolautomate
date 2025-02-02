<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan,payroll.PRMiscDeduction" %>
<%
WebInterface WI = new WebInterface(request);

///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
	boolean bolMyHome = false;	
	String strEmpID = null;
	if (WI.fillTextValue("my_home").equals("1")){
		strColorScheme = CommonUtil.getColorScheme(9);
		bolMyHome = true;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee Loans Reconciliation</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/formatFloat.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../../search/srch_emp.jsp?opner_info=form_.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ReloadPage()
{
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function focusID() {
  if(document.form_.my_home.value == "0")
	document.form_.emp_id.focus();
}

function CopyID(strID)
{
	document.form_.print_page.value="";
	document.form_.emp_id.value=strID;
	this.SubmitOnce("form_");

}

function clearFields(){
	document.form_.loan_amount.value="";
	document.form_.terms.value="";
	document.form_.monthly_amount.value="";
	document.form_.collection_period.value="";
	document.form_.start_date.value="";
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

-->
</script>
<%
	DBOperation dbOP = null;	
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
			
//add security here.
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./emp_loan_schedule_print.jsp"/>
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
	
	strEmpID = (String)request.getSession(false).getAttribute("userId");
	if (strEmpID != null ){
		if(bolMyHome){
			iAccessLevel  = 2;
			request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
		}
	}

	strEmpID = WI.fillTextValue("emp_id");
 	if(strEmpID.length() == 0)
		strEmpID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
	strEmpID = WI.getStrValue(strEmpID, "");
 	if (WI.fillTextValue("emp_id").length() == 0 && strEmpID.length() > 0){
		request.setAttribute("emp_id",strEmpID);
	}
	
	if (strEmpID == null) 
		strEmpID = "";

	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-LOANS-Reports-Employee Loans Reconciliation","emp_loan_schedule.jsp");
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
	Vector vRetResult = null;
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);

	String strRetLoanIndex = WI.fillTextValue("ret_loan_index");
	String strLoanName = null;
	double dPrincipal = 0d;
	double dInterest = 0d;
	double dActualPr = 0d;
	double dActualIn = 0d;
	int iSearchResult = 0;
	double dTemp = 0d;
	double dTemp2 = 0d;
	double dDiscrepancyPr = 0d;
	double dDiscrepancyIn = 0d;
	
	String strReadOnly = "";
	String strSchedBase = null;
	Vector vTemp = null;
	int i = 0;
	String[] astrTermUnit = {"Months","Years", "weeks"};
	String strEmpIndex = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
			
	payroll.PRConfidential prCon = new payroll.PRConfidential();
	boolean bolCheckAllowed = true;
	if(!WI.getStrValue(strSchCode).toUpperCase().startsWith("FADI"))
		bolCheckAllowed = (prCon.checkIfEmpIsProcessor(dbOP, request, WI.fillTextValue("emp_id"), true) == 1);
	 	
	if (WI.fillTextValue("emp_id").length() > 0 || (strEmpID != null && strEmpID.length() > 0)) {
		if(bolCheckAllowed){
			enrollment.Authentication authentication = new enrollment.Authentication();
			vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
			if (vPersonalDetails == null || vPersonalDetails.size()==0){
				strErrMsg = authentication.getErrMsg();
				vPersonalDetails = null;
			}else{
				strEmpIndex = (String)vPersonalDetails.elementAt(0);
			}
	
				vRetResult = PRRetLoan.generateEmployeeLoanRecon(dbOP, strRetLoanIndex);
				if(vRetResult != null){
					iSearchResult = PRRetLoan.getSearchCount();
					vTemp = (Vector) vRetResult.elementAt(0);
				}else{
					strErrMsg = PRRetLoan.getErrMsg();
				}
				if(vTemp != null && vTemp.size() > 0){
					strLoanName = (String)vTemp.elementAt(6);
				}
 		}else
			 strErrMsg = prCon.getErrMsg();		
	}
%>
<body bgcolor="#D2AE72" onLoad="focusID();" class="bgDynamic">
<form name="form_" method="post" action="emp_loan_schedule.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
      PAYROLL : LOANS RECONCILIATION PAGE ::::</strong></font></td>
    </tr>
  </table>
  <% if (vPersonalDetails != null && vPersonalDetails.size() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
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
	<%if(vTemp != null && vTemp.size() > 0){%>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="18%" height="26">&nbsp;Loan Code :</td>
      <td height="26" colspan="3"><strong>&nbsp;<%=(String)vTemp.elementAt(6)%></strong></td>
    </tr>
    <tr>
      <td height="17" colspan="5"><hr size="1"></td>
    </tr>

    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Amount Loaned </td>
      <td width="36%">&nbsp;<strong><%=(String)vTemp.elementAt(0)%></strong></td>
      <td width="15%" height="27">&nbsp;Terms</td>
      <td width="28%"><strong>&nbsp;<%=(String)vTemp.elementAt(1)%> 
        <%//=astrTermUnit[Integer.parseInt(WI.getStrValue((String)vTemp.elementAt(4),"0"))]%>
      </strong></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Release Date<strong> </strong></td>
      <td>&nbsp;<strong><%=WI.getStrValue((String)vTemp.elementAt(2),"")%></strong></td>
      <td height="27">&nbsp;First Payment</td>
      <td>&nbsp;<strong><%=(String)vTemp.elementAt(3)%></strong></td>
    </tr>
	<%}%>
    <tr>
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>
  <%if(vRetResult != null && vRetResult.size() > 0){%>  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr> 
      <td height="18" align="right"><font size="2">Number of Rows Per 
          Page :</font><font>
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 20; i <=40 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></td>
    </tr>
  </table> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#99CCFF">
      <td height="25" colspan="8" align="center" class="BorderAll"><strong>::
      LOANS RECONCILIATION FOR  <%=strLoanName%> ::</strong></td>
    </tr>
    <tr>
      <td width="2%" align="center" class="BorderBottomLeft">&nbsp;</td>
      <td width="14%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1">DATE DUE </font></strong></td>
      <td width="14%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1">PRINCIPAL AMOUNT</font></strong></td>
      <td width="14%" align="center" class="BorderBottomLeft"><strong><font size="1">ACTUAL </font></strong><strong><font size="1">PAYMENT</font></strong></td>
      <td width="14%" align="center" class="BorderBottomLeft"><strong>DISCREPANCY</strong></td>
      <td width="14%" align="center" class="BorderBottomLeft"><strong><font size="1">INTEREST  AMOUNT DUE </font></strong></td>
      <td width="14%" align="center" class="BorderBottomLeft"><strong><font size="1">ACTUAL INTEREST PAYMENT</font></strong></td>
      <td width="14%" align="center" class="BorderBottomLeft"><strong>DISCREPANCY</strong></td>
    </tr>
    <%
		int iIncr = 1;
 	for(i= 1; i < vRetResult.size() ; i+=15, iIncr++){%>
    <tr>
      <td class="BorderBottomLeft">&nbsp;<%=iIncr%></td>
      <td class="BorderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
	  <% dTemp = 0d;
		 dTemp2 = 0d;
	  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+2),"0");		
		strTemp = ConversionTable.replaceString(strTemp,",",""); 
	  	dTemp = Double.parseDouble(strTemp);
		dTemp2 = dTemp;
		dPrincipal += dTemp;
	  %>
      <td height="24" align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
      <% dTemp = 0d;
	  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4),"0");
		strTemp = ConversionTable.replaceString(strTemp,",",""); 
	  	dTemp = Double.parseDouble(strTemp);
		dTemp2 = dTemp2 - dTemp;
		dDiscrepancyPr += dTemp2;
		dActualPr += dTemp;
		strTemp2 = Double.toString(dTemp2);
		strTemp2 = ConversionTable.replaceString(strTemp2,"-",""); 
		if(dTemp2 < 0d)
			strTemp	= WI.getStrValue(strTemp2,"(",")","");
		strTemp2 = CommonUtil.formatFloat(strTemp2,true);
		strTemp = CommonUtil.formatFloat(dTemp,true);
		if(dTemp ==0d)
			strTemp = "";
		if(dTemp2 ==0d)
			strTemp2 = "";		
	  %>
      <td align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
      <td align="right" class="BorderBottomLeft"><%=strTemp2%>&nbsp;</td>
      <% dTemp = 0d;
		 dTemp2 = 0d;
	  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3),"0");		
		strTemp = ConversionTable.replaceString(strTemp,",",""); 
	  	dTemp = Double.parseDouble(strTemp);
		dTemp2 = dTemp;
		dInterest += dTemp;
	  %>
      <td align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
      <% dTemp = 0d;
	  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5),"0");		
		strTemp = ConversionTable.replaceString(strTemp,",",""); 
	  	dTemp = Double.parseDouble(strTemp);
		dTemp2 = dTemp2 - dTemp;
		dDiscrepancyIn += dTemp2;
		dActualIn += dTemp;
		strTemp2 = Double.toString(dTemp2);
		strTemp2 = ConversionTable.replaceString(strTemp2,"-",""); 
		if(dTemp2 < 0d)
			strTemp2	= WI.getStrValue(strTemp2,"(",")","");
		strTemp2 = CommonUtil.formatFloat(strTemp2,true);
		strTemp = CommonUtil.formatFloat(dTemp,true);
		if(dTemp == 0d)
			strTemp = "";
		if(dTemp2 == 0d)
			strTemp2 = "";
	  %>
      <td align="right" class="BorderBottomLeft"><%=strTemp%>&nbsp;</td>
      <td align="right" class="BorderBottomLeft"><%=strTemp2%>&nbsp;</td>
    </tr>
    <%}%>
    <tr>
      <td height="19" colspan="8"><hr size="1"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>TOTALS :</td>
      <td height="24" align="right"><%=CommonUtil.formatFloat(dPrincipal,true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dActualPr,true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dDiscrepancyPr,true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dInterest,true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dActualIn,true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dDiscrepancyIn,true)%>&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <%} // end if vRetResult != null %>
  <%}// largest if... (WI.fillTextValue("emp_id").length() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
	<input type="hidden" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>">
	<input type="hidden" name="ret_loan_index" value="<%=WI.fillTextValue("ret_loan_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
