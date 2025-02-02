<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee Without Finger Data</title>
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
<body>
<%@ page language="java" import="utility.*,search.EmpFingerInfo,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	int iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_emp_page"));
	int i = 0;
	boolean bolPageBreak = false;
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-SEARCH-Employees","ssrch_emp_finger_data.jsp");
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

EmpFingerInfo empFinger = new EmpFingerInfo (request);
if(WI.fillTextValue("searchEmployee").compareTo("1") == 0){
	vRetResult = empFinger.operateOnViewEmpFingerInfo (dbOP);
	if(vRetResult == null)
		strErrMsg = empFinger.getErrMsg();
	else	
		iSearchResult = empFinger.getSearchCount();
}

if(vRetResult != null && vRetResult.size() > 0){
	for(;i< vRetResult.size();){


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
        SEARCH EMPLOYEE WITHOUT FINGER DATA PAGE ::::</strong></div></td>
    </tr>
	</table>

  
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
    </tr>
	<% 
 	for(int iCount = 0; iCount <= iMaxStudPerPage; i += 18,++iCount){
  		if (iCount >= iMaxStudPerPage || i >= vRetResult.size()){
			if(i >= vRetResult.size())
				bolPageBreak = false;
			else
				bolPageBreak = true;
			break;			
	 }%>
	
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td height="25" class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i + 2) ,(String)vRetResult.elementAt(i + 3) , (String)vRetResult.elementAt(i + 4),4)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 17)%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 11)%></td>
      <td class="thinborder">
	  <% if(vRetResult.elementAt(i + 9) != null) {
	  		//outer loop.
		  if(vRetResult.elementAt(i + 10) != null) {//inner loop.%>
		     <%=(String)vRetResult.elementAt(i + 9)%>/<%=(String)vRetResult.elementAt(i + 10)%> 
     		<%}else{%> 
	    	<%=(String)vRetResult.elementAt(i + 9)%> <%}//end of inner loop/
	  }else if(vRetResult.elementAt(i + 10) != null){//outer loop else%> 
	  <%=(String)vRetResult.elementAt(i + 10)%>  
	  <%}else{%>
	  &nbsp;
	  <%}%>
	  </td>
	  </tr>
    <%}//end of for loop to display employee information.%>
</table>
  
 <% if (i >= vRetResult.size()){	
   %> 
<table width="100%" height="30" border="0" cellpadding="1" cellspacing="0">
  <tr>
    <td><div align="center">*****************NOTHING FOLLOWS *******************</div></td>
  </tr>
   <%}else{%>    
  <tr> 
    <td><div align="center">************** CONTINUED ON NEXT PAGE ****************</div></td>
  </tr>
  <%}%>
</table>
<%
//INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
    if (bolPageBreak) {%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break only if it is not last page.
  }}%>

  <script language="JavaScript">
window.print();
</script>
</p>
</body>
</html>
<%
dbOP.cleanUP();
%>