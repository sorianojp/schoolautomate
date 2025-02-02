<%@ 
	page language="java" 
	import="utility.*,Accounting.Report.ReportGeneric, java.util.Vector, payroll.ReportPayroll, payroll.CreateExcelFile" 
%>
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

//ReportGeneric rg  = new ReportGeneric();
//Vector vRetResult = rg.getTrialBalance(dbOP, request);
ReportPayroll RptPay = new ReportPayroll(request);
Vector vRetResult = RptPay.getEmpATMListingEAC(dbOP);
if(vRetResult == null)
	strErrMsg = RptPay.getErrMsg();


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

int iRowPerPg  = 1000000;
int iTotalRow  = vRetResult.size()/4;
int iTotalPage = iTotalRow / iRowPerPg;
if(iTotalRow % iRowPerPg > 0) 
	++iTotalPage;

int iCurPage   = 0;
int iCurRow    = 1; boolean bolEndOfPrinting = false;
int iRowCount  = 1;

int iHeaderLevel = 1; 
String strIndent = null;

boolean bolPrintHeader = false;
Vector vRows = new Vector();
Vector vColHeader = new Vector();
Vector vColDetails = new Vector();

vColHeader.addElement("3");
vColHeader.addElement(new Boolean(true));
vColHeader.addElement("Account Number");
vColHeader.addElement("Amount");
vColHeader.addElement("Employee Name");
       
vColDetails.addElement("3");
vColDetails.addElement(new Boolean(true));

for(int i =3; i < vRetResult.size(); i+=4) {
	strTemp = ( vRetResult.elementAt(i) == null ? " " : ((String)vRetResult.elementAt(i)).replaceAll("-","") );
	vColDetails.addElement( strTemp );
	strTemp = ( vRetResult.elementAt(i+3) == null ? " " : ( CommonUtil.formatFloat((String)vRetResult.elementAt(i+3),true) ).replaceAll(",","") );
	vColDetails.addElement( strTemp );
	strTemp = ( vRetResult.elementAt(i+1) == null ? " " : ( (String)vRetResult.elementAt(i+1) ).replaceAll("ñ|Ñ","") );
	vColDetails.addElement( "\"" +  strTemp.toUpperCase() + "\"");	
%>

<% strTemp = ( vRetResult.elementAt(i) == null ? "" : ((String)vRetResult.elementAt(i)).replaceAll("-","") ); %>
	<%= strTemp %>, 
<% strTemp = ( vRetResult.elementAt(i+3) == null ? "" : ( CommonUtil.formatFloat((String)vRetResult.elementAt(i+3), true) ).replaceAll(",","") ); %>
	<%= strTemp %>, 	
"<%=vRetResult.elementAt(i + 1)%>"

<%if( (i+4) < vRetResult.size()){%><br /><%}%>


<%}


	String strFileName = WI.fillTextValue("file_name");
		
	Vector vParam = new Vector();
	vRows.addElement( vColHeader );
	vRows.addElement( vColDetails );
	
	vParam.addElement( strFileName );	
	vParam.addElement( vRows );	
	
	CreateExcelFile cef = new CreateExcelFile( vParam );
	cef.constructCSV();
	cef.convertCSVtoXLS();

	dbOP.cleanUP();
%>