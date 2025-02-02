<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*, osaGuidance.GDCounseling, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;

	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String[] astrSemester = {"SU", "FS", "SS", "TS"};

	
//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Guidance & Counseling","Counseling Cases",request.getRemoteAddr(),
														"search_counseling_cases_print.jsp");
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

int iSearchResult = 0;
GDCounseling GDCounsel = new GDCounseling();

	vRetResult = GDCounsel.searchCounselingCase(dbOP, request);
	if(vRetResult == null)
		strErrMsg = GDCounsel.getErrMsg();
	else	
		iSearchResult = GDCounsel.getSearchCount();

if(strErrMsg != null) {%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="2">
    <tr> 
      <td colspan="4" height="20"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
<%}%>
  
<%if(vRetResult!=null && vRetResult.size()>0){
boolean bolShowBkgStudy   = false;
boolean bolShowDifficulty = false;
boolean bolShowPresentCon = false;
boolean bolShowConclusion = false;

if(WI.fillTextValue("show3").length() > 0) 
	bolShowBkgStudy   = true;
if(WI.fillTextValue("show4").length() > 0) 
	bolShowDifficulty   = true;
if(WI.fillTextValue("show5").length() > 0) 
	bolShowPresentCon   = true;
if(WI.fillTextValue("show6").length() > 0) 
	bolShowConclusion   = true;
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td align="center" class="thinborderBOTTOM"><strong> COUNSELING REPORT </strong></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td align="right" style="font-size:9px;" height='25' valign="bottom"> Date and Time Printed: <%=WI.getTodaysDateTime()%></td>
    </tr>
  </table>  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF"  class="thinborder">
    <tr> 
    <td width="4%" class="thinborder"><div align="center"><font size="1"><strong>SY/TERM</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>STUDENT ID</strong></font></div></td>
      <td width="12%" height="25" class="thinborder"><div align="center"><font size="1"><strong>STUDENT NAME </strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>COURSE/MAJOR</strong></font></div></td>
      <td width="5%" class="thinborder"><div align="center"><font size="1"><strong>GENDER</strong></font></div></td>
      <td width="8%" class="thinborder"><div align="center"><font size="1"><strong>COUNSELED DATE</strong></font></div></td>
      <td width="12%" class="thinborder"><div align="center"><strong><font size="1"><strong>COUNSELED BY</strong></font></strong></div></td>
<%if(bolShowBkgStudy){%>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1"><strong>BACKGROUP OF STUDY</strong></font></strong></div></td>
<%}if(bolShowDifficulty){%>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1"><strong>DIFFICULTY</strong></font></strong></div></td>
<%}if(bolShowPresentCon){%>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1"><strong>PRESENT CONDITION</strong></font></strong></div></td>
<%}if(bolShowConclusion){%>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1"><strong>CONCLUSION</strong></font></strong></div></td>
<%}%>
      </tr>
    <%for (int i = 0; i<vRetResult.size(); i+=23){%>
    <tr> 
     <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+5)%>-<%=((String)vRetResult.elementAt(i+6)).substring(2)%>&nbsp;<%=astrSemester[Integer.parseInt((String)vRetResult.elementAt(i+7))]%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td height="20" class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),7)%></font></td>
      <td class="thinborder"><font size="1">
      <%=WI.getStrValue((String)vRetResult.elementAt(i+10),((String)vRetResult.elementAt(i+9)) + "/","",(String)vRetResult.elementAt(i+9))%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i+8), "-", "","")%>
	  </font></td>
      <td class="thinborder"><div align="center"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+11), "&nbsp;")%></font></div></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+12), "&nbsp;")%></font></td>
      <td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+13), (String)vRetResult.elementAt(i+14), (String)vRetResult.elementAt(i+15),7)%></font></td>
<%if(bolShowBkgStudy){%>
	      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+17), "&nbsp;")%></font></td>
<%}if(bolShowDifficulty){%>
	      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+19), "&nbsp;")%></font></td>
<%}if(bolShowPresentCon){%>
	      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+18), "&nbsp;")%></font></td>
<%}if(bolShowConclusion){%>
	      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+20), "&nbsp;")%></font></td>
<%}%>
      </tr>
    <%}%>
  </table>
<%}%>

</body>
</html>
<%
dbOP.cleanUP();
%>
