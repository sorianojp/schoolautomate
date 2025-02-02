<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Sheet/Register - Part Time</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.print_pg.value="";
	this.SubmitOnce("form_");
}

function PrintPg(){
	document.form_.print_pg.value="1";
	this.SubmitOnce("form_");
}

function loadSalPeriods() {
	var strMonth = document.form_.month_of.value;
	var strYear = document.form_.year_of.value;
	var strWeekly = null;
	
	if(document.form_.is_weekly){
		if(document.form_.is_weekly.checked)
			strWeekly = "1";
		else
			strWeekly = "";
	}
	
	var objCOAInput = document.getElementById("sal_periods");
	
	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
		if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}

	var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly;

	this.processRequest(strURL);
}

</script>
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	
//add security here.


if (WI.fillTextValue("print_pg").length() > 0){ %>
	<jsp:forward page="./payroll_sheet_print_cgh_pt.jsp" />
<% return;}
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Sheet PT(CGH)","payroll_sheet_cgh_pt.jsp");
								
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
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"payroll_sheet_cgh_pt.jsp");
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
	PReDTRME prEdtrME = new PReDTRME();
	
	Vector vRetResult = null;
	ReportPayroll RptPay = new ReportPayroll(request);
	String strPayrollPeriod  = null;
	String strTemp2 = null;
	String strDeanName = null;
	
	double dTemp = 0d;
	double dTotalAmount = 0d;
	double dHonorarium = 0d;
	double dTotalTax = 0d;
	double dTotalNet = 0d;	
	double dTotalAdjust = 0d;
	double dRate = 0d;
	double dHoursWork = 0d;
		
	double dLineTotal = 0d;
	
	vRetResult = RptPay.generatePayrollSheetPT(dbOP);
		if(vRetResult == null)
			strErrMsg = RptPay.getErrMsg();
		else
			iSearchResult = RptPay.getSearchCount();

	if(WI.fillTextValue("c_index").length() > 0){
		strDeanName = dbOP.mapOneToOther("college","c_index",WI.fillTextValue("c_index"),"dean_name","");
	}

	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
%>
<body>
<form name="form_" 	method="post" action="./payroll_sheet_cgh_pt.jsp">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
        PAYROLL: PAYROLL SHEET PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><font size="1"><a href="./payroll_sheet_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td colspan="3">
	    <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select>
        (Must be filled up to display salary period information)</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%">Salary Period</td>
      <td width="82%" colspan="3"><strong>
			<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px">
          <%
		String[] astrConvertMonth = {"January","February","March","April","May","June","July","August",
									"September","October","November","December"};

	 	strTemp = WI.fillTextValue("sal_period_index");		
		
		for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
			if(((String)vSalaryPeriod.elementAt(i+3)).equals("5")){
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += "Whole Month";
			}else{
				strTemp2 = (String)vSalaryPeriod.elementAt(i+9) + " - ";
				strTemp2 += (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);			
//				strTemp2 = astrConvertMonth[Integer.parseInt((String)vSalaryPeriod.elementAt(i + 4))] + " :: "+
//					(String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
			}
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
		%>
          <option selected value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%> </option>
          <%}else{%>
          <option value="<%=(String)vSalaryPeriod.elementAt(i)%>"> <%=strTemp2%></option>
          <%}//end of if condition.		  
		 }//end of for loop.%>
        </select>
				</label>
      </strong></td>
    </tr>
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td>College</td>
      <td colspan="3"> 
	    <select name="c_index" onChange="document.form_.noted_by.value='';ReloadPage();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3"> 
	    <select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employment type</td>
      <td height="10" colspan="3">
			<select name="work_type" onChange="ReloadPage();">
				<option value="0">&nbsp;Normal</option>
        <%if(WI.fillTextValue("work_type").equals("1")){%>
				<option value="1" selected>&nbsp;Built In CI</option>
        <option value="2">&nbsp;Physician</option>				
				<%}else if(WI.fillTextValue("work_type").equals("2")){%>
        <option value="1">&nbsp;Built In CI</option>
				<option value="2"selected>&nbsp;Physician</option>				
        <%}else{%>
        <option value="1">&nbsp;Built In CI</option>
				<option value="2">&nbsp;Physician</option>				
        <%}%>
      </select></td>
    </tr>
    <tr> 
      <td height="10" colspan="5">&nbsp;</td>
    </tr>
  </table>  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="3%" height="29">&nbsp;</td>
      <td>SORT BY :</td>
      <td width="25%" height="29"><select name="sort_by1">
          <option value="">N/A</option>
          <%if(WI.fillTextValue("sort_by1").equals("ID_NUMBER"))		    
			{%>
          <option selected value="ID_NUMBER">Employee ID</option>
          <%}else{%>
          <option value="ID_NUMBER">Employee ID</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by1").equals("LNAME"))
		    {%>
          <option selected value="LNAME">Lastname</option>
          <%}else{%>
          <option value="LNAME">Lastname</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by1").equals("FNAME"))
		   {%>
          <option selected value="FNAME">Firstname</option>
          <%}else{%>
          <option value="FNAME">Firstname</option>
          <%}%>
        </select></td>
      <td width="29%" height="29"><select name="sort_by2">
          <option value="">N/A</option>
          <%if(WI.fillTextValue("sort_by2").equals("ID_NUMBER"))		    
			{%>
          <option selected value="ID_NUMBER">Employee ID</option>
          <%}else{%>
          <option value="ID_NUMBER">Employee ID</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by2").equals("LNAME"))
		    {%>
          <option selected value="LNAME">Lastname</option>
          <%}else{%>
          <option value="LNAME">Lastname</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by2").equals("FNAME"))
		   {%>
          <option selected value="FNAME">Firstname</option>
          <%}else{%>
          <option value="FNAME">Firstname</option>
          <%}%>
        </select></td>
      <td width="29%" height="29"><select name="sort_by3">
          <option value="">N/A</option>
          <%if(WI.fillTextValue("sort_by3").equals("ID_NUMBER"))		    
			{%>
          <option selected value="ID_NUMBER">Employee ID</option>
          <%}else{%>
          <option value="ID_NUMBER">Employee ID</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by3").equals("LNAME"))
		    {%>
          <option selected value="LNAME">Lastname</option>
          <%}else{%>
          <option value="LNAME">Lastname</option>
          <%}%>
          <%if(WI.fillTextValue("sort_by3").equals("FNAME"))
		   {%>
          <option selected value="FNAME">Firstname</option>
          <%}else{%>
          <option value="FNAME">Firstname</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="15">&nbsp;</td>
      <td width="14%" height="15">&nbsp;</td>
      <td><select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
	if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td><select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">
			<!--
			<input name="image" type="image" onClick="ReloadPage()" src="../../../../images/form_proceed.gif">
			-->
        <font size="1">
        <input type="button" name="12" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ReloadPage();">
        </font>        <font size="1">click to display employee list to print</font></td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Prepared By: </td>
			<%
				strTemp = WI.fillTextValue("prepared_by");
				if(strTemp.length() == 0)
					strTemp = CommonUtil.getNameForAMemberType(dbOP,"Payroll/HR Personnel",7);
				if( strTemp == null || strTemp.length() == 0)
					strTemp = (String)request.getSession(false).getAttribute("first_name");
			%>				
      <td height="10" colspan="3"><input type="text" name="prepared_by" maxlength="128" size="32" value="<%=WI.getStrValue(strTemp,"")%>"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Reviewed By: </td>
			<%
				strTemp = WI.fillTextValue("reviewed_by");
				if(strTemp.length() == 0)
					strTemp = CommonUtil.getNameForAMemberType(dbOP,"Assistant for Administrative Affairs",7);
				strTemp = WI.getStrValue(strTemp);
			%>				
      <td height="10" colspan="3"><input type="text" name="reviewed_by" maxlength="128" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10">Noted By </td>
			<%
				strTemp = WI.fillTextValue("noted_by");				
				if(strTemp.length() == 0)
					strTemp = strDeanName;
				strTemp = WI.getStrValue(strTemp);
			%>				
      <td height="10" colspan="3"><input type="text" name="noted_by" maxlength="128" size="32" value="<%=strTemp%>"></td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <% if (vRetResult != null && vRetResult.size() > 0){%>
      <td height="10" colspan="4"><div align="right"><a href="javascript:PrintPg()"><img src="../../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></div></td>
      <%}%>
    </tr>
  </table>
  <% if (vRetResult != null && vRetResult.size() > 0 ){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="42" colspan="23"> <%
		int iPageCount = iSearchResult/RptPay.defSearchSize;
		if(iSearchResult % RptPay.defSearchSize > 0) ++iPageCount;		
		if(iPageCount > 1)
		{%> <div align="right">Jump To page: 
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
			for( int i =1; i<= iPageCount; ++i ){
				if(i == Integer.parseInt(strTemp) ){%>
            <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
            <%
					}
			}%>
          </select>
          <%}%>
        </div></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="1" cellspacing="0" cellpadding="0">
    <tr> 
      <%

	 	strTemp = WI.fillTextValue("sal_period_index");		

		for(int i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 6) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
          strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
          }
		 }
		%>
      <td height="24" colspan="8" align="center"><strong><font color="#0000FF">PAYROLL 
          SHEET FOR SALARY SCHEDULE : <%=WI.getStrValue(strPayrollPeriod,"")%></font></strong></td>
    </tr>
    <tr> 
      <td width="21%" height="23" align="center">NAME OF EMPLOYEE </td>
      <td width="12%" align="center">RATE PER HOUR</td>
      <td width="13%" align="center">NO OF HOURS</td>
      <td width="13%" align="center">AMOUNT</td>
      <td width="14%" align="center">ADJUSTMENT</td>
			<%if(WI.fillTextValue("work_type").equals("2")){%>
      <td width="14%" align="center">HONORARIUM / INCENTIVES </td>
			<%}%>
      <td width="14%" align="center">W/TAX</td>
      <td width="13%" align="center">NET PAY</td>
    </tr>
    <% 
	if (vRetResult != null && vRetResult.size() > 0 ){
		//System.out.println("vRetResult " + vRetResult.size());
      for(int i = 0; i < vRetResult.size(); i += 12){
	  dLineTotal = 0d;
	%>
    <tr> 
      <td height="24"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4)%></font></td>
      <%dRate = 0d;
	    strTemp = "";
	  	if (vRetResult.elementAt(i+8) != null){	
			strTemp = (String) vRetResult.elementAt(i+8);
			strTemp = CommonUtil.formatFloat(strTemp,true);
			dRate = Double.parseDouble(ConversionTable.replaceString(strTemp,",",""));
		}
	  %>
      <td align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
	  <%
	  	dHoursWork = 0d;
	  if (vRetResult.elementAt(i+7) != null)
			strTemp = (String) vRetResult.elementAt(i+7); 
		else
			strTemp = "";
		strTemp = CommonUtil.formatFloat(strTemp,false);
		dHoursWork = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
	  %>
      <td align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
	  <%
		dLineTotal = dRate * dHoursWork;
		dTotalAmount += dLineTotal;
	  %>	  
      <td align="right"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
	  <%	  	
	  	if (vRetResult.elementAt(i+6) != null)
			strTemp = (String) vRetResult.elementAt(i+6); 
		else
			strTemp = "";
		strTemp = CommonUtil.formatFloat(strTemp,true);
		dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		dLineTotal += dTemp;
		dTotalAdjust +=dTemp;
	  %>
      <td align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
			
			<%if(WI.fillTextValue("work_type").equals("2")){%>
	    <%	  	
				// other incentives
				strTemp = (String) vRetResult.elementAt(i+10); 
				dTemp = Double.parseDouble(WI.getStrValue(strTemp,"0"));				
	
					// honorarium
				strTemp = (String) vRetResult.elementAt(i+11); 
				dTemp += Double.parseDouble(WI.getStrValue(strTemp,"0"));				
 				if(dTemp == 0d)
					strTemp = "";
				else
					strTemp = CommonUtil.formatFloat(dTemp,true);
	 			dLineTotal += dTemp;
 				dHonorarium += dTemp;				
			%>			
	    <td align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
			<%}%>
	    <%	  	
	  	if (vRetResult.elementAt(i+5) != null)
			strTemp = (String) vRetResult.elementAt(i+5); 
		else
			strTemp = "";
		strTemp = CommonUtil.formatFloat(strTemp,true);
		dTemp = Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTemp,"0"),",",""));
		dLineTotal -= dTemp;
		dTotalTax += dTemp;
	  %>
      <td align="right"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
	  <%
	  	dTotalNet += dLineTotal;
	  %>
      <td align="right"><%=CommonUtil.formatFloat(dLineTotal,true)%>&nbsp;</td>
    </tr>
    <%}//end for loop
	} // end if %>
    <tr> 
      <td height="26" align="right"><font size="1"><strong>TOTAL :   </strong></font></td>
      <td align="right">&nbsp;</td>
      <td align="right">&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dTotalAmount,true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dTotalAdjust,true)%>&nbsp;</td>
			<%if(WI.fillTextValue("work_type").equals("2")){%>
      <td align="right">&nbsp;</td>
			<%}%>
      <td align="right"><%=CommonUtil.formatFloat(dTotalTax,true)%>&nbsp;</td>
      <td align="right"><%=CommonUtil.formatFloat(dTotalNet,true)%>&nbsp;</td>
    </tr>
  </table>  
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_pg" value="">  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>