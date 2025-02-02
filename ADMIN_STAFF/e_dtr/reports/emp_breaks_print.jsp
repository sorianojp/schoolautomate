<%@ page language="java" import="utility.*,eDTR.ReportEDTRExtn,java.util.Vector" %>
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
<title>Search Employee</title>
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
								"Admin/staff-eDaily Time Record-Reports & Statistics - Summary Emp with Absent","emp_breaks.jsp");
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
														"emp_breaks.jsp");	
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
 
int iSearchResult = 0;

ReportEDTRExtn rptExtn = new ReportEDTRExtn(request);
String strCurDate = null;
boolean bolPageBreak = false;;

	vRetResult = rptExtn.generateEmployeeBreaks(dbOP, request);
	if (vRetResult != null) {	
		int j = 0; 
		int i = 0;
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr = 1;
		
		for (;iNumRec < vRetResult.size();){	
			strCurDate = null;
%>
<form name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    
    <tr>
      <td width="34%" align="center"><strong>SUMMARY OF EMPLOYEE BREAKS </strong></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="12%" height="25" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
          ID</font></strong></td>
      <td width="32%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
          NAME </font></strong></td>
      <td width="31%" align="center" class="thinborder"><strong><font size="1">DEPT/ 
          OFFICE</font></strong></td>
      <td width="17%" align="center" class="thinborder"><strong><font size="1">POSITION</font></strong></td>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">BREAK <br>
      (in min)</font></strong></td>
    </tr>
    <%
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=20,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;
				
		 if(strCurDate == null || !((String)vRetResult.elementAt(i + 11)).equals(strCurDate)){
			strCurDate = (String)vRetResult.elementAt(i + 11);
	 %>		
    <tr>
      <td height="25" colspan="5" class="thinborder"><strong>DATE : <%=strCurDate%></strong></td>
    </tr>
			<%}%>
    <tr> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>
      <td class="thinborder">&nbsp;
        <% 
	  	strTemp = "";
	  	if(vRetResult.elementAt(i + 7) != null) {
	  		if(vRetResult.elementAt(i + 8) != null) {
				strTemp = (String)vRetResult.elementAt(i + 7) + " / "  + (String)vRetResult.elementAt(i + 8);
			}else{
				strTemp = (String)vRetResult.elementAt(i + 7);
			}//end of inner loop/
	     }else 
	 		if(vRetResult.elementAt(i + 8) != null){ 
				strTemp = (String)vRetResult.elementAt(i + 8);
			}
	  %>
        <%=strTemp%> </td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 6)%></td>
      <td align="center" class="thinborder"> <%=(String)vRetResult.elementAt(i + 12)%></td>
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