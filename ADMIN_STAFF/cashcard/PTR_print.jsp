<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<title>Untitled Document</title>
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript"  src ="../../Ajax/ajax.js" ></script>
<script language="JavaScript" src="../../jscript/common.js"></script>
<script language="JavaScript" src="../../jscript/date-picker.js"></script>

<%@ page language="java" import="utility.*, cashcard.Pos, java.util.Vector " buffer="16kb"%>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	String strErrMsg = null;
	String strTemp   = null;
	String mName = null;

//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD-CARD MANAGEMENT"),"0"));
		if(iAccessLevel == 0)
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("CASH CARD"),"0"));
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are already logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../commfile/unauthorized_page.jsp");
		return;
	}
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Cash Card-POS TERMINAL REPORT","pos_terminal_report.jsp");					
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
	Vector vEditInfo  = null; 
	Vector vTransResult = null;
	Vector vIPResult = null;
	Vector vStudInfo  = null; 
	int pageNo = 0;
	int i = 0;
	int iSearchResult = 0;
	boolean bolIsBasic = false;
	String[] astrConvertYrLevel = {"N/A","1st Yr","2nd Yr","3rd Yr","4th Yr","5th Yr","6th Yr","7th Yr","8th Yr"};
	String[] astrConvertSem     = {"Summer","1st Sem","2nd Sem","3rd Sem"};
	
	Pos cardTrans = new Pos();
	enrollment.FAPaymentUtil pmtUtil = new enrollment.FAPaymentUtil();
	
	vIPResult = cardTrans.operateOnIPFilter(dbOP, request);
	if (vIPResult == null) {%>
		<p style="font-weight:bold; font-color:red; font-size:16px;"><%=cardTrans.getErrMsg()%></p>
	<%
		dbOP.cleanUP();
		return;	
	}	
		vTransResult = cardTrans.operateOnTransaction(dbOP, request, 4, null);
		if(vTransResult == null){%>
		<p style="font-weight:bold; font-color:red; font-size:16px;"><%=cardTrans.getErrMsg()%></p>
		<%
		dbOP.cleanUP();
		return;	
	}
	else	
			iSearchResult = cardTrans.getSearchCount();
%>	
<body>
<%if(vTransResult != null) {%>
<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
<tr bgcolor="#DDDDEE"> 
  <td height="25" colspan="6" class="thinborder" align="center">
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
     <td width="85%" align="center"><strong>LIST OF TRANSACTIONS </strong></td>
     <td width="15%" align="right">
	 Total:<strong><%=(String)vTransResult.remove(0)%></strong>
    </td>
  </tr>
  </table>
  </td>
</tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
<tr bgcolor="#FFFFFF"> 
  <td width="72%" class="thinborderLEFT"><strong>Total Results: <%=iSearchResult%> - Showing(<strong><%=cardTrans.getDisplayRange()%></strong>)</strong></td>
  <td width="28%" class="thinborderRIGHT" height="25">&nbsp;
  <%
	int iPageCount = 1;
	iPageCount = iSearchResult/cardTrans.defSearchSize;		
	if(iSearchResult % cardTrans.defSearchSize > 0) 
		++iPageCount;
	strTemp = " - Showing("+cardTrans.getDisplayRange()+")";
	if(iPageCount > 1){%> 
		<div align="right">Page ---> 
		<%
			strTemp = (String)request.getParameter("jumpto");
		%> 
		<%=strTemp%>
		</div>
	<%}%>
  </td>
</tr>
</table>
<table width="100%" cellspacing="0" cellpadding="0" class="thinborder" bgcolor="#FFFFFF">
<tr style="font-weight:bold" align="center">
  <td height="25" class="thinborder" style="font-size:9px;" width="9%">Student ID</td> 
  <td class="thinborder" style="font-size:9px;" width="23%">Name</td> 
  <td class="thinborder" style="font-size:9px;" width="10%">Reference</td> 
  <td class="thinborder" style="font-size:9px;" width="25%">Transaction Note</td> 
  <td class="thinborder" style="font-size:9px;" width="8%">Posted By </td> 
  <td class="thinborder" style="font-size:9px;" width="19%">Transaction Date</td>  
  <td class="thinborder" style="font-size:9px;" width="6%">Amount</td>
</tr>
<%
for(i = 0; i < vTransResult.size(); i += 13){
%>	
<tr>  
  <td class="thinborder" style="padding-top: 5px;padding-bottom: 5px">&nbsp;<%=(String)vTransResult.elementAt(i + 9)%></td>
  <td class="thinborder">&nbsp;
  <%=(String)vTransResult.elementAt(i + 12)%>, 
  <%=(String)vTransResult.elementAt(i + 10)%> 
  <%
  	mName = (String)vTransResult.elementAt(i + 11);
	mName = mName.substring(0,1);
  %>
  <%=mName%>.</td>
  <td class="thinborder">&nbsp;<%=(String)vTransResult.elementAt(i + 3)%></td>
  <td class="thinborder">&nbsp;<%=(String)vTransResult.elementAt(i + 4)%></td>
  <td class="thinborder">&nbsp;<%=(String)vTransResult.elementAt(i + 6)%></td>
  <td class="thinborder">&nbsp;<%=(String)vTransResult.elementAt(i + 2)%></td>
  <td class="thinborder" align="right">&nbsp;
  <%=CommonUtil.formatFloat((String)vTransResult.elementAt(i + 5), true)%></td>
</tr>
<%}//End of vTransResut%>	
</table>
<%}//End of vTransResult if not null%>	
</body>
</html>
<%
dbOP.cleanUP();
%>