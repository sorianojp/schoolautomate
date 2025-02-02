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
<title>Payroll Payslip - Cash Gift</title>
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

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_pg.value = "";
	document.form_.print_all.value ="";	
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_pg.value = "";
	document.form_.print_all.value ="";	
	this.SubmitOnce('form_');
}

function PrintSlip(emp_id, strBankAcct, strAmount, strGiftIndex)
{
	var pgLoc = "./cash_gift_pay_print.jsp?emp_id="+emp_id+"&bank_account="+strBankAcct+
							"&total_amount="+strAmount+"&gift_index="+strGiftIndex+
							"&year_of="+document.form_.year_of.value;
	var win=window.open(pgLoc,"PrintWindow",'width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrintALL() {
	document.form_.print_all.value ="1";
	document.form_.print_pg.value = "";
	this.SubmitOnce('form_');
}

function loadDept() {
		var objCOA=document.getElementById("load_dept");
 		var objCollegeInput = document.form_.c_index[document.form_.c_index.selectedIndex].value;
		
		this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		///if blur, i must find one result only,, if there is no result foud
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
}
</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn, payroll.PReDTRME" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	String strPayrollPeriod  = null;
	
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payslips-Cash Gift","cash_gift_pay.jsp");

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
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"cash_gift_pay.jsp");
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


String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};

PReDTRME prEdtrME = new PReDTRME();
EnrlReport.StatementOfAccount SOA = new EnrlReport.StatementOfAccount();

Vector vRetResult = null;
Vector vSalaryRange = null;
ReportPayrollExtn RptPayExtn = new ReportPayrollExtn(request);
int iItems = 0;

if(WI.fillTextValue("searchEmployee").equals("1") && WI.fillTextValue("reset_page").length() == 0){

  vRetResult = RptPayExtn.searchCashGiftPay(dbOP);
	if(vRetResult == null){
		strErrMsg = RptPayExtn.getErrMsg();
	}else{
		iSearchResult = RptPayExtn.getSearchCount();
	}
}

if(strErrMsg == null) 
strErrMsg = "";
%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="./cash_gift_pay.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
      PAYROLL : REPORTS : PAY SLIPS - CASH GIFT PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="1">&nbsp;<a href="./pay_slips_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="27"><strong><%=strErrMsg%></strong></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="21%"> Salary Month/Year :</td>
      <td width="76%"><select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select></td>
    </tr>
    
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td width="20%">Payroll Category :</td>
      <td width="77%"> 
	  <select name="employee_category" onChange="ReloadPage();">
		  <option value="">ALL</option>
          <%if (WI.fillTextValue("employee_category").equals("0")){%>
		  <option value="0" selected>Non-Teaching</option>
          <option value="1">Teaching</option>
          <%}else if (WI.fillTextValue("employee_category").equals("1")){%>
		  <option value="0">Non-Teaching</option>
          <option value="1" selected>Teaching</option>
          <%}else{%>
		  <option value="0">Non-Teaching</option>
          <option value="1">Teaching</option>		  
		  <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Payroll Status :</td>
      <td height="25"> 
	    <select name="pt_ft" onChange="ReloadPage();">
          <option value="" selected>All</option>
          <%if (WI.fillTextValue("pt_ft").equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
		  <option value="2">Contractual</option>
          <%}else if (WI.fillTextValue("pt_ft").equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
		  <option value="2">Contractual</option>
          <%}else if (WI.fillTextValue("pt_ft").equals("2")){%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
		  <option value="2" selected>Contractual</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
		  <option value="2">Contractual</option>
          <%}%>
        </select> </td>
    </tr>
    
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><strong><u>Print by :</u></strong></td>
      <td height="25">&nbsp;</td>
    </tr>
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td height="25"><select name="c_index" onChange="loadDept();">
          <option value="">ALL</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
        </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Office</td>
      <td height="26">
				<label id="load_dept">
				<select name="d_index">
          <option value="">ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select>
				</label>
			</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Employee ID </td>
      <td height="25"><input name="emp_id" type="text" size="16"maxlength="16" value="<%=WI.fillTextValue("emp_id")%>"></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">&nbsp;</td>
      <td height="26"><a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a><font size="1">click 
        to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td>&nbsp;</td>
      <td><div align="right"></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">Print Employee payroll whose lastname starts 
        with 
        <select name="lname_from" onChange="ReloadPage();">
          <%
	 strTemp = WI.fillTextValue("lname_from");
	 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
	 for(int i=0; i<28; ++i){
	 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
	 j = i; %>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
			}%>
        </select>
        to 
        <select name="lname_to">
          <option value="0"></option>
          <%
			 strTemp = WI.fillTextValue("lname_to");
			 
			 for(int i=++j; i<28; ++i){
			 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
		}%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp;</td>
    </tr>
	<% if(vRetResult != null && vRetResult.size() > 0) { %>
    <tr> 
      <td height="25">&nbsp;</td>
      <%if (vRetResult != null)
	  	  strTemp = Integer.toString(iSearchResult);
		else
		  strTemp = "";
	  %>	  
      <td height="25" colspan="2"><font size="3">TOTAL EMPLOYEES TO BE PRINTED 
        : <strong><%=WI.getStrValue(strTemp,"0")%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">PRINT OPTION 1 : </td>
      <td height="25"><select name="print_page_range">
          <option value="">ALL</option>
          <%
	  strTemp = WI.fillTextValue("print_page_range");
	  int iTemp = vRetResult.size()/11;
	  int iLastCount = 0;
	  for(int i = 1; i <= iTemp;){
	  	i += 25; //in batch of 25
		if(i > iTemp)
			iLastCount = iTemp;
		else	
			iLastCount += 25;
		 if(strTemp.compareTo(Integer.toString(iLastCount)) == 0){%>
          <option value="<%=iLastCount%>" selected><%=i - 25%> to <%=iLastCount%></option>
          <%}else{%>
          <option value="<%=iLastCount%>"><%=i - 25%> to <%=iLastCount%></option>
          <%}
	  }%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">PRINT OPTION 2 : <br> <font color="#0099FF">&nbsp; </font></td>
      <td height="25"><input name="print_option2" type="text" size="16" maxlength="32" 
	  value="<%=WI.fillTextValue("print_option2")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <font color="#0099FF" size="1"><strong><br>(Enter page numbers and/or page 
        ranges separated by commas. For ex: 1,3,5-12)</strong></font></td>
    </tr>
	<%}// end if(vRetResult != null && vRetResult.size() > 0) %>
  </table>
  <% if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="5" align="right"><a href="javascript:PrintALL();"> 
        <img src="../../../../images/print.gif" border="0"></a> <font size="1">Click 
        to print all</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">    	
    <tr bgcolor="#B9B292" class="thinborder"> 
      <td height="23" colspan="5" align="center"><b>LIST OF EMPLOYEES FOR PRINTING.</b></td>
    </tr>
    <tr bgcolor="#ffff99" class="thinborder"> 
      <td class="thinborder" height="25" colspan="2" align="center"><strong>EMPLOYEE 
        ID</strong></td>
      <td class="thinborder" width="29%" align="center"><strong>EMPLOYEE NAME</strong></td>
      <td class="thinborder" width="40%" align="center"><strong>DEPARTMENT/OFFICE</strong></td>
      <td class="thinborder" width="11%" align="center"><strong>PRINT</strong></td>
    </tr>
    <% 	//System.out.println("size " +vRetResult.size());
	for(int i = 0,iCount=1; i < vRetResult.size(); i +=10,++iCount){		
	%>
    <tr bgcolor="#FFFFFF" class="thinborder"> 
      <td class="thinborder" width="4%">&nbsp;<%=iCount%>.</td>
      <td class="thinborder" width="16%" height="30">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder" ><strong><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4)%></strong></td>
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>
      <td class="thinborder" >&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5)," ")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6)," ")%> 
      </td>
      <td class="thinborder" align="center">
	  <!--emp_id, strBankAcct, strAmount, strGiftIndex-->
	  <a href='javascript:PrintSlip("<%=(String)vRetResult.elementAt(i+1)%>",	  								
										"<%=(String)vRetResult.elementAt(i+8)%>",
										"<%=(String)vRetResult.elementAt(i+7)%>",
										"<%=(String)vRetResult.elementAt(i+9)%>")'>
	  								<img src="../../../../images/print.gif" border="0"></a> 
      </td>
    </tr>
    <%} // end for loop%>	
  </table>
  <%} // end if vRetResult != null && vRetResult.size() %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="reset_page">
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">
  <input type="hidden" name="print_all" value=""> 
</form>
<%
//if print all - i have to print all one by one.. 
if(WI.fillTextValue("print_all").compareTo("1") == 0 && vRetResult != null && vRetResult.size() > 0){
int iMaxPage = vRetResult.size()/10;
if(WI.fillTextValue("print_option2").length() > 0) {
//I have to now check if format entered is correct.
	int[] aiPrintPg = SOA.getPrintPage(WI.fillTextValue("print_option2"),iMaxPage);	
	if(aiPrintPg == null) {
		strErrMsg = SOA.getErrMsg();%> 
		<script language="JavaScript">alert("<%=strErrMsg%>");</script><%
	}
	else {//print here.
		
		int iCount = 0; %>
		<script language="JavaScript">
		var countInProgress = 0;
		<%
		for(int i = 0; i < aiPrintPg.length; ++i,++iCount) {%>
		
			function PRINT_<%=iCount%>() {
				var pgLoc = "./cash_gift_pay_print.jsp?emp_id=<%=(String)vRetResult.elementAt(aiPrintPg[i] * 10 - 9)%>" +
					"&bank_account=<%=(String)vRetResult.elementAt(aiPrintPg[i] * 10 - 2)%>" +					
					"&total_amount=<%=(String)vRetResult.elementAt(aiPrintPg[i] * 10 - 3)%>" + 
					"&gift_index=<%=(String)vRetResult.elementAt(aiPrintPg[i] * 10 - 1)%>" + 
					"&year_of="+document.form_.year_of.value;														
				window.open(pgLoc,"PrintWindow",'width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
			}
		<%}%>
		function callPrintFunction() {
			//alert(countInProgress);
			if(eval(countInProgress) > <%=iCount-1%>)
				return;
			eval('this.PRINT_'+countInProgress+'()');//alert(countInProgress);
			countInProgress = eval(countInProgress) + 1;//alert(printCountInProgress);
		
			window.setTimeout("callPrintFunction()", 6000);
		}
		this.callPrintFunction();
		</script>
	<%
	}
}
else {
	//enter this only if page number is selected. -- but call the above only if page range in enter in the input box.
	int iPrintRangeTo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("print_page_range"),"0"));
	int iPrintRangeFr = iPrintRangeTo - 25; if(iPrintRangeFr < 1) iPrintRangeFr = 0;
	if(iPrintRangeTo == iMaxPage && iMaxPage %25 > 0) {
		//i can't subtract just like that.. i have to find the last page count.
		iPrintRangeFr = iMaxPage - iMaxPage%25;	
	}
	%>
		<script language="JavaScript">
			var printCountInProgress = 0;
			var totalPrintCount = 0;
			<%int iCount = 0; 
			for(int i = 0; i < vRetResult.size(); i += 10,++iCount) {
				if(iPrintRangeTo > 0) {
					if( (iCount + 1) < iPrintRangeFr || (iCount + 1) > iPrintRangeTo)
						continue;				
				}%>
				
				function PRINT_<%=iCount%>() {
						var pgLoc = "./cash_gift_pay_print.jsp?emp_id=<%=(String)vRetResult.elementAt(i+1)%>" +					
					"&bank_account=<%=(String)vRetResult.elementAt(i + 8)%>" +					
					"&total_amount=<%=(String)vRetResult.elementAt(i + 7)%>" + 
					"&gift_index=<%=(String)vRetResult.elementAt(i + 9)%>" + 
					"&year_of="+document.form_.year_of.value;							
					window.open(pgLoc,"PrintWindow",'width=700,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
				}//end of printing function.
			<%
		}//end of for loop.
		
		//for(int i = 0;  i < vRetResult.size(); i += 2){
		%>totalPrintCount = <%=iCount%>;
		printCountInProgress = <%=iPrintRangeFr%>;
		<%if(iPrintRangeTo == 0)
			iPrintRangeTo = iCount;
		%>
		totalPrintCount = <%=iPrintRangeTo%>;
		function callPrintFunction() {
			//alert(printCountInProgress);
			if(eval(printCountInProgress) >= eval(totalPrintCount))
				return;
			eval('this.PRINT_'+printCountInProgress+'()');//alert(printCountInProgress);
			printCountInProgress = eval(printCountInProgress) + 1;//alert(printCountInProgress);
		
			window.setTimeout("callPrintFunction()", 6000);
		}
		//function PrintALL(strIndex) {
			//if(eval(strIndex) < eval(totalPrintCount))
		//}	
			this.callPrintFunction();
		</script>

<%}//end if print_option2 is not entered.
}//end if print is called.%>
</body>
</html>
<%
dbOP.cleanUP();
%>