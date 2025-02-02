<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strStudInfoList = (String)request.getSession(false).getAttribute("stud_list");
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strInfo5 = (String)request.getSession(false).getAttribute("info5");//System.out.println(strSchCode);
	
	//I have to make sure if called from myHOME, student id is considered.. 
	String strErrMsg = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strErrMsg != null && strErrMsg.equals("4"))
		strStudInfoList = (String)request.getSession(false).getAttribute("userId");
	
	strErrMsg = null;
	
	if(WI.getStrValue(strStudInfoList).length() == 0) 
		strErrMsg = "Student List not found.";
	else if(strSchCode == null) 
		strErrMsg = "You are already logged out. please login again.";

	if(strErrMsg != null)  {%>
	<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold"><%=strErrMsg%></p>
	<%
		return; 
	}
//strSchCode = "PHILCST";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Admission Slip Batch Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
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
	function UpdateUnitEnrolled(strLabelID, strValue) {
		document.getElementById(strLabelID).innerHTML = strValue;
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
	
	strTemp = WI.fillTextValue("pmt_schedule");
	String strExamName = null;
	if(strTemp.length() > 0){
		strTemp = "select exam_name from fa_pmt_schedule where pmt_sch_index = "+strTemp;
		strExamName = dbOP.getResultOfAQuery(strTemp, 0);		
	}	
	
	Vector vStudIDList = new Vector();
	
	String strPrintURL = null;
	
	if(strSchCode.startsWith("CLDH") || strSchCode.startsWith("VMUF"))
		strPrintURL = "./admission_slip_print_cldh.jsp";
	else if(strSchCode.startsWith("CPU"))
		strPrintURL = "./admission_slip_print_cpu.jsp";
	else if(strSchCode.startsWith("CGH"))
		strPrintURL = "./admission_slip_print_cgh.jsp";
	else if(strSchCode.startsWith("UDMC"))
		strPrintURL = "./admission_slip_print_udmc.jsp";
	else if(strSchCode.startsWith("AUF") || strSchCode.startsWith("DBTC") || strSchCode.startsWith("PIT") || 
		strSchCode.startsWith("UPH") || strSchCode.startsWith("WUP") || strSchCode.startsWith("MARINER")) {
		if(strInfo5 != null && strInfo5.startsWith("jonelta"))
			strPrintURL = "./admission_slip_print_jonelta.jsp";
		else	
			strPrintURL = "./admission_slip_print_auf.jsp";
	}
	else if(strSchCode.startsWith("PHILCST"))
		strPrintURL = "./admission_slip_print_philcst.jsp";
	else if(strSchCode.startsWith("FATIMA"))
		strPrintURL = "./admission_slip_print_fatima.jsp";
	else if(strSchCode.startsWith("EAC"))
		strPrintURL = "./admission_slip_print_eac.jsp";
	else if(strSchCode.startsWith("UC"))
		strPrintURL = "./admission_slip_print_uc.jsp";
	else if(strSchCode.startsWith("VMA"))
		strPrintURL = "./admission_slip_print_vma.jsp";
	else if(strSchCode.startsWith("PWC"))
		strPrintURL = "./admission_slip_print_PWC.jsp";
	else if(strSchCode.startsWith("HTC"))
		strPrintURL = "./admission_slip_print_htc.jsp";
	else if(strSchCode.startsWith("SWU")){
		if(strExamName != null && strExamName.toLowerCase().startsWith("prelim"))			
			strPrintURL = "other/cit/exam_permit_for_prelim_SWU.jsp";
		else
			strPrintURL = "other/cit/exam_permit_print_SWU.jsp";
			
	}
	else	
		strPrintURL = "./admission_slip_print.jsp";

	strPrintURL += "?batch_print=1&sy_from="+WI.fillTextValue("sy_from")+
		"&sy_to="+WI.fillTextValue("sy_to")+
		"&offering_sem="+WI.fillTextValue("offering_sem")+
		"&semester="+WI.fillTextValue("offering_sem")+
		"&pmt_schedule="+WI.fillTextValue("pmt_schedule")+
		"&gr_year_level="+WI.fillTextValue("year_level")+
		"&print_final="+WI.fillTextValue("print_final")+
		"&is_basic="+WI.fillTextValue("is_basic")+
		"&course_classification="+WI.fillTextValue("course_classification");

	

	strPrintURL += "&stud_id=";
	
	Vector vStudList = CommonUtil.convertCSVToVector(strStudInfoList, ",", true);
	
	
	boolean bolPageBreak = false;
	for(int i = 0; i < vStudList.size(); i++){
		if(i == (vStudList.size()-1))
			bolPageBreak = false;
		else
			bolPageBreak = true;
	%>
	<script language="javascript">
		ShowProgress(<%=(i+1)%>, <%=vStudList.size()%>);
	</script>
		<jsp:include page="<%=strPrintURL+(String)vStudList.elementAt(i)%>" />
	
	<%if(bolPageBreak){%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}%>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
