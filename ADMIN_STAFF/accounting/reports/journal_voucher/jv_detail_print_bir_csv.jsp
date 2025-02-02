<%@ page language="java" import="utility.*,Accounting.Report.ReportFS,Accounting.Report.ReportSpecialBooks,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Reports - journal_voucher","jv_detail_print_bir.jsp");
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

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING-REPORTS"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ACCOUNTING"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

//end of authenticaion code.

String strJVType = WI.getStrValue(WI.fillTextValue("jv_type"),"0");
if(strJVType.equals("0"))
	strJVType = "General Journal";
else if(strJVType.equals("1"))
	strJVType = "Scholarship Journal";
else if(strJVType.equals("3"))
	strJVType = "AR Journal";
else if(strJVType.equals("4"))
	strJVType = "Cash Receipt Journal";
else if(strJVType.equals("-1"))
	strJVType = "Disbursement Voucher";


ReportFS RFS = new ReportFS();
ReportSpecialBooks RSB = new ReportSpecialBooks();
Vector vJVDetail  = null;
Vector vRetResult = null;
if(strJVType.equals("Disbursement Voucher")) {
	vRetResult = RSB.getCDBirFormat(dbOP, request);//System.out.println(vRetResult);

	if(vRetResult == null || vRetResult.size() == 0) {
		strErrMsg = RSB.getErrMsg();
		if(strErrMsg == null)
			strErrMsg = "No Result found.";
	}
}	
else {
	vRetResult = RFS.getGeneralJournalNew(dbOP, request);

	if(vRetResult == null)
		strErrMsg = RFS.getErrMsg();
}


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
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
	font-size: 11px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TABLE.thinborderALL {
    border-top: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
</style>
</head>
<body>
<%if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:14px; font-weight:bold; color:#FF0000"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%dbOP.cleanUP();return;}
if(vRetResult != null && vRetResult.size() > 0) {
	
	while(vRetResult.size() > 0){
		strTemp = (String)vRetResult.elementAt(6);%>
		
			"<%=vRetResult.elementAt(0)%>","<%=vRetResult.elementAt(1)%>","<%=vRetResult.elementAt(2)%>","<%=vRetResult.elementAt(3)%>","<%=vRetResult.elementAt(4)%>","<%if(strTemp.equals("1")){%><%=vRetResult.elementAt(5)%><%}else{%>0.00<%}%>","<%if(strTemp.equals("0")){%><%=vRetResult.elementAt(5)%><%}else{%>0.00<%}%>"			
<%		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
		if(vRetResult.size() > 0) {%> <br><%}
	}
}%>
</body>
</html>
<%
dbOP.cleanUP();
%>