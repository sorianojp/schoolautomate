<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>RECEIVABLES PROJECTION REPORT</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 7px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 7px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 7px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 7px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 7px;
    }

-->
</style>
</head>

<body >
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
WebInterface WI = new WebInterface(request);
DBOperation dbOP = null;
String strErrMsg = null;


	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Fee Assessment & payment-REPORTS","rec_projection_print_percourse.jsp");
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
String[] astrConvertToSem = {"SUMMER", "1ST SEM","2ND SEM","3RD SEM"};
Vector vRetResult = null;
Vector vMiscFeeName = null;
Vector vFeeDetailPerCollege = null;
Vector vFeeDetailUniversity = null;
Vector vStudDetail = null;

EnrlReport.FeeExtraction fEx = new EnrlReport.FeeExtraction();
vRetResult = fEx.getRecProj(dbOP, request);
if(vRetResult == null || vRetResult.size() == 0) {
	strErrMsg = fEx.getErrMsg();
}
else {
	vFeeDetailUniversity = (Vector)vRetResult.remove(0);
	vMiscFeeName         = (Vector)vRetResult.remove(0);
	vFeeDetailPerCollege = (Vector)vRetResult.remove(0);	
}
//System.out.println(vFeeDetailPerCollege);
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td height="25"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,false)%></div></td>
    </tr>
    <tr >
      
    <td height="25" align="right"><br>Date and time printed: <%=WI.getTodaysDateTime()%><br><BR></td>
    </tr>
</table>
<%
if(strErrMsg != null) {//return here.%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
    <td height="25"><br><%=strErrMsg%></td>
    </tr>
</table>

<%dbOP.cleanUP();
return;
}
%>
  
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td height="20" colspan="3"><div align="center"><strong><font size="1">RECEIVABLES PER COURSE AS OF &nbsp;<%=astrConvertToSem[Integer.parseInt(WI.fillTextValue("semester"))]+", "+WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")%> 
        <%=WI.fillTextValue("date_from")%></font></strong></div></td>
  </tr>
  </table>

  <%//System.out.println(vRetResult.size());
  //System.out.println(vFeeDetailPerCollege.size()/ (7 + vMiscFeeName.size()) );
 for(int k = 0; k < vFeeDetailPerCollege.size(); k = k + 7 + vMiscFeeName.size()){
 	if(vRetResult.size() > 0) {
		vStudDetail = (Vector)vRetResult.remove(0);
		if(vStudDetail == null)
			continue;
	}
	else 
	 	continue;
 //System.out.println("Stud : "+vStudDetail.size() / (7 + vMiscFeeName.size()));
 %>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr> 
    <td width="100%" height="20"><div align="center"><font size="2"><br>Course Name : 
	<%=dbOP.mapOneToOther("course_offered","course_index", (String)vFeeDetailPerCollege.elementAt(k), 
	"course_name",null)%></font></div></td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
  <tr> 
    <td width="4%" height="20" class="thinborder"><div align="center">STUD NAME</font></div></td>
    <td width="4%" class="thinborder">UNIT</td>
    <td width="4%" class="thinborder">TOT ASSM.</td>
    <td width="4%" class="thinborder">TUITION FEE</td>
    <td width="4%" class="thinborder">COMP. HANDS ON</td>
    <%
	for(int i = 0; i < vMiscFeeName.size(); ++i){%>
    <td class="thinborder"><%=((String)vMiscFeeName.elementAt(i)).toUpperCase()%></td>
    <%}%>
  </tr>
  <%
 for(int i = 0; i < vStudDetail.size(); i = i + 10 + vMiscFeeName.size()){%>
  <tr> 
    <td width="4%" height="20" class="thinborder"><div align="center"><%=(String)vStudDetail.elementAt(i + 2)%></font></div></td>
    <td width="4%" height="20" class="thinborder"><div align="center"><%=((String)vStudDetail.elementAt(i + 3)).charAt(0)%>
	<%=(String)vStudDetail.elementAt(i + 4)%></font></div></td>
    <td width="4%" class="thinborder"><%=(String)vStudDetail.elementAt(i + 2)%></td>
    <td width="4%" class="thinborder"><%=(String)vStudDetail.elementAt(i + 3)%></td>
    <td width="4%" class="thinborder"><%=(String)vStudDetail.elementAt(i + 6)%></td>
    <%
	for(int p = 0; p < vMiscFeeName.size(); ++p){%>
    <td class="thinborder"><%=((String)vStudDetail.elementAt(i + 10 + p))%></td>
    <%}%>
  </tr>
  <%}//END OF SHOWING vStudDetail%>
  <tr> 
    <td width="4%" height="20" class="thinborder"><div align="center"><strong>GT</strong></font></div></td>
    <td width="4%" class="thinborder">&nbsp;</td>
    <td width="4%" class="thinborder"><strong><%=(String)vFeeDetailPerCollege.elementAt(k + 2)%></strong></td>
    <td width="4%" class="thinborder"><strong><%=(String)vFeeDetailPerCollege.elementAt(k + 3)%></strong></td>
    <td width="4%" class="thinborder"><strong><%=(String)vFeeDetailPerCollege.elementAt(k + 6)%></strong></td>
    <%
	for(int p = 0; p < vMiscFeeName.size(); ++p){%>
    <td class="thinborder"><strong><%=((String)vFeeDetailPerCollege.elementAt(7 + p))%></strong></td>
    <%}%>
  </tr>
</table>
<%}//fee per college loop
%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="2"><font size="1">&nbsp;</font></td>
      <td width="0">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"><font size="1">Prepared by :</font></td>
      <td height="25"><font size="1">Reviewed by : </font></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25" valign="bottom"><font size="1">__________________________________________________</font></td>
      <td height="25" valign="bottom"><font size="1">_____________________________________________________</font></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="48%" height="24"><div align="left"><font size="1">Accountant</font></div></td>
      <td width="52%" height="24"><font size="1">Head Accountant</font></td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>
</body>
</html>
<%
dbOP.cleanUP();
%>