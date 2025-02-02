<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<body onLoad="window.print();">
<%@ page language="java" import="utility.*,search.SearchEmployee,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	
	Vector vRetResult = null;
	
	boolean bolIsSchool = (new CommonUtil().getIsSchool(null)).equals("1");
	


	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-Employees","srch_emp.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
	// allow search employee only if the user is not a student / parent. 
	strTemp = (String)request.getSession(false).getAttribute("userId");
	if(strTemp == null)
		strErrMsg = "You are already logged out. Please login again.";
	else {
		strTemp = dbOP.mapOneToOther("user_table","id_number","'"+strTemp+"'","AUTH_TYPE_INDEX"," and is_valid = 1 and is_del = 0");
		if(strTemp == null || strTemp.compareTo("4") ==0 || strTemp.compareTo("6") ==0)//student or parent or not having any access
			strErrMsg = "You are not authorized to view Employee search page.";		
	}
	if(strErrMsg != null) {
		dbOP.cleanUP();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
			

//end of authenticaion code.
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrDropListGT = {"Equal to","Less than","More than"};
String[] astrDropListValGT = {"=","greater","less"};
String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Tenureship","Salary","Emp. Status","Emp. Type","D.O.B"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","doe","SALARY_AMT","user_status.status",
								"HR_EMPLOYMENT_TYPE.EMP_TYPE_NAME","dob"};
String[] astrDropListBetween = {"Between","Equal to","Less than","More than"};
String[] astrDropListValBetween = {"BETWEEN","=","greater","less"};//check for between
String[] astrDropListValBetweenAGE = {"BETWEEN","=","less","greater"};//for age, less than and greater than is swapped.

String[] astrMonthList     = {"January","February","March","April","May","June","July","August","September","October","November","December"};
String[] astrMonthListVal  = {"1","2","3","4","5","6","7","8","9","10","11","12"};
int iSearchResult = 0;

SearchEmployee searchEmp = new SearchEmployee(request);
if(WI.fillTextValue("searchEmployee").compareTo("1") == 0){
	vRetResult = searchEmp.searchGeneric(dbOP);
	if(vRetResult == null)
		strErrMsg = searchEmp.getErrMsg();
	else	
		iSearchResult = searchEmp.getSearchCount();
}

%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr bgcolor="#A49A6A"> 
    <td height="25" colspan="2" bgcolor="#FFFFFF"><div align="center"> <font size="2"> 
        <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></div></td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td height="10" colspan="2" bgcolor="#FFFFFF"><div align="center"></div></td>
  </tr>
  <tr bgcolor="#FFFFFF"> 
    <td width="48%" height="25" bgcolor="#FFFFFF"><font size="2">&nbsp;</font></td>
    <td width="52%" height="25" bgcolor="#FFFFFF"><div align="right"><font size="1">&nbsp;Date 
        and time printed: <%=WI.getTodaysDateTime()%></font></div></td>
  </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td height="25" colspan="4" bgcolor="#CCCCCC"><div align="center"><strong>:::: 
          SEARCH EMPLOYEE PAGE ::::</strong></div></td>
    </tr>
	</table>

  <%
if(vRetResult != null && vRetResult.size() > 0){%>
  
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td width="66%" ><b> TOTAL RESULT: <%=iSearchResult%></b></td>
  </tr>
</table>

  
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr> 
    <td  width="13%" height="25" class="thinborder"><div align="center"><strong><font size="1">EMPLOYEE 
        ID</font></strong></div></td>
    <td width="24%" class="thinborder"><div align="center"><strong><font size="1">NAME (LNAME,FNAME 
        MI) </font></strong></div></td>
    <td width="5%" class="thinborder"><div align="center"><strong><font size="1">GENDER</font></strong></div></td>
    <td width="10%" class="thinborder"><div align="center"><strong><font size="1">EMPLOYMENT STATUS</font></strong></div></td>
    <td width="9%" class="thinborder"><div align="center"><strong><font size="1">EMPLOYMENT TYPE</font></strong></div></td>
    <td width="30%" class="thinborder"><div align="center"><strong><font size="1"><%if (bolIsSchool){%>COLLEGE<%}else{%>DIVISION<%}%>/ OFFICE</font></strong></div></td>
    <%
if(WI.fillTextValue("show_dob").compareTo("1") ==0){%>
    <td width="5%" class="thinborder"><div align="center"><strong><font size="1">DOB</font></strong></div></td>
    <%}if(WI.fillTextValue("show_b_month").compareTo("1") ==0){%>
    <td width="5%" class="thinborder"><div align="center"><strong><font size="1">BIRTH MONTH</font></strong></div></td>
    <%}if(WI.fillTextValue("show_age").compareTo("1") ==0){%>
    <td width="5%" class="thinborder"><div align="center"><strong><font size="1">AGE</font></strong></div></td>
    <%}if(WI.fillTextValue("show_tenur").compareTo("1") ==0){%>
    <td width="5%" class="thinborder"><div align="center"><strong><font size="1">DOE</font></strong></div></td>
    <%}if(WI.fillTextValue("show_salary").compareTo("1") ==0){%>
    <td width="5%" class="thinborder"><div align="center"><strong><font size="1">SALARY</font></strong></div></td>
    <%}%>
  </tr>
  <%
for(int i = 0 ; i < vRetResult.size(); i +=13){%>
  <tr> 
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
    <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 2)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 3)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 4)%></td>
    <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%></td>
    <td class="thinborder">&nbsp;<% if(vRetResult.elementAt(i + 6) != null) {//outer loop.
	  		if(vRetResult.elementAt(i + 7) != null) {//inner loop.%> <%=(String)vRetResult.elementAt(i + 6)%>/<%=(String)vRetResult.elementAt(i + 7)%> <%}else{%> <%=(String)vRetResult.elementAt(i + 6)%> <%}//end of inner loop/
	  }else if(vRetResult.elementAt(i + 7) != null){//outer loop else%> <%=(String)vRetResult.elementAt(i + 7)%> <%}%> </td>
    <%
if(WI.fillTextValue("show_dob").compareTo("1") ==0){%>
    <td width="5%" class="thinborder"> <div align="center"><%=(String)vRetResult.elementAt(i + 8)%></div></td>
    <%}if(WI.fillTextValue("show_b_month").compareTo("1") ==0){%>
    <td width="5%" class="thinborder"> <div align="center"><%=(String)vRetResult.elementAt(i + 9)%></div></td>
    <%}if(WI.fillTextValue("show_age").compareTo("1") ==0){%>
    <td width="5%" class="thinborder"> <div align="center"><%=(String)vRetResult.elementAt(i + 10)%></div></td>
    <%}if(WI.fillTextValue("show_tenur").compareTo("1") ==0){%>
    <td width="5%" class="thinborder"> <div align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 11))%></div></td>
    <%}if(WI.fillTextValue("show_salary").compareTo("1") ==0){%>
    <td width="5%" class="thinborder"> <div align="center"><%=WI.getStrValue(vRetResult.elementAt(i + 12),"&nbsp;")%></div></td>
    <%}%>
  </tr>
  <%}//end of for loop to display employee information.%>
</table>
  <%}//only if vRetResult not null
%>
</body>
</html>
<%
dbOP.cleanUP();
%>