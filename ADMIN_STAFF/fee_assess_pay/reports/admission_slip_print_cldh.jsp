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

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFT {
    border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderLEFTBOTTOM {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
<body onLoad="CloseWnd();" topmargin="10">
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
String strExamSchName = dbOP.mapOneToOther("FA_PMT_SCHEDULE","pmt_sch_index",
	WI.fillTextValue("pmt_schedule"),"exam_name",null);
if(strExamSchName != null)
	strExamSchName = strExamSchName.toUpperCase();

if(WI.fillTextValue("print_final").equals("1")
	&& strExamSchName.toLowerCase().indexOf("final") != -1){
	strExamSchName = "Fourth Grading";
}


String astrConvertTerm[] = {"Summer","1st Semester","2nd Semester","3rd Semester"};


String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

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
      <td height="25" colspan="4" style="font-size:13px; font-weight:bold">
<%if(strSchCode.startsWith("CLDH")){%>
	  	CENTRAL LUZON DOCTORS&#8217; HOSPITAL EDUCATIONAL INSTITUTION, INC
<%}else if(strSchCode.startsWith("VMUF")){%>
	  	VIRGEN MILAGROSA UNIVERSITY FOUNDATION
<%}%>
	  </td>
    </tr>
    <tr>
      <td height="22" colspan="3">EXAMINATION PERMIT NUMBER : <%=strAdmSlipNumber%></td>
      <td width="50%">COURSE : <%=(String)vStudDetail.elementAt(6)%></td>
    </tr>
    <tr>
      <td height="25" colspan="3">SEMESTER : <%=astrConvertTerm[Integer.parseInt(request.getParameter("offering_sem"))]%> </td>
      <td height="25">S.Y. :<%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></td>
    </tr>
    <tr>
      <td height="10" colspan="3">&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
  </table>


<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="20" style="font-size:12px; font-weight:bold"><u><%=request.getParameter("stud_id")%></u></td>
    <td style="font-size:12px; font-weight:bold"><u><%=((String)vStudDetail.elementAt(2)).toUpperCase()%></u></td>
  </tr>
  <tr valign="top">
    <td width="28%" height="20"><font size="1">STUD NUMBER</font></td>
    <td width="72%"><font size="1">STUDENT NAME </font></td>
  </tr>
  <tr valign="top">
    <td height="21" colspan="2" align="center" style="font-size:15px; font-weight:bold"><%=strExamSchName.toUpperCase()%> EXAMINATION
    </td>
  </tr>
</table>
<table width="100%" cellpadding="0" cellspacing="0" border="0">
  <tr>
    <td valign="top"> <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
        <tr>
          <td height="25" width="20%" class="thinborder"><u>SUBJECT</u></td>
          <td height="25" width="15%" class="thinborder"><u>PROF. SIGNATURE</u></td>
          <td height="25" width="20%" class="thinborder"><u>SUBJECT</u></td>
          <td height="25" width="15%" class="thinborder"><u>PROF. SIGNATURE</u></td>
        </tr>
        <tr>
          <td height="23" class="thinborder">
            <%if(vRetResult.size() > 0){%>
            <%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
          <td class="thinborder">
            <%if(vRetResult.size() > 0){%>
            <%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
        </tr>
        <tr>
          <td height="23" class="thinborder">
            <%if(vRetResult.size() > 0){%>
            <%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
          <td class="thinborder">
            <%if(vRetResult.size() > 0){%>
            <%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
        </tr>
        <tr>
          <td height="23" class="thinborder">
            <%if(vRetResult.size() > 0){%>
            <%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
          <td class="thinborder">
            <%if(vRetResult.size() > 0){%>
            <%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
        </tr>
        <tr>
          <td height="23" class="thinborder">
            <%if(vRetResult.size() > 0){%>
            <%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
          <td class="thinborder">
            <%if(vRetResult.size() > 0){%>
            <%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
        </tr>
        <tr>
          <td height="23" class="thinborder">
            <%if(vRetResult.size() > 0){%>
            <%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
          <td class="thinborder">
            <%if(vRetResult.size() > 0){%>
            <%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
        </tr>
        <tr>
          <td height="23" class="thinborder">
            <%if(vRetResult.size() > 0){%>
            <%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
          <td class="thinborder">
            <%if(vRetResult.size() > 0){%>
            <%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
        </tr>
        <tr>
          <td height="23" class="thinborder">
            <%if(vRetResult.size() > 0){%>
            <%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
          <td class="thinborder">
            <%if(vRetResult.size() > 0){%>
            	<%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i)
				vRetResult.removeElementAt(0);
			}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
        </tr>
<%while(vRetResult.size() > 0) {%>
        <tr>
          <td height="23" class="thinborder">
            <%if(vRetResult.size() > 0){%>
            <%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i) vRetResult.removeElementAt(0);}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
          <td class="thinborder">
            <%if(vRetResult.size() > 0){%>
            	<%=(String)vRetResult.elementAt(0)%>
            <%for(int i =0; i < 11; ++i)
				vRetResult.removeElementAt(0);
			}else{%>
            &nbsp;
            <%}%>
          </td>
          <td class="thinborder">&nbsp;</td>
        </tr>
<%}%>
	  </table>

	  <br><br>
<%
boolean bolIsFinal = false;
if(strExamSchName.toUpperCase().startsWith("FINAL"))
	bolIsFinal = true;
%>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(strSchCode.startsWith("CLDH")){
	if(bolIsFinal){%>
				<tr>
					<td width="50%" align="center">____________________</td>
					<td width="50%" align="center">____________________</td>
				</tr>
				<tr>
				  <td align="center">SAO</td>
				  <td align="center">DEAN</td>
			  </tr>
	<%}%>
			  <tr>
				  <td align="center" height="30" valign="bottom"><%if(bolIsFinal){%>____________________<%}%></td>
				  <td align="center" height="30" valign="bottom">____________________</td>
			  </tr>
				<tr>
				  <td align="center"><%if(bolIsFinal){%>LIBRARY<%}%></td>
				  <td align="center">ACCOUNTING</td>
			  </tr>
<%}//show only if cldh..
else if(strSchCode.startsWith("VMUF")){%>
				<tr>
					<td width="50%" align="center">____________________</td>
					<td width="50%" align="center">____________________</td>
				</tr>
				<tr>
				  <td align="center">ASSESSMENT OFFICER</td>
				  <td align="center">HEAD BUSINESS OFFICE</td>
			  </tr>
<%}%>
		</table>
    </td>
    <td width="25%" valign="top"> <table width="100%" border="0" cellspacing="0" cellpadding="0">
        <tr>
          <td width="5%" valign="top">&nbsp;</td>
          <td width="95%" height="163" valign="top" align="justify">1.) An examination taken without
            the Professor&#8217;s signature on this permit is invalid.
            <p>2.) The permit is non-transferable and should bear the authorized
              signature of the accounting officer.</p>
            <p>3.) If the permit is destroyed, lost or misplaced, a duplicate
              may be issued upon payment of P100.00 to the school cashier.<br>
          </p></td>
        </tr>
        <tr>
          <td valign="bottom">&nbsp;</td>
          <td height="25" valign="bottom">A V O I D &nbsp;&nbsp;P E N A L T Y</td>
        </tr>
        <tr>
          <td valign="bottom">&nbsp;</td>
          <td height="10" valign="bottom">&nbsp;</td>
        </tr>
        <tr>
          <td valign="bottom">&nbsp;</td>
          <td height="25" valign="bottom">Date and Time Printed :<br> <%=WI.getTodaysDateTime()%></td>
        </tr>
      </table></td>
  </tr>
</table>





<script src="../../../jscript/common.js"></script>
<script language="JavaScript">
this.autoPrint();
this.closeWnd = 1;
</script>

</body>
</html>
<%
dbOP.cleanUP();
%>
