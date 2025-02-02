<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInsuranceTracking" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Health Insurance Application</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<body onLoad="window.print();">
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	boolean bolPageBreak = false;
	
	String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
	if(strAuthTypeIndex == null){
		request.getSession(false).setAttribute("go_home","../../../../index.jsp");
		request.getSession(false).setAttribute("errorMessage","You are not logged in. Please login to access this page.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
			"Admin/staff-HR-Personnel-Health Insurance Print","health_insurance_application_print.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}

	Vector vRetResult = null;
	HRInsuranceTracking hriTracker = new HRInsuranceTracking();
	int iSearchResult = 0;
	int i = 0;
	boolean bolIsWthBenefit = WI.fillTextValue("with_benefits").equals("1");
	vRetResult = hriTracker.searchHealthInsurances(dbOP,request);
	if (vRetResult != null) {			
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(10*iMaxRecPerPage);	
		if(vRetResult.size()%(10*iMaxRecPerPage) > 0)
			iTotalPages++;	
		for (;iNumRec < vRetResult.size();iPageNo++){	
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr> 
			<td height="25" colspan="5" align="center">
				<strong>:::: HEALTH INSURANCE APPLICATION ::::</strong>
			</td>
		</tr>
	</table>
  	<table width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr>
			<td height="25" colspan="2">&nbsp;</td>
		</tr>
		<tr>
		  <td width="3%" height="25">&nbsp;</td>
	      <td width="16%">Insurance Type :  </td>
		  <td width="81%"><%=WI.fillTextValue("insurance_name")%></td>
	  </tr>
		<tr>
		  <td height="25" >&nbsp;</td>
	      <td>Year : </td>
		  <td><%=WI.fillTextValue("year_of")%></td>
	  </tr>
	  <tr>
		  <td height="10" >&nbsp;</td>
	      <td>&nbsp;</td>
		  <td>&nbsp;</td>
	  </tr>
		<tr>
			<td colspan="2" height="25" align="left" style="font-size:9px;">Page <%=iPageNo%> of <%=iTotalPages%></td>
		  	<td align="right" style="font-size:9px;">Date and Time Printed : <%=WI.getTodaysDateTime()%>&nbsp;</td>
	  </tr>
  	</table>
	
  	<table width="100%" border="0" cellpadding="0" cellspacing="0"  class="thinborder">
		<tr> 
			<%
				if(bolIsWthBenefit)
					strTemp = "HAVING INSURANCE";
				else
					strTemp = "NOT HAVING INSURANCE";
			%>
		  	<td height="20" colspan="7" bgcolor="#FFFFFF" class="thinborder"><div align="center"><strong>LIST OF EMPLOYEES <%=strTemp%></strong></div></td>
		</tr>
    	<tr>
			<td width="3%"  class="thinborder" align="center" height="23"><strong><font size="1">SL#</font></strong></td>
			<td width="8%"  class="thinborder" align="center"><strong><font size="1">EMP. ID</font></strong></td> 
			<td width="31%" class="thinborder" align="center"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
			<td width="29%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
			<%if(bolIsWthBenefit){%>
			<td width="12%" align="center" class="thinborder"><strong><font size="1">AMOUNT</font></strong></td>
			<td width="9%" align="center" class="thinborder"><strong><font size="1">BALANCE </font></strong></td>
			<%}%>
		</tr>
    	<% 
			for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=10, ++iCount){
				i = iNumRec;
				if (iCount > iMaxRecPerPage){
					bolPageBreak = true;
					break;
				}
				else 
					bolPageBreak = false;			
		%>
    	<tr>
      		<td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      		<td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      		<td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;
	  			<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
					(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
				<%
					if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null)
						strTemp = " ";			
					else
						strTemp = " - ";
				%>
      		<td class="thinborder">&nbsp;
	   			<%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%>
				<%=strTemp%>
				<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%>
			</td>
	<%if(bolIsWthBenefit){%>
	   		<td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 7), true)%> </td>	
      		<td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 8), true)%></td>
	<%}%>
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