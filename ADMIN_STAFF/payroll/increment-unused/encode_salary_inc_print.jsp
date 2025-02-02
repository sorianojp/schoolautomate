<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payroll Summary For Bank</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
    TD.noBorder {
	font-family: Verdana, Arial, Geneva,  Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderBOTTOMLeft {
    border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;	
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderBOTTOMLeftRight {
    border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;	
	border-right: solid 1px #000000;	
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
	
	
</style>


</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<form name="form_" 	method="post" action="./encode_salary_inc.jsp">
<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll" %>
<%  WebInterface WI = new WebInterface(request);

	DBOperation dbOP = null;
	
	String strErrMsg = null;
	String strTemp = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	int iSearchResult = 0;
	int i = 0;

//add security here.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
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

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-REPORTS-Payroll Summary by status","encode_salary_inc.jsp");
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
//end of authenticaion code.

	Vector vRetResult = null;
	ReportPayroll RptPay = new ReportPayroll(request);
	String[] astrPTFT = {"Part-Time", "Full-time"};
	String[] astrType = {"Staff", "Faculty","Staff with Teaching Load"};
	String strPageAction = WI.fillTextValue("page_action");


	vRetResult = RptPay.operateOnIncrement(dbOP,4);
		if(vRetResult == null){
			strErrMsg = RptPay.getErrMsg();
		}else{
			iSearchResult = RptPay.getSearchCount();
		}

	
	if(strPageAction.length() > 0){
		if(RptPay.operateOnIncrement(dbOP,1) == null){
			strErrMsg = RptPay.getErrMsg();
		}else{
			strErrMsg = "Success!";
		}
		
	}
%>
  <%if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="8" class="thinborderBOTTOM" ><div align="center"><strong><font color="#000000">LIST 
          OF INCREMENTS</font></strong></div></td>
    </tr>
    <tr> 
      <td  width="16%" height="25" class="thinborderBOTTOMLeft" ><div align="center"><strong><font size="1">EMPLOYEE 
          CATEGORY</font></strong></div></td>
      <td width="16%" class="thinborderBOTTOMLeft"><div align="center"><strong><font size="1">EMPLOYEE STATUS</font></strong></div></td>
      <td width="12%" class="thinborderBOTTOMLeft"><div align="center"><strong><font size="1">ID NUMBER</font></strong></div></td>
      <td width="12%" class="thinborderBOTTOMLeft"><div align="center"><strong><font size="1">EFFECTIVE DATE</font></strong></div></td>
      <td width="11%" class="thinborderBOTTOMLeft"><div align="center"><strong><font size="1">REGULAR INCREMENT</font></strong></div></td>
      <td width="11%" class="thinborderBOTTOMLeft"><div align="center"><strong><font size="1">RERANKING</font></strong></div></td>
      <td width="11%" class="thinborderBOTTOMLeft"><div align="center"><strong><font size="1">OTHER INCREMENT</font></strong></div></td>
      <td width="11%" class="thinborderBOTTOMLeftRight"><div align="center"><strong><font size="1">TOTAL INCREMENT</font></strong></div></td>
      <!--
      <td width="10%"><div align="center"><strong><font size="1">SELECT ALL</font><br>
          <input type="checkbox" name="selAll" value="0" onClick="CheckAll();">
          </strong></div></td>
	-->
    </tr>
    <% 
	for(i = 0 ; i < vRetResult.size(); i +=10){%>
    <tr> 
      <%
	  	if(vRetResult.elementAt(i + 1) != null){
			strTemp = (String) vRetResult.elementAt(i + 1);
			strTemp = astrType[Integer.parseInt(strTemp)];
		}else{
			strTemp = "";
		}
		
		if(vRetResult.elementAt(i + 3) != null)
			strTemp = "&nbsp;";
		
	  %>
      <td height="19" class="thinborderBOTTOMLeft">&nbsp;<%=WI.getStrValue(strTemp,"All Employees")%></td>
      <%
	  	if(vRetResult.elementAt(i + 2) != null){
			strTemp = (String) vRetResult.elementAt(i + 2);
			strTemp = astrPTFT[Integer.parseInt(strTemp)];
		}else{
			strTemp = "";
		}

		if(vRetResult.elementAt(i + 3) != null)
			strTemp = "&nbsp;";		
	  %>
      <td height="19" class="thinborderBOTTOMLeft"><div align="left">&nbsp;<%=WI.getStrValue(strTemp,"All Employees")%></div></td>
      <td class="thinborderBOTTOMLeft">&nbsp;<%=WI.getStrValue((String) vRetResult.elementAt(i + 3),"&nbsp;")%></td>
      <td class="thinborderBOTTOMLeft"><div align="right"><%=WI.getStrValue((String) vRetResult.elementAt(i + 4),"&nbsp;")%>&nbsp;</div></td>
      <td class="thinborderBOTTOMLeft"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String) vRetResult.elementAt(i + 5),true),"&nbsp;")%>&nbsp;</div></td>
      <td class="thinborderBOTTOMLeft"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String) vRetResult.elementAt(i + 6),true),"&nbsp;")%>&nbsp;</div></td>
      <td class="thinborderBOTTOMLeft"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String) vRetResult.elementAt(i + 7),true),"&nbsp;")%>&nbsp;</div></td>
      <td class="thinborderBOTTOMLeftRight"><div align="right"><%=WI.getStrValue(CommonUtil.formatFloat((String) vRetResult.elementAt(i + 8),true),"&nbsp;")%>&nbsp;</div></td>
    </tr>
    <%}//end of for loop to display employee information.%>
  </table>  
  <%}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>