<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strStudInfoList = WI.fillTextValue("stud_list");
	if(strStudInfoList.equals("-1"))
		strStudInfoList = (String)request.getSession(false).getAttribute("stud_list");

	if(strStudInfoList == null || strStudInfoList.length() == 0) {%>
	<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold">Student List not found.</p>
	<%
		return; 
	}
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
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
	Vector vStudIDList = new Vector();
	String strPageURL  = "./grade_certificate_print.jsp";
	if(strSchCode.startsWith("UL"))
		strPageURL  = "./grade_certificate_print_ul.jsp";
	if(strSchCode.startsWith("CDD"))
		strPageURL  = "./grade_certificate_print_CDD.jsp";
	
	strPageURL += "?batch_print=1&sy_from="+WI.fillTextValue("sy_from")+
						"&sy_to="+WI.fillTextValue("sy_to")+"&font_size=11";
	if (WI.fillTextValue("first_sem").length() > 0) 
		strPageURL += "&first_sem=1";
	if (WI.fillTextValue("second_sem").length() > 0) 
		strPageURL += "&second_sem=2";
	if (WI.fillTextValue("third_sem").length() > 0) 
		strPageURL += "&third_sem=3";
	if (WI.fillTextValue("summer").length() > 0) 
		strPageURL += "&summer=0";
	strPageURL += "&stud_id=";
	
	Vector vStudList = CommonUtil.convertCSVToVector(strStudInfoList, ",", true);
	
	
	boolean bolPageBreak = false;
	for(int i = 0; i < vStudList.size(); i++){
		Thread.sleep(200);
		if(i == (vStudList.size()-1))
			bolPageBreak = false;
		else
			bolPageBreak = true;
	%>
		<jsp:include page="<%=strPageURL+(String)vStudList.elementAt(i)%>" />
	
	<%if(bolPageBreak){%>
		<DIV style="page-break-before:always" ><img src="../../../images/blank.gif" width="1" height="1"></DIV>
	<%}%>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
