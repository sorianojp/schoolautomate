<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;

	//get offerings.. 
	String strSYFrom      = WI.fillTextValue("sy_from");
	String strSemester    = WI.fillTextValue("semester");
	String strPmtSchIndex = WI.fillTextValue("pmt_schedule");
	
	if(strSYFrom.length() == 0 || strSemester.length() == 0 || strPmtSchIndex.length() == 0) {
		%>
		<p style="font-size:14px; color:#FF0000; font-weight:bold">SY-Term/ Exam Schedule missing</p>
	<%return;}
	if(request.getSession(false).getAttribute("userIndex") == null) {
		%>
		<p style="font-size:14px; color:#FF0000; font-weight:bold">You are logged out. please login again.</p>
	<%return;}

String strFontSize = WI.fillTextValue("font_size");
if(strFontSize.length() == 0)
	strFontSize = "10";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Admission Slip Batch Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style>
	body {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=strFontSize%>px;
	}
	
	td {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=strFontSize%>px;
	}
	
	th {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=strFontSize%>px;
	}
	
	.bodystyle {
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: <%=strFontSize%>px;
	}
    TD.thinborderNONE {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;	
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

</style>


</head>

<script language="javascript" src="../../../jscript/common.js"></script>
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
<body topmargin="0" bottommargin="0" onLoad="CallOnLoad();window.print();" bgcolor="#DDDDDD">
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
<%
	DBOperation dbOP = null;
	String strTemp = null;
	
	//add security here.
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	String strExamName = "select exam_name from fa_pmt_schedule where pmt_sch_index = "+WI.fillTextValue("pmt_schedule");
	strExamName = dbOP.getResultOfAQuery(strExamName, 0);
	request.setAttribute("exam_name_",strExamName);
	
	//get all offering here. 
	Vector vSubSecList = new Vector();
	
	String strSQLQuery = "select EAC_EXAM_ASSIGNMENT.SUB_SEC_INDEX from EAC_EXAM_ASSIGNMENT "+
						"join EAC_EXAM_SCHED on (EAC_EXAM_SCHED.sched_index = EAC_EXAM_ASSIGNMENT.sched_index ) "+
						"join e_sub_section on (EAC_EXAM_ASSIGNMENT.sub_sec_index = e_sub_section.sub_sec_index) "+
						"join subject on (subject.sub_index = e_sub_section.sub_index) "+
						"join e_room_detail on (e_room_detail.room_index = EAC_EXAM_ASSIGNMENT.room_ref) "+
						" where PMT_SCH_INDEX = "+strPmtSchIndex+" and sy_from = "+strSYFrom+" and semester = "+strSemester+
						" order by exam_date, exam_time_fr, sub_code, room_number";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	while(rs.next())  
		vSubSecList.addElement(rs.getString(1));
	rs.close();
	
	if(vSubSecList.size() == 0) {
		%>
		<p style="font-size:14px; color:#FF0000; font-weight:bold">Exam Schedule not found. Please check detail list before printing.</p>
	<%return;}


	String strPrintURL = "./print_one.jsp?batch_print=1&sy_from="+strSYFrom+"&semester="+strSemester+
							"&pmt_schedule="+strPmtSchIndex+"&sub_sec_i=";//System.out.println(strPrintURL);System.out.println(vSubSecList);
	
	boolean bolPageBreak = false;
	for(int i = 0; i < vSubSecList.size(); i++){
		if(i == (vSubSecList.size()-1))
			bolPageBreak = false;
		else
			bolPageBreak = true;
	%>
	<script language="javascript">
		ShowProgress(<%=(i+1)%>, <%=vSubSecList.size()%>);
	</script>
		<jsp:include page="<%=strPrintURL+(String)vSubSecList.elementAt(i)%>" />
	
	<%if(bolPageBreak){%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}%>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
