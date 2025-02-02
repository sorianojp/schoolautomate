<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	int iMaxDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_disp"), "0"));
	if(iMaxDisp < 1) {%>
	<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold">Print List not found.</p>
	<%
		return; 
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<body onLoad="window.print();" topmargin="0" bottommargin="0">
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

	
	String strPageURL = "./print_plotted_room_assignment_one.jsp?print_pg=1&school_year_fr="+WI.fillTextValue("school_year_fr")+
						"&school_year_to="+WI.fillTextValue("school_year_to")+
						"&offering_sem="+WI.fillTextValue("offering_sem")+
						"&show_class_size="+WI.fillTextValue("show_class_size");

	strPageURL += "&room_i=";
	
	boolean bolPageBreak = false;
	
	int iPrinted = 0;
	for(int i = 0; i < iMaxDisp; ++i){
		strTemp = WI.fillTextValue("_"+i);
		if(strTemp.length() == 0) 
			continue;
		if(iPrinted > 0) {%>
			<DIV style="page-break-before:always" >&nbsp;</DIV>
		<%}++iPrinted;%>

		<jsp:include page="<%=strPageURL+strTemp%>" />
	
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
