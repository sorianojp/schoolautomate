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
Vector vStudDetail= null; Vector vOfferingCount = null;
String strAdmSlipNumber = null;

ReportEnrollment reportEnrl= new ReportEnrollment();
vRetResult = reportEnrl.getStudentLoad(dbOP, request.getParameter("stud_id"),request.getParameter("sy_from"),
						request.getParameter("sy_to"),request.getParameter("offering_sem"));

if(vRetResult == null)
	strErrMsg = reportEnrl.getErrMsg();
else {
	vStudDetail = (Vector)vRetResult.remove(0);
	vOfferingCount = (Vector)vStudDetail.remove(7);

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

strTemp = "select exam_name from FA_PMT_SCHEDULE where pmt_sch_index = "+WI.fillTextValue("pmt_schedule");
strExamSchName = dbOP.getResultOfAQuery(strTemp, 0);

String astrConvertTerm[] = {"Summer","First Semester","Second Semester","Third Semester"};

boolean bolIsBasic = false;
if(WI.fillTextValue("is_basic").length() > 0) {
	bolIsBasic = true;
	astrConvertTerm[1] = "";
}


if(strErrMsg != null){
dbOP.cleanUP();%>
<table border="0">
    <tr>
      <td width="100%"><div align="center"><font size="3"><%=strErrMsg%></font></div></td>
    </tr>
</table>
<%return;}%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td align="center">
        <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong> <br>
          <%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false), "", "<br>", "&nbsp;")%>
          <%=WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false), "", "<br>", "&nbsp;")%>
          <%=WI.getStrValue(SchoolInformation.getAddressLine3(dbOP,false,false), "", "<br>", "&nbsp;")%>
      </td>
  </tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr valign="top">
    <td height="21" colspan="2" align="center" style="font-weight:bold"><br>
	<%=strExamSchName%> Permit - <%=astrConvertTerm[Integer.parseInt(request.getParameter("offering_sem"))]%> <%=request.getParameter("sy_from")%> -<%=request.getParameter("sy_to")%>	  </td>
  </tr>
  <tr style="font-weight:bold">
    <td width="69%" height="21">NAME : <%=((String)vStudDetail.elementAt(2)).toUpperCase()%></td>
    <td width="31%" height="21">STUDENT NO: <%=request.getParameter("stud_id")%></td>
  </tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
  <tr style="font-weight:bold">
<%if(!bolIsBasic) {%>
    <td width="5%" height="20" class="thinborder" align="center">CODE</td>
<%}%>
    <td width="10%" class="thinborder" align="center">SUBJECT</td>
    <td width="52%" class="thinborder" align="center">DESCRIPTION</td>
    <td width="5%" class="thinborder" align="center">UNITS</td>
    <td width="8%" class="thinborder" align="center">ROOM</td>
    <td height="15%" width="15%" class="thinborder" align="center">INSTRUCTOR</td>
  </tr>
	<%//System.out.println(vRetResult);
	while(vRetResult.size() > 0) {
	vRetResult.remove(10);vRetResult.remove(8);vRetResult.remove(7);vRetResult.remove(6);vRetResult.remove(5);vRetResult.remove(3);vRetResult.remove(2);%>
	  <tr>
<%if(!bolIsBasic) {%>
	    <td class="thinborder"><%=vOfferingCount.remove(0)%></td>
<%}%>
	    <td class="thinborder"><%=vRetResult.remove(0)%></td>
		<td height="20" class="thinborder"><%=vRetResult.remove(0)%></td>
		<td class="thinborder"><%=vRetResult.remove(1)%></td>
		<td class="thinborder">
		<%
		strTemp = (String)vRetResult.remove(0);
		if(strTemp != null) {
			int iIndexOf = strTemp.lastIndexOf("/");
			strTemp = strTemp.substring(iIndexOf+1, strTemp.length());
		}%>
		<%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td class="thinborder">&nbsp;</td>
	  </tr>
	<%}%>
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
