<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan,payroll.PRMiscDeduction" %>
<%
///added code for HR/companies.
WebInterface WI = new WebInterface(request);

boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
	boolean bolMyHome = false;	
	String strEmpID = null;
//add security here.
	if (WI.fillTextValue("my_home").equals("1")) {
		strColorScheme = CommonUtil.getColorScheme(9);
		bolMyHome = true;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>

<title>Employee Loans Summary</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.thinborderBOTTOMLEFT{
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOMLEFTRIGHT{
    border-left: solid 1px #000000;
	border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOM{
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
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
	document.form_.emp_id.focus();
}

function CopyID(strID)
{
	document.form_.print_page.value="";
	document.form_.emp_id.value=strID;
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

function viewLoanDetail(strRetLoanIndex) {
	var pgLoc = "../reconciliation/emp_loan_schedule.jsp?emp_id="+document.form_.emp_id.value+
							"&ret_loan_index="+strRetLoanIndex;
	var win=window.open(pgLoc,"loanDetail",'width=600,height=450,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

-->
</script>
<%
	DBOperation dbOP = null;	
	String strErrMsg = "";
	String strTemp = null;
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

if(strEmpID == null || strEmpID.length() == 0)
	strEmpID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strEmpID);
strEmpID = WI.getStrValue(strEmpID);

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
								"Admin/staff-Payroll-LOANS-Reports-Loans Summary","emp_loans_summary.jsp");
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
	Vector vEmpList = null;
	String[] astrLoanType = {"Retirement","Emergency","Institutional", "SSS","PAG-IBIG","PERAA","GSIS"};
	
	PRMiscDeduction prd = new PRMiscDeduction(request);
	PRRetirementLoan PRRetLoan = new PRRetirementLoan(request);
	payroll.PRConfidential prCon = new payroll.PRConfidential();
	boolean bolCheckAllowed = (prCon.checkIfEmpIsProcessor(dbOP, request, WI.fillTextValue("emp_id"), true) == 1);

	if(strEmpID.length() == 0)
		strEmpID = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	strEmpID = WI.getStrValue(strEmpID);
	
	
	if (WI.fillTextValue("emp_id").length() > 0 || strEmpID != null) {
		if(bolCheckAllowed || bolMyHome){
			enrollment.Authentication authentication = new enrollment.Authentication();
			vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
			
			if (vPersonalDetails == null || vPersonalDetails.size()==0){
				strErrMsg = authentication.getErrMsg();
				vPersonalDetails = null;
			}
			vEmpList = prd.getEmployeesList(dbOP);
			
			vRetResult = PRRetLoan.getEmpLoanSummary(dbOP);
			if(vRetResult == null)
				strErrMsg = PRRetLoan.getErrMsg();
		}else
	   strErrMsg = prCon.getErrMsg();
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic" >
<form name="form_" method="post" action="./emp_loans_summary.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="2" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
      PAYROLL : LOANS : EMPLOYEE LOANS SUMMARY PAGE ::::</strong></font></td>
    </tr>
    <%if(!bolMyHome){%>
    <tr bgcolor="#FFFFFF">
      <td width="54%" height="25">&nbsp;</td>
      <td width="46%" align="right"><%
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
	<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
	<tr>
      <td height="27" colspan="3"><font size="1"><%if(!bolMyHome){%><a href="../loans_report_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a><%}%>&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></font></td>
    </tr>
	<%if(!bolMyHome){%>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="21%" height="27"><br>
        Employee ID :</td>
      <td width="76%" height="27"><font size="1">
        <input name="emp_id" type="text" class="textbox" onKeyUp="AjaxMapName(1);"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("emp_id")%>" size="16">
        <strong><a href="javascript:OpenSearch();"><img src="../../../../images/search.gif" width="37" height="30" border="0"></a></strong> <a href="javascript:ReloadPage()"></a>
        <input type="submit" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;">
      </font><label id="coa_info"></label></td>
    </tr>
    <tr>
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
	<%}else{// not my Home%>
	<!--
	<input name="emp_id" type="hidden" value="<%=strEmpID%>">
	-->
	<%}%>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0 && vPersonalDetails != null && vPersonalDetails.size() > 0){ %>
  <table width="100%" height="154" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="3%" height="29">&nbsp;</td>
      <td height="29">Employee Name : <strong><%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong>
      </td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td height="29">Employee ID : <strong><%=WI.fillTextValue("emp_id")%></strong></td>
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
      <td height="29">
        <%if(bolIsSchool){%>College<%}else{%>Division<%}%>/Office : <strong><%=strTemp%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td>Employment Type/Position : <strong><%=(String)vPersonalDetails.elementAt(15)%></strong></td>
    </tr>
    <tr>
      <td height="29">&nbsp;</td>
      <td width="97%">Employment Status<strong> : <%=(String)vPersonalDetails.elementAt(16)%>
        </strong></td>
    </tr>
    <tr>
      <td height="2" colspan="2"><hr size="1"></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="14" colspan="9" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
    <tr>
      <td width="14%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">LOAN TYPE </font></strong></td> 
      <td width="13%" height="25" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">LOAN 
      CODE </font></strong></td>
      <td width="15%" height="25" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">STATUS</font></strong></td>
      <td width="11%" align="center" class="thinborderBOTTOMLEFT"><strong><font size="1">AMOUNT 
      LOANED</font></strong></td>
      <td width="11%" height="25" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>DATE 
      GIVEN </strong></font></td>
      <td width="11%" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>PRINCIPAL AMOUNT </strong></font></td>
      <td width="10%" align="center" class="thinborderBOTTOMLEFT"><font size="1"><strong>INTEREST</strong></font></td>
      <td width="12%" align="center" class="thinborderBOTTOMLEFTRIGHT"><font size="1"><strong>REFERENCE </strong></font></td>
      <td width="3%" align="center" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
    	
	<%for(int i = 0;i < vRetResult.size();i+=15){%>
    <tr>
      <td height="20" class="thinborderBOTTOMLEFT">&nbsp;<%=astrLoanType[Integer.parseInt((String)vRetResult.elementAt(i+7))]%></td> 
      <td class="thinborderBOTTOMLEFT">&nbsp;<%=(String)vRetResult.elementAt(i+5)%></td>
	  <%
	  	if(((String)vRetResult.elementAt(i+4)).equals("1")){
	  		strTemp = "Fully paid ";	
		}else{
			strTemp = "On going payment ";	
		}
	  %>
      <td class="thinborderBOTTOMLEFT">&nbsp;<%=strTemp%></td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+1),true)%>&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%>&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+8),true)%>&nbsp;</td>
      <td align="right" class="thinborderBOTTOMLEFT"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+9),true)%>&nbsp;</td>
      <td class="thinborderBOTTOMLEFTRIGHT"><span class="thinborderBOTTOMLEFT"><%=WI.getStrValue((String)vRetResult.elementAt(i+10),"&nbsp;")%></span></td>
      <td class="thinborderBOTTOMLEFTRIGHT"><a href="javascript:viewLoanDetail('<%=vRetResult.elementAt(i)%>');">VIEW</a></td>
    </tr>
	<%}%>
  </table>
  <%}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <!--
	<tr>
      <td height="25" bgcolor="#D3D6A9"><input type="checkbox" name="checkbox" value="checkbox">
        Display Summary of Payments &nbsp; &nbsp; &nbsp; 
        <input type="checkbox" name="checkbox2" value="checkbox">
        List of Payments </td>
    </tr>
    <tr> 
      <td height="25"><div align="left">(NOTE: make the loan code clickable. If 
          Display Summary.. is tick then loan code is click show Summary of Payments. 
          Show list of payments if this is the one ticked.)</div></td>
    </tr>
	-->
	
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  
  <input type="hidden" name="print_page">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>