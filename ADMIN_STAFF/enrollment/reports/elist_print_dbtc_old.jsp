<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
}
/**
<%if(WI.fillTextValue("show_border").compareTo("1") ==0){%>
**/
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.thinborderSP {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
/**
<%}else{%>
**/
    TD.thinborderSP {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
/**
<%}%>
**/
    TABLE.jumboborder {
    border-top: solid 2px #000000;
    border-bottom: solid 2px #000000;
    border-left: solid 2px #000000;
    border-right: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderRIGHT {
    border-right: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderTOP {
    border-top: solid 2px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderTOPex {
    /**border-top: solid 1px #000000;**/
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.jumboborderTOPONLY {
    border-top: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }


-->
</style>
</head>

<body bottommargin="0" onLoad="window.print();">
<%
	String strErrMsg = null;String strTemp = null;
	String strCollegeName = null;
	String strCollegeIndex = null;

	String strSchCode = null;//for UI , do not show remarks.
	//for CLDH, show total enrolled unit instead of remark.


	String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester"};
	String[] astrConvertYr	= {"N/A","First Year","Second Year","Third Year","Fourth Year","Fifth Year","Sixth Year","Seventh Year"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-Enrollment list print","elist_print_dbtc.jsp");
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
//get the enrollment list here.
ReportEnrollment enrlReport = new ReportEnrollment();
Vector vEnrlInfo = new Vector();
boolean bolSeparateName = false;
int iNoOfSubPerRow = 6;
boolean bolShowPageBreak = false;

strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
String strOrigSchooCode = strSchCode;

//strSchCode = "VMUF";
	bolSeparateName = true;
	iNoOfSubPerRow = 20;

Vector vRetResult = enrlReport.getEnrollmentList(dbOP,request,iNoOfSubPerRow,bolSeparateName);//8 subjects in one row -- change it for different no of subjects per row
	//System.out.println(vRetResult);
	
if(vRetResult == null || vRetResult.size() ==0) {
	strErrMsg = enrlReport.getErrMsg();

	if(strErrMsg == null)
		strErrMsg = "Enrollment list not found.";
}

if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0">
<tr>
	<td>
		<font size="4"><%=strErrMsg%></font>
	</td>
</tr>
</table>
<%dbOP.cleanUP();
return;
}%>

<table width=100% border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="20%" height="20">Name Of Institution: </td>
		<td colspan="2" style="font-weight:bold">DON BOSCO TECHNOLOGY CENTER</td>
	</tr>
	<tr>
		<td height="20">Address:</td>
		<td colspan="2" style="font-weight:bold">Punta Princesa, Cebu City</td>
	</tr>
	<tr>
		<td height="20">Institutional Identifier:</td>
		<td width="47%" style="font-weight:bold">07089</td>
	    <td width="33%">Tel. No. &nbsp;&nbsp;&nbsp;<b>272-2910</b></td>
	</tr>
	<tr>
		<td height="20">Sem/Tri: </td>
		<td colspan="2" style="font-weight:bold"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%>, Academic Year <strong><%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></td>
	</tr>
	<tr>
		<td height="20">Course/Program:</td>
		<td colspan="2" style="font-weight:bold">
		<%=request.getParameter("course_name")%>
	<%if(WI.fillTextValue("major_name").length() >0){%>Major in <%=request.getParameter("major_name")%><%}%>		</td>
	</tr>
	<tr>
		<td height="20">Year Level:</td>
		<td colspan="2" style="font-weight:bold"><%=astrConvertYr[Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_level"),"0"))]%></td>
	</tr>
</table>

<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
<%

String strInsertPageBreak = "</table><DIV style='page-break-after:always'>&nbsp;</DIV><table width='100%' cellpadding='0' cellspacing='0' class='thinborder'>";


int iStudCount = 0;
int iDefNoOfRowPerPg = 0;
if(request.getParameter("stud_per_pg") == null)
	iDefNoOfRowPerPg = 18;
else
	iDefNoOfRowPerPg = Integer.parseInt(request.getParameter("stud_per_pg"));

int iNoOfRowPerPg = iDefNoOfRowPerPg;

int iTotalNoOfPage = 0;
int iTotalRows = 0;//I have to find number of subjects.. 

for(int i = 4; i < vRetResult.size(); ++i) {
	vEnrlInfo = (Vector) vRetResult.elementAt(i);
	iTotalRows += ((vEnrlInfo.size() - 7))/2 + 1;
}
//System.out.println("iTotalRows : "+iTotalRows);
iTotalNoOfPage = iTotalRows/iNoOfRowPerPg;
if(iTotalRows % iNoOfRowPerPg > 0 || iTotalRows == 0) 
	++iTotalNoOfPage;
//System.out.println("iTotalNoOfPage : "+iTotalNoOfPage);
//System.out.println("iNoOfRowPerPg : "+iNoOfRowPerPg);
/////////////////// end of computation for total # of pages. ///////////


int iPageCount = 1; double dTotUnit = 0d; boolean bolShowName = false;
String strUserIndex = null;
String strPgCountDisp = null;
vEnrlInfo = new Vector();

for(int i=4; i<vRetResult.size();){//start of Loop3
	iNoOfRowPerPg = iDefNoOfRowPerPg;
	strPgCountDisp = "Page count : "+Integer.toString(iPageCount++) +" of "+Integer.toString(iTotalNoOfPage);
%>
<%if(i > 4){%>
<%=strInsertPageBreak%>
<%}%>

<%	
for(; i<vRetResult.size();++i){//start of Loop2
	if(vEnrlInfo.size() == 0) {
		vEnrlInfo = (Vector) vRetResult.elementAt(i);
		if(vEnrlInfo == null || vEnrlInfo.size() == 0) 
			continue;
		bolShowName = true;
	}
	else
		bolShowName = false;
%>
<%if(i == 4) {%>
		<tr align="center" style="font-weight:bold">
			<td width="5%" rowspan="2" class="thinborder">No</td>
		    <td width="15%" rowspan="2" class="thinborder">Student No </td>
		    <td colspan="3" width="35%" class="thinborder">Student Name </td>
		    <td width="5%" rowspan="2" class="thinborder">Gender</td>
		    <td width="30%" rowspan="2" class="thinborder">Subject Enrolled </td>
		    <td width="10%" rowspan="2" class="thinborder">No. Of Units </td>
	    </tr>
		<tr style="font-weight:bold" align="center">
		  <td class="thinborder" width="12%">Surname</td>
		  <td class="thinborder" width="12%">First Name</td>
		  <td class="thinborder" width="11%">Middle Name</td>
	  </tr>
<%}
if(bolShowName) {
bolShowName = false;
strTemp = (String)vEnrlInfo.elementAt(2);
if(strTemp.toLowerCase().equals("m"))
	strTemp = "Male";
else	
	strTemp = "Female";

	--iNoOfRowPerPg;
%>
		<tr>
		  <td class="thinborder" width="5%"><%=++iStudCount%>.</td>
		  <td class="thinborder" width="15%"><%=vEnrlInfo.elementAt(0)%></td>
		  <td class="thinborder" width="12%"><%=vEnrlInfo.elementAt(6)%></td>
		  <td class="thinborder" width="12%"><%=vEnrlInfo.elementAt(4)%></td>
		  <td class="thinborder" width="11%"><%=WI.getStrValue(vEnrlInfo.elementAt(5),"&nbsp;")%></td>
		  <td class="thinborder" align="center" width="5%"><b><%=strTemp%></b></td>
<%
//all header info removed.. 
vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);

dTotUnit += Double.parseDouble((String)vEnrlInfo.elementAt(1));
%>		  
		  <td class="thinborder" width="30%"><%=vEnrlInfo.remove(0)%></td>
		  <td class="thinborder" align="center" width="10%"><%=CommonUtil.formatFloat((String)vEnrlInfo.remove(0), false)%></td>
	  </tr>
<%}//show only if bolShowName is true

while(vEnrlInfo.size() > 0) {//start of Loop 1
dTotUnit += Double.parseDouble((String)vEnrlInfo.elementAt(1));
%>		
		<tr>
		  <td class="thinborder" width="5%">&nbsp;</td>
		  <td class="thinborder" width="15%">&nbsp;</td>
		  <td class="thinborder" width="12%">&nbsp;</td>
		  <td class="thinborder" width="12%">&nbsp;</td>
		  <td class="thinborder" width="11%">&nbsp;</td>
		  <td class="thinborder" width="5%">&nbsp;</td>
		  <td class="thinborder" width="30%"><%=vEnrlInfo.remove(0)%></td>
		  <td class="thinborder" align="center" width="10%"><%=CommonUtil.formatFloat((String)vEnrlInfo.remove(0), false)%></td>
	  </tr>
<%	--iNoOfRowPerPg;
	if(iNoOfRowPerPg <= 0) {
		bolShowPageBreak = true;
		break;
	}
}//end of Loop 1
if(vEnrlInfo.size() == 0) {//print total.. %>
		<tr style="font-weight:bold" align="center">
		  <td class="thinborder" width="5%">&nbsp;</td>
		  <td class="thinborder" width="15%">&nbsp;</td>
		  <td class="thinborder" width="12%">&nbsp;</td>
		  <td class="thinborder" width="12%">&nbsp;</td>
		  <td class="thinborder" width="11%">&nbsp;</td>
		  <td class="thinborder" width="5%">&nbsp;</td>
		  <td class="thinborder" align="right" width="30%">TOTAL &nbsp;</td>
		  <td class="thinborder" width="10%"><%=CommonUtil.formatFloat(dTotUnit, false)%></td>
	  </tr>
<%dTotUnit = 0d;
--iNoOfRowPerPg;}

	if(iNoOfRowPerPg <= 0) {
		bolShowPageBreak = true;
		break;
	}
}//end of Loop2

%>
</table>
<div align="right"><%=strPgCountDisp%></div>
<table width="100%">
	<tr>
		<td width="17%">Certified correct by:</td>
		<td width="37%" align="center">		</td>
		<td width="46%">&nbsp;</td>
	</tr>
	<tr>
	  <td>&nbsp;</td>
	  <td align="center"><u>&nbsp;&nbsp;<%=CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7)%>&nbsp;&nbsp;</u><br>
								Registrar</td>
	  <td>&nbsp;</td>
  </tr>
</table>

<%}%>








<script language="JavaScript">
alert("Total no of pages to print : <%=iTotalNoOfPage%>");
//window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>
