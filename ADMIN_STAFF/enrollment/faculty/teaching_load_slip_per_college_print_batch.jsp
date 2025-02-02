<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	DBOperation dbOP = (DBOperation)request.getSession(false).getAttribute("dbOP_");

	Vector vEmployeeList = (Vector)request.getSession(false).getAttribute("emp_list");

	if(vEmployeeList == null || vEmployeeList.size() == 0) {%>
	<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold">Employee List not found.</p>
	<%
		if(dbOP != null)
			dbOP.cleanUP();
			
		return; 
	}
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";
	
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script>
	function CallOnLoad() {
		document.all.processing.style.visibility='hidden';	
		document.bgColor = "#FFFFFF";
	}
</script>
<body topmargin="0" bottommargin="0" onLoad="CallOnLoad();window.print();" bgcolor="#DDDDDD">
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <!--<label id="page_progress"></label>-->
			<br><img src="../../../Ajax/ajax-loader_small_black.gif">
			</font></p>
			
			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>
<%
	String strErrMsg = null;
	String strTemp = null;
	
	String strPageURL  = "./teaching_load_slip_per_college_print.jsp";
	if(strSchCode.startsWith("SPC"))
		strPageURL  = "./teaching_load_slip_per_college_print_spc_fc.jsp";
	if(WI.fillTextValue("show_teacher_copy").length() > 0) 
		strPageURL  = "./teaching_load_slip_per_college_print_spc_tc.jsp";
	if(strSchCode.startsWith("UB"))
		strPageURL  = "./teaching_load_slip_print_ub.jsp";
	
	strPageURL += "?batch_print=1&semester="+WI.fillTextValue("semester")+
						"&sy_from="+WI.fillTextValue("sy_from")+
						"&show_enroll_stud="+WI.fillTextValue("show_enroll_stud")+
						"&show_sub_desc="+WI.fillTextValue("show_sub_desc")+
						"&sy_to="+WI.fillTextValue("sy_to")+"&font_size=11&emp_id=";
	
	boolean bolPageBreak = false;
	for(int i = 0; i < vEmployeeList.size(); i++){
		Thread.sleep(200);
		if(i == (vEmployeeList.size()-1))
			bolPageBreak = false;
		else
			bolPageBreak = true;
	%>
		<jsp:include page="<%=strPageURL+(String)vEmployeeList.elementAt(i)%>" />
	
	<%if(bolPageBreak){%>
		<DIV style="page-break-before:always" ><img src="../../../images/blank.gif" width="1" height="1"></DIV>
	<%}%>
<%}%>
</body>
</html>
<%
if(dbOP != null)
	dbOP.cleanUP();
%>
