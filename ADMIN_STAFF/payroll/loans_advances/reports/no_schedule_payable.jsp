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
<title>No Schedule with payable balance</title>
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

function ReloadPage(){
	document.form_.print_page.value="";
	document.form_.proceed.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function checkAllSave() {
	var maxDisp = document.form_.emp_count.value;
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

function SaveData() {
	document.form_.print_page.value = "";
	document.form_.proceed.value = "1";
	document.form_.save.disabled = true;
	document.form_.save_record.value = "1";
	//document.form_.hide_save.src = "../../../../images/blank.gif";
	document.form_.submit();
	//this.SubmitOnce('form_');
}

function SearchEmployee(){
	document.form_.proceed.value = "1";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function CopyAll(){
	var vItems = document.form_.emp_count.value;
	if (vItems.length == 0)
		return;	
		
	for (var i = 1 ; i < eval(vItems);++i)
		eval('document.form_.penalty_'+i+'.value=document.form_.penalty_1.value');			

}

-->
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./no_schedule_payable_print.jsp" />
<% return;}

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("RETIREMENT"),"0"));
		}

		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-LOANS/ADVANCES"),"0"));
			if(iAccessLevel == 0) {
				iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
			}						
		}		
	}
	
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
								"Admin/staff-Payroll-LOANS-Reports-Loan With Balance No Schedule","no_schedule_payable.jsp");
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
	String strLoanType = null;
	String strCodeIndex = null;
	String[] astrLoanType = {"Regular Retirement Loan","Emergency Loan","Institutional/Company Loan", "SSS Loan", "PAG-IBIG Loan", 
							"PERAA Loan","GSIS Loan"};
	String strTypeName = null;	
	
	String[] astrSortByName    = {"Lastname","Loan Name"};
	String[] astrSortByVal     = {"lname","loan_name"};
	
	int iSearchResult = 0;
	int i = 0;
	int iDefault = 0;
	double dTotalLoan = 0d;
	double dTotalPaid = 0d;
	double dPayable = 0d;
	double dTemp = 0d;
	String strLoanOption = WI.getStrValue(WI.fillTextValue("loan_option"),"0");
	
	if (WI.fillTextValue("save_record").length() > 0) {
		if(strLoanOption.equals("0"))	{
			if(PRRetLoan.operateOnNoSchedPayable(dbOP,request, 1) == null)
				strErrMsg = PRRetLoan.getErrMsg();
		}else{
			if(!PRRetLoan.extendLoanSechedule(dbOP))
				strErrMsg = PRRetLoan.getErrMsg();
		}
	}
	
	if (WI.fillTextValue("proceed").length() > 0) {		
		vRetResult = PRRetLoan.operateOnNoSchedPayable(dbOP,request, 4);
		if(vRetResult == null)
			strErrMsg = PRRetLoan.getErrMsg();		
		else
			iSearchResult = PRRetLoan.getSearchCount();		
	}
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form name="form_" method="post" action="no_schedule_payable.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: LOANS W/BALANCES NO SCHEDULE PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25"><font size="3">&nbsp;<strong><font size="1"><a href="../loans_report_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a>&nbsp;&nbsp;&nbsp;</font><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <tr>
      <td width="3%">&nbsp;</td>
      <td width="12%" height="27">Loan Type : </td>
      <%
	  	strLoanType = WI.fillTextValue("loan_type");
	  %>	  
      <td width="85%" height="27">
	  <select name="loan_type" onChange="ReloadPage();">	  	
		<option value="" selected>ALL</option>
		<%for(i = 2; i < 7; i++){%>        
        <%if(strLoanType.equals(Integer.toString(i))){
		strTypeName = astrLoanType[i];
		%>
        <option value="<%=i%>" selected><%=astrLoanType[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrLoanType[i]%></option>
        <%}%>
		<%}// end for loop%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">Loan Name </td>
	  <%
	  	strCodeIndex = WI.fillTextValue("code_index");
	  %>
      <td height="27">
	    <select name="code_index" onChange="ReloadPage();">
          <option value="">All</option>
          <%=dbOP.loadCombo("code_index","loan_name, loan_code ",
		                    " from ret_loan_code where is_valid = 1 and loan_type = " + WI.getStrValue(strLoanType,"2"),
							strCodeIndex ,false)%>
        </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="18">Option:</td>
      <td height="18"><select name="loan_option" onChange="ReloadPage();">
        <option value="0">Forward Loan as miscellaneous deduction</option>
        <%if(WI.fillTextValue("loan_option").equals("1")){%>
        <option value="1" selected>Extend loan by creating additional schedule</option>
        <%}else{%>
        <option value="1">Extend loan by creating additional schedule</option>
        <%}%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18"><%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">
View ALL </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="18">Sort by: </td>
      <td height="18"><select name="sort_by1">
        <option value="">N/A</option>
        <%=PRRetLoan.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%>
      </select></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="27">&nbsp;</td>
      <td height="27"><select name="sort_by1_con">
        <option value="asc">Ascending</option>
        <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
        <option value="desc" selected>Descending</option>
        <%}else{%>
        <option value="desc">Descending</option>
        <%}%>
      </select></td>
    </tr>
    
    <tr>
      <td>&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27">&nbsp;</td>
      <td height="27">
			<!--
			<a href="javascript:ReloadPage()"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to list loan balances</font>			</td>
    </tr>
    <tr> 
      <td height="10" colspan="3"><hr size="1"></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="3%">&nbsp;</td>
      <td width="97%" height="27">EMPLOYEES WITH OUTSTANDING <%=WI.getStrValue(strTypeName," ").toUpperCase()%> BALANCES AND NO SCHEDULE </td>
    </tr>
    <tr> 
      <td>&nbsp;</td>
      <td height="27"> AS OF <%=WI.getTodaysDate(1)%></td>
    </tr>
    <tr> 
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="9"><div align="right">Number of records per page 
          <select name="num_rows">
            <% iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rows"),"20"));
				for(i = 5; i <=30 ; i++) {
					if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg();"> <img src="../../../../images/print.gif" border="0"></a> 
          <font size="1">click to print list</font></div></td>
    </tr>
    <%		
		if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/PRRetLoan.defSearchSize;		
	if(iSearchResult % PRRetLoan.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr> 
      <td height="25" colspan="9" align="right">Jump To page: 
          <select name="jumpto" onChange="SearchEmployee();">
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
          </select>        </td>
    </tr>
    <%}
		}// if (view_all).length == 0%>
    <tr>
      <td height="15" colspan="9" class="BorderBottom">&nbsp;</td>
    </tr>
    <tr> 
      <td width="5%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">COUNT</font></strong></td>
      <td width="40%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">EMPLOYEE 
      NAME </font></strong></td>
      <td width="17%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN NAME </font></strong></td>
      <td width="10%" height="25" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL 
      LOAN </font></strong></td>
      <td width="11%" align="center" class="BorderBottomLeft"><strong><font size="1">TOTAL PAYMENT</font></strong></td>
      <td width="10%" align="center" class="BorderBottomLeft"><strong><font size="1">LOAN BALANCE</font></strong></td>
      <%if(strLoanOption.equals("1")){%>
			<td width="10%" align="center" class="BorderBottomLeft"><strong><font size="1"> MONTHLY AMT </font></strong></td>
			<td width="10%" align="center" class="BorderBottomLeft"><strong><font size="1">PENALTY AMOUNT </font></strong><br>
        <strong><font size="1"><a href="javascript:CopyAll();">Copy all</a></font></strong></td>
			<%}%>
      <td width="7%" align="center" class="BorderBottomLeftRight"><font size="1"><strong>SELECT ALL<br>
      </strong>
          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" checked>
      </font></td>
    </tr>
    <%
	int iCount = 1;
	for(i = 0; i < vRetResult.size(); i+=20,iCount++){
	%>
    <tr> 
		<input type="hidden" name="user_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+8)%>">
		<input type="hidden" name="loan_name_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+7)%>">
		<input type="hidden" name="code_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+9)%>">
		<input type="hidden" name="amount_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+6)%>">		
		<input type="hidden" name="ret_loan_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">		
      <td height="24" align="right" class="BorderBottomLeft"><%=iCount%>&nbsp;</td>
      <td height="24" class="BorderBottomLeft"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2),
							(String)vRetResult.elementAt(i+3), 4)%></strong></font></td>
      <td class="BorderBottomLeft">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+7),"&nbsp;")%></td>
      <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+5),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTotalLoan += Double.parseDouble(strTemp);
	%>							
      <td height="24" align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>
      <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dTemp = Double.parseDouble(strTemp);
		if(dTemp > 0d)
			dTotalPaid += dTemp;
		else
			strTemp = "&nbsp;";
	%>      
	    <td align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>
	    <%	
		strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+6),true);
		strTemp = ConversionTable.replaceString(strTemp,",","");		
		dPayable += Double.parseDouble(strTemp);
	%>      
	    <td align="right" class="BorderBottomLeft">&nbsp;<%=strTemp%>&nbsp;</td>
			<%if(strLoanOption.equals("1")){%>
	    <%	
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+11),true);
				strTemp = ConversionTable.replaceString(strTemp,",","");		
			%>      
			<td align="center" class="BorderBottomLeft"><strong><%=strTemp%>
			  <!--
				<input name="monthly_amt_<%=iCount%>2" type="text" class="textbox" size="7" maxlength="8"  value="<%=strTemp%>"
	      onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
				style="text-align:right; font-size:9px;" >
				-->
			</strong></td>
      <td align="center" class="BorderBottomLeft"><strong>
        <input name="penalty_<%=iCount%>" type="text" class="textbox" size="7" maxlength="8" 
	      onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;"
				style="text-align:right; font-size:9px;" >
      </strong></td>
			<%}%>
      <td align="center" class="BorderBottomLeftRight"><span class="thinborder">
        <input type="checkbox" name="save_<%=iCount%>" value="1" checked tabindex="-1">
      </span></td>
    </tr>
    <%}%>
		<input type="hidden" name="emp_count" value="<%=iCount%>">
    <tr> 
      <td height="24" colspan="2" align="right" class="BorderBottomLeft">TOTAL :&nbsp;&nbsp;&nbsp;</td>
      <td class="BorderBottomLeft">&nbsp;</td>
      <td height="24" align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTotalLoan,true)%>&nbsp;</td>
      <td align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dTotalPaid,true)%>&nbsp;</td>
      <td align="right" class="BorderBottomLeft"><%=CommonUtil.formatFloat(dPayable,true)%>&nbsp;</td>
      <%if(strLoanOption.equals("1")){%>
			<td align="right" class="BorderBottomLeft">&nbsp;</td>
			<td align="right" class="BorderBottomLeft">&nbsp;</td>
			<%}%>
      <td align="right" class="BorderBottomLeftRight">&nbsp;</td>
    </tr>
  </table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td align="center">&nbsp;</td>
    </tr>
    <tr>
			<%
			if(strLoanOption.equals("0"))
				strTemp = "Click to forward selected loans as misc deduction";
			else
				strTemp = "Click to extend loan schedule";
			%>
			
     <td align="center"><input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:SaveData();">		 
      <font size="1"><%=strTemp%></font></td>
   </tr>
	</table>
  <%}%>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="proceed">
	<input type="hidden" name="save_record">	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>