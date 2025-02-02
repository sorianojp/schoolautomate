<%@ page language="java" import="utility.*,Accounting.Report.ReportFS,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Reports - Cash Receipt Journal","crj_print.jsp");
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

ReportFS RFS = new ReportFS();
Vector vJVDetail  = null;
Vector vRetResult = RFS.getJVDetail(dbOP, request);

if(vRetResult == null)
	strErrMsg = RFS.getErrMsg();
else	
	vJVDetail = (Vector)vRetResult.remove(0);

String[] astrConvertMonth = {"January","February","March","April","May","June","July","August","September","October","November","December"};

//System.out.println(vRetResult);
//System.out.println(vJVDetail);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">
function PrintPg() {
	<%if(WI.fillTextValue("print_").equals("1")){%>
		window.print();
	<%}%>
}
</script>
<body onLoad="PrintPg()">
<%if(strErrMsg != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFFFF">
      <td height="25" style="font-size:14px; font-weight:bold; color:#FF0000"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<%dbOP.cleanUP();return;}
int iRowPerPg = Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iCurPg    = 0;

int iIndexOf  = 0; Vector vTempJVInfo = null;

if(vRetResult != null && vRetResult.size() > 0) {
double dTotalDebit  = ((Double)vRetResult.remove(0)).doubleValue();
double dTotalCredit = ((Double)vRetResult.remove(0)).doubleValue();
int iPageOf = 1;
int iTotalPages = vRetResult.size()/(2 * iRowPerPg);
if(vRetResult.size() % (2 * iRowPerPg) > 0)
	++iTotalPages;
	
//System.out.println(vRetResult);	
for(int i = 0; i < vRetResult.size(); ++iPageOf){
iCurPg = 0;%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr>
      <td width="100%" height="25" align="center"><font size="2">
      <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
        <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
        Detail of AR Journal <br>
        For the Month of 
		<u><%=astrConvertMonth[Integer.parseInt(WI.fillTextValue("jv_month"))]%> <%=WI.fillTextValue("jv_year")%></u>		
	 </td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="22" align="right" style="font-size:10px">Page <%=iPageOf%> of <%=iTotalPages%>&nbsp;</td>
    </tr>
  </table>
  
  <table border="0" cellpadding="0" cellspacing="0" class="thinborder" width="100%">
    <tr>
      <td align="center" class="thinborder"><strong>ACCOUNT CODE</strong></td>
      <td height="26" align="center" class="thinborder"><strong>ACCOUNT TITLE<br>
        <font color="#FFFFFF">******************</font></strong></td>
      <%for(int p = 0; p < vJVDetail.size(); p += 3){%><td class="thinborder" align="center"><strong><%=vJVDetail.elementAt(p)%></strong></td><%}%>
      <td class="thinborder" align="center"><strong>DEBIT</strong></td>
      <td class="thinborder" align="center"><strong>CREDIT</strong></td>
    </tr>
<%for(; i < vRetResult.size();){//System.out.println(vRetResult.elementAt(2));
vTempJVInfo = (Vector)vRetResult.remove(2);//System.out.println(vTempJVInfo);%>
	<tr>
	  <td class="thinborder"><%=vRetResult.remove(1)%></td>
      <td height="26" class="thinborder"><%=vRetResult.remove(0)%></td>
	  <%for(int p = 0; p < vJVDetail.size(); p += 3){%>
	  	<td class="thinborder" align="center">
			<%
			iIndexOf = vTempJVInfo.indexOf(vJVDetail.elementAt(p + 1));
			if(iIndexOf != -1) {
				strTemp = (String)vTempJVInfo.elementAt(iIndexOf - 1);//amount
				vTempJVInfo.removeElementAt(iIndexOf-1); vTempJVInfo.removeElementAt(iIndexOf-1);				
			} 
			else
				strTemp = "&nbsp;";
			//System.out.println("Print : "+strTemp);%>
			<%=strTemp%>	   </td>
	  <%}%>
      <td width="8%" class="thinborder" align="right"><%=vTempJVInfo.elementAt(vTempJVInfo.size() - 2)%></td>
      <td width="10%" class="thinborder" align="right"><%=vTempJVInfo.elementAt(vTempJVInfo.size() - 1)%></td>
    </tr>
<%if(i == vRetResult.size()){%>
    <tr>
      <td height="26" colspan="2" align="right" class="thinborder"><strong>TOTAL :&nbsp;&nbsp;&nbsp; </strong></td>
      <%for(int p = 0; p < vJVDetail.size(); p += 3){%><td class="thinborder" align="right">&nbsp;</td><%}%>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTotalDebit,true)%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTotalCredit,true)%></td>
    </tr>
    <tr>
      <td height="26" colspan="2" valign="top" class="thinborder"><strong>EXPLANATION :</strong> </td>
      <%for(int p = 0; p < vJVDetail.size(); p += 3){%><td class="thinborder" valign="top" style="font-size:9px;"><%=vJVDetail.elementAt(p + 2)%></td><%}%>
      <td class="thinborder" align="right">&nbsp;</td>
      <td class="thinborder" align="right">&nbsp;</td>
    </tr>
<%}//print at end.. 
if(++iCurPg == iRowPerPg)
	break;
}%>
  </table>
<%if(i < vRetResult.size()){%>
<DIV style="page-break-after:always" >&nbsp;</DIV>
<%}%>

<%}//end of vRetResult.. 
}//end of big loop - if condition.%>
</body>
</html>
<%
dbOP.cleanUP();
%>