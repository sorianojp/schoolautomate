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
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"GUIDANCE & COUNSELING-PSYCHOLOGICAL TESTS","percentile_score_map_print.jsp");
	
	Vector vRetResult = null;
	int i = 0;
	String strErrMsg = null;
	String strTemp = null;


	GDPsychologicalTest PsychTest = new GDPsychologicalTest();
	vRetResult = PsychTest.operateOnPercentileMapping(dbOP, request, 4);
	if (vRetResult == null)
		strErrMsg = PsychTest.getErrMsg();
%>
<body bgcolor="#FFFFFF">
  <%if (vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DADADA"> 
      <td  height="25" colspan="3" align="center" class="thinborder"><strong>LIST 
          OF PSYCHOLOGICAL TESTS</strong></td>
    </tr>
    <tr> 
      <td width="50%" height="28" align="center" class="thinborder"><font size="1"><strong>RAW SCORE</strong></font></td>
      <td width="50%" align="center" class="thinborder"><font size="1"><strong>PERCENTILE </strong></font></td>
    </tr>
	<%for (i=0; i < vRetResult.size(); i+=3){%>
    <tr> 
      <td  height="26" class="thinborder" align="center">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
      <td class="thinborder" align="center">&nbsp;<%=CommonUtil.formatFloat(Double.parseDouble((String)vRetResult.elementAt(i+2)),false)%></td>
    </tr>
    <%}%>
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