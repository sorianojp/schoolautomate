<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	String strStudInfoList = (String)request.getSession(false).getAttribute("batch_201");

	if(strStudInfoList == null || strStudInfoList.length() == 0) {%>
	<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold">Employee List not found.</p>
	<%
		return; 
	}
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthTypeIndex == null || strAuthTypeIndex.equals("4")) {%>
	<p style="font-size:14px; font-family:Verdana, Arial, Helvetica, sans-serif; color:#FF0000; font-weight:bold">You are not authorized to view this page. Please login</p>
	<%
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
<style type="text/css">
td.thinBorderBottom {
	border-bottom:1px solid #000000;
}

.thinBorderALL {
	border-bottom:1px solid #000000;
	border-left: 1px solid #000000;
	border-right: 1px solid #000000;
	border-top: 1px solid #000000;
}

body{
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:11px;	
}

TD.thinBorder{
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:11px;
	border-bottom:1px solid #000000;
	border-left: 1px solid #000000;
}

TABLE.thinBorder{
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:11px;
	border-right:1px solid #000000;
	border-top: 1px solid #000000;
}

TD{
	font-family:Verdana, Arial, Helvetica, sans-serif;
	font-size:11px;	
}
</style>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script>
	function CallOnLoad() {
		document.all.processing.style.visibility='hidden';
		document.bgColor = "#FFFFFF";
	}
</script>
<body onLoad="CallOnLoad();window.print();" bgcolor="#DDDDDD">
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
	String strErrMsg = null;
	String strTemp = null;
	
	String strPageURL  = "./hr_personnel_201_file_print.jsp?batch_print=1&emp_id=";	
	Vector vEmpIDList = CommonUtil.convertCSVToVector(strStudInfoList, ",", true);
	
	
	boolean bolPageBreak = false;
	for(int i = 0; i < vEmpIDList.size(); i++){
		Thread.sleep(300);
		if(i == (vEmpIDList.size()-1))
			bolPageBreak = false;
		else
			bolPageBreak = true;
	%>
		<jsp:include page="<%=strPageURL+(String)vEmpIDList.elementAt(i)%>" />
	
	<%if(bolPageBreak){%>
		<DIV style="page-break-before:always" ><img src="../../../images/blank.gif" width="1" height="1"></DIV>
	<%}%>
<%}%>
</body>
</html>
