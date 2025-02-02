<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.searchEmployee.value = "";
	document.form_.print_page.value="";
	this.SubmitOnce("form_");
}
function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}

</script>
<body>
<form name="form_" 	method="post" action="./payroll_masterlist_AUF.jsp">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	int i = 0;	
//add security here.


if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./payroll_masterlist_AUF_print.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-PayrollGroupSummary","payroll_masterlist_AUF.jsp");
								
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"Payroll","REPORTS",request.getRemoteAddr(),
														"payroll_masterlist_AUF.jsp");
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
	Vector vSalaryPeriod 		= null;//detail of salary period.
	Vector vSalPeriods = null;
	PReDTRME prEdtrME = new PReDTRME();
	
	Vector vRetResult = null;
	ReportPayroll RptPay = new ReportPayroll(request);
	String strPayrollPeriod  = null;
	String strSchCode = dbOP.getSchoolIndex();
	String strTemp2= null;
	double dSalary = 0d;
	double dDivider = 0d;
	double dTemp = 0d;
	
if(WI.fillTextValue("year_of").length() > 0){
  vSalaryPeriod = prEdtrME.operateOnSalaryPeriod(dbOP, request, 4);
}
if(WI.fillTextValue("searchEmployee").length() > 0) {	
	vSalPeriods = RptPay.getSalaryPeriod(dbOP);	
    vRetResult = RptPay.generateMasterlist(dbOP);
	  if(vRetResult == null){
	    strErrMsg = RptPay.getErrMsg();
  	  }else{
	    iSearchResult = RptPay.getSearchCount();
	  }
}

%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5"><div align="center"><font color="#000000" ><strong>:::: 
          PAYROLL: EMPLOYEE SALARY MASTER LIST  ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><strong><font color="#FF0000"><%=WI.getStrValue(strErrMsg,"")%></font></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td colspan="3"> <select name="month_of" onChange="document.form_.reset_page.value='1';ReloadPage()">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="document.form_.reset_page.value='1';ReloadPage()">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td width="16%">Salary Period</td>
      <td width="82%" colspan="3"><select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="document.form_.reset_page.value='1';ReloadPage();">
        <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");

		for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 8) {
		if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
			strTemp2 = "Whole Month";
		}else{
			strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
				(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		}
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		%>
        <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>		
        <%}else{%>
        <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"><%=strTemp2%></option>
        <%}//end of if condition.
		 }//end of for loop.%>
      </select></td>
    </tr>
	<tr>
	  <td height="24">&nbsp;</td>
	  <td>Salary Type</td>
	  <td colspan="3">
	  <%
		  strTemp = WI.fillTextValue("salary_period");
	  %>
	  <select name="salary_period">
        <option value="0">Daily</option>
        <%		
		if(strTemp.equals("1")){%>
        <option value="1" selected>Weekly</option>
        <%}else{%>
        <option value="1">Weekly</option>
        <%}if(strTemp.equals("2")) {%>
        <option value="2" selected>Bi-monthly</option>
        <%}else{%>
        <option value="2">Bi-monthly</option>
        <%}if(strTemp.equals("3")) {%>
        <option value="3" selected>Monthly</option>
        <%}else{%>
        <option value="3">Monthly</option>
        <%}%>
      </select>
	  </td>
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
        </select></td>
    </tr>	
    <% 
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
	<%if(bolIsSchool){%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3"><select name="employee_category" onChange="ReloadPage();">                    
          <option value="" selected>ALL</option>
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
        </select> </td>
    </tr>
	<%}%>
    
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3"> <select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3"> <select name="d_index" onChange="ReloadPage();">
          <option value="" selected>ALL</option>
          <%if ((strCollegeIndex.length() == 0)){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> </td>
    </tr>
    
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
    <tr> 
      <td width="3%" height="10">&nbsp;</td>
      <td width="16%" height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3"><input name="image" type="image" onClick="SearchEmployee()" src="../../../images/form_proceed.gif">      </td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
  </table>
  <% if (vRetResult != null && vRetResult.size() > 1 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18"><div align="right"><font size="2"> Number of Employees Per 
          Page :</font><font> 
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 5; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr>
    <%		
	int iPageCount = iSearchResult/RptPay.defSearchSize;		
	if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>	
    <tr> 
      <td><div align="right"><font size="2">Jump To page: 
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
          </font></div></td>
    </tr>
	<%}%>
  </table>
  <%if(strPayrollPeriod != null && strPayrollPeriod.length() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
    <tr> 
      <td height="24">&nbsp;</td>
      <td height="24">&nbsp;</td>
      <td height="24"><div align="center"><strong><font color="#0000FF">PAYROLL 
          DATE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></div></td>
      <td height="24">&nbsp;</td>
    </tr>
  </table>
  <%if(WI.fillTextValue("salary_period").equals("1")){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="4%" height="20" class="thinborder">&nbsp;</td>
      <td width="37%" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE NAME</strong></font></div></td>
      <td width="13%" class="thinborder"><div align="center"><font size="1"><strong>SALARY</strong></font></div></td>
	  <%if(vSalPeriods != null && vSalPeriods.size() > 0){
	  	for(int k = 0;k < vSalPeriods.size(); k+=2,dDivider++){
		strPayrollPeriod = (String)vSalPeriods.elementAt(k) +" - "+(String)vSalPeriods.elementAt(k+1);
	  %>
      <td class="thinborder"><div align="center"><%=strPayrollPeriod%></div></td>
	  <%}
	  }%>
    </tr>
    <% int iCount = 0;
	if (vRetResult != null && vRetResult.size() > 0){	  
	  for(i = 0,iCount=1; i < vRetResult.size(); i += 6,++iCount){%>
    <tr> 
      <td height="22" class="thinborder"><div align="right"><%=iCount%></div></td>
      <td class="thinborder"><div align="left"><font size="1"><strong>&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
							((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></strong></font></div></td>
      <%if (vRetResult != null && vRetResult.size() > 0){			
		  strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true);
		  dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""))/dDivider;
		}
	  %>
      <td class="thinborder"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;</font></div></td>
	  <%for(int j = 0;j < dDivider; j++){%>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</div></td>
	  <%}%>
    </tr>
    <% } // end for loop
	 }// end if%>
  </table>
  <%}else if(WI.fillTextValue("salary_period").equals("2")){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">

    <tr> 
      <td width="4%" class="thinborder">&nbsp;</td>
      <td width="41%" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE NAME</strong></font></div></td>
      <td width="17%" class="thinborder"><div align="center"><font size="1"><strong>SALARY</strong></font></div></td>
	  <%if(vSalPeriods != null && vSalPeriods.size() > 0){
	  	for(int k = 0;k < vSalPeriods.size(); k+=2,dDivider++){
		strPayrollPeriod = (String)vSalPeriods.elementAt(k) +" - "+(String)vSalPeriods.elementAt(k+1);
	  %>
      <td class="thinborder"><div align="center"><%=strPayrollPeriod%></div></td>
	  <%}
	  }%>
    </tr>
    <% int iCount = 0;
	if (vRetResult != null && vRetResult.size() > 0){	  
	  for(i = 0,iCount=1; i < vRetResult.size(); i += 6,++iCount){%>
    <tr> 
      <td height="22" class="thinborder"><div align="right"><%=iCount%></div></td>
      <td class="thinborder"><div align="left"><font size="1"><strong>&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
							((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></strong></font></div></td>
      <%if (vRetResult != null && vRetResult.size() > 0){			
		  strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true);			
		  dTemp = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""))/dDivider;
		}
	  %>
      <td class="thinborder"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
	  <%for(int j = 0;j < dDivider; j++){%>
      <td class="thinborder"><div align="right"><%=CommonUtil.formatFloat(dTemp,true)%>&nbsp;</div></td>
	  <%}%>
    </tr>
    <% } // end for loop
	 }// end if%>
  </table>
  <%}else{%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td width="4%" class="thinborder">&nbsp;</td>
      <td width="68%" class="thinborder"><div align="center"><font size="1"><strong>EMPLOYEE NAME</strong></font></div></td>
      <td width="28%" class="thinborder"><div align="center"><font size="1"><strong>SALARY</strong></font></div></td>
    </tr>
    <% int iCount = 0;
	if (vRetResult != null && vRetResult.size() > 0){	  
	  for(i = 0,iCount=1; i < vRetResult.size(); i += 6,++iCount){%>
    <tr> 
      <td height="22" class="thinborder"><div align="right"><%=iCount%></div></td>
      <td class="thinborder"><div align="left"><font size="1"><strong>&nbsp;<%=WI.formatName(((String)vRetResult.elementAt(i+1)).toUpperCase(), (String)vRetResult.elementAt(i+2),
							((String)vRetResult.elementAt(i+3)).toUpperCase(), 4)%></strong></font></div></td>
      <%if (vRetResult != null && vRetResult.size() > 0){			
		  strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i+4),true);			
		}
	  %>
      <td class="thinborder"><div align="right"><font size="1"><%=WI.getStrValue(strTemp,"")%>&nbsp;&nbsp;&nbsp;</font></div></td>
    </tr>
    <% } // end for loop
	 }// end if%>
  </table>
    <%}// end else%>
   <%} // end if strSalPeriod != null %>
  <%}%>
  
  <%if (vRetResult != null && vRetResult.size() > 1 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF"><div align="left"></div></td>
    </tr>
  </table>
  <%}%>  
  <input type="hidden" name="reset_page">
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>