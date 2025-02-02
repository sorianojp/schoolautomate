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
<title>Tax Withheld</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

TD.thinborderBOTTOMLEFTx {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

TD.thinborderBOTTOMLEFTRIGHTx {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderBOTTOM {
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
TD.thinborderTOPBOTTOM {
	border-bottom: solid 1px #000000;
	border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript">

function ReloadPage()
{	
	document.form_.searchEmployee.value = "";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}

function SearchEmployee()
{
	document.form_.searchEmployee.value = "1";
	document.form_.print_page.value = "";
	this.SubmitOnce('form_');
}


function PrintPg() {
	document.form_.print_page.value = "1";
	this.SubmitOnce('form_');
}

</script>

<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance" %>

<body  class="bgDynamic">
<form name="form_" method="post" action="./tax_compensation_monthly.jsp">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	boolean bolHasTeam = false;

//add security here.
if (WI.fillTextValue("print_page").length() > 0){ %>
	<jsp:forward page="./tax_compensation_print2.jsp" />
<% return;}

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-Remittances-Tax Compensation","tax_compensation_monthly.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
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
														"tax_compensation_monthly.jsp");
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

//end of authenticaion code.

Vector vRetResult = null;
PRRemittance PRRemit = new PRRemittance(request);
boolean bolNextEmp = false;
int iMonthOf = 0;

String[] astrMonth = {"January","February","March","April","May","June","July",
					  "August", "September","October","November","December"};
					  
int i = 0;
String strMonth = null;
String strYear = WI.fillTextValue("year_of");
boolean bolIncremented = false;
double dRowTotal = 0d;

if(WI.fillTextValue("searchEmployee").equals("1")){
  vRetResult = PRRemit.getWithholdingTaxCompensationMonthly(dbOP);
	if(vRetResult == null){
		strErrMsg = PRRemit.getErrMsg();
	}else{	
		iSearchResult = PRRemit.getSearchCount();
	}
}

if(WI.fillTextValue("month_of").length() > 0){
	iMonthOf = Integer.parseInt(WI.fillTextValue("month_of")) + 1;
	strMonth = Integer.toString(iMonthOf);
}

if(strErrMsg == null) 
strErrMsg = "";
%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        PAYROLL : WITHHOLDING (MONTHLY) TAX PAGE ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="23" colspan="3"><font size="1"><a href="./remittances_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font></td>
    </tr>
    <tr> 
      <td height="23" colspan="3"><strong><%=strErrMsg%></strong></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Month and Year </td>
      <td> 
		<select name="month_of">
          <%=dbOP.loadComboMonth(WI.fillTextValue("month_of"))%> 
        </select>
        - 
        <select name="year_of">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_of"),2,1)%> 
        </select></td>
    </tr>
    
    	
    <tr> 
      <td height="24">&nbsp;</td>
      <td>Employee Status</td>
      <td><select name="pt_ft" onChange="ReloadPage();">
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
      <td><select name="employee_category" onChange="ReloadPage();">                    
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
      <td>Employer name </td>
      <td>
			<select name="employer_index" onChange="ReloadPage();">
<%
String strEmployer = WI.fillTextValue("employer_index");
boolean bolIsDefEmployer = false;
java.sql.ResultSet rs = null;
strTemp = "select employer_index,employer_name,is_default from pr_employer_profile where is_del = 0 order by is_default desc";
rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	strTemp = rs.getString(1);
	if(strEmployer.length() == 0 || strEmployer.equals(strTemp)) {
		strErrMsg = " selected";
		if(rs.getInt(3) == 1)
			bolIsDefEmployer = true;
		if(strEmployer.length() == 0)
			strEmployer = strTemp;
	}
	else	
		strErrMsg = "";
		
%>			<option value="<%=strTemp%>" <%=strErrMsg%>><%=rs.getString(2)%></option>
<%}
rs.close();
%>      </select></td>
    </tr>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td> 
			<!--
			<select name="c_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <%//=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> 
			</select> 
			-->
			<select name="c_index" onChange="ReloadPage();">
        <option value="">N/A</option>
<%  
if(bolIsDefEmployer)
	strTemp = " from college where is_del= 0 and not exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.c_index = college.c_index and employer_index <>"+strEmployer+")";
else
	strTemp = " from college where is_del= 0 and exists(select * from pr_employer_mapping " +
						"where pr_employer_mapping.c_index = college.c_index and employer_index ="+strEmployer+")";
%>
        <%=dbOP.loadCombo("c_index","c_name", strTemp,strCollegeIndex,false)%>
      </select>			</td>
    </tr>
     <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td><!-- <select name="d_index" onChange="ReloadPage();">
          <option value="">ALL</option>
          <%//if ((strCollegeIndex.length() == 0)){%>
          <%//=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0", WI.fillTextValue("d_index"),false)%> 
          <%//}else if (strCollegeIndex.length() > 0){%>
          <%//=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%//}%>
        </select> 
				-->
        <select name="d_index" onChange="ReloadPage();">
          <option value="">N/A</option>
          <% 
				if(bolIsDefEmployer)
					strTemp = " from department where is_del= 0 " +
										" and not exists(select * from pr_employer_mapping " +
										"   where pr_employer_mapping.d_index = department.d_index " +
										"   and employer_index <> " + strEmployer + ")";
				else
					strTemp = " from department where is_del= 0 " +
										" and exists(select * from pr_employer_mapping " +
										"   where pr_employer_mapping.d_index = department.d_index " +
										"   and employer_index = " + strEmployer + ")";
				if ((strCollegeIndex.length() == 0))
					strTemp += " and (c_index = 0 or c_index is null) ";
				else
					strTemp += " and c_index = " + strCollegeIndex;
				%>
          <%=dbOP.loadCombo("d_index","d_name", strTemp,WI.fillTextValue("d_index"),false)%>
        </select></td>
    </tr>    
  		<%if(bolHasTeam){%>
		<tr>
      <td height="25">&nbsp;</td>
      <td>Team</td>
      <td>
			<select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select>
      </td>
    </tr>
		<%}%>
		<tr>
		  <td height="25">&nbsp;</td>
			<%
				if(WI.fillTextValue("show_total").equals("1"))
					strTemp = " checked";
				else
					strTemp = "";
				
			%>
		  <td><input type="checkbox" name="show_total" value="1" <%=strTemp%>>Show Total </td>
			<%
				strTemp = "";
				if(WI.fillTextValue("inc_resigned").length() > 0)
					strTemp = " checked";
			%>			
		  <td><input type="checkbox" name="inc_resigned" value="1" <%=strTemp%>>
include resigned employees in report</td>
	  </tr>
		<tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="20%">&nbsp;</td>
      <td width="78%">
			<!--
			<a href="javascript:SearchEmployee();"><img src="../../../../images/form_proceed.gif" border="0"></a>
			-->
			<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:SearchEmployee();">
			<font size="1">click to display employee list to print.</font>			</td>
    </tr>
    <tr> 
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
  </table>
	<% 		
	if (vRetResult != null && vRetResult.size() > 0 ){%>  
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="18"><div align="right"><font size="2"> Number of Employees / rows Per 
          Page :
          <select name="num_rec_page">
            <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for( i = 5; i <=45 ; i++) {
				if ( i == iDefault) {%>
            <option selected value="<%=i%>"><%=i%></option>
            <%}else{%>
            <option value="<%=i%>"><%=i%></option>
            <%}}%>
          </select>
          <a href="javascript:PrintPg()"> <img src="../../../../images/print.gif" border="0"></a> 
          <font size="1">click to print</font></font></div></td>
    </tr>
  </table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="5">&nbsp;</td>
  </tr>
  <tr>
    <td colspan="5"><div align="center"><strong><font color="#000000" ><strong>WITHHOLDING TAX</strong></font> COMPENSATION (MONTHLY)<br>
          <%=astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))]%> <%=WI.fillTextValue("year_of")%></strong></div></td>
  </tr>
  <tr>
    <td colspan="5" class="thinborderBOTTOM">&nbsp;</td>
  </tr>
  </table>	
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">	
  <tr >
    <td class="thinborderBOTTOM">&nbsp;</td>
    <td class="thinborderBOTTOM" height="19" ><font size="1"><strong>&nbsp;Dept Code</strong></font></td>
	<td class="thinborderBOTTOM" height="19" ><font size="1"><strong>&nbsp;Department Name</strong></font></td>
	<td class="thinborderBOTTOM" height="19" align="right" ><font size="1"><strong>Salary&nbsp;</strong></font></td>
	<td width="7%" class="thinborderBOTTOM" height="19" align="right" ><font size="1"><strong>Absences&nbsp;</strong></font></td>
	<td width="6%" height="19" align="right" class="thinborderBOTTOM" ><font size="1"><strong>W/Tax&nbsp;</strong></font></td>
	<td width="6%" height="19" align="right" class="thinborderBOTTOM" ><font size="1"><strong>SSS&nbsp;</strong></font></td>
	<td width="6%" height="19" align="right" class="thinborderBOTTOM" ><font size="1"><strong>PHIC&nbsp;</strong></font></td>
	<td width="6%" height="19" align="right" class="thinborderBOTTOM" ><font size="1"><strong>Pag-ibig&nbsp;</strong></font></td>
	<td width="8%" height="19" align="right" class="thinborderBOTTOM" ><font size="1"><strong>Compensation&nbsp;</strong></font></td>
	<td width="6%" height="19" align="right" class="thinborderBOTTOM" ><font size="1"><strong>Total SSS, <br>
	  PHIC &<br>Pag-ibig&nbsp;</strong></font></td>
    <td width="6%" height="19" align="right" class="thinborderBOTTOM" ><font size="1"><strong>15th&nbsp;</strong></font></td>
    <td width="6%" height="19" align="right" class="thinborderBOTTOM" ><font size="1"><strong>30th&nbsp;</strong></font></td>
    <td width="6%" height="19" align="right" class="thinborderBOTTOM" ><font size="1"><strong>TOTAL&nbsp;</strong></font></td>
	<td width="1%" class="thinborderBOTTOM">&nbsp;</td>
  </tr>
  
  <%!
	public double getTaxesWHeld( Vector vRetResult, int i, int ii ){
		String strTemp = vRetResult.elementAt(i+ii)+"";
		strTemp = (strTemp == null || strTemp.length() == 0 ? "0": strTemp );
		return Double.parseDouble(strTemp);
	}
  %>
  
  <%
  
	int iCount = 1;
	String strDept = "";
	String strTemp1 = "";
	String strNxtDept = "";	
	
	double dTotalSalary = 0d;
	double dTotalAWOL = 0d;
	double dTotalWtax = 0d;
	double dTotalSSS = 0d;
	double dTotalPHIC = 0d;
	double dTotalPagIbig = 0d;
	double dTotalCompensation = 0d;
	double dTotalSSS_PHIC_PAGIBIG = 0d;
	double dTotal15th = 0d;
	double dTotal30th = 0d;
	double dTotal1530th = 0d;	
		
	double dGrandSalary = 0d;
	double dGrandAWOL = 0d;
	double dGrandWTax = 0d;
	double dGrandSSS = 0d;
	double dGrandPHIC = 0d;
	double dGrandPagIbig = 0d;
	double dGrandCompensation = 0d;
	double dGrandSSS_PHIC_PAGIBIG = 0d;
	double dGrandTotal15th = 0d;
	double dGrandTotal30th = 0d;
	double dGrandTotal = 0d;
	
	double dSalary = 0d;
	double dWTax = 0d;
	double dAbsences = 0d;
	double dAWOL_amt = 0d;
	double dSSS_amt = 0d;
	double dPHIC_amt = 0d;
	double dPagIbig_amt = 0d;
	double dCompensation = 0d;
	double dSumSSS_PHIC_PAGIBIG = 0d;
	double d15th = 0d;
	double d30th = 0d;	
	double dTotal = 0d;	
	
	int lstidx = 0;
	int iRetResultSize = vRetResult.size();
	
  for(i=0; i<iRetResultSize;iCount++){
	strDept = (String)vRetResult.elementAt(i+1);	
	for(int ii=0; ii<iRetResultSize; ii+=17){
		// (ii+1+)17+lstidx the next index for the Dept.
		if( iRetResultSize >= (ii+18+lstidx) && 
			!strDept.equals((vRetResult.elementAt(ii+18+lstidx)+"")) ){
			strNxtDept = (String)vRetResult.elementAt((ii+18+lstidx));
			break;
		}
		lstidx+=17;
	}
	strDept = (strDept == null ? "DEPT. NOT DEFINED" : strDept);	
  %>	
	<%if( !strDept.equals(strTemp1) ){
		strTemp1 = strDept;
	%>
	
	<tr height="30">
		<td colspan="5">&nbsp;
			<!-- Dept Code -->
			<font size="1"><%=(String)vRetResult.elementAt(i+2)%></font>
			&nbsp;&nbsp;&nbsp;
			<!-- Dept Name -->
			<font size="1"></strong><%=strDept%></strong></font>
		</td>
	</tr>
	<%}%>	
    <tr>
		<td>&nbsp;</td>	
		<!-- ID No. -->
		<td height="23" >&nbsp;
			<font size="1"><%=(String)vRetResult.elementAt(i+3)%></font>
		</td>	
		
		<!-- NAME -->
		<td height="23" >&nbsp;
			<font size="1">
			<%=	WI.formatName(((String)vRetResult.elementAt(i+4)).toUpperCase(), (String)vRetResult.elementAt(i+5),
				((String)vRetResult.elementAt(i+6)).toUpperCase(), 4)
			%>
			</font>
		</td>
		
	  <%
		for(; i < vRetResult.size();){				
			bolNextEmp = false;
			bolIncremented = false;
	  %>

	  <% 
			if(ConversionTable.compareDate((String)vRetResult.elementAt(i+16),strMonth +"/15/"+strYear) < 1){
				dSalary += getTaxesWHeld( vRetResult, i, 7 ); 	//SALARY
				dAWOL_amt += getTaxesWHeld( vRetResult, i, 8 ); //ABSENCES
				dSSS_amt += getTaxesWHeld( vRetResult, i, 9 ); 	//SSS
				dPHIC_amt += getTaxesWHeld( vRetResult, i, 10 ); 	//PHILHEALTH
				dPagIbig_amt += getTaxesWHeld( vRetResult, i, 11 ); //PAGIBIG
				strTemp = (String)vRetResult.elementAt(i+12);
				
				i = i + 17;			 
				bolIncremented = true;
			}else{
				strTemp = "";
			}
			strTemp = WI.getStrValue(strTemp,"0");
			d15th = Double.parseDouble(CommonUtil.formatFloat(strTemp,true));
	  %>

	  <% 
			if(i < vRetResult.size()){
				if(i > 2 && !((String)vRetResult.elementAt(i)).equals((String)vRetResult.elementAt(i-17)))
					bolNextEmp = true;
					
				if(!bolNextEmp){						
					if(ConversionTable.compareDate((String)vRetResult.elementAt(i+16),strMonth +"/31/"+strYear) < 1){
						dSalary += getTaxesWHeld( vRetResult, i, 7 ); 	//SALARY
						dAWOL_amt += getTaxesWHeld( vRetResult, i, 8 ); //ABSENCES
						dSSS_amt += getTaxesWHeld( vRetResult, i, 9 ); 	//SSS
						dPHIC_amt += getTaxesWHeld( vRetResult, i, 10 ); 	//PHILHEALTH
						dPagIbig_amt += getTaxesWHeld( vRetResult, i, 11 ); //PAGIBIG
						strTemp = (String)vRetResult.elementAt(i+12);				
						
						i = i + 17;
						bolIncremented = true;
					}else{
						strTemp = "";
					}
				}else{
					if(!bolIncremented){
						dSalary += getTaxesWHeld( vRetResult, i, 7 ); 	//SALARY
						dAWOL_amt += getTaxesWHeld( vRetResult, i, 8 ); //ABSENCES
						dSSS_amt += getTaxesWHeld( vRetResult, i, 9 ); 	//SSS
						dPHIC_amt += getTaxesWHeld( vRetResult, i, 10 ); 	//PHILHEALTH
						dPagIbig_amt += getTaxesWHeld( vRetResult, i, 11 ); //PAGIBIG
						strTemp = (String)vRetResult.elementAt(i+11);
						
						i = i + 17;
						bolIncremented = true;			
					}else{
						strTemp = "";	
					}
				}				
			}else{
				strTemp = "";
			}	
		
			//30TH Period
			strTemp = WI.getStrValue(strTemp,"0");
			d30th = Double.parseDouble(CommonUtil.formatFloat(strTemp,true));

			//W/TAX
			dWTax = (d15th+d30th);	

			//COMPENSATION
			dCompensation = (dSalary-dAWOL_amt);
			
			//TOTAL SSS PHIC PAGIBIG
			dSumSSS_PHIC_PAGIBIG = (dSSS_amt+dPHIC_amt+dPagIbig_amt);
			
			//TOTAL 
			dTotal = (d15th+d30th);			
			
			// TOTALS
			dTotalSalary += dSalary;
			dTotalAWOL += dAWOL_amt;
			dTotalWtax += dWTax;
			dTotalSSS += dSSS_amt;
			dTotalPHIC += dPHIC_amt;
			dTotalPagIbig += dPagIbig_amt;
			dTotalCompensation += dCompensation;
			dTotalSSS_PHIC_PAGIBIG += dSumSSS_PHIC_PAGIBIG;
			dTotal15th += d15th;
			dTotal30th += d30th;
			dTotal1530th += dTotal;

			// GRAND TOTALS
			dGrandSalary += dSalary;
			dGrandAWOL += dAWOL_amt;
			dGrandWTax += dWTax;
			dGrandSSS += dSSS_amt;
			dGrandPHIC += dPHIC_amt;
			dGrandPagIbig += dPagIbig_amt;
			dGrandCompensation += dCompensation;
			dGrandSSS_PHIC_PAGIBIG += dSumSSS_PHIC_PAGIBIG;
			dGrandTotal15th += d15th;
			dGrandTotal30th += d30th;
			dGrandTotal += dTotal;
	  %>
	  
		<!-- SALARY -->
		<td align="right" ><font size="1"><%=CommonUtil.formatFloat(dSalary,true)%></font></td>
		<!-- ABSENCES -->
		<td align="right" ><font size="1"><%=CommonUtil.formatFloat(dAWOL_amt,true)%></font></td>
		<!-- W/TAX -->
		<td align="right" ><font size="1"><%=CommonUtil.formatFloat(dWTax,true)%></font></td>
		<!-- SSS -->
		<td align="right" ><font size="1"><%=CommonUtil.formatFloat(dSSS_amt,true)%></font></td>
		<!-- PHIC -->
		<td align="right" ><font size="1"><%=CommonUtil.formatFloat(dPHIC_amt,true)%></font></td>
		<!-- PAGIBIG -->
		<td align="right" ><font size="1"><%=CommonUtil.formatFloat(dPagIbig_amt,true)%></font></td>
		<!-- COMPENSATION -->
		<td align="right" ><font size="1"><%=CommonUtil.formatFloat(dCompensation,true)%></font></td>
		<!-- TOTAL SSS, PHIC & PAG-IBIG -->
		<td align="right" ><font size="1"><%=CommonUtil.formatFloat(dSumSSS_PHIC_PAGIBIG,true)%></font></td>	  
		<!-- 15th -->
		<td align="right" ><font size="1"><%=CommonUtil.formatFloat(d15th,true)%></font></td>	 
		<!-- 30th -->
		<td align="right" ><font size="1"><%=CommonUtil.formatFloat(d30th,true)%></font></td>	  
		<!-- TOTAL -->
		<td align="right" ><font size="1"><%=CommonUtil.formatFloat(dTotal,true)%></font></td>
    </tr>	
	<%
			dSalary = 0d;
			dAWOL_amt = 0d;
			dSSS_amt = 0d;
			dPHIC_amt = 0d;
			dPagIbig_amt = 0d;	
			break;
		}// inner for loop
	%>	
	
	<%if( !strDept.equals(strNxtDept) || i>= iRetResultSize ){%>
	<tr height="50" >
		<td class="thinborderTOPBOTTOM" >&nbsp;</td>		
		<td class="thinborderTOPBOTTOM" >&nbsp;</td>		
		<td class="thinborderTOPBOTTOM" ><strong><font size="1">TOTALS:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></strong></td>		
		<td class="thinborderTOPBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dTotalSalary,true)%></font></td>
		<td class="thinborderTOPBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dTotalAWOL,true)%></font></td>
		<td class="thinborderTOPBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dTotalWtax,true)%></font></td>
		<td class="thinborderTOPBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dTotalSSS,true)%></font></td>
		<td class="thinborderTOPBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dTotalPHIC,true)%></font></td>
		<td class="thinborderTOPBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dTotalPagIbig,true)%></font></td>
		<td class="thinborderTOPBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dTotalCompensation,true)%></font></td>
		<td class="thinborderTOPBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dTotalSSS_PHIC_PAGIBIG,true)%></font></td>
		<td class="thinborderTOPBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dTotal15th,true)%></font></td>
		<td class="thinborderTOPBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dTotal30th,true)%></font></td>
		<td class="thinborderTOPBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dTotal1530th,true)%></font></td>
		<td class="thinborderTOPBOTTOM" >&nbsp;</td>
	</tr>
	<%
		dTotalSalary = 0d;
		dTotalAWOL = 0d;
		dTotalWtax = 0d;
		dTotalSSS = 0d;
		dTotalPHIC = 0d;
		dTotalPagIbig = 0d;
		dTotalCompensation = 0d;
		dTotalSSS_PHIC_PAGIBIG = 0d;
		dTotal15th = 0d;
		dTotal30th = 0d;
		dTotal1530th = 0d;
	}%>
	
  <% if(!bolIncremented){
  		break;
	}
  }// outer for loop%>
  		
	<tr height="50" >
		<td class="thinborderBOTTOM" >&nbsp;</td>		
		<td class="thinborderBOTTOM" >&nbsp;</td>		
		<td class="thinborderBOTTOM" ><strong><font size="1">GRAND TOTALS:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</font></strong></td>		
		<td class="thinborderBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dGrandSalary,true)%></font></td>
		<td class="thinborderBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dGrandAWOL,true)%></font></td>
		<td class="thinborderBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dGrandWTax,true)%></font></td>
		<td class="thinborderBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dGrandSSS,true)%></font></td>
		<td class="thinborderBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dGrandPHIC,true)%></font></td>
		<td class="thinborderBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dGrandPagIbig,true)%></font></td>
		<td class="thinborderBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dGrandCompensation,true)%></font></td>
		<td class="thinborderBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dGrandSSS_PHIC_PAGIBIG,true)%></font></td>
		<td class="thinborderBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dGrandTotal15th,true)%></font></td>
		<td class="thinborderBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dGrandTotal30th,true)%></font></td>
		<td class="thinborderBOTTOM" align="right"><strong><font size="1"><%=CommonUtil.formatFloat(dGrandTotal,true)%></font></td>
		<td class="thinborderBOTTOM" >&nbsp;</td>
	</tr>  
	
	<tr>
		<td width="1%">&nbsp;</td>
		<td width="9%">&nbsp;</td>
		<td width="19%">&nbsp;</td>
		<td width="7%">&nbsp;</td>
		<td width="7%">&nbsp;</td>
	</tr>
</table>
<%} // if (vRetResult != null && vRetResult.size() > 0 )%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  
  <tr>
    <td height="25">&nbsp;</td>
    </tr>
  <tr bgcolor="#A49A6A">
    <td width="50%" height="25" class="footerDynamic">&nbsp;</td>
  </tr>
</table>
  <input type="hidden" name="searchEmployee" value="<%=WI.fillTextValue("searchEmployee")%>">
  <input type="hidden" name="print_page" value="">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>