<%if(request.getSession(false).getAttribute("userIndex") == null){%>
	<p style="font-size:14px; font-weight:bold; color:#FF0000;">You are logged out. Please login again.</p>
<%return;}%>
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
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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

    TABLE.jumboborder {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderRIGHT {
    border-right: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
	
	TD.jumboborderRIGHTBottom {
    border-right: solid 1px #AAAAAA;
    border-bottom: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

	TD.jumboborderBottom {
    border-bottom: solid 1px #AAAAAA;
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
    TABLE.thinborderALL {
    border-left: solid 2px #000000;
    border-right: solid 2px #000000;
    border-top: solid 2px #000000;
    border-bottom: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }


-->
</style>
</head>
<script language="javascript">
function CallOnLoad() {
	document.all.processing.style.visibility='hidden';	
	document.bgColor = "#FFFFFF";
}

</script>
<body topmargin="0" bottommargin="0" onLoad="CallOnLoad();window.print();" bgcolor="#DDDDDD">
<!-- Printing information. -->
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFFFFF">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <label id="page_progress"></label></font></p>
			
			<img src="../../../Ajax/ajax-loader_small_black.gif"></td>
      </tr>
</table>
</div>
<form name="form_">
<%
	String strErrMsg = null;String strTemp = null;
	String strCollegeName = null;
	String strCollegeIndex = null;
	String strCollegeCode = null;
	String strMajorCode = null;
	

	String strSchCode = null;//for UI , do not show remarks.
	//for CLDH, show total enrolled unit instead of remark.


	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};
	String[] astrConvertYr	= {"N/A","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-Enrollment list print","elist_print.jsp");
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
Vector vEnrlInfo = new Vector(); Vector vRetResult = null;
boolean bolShowPageBreak = false;

Vector vEduLevel = null;
int iTotalStud = 0, iMaxSubCount = 0;

//get here the enrollment list.. 
vRetResult = enrlReport.getEnrollmentListBasic(dbOP, request);
if(vRetResult == null)
	strErrMsg = enrlReport.getErrMsg();
else {
	vEduLevel = (Vector)vRetResult.remove(0);
	iMaxSubCount = Integer.parseInt((String)vRetResult.remove(0));	
	iTotalStud   = Integer.parseInt((String)vRetResult.remove(0));	
}

strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
	


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
}

int iDefNoOfRowPerPg = 0;
if(request.getParameter("stud_per_pg") == null)
	iDefNoOfRowPerPg = 25;
else
	iDefNoOfRowPerPg = Integer.parseInt(request.getParameter("stud_per_pg"));

int iNoOfRowPerPg = iDefNoOfRowPerPg;
//if(strSchCode.startsWith("UI") || strSchCode.startsWith("LNU") )
//	iNoOfRowPerPg = 20;

int iStudCount = 1;
int iTemp = iTotalStud;//total no of rows.
//iTemp is not correct -- i have to run a for loop to find number of rows.

int iTotalNoOfPage = iTemp / iNoOfRowPerPg;
if(iTemp%iNoOfRowPerPg > 0) ++iTotalNoOfPage;


int iPageCount = 1;
String strUserIndex = null;
String strPgCountDisp = null;

double dUnitEnrolled = 0d; String strUnit = null;


int i = 0 ; // index for inner loop (student loop) 

String strSubjectsLoad = null;
int iStudNumber = 1;

String strEduLevelName = null;
String strGLevel = null; String strYrLevel = null;
Integer objYrLevel = null;

while(i<vRetResult.size()) {
if(objYrLevel == null) {
	strEduLevelName = (String)vEduLevel.remove(0);
	strYrLevel      = (String)vEduLevel.remove(0);
	strGLevel       = (String)vEduLevel.remove(0);
}
objYrLevel = new Integer(strYrLevel);

//while(true){

	
	%>
	
	<table width="1136" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td colspan="2">
<%if(bolShowPageBreak || i == 0 ) {%>
			<div align="center">
			<font style="font-size:12px; font-weight:bold"> West Negros University</font><br>
		(Formerly West Negros College)<br>
		Bacolod City, Philippines<br><br>
			<strong> DEPED ENROLMENT LIST</strong>
			<br> School Year: 
			<%if(request.getParameter("semester").equals("0")){%>
			Summer, <%}%>
			<%=request.getParameter("sy_from")%> - <%=Integer.parseInt((String)request.getParameter("sy_from")) + 1%>
			</div>
<%}else {--iNoOfRowPerPg;%><br><%}%>
			<strong> <%if(strEduLevelName != null){--iNoOfRowPerPg;%> Department : <%=strEduLevelName%><br><%}%>
			Course : <%=strGLevel%>
			<br>
			</strong>
	</td>
	  </tr>
	</table>
	<table width="1200" border="0" cellpadding="0" cellspacing="0" class="thinborder">
	  <tr>
		<td class="thinborder" width="25">Rec No.</td>
		<td width="90" class="thinborder">Student No.</td>
		<td width="210" class="thinborder">Student Name</td>
		<td width="30" class="thinborder">Sex</td>
		<%
		for(int p = 0; p < iMaxSubCount; ++p){%>
		<td width="50" class="thinborder">Subject</td>
		<td width="30" class="thinborder">Units</td>
		<%}%>
		<td width="55" class="thinborder">Credit Units</td>
	  </tr>
<%
	for(; i<vRetResult.size();++i){// this is for page wise display.
	vEnrlInfo = (Vector)vRetResult.elementAt(i);
	if(vEnrlInfo.indexOf(objYrLevel) == -1) {//different year.. so break out.
		strEduLevelName = (String)vEduLevel.remove(0);
		strYrLevel      = (String)vEduLevel.remove(0);
		strGLevel       = (String)vEduLevel.remove(0);
		
		//bolShowPageBreak = true; 
		break;
	}
	
	if(iNoOfRowPerPg <= 0) {
		bolShowPageBreak = true;
		iNoOfRowPerPg = iDefNoOfRowPerPg;
		break;
	}
	bolShowPageBreak = false;
	dUnitEnrolled = 0d;
	
	--iNoOfRowPerPg;
	%>
	  <tr>
		<td class="thinborder" width="25"><%=iStudNumber++%></td>
		<td class="thinborder"><%=(String)vEnrlInfo.remove(0)%></td>
		<td class="thinborder"><%=(String)vEnrlInfo.remove(0)%></td>
		<td class="thinborder"><%=(String)vEnrlInfo.remove(0)%></td>
		<%vEnrlInfo.remove(0);dUnitEnrolled = 0d;
		for(int p = 0; p < iMaxSubCount; ++p){
		strTemp = "&nbsp;";strUnit = "&nbsp;";
		if(vEnrlInfo.size() > 0) {
			strTemp = (String)vEnrlInfo.remove(0);
			strUnit = (String)vEnrlInfo.remove(0);
			dUnitEnrolled += Double.parseDouble(strUnit);
		}%>
		<td class="thinborder"><%=strTemp%></td>
		<td class="thinborder"><%=strUnit%></td>
		<%}%>
		<td class="thinborder"><%=CommonUtil.formatFloat(dUnitEnrolled, true)%></td>
	  </tr>
	
	<%}%>
	</table>	
<%
if(iNoOfRowPerPg < 3) {
	bolShowPageBreak = true;
	iNoOfRowPerPg = iDefNoOfRowPerPg;
}
if(bolShowPageBreak || i >= vRetResult.size()){%>
	<table width="1136" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td width="1136" align="center">Page count : <%=Integer.toString(iPageCount++)%> of <input type="text" name="_<%=iPageCount%>" class="textbox_noborder" style="font-size:11px;font-weight:normal;" size="5"></td>
	  </tr>
	</table>
<%}
if(bolShowPageBreak){%>
	<!-- introduce page break here -->
	<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%//break;
	}//break only if it is not last page.

//}//end of printing. - outer for loop.

}//end of while(vCollegeInfo.size() > 0)

--iPageCount;
dbOP.cleanUP();
%>

<script language="JavaScript">
function updateTotalPg() {
	var totalPg = <%=iPageCount + 1%>;
	var objLabel; var strTemp;
	for(var i = 2; i <= totalPg; ++i) {
		strTemp = i; 
		eval('objLabel=document.form_._'+i);
		if(!objLabel)
			continue;
		
		objLabel.value = "<%=iPageCount%>";
	}
}
this.updateTotalPg();
alert("Total no of pages to print : <%=iPageCount%>");
</script>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>