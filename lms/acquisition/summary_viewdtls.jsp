<%@ page language="java" import="utility.*,lms.LmsAcquision,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null; String strTemp = null;
	String strUserIndex  = null;

//authenticate this user.
	int iAccessLevel = 0;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(request.getSession(false).getAttribute("userIndex") == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth != null && svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else if (svhAuth != null)
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("LIB_Acquisition".toUpperCase()),"0"));

	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../lms/");
		request.getSession(false).setAttribute("errorMessage","Please login to access this page.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}

//end of authenticaion code.

	try {
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


LmsAcquision lmsAcq   = new LmsAcquision();
Vector vRetResult     = null; Vector vInsList = null;
String strCollegeName = null;

vRetResult = lmsAcq.viewBudgetDetail(dbOP, request);
//System.out.println("vRetResult "+vRetResult);
if(vRetResult == null && strErrMsg == null)
	strErrMsg = lmsAcq.getErrMsg();
else	
	strCollegeName = dbOP.getResultOfAQuery("select c_name from college where c_index = "+WI.fillTextValue("college"), 0);
	


%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../css/tabStyle.css" rel="stylesheet" type="text/css">
</head>
<body>
<%if(strErrMsg != null){%> 
<p align="center" style="font-size:14px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif; color:red"><%=strErrMsg%></p>
<%dbOP.cleanUP();return;}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr style="font-weight:bold">
    <td width="45%" height="20">Acquisition Detail for College : <%=strCollegeName%> <br>Total Budget : <%=WI.fillTextValue("budget")%> &nbsp;Total Acquisition : <%=WI.fillTextValue("consumed")%> &nbsp;Total Balance : <%=WI.fillTextValue("balance")%></td>
  </tr>
</tr>
</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		  <tr>
			<td height="25" align="center" class="thinborderBOTTOM"><strong>:::: Acquisition Details ::::</strong></td>
		  </tr>
<%
Vector vBookDetail = null;
while(vRetResult.size() > 0) {
vBookDetail = (Vector)vRetResult.remove(7);
if(vBookDetail == null) {
	vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);vRetResult.remove(0);
	
	continue;
}
vRetResult.remove(0);//ACQUISITION_INDEX
vRetResult.remove(4);
%>
		  <tr>
			<td height="25">
			<%=WI.getStrValue((String)vRetResult.remove(4))%>  
			Acquisition #:<%=WI.getStrValue((String)vRetResult.remove(0),"N/A")%>  
			PO #<%=WI.getStrValue((String)vRetResult.remove(0),"N/A")%>  
			DR #:<%=WI.getStrValue((String)vRetResult.remove(0),"N/A")%>  
			Total Amount:<%=WI.getStrValue((String)vRetResult.remove(0),"N/A")%>  </td>
		  </tr>
		  <tr>
			<td height="25">
			<table class="thinborder" cellpadding="0" cellspacing="0" width="100%">
				<tr align="center" style="font-weight:bold">
				<td width="5%" class="thinborder">Count</td>
				<td width="20%" height="25" class="thinborder">Author</td>
				<td width="25%" class="thinborder">Title</td>
				<td width="7%" class="thinborder">Edition</td>
				<td width="8%" class="thinborder">Unit Price</td>
				<td width="5%" class="thinborder">Qty</td>
				<td width="10%" class="thinborder">Actual Cost </td>
				<td width="15%" class="thinborder">Purchased Price</td>
			  </tr>
			<%for(int i = 0; i < vBookDetail.size(); i += 10){%>
			  <tr>
				<td class="thinborder"><%=i/10 + 1%>.</td>
				<td height="20" class="thinborder"><%=vBookDetail.elementAt(i + 3)%></td>
				<td class="thinborder"><%=vBookDetail.elementAt(i + 6)%></td>
				<%
					strTemp = (String)vBookDetail.elementAt(i + 4);
					if(strTemp != null)
						strTemp = (String)vBookDetail.elementAt(i + 4);
					else
						strTemp = "";
				%>
				<td class="thinborder">&nbsp;<%=strTemp%></td>
				<td class="thinborder" align="right"><%=vBookDetail.elementAt(i + 9)%> &nbsp;</td>
				<td class="thinborder"><%=vBookDetail.elementAt(i + 8)%></td>
				<td class="thinborder" align="center"><%=vBookDetail.elementAt(i)%> &nbsp;</td>
				<td class="thinborder" align="center"><%=vBookDetail.elementAt(i + 2)%> &nbsp;</td>
			  </tr>
			<%}%>
			</table>
			
			</td>
		  </tr>
<%}//end of while.. %>	  
	  </table>
</body>
</html>
<%
dbOP.cleanUP();
%>