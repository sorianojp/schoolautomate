<%@ page language="java" import="utility.*,eDTR.ReportEDTR,java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Employee</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize11{
		font-size : 11px;
	}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Reports & Statistics - Summary Emp with Absent","summary_emp_leaves.jsp");
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
														"summary_emp_leaves.jsp");	
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
	String[] astrConvertGender = {"M","F"};
	String strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");;
	String strSYTo = (String)request.getSession(false).getAttribute("cur_sch_yr_to");

int iSearchResult = 0;
boolean bolPageBreak = false;

ReportEDTR rD = new ReportEDTR(request);
String[] astrMonth = {" Select Month"," January"," February", " March", " April", " May", " June",
					  " July", " August", " September"," October", " November", " December"};
  vRetResult = rD.viewLeavesSummary(dbOP, request);
	if (vRetResult != null) {	
		int iCount = 0;
		int i = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){
%>
<form>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
  <%
	  if(!WI.fillTextValue("strMonth").equals("0"))
			strTemp = " for month of " + astrMonth[Integer.parseInt(WI.getStrValue(WI.fillTextValue("strMonth"),"0"))] + " " + WI.fillTextValue("year_of");
		else
			strTemp = " between " + WI.fillTextValue("date_fr") + " and " + WI.fillTextValue("date_to");
	%>
    <td align="center"><strong>Employee leaves <%=strTemp%></strong></td>
    </tr>
</table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="9%" height="25" align="center"  class="thinborder"><strong><font size="1">EMPLOYEE 
      ID</font></strong></td>
      <td width="27%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
      NAME </font></strong></td>
	<!--
	<% if (!strSchCode.startsWith("AUF")) {%>
      <td width="13%" align="center" class="thinborder"><strong><font size="1">EMP. 
      TYPE</font></strong></td>
	<%}%>
	-->

      <td width="19%" align="center" class="thinborder"><strong><font size="1">DEPT/ 
      OFFICE</font></strong></td>
      <td width="18%" align="center" class="thinborder"><strong>Leave Type</strong></td>
      <td width="17%" align="center" class="thinborder"><strong>Leave Date </strong></td>
    </tr>
    <%
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=20,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			
		%>		
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 3),
	  (String)vRetResult.elementAt(i + 4),(String)vRetResult.elementAt(i + 5),4)%></td>
	  <!--
	  <% if (!strSchCode.startsWith("AUF")) {%>
      <td class="thinborder">&nbsp;<%//=(String)vRetResult.elementAt(i + 8)%><br>
      &nbsp;(<%//=(String)vRetResult.elementAt(i + 7)%>)</td>
	  <%}%>
	  -->
      <td class="thinborder"><% if(vRetResult.elementAt(i + 9) != null) {//outer loop.
	  		if(vRetResult.elementAt(i + 10) != null) {//inner loop.%>
        <%=(String)vRetResult.elementAt(i + 9)%>/<%=(String)vRetResult.elementAt(i + 10)%>
        <%}else{%>
        <%=(String)vRetResult.elementAt(i + 9)%>
        <%}//end of inner loop/
	  }else if(vRetResult.elementAt(i + 10) != null){//outer loop else%>
        <%=(String)vRetResult.elementAt(i + 10)%>
      <%}%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 13)%> </td>
	  <%
	  	if(((String)vRetResult.elementAt(i + 11)).equals((String)vRetResult.elementAt(i + 12)))
		  strTemp = (String)vRetResult.elementAt(i + 11);		  
		else
		  strTemp = (String)vRetResult.elementAt(i + 11)+WI.getStrValue((String)vRetResult.elementAt(i + 12),"-","","");	

		strTemp3 = CommonUtil.formatFloat((String)vRetResult.elementAt(i+16), false);	
		if(WI.getStrValue((String)vRetResult.elementAt(i+18)).equals("1"))
			strTemp3 += " hr(s)";
		else
			strTemp3 += " day(s)";		
	  %>	  
	  <td class="thinborder"><%=strTemp%><br><%=WI.getStrValue(strTemp3)%></td>
    </tr>
    <%}//end of for loop to display employee information.%>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>