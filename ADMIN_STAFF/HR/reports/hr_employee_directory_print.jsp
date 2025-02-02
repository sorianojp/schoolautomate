<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">

</head>


<%
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	boolean bolShowSeminar = (WI.fillTextValue("show_seminar").length() > 0);
	boolean bolShowEducation = (WI.fillTextValue("show_education").length() > 0);
	boolean bolShowLengthOfService = (WI.fillTextValue("show_length_of_service").length() > 0);
	boolean bolShowDept    = (WI.fillTextValue("show_department").length() > 0);
	boolean bolShowAddress = (WI.fillTextValue("show_address").length() > 0);
	boolean bolShowLicense = (WI.fillTextValue("show_licenses").length() > 0);
	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	boolean bolMyHome = false;

	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-REPORTS AND STATISTICS","hr_employee_directory.jsp");
		
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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","REPORTS AND STATISTICS",request.getRemoteAddr(),
														"hr_employee_directory.jsp");

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

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Emp. Status","Emp. Type"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","user_status.status","HR_EMPLOYMENT_TYPE.EMP_TYPE_NAME","c_name","d_name"};

String[] astrCStatus = {"","Single","Married", "Divorced/ Separated", "Widow/ Widower","Annuled","Living Together"};
String[] astrPTFT    = {"Part-Time", "Full-Time"};

hr.HRStatsReportsExtn hrStatReportExtn = new hr.HRStatsReportsExtn();
Vector vRetResult = null;
int iElemCount = 0;
int iSearchResult = 0;

	vRetResult = hrStatReportExtn.getEmployeeDirectory(dbOP, request);
	if(vRetResult == null)
		strErrMsg = hrStatReportExtn.getErrMsg();
	else{
		iElemCount = hrStatReportExtn.getElemCount();
		iSearchResult = hrStatReportExtn.getSearchCount();
	}



%>
<body>


<%
if(vRetResult != null && vRetResult.size() > 0){
%>
<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF">
	<tr><td align="center">
	<strong><%=SchoolInformation.getSchoolName(dbOP, true, false)%><br>
	Directory of Employees
	</strong>
	</td></tr>
</table>
<table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">	
		<tr valign="bottom" style="font-weight:bold;">
		    <td class="thinborder">SL No.</td>
			<td class="thinborder">Name</td>
			<%if(bolShowDept){%><td width="9%" class="thinborder">Department/Offices</td><%}%>
			<%if(bolShowAddress){%><td width="4%" class="thinborder">Address</td><%}%>
			<td width="4%" class="thinborder">Contact No.</td>
			<td width="4%" class="thinborder">Date<br>of<br>Birth</td>
			<td width="4%" class="thinborder">Civil<br>Status</td>
			<td width="5%" class="thinborder">Spouse,<br>If Married</td>
			<td width="4%" class="thinborder">SSS Num.</td>
			<td width="4%" class="thinborder">TIN</td>
			<td width="4%" class="thinborder">Pag-ibig</td>
			<td width="5%" class="thinborder">Date Hired</td>
			<%if(bolShowLengthOfService){%><td width="4%" class="thinborder">Length<br>
		    on<br>Service</td><%}%>
			<td width="7%" class="thinborder">Emp. Tenureship<br>
		    (Regular/Probi)</td>
			<td width="7%" class="thinborder">Emp. Status <br>
		    (Full-Time /PartTime<br>/Profesional<br>Lecturer)</td>
			<%if(bolShowEducation){%><td width="10%" class="thinborder">Education</td><%}%>
			<%if(bolShowLicense){%><td width="10%" class="thinborder">Licenses</td><%}%>			
			<td width="5%" class="thinborder">Job Rank</td>
			<%if(bolShowSeminar){%><td width="10%" class="thinborder">Seminars/Training<br>
		    (Name of Seminar/Date/Venue)</td><%}%>
		</tr>
	<%
	int iCount = 0;
	int iSLNo  = 0;
	int iIndexOf = 0;
	Vector vTraining = null;
	Vector vEduHist  = null;
	Vector vLicenseList  = null;
	for(int i = 0; i < vRetResult.size(); i+=iElemCount){
		vTraining = (Vector)vRetResult.elementAt(i+24);
		if(vTraining == null)
			vTraining = new Vector();
		vEduHist = (Vector)vRetResult.elementAt(i+22);
		if(vEduHist == null)
			vEduHist = new Vector();
		vLicenseList = (Vector)vRetResult.elementAt(i+25);
		if(vLicenseList == null)
			vLicenseList = new Vector();
	%>
		<tr valign="bottom">
		    <td class="thinborder" align="right"><%=++iSLNo%>.</td>
			<%
			strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4);
			%>
			<td height="25" class="thinborder"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></td>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+6));
			strErrMsg = WI.getStrValue(vRetResult.elementAt(i+8));			
			if(strTemp.length() > 0 && strErrMsg.length() > 0)
				strTemp += "/";
			strTemp += strErrMsg;
			%>
			<%if(bolShowDept){%><td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><%}%>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+9));			
			%>
			<%if(bolShowAddress){%><td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><%}%>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+10));	
			
			iIndexOf = strTemp.indexOf("/");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(",");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(";");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf("or");
					
			if(iIndexOf > -1)	{
				if(strTemp.indexOf("or") > -1)
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+2);
				else
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+1);
			}
				
			iIndexOf = strTemp.indexOf("/");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(",");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(";");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf("or");
								
			if(iIndexOf > -1)	{
				if(strTemp.indexOf("or") > -1)
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+2);
				else
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+1);
			}
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+11));			
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = astrCStatus[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+12),"1"))];
			
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+13),(String)vRetResult.elementAt(i+14),(String)vRetResult.elementAt(i+15),4);
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+16));	
			iIndexOf = strTemp.indexOf("/");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(",");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(";");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf("or");
					
			if(iIndexOf > -1)	{
				if(strTemp.indexOf("or") > -1)
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+2);
				else
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+1);
			}
				
			iIndexOf = strTemp.indexOf("/");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(",");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(";");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf("or");
								
			if(iIndexOf > -1)	{
				if(strTemp.indexOf("or") > -1)
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+2);
				else
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+1);
			}		
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+17));	
			iIndexOf = strTemp.indexOf("/");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(",");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(";");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf("or");
					
			if(iIndexOf > -1)	{
				if(strTemp.indexOf("or") > -1)
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+2);
				else
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+1);
			}
				
			iIndexOf = strTemp.indexOf("/");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(",");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(";");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf("or");
								
			if(iIndexOf > -1)	{
				if(strTemp.indexOf("or") > -1)
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+2);
				else
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+1);
			}		
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+18));	
			iIndexOf = strTemp.indexOf("/");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(",");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(";");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf("or");
					
			if(iIndexOf > -1)	{
				if(strTemp.indexOf("or") > -1)
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+2);
				else
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+1);
			}
				
			iIndexOf = strTemp.indexOf("/");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(",");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf(";");
			if(iIndexOf == -1)
				iIndexOf = strTemp.indexOf("or");
								
			if(iIndexOf > -1)	{
				if(strTemp.indexOf("or") > -1)
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+2);
				else
					strTemp = strTemp.substring(0, iIndexOf)+"<br>"+strTemp.substring(iIndexOf+1);
			}		
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+19));			
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = new hr.HRUtil().getServicePeriodLength(dbOP,(String)vRetResult.elementAt(i));
			%>
			<%if(bolShowLengthOfService){%><td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><%}%>
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+20));			
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			strTemp = astrPTFT[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+21)))];
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			iCount = 0;
			strTemp = null;
			for(int x=0; x < vEduHist.size(); x+=2){
				if(strTemp == null)
					strTemp = (++iCount)+".) "+(String)vEduHist.elementAt(x)+WI.getStrValue((String)vEduHist.elementAt(x+1)," (Major in ",")","");
				else
					strTemp += "<br>"+ (++iCount)+".) "+(String)vEduHist.elementAt(x)+WI.getStrValue((String)vEduHist.elementAt(x+1)," (Major in ",")","");
			}		
			%>
			<%if(bolShowEducation){%><td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><%}%>
			
			<%
			iCount = 0;
			strTemp = null;
			for(int x=0; x < vLicenseList.size(); x+=2){
				if(strTemp == null)
					strTemp = (++iCount)+".) "+(String)vLicenseList.elementAt(x)+WI.getStrValue((String)vLicenseList.elementAt(x+1)," - ","","");
				else
					strTemp += "<br>"+ (++iCount)+".) "+(String)vLicenseList.elementAt(x)+WI.getStrValue((String)vLicenseList.elementAt(x+1)," - ","","");
			}		
			%>
			<%if(bolShowLicense){%><td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><%}%>
			
			
			<%
			strTemp = WI.getStrValue(vRetResult.elementAt(i+23));			
			%>
			<td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
			iCount = 0;
			strTemp = null;
			for(int x=0; x < vTraining.size(); x+=4){
				if(strTemp == null)
					strTemp = (++iCount)+".) "+(String)vTraining.elementAt(x)+
						WI.getStrValue((String)vTraining.elementAt(x+1))+
						WI.getStrValue((String)vTraining.elementAt(x+2)," to ","","")+
						WI.getStrValue((String)vTraining.elementAt(x+3));
				else
					strTemp += "<br>"+ (++iCount)+".) "+(String)vTraining.elementAt(x)+
						WI.getStrValue((String)vTraining.elementAt(x+1))+
						WI.getStrValue((String)vTraining.elementAt(x+2)," to ","","")+
						WI.getStrValue((String)vTraining.elementAt(x+3));
			}		
			%>
			<%if(bolShowSeminar){%><td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><%}%>
		</tr>
	<%}%>
</table>
<script>window.print();</script>
<%}%>
</body>
</html>
<%
	dbOP.cleanUP();
%>
