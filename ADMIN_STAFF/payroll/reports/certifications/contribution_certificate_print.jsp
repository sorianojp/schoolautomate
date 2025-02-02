<%@ page language="java" import="utility.*,java.util.Vector, java.util.Calendar" %>
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
<title>Untitled Document</title>
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
<body>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;


try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Certificate of Contribution","phic_certificate_contribution.jsp");
								
		
		
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
														"phic_certificate_contribution.jsp");
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

payroll.PRRemittance employer = new payroll.PRRemittance(request);
payroll.PRSalaryExtn salaryExtn = new payroll.PRSalaryExtn();	
payroll.PRContributionReport PRContribute = new payroll.PRContributionReport();	




strErrMsg = null;
								
String strContributionEmpList = WI.fillTextValue("employee_to_print");
if(strContributionEmpList.length() == 0)
	strContributionEmpList = (String)request.getSession(false).getAttribute("contribution_emp_list");	


if(strContributionEmpList == null || strContributionEmpList.length() == 0)
	strErrMsg = "EMPLOYEE LIST NOT FOUND";
	
String strTransactionType = WI.fillTextValue("transaction_type");
if(strTransactionType.length() == 0){
	if(strErrMsg == null)
		strErrMsg = "Transaction Type not found.";
	else
		strErrMsg += "<br>Transaction Type not found.";
}
	

Vector vEmployerInfo = employer.operateOnEmployerProfile(dbOP,4);
if(vEmployerInfo == null || vEmployerInfo.size() == 0){
	strTemp =  employer.getErrMsg();
	if(strTemp == null || strTemp.length() == 0)
		strTemp = "Employer information not found.";

	if(strErrMsg == null)
		strErrMsg = strTemp;
	else
		strErrMsg += "<br>"+strTemp;
}
	


if(strErrMsg != null){dbOP.cleanUP();%>
	<div style="text-align:center; height:25; color:#FF0000; font-size:14px;"><strong><%=strErrMsg%></strong></div>
<%return;}





strTemp = "select SSS_NUMBER, PAG_IBIG, PHILHEALTH from HR_INFO_PERSONAL where IS_VALID = 1 and USER_INDEX = ?";
java.sql.PreparedStatement pstmtSelectSSS = dbOP.getPreparedStatement(strTemp);

strTemp = "select DOB from INFO_FACULTY_BASIC where IS_VALID =1 and USER_INDEX = ?";
java.sql.PreparedStatement pstmtSelectDOB = dbOP.getPreparedStatement(strTemp);

java.sql.ResultSet rs = null;




Vector vUserDetail = null;
Vector vEmpList = CommonUtil.convertCSVToVector(strContributionEmpList);
Vector vContribution = null;
int iElemCount = 0;


String strEmpName = null;
String strEmpNumber = null;
String strEmpIndex = null;
String strDOB  = null;


String[] astrTrasanctionType = {"Select Transaction Type","PHILHEALTH","PAGIBIG PREMIUM","PAGIBIG LOAN","SSS PREMIUM","SSS LOAN"};
String[] astrMonth = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };
while(vEmpList.size() > 0){
	strEmpIndex = (String)vEmpList.remove(0);


	vUserDetail = salaryExtn.getEmployeeInfo(dbOP, strEmpIndex);	
	if(vUserDetail == null || vUserDetail.size() == 0)
		continue;
		
	
	strEmpName =WI.formatName((String)vUserDetail.elementAt(2),(String)vUserDetail.elementAt(3),(String)vUserDetail.elementAt(4),4); 

	
	iElemCount = 0;
	vContribution = PRContribute.getEmployeeContribution(dbOP, request, strEmpIndex, strTransactionType);
	if(vContribution == null)
		vContribution = new Vector();
	else
		iElemCount = PRContribute.getElemCount();
		

	strDOB = null;
	pstmtSelectDOB.setString(1, strEmpIndex);
	rs = pstmtSelectDOB.executeQuery();
	if(rs.next())
		strDOB = ConversionTable.convertMMDDYYYY(rs.getDate(1));
	rs.close();
	
	
	
	strEmpNumber = null;
	pstmtSelectSSS.setString(1, strEmpIndex);
	rs = pstmtSelectSSS.executeQuery();
	
	if(rs.next()){
		if(strTransactionType.equals("1"))//PHILHEALTH
			strEmpNumber = rs.getString(3);
		else if(strTransactionType.equals("2"))//PAG_IBIG
			strEmpNumber = rs.getString(2);
		else if(strTransactionType.equals("4"))//SSS
			strEmpNumber = rs.getString(1);			
	}rs.close();
	
%>
  
<table width="90%" align="center" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr><td height="40" colspan="7">&nbsp;</td></tr>
	<tr>
		<td height="50" colspan="7" align="center"><strong style="font-size:20px;">CERTIFICATION</strong></td>
	</tr>
<tr>
		<td height="20" colspan="7">&nbsp;</td>
	</tr>
<%
if(strTransactionType.equals("1")){
%>
	<tr>
		<td colspan="7" style="text-indent:40px; text-align:justify;">
			This is to certify that <%=WI.getStrValue(vEmployerInfo.elementAt(12)).toUpperCase()%>, with
Corporate PhilHealth ID Number <%=WI.getStrValue(vEmployerInfo.elementAt(8))%>, had remitted the following
PHILHEALTH contribution payment(s) of <strong><%=strEmpName%></strong> with 
        <strong>PhilHealth ID Number <%=strEmpNumber%></strong> are as follows:		</td>
	</tr>
<%}else if(strTransactionType.equals("2")){%>
	<tr>
		<td colspan="7" style="text-indent:40px; text-align:justify;">
		This is to certify that <%=WI.getStrValue(vEmployerInfo.elementAt(12)).toUpperCase()%>, with Corporate HDMF Number 202275040000 had remitted the 
premiums of <strong><%=strEmpName%></strong> with <strong>HDMF Number <%=strEmpNumber%> <%=WI.getStrValue(strDOB," and BIRTHDATE ","","")%> </strong>
to PAG-IBIG fund as follows:
		</td>
	</tr>
<%}else{//SSS%>
	<tr>
		<td colspan="7" style="text-indent:40px; text-align:justify;">		
This is to certify that <%=WI.getStrValue(vEmployerInfo.elementAt(12)).toUpperCase()%>, with Corporate SSS ID Number <%=WI.getStrValue(vEmployerInfo.elementAt(6))%>, had remitted the
following contribution payment including SSS and EC of <strong><%=strEmpName%></strong> with <strong>SSS No. <%=strEmpNumber%></strong>
are as follows:
		</td>
	</tr>
<%}%>
	
	<tr>
		<td height="30" colspan="7">&nbsp;</td>
	</tr>
	
	<tr style="font-weight:bold;">
		<td width="20%" align="right"><u>MONTH/YEAR</u></td>
	    <td width="16%" align="right"><u>EMPLOYEE</u></td>
	    <td width="16%" align="right"><u>EMPLOYER</u></td>
	    <td width="13%" align="right"><u>TOTAL</u></td>
	    <td width="2%">&nbsp;</td>
		<%
		if(!strTransactionType.equals("4"))
			strTemp = "OR#";
		else
			strTemp = "SBR#";
		%>
	    <td width="13%"><u><%=strTemp%></u></td>
	    <td width="20%"><u>DATE PAID</u></td>
	</tr>
<%
double dTotal = 0d;
for(int i = 0; i < vContribution.size(); i+=iElemCount){
%>	
	<tr>
	    <td height="20" align="right"><%=astrMonth[Integer.parseInt((String)vContribution.elementAt(i+3))]%> <%=(String)vContribution.elementAt(i+4)%></td>
	    <td align="right"><%=(String)vContribution.elementAt(i+6)%></td>
	    <td align="right"><%=(String)vContribution.elementAt(i+7)%></td>
		<%
		try{
			dTotal = Double.parseDouble(WI.getStrValue(vContribution.elementAt(i+6),"0")) + 
				Double.parseDouble(WI.getStrValue(vContribution.elementAt(i+7),"0"));
		}catch(Exception e){
			dTotal = 0d;
		}
		%>
	    <td align="right"><%=CommonUtil.formatFloat(dTotal,true)%></td>
		<td>&nbsp;</td>	
	    <td><%=(String)vContribution.elementAt(i+1)%></td>
	    <td><%=(String)vContribution.elementAt(i+2)%></td>
	    
    </tr>
<%}%>
	
	<tr>
		<td height="30" colspan="7">&nbsp;</td>
	</tr>
<%
if(strTransactionType.equals("1")){
%>
	
	<tr>
		<td colspan="7" style="text-indent:40px;">
		This certification is being issued upon the request of the above employee
in connection with his/her application for PhilHealth benefits.
		
		</td>
	</tr>
<%}else if(strTransactionType.equals("2")){%>	
	<tr>
		<td colspan="7" style="text-indent:40px;">
		This certification is being issued upon the request of the above employee for
whatever purpose(s) it may serve him/her best.
		
		</td>
	</tr>
<%}else{%>
	<tr>
		<td colspan="7" style="text-indent:40px;">
		This certification is being issued upon the request of the above employee in connection
with his/her application for SSS benefits.
		</td>
	</tr>
<%}%>
	
	<tr>
		<td height="25" colspan="7">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="7" style="text-indent:40px;">
		Given on <%=WI.getTodaysDate(6)%> located at <%=WI.getStrValue(vEmployerInfo.elementAt(3))%>.
		
		</td>
	</tr>
	<tr>
		<td colspan="7" valign="bottom" height="100" align="center">
		<div style="border-bottom:solid 1px #000000; width:30%;"></div>
		<%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "Chief Accountant",7)).toUpperCase()%><br>
		Chief Accountant
		</td>
	</tr>
</table>  

<%}//end of while%>
<script>window.print();</script>
</body>
</html>
<%
dbOP.cleanUP();
%>