<%@ page language="java" import="utility.*,java.lang.Integer, java.util.Vector,payroll.PayrollSheet, payroll.PReDTRME, eDTR.OverTime, eDTR.ReportEDTRExtn" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Control Total for Payroll</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
    table.TOPRIGHT {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }

    TD.headerBOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: 9px;
    }
    TD.headerBOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva, Helvetica, sans-serif;
		font-size: 9px;
    }		

		TD.BOTTOMLEFT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
		font-size: 9px;
    }
    TD.BOTTOMLEFTRIGHT {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Verdana, Arial,  Geneva,  Helvetica, sans-serif;
		font-size: 9px;
    }		
    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
		}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage()
{	
	document.form_.generate_report.value = "";
	this.SubmitOnce('form_');
}
function UpdateLabel(objTxtBox, strLabel) {
	document.getElementById(strLabel).innerHTML = objTxtBox.value;
}
function PrintPg(){
	
	var strPrepared = document.form_.prepared_by.value;
	var strReviewed = document.form_.reviewed_by.value;
	
	//check prepared by and verified by
	if(strPrepared.length == 0){
		alert("Please enter prepared by name.");
		return;		
	}
	if(strReviewed.length == 0 ){
		alert("Please enter verified by name.");
		return;		
	}
	
	document.bgColor = "#FFFFFF";	
	//delete table 1.
	document.getElementById('table1').deleteRow(0);
	
	var obj = document.getElementById('table2');
	var oRows = obj.getElementsByTagName('tr');
	var iRowCount = oRows.length;
	for(i = 0; i < iRowCount; ++i)
		obj.deleteRow(0);
	
	
	document.getElementById('table3').deleteRow(0)
	alert("Print this page?");
	window.print();
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
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=112&col_ref="+objCollegeInput+
								 "&sel_name=d_index&all=1";
		this.processRequest(strURL);
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

	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=301&month_of="+strMonth+
							 "&year_of="+strYear+"&is_weekly="+strWeekly+"&onchange=ReloadPage()";

	this.processRequest(strURL);
}

</script>

<%
	
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	String strTemp2  = null;

	int iSearchResult = 0;
	
//add security here.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Control Payroll","control_report.jsp");
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
														"control_report.jsp");
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
	String strPayrollPeriod = null;

	Vector vSalaryPeriod  = null;
	Vector vRetResult     = null;
	Vector vDedCols       = new Vector();
	Vector vEarnCols      = new Vector();
	
	Vector vShowDetailEarningFor = new Vector();
	Vector vShowDetailDedFor     = new Vector();
	
	String strNoOfEmployee       = null;

	///data here.
	//0. Basic Pay 1 = net salary, 2 = Overtime, 3 = Tax, 4 = sss, 5 = philhealth, 6 = pagibig, 7 = philhealth EC, 8 = pagibig EC, 9 = SSS EC,  
    Vector vData           = null;
	//[0] name of group, [1] amount
    Vector vEarningSummary = new Vector();
	//[0] name of group, [1] name of earning, [2] amount.
    Vector vEarningDetail  = new Vector();
	//[0] name of group, [1] amount
    Vector vDedSummary     = new Vector();
	//[0] name of group, [1] name of ded, [2] amount.
    Vector vDedDetail      = new Vector();
	
	
//end of authenticaion code.
	PayrollSheet RptPSheet = new PayrollSheet(request);
	PReDTRME prEdtrME      = new PReDTRME();
	payroll.ReportPayrollExtn repPayroll = new payroll.ReportPayrollExtn(request);
	
	
	String strSQLQuery = null;
	java.sql.ResultSet rs = null;

	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	///get the earning and ded columns.
	strSQLQuery = "select distinct group_name,is_deduction from pr_group_map where is_for_sheet = 1 order by is_deduction,group_name desc";
	rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next()) {
		if(rs.getInt(2) == 1)
			vDedCols.addElement(rs.getString(1));
		else	
			vEarnCols.addElement(rs.getString(1));
	}
	rs.close();
	
	
	if(WI.fillTextValue("generate_report").length() > 0 && WI.fillTextValue("sal_period_index").length() > 0) {
		vRetResult = repPayroll.getPayrollControlEAC(dbOP);
		if(vRetResult == null) 
			strErrMsg = repPayroll.getErrMsg();
		else {
			strNoOfEmployee = (String)vRetResult.remove(0);
			vData           = (Vector)vRetResult.remove(0);
			vEarningSummary = (Vector)vRetResult.remove(0);
			vEarningDetail  = (Vector)vRetResult.remove(0);
			vDedSummary     = (Vector)vRetResult.remove(0);
			vDedDetail      = (Vector)vRetResult.remove(0);
		}
	}

//I have to check if thre are details to be shown.
boolean bolShowDetails = false; //if true, show detail for that label.. 
int iIndexOf = 0;
for(int i = 0; i < 10; ++i) {
	if(WI.fillTextValue("group_earn_"+i).length() > 0) 
		vShowDetailEarningFor.addElement(WI.fillTextValue("group_earn_"+i));
	if(WI.fillTextValue("group_ded_"+i).length() > 0) 
		vShowDetailDedFor.addElement(WI.fillTextValue("group_ded_"+i));	
}	
%>
<body>
<form name="form_" 	method="post" action="control_report.jsp">
<table  id="table1" width="100%"> 
<tr><td>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr > 
      <td height="25" colspan="5" align="center"><font color="#000000" ><strong>:::: 
      PAYROLL: CONTROL TOTAL FOR PAYROLL ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><font size="2" color="#FF0000"><strong>&nbsp;<%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td height="22">&nbsp;</td>
      <td>Salary period for Yr</td>
      <td colspan="3"> <select name="month_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of" onChange="loadSalPeriods();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select></td>
    </tr>
    <tr> 
      <td width="16%" height="22">&nbsp;</td>
      <td width="18%">Salary Period</td>
      <td width="66%" colspan="3"><strong>
			<label id="sal_periods">
        <select name="sal_period_index" style="font-weight:bold;font-size:11px" onChange="ReloadPage();">
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
	
	<tr><td colspan="3"><hr size="1" color="#0000FF"></td></tr>
  </table> 
  
 </td></tr></table> <!-- end of table1 --> 
  
	<table width="54%" border="0"  align="center" cellspacing="0" cellpadding="0" id="table2">	 
	<%
		boolean bShowOtherEarnDetails = WI.fillTextValue("show_other_details").equals("1");
		if( bShowOtherEarnDetails )
			strTemp = " checkded";
		else
			strTemp = "";
	%>
		<tr>     
		  <td colspan="3"><input type="checkbox" name="show_other_details" value="1" <%=strTemp%>> 
		  Show Other Earnings details</td>	
		<tr>
<%if(vDedCols.size() > 0 || vEarnCols.size() > 0) {%>
		<tr>     
		  <td width="27%" height="25">&nbsp;Show Details for:</td>	
		  <td height="10"  align="left">&nbsp;&nbsp;<strong>EARNINGS</strong></td>
		  <td width="36%" height="10" colspan="3" align="left"><strong>DEDUCTIONS</strong></td>
	  	</tr>
	  	<tr>      
      		<td height="10" width="27%">&nbsp;</td>      
	 		<td width="34%"  valign="top" style="font-size:9px;"> 
			 <%
			 for(int i = 0; i < vEarnCols.size(); ++i) {
			 	if(WI.fillTextValue("group_earn_"+i).equals(vEarnCols.elementAt(i)))
					strTemp = " checked";
				else	
					strTemp = "";
			 	%>
				&nbsp;
				<input type="checkbox" name="group_earn_<%=i%>" value="<%=vEarnCols.elementAt(i)%>" <%=strTemp%> > <%=vEarnCols.elementAt(i)%><br />
			 
			<%}//end of loop%>			</td>
	<td height="10" colspan="3" valign="top" style="font-size:9px;">	
			 <%
			 for(int i = 0; i < vDedCols.size(); ++i) {
			 	if(WI.fillTextValue("group_ded_"+i).equals(vDedCols.elementAt(i)))
					strTemp = " checked";
				else	
					strTemp = "";
			 	%>
				&nbsp;
				<input type="checkbox" name="group_ded_<%=i%>" value="<%=vDedCols.elementAt(i)%>" <%=strTemp%> > <%=vDedCols.elementAt(i)%><br />
			 
			<%}//end of loop%>	 </td>
	</tr>
	<%		
	}//end of loop%>	  	
	<tr>
	  	  <td height="10">&nbsp;</td>
	  	  <td  valign="top" style="font-size:9px;">&nbsp;</td>
  	  </tr>
	  	<tr>
	  	  <td height="10">Prepared BY: </td>
	  	  <td>
		  <input type="text" name="prepared_by" maxlength="128" size="32" value="<%=WI.fillTextValue("prepared_by")%>" onKeyUp="UpdateLabel(document.form_.prepared_by,'prepared_by_label');">
		  </td>
	  	  <td>        
  	  </tr>
	  	<tr>
	  	  <td height="10">Reviewed BY: </td>
	  	  <td>
		  <input type="text" name="reviewed_by" maxlength="128" size="32" value="<%=WI.fillTextValue("reviewed_by")%>" onKeyUp="UpdateLabel(document.form_.reviewed_by,'reviewed_by_label');">
		  </td>
	  	  <td>        
  	  </tr>
	  	<tr>
	  	  <td height="10">&nbsp;</td>
	  	  <td  valign="top" style="font-size:9px;" align="center">&nbsp;</td>
	  	  <td>        
  	  </tr>
	  	<tr>
	  	  <td height="10">&nbsp;</td>
	  	  <td  valign="top" style="font-size:9px;" align="center">&nbsp;</td>
	  	  <td>        
  	  </tr>
	  	<tr>
	  	  <td height="10">&nbsp;</td>
	  	  <td  valign="top" style="font-size:9px;" align="center"><input type="button" name="proceed_btn" value=" Generate Report " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.generate_report.value='1';document.form_.submit();"></td>
  	  <td>  	  </tr>	
	</table>
	
	
<% 
double dTotAmt = 0d;
if(vData != null && vData.size() > 0){ %>
<table width="54%" border="0" align="center" cellpadding="5" cellspacing="0" id='table3'>
  <tr>		 
	  <td colspan="2" align="right">&nbsp;
		<a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font>		  </td>
  </tr>		  
</table>
	
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td align="center" colspan="2"><strong><font size="3"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong></td>	  
    </tr>  
	 <tr>
      <td align="center" colspan="2"><font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></td>	  
    </tr> 
    <tr>
      <td>&nbsp;</td>
	  <td align="right" style="font-size:9px;">&nbsp;Date and time printed : <%=WI.getTodaysDateTime()%></td>    
    </tr>
 </table>
	
	<table width="54%" border="0" align="center" cellpadding="5" cellspacing="0" >
	  <tr>	  
	  	<td width="62%" height="50">
			<div style=" margin-left: -5px; padding: 10px 0px 10px 5px;" >
			  <strong>CONTROL TOTAL FOR PAYROLL</strong><BR/>			  
			  	CUT-OFF :  <%=strPayrollPeriod%> <br/>
			</div>		</td>
		
		<td>&nbsp;</td>
	</table>
	<!-- Earning Block -- 1st Block -->
	<br>
	<table width="54%" border="0" align="center" cellspacing="0" class="thinborder">
	  <tr>	  
	  	<td width="62%" class="thinborder" height="22">BASIC PAY</td>	
		<td class="thinborder" align="right"><%=vData.elementAt(0)%></td>
	  </tr>
	  <tr>	  
	  	<td class="thinborder" height="22"> OVERTIME PAY</td>	
		<td class="thinborder" align="right"><%=vData.elementAt(2)%></td>
	  </tr>
	  <%//System.out.println(vEarningDetail);
	  	dTotAmt = Double.parseDouble(ConversionTable.replaceString((String)vData.elementAt(0), ",",""));
	  	dTotAmt += Double.parseDouble(ConversionTable.replaceString((String)vData.elementAt(2), ",",""));
		  for(int i = 0; i < vEarningSummary.size(); i += 2) {
			  dTotAmt += Double.parseDouble(ConversionTable.replaceString((String)vEarningSummary.elementAt(i + 1), ",",""));
			  iIndexOf = -1;bolShowDetails = false;
			  if(vEarningSummary.elementAt(i) == null) {
			  	if(WI.fillTextValue("show_other_details").length() > 0) {
					bolShowDetails = true;
					strTemp = null;//name of earning group.. 
				}
			  }
			  else{
			  	  iIndexOf = vShowDetailEarningFor.indexOf(vEarningSummary.elementAt(i));
				  if( iIndexOf > -1) {
				  	bolShowDetails = true;
					strTemp = (String)vShowDetailEarningFor.elementAt(iIndexOf);
				  }
				
			   }
			%>	
			  <tr>	  
				<td width="62%" class="thinborder" height="22"><%=WI.getStrValue(vEarningSummary.elementAt(i), "OTHERS")%></td>	
				<td class="thinborder" align="right"><%if(bolShowDetails) {%>&nbsp;<%}else{%><%=vEarningSummary.elementAt(i + 1)%><%}%></td>
			  </tr>
			  <%if(bolShowDetails) {
			  	for(int p = 0; p < vEarningDetail.size(); p += 3) {
					if(strTemp == null)  {
						if(vEarningDetail.elementAt(p) != null)
							continue;
					}
					else {
						if(!strTemp.equals((String)vEarningDetail.elementAt(p)))
							continue;
					}
					%>
					  <tr>	  
						<td width="62%" class="thinborder" height="22">&nbsp;&nbsp;<%=WI.getStrValue(vEarningDetail.elementAt(p + 1), "--").substring(1)%></td>	
						<td class="thinborder" align="right"><%=vEarningDetail.elementAt(p + 2)%></td>
					  </tr>
				<%}%>
			  <%}%>
		  
		  <%}%>
		  <tr>	  
	  	<td width="62%" class="thinborder" height="22"></td>	
		<td class="thinborder" align="right" style="font-weight:bold; font-size:11px;"><%=CommonUtil.formatFloat(dTotAmt, true)%></td>
	  </tr>
	</table>
	<!-- Deduction Block -- 2nd Block -->
	<br><br>
	<table width="54%" border="0" align="center" cellspacing="0" class="thinborder">
	  <tr>	  
	  	<td width="62%" class="thinborder" height="22">NET PAY</td>	
		<td class="thinborder" align="right"><%=vData.elementAt(1)%></td>
	  </tr>
	  <tr>	  
	  	<td class="thinborder" height="22">W/ TAX</td>	
		<td class="thinborder" align="right"><%=vData.elementAt(3)%></td>
	  </tr>
	  <tr>	  
	  	<td class="thinborder" height="22">PH PREMIUM - EMPLOYEE</td>	
		<td class="thinborder" align="right"><%=vData.elementAt(5)%></td>
	  </tr>
	  <tr>	  
	  	<td class="thinborder" height="22">PAGIBIG PREMIUM - EMPLOYEE</td>	
		<td class="thinborder" align="right"><%=vData.elementAt(6)%></td>
	  </tr>
	  <tr>	  
	  	<td class="thinborder" height="22">SSS PREMIUM - EMPLOYEE</td>	
		<td class="thinborder" align="right"><%=vData.elementAt(4)%></td>
	  </tr>
	  <%
	  	dTotAmt = Double.parseDouble(ConversionTable.replaceString((String)vData.elementAt(1), ",",""));
	  	dTotAmt += Double.parseDouble(ConversionTable.replaceString((String)vData.elementAt(3), ",",""));
	  	dTotAmt += Double.parseDouble(ConversionTable.replaceString((String)vData.elementAt(4), ",",""));
	  	dTotAmt += Double.parseDouble(ConversionTable.replaceString((String)vData.elementAt(5), ",",""));
	  	dTotAmt += Double.parseDouble(ConversionTable.replaceString((String)vData.elementAt(6), ",",""));
		  for(int i = 0; i < vDedSummary.size(); i += 2) {
		  	dTotAmt += Double.parseDouble(ConversionTable.replaceString((String)vDedSummary.elementAt(i + 1), ",",""));
			  //added to show details if selected.. 
			  iIndexOf = -1;bolShowDetails = false;
			  if(vDedSummary.elementAt(i) == null) {
			  	//will nto happen.. as ded does not come out if not mapped.. 
				continue;
			  	//if(WI.fillTextValue("show_other_details").length() > 0) {
				//	bolShowDetails = true;
				//	strTemp = null;//name of earning group.. 
				//}
			  }
			  else{
			  	  iIndexOf = vShowDetailDedFor.indexOf(vDedSummary.elementAt(i));
				  if( iIndexOf > -1) {
				  	bolShowDetails = true;
					strTemp = (String)vShowDetailDedFor.elementAt(iIndexOf);
				  }
				
			   }
		  %>
		  <tr>	  
			<td width="62%" class="thinborder" height="22"><%=WI.getStrValue(vDedSummary.elementAt(i), "OTHERS")%></td>	
			<td class="thinborder" align="right"><%if(bolShowDetails) {%>&nbsp;<%}else{%><%=vDedSummary.elementAt(i + 1)%><%}%></td>
		  </tr>
			  <%if(bolShowDetails) {
			  	for(int p = 0; p < vDedDetail.size(); p += 3) {
					if(strTemp == null)  {//will not happen.
						continue;
					}
					else {
						if(!strTemp.equals((String)vDedDetail.elementAt(p)))
							continue;
					}
					%>
					  <tr>	  
						<td width="62%" class="thinborder" height="22">&nbsp;&nbsp;<%=WI.getStrValue(vDedDetail.elementAt(p + 1), "--").substring(1)%></td>	
						<td class="thinborder" align="right"><%=vDedDetail.elementAt(p + 2)%></td>
					  </tr>
				<%}%>
			  <%}%>
		  <%}%>
		  <tr>	  
	  	<td width="62%" class="thinborder" height="22"></td>	
		<td class="thinborder" align="right" style="font-weight:bold; font-size:11px;"><%=CommonUtil.formatFloat(dTotAmt, true)%></td>
	  </tr>
	</table>

	<!-- Last Block --> 
	<br><br>
	<%
	  	dTotAmt = Double.parseDouble(ConversionTable.replaceString((String)vData.elementAt(7), ",",""));
	  	dTotAmt += Double.parseDouble(ConversionTable.replaceString((String)vData.elementAt(8), ",",""));
	  	dTotAmt += Double.parseDouble(ConversionTable.replaceString((String)vData.elementAt(9), ",",""));
	%>
	<table width="54%" border="0" align="center" cellspacing="0" class="thinborder">
	  <tr>	  
	  	<td width="62%" class="thinborder" height="22">PH PREMIUM - EMPLOYER</td>	
		<td class="thinborder" align="right"><%=vData.elementAt(7)%></td>
	  </tr>
	  <tr>	  
	  	<td class="thinborder" height="22">SSS EC - EMPLOYER</td>	
		<td class="thinborder" align="right"><%=vData.elementAt(9)%></td>
	  </tr>
	  <tr>	  
	  	<td class="thinborder" height="22">PAGIBIG PREMIUM - EMPLOYER</td>	
		<td class="thinborder" align="right"><%=vData.elementAt(8)%></td>
	  </tr>
	  <tr>	  
	  	<td width="62%" class="thinborder" height="22"></td>	
		<td class="thinborder" align="right" style="font-weight:bold; font-size:11px;"><%=CommonUtil.formatFloat(dTotAmt, true)%></td>
	  </tr>
	</table>
	<br><br>
	<table width="54%" border="0" align="center" cellspacing="0">
	  <tr>	  
	  	<td width="62%" height="22" style="font-weight:bold">NUMBER OF EMPLOYEES:</td>	
		<td align="right" style="font-weight:bold"><%=strNoOfEmployee%></td>
	  </tr>
	</table>
  	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr>
			<td width="18%">&nbsp;</td>
			<td width="42%">&nbsp;</td>
			<td width="40%">&nbsp;</td>
		</tr>
		<tr>
			<td width="18%">&nbsp;</td>
			<td width="42%">&nbsp;</td>
			<td width="40%">&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td>Prepared by: <strong><label id="prepared_by_label"><%=WI.fillTextValue("prepared_by")%></label></strong>
			</td>
			
			<td>Reviewed by: <strong><label id="reviewed_by_label"><%=WI.fillTextValue("reviewed_by")%></label></strong>
		  </td>
		</tr>
	</table>	

<%} //end of  if pheetdetails not null%>


<input type="hidden" name="generate_report">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>