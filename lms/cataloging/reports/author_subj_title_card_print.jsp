<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Card Report.</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<body onLoad="javascript:window.print();" topmargin="0" bottommargin="0">
<%@ page language="java" import="utility.*,lms.CatalogReport,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp   = null;
	WebInterface WI  = new WebInterface(request);

	String strReportType = WI.fillTextValue("report_type");
	
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
	CatalogReport CR = new CatalogReport();
	Vector vRetResult = CR.generateReportCard(dbOP, request);

if(vRetResult == null || vRetResult.size() == 0) {
	dbOP.cleanUP();
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=CR.getErrMsg()%></font></p>
	<%
	return;
}
%>

<!-- For sample only... uncomment to see the sample
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="87" height="28">&nbsp;</td>
      <td height="28" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="28" valign="top">$call_num<br>
        $cpy_date</td>
      <td width="457" height="28">$author_lname,&nbsp; $Author_fname.&nbsp;<br>
        &nbsp;&nbsp;&nbsp;$Title&nbsp;/&nbsp;$author_name1, $author_name2, $author_name_n. 
        --&nbsp;$edition -- &nbsp;$place_of_pub&nbsp;:&nbsp;$publisher,&nbsp;c$copyright_date.<br> 
        &nbsp;&nbsp;&nbsp;$inclusion&nbsp;$other_phy_desc&nbsp;&nbsp;$size --<br>
        &nbsp; <br> &nbsp;&nbsp;&nbsp;$note_fields_general.<br> &nbsp;&nbsp;&nbsp;$ISBN<br> 
        <br> &nbsp;&nbsp;&nbsp;1. $subject_headings1. &nbsp;2. $subject_headings2.&nbsp;&nbsp;I. 
        $added_entry.&nbsp;&nbsp;<br>
        II. $Title. <br> </td>
      <td width="705">&nbsp;</td>
    </tr>
    <tr> 
      <td height="10" colspan="3">NOTE : Display call num line by line. See sample.</td>
    </tr>
  </table>
-->
<%
Vector vAN = null;//author names.
Vector vSH = null;//subject heading.

String strAN = null;
String strSH = null;
//System.out.println(vRetResult);
for(int i= 0; i < vRetResult.size(); i += 19){
vAN = (Vector)vRetResult.elementAt(i + 8);
vSH = (Vector)vRetResult.elementAt(i + 18);
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="15%" valign="top"><%//=WI.getStrValue((String)vRetResult.elementAt(i),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 1),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 4))%></td>
      <td width="85%">
	  <%//show author for author card, title for title card, subject heading for subject card.
	if(strReportType.equals("3")){%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"",".&nbsp;","")%><br>
	<%}else if(strReportType.equals("4")){//subject card%>
			<%if(vSH != null && vSH.size() > 0) {%><%=WI.getStrValue((String)vSH.elementAt(0))%><%}else{%>xxxx<%}%> <br>
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"",".&nbsp;","")%><br>	  
	<%}else if(strReportType.equals("5")){//title card.%>
		<%=WI.getStrValue(WI.getStrValue((String)vRetResult.elementAt(i + 6),"",
			WI.getStrValue((String)vRetResult.elementAt(i + 7)," : ","","")
			,""),"",".<br>","")%> 
		
		<%//=WI.getStrValue((String)vRetResult.elementAt(i + 6))%> 
        &nbsp; <%//=WI.getStrValue((String)vRetResult.elementAt(i + 7)," : ",".","")%>
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"",".&nbsp;","")%><br>	  
	<%}%>
	  
	  
        &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%> 
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 7)," : ",".&nbsp;","")%>/&nbsp;
<%
///author names
strAN = (String)vRetResult.elementAt(i + 5)+".";
if(vAN != null && vAN.size() > 0) {
	for(int p = 0; p < vAN.size(); ++p)  {
		if(vAN.elementAt(p) == null)
			continue;
			
		strAN = strAN + ","+(String)vAN.elementAt(p)+".";
	}
}
%>
		<%=WI.getStrValue(strAN)%>
		 
        &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 9),""," -- &nbsp;","")%>
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 10))%>
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 11),"&nbsp;:&nbsp;","","")%>
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 12),", c",".","")%><br> 
        &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 13))%>&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 14))%>&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 15),""," --","")%><br>
        &nbsp; <br> &nbsp;&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 16),"","<br> &nbsp;&nbsp;&nbsp;","")%>
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 17))%><br><br> &nbsp;&nbsp;&nbsp;
<%
if(vSH != null && vSH.size() > 0) {
	for(int p = 0; p < vSH.size(); ++p){
		if(vSH.elementAt(p) == null)
			continue;%>
		<%=p+1%>. <%=(String)vSH.elementAt(p)%>
<%}
}
strAN = null;
if(vAN != null && vAN.size() > 0) {
	for(int p = 0; p < vAN.size(); ++p)  {
		if(vAN.elementAt(p) == null)
			continue;
		if(strAN == null)
			strAN = (String)vAN.elementAt(p)+".";	
		else	
			strAN = strAN + ","+(String)vAN.elementAt(p)+".";
	}
}
%>			&nbsp;&nbsp;I. <%=WI.getStrValue(strAN)%>&nbsp;&nbsp;<br>
        II. Title. <br> </td>
    </tr>
  </table>
<%if( (vRetResult.size() - i) > 20){%>
	<DIV style="page-break-after:always">&nbsp;</DIV>
<%}
}%>	
<!--
    <tr> 
      <td height="10" colspan="3">NOTE : Display call num line by line. See sample.</td>
    </tr>
-->	
</body>
</html>
<%
dbOP.cleanUP();
%>