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
    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
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
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderRIGHT {
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderLEFTRIGHT {
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderLEFTTOPBOTTOM {
    border-left: solid 1px #000000;
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderRIGHTBOTTOM {
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
    TD.thinborderALL{
    border-left: solid 1px #000000;
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }

-->
</style>
<body topmargin="10" onLoad="window.print();">
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
int iGrYearLevel = Integer.parseInt(WI.getStrValue(WI.fillTextValue("gr_year_level"),"0"));
String strAccountBalance = null;

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
                            WI.fillTextValue("sy_from"),WI.fillTextValue("offering_sem"));
	if(strAdmSlipNumber == null) 
		reportEnrl.getErrMsg();
}
String strExamSchName = dbOP.mapOneToOther("FA_PMT_SCHEDULE","pmt_sch_index",
	WI.fillTextValue("pmt_schedule"),"exam_name",null);
if(strExamSchName != null)
	strExamSchName = strExamSchName.toUpperCase();
	
if(WI.fillTextValue("print_final").equals("1")
	&& strExamSchName.toLowerCase().indexOf("final") != -1){
	strExamSchName = "Fourth Grading";
}


String astrConvertTerm[] = {"SUMMER","FIRST","SECOND","THIRD"};


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

strAccountBalance = "select PAYABLE_AMT from FA_FEE_HISTORY_PMTSCH_NEW where USER_I = "+(String)vStudDetail.elementAt(0)+
" and PMT_SCH = "+WI.fillTextValue("pmt_schedule")+" and SY_FR = "+WI.fillTextValue("sy_from")+" and SEM ="+WI.fillTextValue("offering_sem");
strAccountBalance = dbOP.getResultOfAQuery(strAccountBalance, 0);
//System.out.println(strAccountBalance);
if(strAccountBalance == null)
	strAccountBalance = "&nbsp;";
else {
	if(strAccountBalance.startsWith("-") || strAccountBalance.startsWith("0."))
	  	strAccountBalance = "OK";do
	else	
		strAccountBalance = CommonUtil.formatFloat(strAccountBalance, true);
}

if(strErrMsg != null){dbOP.cleanUP();

%>
<table width="360" border="0">
    <tr>
      <td width="100%"><div align="center"><font size="3"><%=strErrMsg%></font></div></td>
    </tr>
</table>
<%return;}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="4">
	  	<table width="100%" cellpadding="0" cellspacing="0" border="0"><tr>
		  <td width="17%" valign="top"><%=strAdmSlipNumber%></td>
			<td width="66%" align="center" style="font-size:18px; font-weight:bold">
	  		UNIVERSITY OF THE CORDILLERAS<br>
	  		<font style="font-size:12px;">BAGUIO CITY</font> 
	  	</td>
		<td width="17%"><%=strAccountBalance%></td>
		</tr></table>
	  </td>
    </tr>
    <tr> 
      <td height="18" colspan="3">TERM: <%=astrConvertTerm[Integer.parseInt(request.getParameter("offering_sem"))]%>, <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></td>
      <td width="45%">EXAMINATION PERMIT FOR: <strong><%=strExamSchName%></strong></td>
    </tr>
    <tr>
      <td height="18" colspan="3">ID: <%=request.getParameter("stud_id")%></td>
      <td>COURSE: <%=(String)vStudDetail.elementAt(3)%> </td>
    </tr>
    <tr>
      <td height="18" colspan="3">NAME: <%=((String)vStudDetail.elementAt(2)).toUpperCase()%></td>
      <td>YEAR: <%=WI.getStrValue((String)vStudDetail.elementAt(4))%></td>
    </tr>
</table>
	
	<table width="100%" border="0" cellspacing="0" cellpadding="0" height="180">
	<tr><td valign="top">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr valign="top" align="center">
			  <td width="20%" class="thinborderLEFTTOPBOTTOM">SECTION</td>
			  <td width="15%" class="thinborderLEFTTOPBOTTOM">SUBJECT</td>
			  <td width="4%" class="thinborderLEFTTOPBOTTOM">UNIT</td>
			  <td width="10%" class="thinborderLEFTTOPBOTTOM">INSTRUCTOR</td>
			  <td width="20%" class="thinborderLEFTTOPBOTTOM">SECTION</td>
			  <td width="15%" class="thinborderLEFTTOPBOTTOM">SUBJECT</td>
			  <td width="4%" class="thinborderLEFTTOPBOTTOM">UNIT</td>
			  <td width="10%" class="thinborderALL">INSTRUCTOR</td>
			</tr>
			<%
			int iRowsPrinted = 0; int iIndexOf=0;
			for(int i = 0; i < vRetResult.size(); i += 11) {++iRowsPrinted;
				strTemp = (String)vRetResult.elementAt(i);
				if(strTemp.toLowerCase().startsWith("nstp")) {
					iIndexOf = strTemp.indexOf("(");
					if(iIndexOf > -1) 
						strTemp = strTemp.substring(0, iIndexOf);
				}
				%>
				<tr valign="top">
				  <td class="thinborderLEFTRIGHT" height="18"><%=vRetResult.elementAt(i + 3)%></td>
				  <td class="thinborderRIGHT"><%=strTemp%></td>
				  <td class="thinborderRIGHT"><%=vRetResult.elementAt(i + 9)%></td>
				  <td align="center" class="thinborderRIGHT">_________</td>
				  <td class="thinborderRIGHT"><%i += 11; if(vRetResult.size() > i) {%><%=vRetResult.elementAt(i + 3)%><%}else{%>&nbsp;<%}%></td>
				  <td class="thinborderRIGHT"><%if(vRetResult.size() > i) {
						strTemp = (String)vRetResult.elementAt(i);
						if(strTemp.toLowerCase().startsWith("nstp")) {
							iIndexOf = strTemp.indexOf("(");
							if(iIndexOf > -1) 
								strTemp = strTemp.substring(0, iIndexOf);
						}
				  	%>
				  	<%=strTemp%>
					<%}else{%>&nbsp;<%}%></td>
				  <td class="thinborderRIGHT"><%if(vRetResult.size() > i) {%><%=vRetResult.elementAt(i + 9)%><%}else{%>&nbsp;<%}%></td>
				  <td align="center" class="thinborderRIGHT"><%if(vRetResult.size() > i) {%>_________<%}else{%>&nbsp;<%}%></td>
		  		</tr>
			<%}%>
		  <%while(iRowsPrinted < 8) {++iRowsPrinted;%>
				<tr valign="top">
				  <td class="thinborderLEFTRIGHT" height="18">&nbsp;</td>
				  <td class="thinborderRIGHT">&nbsp;</td>
				  <td class="thinborderRIGHT">&nbsp;</td>
				  <td align="center" class="thinborderRIGHT">&nbsp;</td>
				  <td class="thinborderRIGHT">&nbsp;</td>
				  <td class="thinborderRIGHT">&nbsp;</td>
				  <td class="thinborderRIGHT">&nbsp;</td>
				  <td align="center" class="thinborderRIGHT">&nbsp;</td>
				</tr>
		  <%}%>
				<tr valign="top">
				  <td class="thinborderTOP">&nbsp;</td>
				  <td class="thinborderTOP">&nbsp;</td>
				  <td class="thinborderTOP">&nbsp;</td>
				  <td class="thinborderTOP">&nbsp;</td>
				  <td class="thinborderTOP">&nbsp;</td>
				  <td class="thinborderTOP">&nbsp;</td>
				  <td class="thinborderTOP">&nbsp;</td>
				  <td class="thinborderTOP">&nbsp;</td>
				</tr>
      	</table>
	</td></tr>
	</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr valign="top"> 
      <td height="22" width="56%">PLEASE CONTACT THE ACCOUNTING OFFICE FOR SUBJECT(S) ENROLLED BUT NOT INCLUDED HEREIN.</td>
      <td align="right" width="12%">APPROVED: </td>
      <td width="32%"><img src="./uc_school_accountant.jpg" width="298" height="40"></td>
    </tr>
</table>
</body>
</html>
<%
dbOP.cleanUP();
%>
