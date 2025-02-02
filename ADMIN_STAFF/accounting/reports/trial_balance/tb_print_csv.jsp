<%@ page language="java" import="utility.*,Accounting.Report.ReportGeneric, java.util.Vector" %>
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

ReportGeneric rg  = new ReportGeneric();
Vector vRetResult = rg.getTrialBalance(dbOP, request);
if(vRetResult == null)
	strErrMsg = rg.getErrMsg();


boolean bolIsSACI = false;
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
bolIsSACI = strSchCode.startsWith("UDMC");
%>
<%if(strErrMsg != null || vRetResult == null){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2" style="font-size:13px; font-weight:bold; color:#FF0000"><%=strErrMsg%></td>
    </tr>
  </table>
<%dbOP.cleanUP();return;}%>
<%
boolean bolPrintHeaderAccount = false;
if(WI.fillTextValue("print_header_account").length() > 0)
	bolPrintHeaderAccount = true;

String strTotalDebit  = (String)vRetResult.remove(0); 
String strTotalCredit = (String)vRetResult.remove(0);

//I have to remove it for now.
if(false && !bolPrintHeaderAccount) {
	for(int i =0; i < vRetResult.size(); i += 8) {
		if(vRetResult.elementAt(i + 3).equals("0")){
			vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);
			vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);vRetResult.remove(i);
			i -= 8;
		}
	}
}

int iRowPerPg  = 1000000;
int iTotalRow  = vRetResult.size()/8;
int iTotalPage = iTotalRow / iRowPerPg;
if(iTotalRow % iRowPerPg > 0) 
	++iTotalPage;

int iCurPage   = 0;
int iCurRow    = 1; boolean bolEndOfPrinting = false;
int iRowCount  = 1;

int iHeaderLevel = 1; 
String strIndent = null;

boolean bolPrintHeader = false;
	
for(int i =0; i < vRetResult.size(); i += 8) {
	/**if(vRetResult.elementAt(i + 3).equals("0")){
		if(!bolPrintHeaderAccount) {
			--iCurRow;
			continue;
		}
		continue;
	}**/%>
"<%=vRetResult.elementAt(i + 2)%>","<%=vRetResult.elementAt(i + 1)%>","<%=vRetResult.elementAt(i + 6)%> ","<%=vRetResult.elementAt(i + 7)%> "<%if( (i + 8) < vRetResult.size()){%><br /><%}%>
<%}

dbOP.cleanUP();
%>