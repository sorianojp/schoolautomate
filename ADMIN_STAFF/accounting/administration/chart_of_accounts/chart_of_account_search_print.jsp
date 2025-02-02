<%@ page language="java" import="utility.*,Accounting.Search,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strFormName = null;
	java.util.StringTokenizer strToken = new java.util.StringTokenizer(WI.fillTextValue("opner_info"),".");
	if(strToken.hasMoreElements()) {
		strFormName = strToken.nextToken();
	
	}
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body leftmargin="0" rightmargin="0" topmargin="0" bottommargin="0" onLoad="window.print();">
<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	try
	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};

int iSearchResult = 0;

Search search = new Search(request);
	vRetResult = search.searchCOA(dbOP);
	if(vRetResult == null)
		strErrMsg = search.getErrMsg();
	else	
		iSearchResult = search.getSearchCount();

%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="2"><div align="center">
	  <strong>:::: CHART OF ACCOUNT ::::</strong></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td width="56%" height="25" style="font-size:14px; color:#FF0000">&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
      <td width="44%" style="font-size:9px;" align="right">Date and time printed : <%=WI.getTodaysDateTime()%></td>
    </tr>
  </table>
<%
boolean bolShowOpeningBal = WI.fillTextValue("open_bal").equals("1");

if(vRetResult != null && vRetResult.size() > 0){%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="66%" height="25"><b> Total Result : <%=iSearchResult%></b></td>
      <td width="34%" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr align="center" style="font-weight:bold"> 
      <td width="12%" height="25" class="thinborder"><font size="1">Classification</font></td>
      <td width="14%" class="thinborder"><font size="1">Account #</font></td>
      <td width="50%" class="thinborder"><font size="1">Account Name </font></td>
<%if(bolShowOpeningBal){%>
      <td width="15%" class="thinborder">Opening Balance </td>
<%}%>
      <td width="15%" class="thinborder"><font size="1">Status</font></td>
    </tr>
<%
int iHeaderLevel = 1; 
String strIndent = null;
String strRowStyle = null;//if header type, i have to put it in blue color.. 
	
for(int i = 0 ; i < vRetResult.size(); i += 7){ 
	if(vRetResult.elementAt(i + 4).equals("0"))
		strRowStyle = " style='color:#0000FF;'";
	else	
		strRowStyle = "";
	//find indentation.. 
	iHeaderLevel = Integer.parseInt((String)vRetResult.elementAt(i + 5));
	strIndent = "";
	for(int p = 0; p < iHeaderLevel; ++p)
		strIndent = "-"+strIndent;
	strIndent = strIndent + ">";	
	%>	
    <tr<%=strRowStyle%>> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td class="thinborder">&nbsp;<%=strIndent%> <%=(String)vRetResult.elementAt(i + 2)%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
<%if(bolShowOpeningBal){%>
      <td class="thinborder"><%=CommonUtil.formatFloat(WI.getStrValue(vRetResult.elementAt(i + 6), "0"), true)%></td>
<%}%>
      <td class="thinborder">&nbsp;<%if(!vRetResult.elementAt(i + 3).equals("1")){%><img src="../../../../images/x.gif"><%}else{%>
	  Active<%}%></td>
    </tr>
<%}%>
  </table>
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>