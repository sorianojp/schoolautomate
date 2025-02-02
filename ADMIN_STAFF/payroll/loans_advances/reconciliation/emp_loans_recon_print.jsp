<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRetirementLoan,payroll.PRMiscDeduction" %>
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
<title>print Employee Loans Reconciliation</title>
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

<script language="JavaScript">
<!--
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=form_.emp_id";
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

function clearFields(){
	document.form_.loan_amount.value="";
	document.form_.terms.value="";
	document.form_.monthly_amount.value="";
	document.form_.collection_period.value="";
	document.form_.start_date.value="";
}

-->
</script>
<body onLoad="javascript:window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolMyHome = false;	
	String strEmpID = null;
	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;
		
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
								"Admin/staff-RETIREMENT-ENCODE_LOADNS-Create Loans","emp_loans_recon.jsp");
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

	String strPageAction = WI.fillTextValue("page_action");
	String strLoanType = WI.fillTextValue("loan_type");
	String strCodeIndex = null;
	String strTypeName = null;
	String strLoanName = null;
	String strPrepareToEdit = "0";
	String strSalDateFr = null;
	double dPagePr = 0d;
	double dPageInt = 0d;
	double dPageAcPr = 0d;
	double dPageAcInt = 0d;
	double dPageDisPr = 0d;
	double dPageDisIn = 0d;
		
	double dPrincipal = 0d;
	double dInterest = 0d;
	double dActualPr = 0d;
	double dActualIn = 0d;
	double dDiscrepancyPr = 0d;
	double dDiscrepancyIn = 0d;

	int iSearchResult = 0;
	double dTemp = 0d;
	double dTemp2 = 0d;
	
	String strReadOnly = "";
	String strSchedBase = null;
	Vector vEmpList = null;
	Vector vTemp = null;	
	String[] astrTermUnit = {"Months","Years"};
	boolean bolPageBreak = false;
	
	if (WI.fillTextValue("emp_id").length() > 0) {
		enrollment.Authentication authentication = new enrollment.Authentication();
		vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");

		if (vPersonalDetails == null || vPersonalDetails.size()==0){
			strErrMsg = authentication.getErrMsg();
			vPersonalDetails = null;
		}

		//strLoanName = dbOP.mapOneToOther("ret_loan_code","code_index",WI.fillTextValue("code_index"),
		//								 "'(' + loan_code + ' :: ' + loan_name + ')' ","");

		//strLoanName = "select loan_code from ret_loan_code where is_valid = 1 " +
		//" and code_index = " + WI.fillTextValue("code_index");
		//strLoanName = dbOP.getResultOfAQuery(strLoanName, 0);
		//strLoanName = WI.getStrValue(strLoanName, "(",")","");
		strLoanName = WI.fillTextValue("loan_name");

		vRetResult = PRRetLoan.generateEmployeeLoanRecon(dbOP);		
		if(vRetResult != null && vRetResult.size() > 1){
		vTemp = (Vector) vRetResult.elementAt(0);			
		int i = 0; 
		int iPage = 1; 
		int iCount = 0;
		int iRowCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
			
		int iNumRec = 1;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iTotalPages = vRetResult.size()/(15*iMaxRecPerPage);	
	    if(vRetResult.size() % (15*iMaxRecPerPage) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
		dPagePr = 0d;
		dPageInt = 0d;
		dPageAcPr = 0d;
		dPageAcInt = 0d;
		dPageDisPr = 0d;
		dPageDisIn = 0d;	 
%>
<form name="form_">
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
	<%if(vTemp != null && vTemp.size() > 0){
	%>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;Employee Name</td>
      <td><strong>&nbsp;<%=WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4)%></strong></td>
      <td height="27">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="18%" height="27">&nbsp;Amount Loaned<font size="1"><strong> </strong></font></td>
      <td width="36%">&nbsp;<strong><%=(String)vTemp.elementAt(0)%></strong></td>
      <td width="15%" height="27">&nbsp;Terms<strong><font size="1"> </font></strong></td>
      <td width="28%">&nbsp;<strong><%=(String)vTemp.elementAt(1)%></strong> 
      <%//=astrTermUnit[Integer.parseInt(WI.getStrValue((String)vTemp.elementAt(4),"0"))]%></td>
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
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="8" align="center" class="BorderAll"><strong>::
      LOANS RECONCILIATION FOR  <%=strLoanName%> ::</strong></td>
    </tr>
    <tr>
      <td width="5%" class="BorderBottomLeft">&nbsp;</td>
      <td width="17%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1">DATE DUE </font></strong></td>
      <td width="13%" height="24" align="center" class="BorderBottomLeft"><strong><font size="1">PRINCIPAL AMOUNT</font></strong></td>
      <td width="13%" align="center" class="BorderBottomLeft"><strong><font size="1">ACTUAL </font></strong><strong><font size="1">PAYMENT</font></strong></td>
      <td width="13%" align="center" class="BorderBottomLeft"><strong>DISCREPANCY</strong></td>
      <td width="13%" align="center" class="BorderBottomLeft"><strong><font size="1">INTEREST  AMOUNT DUE </font></strong></td>
      <td width="13%" align="center" class="BorderBottomLeft"><strong><font size="1">ACTUAL INTEREST PAYMENT</font></strong></td>
      <td width="13%" align="center" class="BorderBottomLeftRight"><strong>DISCREPANCY</strong></td>
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=15,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>	
    <tr>
      <td align="center" class="BorderBottomLeft"><%=iIncr%>.&nbsp;</td>
      <td class="BorderBottomLeft">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
	  <% dTemp = 0d;
		 dTemp2 = 0d;
	  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+2),"0");		
		strTemp = ConversionTable.replaceString(strTemp,",",""); 
	  	dTemp = Double.parseDouble(strTemp);
		dTemp2 = dTemp;
		dPrincipal += dTemp;
		dPagePr += dTemp;
	  %>
      <td height="24" align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
	  <% dTemp = 0d;
	  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+4),"0");
		strTemp = ConversionTable.replaceString(strTemp,",",""); 
	  	dTemp = Double.parseDouble(strTemp);
		dTemp2 = dTemp2 - dTemp;
		dDiscrepancyPr += dTemp2;
		dPageDisPr += dTemp2;
		dActualPr += dTemp;				
		dPageAcPr += dTemp;
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
		dPageInt += dTemp;		
	  %>
      <td align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</td>
	  <% dTemp = 0d;
	  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5),"0");		
		strTemp = ConversionTable.replaceString(strTemp,",",""); 
	  	dTemp = Double.parseDouble(strTemp);
		dTemp2 = dTemp2 - dTemp;
		dDiscrepancyIn += dTemp2;
		dPageDisIn += dTemp2;		
		dActualIn += dTemp;
		dPageAcInt += dTemp;		
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
      <td align="right" class="BorderBottomLeftRight"><%=strTemp2%>&nbsp;</td>
    </tr>
    <%}%>    
    <tr>
      <td class="BorderBottomLeft">&nbsp;</td>
      <td class="BorderBottomLeft"><strong>PAGE TOTAL : </strong></td>
      <td height="24" align="right" class="BorderBottomLeft"><strong><%=CommonUtil.formatFloat(dPagePr,true)%>&nbsp;</strong></td>
      <td align="right" class="BorderBottomLeft"><strong><%=CommonUtil.formatFloat(dPageAcPr,true)%>&nbsp;</strong></td>
      <td align="right" class="BorderBottomLeft"><strong><%=CommonUtil.formatFloat(dPageDisPr,true)%>&nbsp;</strong></td>
      <td align="right" class="BorderBottomLeft"><strong><%=CommonUtil.formatFloat(dPageInt,true)%>&nbsp;</strong></td>
      <td align="right" class="BorderBottomLeft"><strong><%=CommonUtil.formatFloat(dPageAcInt,true)%>&nbsp;</strong></td>
      <td align="right" class="BorderBottomLeftRight"><strong><%=CommonUtil.formatFloat(dPageDisIn,true)%>&nbsp;</strong></td>
    </tr>	
    <%if (iNumRec >= vRetResult.size()){%>
    <tr>
      <td class="BorderBottomLeft">&nbsp;</td>
      <td class="BorderBottomLeft"><strong>GRAND TOTAL :</strong></td>
      <td height="24" align="right" class="BorderBottomLeft"><strong><%=CommonUtil.formatFloat(dPrincipal,true)%>&nbsp;</strong></td>
      <td align="right" class="BorderBottomLeft"><strong><%=CommonUtil.formatFloat(dActualPr,true)%>&nbsp;</strong></td>
      <td align="right" class="BorderBottomLeft"><strong><%=CommonUtil.formatFloat(dDiscrepancyPr,true)%>&nbsp;</strong></td>
      <td align="right" class="BorderBottomLeft"><strong><%=CommonUtil.formatFloat(dInterest,true)%>&nbsp;</strong></td>
      <td align="right" class="BorderBottomLeft"><strong><%=CommonUtil.formatFloat(dActualIn,true)%>&nbsp;</strong></td>
      <td align="right" class="BorderBottomLeftRight"><strong><%=CommonUtil.formatFloat(dDiscrepancyIn,true)%>&nbsp;</strong></td>
    </tr>
	<%}%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <%if (iNumRec < vRetResult.size()){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()
} // if (vRetResult != null)%>  
<%}// end if WI.fillTextValue("emp_id").length () > 0 %>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>