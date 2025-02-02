<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strStudInfoList = (String)request.getSession(false).getAttribute("stud_list");
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	String strErrMsg = null;

	if(strStudInfoList.length() == 0) 
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
	Vector vStudIDList = new Vector();
	
	String strPrintURL = null;
	
	strPrintURL = "./statement_of_account_UI_print.jsp";
	if(strSchCode.startsWith("VMA")) {
		strPrintURL = "./statement_of_account_print_vma.jsp";
		if(WI.fillTextValue("is_summarized").length() > 0) 
			strPrintURL = "./statement_of_account_UI_print.jsp";
	}
	if(strSchCode.startsWith("HTC"))
		strPrintURL = "./statement_of_account_print_HTC.jsp";
	if(strSchCode.startsWith("CDD"))
		strPrintURL = "./statement_of_account_print_CDD.jsp";
	if(strSchCode.startsWith("SWU")){
		strPrintURL = "./statement_of_account_print_SWU.jsp";
		request.getSession(false).setAttribute("swu_page_counter","0");		//so that every print starts with 0
	}
		

	strPrintURL += "?batch_print=1&sy_from="+WI.fillTextValue("sy_from")+"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+
		WI.fillTextValue("semester")+"&pmt_schedule="+WI.fillTextValue("pmt_schedule")+
		"&is_basic="+WI.fillTextValue("is_basic")+"&print_final="+WI.fillTextValue("print_final");

	

	strPrintURL += "&stud_id=";
	
	Vector vStudList = CommonUtil.convertCSVToVector(strStudInfoList, ",", true);
	//System.out.println(strPrintURL);
	
	int iCount = 0;
	boolean bolPageBreak = false;
	for(int i = 0; i < vStudList.size(); i++){//System.out.println(vStudList.elementAt(i));
		if(i == (vStudList.size()-1))
			bolPageBreak = false;
		else
			bolPageBreak = true;
		if(strSchCode.startsWith("SWU")){//used in printing SA of SWU
			strTemp = (String)request.getSession(false).getAttribute("swu_page_counter");
			iCount = Integer.parseInt(WI.getStrValue(strTemp, "0"));	
			request.getSession(false).setAttribute("swu_page_counter", Integer.toString(iCount));
		}
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
