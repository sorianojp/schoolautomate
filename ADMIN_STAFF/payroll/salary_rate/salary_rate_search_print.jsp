<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRSalaryRate, payroll.PRAllowances" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Salary rate print search result</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize10{
		font-size:11px;
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

<body bgcolor="#FFFFFF" onLoad="window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;

	int iSearchResult = 0;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-SALARY RATE",
								"salary_rate_search.jsp");

	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"PAYROLL","SALARY RATE",
											request.getRemoteAddr(),"salary_rate_search.jsp");
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


PRSalaryRate hrStat = new PRSalaryRate(request);
PRAllowances prAllow = new PRAllowances();
String[] astrSortByName    = {"Last Name","First Name","Tax Status", "Salary Period","Bank Code", "Account No"};
String[] astrSortByVal     = {"lname","fname","tax_status", "salary_period","bank_code", "bank_account"};
int iCheckboxes = 25;
boolean[] abolShowList= new boolean[iCheckboxes];
	
int iIndex = 1;
int iIndexOf  = 0;
Long lIndex = null;
String strTemp2 = null;

String[] astrConvertCivilStat = {"","Single","Married","Divorced/Separated","Widow/Widower"};
String[] astrTaxStatus={" N / A","Z","S","HF","ME"};
String[] astrSalaryPeriod = {"N / A","Daily","Weekly","Bi-Monthly","Monthly"};
String[] astrExemptionName    = {"Zero", "Single","Head of Family", "Head of Family 1 Dependent (HF1)", 
																"Head of Family 2 Dependents (HF2)","Head of Family 3 Dependents (HF3)", 
																"Head of Family 2 Dependents (HF4)", "Married Employed", 																	 
																 "Married Employed 1 Dependent (ME1)", "Married Employed 2 Dependents (ME2)",
																 "Married Employed 3 Dependents (ME3)", "Married Employed 4 Dependents (ME4)"};
String[] astrExemptionVal     = {"0","1","2","21","22","23","24","3","31","32","33","34"};

String strStatus = null;
String strDependent = null;

boolean bolOneSelected = false;
Vector vAllowances = null;

for(; iIndex <= (iCheckboxes-1); iIndex++){
	if(WI.fillTextValue("checkbox"+iIndex).equals("1")){
		abolShowList[iIndex] = true;
		if ( iIndex <= 5){
			bolOneSelected = true;
		}
	}
}

// force the basic monthly to be selected in case
// none of the rates is selected.. 
if(!bolOneSelected){
	abolShowList[1] = true;
}

Vector vRetResult =  hrStat.searchSalaryRate(dbOP, true);
	vAllowances = prAllow.getAppliedAllowanceToEmp(dbOP, request);
	if (vRetResult != null){
		iSearchResult = hrStat.getSearchCount();
	}else{
		strErrMsg = hrStat.getErrMsg();
	}
%>

<% if (strErrMsg != null) {%> 
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25">&nbsp;<%=WI.getStrValue(strErrMsg,"<strong><font size=\"3\" color=\"#FF0000\">","</font></strong>","")%></td>
    </tr>
  </table>
 <%} else if (vRetResult != null && vRetResult.size() > 0) {
 
 	int iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_lines"),"15"));
	int iRowsPrinted = 0;
 
 	for (int i = 0; i < vRetResult.size();) {
		iRowsPrinted = 0;
	
	
 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" align="center" > <strong> SALARY RATES OF EMPLOYEES </strong></td>
    </tr>
  </table>
  
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="49%" height="25">&nbsp;
	  <% if (i ==0) {%> 
	  <b>&nbsp;TOTAL RESULT : <%=iSearchResult%>  <%}%> 

			 </b></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="3%" align="center"  class="thinborder"><font size="1"><strong>ID</strong></font></td> 
          <td width="16%" height="25" align="center"  class="thinborder"><font size="1"><strong>EMPLOYEE 
            NAME</strong></font></td>
      <td width="8%" align="center"  class="thinborder"><font size="1"><strong>UNIT</strong></font></td>
      <td width="8%" align="center" class="thinborder"><font size="1"><strong>POSITION</strong></font></td>
      <% iIndex = 1; if (abolShowList[iIndex++]){%>
      <td width="7%" class="thinborder"><strong><font size="1">&nbsp;BASIC</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="8%" class="thinborder"><strong><font size="1">&nbsp;DAILY</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="8%" class="thinborder"><font size="1"><strong>&nbsp;HOURLY</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
			<td width="9%" class="thinborder"><font size="1"><strong>ALLOWANCES</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="9%" class="thinborder"><font size="1"><strong>&nbsp;TEACHING</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">&nbsp;OVER<br>
      LOAD</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="7%" align="center" class="thinborder"><font size="1"><strong>TAX<br>
      STATUS</strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="9%" align="center" class="thinborder"><font size="1"><strong>SALARY PERIOD </strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="8%" class="thinborder"><font size="1"><strong>BANK INFO </strong></font></td>
      <%}if (abolShowList[iIndex++]){%>
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>SUPERVISOR</strong></font></td>
			<%}if (abolShowList[iIndex++]){%>			
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>DATE HIRED </strong></font></td>
			<%}if (abolShowList[iIndex++]){%>			
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>BIRTH DATE</strong></font></td>
			<%}if (abolShowList[iIndex++]){%>			
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>MARITAL STATUS </strong></font></td>
			<%}if (abolShowList[iIndex++]){%>			
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>TAX EXEMPTION</strong></font></td>
			<%}if (abolShowList[iIndex++]){%>			
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>CATEGORY</strong></font></td>
			<%}if (abolShowList[iIndex++]){%>			
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>JOB GRADE</strong></font></td>
			<%}if (abolShowList[iIndex++]){%>			
      <td width="6%" align="center" class="thinborder"><font size="1"><strong>JOB CODE</strong></font></td>
			<%}if (abolShowList[iIndex++]){%>			
      <td width="6%" align="center" class="thinborder"><strong><font size="1">GENDER</font></strong></td>
      <%}if (abolShowList[iIndex++]){%>			
      <td width="6%" align="center" class="thinborder"><strong><font size="1">RLE<br>
      RATE</font></strong></td>
			<%}if (abolShowList[iIndex++]){%>			
      <td width="6%" align="center" class="thinborder"><strong><font size="1">LEC<br>
      RATE</font></strong></td>
			<%}if (abolShowList[iIndex++]){%>			
      <td width="6%" align="center" class="thinborder"><strong><font size="1">LAB<br>
      RATE</font></strong></td>
			<%}if (abolShowList[iIndex++]){%>		
			<td width="6%" align="center" class="thinborder"><strong><font size="1">GRAD RATE</font></strong></td>
			<%}if (abolShowList[iIndex++]){%>			
			<td width="6%" align="center" class="thinborder"><strong><font size="1">NSTP RATE</font></strong></td>
			<%}if (abolShowList[iIndex++]){%>		
      <td width="6%" align="center" class="thinborder"><strong><font size="1">CLASS<br>
      RATE</font></strong></td>
      <%}%>
    </tr>
    <% 
		for (; i < vRetResult.size(); i+=35,iRowsPrinted ++){
		iIndex = 1;
		lIndex = (Long)vRetResult.elementAt(i+16);
		if (iRowsPerPage == iRowsPrinted) 
			break;
		
	%>
    <tr>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i)%></td> 
      <td height="25" class="thinborder">
  	  <%=WI.formatName((String)vRetResult.elementAt(i+1),
	  					(String)vRetResult.elementAt(i+2),
					    (String)vRetResult.elementAt(i+3),4)%></td>
      <% 
		strTemp = (String)vRetResult.elementAt(i+4);
		if (strTemp == null) 
			strTemp = (String)vRetResult.elementAt(i+5);
		else 
			strTemp += WI.getStrValue((String)vRetResult.elementAt(i+5)," :: ","","");
	%>
      <td class="thinborder"> <%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i+6),"&nbsp;")%></td>
      <%if (abolShowList[iIndex++]){%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+7),true)%>&nbsp;</td>
      <%}if (abolShowList[iIndex++]){%>
      <td align="right" class="thinborder"> <%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+8),true)%>&nbsp;</td>
      <%}if (abolShowList[iIndex++]){%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+9),true)%>&nbsp;</td>
      <%}if (abolShowList[iIndex++]){
				strTemp = "";
				if(vAllowances != null && vAllowances.size() > 0){
					iIndexOf = vAllowances.indexOf(lIndex);					
					while(iIndexOf != -1){
						vAllowances.remove(iIndexOf); // user_index, , , , " +
						if(strTemp.length() > 0)
							strTemp += "<br>-"+(String)vAllowances.remove(iIndexOf); // allowance_name
						else
							strTemp = "-" +(String)vAllowances.remove(iIndexOf); // allowance_name
						
						vAllowances.remove(iIndexOf); // sub_type
						vAllowances.remove(iIndexOf); // cola_month
						vAllowances.remove(iIndexOf); // cola_daily
						vAllowances.remove(iIndexOf); // cola_hourly
						vAllowances.remove(iIndexOf); // release_sched
						vAllowances.remove(iIndexOf); // deduct_absent
						iIndexOf = vAllowances.indexOf(lIndex);
					}
				}
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
      <%}if (abolShowList[iIndex++]){%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+10),true)%>&nbsp;</td>
      <%}if (abolShowList[iIndex++]){%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i+11),true)%>&nbsp;</td>
      <%}if (abolShowList[iIndex++]){%>
			  <%
				strStatus = WI.getStrValue(((Long)vRetResult.elementAt(i+12)).toString(),"-1");
				strDependent = null;
 					if(strStatus.length() == 2){
						strDependent = strStatus.substring(1,2);
						strStatus = strStatus.substring(0,1);						
					}
					
				 strTemp2 = "";
				 if(Integer.parseInt(strStatus) < 10){
				 		strTemp2 = (String)vRetResult.elementAt(i+24);
						if(Integer.parseInt(strTemp2) == 0)
							strTemp2 = "";
					}				 
				%>			
      <td class="thinborder"><%=astrTaxStatus[Integer.parseInt(strStatus)  + 1]%><%=strTemp2%><%=WI.getStrValue(strDependent)%></td>
      <%}if (abolShowList[iIndex++]){%>
      <td class="thinborder">
	  		<%=astrSalaryPeriod[Integer.parseInt(WI.getStrValue(vRetResult.elementAt(i+13),"-1")) + 1]%>	  </td>
      <%}if (abolShowList[iIndex++]){
	  	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+14));
		
		if (strTemp.length() == 0) 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+15));
		else
			strTemp += WI.getStrValue((String)vRetResult.elementAt(i+15),"::","","");
	  
	  	if (strTemp.length() ==0 || strTemp.equals("::0") || strTemp.equals("0")){
			strTemp = "No Record";
		}
	  %>
      <td class="thinborder"><%=strTemp%></td>
      <%}if (abolShowList[iIndex++]){
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+22),"&nbsp;");
			%>
      <td class="thinborder"><%=strTemp%></td>
			<%}if (abolShowList[iIndex++]){
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+17),"&nbsp;");
			%>
      <td class="thinborder"><%=strTemp%></td>
			<%}if (abolShowList[iIndex++]){
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+18),"&nbsp;");
			%>
      <td class="thinborder"><%=strTemp%></td>
			<%}if (abolShowList[iIndex++]){
			strTemp = astrConvertCivilStat[Integer.parseInt((String)vRetResult.elementAt(i+19))];
			%>
      <td class="thinborder"><%=strTemp%></td>
			<%}if (abolShowList[iIndex++]){
			strTemp = (String)vRetResult.elementAt(i+23);
			%>
      <td align="right" class="thinborder"><%=strTemp%></td>
			<%}if (abolShowList[iIndex++]){%>
      <td class="thinborder"><%=strTemp%></td>
			<%}if (abolShowList[iIndex++]){
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+21),"&nbsp;");
			%>
      <td class="thinborder"><%=strTemp%></td>
			<%}if (abolShowList[iIndex++]){%>
      <td class="thinborder"><%=strTemp%></td>
			<%}if (abolShowList[iIndex++]){
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+20));
			if(strTemp.equals("1"))
				strTemp = "F";
			else
				strTemp = "M";
			%>
      <td class="thinborder"><%=strTemp%></td>
      <%}if (abolShowList[iIndex++]){
				strTemp = (String)vRetResult.elementAt(i+25);
			%>
      <td class="thinborder"><%=WI.getStrValue(strTemp)%></td>
			<%}if (abolShowList[iIndex++]){
			strTemp = (String)vRetResult.elementAt(i+26);
			%>
      <td class="thinborder"><%=WI.getStrValue(strTemp)%></td>
			<%}if (abolShowList[iIndex++]){
			strTemp = (String)vRetResult.elementAt(i+27);
			%>
      <td class="thinborder"><%=WI.getStrValue(strTemp)%></td>
			<%}if (abolShowList[iIndex++]){
			strTemp = (String)vRetResult.elementAt(i+29);
			%>
      <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%}if (abolShowList[iIndex++]){
			strTemp = (String)vRetResult.elementAt(i+30);
			%>
      <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>

			<%}if (abolShowList[iIndex++]){
			strTemp = (String)vRetResult.elementAt(i+28);
			%>
      <td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			<%}%>
    </tr>
    <%}// end for loop%>
</table>
<% if (i < vRetResult.size()){ %>
	<DIV style="page-break-before:always">&nbsp;</Div>
<% }  
  } //end outer most for loop
 }
%>
</body>
</html>
<%
	dbOP.cleanUP();
%>