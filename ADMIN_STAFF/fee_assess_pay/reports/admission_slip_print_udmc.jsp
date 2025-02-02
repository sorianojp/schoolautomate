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

-->
</style>
<body onLoad="CloseWnd();">
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
	vStudDetail = (Vector)vRetResult.elementAt(0);
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

String	strCollegeName = null;
if(vStudDetail != null && vStudDetail.size() > 0) {
	strCollegeName =
		new enrollment.CurriculumMaintenance().getCollegeName(dbOP,(String)vStudDetail.elementAt(5));

	if(strCollegeName != null && !strCollegeName.equals("<NOT FOUND>"))
		strCollegeName = strCollegeName.toUpperCase();
	else{
		if (iGrYearLevel==1)
			strGrYearLevel = "(Preparatory)";
		else if (iGrYearLevel==2 )
			strGrYearLevel = "(Elementary)";
		else if (iGrYearLevel>=3)
			strGrYearLevel = "(High School)";

		strCollegeName = "<strong>BASIC EDUCATION DEPARTMENT " + strGrYearLevel + " </strong>";
	}
}


String astrConvertTerm[] = {"Summer","1st Semester","2nd Semester","3rd Semester"};

if(strErrMsg != null){dbOP.cleanUP();
%>
<table width="360" border="0">
    <tr>
      <td width="100%"><div align="center"><font size="3"><%=strErrMsg%></font></div></td>
    </tr>
</table>
<%return;}
	int iMaxRows = 15;
%>

<table border="0" cellpadding="0" cellspacing="0" width="360">
  <tr>
    <td height="28" colspan="2"><div align="center"><font size="2"><%=strCollegeName%></font></div></td>
  </tr>
  <tr>
    <td width="49%" height="20">&nbsp;</td>
    <td width="51%">&nbsp;</td>
  </tr>
  <tr>
    <td height="20" colspan="2" align="center"><%=astrConvertTerm[Integer.parseInt(request.getParameter("offering_sem"))]%> <%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></td>
  </tr>
  <tr>
    <td height="25" colspan="2"><strong><font size="2"><%=strAdmSlipNumber%> <%=WI.getStrValue(strExamSchName,"(",")","")%></font></strong> </td>
  </tr>
</table>
<table border="0" cellspacing="0" cellpadding="0" width="360'">
  <tr >
    <td width="66%" height="30" style="font-size:14px; font-weight:bold"><%=(String)vStudDetail.elementAt(2)%></td>
    <td width="34%" ><%=(String)vStudDetail.elementAt(6)%>-<%=(String)vStudDetail.elementAt(4)%></td>
  </tr>
</table>

<table cellpadding="0" cellspacing="0" width="360">
  <tr style="font-weight:bold">
    <td height="20"  width="38%">Subject</td>
    <td width="39%">Name of Professor </td>
    <td width="23%"  align="center">Signature</td>
  </tr>
  <tr style="font-weight:bold">
    <td height="20"  width="38%">&nbsp;</td>
    <td width="39%"  align="center">&nbsp;</td>
    <td width="23%"  align="center">&nbsp;</td>
  </tr>
  <%
 int iTotalLoad = 0;//System.out.println(vRetResult);
 int iIndex = 0;int i = 0;
 for( iIndex=1,i=1; i< vRetResult.size(); i += 11, iIndex++){
 //do not show the re-enrolled subjects.
 strTemp =(String)vRetResult.elementAt(i+1);
 if (strTemp.length() > 40)	strTemp = strTemp.substring(0,38)+"..";
 %>
  <tr>
    <td height="20" width="38%"><%=(String)vRetResult.elementAt(i)%></td>
    <td>
	<%strTemp = (String)vRetResult.elementAt(i + 6);
	if(strTemp != null) {
		int iIndexOf = strTemp.indexOf(",");
		if(iIndexOf > -1)
			strTemp = strTemp.substring(0,iIndexOf);
	}
	if( strTemp!= null){%>
		<font size="1"><%=strTemp%></font>
	<%}else{%><hr size="1" width="80%"><%}%></td>
    <td  align="center"><hr size="1" width="80%"></td>
  </tr>
  <%}%>
  <% while (iIndex < iMaxRows){%>
  <tr>
    <td height="28">&nbsp; </td>
    <td>&nbsp;</td>
    <td>&nbsp; </td>
  </tr>
  <%iIndex++;}%>
  <tr>
    <td height="15" colspan="3" ><div align="right"><strong><%=CommonUtil.getName(dbOP,(String)request.getSession(false).getAttribute("userId"),4)%></strong></div></td>
  </tr>
</table>
<script src="../../../jscript/common.js"></script>
<script language="JavaScript">
//get this from common.js
this.autoPrint();

this.closeWnd = 1;
</script>

</body>
</html>
<%
dbOP.cleanUP();
%>
