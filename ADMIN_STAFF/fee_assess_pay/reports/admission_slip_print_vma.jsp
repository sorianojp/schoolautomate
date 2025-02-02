<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
	try
	{
		dbOP = new DBOperation();
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
Vector vRetResult = null;
Vector vStudDetail= null;
String strAdmSlipNumber = null;
String strGrYearLevel = "";

ReportEnrollment reportEnrl= new ReportEnrollment();
vRetResult = reportEnrl.getStudentLoad(dbOP, request.getParameter("stud_id"),request.getParameter("sy_from"),
						request.getParameter("sy_to"),request.getParameter("offering_sem"));

if(vRetResult == null)
	strErrMsg = reportEnrl.getErrMsg();
else {
	vStudDetail = (Vector)vRetResult.remove(0);
	//get admission slip number here and as well save the information.
	strTemp = WI.fillTextValue("pmt_schedule");
	if(WI.fillTextValue("print_final").equals("1") && WI.fillTextValue("is_basic").length() > 0)
		strTemp = "100";//pmt sch index = 250.
	//System.out.println(strTemp);
	strAdmSlipNumber = reportEnrl.autoGenAdmSlipNum(dbOP,
							(String)vStudDetail.elementAt(0),strTemp,
                            WI.fillTextValue("sy_from"),WI.fillTextValue("offering_sem"),
                            (String)request.getSession(false).getAttribute("userIndex"));
	if(strAdmSlipNumber == null)
		reportEnrl.getErrMsg();
}
String strExamSchName = null;
String strExamDate    = null;

strTemp = "select EXAM_SCHEDULE, exam_name from FA_PMT_SCHEDULE where pmt_sch_index = "+WI.fillTextValue("pmt_schedule");
try {
	if(WI.fillTextValue("pmt_schedule").length() > 0) {
		java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
		if(rs.next()) {
			strExamSchName = rs.getString(2);
			strExamDate    = ConversionTable.convertMMDDYYYY(rs.getDate(1), true);
		}
		rs.close();
		//problem here, I have to search for if it is set per course..

		//1. Find if it is set per semester..
		strTemp = "select EXAM_SCHEDULE  from FA_PMT_SCHEDULE_EXTN where pmt_sch_index = "+WI.fillTextValue("pmt_schedule")+
			" and SY_FROM = "+WI.fillTextValue("sy_from")+" and semester="+WI.fillTextValue("offering_sem")+
			" and is_valid = 1";
		rs = dbOP.executeQuery(strTemp);
		if(rs.next())
			strExamDate    = ConversionTable.convertMMDDYYYY(rs.getDate(1), true);
		rs.close();

		//2. I have to find it now per course.
		 strTemp = "select EXAM_SCHEDULE  from FA_PMT_SCH_EXTN_COURSE where pmt_sch_index = "+WI.fillTextValue("pmt_schedule")+
			" and COURSE_INDEX = "+vStudDetail.elementAt(5)+" and semester="+WI.fillTextValue("offering_sem")+
			" and is_valid = 1";
		rs = dbOP.executeQuery(strTemp);
		if(rs.next())
			strExamDate    = ConversionTable.convertMMDDYYYY(rs.getDate(1), true);
		rs.close();

	}
}
catch(java.sql.SQLException sqlE) {}

String astrConvertTerm[] = {"Summer","1st Sem","2nd Sem","3rd Sem"};
boolean bolIsBasic = false;
if (WI.fillTextValue("is_basic").equals("1"))
	bolIsBasic = true;

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

if(strExamSchName != null) {
	strExamSchName = strExamSchName.toUpperCase();
	if(strSchCode.startsWith("AUF"))
		strExamSchName += "S";
}

boolean bolIsWUP = strSchCode.startsWith("WUP");
String strFontSize = "11px";
if(bolIsWUP)
	strFontSize = "9px";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>;
    }

-->
</style>
<body onLoad="window.print();" topmargin="10">
<%
if(strErrMsg != null){dbOP.cleanUP();
%>
<table border="0">
    <tr>
      <td width="100%"><div align="center"><font size="3"><%=strErrMsg%></font></div></td>
    </tr>
</table>
<%return;}%>
<table width="50%" border="0" cellpadding="0" cellspacing="0">
  <tr valign="top">
    <td height="21" colspan="2" align="center" style="font-size:14px; font-weight:bold">
	VMA Global College<br>
	<font style="font-size:11px; font-weight:normal">Asian Mari-Tech Development Corporation<br>Bacolod City</font></td>
    <td rowspan="2" align="center" style="font-size:14px; font-weight:bold">
			<table width="100%" cellpadding="0" cellspacing="0" class="thinborderALL">
				<tr><td style="font-size:9px;">
					Form ID: ACCTG 0022<br>
					Rev. No.: 01<br>
					Rev. Date: 08/14/01</td>
				</tr>
			</table>
	</td>
  </tr>
  <tr valign="top">
    <td colspan="2" align="center" style="font-size:14px; font-weight:bold">
	STUDENT EXAMINATION PERMIT	</td>
  </tr>

  <tr valign="top">
    <td height="21" colspan="3" align="right" valign="bottom">Permit No :
	<%if(strSchCode.startsWith("WUP")){%><font style="font-size:11px;"><%}%>
	<%=strAdmSlipNumber%><%if(strSchCode.startsWith("WUP")){%></font><%}%> &nbsp;&nbsp;&nbsp;</td>
  </tr>
  <tr valign="top">
    <td colspan="3" valign="bottom" style="font-size:11px; font-weight:bold">
	Student: <u><%=((String)vStudDetail.elementAt(2)).toUpperCase()%> [<%=request.getParameter("stud_id")%>]</u></td>
  </tr>
  <tr valign="top">
    <td height="21" colspan="3">Course : <%=(String)vStudDetail.elementAt(3)%> <%=WI.getStrValue((String)vStudDetail.elementAt(4), " - ", "","")%></td>
  </tr>
  <tr valign="top">
    <td height="21" colspan="3" valign="bottom">SY: <%=request.getParameter("sy_from")%> -<%=request.getParameter("sy_to")%>, <%=astrConvertTerm[Integer.parseInt(request.getParameter("offering_sem"))]%>	</td>
  </tr>
  <tr valign="top">
    <td height="21" colspan="3" valign="bottom">Term: <%=strExamSchName%></td>
  </tr>
<%if(!bolIsWUP){%>
  <tr valign="top">
    <td width="40%" height="21"></td>
    <td width="31%"></td>
    <td width="29%" height="21">&nbsp;</td>
  </tr>
<%}%>
</table>
<table width="50%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr>
    <td height="22" width="50%" class="thinborder" align="center">SUBJECT</td>
    <td width="25%" class="thinborder" align="center">Proctor's Signature </td>
    <td width="25" class="thinborder" align="center">Remarks</td>
  </tr>
	<%int iRowsPrinted = 0;
	while(vRetResult.size() > 0) {%>
	  <tr>
		<td height="20" class="thinborder"><%=(String)vRetResult.remove(0)%>
			<%for(int i =0; i < 10; ++i, ++iRowsPrinted)
				vRetResult.removeElementAt(0);%>		</td>
		<td class="thinborder">&nbsp;</td>
	    <td class="thinborder">&nbsp;</td>
	  </tr>
	<%}%>
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>
