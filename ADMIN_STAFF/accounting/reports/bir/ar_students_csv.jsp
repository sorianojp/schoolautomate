<%@ page language="java" import="utility.*,Accounting.Report.ReportBIRAnnual, java.util.Vector" %>
<%
	WebInterface WI  = new WebInterface(request);
	DBOperation dbOP = null;
	
	String strTemp   = null;
	String strErrMsg = null;
	
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
		response.sendRedirect("../../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0) {//NOT AUTHORIZED.
		response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
		return;
	}

//add security here.
	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.

ReportBIRAnnual reportBIR = new ReportBIRAnnual();
Vector vRetResult = reportBIR.generateAR(dbOP, request);
if(vRetResult == null)
	strErrMsg = reportBIR.getErrMsg();
%>
<%if(strErrMsg != null || vRetResult == null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2" style="font-size:13px; font-weight:bold; color:#FF0000"><%=strErrMsg%></td>
    </tr>
  </table>
<%dbOP.cleanUP();return;}

dbOP.cleanUP();
	
for(int i =1; i < vRetResult.size(); i += 4) {
	/**if(vRetResult.elementAt(i + 3).equals("0")){
		if(!bolPrintHeaderAccount) {
			--iCurRow;
			continue;
		}
		continue;
	}**/%>
"<%=vRetResult.elementAt(i)%>","<%=vRetResult.elementAt(i + 1)%>","<%=vRetResult.elementAt(i + 2)%> ","<%=vRetResult.elementAt(i + 3)%>"<%if( (i + 4) < vRetResult.size()){%><br /><%}%>
<%}

%>