<%@ page language="java" import="utility.*,eDTR.ReportEDTR,java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employees with absences</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
<style>
	.fontsize11{
		font-size : 11px;
	}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print()">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	
	Vector vRetResult = null;
	boolean bolHasTeam = false;
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Reports & Statistics - Summary Emp with Absent","summary_emp_with_awol.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"summary_emp_with_awol.jsp");	
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
String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"ID #","Lastname","Firstname","Gender","Emp. Status","Emp. Type"};
String[] astrSortByVal     = {"id_number","lname","fname","gender","user_status.status","HR_EMPLOYMENT_TYPE.EMP_TYPE_NAME","c_name","d_name"};

int iSearchResult = 0;

ReportEDTR rD = new ReportEDTR(request);
	vRetResult = rD.viewEmployeesAbsences(dbOP, request);
	if(vRetResult == null)
		strErrMsg = rD.getErrMsg();
	else
		iSearchResult = rD.getSearchCount();
String[] astrMonth = {" Select Month"," January"," February", " March", " April", " May", " June",
					  " July", " August", " September"," October", " November", " December"};
%>
<form>
  <% if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td height="25" colspan="7"  class="thinborder"><b>TOTAL RESULT: <%=iSearchResult%></b></td>
    </tr>
    <tr> 
      <td  width="14%" height="25" align="center"  class="thinborder"><strong><font size="1">EMPLOYEE 
      ID</font></strong></td>
      <td width="27%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
      NAME </font></strong></td>
<% if (!strSchCode.startsWith("AUF")) {%>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">GENDER</font></strong></td>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">EMP. 
      TYPE</font></strong></td>
<%}%>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">EMP. 
      STATUS</font></strong></td>
      <td width="17%" align="center" class="thinborder"><strong><font size="1">DEPT/ 
      OFFICE</font></strong></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">TOTAL 
      ABSENCES </font></strong></div></td>
    </tr>
    <%
	String[] astrConvertGender = {"M","F"};
for(int i = 0 ; i < vRetResult.size(); i +=12){
	if (((String)vRetResult.elementAt(i + 11)).compareTo("0") ==0) continue;
%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
<% if (!strSchCode.startsWith("AUF")) {%>
      <td class="thinborder">&nbsp;<%=astrConvertGender[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 7)%></td>
<%}%>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></td>
      <td class="thinborder"> &nbsp; 
        <% if(vRetResult.elementAt(i + 8) != null) {//outer loop.
	  		if(vRetResult.elementAt(i + 9) != null) {//inner loop.%> <%=(String)vRetResult.elementAt(i + 8)%>/<%=(String)vRetResult.elementAt(i + 9)%> <%}else{%> <%=(String)vRetResult.elementAt(i + 8)%> <%}//end of inner loop/
	  }else if(vRetResult.elementAt(i + 9) != null){//outer loop else%> <%=(String)vRetResult.elementAt(i + 9)%> <%}%> </td>
      <td align="center" class="thinborder"> <%=(String)vRetResult.elementAt(i + 11)%></td>
    </tr>
    <%}//end of for loop to display employee information.%>
  </table>
   <%}//only if vRetResult not null%>
	 
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>