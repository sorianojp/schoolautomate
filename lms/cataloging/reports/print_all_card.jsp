<%
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
if(strAuthTypeIndex == null) {%>
	<p align="center" style="font-size:14px; color:#FF0000; font-weight:bold">You are already logged out. Please login again.</p>
<%return;}%>

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
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
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
Vector vAN   = null;//author names.
Vector vSH   = null;//subject heading.
Vector vANum = null;///accession number.

boolean bolIsEditedBy = false;//if edited by then do not print list of authors in CSV..  -- it is title entry if true.. 
int iIndexOf = 0; //I have to format the lastname, first name to first name last name for the author names.

String strAN = null;
String strSH = null;
//System.out.println(vRetResult);
for(int i= 0; i < vRetResult.size(); i += 23){
vAN = (Vector)((Vector)vRetResult.elementAt(i + 8)).clone();
vSH = (Vector)((Vector)vRetResult.elementAt(i + 18)).clone();
vANum = (Vector)((Vector)vRetResult.elementAt(i + 20)).clone();
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td valign="top" colspan="2" align="right">SHELF LIST</td>
    <tr> 
      <td width="15%" valign="top">
<%if(strSchCode.startsWith("UI")){
//System.out.println("1 : "+vRetResult.elementAt(i + 1));System.out.println("21 : "+vRetResult.elementAt(i + 21));
//System.out.println("3 : "+vRetResult.elementAt(i + 3));System.out.println("4 : "+vRetResult.elementAt(i + 4));
//System.out.println("22 : "+vRetResult.elementAt(i + 22));%>
	  <%//=WI.getStrValue((String)vRetResult.elementAt(i),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 1),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 21),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 4),"","<br>","")%>
<%}else{%>
	  <%//=WI.getStrValue((String)vRetResult.elementAt(i),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 1),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 4))%>
<%}%>	  
	  <br><br>
<%
//get ACCESSION NUMBER.
for(int p = 0; p < vANum.size();) {%>
<%=(String)vANum.remove(0)%><br>
<%}
strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 5));
if(strTemp.startsWith("edited by")) {
	strTemp = "";
	bolIsEditedBy = true;
}
else	
	strTemp = strTemp + ".&nbsp;<br>";
	%>	  
	</td>
      <td width="85%" valign="top"><%=strTemp%>
	    &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%>
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 7),": ","","")%>&nbsp;/
<%
///author names
strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 5));
iIndexOf = strTemp.indexOf(",");
if(iIndexOf > -1)
	strTemp = strTemp.substring(iIndexOf + 1) + " "+strTemp.substring(0, iIndexOf );
	
strAN = strTemp;//+".";
if(vAN != null && vAN.size() > 0) {
	for(int p = 0; p < vAN.size(); ++p)  {
		if(vAN.elementAt(p) == null)
			continue;
			
		if(!bolIsEditedBy) {
			strTemp = WI.getStrValue((String)vAN.elementAt(p));
			iIndexOf = strTemp.indexOf(",");
			if(iIndexOf > -1)
				strTemp = strTemp.substring(iIndexOf + 1) + " "+strTemp.substring(0, iIndexOf );

			strAN = strAN + ","+strTemp;// -- according to UI, there should not be multiple Author here, as it is at bottom.
		}
	}
}
if(strAN != null && strAN.length() > 0) 
	strAN = strAN + ".";
%>
		<%=WI.getStrValue(strAN)%>
		 
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 9), "--&nbsp;","","")%> -- 
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 10))%>&nbsp;:
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 11))%>,
		c<%=WI.getStrValue((String)vRetResult.elementAt(i + 12))%>.<br> 
        &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 13))%>&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 14))%>&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 15))%> -- <%=WI.getStrValue((String)vRetResult.elementAt(i + 22))%><br>
        &nbsp; <br> &nbsp;&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 16))%><br> &nbsp;&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 17))%>
		<%if(vRetResult.elementAt(i + 19) != null && ((String)vRetResult.elementAt(i + 19)).length() > 0){%> 
		<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 19),true)%><%}//show only if amount is defined.%><br> 
        <br> &nbsp;&nbsp;&nbsp;
<%
//System.out.println("vSH : "+vSH);
//System.out.println("vAN : "+vAN);
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
			strAN = (String)vAN.elementAt(p);	
		else	
			strAN = strAN + ","+(String)vAN.elementAt(p); 
	}
}
if(strAN != null)
	strAN = strAN + ".";
	
%>			&nbsp;&nbsp;I. <%=WI.getStrValue(strAN, "Title.")%>&nbsp;&nbsp;
		<%if(!bolIsEditedBy && WI.getStrValue(strAN).length() > 0){%><br>II. Title. <br><%}%> 
	  </td>
    </tr>
    <tr>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
<DIV style="page-break-after:always">&nbsp;</DIV>
<!--------------------- Print another shelf list ------------------------------------->
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td valign="top" colspan="2" align="right">CONTROL FILE </td>
    <tr> 
    <tr> 
      <td width="15%" valign="top">
<%if(strSchCode.startsWith("UI")){%>
	  <%//=WI.getStrValue((String)vRetResult.elementAt(i),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 1),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 21),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 4),"","<br>","")%>
<%}else{%>
	  <%//=WI.getStrValue((String)vRetResult.elementAt(i),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 1),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 4))%>
<%}%>	  
	  <br><br>
<%
vANum = (Vector)((Vector)vRetResult.elementAt(i + 20)).clone();
//get ACCESSION NUMBER.
for(int p = 0; p < vANum.size();) {%>
<%=(String)vANum.remove(0)%><br>
<%}
strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 5));
if(strTemp.startsWith("edited by"))
	strTemp = "";
else	
	strTemp = strTemp + ".&nbsp;<br>";
%>
      </td>
      <td width="85%" valign="top"><%=strTemp%>
	    &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%> 
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 7),": ","","")%>&nbsp;/
<%
///author names
strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 5));
iIndexOf = strTemp.indexOf(",");
if(iIndexOf > -1)
	strTemp = strTemp.substring(iIndexOf + 1) + " "+strTemp.substring(0, iIndexOf );
	
strAN = strTemp;//+".";
if(vAN != null && vAN.size() > 0) {
	for(int p = 0; p < vAN.size(); ++p)  {
		if(vAN.elementAt(p) == null)
			continue;
			
		if(!bolIsEditedBy) {
			strTemp = WI.getStrValue((String)vAN.elementAt(p));
			iIndexOf = strTemp.indexOf(",");
			if(iIndexOf > -1)
				strTemp = strTemp.substring(iIndexOf + 1) + " "+strTemp.substring(0, iIndexOf );

			strAN = strAN + ","+strTemp;// -- according to UI, there should not be multiple Author here, as it is at bottom.
		}
	}
}
if(strAN != null && strAN.length() > 0) 
	strAN = strAN + ".";
%>
		<%=WI.getStrValue(strAN)%>
		 
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 9), "--&nbsp;","","")%> -- 
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 10))%>&nbsp;:
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 11))%>,
		c<%=WI.getStrValue((String)vRetResult.elementAt(i + 12))%>.<br> 
        &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 13))%>&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 14))%>&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 15))%> -- <%=WI.getStrValue((String)vRetResult.elementAt(i + 22))%><br>
        &nbsp; 
		<%if(!strSchCode.startsWith("UI")){%><br> &nbsp;&nbsp;&nbsp;
			<%=WI.getStrValue((String)vRetResult.elementAt(i + 16))%><br> &nbsp;&nbsp;&nbsp;
			<%=WI.getStrValue((String)vRetResult.elementAt(i + 17))%>
			<%if(vRetResult.elementAt(i + 19) != null && ((String)vRetResult.elementAt(i + 19)).length() > 0){%> 
			<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 19),true)%><%}//show only if amount is defined.%><br> 
        <%}%><br> &nbsp;&nbsp;&nbsp;
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
			strAN = (String)vAN.elementAt(p);	
		else	
			strAN = strAN + ","+(String)vAN.elementAt(p);//+".";
	}
}
%>			&nbsp;&nbsp;I. <%=WI.getStrValue(strAN, "Title.")%>&nbsp;&nbsp;
		<%if(!bolIsEditedBy && WI.getStrValue(strAN).length() > 0){%><br>II. Title. <br><%}%> 
	  </td>
    </tr>
    <tr>
      <td valign="top">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>

<DIV style="page-break-after:always">&nbsp;</DIV>

<%}%>	
<!--
    <tr> 
      <td height="10" colspan="3">NOTE : Display call num line by line. See sample.</td>
    </tr>
-->	

<!--------------------------------------- TITLE CARD PRINTING ---------------------------------------->
<!-- do not print if 		bolIsEditedBy is true.. there will be no title card printing. if book is a title entry -->

<%
	
	request.setAttribute("report_type","3");
	vRetResult = CR.generateReportCard(dbOP, request);
	///author card, subject card and title card are all same just change in vector.	
	if(vRetResult == null || vRetResult.size() == 0) {
		dbOP.cleanUP();
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		<%=CR.getErrMsg()%></font></p>
	<%
	return;
}
strReportType = "5";
for(int i= 0; i < vRetResult.size(); i += 19, i = vRetResult.size()){
	if(bolIsEditedBy)
		break;
vAN = (Vector)((Vector)vRetResult.elementAt(i + 8)).clone();
vSH = (Vector)((Vector)vRetResult.elementAt(i + 18)).clone();
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td valign="top" align="right">&nbsp;</td>
      <td valign="top"><%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%> <!-- print for title card.. -->
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 7),": ",".","")%><br>&nbsp;</td>
    <tr> 
    <tr> 
      <td width="15%" valign="top"><%//=WI.getStrValue((String)vRetResult.elementAt(i),"","<br>","")%>
	  <%//=WI.getStrValue((String)vRetResult.elementAt(i),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 1),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 4))%>	  </td>
      <td width="85%" valign="top">
	  <%//show author for author card, title for title card, subject heading for subject card.
strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 5));
if(strTemp.startsWith("edited by"))
	strTemp = "";
else	
	strTemp = strTemp + ".&nbsp;<br>";

	if(strReportType.equals("3")){%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 5))%>.&nbsp;<br>
	<%}else if(strReportType.equals("4")){//subject card%>
			<%if(vSH != null && vSH.size() > 0) {%><%=WI.getStrValue((String)vSH.elementAt(0))%><%}else{%>xxxx<%}%> <br>
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 5))%>.&nbsp;<br>	  
	<%}else if(strReportType.equals("5")){//title card.%>
		<%=strTemp%>	  
	<%}%>
	  
	  
        &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%>
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 7),": ","","")%>&nbsp;/
<%
///author names
strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 5));
iIndexOf = strTemp.indexOf(",");
if(iIndexOf > -1)
	strTemp = strTemp.substring(iIndexOf + 1) + " "+strTemp.substring(0, iIndexOf );
	
strAN = strTemp;//+".";
if(vAN != null && vAN.size() > 0) {
	for(int p = 0; p < vAN.size(); ++p)  {
		if(vAN.elementAt(p) == null)
			continue;
			
		if(!bolIsEditedBy) {
			strTemp = WI.getStrValue((String)vAN.elementAt(p));
			iIndexOf = strTemp.indexOf(",");
			if(iIndexOf > -1)
				strTemp = strTemp.substring(iIndexOf + 1) + " "+strTemp.substring(0, iIndexOf );

			strAN = strAN + ","+strTemp;//+".";// -- according to UI, there should not be multiple Author here, as it is at bottom.
		}
	}
}
if(strAN != null && strAN.length() > 0) 
	strAN = strAN + ".";
%>
		<%=WI.getStrValue(strAN)%>
		 
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 9), "--&nbsp;","","")%> -- 
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 10))%>&nbsp;:
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 11))%>,
		c<%=WI.getStrValue((String)vRetResult.elementAt(i + 12))%>.<br> 
        &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 13))%>&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 14))%>&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 15))%> --<br>
        &nbsp; <%if(!strSchCode.startsWith("UI")){%><br> &nbsp;&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 16))%><br> &nbsp;&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 17))%><br> 
        <br> &nbsp;&nbsp;&nbsp;
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
			strAN = (String)vAN.elementAt(p);//+".";	
		else	
			strAN = strAN + ","+(String)vAN.elementAt(p);//+".";
	}
}
if(strAN != null && strAN.length() > 0) 
	strAN = strAN + ".";
%>			&nbsp;&nbsp;I. <%=WI.getStrValue(strAN, "Title.")%>&nbsp;&nbsp;
			<%if(!bolIsEditedBy && WI.getStrValue(strAN).length() > 0){%><br>II. Title. <br><%}%> 
        <%}%></td>
    </tr>
  </table>
<DIV style="page-break-after:always">&nbsp;</DIV>
<%}///end of Author card
////////////////////////////////////////////////////author card ///////////////////////////////////
///author will be printed equal to # of authors in author Vector.. 
strReportType = "3";
Vector vANAdditional = null;
for(int i= 0; i < vRetResult.size(); i += 19, i = vRetResult.size()){
vAN = (Vector)((Vector)vRetResult.elementAt(i + 8)).clone();
vSH = (Vector)((Vector)vRetResult.elementAt(i + 18)).clone();
vANAdditional = (Vector)vAN.clone();
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="15%" valign="top"><%//=WI.getStrValue((String)vRetResult.elementAt(i),"","<br>","")%>
	  <%//=WI.getStrValue((String)vRetResult.elementAt(i),"","<br>","")%>Testing.... 
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 1),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 4))%>
	  </td> 
      <td width="85%" valign="top">
	  <%//show author for author card, title for title card, subject heading for subject card.
	if(strReportType.equals("3")){
strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 5));
if(strTemp.startsWith("edited by"))
	strTemp = "";
else	
	strTemp = strTemp + ".&nbsp;<br>";
	%>
	  <%=strTemp%>
	<%}else if(strReportType.equals("4")){//subject card%>
			<%if(vSH != null && vSH.size() > 0) {%><%=WI.getStrValue((String)vSH.elementAt(0))%><%}else{%>xxxx<%}%> <br>
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 5))%>.&nbsp;<br>	  
	<%}else if(strReportType.equals("5")){//title card.%>
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%> 
        &nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 7),": ","","")%><br>
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 5))%>.&nbsp;<br>	  
	<%}%>
	  
	  
        &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%> 
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 7),": ","","")%>&nbsp;/
<%
///author names
strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 5));
iIndexOf = strTemp.indexOf(",");
if(iIndexOf > -1)
	strTemp = strTemp.substring(iIndexOf + 1) + " "+strTemp.substring(0, iIndexOf );
	
strAN = strTemp;//+".";
if(vAN != null && vAN.size() > 0) {
	for(int p = 0; p < vAN.size(); ++p)  {
		if(vAN.elementAt(p) == null)
			continue;
			
		if(!bolIsEditedBy) {
			strTemp = WI.getStrValue((String)vAN.elementAt(p));
			iIndexOf = strTemp.indexOf(",");
			if(iIndexOf > -1)
				strTemp = strTemp.substring(iIndexOf + 1) + " "+strTemp.substring(0, iIndexOf );

			strAN = strAN + ","+strTemp;//+".";// -- according to UI, there should not be multiple Author here, as it is at bottom.
		}
	}
}
if(strAN != null && strAN.length() > 0) 
	strAN = strAN + ".";
%>
		<%=WI.getStrValue(strAN)%>
		 
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 9), "--&nbsp;","","")%> -- 
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 10))%>&nbsp;:
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 11))%>,
		c<%=WI.getStrValue((String)vRetResult.elementAt(i + 12))%>.<br> 
        &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 13))%>&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 14))%>&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 15))%> --<br>
        &nbsp; <br> &nbsp;&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 16))%><br> &nbsp;&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 17))%><br> 
        <br> &nbsp;&nbsp;&nbsp;
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
			strAN = (String)vAN.elementAt(p);//+".";	
		else	
			strAN = strAN + ","+(String)vAN.elementAt(p);//+".";
	}
}
%>			&nbsp;&nbsp;I. <%=WI.getStrValue(strAN, "Title.")%>&nbsp;&nbsp;
		<%if(!bolIsEditedBy && WI.getStrValue(strAN).length() > 0){%><br>II. Title. <br><%}%> 
	  </td>
    </tr>
  </table>
<DIV style="page-break-after:always">&nbsp;</DIV>
<%}///end of author card..  
//I have to now print subject heading if there are more Authors. 
if(vANAdditional == null)
	vANAdditional = new Vector();

String strAuthorNameAdditional = null;
while(vANAdditional.size() > 0) {
strAuthorNameAdditional = (String)vANAdditional.remove(0);
strReportType = "4";
Vector vSHToPrint = new Vector();
for(int i= 0; i < vRetResult.size(); i += 19){
vSH = (Vector)((Vector)vRetResult.elementAt(i + 18)).clone();
if(vSHToPrint.size() == 0)
	vSHToPrint = (Vector)vSH.clone();
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="15%" valign="top"><%//=WI.getStrValue((String)vRetResult.elementAt(i),"","<br>","")%><br><br>
	  <%//=WI.getStrValue((String)vRetResult.elementAt(i),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 1),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 4))%>
	  </td>
      <td width="85%" valign="top">
	  <%
strTemp = strAuthorNameAdditional + ".&nbsp;<br>";
	%>
			<%if(vSHToPrint != null && vSHToPrint.size() > 0) {%><%=WI.getStrValue((String)vSHToPrint.remove(0))%><%}else{%>xxxx<%}%> <br>
		<br><%=strTemp%>	  
	  
        &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%> 
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 7),": ","","")%>&nbsp;/
<%
///author names
strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 5));
iIndexOf = strTemp.indexOf(",");
if(iIndexOf > -1)
	strTemp = strTemp.substring(iIndexOf + 1) + " "+strTemp.substring(0, iIndexOf );
	
strAN = strTemp;//+".";
if(vAN != null && vAN.size() > 0) {
	for(int p = 0; p < vAN.size(); ++p)  {
		if(vAN.elementAt(p) == null)
			continue;
			
		if(!bolIsEditedBy) {
			strTemp = WI.getStrValue((String)vAN.elementAt(p));
			iIndexOf = strTemp.indexOf(",");
			if(iIndexOf > -1)
				strTemp = strTemp.substring(iIndexOf + 1) + " "+strTemp.substring(0, iIndexOf );

			strAN = strAN + ","+strTemp;//+".";// -- according to UI, there should not be multiple Author here, as it is at bottom.
		}
	}
}
%>
		<%=WI.getStrValue(strAN)%>
		 
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 9), "--&nbsp;","","")%> -- 
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 10))%>&nbsp;:
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 11))%>,
		c<%=WI.getStrValue((String)vRetResult.elementAt(i + 12))%>.<br> 
        &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 13))%>&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 14))%>&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 15))%> --<br>&nbsp; 
     </td>
    </tr>
  </table>
<DIV style="page-break-after:always">&nbsp;</DIV>
<%
	if(vSHToPrint != null && vSHToPrint.size() > 0) {
		i -= 19;
		continue;
	}//print copies equivalent to number of SH encoded.. 
	else 
		break;//print one copy only.  

}//for loop.%>	



<%}//end of printing subject card if more authorse are there.. 

////////////////////////////////////////////////////  subject card print ///////////////////////////////////
///Note :: print copies :: equal to 
strReportType = "4";
Vector vSHToPrint = new Vector();
for(int i= 0; i < vRetResult.size(); i += 19){
vAN = (Vector)vRetResult.elementAt(i + 8);
vSH = (Vector)vRetResult.elementAt(i + 18);
if(vSHToPrint.size() == 0)
	vSHToPrint = vSH;
//System.out.println("vSHToPrint : "+vSHToPrint);
//System.out.println("vAN : "+vAN);
//System.out.println("vSH : "+vSH);
//System.out.println("vRetResult : "+vRetResult);
%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="15%" valign="top"><%//=WI.getStrValue((String)vRetResult.elementAt(i),"","<br>","")%><br><br>
	  <%//=WI.getStrValue((String)vRetResult.elementAt(i),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 1),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 2),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 3),"","<br>","")%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 4))%>
	  </td>
      <td width="85%" valign="top">
	  <%//show author for author card, title for title card, subject heading for subject card.
	if(strReportType.equals("3")){%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 5))%>.&nbsp;<br>
	<%}else if(strReportType.equals("4")){//subject card
strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 5));
if(strTemp.startsWith("edited by"))
	strTemp = "";
else	
	strTemp = strTemp + ".&nbsp;<br>";
	%>
			<%if(vSHToPrint != null && vSHToPrint.size() > 0) {%><%=WI.getStrValue((String)vSHToPrint.remove(0))%><%}else{%>xxxx<%}%> <br>
		<br><%=strTemp%>	  
	<%}else if(strReportType.equals("5")){//title card.%>
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%> 
        &nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 7),": ","","")%><br>
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 5))%>.&nbsp;<br> 
	<%}%>
	  
	  
        &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6))%> 
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 7),": ","","")%>&nbsp;/
<%
///author names
strTemp = WI.getStrValue((String)vRetResult.elementAt(i + 5));
iIndexOf = strTemp.indexOf(",");
if(iIndexOf > -1)
	strTemp = strTemp.substring(iIndexOf + 1) + " "+strTemp.substring(0, iIndexOf );
	
strAN = strTemp;//+".";
if(vAN != null && vAN.size() > 0) {
	for(int p = 0; p < vAN.size(); ++p)  {
		if(vAN.elementAt(p) == null)
			continue;
			
		if(!bolIsEditedBy) {
			strTemp = WI.getStrValue((String)vAN.elementAt(p));
			iIndexOf = strTemp.indexOf(",");
			if(iIndexOf > -1)
				strTemp = strTemp.substring(iIndexOf + 1) + " "+strTemp.substring(0, iIndexOf );

			strAN = strAN + ","+strTemp;//+".";// -- according to UI, there should not be multiple Author here, as it is at bottom.
		}
	}
}
%>
		<%=WI.getStrValue(strAN)%>
		 
        <%=WI.getStrValue((String)vRetResult.elementAt(i + 9), "--&nbsp;","","")%> -- 
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 10))%>&nbsp;:
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 11))%>,
		c<%=WI.getStrValue((String)vRetResult.elementAt(i + 12))%>.<br> 
        &nbsp;&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 13))%>&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 14))%>&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 15))%> --<br>&nbsp; 
<%if(!strSchCode.startsWith("UI") && false){//do not print below anymore.. %><br> &nbsp;&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 16))%><br> &nbsp;&nbsp;&nbsp;
		<%=WI.getStrValue((String)vRetResult.elementAt(i + 17))%><br> 
        <br> &nbsp;&nbsp;&nbsp;
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
			strAN = (String)vAN.elementAt(p);//+".";	
		else	
			strAN = strAN + ","+(String)vAN.elementAt(p);//+".";
	}
}
%>			&nbsp;&nbsp;I. <%=WI.getStrValue(strAN, "Title.")%>&nbsp;&nbsp;
				<%if(!bolIsEditedBy && WI.getStrValue(strAN).length() > 0){%><br>II. Title. <br><%}%> 
<%		}//do not show if it is UI%></td>
    </tr>
  </table>
<DIV style="page-break-after:always">&nbsp;</DIV>
<%
if(vSHToPrint != null && vSHToPrint.size() > 0) {
	i -= 19;
	continue;
}//print copies equivalent to number of SH encoded..
else 
	break;//print one copy only.  

}%>	
</body>
</html>
<%
dbOP.cleanUP();
%>