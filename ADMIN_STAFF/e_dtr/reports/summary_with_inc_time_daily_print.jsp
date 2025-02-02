<%@ page language="java" import="utility.*,eDTR.ReportEDTRExtn,java.util.Vector, java.util.Calendar" %>
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
<title>Employees with deductibles</title>
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
TD.thinborder {
	border-left: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
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
								"Admin/staff-eDaily Time Record-Reports & Statistics-Summary Emp Incomplete Work","summary_with_inc_time_daily.jsp");
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
														"summary_with_inc_time_daily.jsp");	
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
String[] astrAMPM = {"AM","PM"};

String strMonths = WI.fillTextValue("strMonth");
if(strMonths.length() == 0){
	Calendar calendar = Calendar.getInstance();
	strMonths = Integer.toString(calendar.get(Calendar.MONTH) + 1);
}
if(bolIsSchool)
	strTemp = "College";
else
	strTemp = "Division";
String[] astrSortByName    = {"ID #","Lastname","Firstname", strTemp, "Department","Login Time"};
String[] astrSortByVal     = {"id_number","lname","fname","c_name","d_name", "time_in"};

int iSearchResult = 0;
int i = 0;
int iCount = 0;
long lTime = 0l;
String strCurDate = null;
String strPrevDate = null;
Vector vEmployeeWH = null;

ReportEDTRExtn rDExtn = new ReportEDTRExtn(request);
vRetResult = rDExtn.searchEmpOffensesDaily(dbOP, strSchCode);
boolean bolPageBreak = false;
	if (vRetResult != null) {	
 		int iPage = 1; 
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;

		int iTotalPages = (vRetResult.size())/(25*iMaxRecPerPage);	
		if((vRetResult.size() % (25*iMaxRecPerPage)) > 0) ++iTotalPages;

	for (;iNumRec < vRetResult.size();iPage++){	
		strPrevDate = null;
%>
<form  name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr>
      <td width="74%" height="22" >&nbsp;<strong><%=WI.fillTextValue("report_title")%></strong></td>
      <td width="26%" align="right" >Page <%=iPage%> of <%=iTotalPages%></td>
    </tr>
  </table>

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <%
 		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=25,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			

			strCurDate = (String)vRetResult.elementAt(i+4);
			vEmployeeWH = (Vector)vRetResult.elementAt(i+9);
			//vEmpInfo = (Vector)vRetResult.elementAt(i+9);
			if(strPrevDate == null || !strCurDate.equals(strPrevDate)){
			//System.out.println("strCurDate " + strCurDate);
			//System.out.println("strPrevDate " + strPrevDate);
		%>		
    <tr>
      <td height="25" colspan="6"  class="thinborder"><strong>&nbsp;DATE : <%=strCurDate%></strong></td>
    </tr>
    <tr>
      <td width="23%" align="center" class="thinborder">&nbsp;</td>
      <td width="27%" height="25" align="center" class="thinborder">SCHEDULE</td>
      <td width="25%" align="center" class="thinborder">DTR ENTRIES </td>
      <td width="8%" align="center" class="thinborder">LATE</td>
      <td width="9%" align="center" class="thinborder">UNDERTIME</td>
      <td width="8%" align="center" class="thinborder">HOURS WORK </td>
    </tr>
		<%}%>
    <tr>
			<%
				strTemp = WebInterface.formatName((String)vRetResult.elementAt(i + 11),
								  (String)vRetResult.elementAt(i + 12),(String)vRetResult.elementAt(i + 13), 4);
									
			//if(vEmpInfo != null){
			//	strTemp = WebInterface.formatName((String)vEmpInfo.elementAt(1),
			//					  (String)vEmpInfo.elementAt(2),(String)vEmpInfo.elementAt(3),4);
			//}
			
			%>
      <td class="thinborder">&nbsp;<strong><%=strTemp%></strong></td>
		<% 	
			if(vEmployeeWH != null && vEmployeeWH.size() > 0) {
				strTemp = (String)vEmployeeWH.elementAt(3) +  ":"  + 
				CommonUtil.formatMinute((String)vEmployeeWH.elementAt(4)) + " " +
				astrAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(5))] + " - " + (String)vEmployeeWH.elementAt(6)  +
				":"  + CommonUtil.formatMinute((String)vEmployeeWH.elementAt(7))  + " " + 
				astrAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(8))];
				
				if ((String)vEmployeeWH.elementAt(12) != null)
				strTemp += " / " + (String)vEmployeeWH.elementAt(12) +  ":" + 
				CommonUtil.formatMinute((String)vEmployeeWH.elementAt(13)) +
				" " + astrAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(14))] + " - " + 
				(String)vEmployeeWH.elementAt(15) + ":"  + 
				CommonUtil.formatMinute((String)vEmployeeWH.elementAt(16)) +  " " + 
				astrAMPM[Integer.parseInt((String)vEmployeeWH.elementAt(17))];
						 
					if (((String)vEmployeeWH.elementAt(9)).equals("1"))
						strTemp +="(next day)";
			}else{
				strTemp = "&nbsp;";
			}
		%>		
      <td height="25" class="thinborder">&nbsp;<%=WI.getStrValue(strTemp, "No Schedule")%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i + 2);				
				lTime = Long.parseLong(strTemp);
				if(lTime > 0l)
					strTemp = WI.formatDateTime(lTime, 2);
				else
					strTemp = "";
				
				
				strTemp2 = (String)vRetResult.elementAt(i + 3);				
				lTime = Long.parseLong(strTemp2);
				if(lTime > 0l)
					strTemp2 = WI.formatDateTime(lTime, 2);
				else
					strTemp2 = "";				

				strTemp2 = WI.getStrValue(strTemp2, "&nbsp;");
				strTemp = WI.getStrValue(strTemp, "", " - " + strTemp2, "absent");
			%>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
			<%
				strTemp = (String)vRetResult.elementAt(i + 7);
			%>
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i + 8);
			%>			
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
			<%
				strTemp = (String)vRetResult.elementAt(i + 6);
			%>				
      <td align="right" class="thinborder"><%=WI.getStrValue(strTemp)%>&nbsp;</td>
    </tr>				
 		<%
			strPrevDate = strCurDate;
		}//end of outer for loop to display employee information.%>
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