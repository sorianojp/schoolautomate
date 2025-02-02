<%@ page language="java" import="utility.*, visitor.VisitLog, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
	if(request.getSession(false).getAttribute("userIndex") == null){%>
		<p style="font-size:16px; color:#FF0000;">You are logged out.</p>
		<%return;
	}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Search Visitor Log Print</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript" src="../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;		
	String strErrMsg = null;
	String strTemp = null;
	
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Visitor Management-Record Going In","search_visitor_log.jsp");
	}
	catch(Exception exp) {
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
	
	String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
	String[] astrDropListValEqual = {"equals","starts","ends","contains"};
	
	Vector vRetResult = null;
	boolean bolPageBreak = false;
	int i = 0;
	double dTemp = 0d;
	int iSearchResult = 0;
	
	VisitLog visitLog = new VisitLog();
	
	vRetResult = visitLog.searchVisitLogs(dbOP, request);
	if (vRetResult != null) {		
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(18*iMaxRecPerPage);
		if(vRetResult.size()%(18*iMaxRecPerPage) > 0)
			iTotalPages++;	
		for (;iNumRec < vRetResult.size();iPageNo++){	
	%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td width="15%" height="25" align="left" style="font-size:9px;">Page <%=iPageNo%> of <%=iTotalPages%></td>
		  	<td width="85%" align="right" style="font-size:9px;">Date and Time Printed : <%=WI.getTodaysDateTime()%>&nbsp;</td>
	  	</tr>
	</table>
	<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<tr>
			<td height="20" colspan="11" class="thinborder">
				<div align="center"><strong>VISITOR'S LIST</strong></div></td>
	 	</tr>
		<tr>
			<td height="25" align="center" class="thinborder" width="9%"><strong>DATE</strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>TIME-IN</strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>TIME-OUT</strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>ENCODED BY </strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>VISITOR'S RF CARD NO. </strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>VISITOR'S NAME </strong></td>
		    <td align="center" class="thinborder" width="9%"><strong> PICTURE </strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>ID PRESENTED </strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>VISITED</strong></td>
		    <td align="center" class="thinborder" width="9%"><strong>PURPOSE</strong></td>
		    <td align="center" class="thinborder" width="10%"><strong>REMARK</strong></td>
		</tr>
		<% 
			for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=20, ++iCount){
				i = iNumRec;
				if (iCount > iMaxRecPerPage){
					bolPageBreak = true;
					break;
				}
				else 
					bolPageBreak = false;	
		%>
		<tr>
			<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
		    <td class="thinborder"><%=CommonUtil.convert24HRTo12Hr(Double.parseDouble((String)vRetResult.elementAt(i+2)))%></td>
			<%
				dTemp = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i+3), "0"));
				if(dTemp == 0)
					strTemp = "&nbsp;";
				else
					strTemp = CommonUtil.convert24HRTo12Hr(dTemp);
			%>
		    <td class="thinborder"><%=strTemp%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+4)%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+5)%></td>
		    <td class="thinborder">
			<%=WebInterface.formatName((String)vRetResult.elementAt(i+6), (String)vRetResult.elementAt(i+7), (String)vRetResult.elementAt(i+8), 4)%></td>
		    <%
				strTemp = "../../upload_img/visitor/"+(String)vRetResult.elementAt(i+16)+".jpg";
			%>
			<td class="thinborder" align="center"><img src="<%=strTemp%>" width="50" height="50" border="1"></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+9)%></td>
			<%
			strTemp = WebInterface.formatName((String)vRetResult.elementAt(i+11), (String)vRetResult.elementAt(i+12), (String)vRetResult.elementAt(i+13), 4);
			if(strTemp == null || strTemp.length() == 0)
				strTemp = (String)vRetResult.elementAt(i+18);
			if(strTemp == null || strTemp.length() == 0)
				strTemp = (String)vRetResult.elementAt(i+19);

			%>
		    <td class="thinborder">
			<%=strTemp%></td>
		    <td class="thinborder"><%=(String)vRetResult.elementAt(i+14)%></td>
		    <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+15), "&nbsp;")%></td>
		</tr>
	<%} //end for loop%>
	</table>
	<%if (bolPageBreak){%>
		<DIV style="page-break-before:always" >&nbsp;</DIV>
	<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
	} //end end upper most if (vRetResult !=null)%>
</body>
</html>
<%
dbOP.cleanUP();
%>