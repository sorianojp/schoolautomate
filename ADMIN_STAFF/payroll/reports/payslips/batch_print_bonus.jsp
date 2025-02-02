<%@ page language="java" import="utility.*,java.util.Vector,payroll.ReportPayroll, payroll.PReDTRME"
				 buffer="32kb"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Batch Print Bonus Payslip</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">
function resizeIframeToFitContent(iframe) {
  //iframe.height = document.frames[iframe.id].document.body.scrollHeight;
	//document.frames('iframename').document.body.scrollHeight;
	//document.getElementById('iframename').contentDocument.body.scrollHeight;
	
 	//var strHeight = document.getElementById(iframe).contentWindow.document.body.scrollHeight;
	var strHeight;
	//strHeight = document.frames[iframe].document.body.scrollHeight;	
	//alert("strHeight - 1 " + strHeight);
	//alert("iframe " + iframe);
	//strHeight = document.getElementById(iframe).contentWindow.document.body.scrollHeight;
	strHeight = document.getElementById(iframe).contentDocument.body.scrollHeight;
	//alert("strHeight - 1 " + document.frames(iframe).document.body.scrollHeight);
	//alert("strHeight - 2 " + document.getElementById(iframe).contentDocument.body.scrollHeight);	
	//alert("strHeight - 3 " + document.frames[iframe.id].document.body.scrollHeight);	
	//alert("strHeight - 4 " + document.frames[iframe].document.body.scrollHeight);	
	//alert("strHeight - 5 " + document.getElementById(iframe).contentWindow.document.body.scrollHeight);	

	//alert("strHeight - 2 " + document.getElementById(iframe).contentDocument.body.scrollHeight);	
	document.getElementById(iframe).style.height = strHeight;
	
 //  var the_height=
//    document.getElementById('the_iframe').contentWindow.
//      document.body.scrollHeight;

}

var iframehide = "no";

var getFFVersion = navigator.userAgent.substring(navigator.userAgent.indexOf("Firefox")).split("/")[1];
var FFextraHeight = parseFloat(getFFVersion) >= 0.1 ? 20 : 20; //extra height in px to add to iframe in FireFox 1.0+ browsers

//function resizeCaller() {
//	var dyniframe=new Array()
//	for (i=0; i<iframeids.length; i++){
//		if (document.getElementById)
//			resizeIframe(iframeids[i])
//		//reveal iframe for lower end browsers? (see var above):
//		if ((document.all || document.getElementById) && iframehide=="no"){
//			var tempobj=document.all? document.all[iframeids[i]] : document.getElementById(iframeids[i])
//			tempobj.style.display="block"
//		}
//	}
//}

function resizeIframe(frameid){
	var currentfr=document.getElementById(frameid);
	if (currentfr && !window.opera){
		currentfr.style.display="block";
		if (currentfr.contentDocument && currentfr.contentDocument.body.offsetHeight){ //ns6 syntax
			currentfr.height = currentfr.contentDocument.body.offsetHeight+FFextraHeight; 
			// for firefox ni na code!... much better than in iE
			// walay contentDocument ang iE
		}else if (currentfr.document && currentfr.document.body.scrollHeight) {//ie5+ syntax
			//alert("1 -- " + currentfr.document.body.offsetHeight);
			//alert("2 -- " + currentfr.document.body.scrollHeight);
			//alert("3 -- " + currentfr.contentWindow.body.offsetHeight);
	//alert("strHeight - 1 " + document.frames(iframe).document.body.scrollHeight);
	//alert("strHeight - 2 " + currentfr.contentDocument.body.scrollHeight);// error in iE
	//alert("strHeight - 3 " + document.frames[iframe.id].document.body.scrollHeight);	
	//alert("strHeight - 4 " + document.frames[iframe].document.body.scrollHeight);	
			currentfr.height = currentfr.document.body.offsetHeight;
	//currentfr.style.height = currentfr.document.body.clientHeight;
//			alert("height1 - " + currentfr.height);
//			alert("height2-- " + currentfr.style.height);
//			alert("height3-- " + currentfr.document.body.clientHeight);
		}
		
		if (currentfr.addEventListener){
			// firefox
			currentfr.addEventListener("load", readjustIframe, false);
		}else if (currentfr.attachEvent){
			// iE
			currentfr.detachEvent("onload", readjustIframe); // Bug fix line
			currentfr.attachEvent("onload", readjustIframe);
		}
	}
}

function readjustIframe(loadevt) {
	var crossevt=(window.event)? event : loadevt;
	var iframeroot=(crossevt.currentTarget)? crossevt.currentTarget : crossevt.srcElement;
	if (iframeroot)
		resizeIframe(iframeroot.id);
}

</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strUserID = (String)request.getSession(false).getAttribute("userId");

//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PayroPayroll-REPORTS-Payslips-Batch Print(Regular)","batch_print.jsp");
    	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"batch_print.jsp");
														
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

	String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};
	Vector vSalaryPeriod 		= null;//detail of salary period.

	PReDTRME prEdtrME = new PReDTRME();
	EnrlReport.StatementOfAccount SOA = new EnrlReport.StatementOfAccount();
	
	Vector vRetResult = null;
	ReportPayroll RptPay = new ReportPayroll(request);
	int iCount = 1;
	int i = 0;
	boolean bolPageBreak = false;
	vRetResult = RptPay.searchAddMonthPay(dbOP);
	String strEmpID = (String)request.getSession(false).getAttribute("userId");
%>

<%
	int iMaxPage = vRetResult.size()/15;	
	int[] aiPrintPg = SOA.getPrintPage(WI.fillTextValue("print_option2"),iMaxPage);

	if(aiPrintPg == null) {
		strErrMsg = SOA.getErrMsg();
		strTemp = "";
		%> 
		<script language="JavaScript">alert("<%=strErrMsg%>");</script>

<%}else{
	strTemp	= "javascript:window.print();";
	}%>
<body onLoad="<%=strTemp%>">
<form>
	<%if(vRetResult != null && vRetResult.size() > 0 && aiPrintPg != null){	
	//System.out.println("vRetResult.size() - " + vRetResult.size());
	
 	for(i = 0; i < aiPrintPg.length; ++i,++iCount) {
 	//for(i = 0,iCount=1; i < vRetResult.size(); i += 27,++iCount){
		if(aiPrintPg[i] == 0)
			continue;
		
		if (i < aiPrintPg.length - 1)
			bolPageBreak = true;
		else 
			bolPageBreak = false;					
	%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">    	
    <tr bgcolor="#FFFFFF"> 
			<% 
				strTemp = "./payroll_slip_print_bonus.jsp?emp_id="+(String)vRetResult.elementAt(aiPrintPg[i] * 15 - 14)+
									"&pay_index="+vRetResult.elementAt(aiPrintPg[i] * 15 - 7)+
									"&emp_bonus_index="+(String)vRetResult.elementAt(aiPrintPg[i] * 15 - 15)+
									"&finalize=1&my_home="+WI.fillTextValue("my_home")+
									"&pt_ft="+vRetResult.elementAt(aiPrintPg[i] * 15 - 6)+
									"&bonus_amt="+(String)vRetResult.elementAt(aiPrintPg[i] * 15 - 8)+
									"&skip_print=1";			
				// onload=resizeIframeToFitContent
			%>
			<%//=strTemp%>
      <td height="25">
			<iframe scrolling="no" width="100%" frameborder="0" id="myframe_<%=iCount%>" 
			src="<%=strTemp%>" style="overflow:visible" marginwidth="0" marginheight="0" 
			vspace="0" hspace="0"></iframe>
        <script language="JavaScript">
			resizeIframe('myframe_<%=iCount%>');
			</script>			</td>
    </tr>		
  </table>
	<%if (bolPageBreak){%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break ony if it is not last page.
	 } // end for loop
	}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>