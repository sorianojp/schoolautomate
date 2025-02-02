<%@ page language="java" import="utility.*,health.SchoolSpecific,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";

	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Students Affairs-Guidance-Reports-Other(Hepa/xRay)","hepa_xray.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
SchoolSpecific SS = new SchoolSpecific();
boolean bolIsHepa = WI.fillTextValue("test_type").equals("1");
if(WI.fillTextValue("sy_from").length() > 0) {
	vRetResult = SS.xRayHepaBReport(dbOP, request, 4);
	if(vRetResult == null)
		strErrMsg = SS.getErrMsg();
}

String[] astrConvertToTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Student</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFTTOPBOTTOM {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderALL {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
-->
</style>
</head>
<body onLoad="window.print();">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td height="83"><div align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
        <!--TIN - 004-005-307-000-NON-VAT-->
        <%=SchoolInformation.getInfo1(dbOP,false,false)%><br>
		<%=dbOP.getResultOfAQuery("select c_name from college where c_index="+request.getParameter("c_index"),0)%> - 
		SY/ Term : <%=request.getParameter("sy_from") + " - "+ request.getParameter("sy_to")%>, 
		<%=astrConvertToTerm[Integer.parseInt(request.getParameter("semester"))]%>
		<br>
        <strong> 
		<%if(WI.fillTextValue("report_name").length() == 0){%>
		<%if(!bolIsHepa){%>X-RAY<%}else{%>HEPA-B<%}%> Report
		<%}else{%>
			<%=request.getParameter("report_name")%>
		<%}%>		
		</strong></font></div></td>
  </tr>
</table>
<%if(strErrMsg != null) {%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <%}
if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    
    <tr> 
      <td height="25" colspan="2" bgcolor="#B9B292"><div align="center"><strong><font color="#FFFFFF">SEARCH RESULT</font></strong></div></td>
    </tr>
    <tr> 
      <td width="69%" ><b> Total Students : <%=vRetResult.size()/10%></b></td>
      <td width="31%">&nbsp; </td>
    </tr>
  </table>
<%if(bolIsHepa){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="9%" height="25" rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Student ID</td>
      <td width="15%" rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Student Name</td>
      <td width="30%" rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Screening</td>
      <td width="16%" colspan="4" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Dosage</td>
      <td width="25%" rowspan="2" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Remarks</td>
    </tr>
    <tr>
      <td align="center" width="4%" style="font-size:9px; font-weight:bold" class="thinborder">1</td>
      <td align="center" width="4%" style="font-size:9px; font-weight:bold" class="thinborder">2</td>
      <td align="center" width="4%" style="font-size:9px; font-weight:bold" class="thinborder">3</td>
      <td align="center" width="4%" style="font-size:9px; font-weight:bold" class="thinborder">Booster</td>
    </tr>
    <%
for(int i=0; i<vRetResult.size(); i+=10){
if(WI.getStrValue(vRetResult.elementAt(i + 4)).equals("1"))
	strTemp = " <img src='../../../../images/tick.gif'>";
else
	strTemp = "&nbsp;";
if(WI.getStrValue(vRetResult.elementAt(i + 5)).equals("1"))
	strErrMsg = " <img src='../../../../images/tick.gif'>";
else
	strErrMsg = "&nbsp;";
%>
    <tr> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 3), "&nbsp;")%></td>
      <td class="thinborder" align="center"><%=strTemp%></td>
      <td class="thinborder" align="center"><%=strErrMsg%></td>
<%
if(WI.getStrValue(vRetResult.elementAt(i + 6)).equals("1"))
	strTemp = "<img src='../../../../images/tick.gif'>";
else
	strTemp = "&nbsp;";
if(WI.getStrValue(vRetResult.elementAt(i + 7)).equals("1"))
	strErrMsg = "<img src='../../../../images/tick.gif'>";
else
	strErrMsg = "&nbsp;";
%>
      <td class="thinborder" align="center"><%=strTemp%></td>
      <td class="thinborder" align="center"><%=strErrMsg%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 9), "&nbsp;")%></td>
    </tr>
    <%}%>
  </table>
<%}else{//xray%>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
      <td  width="15%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Student ID</td>
      <td width="25%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Student Name</td>
      <td width="35%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Result</td>
      <td width="25%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">Remarks</td>
    </tr>
    
<%for(int i=0; i<vRetResult.size(); i+=10){%>
    <tr> 
      <td height="25" class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 9), "&nbsp;")%></td>
    </tr>
    <%}%>
  </table>
<%}//else - xRay.%>

<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="100%" height="41" valign="bottom"><u><%=(String)request.getSession(false).getAttribute("first_name")%></u></td>
      <td width="100%" height="41">&nbsp;</td>
    </tr>
    <tr> 
      <td width="100%" height="32" valign="bottom">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Received by</td>
      <td width="100%" height="32" valign="bottom" align="right">Prepared by &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
  </table>
<%}//end of display. %>
</body>
</html>
<%
dbOP.cleanUP();
%>