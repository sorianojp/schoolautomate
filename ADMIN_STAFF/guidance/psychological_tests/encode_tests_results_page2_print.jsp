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
</head>
<%	//authenticate user access level	
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
								"GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS","encode_tests_results_page2_print.jsp");
	
	Vector vRetResult = null;
	Vector vFactors = null;
	Vector vSchedData = null;
	Vector vTemp = null;
	int i = 0;
	int iFactors = 1;
	int iTableFac = 0;
	String strErrMsg = null;
	String strTemp = null;
	int iTemp = 0;
	int iSearchResult = 0;
	String strPrepareToEdit = null;
	String [] astrConvTime={" AM"," PM"};


	GDPsychologicalTest PsychTest = new GDPsychologicalTest();
	vSchedData = PsychTest.operateOnPsyTestSched(dbOP, request, 3);
	if (vRetResult == null)
		strErrMsg = PsychTest.getErrMsg();

	vFactors = PsychTest.retrieveFactors(dbOP, WI.fillTextValue("sched_idx"));
	if (vFactors==null && strErrMsg==null)
			strErrMsg = PsychTest.getErrMsg();

	vRetResult = PsychTest.operateOnTestResultEncoding(dbOP, request, 4);
	if (vRetResult == null && strErrMsg==null)
		strErrMsg = PsychTest.getErrMsg();
	else
		iSearchResult = PsychTest.getSearchCount();		
%>
<body bgcolor="#FFFFFF">
<%
  if (vRetResult!=null && vRetResult.size()>0 && vFactors!= null && vFactors.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DADADA"> 
      <td  height="25" colspan="<%=((vFactors.size()/4)+4)%>" align="center"><strong>LIST 
          OF TESTS RESULTS FOR : <%=((String)vSchedData.elementAt(5)).toUpperCase()%> </strong></td>
    </tr>
    <tr> 
      <td width="15%" rowspan="2" align="center" class="thinborder"><font size="1" height="28"><strong>STUDENT ID</strong></font></td>
      <td width="20%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>STUDENT NAME </strong></font></td>
      <td width="20%" rowspan="2" align="center" class="thinborder"><font size="1"><strong>COURSE<br>/YEAR LEVEL </strong></font></td>
      <td height="19" colspan="<%=vFactors.size()/4%>" align="center" class="thinborder"><font size="1"><strong>SCORE
	  </strong></font></td>
    </tr>
    <tr> 
      <%for (iTableFac=0;iTableFac<vFactors.size();iTableFac+=4){%>
      <td height="20" align="center" class="thinborder"><strong><font size="1"><%=(String)vFactors.elementAt(iTableFac+2)%></font></strong></div></td>
	<%}%>
    </tr>
	<%for (i=0; i<vRetResult.size(); i+=8) {%>
    <tr> 
      <td class="thinborder" height="26"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
      <td class="thinborder"><font size="1">
      <%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),4)%></font></td>
      <td class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+5)%><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"<br>/ ","","")%>
      </font></td>
	<%
	vTemp = (Vector)vRetResult.elementAt(i+7);
	if(vTemp==null || vTemp.size()==0){
	for (iTableFac=0;iTableFac<(vFactors.size()/4);++iTableFac){%>
      <td class="thinborder">&nbsp;</td>
	<%}}else{
	for (iTableFac=0; iTableFac<vTemp.size();iTableFac+=2){%>
	<td align="center" class="thinborder"><font size="1"><%=(String)vTemp.elementAt(iTableFac)%><br><%=(String)vTemp.elementAt(iTableFac+1)%></font></td>
	<%}}%>
    </tr>
    <%}%>
    <tr> 
      <td  height="25" colspan="3" align="left" class="thinborderBOTTOMLEFT"><font size="1"><strong>TOTAL 
          PYSCHOLOGICAL TESTS: &nbsp;&nbsp;<%=iSearchResult%></strong></font></td>
      <td colspan="<%=((vFactors.size()/4)+1)%>" align="right" class="thinborderBOTTOM">&nbsp;</td>
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