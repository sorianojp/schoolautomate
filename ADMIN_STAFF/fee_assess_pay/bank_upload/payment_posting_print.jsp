<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Payment Posting</title>
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
	DBOperation dbOP = null;
	String strErrMsg = null;
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

	Vector vTemp = new Vector();
	String strORFrom = WI.fillTextValue("or_from");
    String strORTo = WI.fillTextValue("or_to");

	String strValidOR = WI.fillTextValue("valid_or");
	if(strValidOR.length() > 0)
		vTemp = CommonUtil.convertCSVToVector(strValidOR);
	else{
		int iORFrom = Integer.parseInt(strORFrom);
		int iORTo = Integer.parseInt(strORTo);

		int iLen = strORFrom.length();

		for(int i = iORFrom; i <= iORTo; i++){
		  strTemp = Integer.toString(i);
		  while(strTemp.length() < iLen)
			strTemp = "0"+strTemp;
		  vTemp.addElement(strTemp);
		}
	}

	String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
	String strInfo5 = WI.getStrValue((String)request.getSession(false).getAttribute("info5"));
	if(strSchoolCode == null)
		strSchoolCode = "";
	String strPath = utility.CommonUtil.getORFileName(null, request);
      if(strPath == null) {%>
        <strong>No default print page found.</strong>
      <%return;}
	  else
	  	strPath = strPath.substring(2);
	
/**
	if(strSchoolCode.startsWith("SPC"))
		strPath = "one_receipt_SPC.jsp";
	if(strSchoolCode.startsWith("AUF"))
		strPath = "one_receipt_AUF.jsp";
	else if(strSchoolCode.startsWith("EAC"))
		strPath = "one_receipt_EAC.jsp";
	else if(strSchoolCode.startsWith("WNU"))
		strPath = "one_receipt_WNU.jsp";
	else if(strSchoolCode.startsWith("CLDH"))
		strPath = "one_receipt_CLDH.jsp";
	else if(strSchoolCode.startsWith("CGH"))
		strPath = "one_receipt_CGH.jsp";
	else if(strSchoolCode.startsWith("UDMC"))
		strPath = "one_receipt_UDMC.jsp";
	else if(strSchoolCode.startsWith("CPU"))
		strPath = "one_receipt_CPU.jsp";
	else if(strSchoolCode.startsWith("CIT"))
		strPath = "one_receipt_CIT.jsp";
	else if(strSchoolCode.startsWith("VMA"))
		strPath = "one_receipt_VMA.jsp";
	else if(strSchoolCode.startsWith("CDD"))
		strPath = "one_receipt_CDD.jsp";
	else if(strSchoolCode.startsWith("UPH")) {
		strPath = "one_receipt_UPH1.jsp";
		if(strInfo5.length() > 0)
			strPath = "one_receipt_UPHS.jsp";
	}
	else if(strSchoolCode.startsWith("WUP"))
		strPath = "one_receipt_WUP.jsp";
	else if(strSchoolCode.startsWith("UB"))
		strPath = "one_receipt_UB.jsp";
	else{%>
		<!--<strong>No default print page found.</strong>-->
	<%
		return;}
**/
	boolean bolPageBreak = false;
	for(int i = 0; i < vTemp.size(); i++){
	Thread.sleep(200);
		if(i == (vTemp.size()-1))
			bolPageBreak = false;
		else
			bolPageBreak = true;

		strTemp = "../payment/"+strPath+"?batch_print=1&or_number="+(String)vTemp.elementAt(i);
	
	%>
		<jsp:include page="<%=strTemp%>" />
	<%
	if(bolPageBreak){%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}%>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
