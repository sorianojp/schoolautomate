<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
<!--

@media print { 
  @page {
		size:8.50in 11in; 
		margin:.5in .5in .5in .5in; 
	}
}

body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

-->
</style>
<body onLoad="window.print();" topmargin="0">
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
	
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);	
	String strErrMsg = null;
	String strTemp = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

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
	
String[] astrConvertYear = {"","FIRST YEAR","SECOND YEAR","THIRD YEAR","FOURTH YEAR","FIFTH YEAR","SIXTH YEAR"};
Vector vRetResult = new Vector();
Vector vStudDetail= new Vector();

ReportEnrollment reportEnrl= new ReportEnrollment();

String strCollegeName = null;
vRetResult = reportEnrl.getStudentLoad(dbOP, WI.fillTextValue("stud_id"),WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));	
if(vRetResult == null)
	strErrMsg = reportEnrl.getErrMsg();
else{
	vStudDetail = (Vector)vRetResult.remove(0);	
	strTemp = "select c_name from college join course_offered on (course_offered.c_index = college.c_index) where course_index = "+vStudDetail.elementAt(5);
	strCollegeName = dbOP.getResultOfAQuery(strTemp,0);
}



String astrConvertTerm[] = {"Summer","1st Semester","2nd Semester","3rd Semester"};

if(strErrMsg != null){
dbOP.cleanUP();%>
<table border="0" width="100%">
    <tr>
      <td width="100%"><div align="center"><font size="3"><%=strErrMsg%></font></div></td>
    </tr>
</table>
<%return;}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>	
      <td width="28%" align="right" style="padding-right:20px;"><img src="../../../images/logo/<%=strSchCode%>.gif" border="0" height="70" width="70" align="absmiddle"></td>
      <td width="72%"><strong style="font-size:18px;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
    </tr>
	<tr><td colspan="2" align="center"><strong style="font-size:14px;">Promisory Note</strong><br><br><%=strCollegeName%><br>
	</td></tr>
	<tr>
	    <td colspan="2" align="right" style="padding-right:40px;">&nbsp;</td>
    </tr>
	<tr>
	    <td colspan="2" align="right" style="padding-right:40px;">Date : <%=WI.getTodaysDate(1)%></td>
    </tr>
	<tr>
	    <td align="right" style="padding-right:40px;">&nbsp;</td>
    </tr>
	<tr>
	<%
	strTemp = ConversionTable.replaceString(WI.fillTextValue("amount"),",","");
	%>
	    <td colspan="2" style="text-indent:40px; text-align:justify">
		I/We, <u><%=((String)vStudDetail.elementAt(2)).toUpperCase()%></u> promise to pay the amount of 
		<u><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strTemp),"Pesos","Centavos")%></u> (P <u><%=WI.fillTextValue("amount")%></u>) 
		representing the balance of my		
		school fees for the <u><%=astrConvertTerm[Integer.parseInt(request.getParameter("semester"))]%> 
		SY <%=request.getParameter("sy_from")%> -<%=request.getParameter("sy_to")%></u> 
		as shown below, subject to existing rules and regulations on partial/delayed payments. (Please attach photocopy ID of parents)		</td>
    </tr>
	<tr>
	    <td colspan="2" style="text-indent:40px; text-align:justify">&nbsp;</td>
    </tr>
	<tr>
	    <td colspan="2" align="right" style="padding-right:40px;">Course : <%=((String)vStudDetail.elementAt(3)).toUpperCase()%></td>
    </tr>
	<tr>
	    <td colspan="2" align="right" style="padding-right:40px;">Year Level : <%=astrConvertYear[Integer.parseInt((String)vStudDetail.elementAt(4))]%></td>
    </tr>
	<tr>
	    <td style="text-indent:40px; text-align:justify">&nbsp;</td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="33%">&nbsp;</td>
		<td width="24%">AMOUNT</td>
		<td width="43%">DUE DATE</td>
	</tr>
	<tr>
		<td style="padding-left:60px;"><%=WI.fillTextValue("exam").toUpperCase()%></td>
		<td><%=WI.fillTextValue("amount")%></td>
		<td><%=WI.fillTextValue("dueDate")%></td>
	</tr>
	<tr>
	    <td style="padding-left:60px;">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td height="25" width="21%" style="padding-left:30px;">Student's Signature</td>
		<td width="33%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%"></div></td>
		<td width="18%">Parent's Signature</td>
		<td width="28%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%"></div></td>
	</tr>
	<tr>
	    <td height="25" style="padding-left:30px;">Student's Name</td>
	    <td valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%"><%=((String)vStudDetail.elementAt(2)).toUpperCase()%></div></td>
	    <td>Parent's Name</td>
	    <td valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%"></div></td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="4" height="30">&nbsp;</td></tr>
	<tr>
	    <td width="12%" height="25" valign="bottom">Endorsed by:</td>
        <td width="44%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%"></div></td>
        <td width="12%" valign="bottom">Approved by:</td>
        <td width="32%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%"></div></td>
	</tr>
	<tr>
	    <td>&nbsp;</td>
	    <td valign="top">Cash Services Head/Student's Account</td>
	    <td>&nbsp;</td>
	    <td valign="top">Director for Finance & Controllership</td>
    </tr>
	<tr>
	    <td colspan="4">Cash Services Copy </td>
    </tr>
	<tr>
	    <td colspan="4" style="border-bottom:solid 2px #000000;">&nbsp;</td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>	
      <td width="28%" align="right" style="padding-right:20px;"><img src="../../../images/logo/<%=strSchCode%>.gif" border="0" height="70" width="70" align="absmiddle"></td>
      <td width="72%"><strong style="font-size:18px;"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></td>
    </tr>
	<tr><td colspan="2" align="center"><strong style="font-size:14px;">Promisory Note</strong><br><br><%=strCollegeName%><br>
	</td></tr>
	<tr>
	    <td colspan="2" align="right" style="padding-right:40px;">&nbsp;</td>
    </tr>
	<tr>
	    <td colspan="2" align="right" style="padding-right:40px;">Date : <%=WI.getTodaysDate(1)%></td>
    </tr>
	<tr>
	    <td align="right" style="padding-right:40px;">&nbsp;</td>
    </tr>
	<tr>
	<%
	strTemp = ConversionTable.replaceString(WI.fillTextValue("amount"),",","");
	%>
	    <td colspan="2" style="text-indent:40px; text-align:justify">
		I/We, <u><%=((String)vStudDetail.elementAt(2)).toUpperCase()%></u> promise to pay the amount of 
		<u><%=new ConversionTable().convertAmoutToFigure(Double.parseDouble(strTemp),"Pesos","Centavos")%></u> (P <u><%=WI.fillTextValue("amount")%></u>) 
		representing the balance of my		
		school fees for the <u><%=astrConvertTerm[Integer.parseInt(request.getParameter("semester"))]%> 
		SY <%=request.getParameter("sy_from")%> -<%=request.getParameter("sy_to")%></u> 
		as shown below, subject to existing rules and regulations on partial/delayed payments. (Please attach photocopy ID of parents)		</td>
    </tr>
	<tr>
	    <td colspan="2" style="text-indent:40px; text-align:justify">&nbsp;</td>
    </tr>
	<tr>
	    <td colspan="2" align="right" style="padding-right:40px;">Course : <%=((String)vStudDetail.elementAt(3)).toUpperCase()%></td>
    </tr>
	<tr>
	    <td colspan="2" align="right" style="padding-right:40px;">Year Level : <%=astrConvertYear[Integer.parseInt((String)vStudDetail.elementAt(4))]%></td>
    </tr>
	<tr>
	    <td style="text-indent:40px; text-align:justify">&nbsp;</td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="33%">&nbsp;</td>
		<td width="24%">AMOUNT</td>
		<td width="43%">DUE DATE</td>
	</tr>
	<tr>
		<td style="padding-left:60px;"><%=WI.fillTextValue("exam").toUpperCase()%></td>
		<td><%=WI.fillTextValue("amount")%></td>
		<td><%=WI.fillTextValue("dueDate")%></td>
	</tr>
	<tr>
	    <td style="padding-left:60px;">&nbsp;</td>
	    <td>&nbsp;</td>
	    <td>&nbsp;</td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td height="25" width="21%" style="padding-left:30px;">Student's Signature</td>
		<td width="33%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%"></div></td>
		<td width="18%">Parent's Signature</td>
		<td width="28%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%"></div></td>
	</tr>
	<tr>
	    <td height="25" style="padding-left:30px;">Student's Name</td>
	    <td valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%"><%=((String)vStudDetail.elementAt(2)).toUpperCase()%></div></td>
	    <td>Parent's Name</td>
	    <td valign="bottom"><div style="border-bottom:solid 1px #000000; width:80%"></div></td>
    </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr><td colspan="4" height="30">&nbsp;</td></tr>
	<tr>
	    <td width="12%" height="25" valign="bottom">Endorsed by:</td>
        <td width="44%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%"></div></td>
        <td width="12%" valign="bottom">Approved by:</td>
        <td width="32%" valign="bottom"><div style="border-bottom:solid 1px #000000; width:90%"></div></td>
	</tr>
	<tr>
	    <td>&nbsp;</td>
	    <td valign="top">Cash Services Head/Student's Account</td>
	    <td>&nbsp;</td>
	    <td valign="top">Director for Finance & Controllership</td>
    </tr>
	<tr>
	    <td colspan="4">Student's Copy </td>
    </tr>	
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>
