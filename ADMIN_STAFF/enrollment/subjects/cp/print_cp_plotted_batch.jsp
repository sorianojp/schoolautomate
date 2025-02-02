<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	int iMaxDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_disp"), "0"));
	if(iMaxDisp < 2) {%>
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

	
	String strPageURL = "./print_cp_plotted_one.jsp?course_index="+WI.fillTextValue("course_index")+"&major_index="+WI.fillTextValue("major_index")+
						"&year_level="+WI.fillTextValue("year_level")+"&school_year_fr="+WI.fillTextValue("school_year_fr")+
						"&school_year_to="+WI.fillTextValue("school_year_to")+"&offering_sem="+WI.fillTextValue("offering_sem")+
						"&cy_f="+WI.fillTextValue("cy_f");
	if(WI.fillTextValue("inc_mixed").length() > 0) 
		strPageURL += "&inc_mixed=1";

	strPageURL += "&section=";
	
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
