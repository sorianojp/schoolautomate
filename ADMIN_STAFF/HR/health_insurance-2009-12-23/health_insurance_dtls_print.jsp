<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInsuranceTracking" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
	boolean bolIsSchool = false;
	if( (new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;
	String[] strColorScheme = CommonUtil.getColorScheme(6);
	//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Health Insurance Details</title>
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

	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-Personnel-Health Insurance Details Print","health_insurance_details_print.jsp");
	}
	catch(Exception exp)	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
	
	Vector vRetResult = null;
	Vector vUserInfo = null;
	HRInsuranceTracking hriTracker = new HRInsuranceTracking();
	int iSearchResult = 0;
	int i = 0;
  
	enrollment.Authentication auth = new enrollment.Authentication();
    request.setAttribute("emp_id", WI.fillTextValue("emp_id"));
    
	vUserInfo = auth.operateOnBasicInfo(dbOP, request, "0");
	if(vUserInfo != null)
		vRetResult = hriTracker.viewHealthInsuranceDetails(dbOP,(String)vUserInfo.elementAt(0));
			
	if(vRetResult != null){
		int iCount = 0;
		int iNumRec = 0;
%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
			<td height="25" colspan="5" align="center">
				<strong>:::: HEALTH INSURANCE CREDITS ::::</strong></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
	   <tr>
		  <td colspan="2" style="font-weight:bold; font-size:13px;"><u>For Year : <%=WI.getTodaysDate(12)%></u></td>
	  </tr>
	  <tr>
			<td colspan="2">&nbsp;</td>
	  </tr>
		<tr> 
			<td height="10" colspan="2"><strong>EMPLOYEE INFORMATION: </strong></td>
		</tr>
		<tr> 
			<td height="10" colspan="2">&nbsp;</td>
		</tr>
		<tr> 
			<td width="15%" height="10">Name:</td>
		    <td width="85%"><%=WebInterface.formatName((String)vUserInfo.elementAt(1),(String)vUserInfo.elementAt(2),(String)vUserInfo.elementAt(3),7)%></td>
		</tr>
		<tr> 
			<td>Dept/Office:</td>
			<%
				if((String)vUserInfo.elementAt(13)== null || (String)vUserInfo.elementAt(14)== null)
					strTemp = " ";			
				else
					strTemp = " - ";
			%>
			<td>
			<%=WI.getStrValue((String)vUserInfo.elementAt(13),"")%>
			<%=strTemp%>
			<%=WI.getStrValue((String)vUserInfo.elementAt(14),"")%> 
			</td>
		</tr>
		<tr> 
			<td height="10" colspan="2">&nbsp;</td>
		</tr>
	</table>
  
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
			<td height="20" colspan="5" class="thinborder" align="center"><strong> BENEFIT DETAILS</strong></td>
		</tr>
		<tr>
			<td width="3%"  align="center" height="23"    class="thinborder"><strong><font size="1">COUNT</font></strong></td>
			<td width="34%" align="center" class="thinborder"><strong><font size="1">BENEFIT</font></strong></td>
			<td width="12%" align="center" class="thinborder"><strong><font size="1">AMOUNT</font></strong></td>
			<td width="9%"  align="center" class="thinborder"><strong><font size="1">BALANCE </font></strong></td>
		</tr>
		<% 	
			for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=4, ++iCount){
				i = iNumRec;
		%>
		<tr>
			<td class="thinborder">&nbsp;<%=iCount%></td>
			<td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;
				<%=(String)vRetResult.elementAt(i+1)%></strong></font>			</td>
			<td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 2), true)%></td>		
			<td class="thinborder">&nbsp;<%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 3), true)%></td>
		</tr>
		<%} //end for loop%>
	</table>
	<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>