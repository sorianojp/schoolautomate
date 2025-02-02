<%@ page language="java" import="utility.*,hr.HRInfoLeave,java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employee With Leaves</title>
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

	.fontsize11{
		font-size : 11px;
	}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script> 
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
 
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strPrevIndex = "";
	boolean bolSameUser = false;
	boolean bolHasTeam = false;
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Reports & Statistics-Summary Emp with Leaves","hr_emp_leaves.jsp");
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
														"HR Management","LEAVE APPLICATION",request.getRemoteAddr(),
														"hr_emp_leaves.jsp");	
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
String strSchName  = SchoolInformation.getSchoolName(dbOP,true,false);
String strAddr1    = SchoolInformation.getAddressLine1(dbOP,false,false);
String strAddr2    = SchoolInformation.getAddressLine2(dbOP,false,false);
String strDateTime = WI.getTodaysDateTime();
String strTitle    = "Summary of Leaves";
if(WI.fillTextValue("strMonth").length() > 0) {
	String[] astrConvetMonth = {"","January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"};
	strTitle += " for " + astrConvetMonth[Integer.parseInt(WI.fillTextValue("strMonth"))]+", "+WI.fillTextValue("year_of");

}
else if(WI.fillTextValue("date_fr").length() > 0) {
	if(WI.fillTextValue("date_to").length() > 0)
		strTitle += " for Duration " + WI.fillTextValue("date_fr")+" to "+ WI.fillTextValue("date_to");
	else
		strTitle += " for Date " + WI.fillTextValue("date_fr");
}	

HRInfoLeave hrLeave = new HRInfoLeave();
vRetResult = hrLeave.viewAppliedLeaves(dbOP, request);
int i = 0; 
int iPageNo = 0;
boolean bolPageBreak = false;
	if (vRetResult != null) {	
		int j = 0; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td align="center"><font size="2"><strong><%=strSchName%></strong></font><br>
		   <font size="1">
				<%=strAddr1%><br><%=strAddr2%><br><strong><%=strTitle%></strong>
				<div align="right">
					Date and Time Printed: <%=strDateTime%> &nbsp;&nbsp; &nbsp; &nbsp; Page# <%=++iPageNo%> <!--of <%//=iTotalPages%>-->
				</div>
		   </font></td>
	  </tr>
  </table>

    <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr>
      <td  width="7%" height="25" align="center"  class="thinborder"><strong><font size="1">ID No. </font></strong></td>
      <td width="20%" align="center" class="thinborder"><strong><font size="1">Employee Name</font></strong></td>
      <td width="13%" align="center" class="thinborder"><strong><font size="1">Dept/Office</font></strong></td>
      <td width="18%" align="center" class="thinborder"><strong><font size="1">Reason</font></strong></td>
      <td width="18%" align="center" class="thinborder"><strong><font size="1">Leave Type</font></strong></td>
      <td width="12%" align="center" class="thinborder"><strong><font size="1">Leave Date</font></strong></td>
      <td width="5%" align="center" class="thinborder" style="font-weight:bold; font-size:9px;">Duration</td>
      <td  width="7%" align="center"  class="thinborder"><font size="1"><strong>Date 
      Filed</strong></font></td> 
    </tr>
    <% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=35,++iIncr, ++iCount){
			i = iNumRec;
			bolSameUser = false;
			if(strPrevIndex.equals((String)vRetResult.elementAt(i+1)))
				bolSameUser = true;		
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			
		%>	
    <tr>      
			<%
				if(bolSameUser)
					strTemp = "&nbsp;";
				else
					strTemp = (String)vRetResult.elementAt(i+2);
			%>
      <td height="25" class="thinborder" style="font-size:9px;">&nbsp;<%=strTemp%></td>
			<%
				if(bolSameUser)
					strTemp = "&nbsp;";
				else
					strTemp = WI.formatName((String)vRetResult.elementAt(i + 3),
																  (String)vRetResult.elementAt(i + 4),
																	(String)vRetResult.elementAt(i + 5),4);
			%>			
      <td class="thinborder" style="font-size:9px;">&nbsp;<%=strTemp%></td>
			<%
				if(bolSameUser)
					strTemp = "&nbsp;";
				else{
					if(vRetResult.elementAt(i + 9) != null) {//outer loop.
						if(vRetResult.elementAt(i + 10) != null) {//inner loop.
							strTemp = (String)vRetResult.elementAt(i + 9) + "/" + (String)vRetResult.elementAt(i + 10);
						}else{
							strTemp = (String)vRetResult.elementAt(i + 9);
						}
					
					}else if(vRetResult.elementAt(i + 10) != null){
						strTemp = (String)vRetResult.elementAt(i + 10);		
					}
				}
 			%>			
      <td class="thinborder" style="font-size:9px;"><%=strTemp%></td>			
      <td class="thinborder" style="font-size:9px;"><%=(String)vRetResult.elementAt(i + 19)%></td>
      <td class="thinborder" style="font-size:9px;"><%=(String)vRetResult.elementAt(i + 13)%> </td>
	  <%
	  	if(((String)vRetResult.elementAt(i + 11)).equals((String)vRetResult.elementAt(i + 12)))
		  strTemp = (String)vRetResult.elementAt(i + 11);		  
		else
		  strTemp = (String)vRetResult.elementAt(i + 11)+WI.getStrValue((String)vRetResult.elementAt(i + 12),"-","","");

		strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i+20));
		strTemp3 =CommonUtil.formatFloat((String)vRetResult.elementAt(i+16), false);	
		
		if(strTemp2.equals("1"))
		  strTemp3 += " hr(s)";
		else
			strTemp3 += " day(s)";
		
//		strTemp2 =CommonUtil.formatFloat((String)vRetResult.elementAt(i+16), false);	
//		if (!strTemp2.equals("0"))
//			strTemp3 += strTemp2 + " day(s)";
	  %>	  
	  <td class="thinborder" style="font-size:9px;"><%=strTemp%></td>
		<td class="thinborder" style="font-size:9px;"><%=WI.getStrValue(strTemp3)%></td>
		<td class="thinborder" style="font-size:9px;"><%=(String)vRetResult.elementAt(i + 18)%></td> 
    </tr>
    <%
			strPrevIndex = (String)vRetResult.elementAt(i + 1);
		}//end of for loop to display employee information.%>
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