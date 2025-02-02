<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayrollExtn" %>
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
<title>Quarterly Longevity</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.noBorder {
	font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }
</style>

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
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function CancelRecord(){
	location = "quarterly_longevity.jsp";	
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

function CancelSave(strIndex){
	document.form_.print_page.value="";
	document.form_.emplist_index.value = strIndex;
	document.form_.searchEmployee.value = "1";
	document.form_.page_action.value= "0";		
	this.SubmitOnce("form_");
}
function VerifyRecord(strIndex, strEmpIndex, strSalGrade){
	document.form_.print_page.value="";
	document.form_.emplist_index.value = strIndex;
	document.form_.emp_index.value=strEmpIndex;
	document.form_.sal_grade.value=strSalGrade;
	document.form_.searchEmployee.value = "1";
	document.form_.page_action.value= "5";		
	this.SubmitOnce("form_");
}
function SaveOne(strEmpIndex, strSalGrade){
	document.form_.searchEmployee.value = "1";
	document.form_.emp_index.value=strEmpIndex;
	document.form_.sal_grade.value=strSalGrade;
	document.form_.page_action.value= "1";		
	document.form_.print_page.value="";
	this.SubmitOnce("form_");

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
<body class="bgDynamic">
<form name="form_" 	method="post" action="quarterly_longevity.jsp">

<%  
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	int i = 0;

//add security here.
	if(WI.fillTextValue("print_page").length() > 0){%>
		<jsp:forward page="./quarterly_longevity_print.jsp" />
	<%return;}
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
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
								"Admin/staff-Payroll-Reports-Longevity Pay","quarterly_longevity.jsp");
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

	Vector vRetResult = null;
	ReportPayrollExtn RptPay = new ReportPayrollExtn(request);
	String strPageAction = WI.fillTextValue("page_action");
	String[] astrQuarterName = {"January - March", "April - June", "July - September", "October - December"};
	String[] astrMonth = {"January", "February", "March", "April", "May", "June", "July", 
						  "August", "September", "October", "November", "December"};
	String strQuarter = WI.fillTextValue("quarter");
	double dTotalAmt = 0d;
	double dTemp = 0d;
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
	  vRetResult = RptPay.getLongevityPay(dbOP);
		if(vRetResult == null)
		  strErrMsg = RptPay.getErrMsg();
		else
		  iSearchResult = RptPay.getSearchCount();
	}
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="3" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL : EMPLOYEES WITH LONGEVITY PAY FOR PERIOD ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="100%" height="23" colspan="3"><strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
  </table>  
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Quarter and Year </td>
	  <%
	  	strQuarter = WI.fillTextValue("quarter");
	  %>
      <td colspan="3">
	  <select name="quarter" onChange="ReloadPage()">
        <%for(i = 0; i < 4; i++){
		  	if(strQuarter.equals(Integer.toString(i))){
		%>
        <option value="<%=i%>" selected><%=astrQuarterName[i]%></option>
        <%}else{%>
        <option value="<%=i%>"><%=astrQuarterName[i]%></option>
        <%}%>
        <%}%>
      </select>
-
<select name="year_of">
  <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,2)%>
</select></td>
    </tr>    	
    
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td colspan="3"><select name="pt_ft" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if (WI.fillTextValue("pt_ft").equals("0")){%>
		  <option value="0" selected>Part - time</option>
          <option value="1">Full - time</option>
          <%}else if(WI.fillTextValue("pt_ft").equals("1")){%>
		  <option value="0">Part - time</option>
          <option value="1" selected>Full - time</option>
          <%}else{%>
		  <option value="0">Part - time</option>
          <option value="1">Full - time</option>
          <%}%>
        </select>	  </td>
    </tr>	
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3"> <select name="c_index" onChange="loadDept();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3"> 
				<label id="load_dept">
				<select name="d_index" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
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
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Personnel Division </td>
			<%
				strTemp = WI.fillTextValue("personnel_div");
			%>
      <td colspan="3"><input name="personnel_div" type="text"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=WI.getStrValue(strTemp,"")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Cash Division </td>
			<%
				strTemp = WI.fillTextValue("cash_div");
			%>
      <td colspan="3"><input name="cash_div" type="text"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=WI.getStrValue(strTemp,"")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>Executive Director </td>
			<%
				strTemp = WI.fillTextValue("director");
			%>
      <td colspan="3"><input name="director" type="text"  class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  value="<%=WI.getStrValue(strTemp,"")%>"></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%" colspan="3"><a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a><font size="1"> click 
        to display employee list to print.</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>  
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" align="center" bgcolor="#B9B292"><strong><font color="#FFFFFF">LIST 
        OF EMPLOYEES</font></strong></td>
    </tr>
    <tr>
      <td align="right"><font size="2"> Number of Employees Per Page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 5; i <=15 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}
			}%>
        </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> <font size="1">click to print</font></td>
    </tr>
	<%		
	int iPageCount = iSearchResult/RptPay.defSearchSize;		
	if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>		
    <tr> 
      <td align="right"><font size="2">Jump To page: 
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
          </select>
      </font></td>
    </tr>
	<%}%>	
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <td  width="12%" height="25" align="center" ><strong><font size="1">EMPLOYEE 
      ID</font></strong></td>
      <td width="28%" align="center"><strong><font size="1">NAME</font></strong></td>
      <td width="9%" align="center"><strong><font size="1">BASIC SALARY </font></strong></td>
      <td width="10%" align="center"><strong><font size="1">ETD</font></strong></td>
      <td width="9%" align="center"><strong><font size="1"><%=astrMonth[Integer.parseInt(strQuarter)*3]%></font></strong></td>
      <td width="9%" align="center"><strong><font size="1"><%=astrMonth[Integer.parseInt(strQuarter)*3 + 1]%></font></strong></td>
      <td width="10%" align="center"><strong><font size="1"><%=astrMonth[Integer.parseInt(strQuarter)*3 + 2]%></font></strong></td>
      <td width="13%" align="center"><strong><font size="1">TOTAL</font></strong></td>
      <!--
      <td width="10%"><div align="center"><strong><font size="1">SELECT ALL</font><br>
          <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
          </strong></div></td>
	-->
    </tr>
    <% int iCount = 0;
	   int iMax = 1;
	for(i = 0 ; i < vRetResult.size(); i +=14,iCount++,iMax++){
		dTotalAmt = 0d;
	%>
    <tr> 
      <td height="25">&nbsp;<font size="1"><%=(String)vRetResult.elementAt(i + 3)%></font></td>
      <td height="25"><font size="1">&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
							((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)%></font></td>
      <td align="right"><font size="1"><%=(String)vRetResult.elementAt(i + 10)%>&nbsp;</font></td>
      <td align="right"><font size="1"><%=(String)vRetResult.elementAt(i + 9)%>&nbsp;</font></td>
	 	<% dTemp = 0d;
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 11),"0");
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
			dTotalAmt += dTemp;
		%>	  
      <td align="right"><font size="1"><%=strTemp%>&nbsp;</font></td>
	 	<% dTemp = 0d;
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 12),"0");
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
			dTotalAmt += dTemp;
		%>	  	  
      <td align="right"><font size="1"><%=strTemp%>&nbsp;</font></td>
	 	<% dTemp = 0d;
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 13),"0");
			dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
			dTotalAmt += dTemp;
		%>	  	  
      <td align="right"><font size="1"><%=strTemp%>&nbsp;</font></td>
      <td align="right"><font size="1"><%=CommonUtil.formatFloat(dTotalAmt,true)%>&nbsp;</font></td>
    </tr>
    <%}//end of for loop to display employee information.%>
	<input type="hidden" name="max_display" value="<%=iMax%>">
  </table>  
  <%}%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="94%" height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#B8CDD1"> 
      <td height="25" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>  
  <input type="hidden" name="page_action">
  <input type="hidden" name="sal_grade">
  <input type="hidden" name="emp_index">
  <input type="hidden" name="emplist_index">
  <input type="hidden" name="searchEmployee">
  <input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>