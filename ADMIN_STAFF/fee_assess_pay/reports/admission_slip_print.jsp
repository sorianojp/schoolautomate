<%
	String strErrMsg = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(false && strErrMsg != null && strErrMsg.equals("4")) {%>
		<p style="font-size:14px;">Page does not exist.</p>
	
	<%return;}

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

	strErrMsg = null;
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
	//if(WI.fillTextValue("print_final").equals("1") && WI.fillTextValue("is_basic").length() > 0)
	//	strTemp = "100";//pmt sch index = 250.
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



if(strErrMsg != null){dbOP.cleanUP();
%>
<table width="100%" border="0">
    <tr>
      <td width="100%"><div align="center"><font size="3"><%=strErrMsg%></font></div></td>
    </tr>
</table>
<%return;}
	int iMaxRows = 11;
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="28" colspan="2"><div align="center"><font size="2"><%=strCollegeName%></font></div></td>
  </tr>
  <tr>
    <td width="40%">&nbsp;</td>
    <td width="60%"><div align="right">&nbsp;<%=WI.getTodaysDateTime()%></div></td>
  </tr>
  <tr>
    <td height="30" colspan="2"><strong><font size="2"><%=strAdmSlipNumber%> <%=WI.getStrValue(strExamSchName,"(",")","")%></font></strong> </td>
  </tr>
</table>
<table width="90%" border="0" cellspacing="0" cellpadding="0" align="center" >

  <tr >
    <td width="42%" height="30" ><div align="center"><strong><font size=2><%=(String)vStudDetail.elementAt(2)%></font></strong></div></td>
  </tr>
  <tr >
    <td height="20" >&nbsp;</td>
  </tr>
</table><br>

<table width="100%" cellpadding="0" cellspacing="0" >
  <tr>
    <td height="25"  width="61%">&nbsp;</td>
    <td  align="center">&nbsp;</td>
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
    <td height="25" width="61%"><%=(String)vRetResult.elementAt(i)%>(<%=strTemp%>)</td>
    <td  align="center">&nbsp; <%if( vRetResult.elementAt(i + 2) != null && ((String)vRetResult.elementAt(i + 2)).compareTo("N/A") == 0){%>
      xxxxxxxxx re-enrolled xxxxxxxxx
      <%}%> </td>
  </tr>
  <%}%>
  <% while (iIndex < iMaxRows){%>
  <tr>
    <td height="25" >&nbsp; </td>
    <td>&nbsp; </td>
  </tr>
  <%iIndex++;}%>
  <tr valign="bottom">
    <td height="30" colspan="2" ><div align="right"><strong>CAROLYN GRACE U. DELARMENTE</strong></div></td>
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
