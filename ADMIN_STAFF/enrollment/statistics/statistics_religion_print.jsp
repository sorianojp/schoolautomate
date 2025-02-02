<%@ page language="java" import="utility.*,enrollment.VMAEnrollmentReports,java.util.Vector" %>
<%	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	//add security here.
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-STATISTICS","statistics_enrollees_neu.jsp");
	}catch(Exception exp){
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%return;
	}
	//authenticate this user.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<body>
<%
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"Enrollment","STATISTICS",request.getRemoteAddr(),
															"statistics_enrollees_neu.jsp");
	if(iAccessLevel == -1)//for fatal error.
	{
		dbOP.cleanUP();
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		dbOP.cleanUP();
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	//end of authenticaion code.	
	Vector vRetResult = new Vector();	
	Vector vRetTotal = new Vector();
	VMAEnrollmentReports ER = new VMAEnrollmentReports();
	
 //   vRetResult = ER.getStudReligionStatistics(dbOP, request,1);
	vRetResult = ER.getStudReligionStatistics(dbOP, request, Integer.parseInt(WI.fillTextValue("option")));
    if(vRetResult == null)
		strErrMsg = ER.getErrMsg();		
    else
	   vRetTotal = (Vector)vRetResult.remove(0);
%>
 </table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		  <tr>
			<td height="83"><div align="center"><font size="2">
			  <strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong>
			  <br><%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
			  <br> AY <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%> <br>
			   Statistics of Religion<br>
				As of <%=WI.fillTextValue("date")%>
				</font></div></td>
		  </tr>
		  <tr>
		  	<td height="30">&nbsp;</td>
		  </tr>
		</table>
<%if(vRetResult != null && vRetResult.size() > 0){
      String strCourseProgram = null;
  %>
	
   <table width="100%" cellpadding="0" cellspacing="0" border="0" bgcolor="#FFFFFF" class="thinborder">   
    
    <tr>
      <td height="26" rowspan="2" class="thinborder" align="center"><strong>&nbsp;</strong></td>
      <td colspan="3" height="15" class="thinborder" align="center"><strong>NEW</strong></td>
	  <td colspan="3" class="thinborder" align="center"><strong>OLD</strong></td>
	  <td width="8%" rowspan="2" class="thinborder" align="center"><strong>TOTAL INC</strong></td>
	  <td width="8%" rowspan="2" class="thinborder" align="center"><strong>TOTAL NON INC</strong></td>
	  <td width="9%" rowspan="2" class="thinborder" align="center"><strong>TOTAL</strong></td>
    </tr>
	<tr>
		<td width="8%" height="15" align="center" class="thinborder"><strong>INC</strong></td>
		<td width="8%" align="center" class="thinborder"><strong>Non-INC</strong></td>
		<td width="8%" align="center" class="thinborder"><strong>TOTAL</strong></td>
		<td width="8%" align="center" class="thinborder"><strong>INC</strong></td>
		<td width="9%" align="center" class="thinborder"><strong>Non-INC</strong></td>
		<td width="8%" align="center" class="thinborder"><strong>TOTAL</strong></td>
	</tr>
	<% 
	
	
	int iSubINCTot = 0;
	int iSubNonINCTot = 0;
	
	int iOldSubINCTot = 0;
	int iOldSubNonINCTot = 0;
	
	String strPrevCCName = "";
	String strCurrCCName = null;
	for(int x = 0; x < vRetResult.size(); x += 10){
      strCurrCCName = (String)vRetResult.elementAt(x+1);
	  if(!strPrevCCName.equals(strCurrCCName)&& x >= 0){ //
	  	strPrevCCName = strCurrCCName;
		
		if(x > 0){
	%>		
		
	  <tr style="font-weight:bold;">
	  	<td align="right" height="25" class="thinborder" style="padding-right:40px;">SUB-TOTAL</td>
	  	<td height="25" class="thinborder" align="center"><%=iSubINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iSubINCTot+iSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubNonINCTot+iOldSubINCTot%></td>
		<td class="thinborder" align="center"><%=iOldSubINCTot+iSubINCTot%></td>
		<td class="thinborder" align="center"><%=iOldSubNonINCTot+iSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubNonINCTot+iOldSubINCTot+iSubINCTot+iSubNonINCTot%></td>
	  </tr>	
	  <%
	  iSubINCTot = 0;
	  iSubNonINCTot = 0;
	  iOldSubINCTot = 0;
	  iOldSubNonINCTot = 0;
	  }%>
		
		<tr>
		  <td height="20" colspan="10" class="thinborder"><strong><%=WI.getStrValue(strCurrCCName).toUpperCase()%></strong></td>
		</tr>
	<%}%>
	  <tr>
	  	<td height="25" class="thinborder" style="padding-left:40px;"><%=vRetResult.elementAt(x+2)%></td>
	  	<td height="25" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(x+3),"0")%></td>
		<td height="25" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(x+4),"0")%></td>
		<td height="25" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(x+5),"0")%></td>
		<td height="25" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(x+6),"0")%></td>
		<td height="25" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(x+7),"0")%></td>
		<td height="25" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(x+8),"0")%></td>
		<%
		strTemp = Integer.toString(Integer.parseInt(WI.getStrValue(vRetResult.elementAt(x+3),"0"))+Integer.parseInt(WI.getStrValue(vRetResult.elementAt(x+6),"0")));
		%>
		<td style="text-align:center" class="thinborder"><%=strTemp%></td>
		<%
		strTemp = Integer.toString(Integer.parseInt(WI.getStrValue(vRetResult.elementAt(x+4),"0"))+Integer.parseInt(WI.getStrValue(vRetResult.elementAt(x+7),"0")));
		%>
		<td style="text-align:center" class="thinborder"><%=strTemp%></td>
		<td height="25" class="thinborder" align="center"><%=WI.getStrValue(vRetResult.elementAt(x+9),"0")%></td>
	  </tr>	
    <% 
	iSubINCTot += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(x+3),"0"));
	iSubNonINCTot  += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(x+4),"0"));
	
	iOldSubINCTot += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(x+6),"0"));
	iOldSubNonINCTot  += Integer.parseInt(WI.getStrValue(vRetResult.elementAt(x+7),"0"));
	}// end of vRetResult loop%>
	
	
	<tr style="font-weight:bold;">
	  	<td align="right" height="25" class="thinborder" style="padding-right:40px;">SUB-TOTAL</td>
	  	<td height="25" class="thinborder" align="center"><%=iSubINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iSubINCTot+iSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubNonINCTot+iOldSubINCTot%></td>
		<td class="thinborder" align="center"><%=iOldSubINCTot+iSubINCTot%></td>
		<td class="thinborder" align="center"><%=iOldSubNonINCTot+iSubNonINCTot%></td>
		<td height="25" class="thinborder" align="center"><%=iOldSubNonINCTot+iOldSubINCTot+iSubINCTot+iSubNonINCTot%></td>
	</tr>
	
<%
int iTotNONINC = 0;
int iTotINC = 0;
%>
	<tr style="font-weight:bold;">
		<td class="thinborder" align="right" style="padding-right:40px;" height="25"><font color="#FF0000">GRAND TOTAL</font></td>
		<%
		strTemp = (String)vRetTotal.remove(0);
		iTotINC = Integer.parseInt(WI.getStrValue(strTemp,"0"));
		%>
		<td class="thinborder" align="center"><font color="#FF0000"><%=strTemp%></font></td>
		<%
		strTemp = (String)vRetTotal.remove(0);
		iTotNONINC = Integer.parseInt(WI.getStrValue(strTemp,"0"));
		%>
		<td class="thinborder" align="center"><font color="#FF0000"><%=strTemp%></font></td>
		<td class="thinborder" align="center"><font color="#FF0000"><%=vRetTotal.remove(0)%></font></td>
		<%
		strTemp = (String)vRetTotal.remove(0);
		iTotINC += Integer.parseInt(WI.getStrValue(strTemp,"0"));
		%>
		<td class="thinborder" align="center"><font color="#FF0000"><%=strTemp%></font></td>
		<%
		strTemp = (String)vRetTotal.remove(0);
		iTotNONINC += Integer.parseInt(WI.getStrValue(strTemp,"0"));
		%>
		<td class="thinborder" align="center"><font color="#FF0000"><%=strTemp%></font></td>
		<td class="thinborder" align="center"><font color="#FF0000"><%=vRetTotal.remove(0)%></font></td>
		<td class="thinborder" align="center"><font color="#FF0000"><%=iTotINC%></font></td>
		<td class="thinborder" align="center"><font color="#FF0000"><%=iTotNONINC%></font></td>
		<td class="thinborder" align="center"><font color="#FF0000"><%=vRetTotal.remove(0)%></font></td>
	</tr>
  </table>

<%} // end of vRetResult!=null && vRetResult.size()>0%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	  <td height="25" colspan="3">&nbsp;</td>
	</tr>
</table>  
<script language="JavaScript">
	window.print();
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>
