	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
	<head>
	<title>Untitled Document</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<style type="text/css">
	@media print { 
	  @page {
			margin-bottom:.1in;
			margin-top:0in;
			margin-left:.5in;
			margin-right:.5in;
		}
	}
	<!--
	body {
		/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
		font-size: 9px;
	}
	td {
		/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
		font-size: 9px;
	}
	th {
		/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
		font-size: 9px;
	}
		TABLE.thinborder {
			border-top: solid 1px #000000;
			border-right: solid 1px #000000;
			/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
			font-size: 9px;
		}
		TABLE.thinborderALL {
			border-top: solid 1px #000000;
			border-bottom: solid 1px #000000;
			border-left: solid 1px #000000;
			border-right: solid 1px #000000;
			/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
			font-size: 9px;
		}
		TD.thinborder {
			border-left: solid 1px #000000;
			border-bottom: solid 1px #000000;
			/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
			font-size: 9px;
		}
	
		TD.thinborderBottom {
			border-bottom: solid 1px #000000;
			/*font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;*/
	font-family: "Times New Roman";
			font-size: 9px;
		}
	-->
	</style>
	
	</head>
	<script language="javascript">
	function CallOnLoad() {
		document.all.processing.style.visibility='hidden';	
		document.bgColor = "#FFFFFF";
	}
	var strMaxPage = null;
	var objLabel   = null;
	function ShowProgress(pageCount, maxPage) {
		if(objLabel == null) {
			objLabel = document.getElementById("page_progress");
			strMaxPage = maxPage;
		}
		if(!objLabel)
			return;
		var strShowProgress = pageCount+" of "+strMaxPage;
		objLabel.innerHTML = strShowProgress;
	}
	</script>
<body onLoad="CallOnLoad();window.print();" bgcolor="#DDDDDD">

<!-- Printing information. -->
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <label id="page_progress"></label></font></p>
			
			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>

<%@ page language="java" import="utility.*,enrollment.GradeSystem,enrollment.FAPaymentUtil,java.util.Vector " %>
<%
	String strErrMsg = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strStudInfoList = (String)request.getSession(false).getAttribute("stud_list");
	
	if(strStudInfoList == null || strStudInfoList.length() == 0) 
		strErrMsg = "Student List not found.";
	else if(strSchCode == null) 
		strErrMsg = "You are already logged out. please login again.";
		
		
	if(strErrMsg != null)  {%>
	<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold"><%=strErrMsg%></p>
	<%
		return; 
	}
	//request.getSession(false).removeAttribute("stud_list");

	DBOperation dbOP  = null;
	WebInterface WI   = new WebInterface(request);
	
//add security here.
	try {
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"), 
								"Admin/staff-Registrar Management-GRADES-Grade Releasing print", "grade_releasing_print.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_add.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	

	


String strSYFrom      = request.getParameter("sy_from");
String strSYTo        = request.getParameter("sy_to");
String strSemester    = request.getParameter("semester");
String strGradeFor    = request.getParameter("grade_for");
String strTermName    = request.getParameter("sem_name");

Vector vStudList = CommonUtil.convertCSVToVector(strStudInfoList, ",", true);

boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");


String strPrintURL = "./grade_releasing_print_swu.jsp";
if(!bolIsFinal)
	strPrintURL = "./grade_releasing_print_swu_midterm.jsp";

strPrintURL += "?grade_for="+strGradeFor+
				"&swu_print_count=1"+
				"&grade_name="+WI.fillTextValue("grade_name")+
				"&print_report_card="+WI.fillTextValue("print_report_card")+
				"&sem_name="+strTermName+
				"&sy_from="+strSYFrom+
				"&sy_to="+strSYTo+
				"&semester="+strSemester;
strPrintURL += "&stud_id=";	
int iCount =0 ;
int iStudCount = vStudList.size();
while(vStudList.size() > 0) {
	//strPrintURL += "&stud_id="+(String)vStudList.remove(0);	
	%>
	<script language="javascript">
		ShowProgress(<%=(++iCount)%>, <%=iStudCount%>);
	</script>
		
		<jsp:include page="<%=strPrintURL+(String)vStudList.remove(0)%>" />
	
	<%if(vStudList.size() > 0){%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}%>
<%}	%>

</body>
</html>

<%
dbOP.cleanUP();
%>