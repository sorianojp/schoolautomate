<%@ page language="java" import="utility.*, osaGuidance.*, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript"  src ="../../../jscript/td.js"></script>
</head>
<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("GUIDANCE & COUNSELING"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	

	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS","create_tests_schedules.jsp");
	
	Vector vRetResult = null;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;
	int iTemp = 0;
	int iSearchResult = 0;
	String [] astrConvTime={" AM"," PM"};

	GDPsychologicalTest PsychTest = new GDPsychologicalTest();

	vRetResult = PsychTest.operateOnPsyTestSched(dbOP, request, 4);
	if (vRetResult == null)
		strErrMsg = PsychTest.getErrMsg();
	else
		iSearchResult = PsychTest.getSearchCount();
		
%>
<body>
  	<%if (vRetResult!=null && vRetResult.size()>0){%>
	
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
		<td align="center"><font style="font-size:14px;"><strong><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong></font><br>
		<font style="font-size:12px;"><%=SchoolInformation.getAddressLine1(dbOP, false, false)%></font>
		<br><br>
		</td>
	</tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td  height="25" colspan="8" class="thinborder" align="center" bgcolor="#DADADA"><strong>LIST 
          OF PSYCHOLOGICAL TESTS SCHEDULES FOR : SY <%=WI.fillTextValue("sy_from") + " - "+WI.fillTextValue("sy_to")+
			WI.getStrValue((dbOP.getHETerm(Integer.parseInt(WI.getStrValue(request.getParameter("semester"),"-1"))).toUpperCase()),", ","","")%></strong></font></td>
    </tr>
    <tr> 
      <td width="11%" class="thinborder"><div align="center"><font size="1"><strong>SCHEDULE CODE</strong></font></div></td>
      <td width="24%" height="28" class="thinborder"><div align="center"><font size="1"><strong>TEST 
          NAME </strong></font></div></td>
      <td width="15%" class="thinborder"><div align="center"><font size="1"><strong>ADMINISTERED 
          BY </strong></font></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong><font size="1">DATE GIVEN</font></strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><font size="1"><strong>TIME <font size="1"> 
          GIVEN</font></strong></font></div></td>
      <td width="9%" class="thinborder"><div align="center"><strong><font size="1">DURATION</font></strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong><font size="1">VENUE</font></strong></div></td>
    </tr>
    <%for (i= 0; i<vRetResult.size(); i+=19){%>
    <tr> 
      <td height="26" class="thinborder"><font size="1"><%=((String)vRetResult.elementAt(i+6))%></font></td>
      <td class="thinborder"><font size="1"><%=((String)vRetResult.elementAt(i+5))%></font></td>
      <td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+15),(String)vRetResult.elementAt(i+16),(String)vRetResult.elementAt(i+17),1)%></font></td>
      <td class="thinborder"><font size="1"><%=((String)vRetResult.elementAt(i+8))%></font></td>
      <td class="thinborder"><font size="1"><%=CommonUtil.formatMinute((String)vRetResult.elementAt(i+9))+':'+
	  CommonUtil.formatMinute((String)vRetResult.elementAt(i+10))+astrConvTime[Integer.parseInt((String)vRetResult.elementAt(i + 11))]%></font></td>
      <td class="thinborder"><font size="1"><%=((String)vRetResult.elementAt(i+7))%> minutes</font></td>
      <td class="thinborder"><font size="1">&nbsp;<%=((String)vRetResult.elementAt(i+13))%></font></td>
    </tr>
    <%}%>
    <tr> 
      <td  height="25" colspan="6" class="thinborderBOTTOMLEFT" align="left"><font size="1"><strong>TOTAL 
          PYSCHOLOGICAL TESTS: &nbsp;&nbsp;<%=iSearchResult%></strong></font></td>
      <td colspan="2" align="right" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
  </table>
    <script language="JavaScript">
		window.print();
	</script>  
  <%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
