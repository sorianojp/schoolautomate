<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRAllowances, payroll.PayrollConfig" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css"> 
TD.thinborderBOTTOMRIGHT {
	border-right: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}

TD.thinborderBOTTOM{
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
TD.thinborderBOTTOMLEFTRIGHT{
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
}
</style>

</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<form name="form_">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strAllowanceName = WI.fillTextValue("allowance_name");
//add security here.

	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL-CONFIGURATION"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-CONFIGURATION-COLA","variable_allowance_set.jsp");
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

//end of authenticaion code.
	Vector vRetResult = null;
	
	PRAllowances prAllow = new PRAllowances();
	PayrollConfig pr = new PayrollConfig();
	
	int iSearchResult = 0;
	boolean bolPageBreak = false;
	boolean bolFixed = false;
	String strAmount = null;
	Vector vAllowanceInfo = null;
	double dTotal = 0d;
	vAllowanceInfo = pr.operateOnColaEcola(dbOP,request,3, WI.fillTextValue("cola_ecola_index"));
	if(vAllowanceInfo != null){
		strAllowanceName = (String)vAllowanceInfo.elementAt(6);
		strAllowanceName += WI.getStrValue((String)vAllowanceInfo.elementAt(7),"&nbsp;(",")","");						
		bolFixed = WI.getStrValue((String)vAllowanceInfo.elementAt(5),"0").equals("0");
		strAmount =  WI.getStrValue((String)vAllowanceInfo.elementAt(3),"");
	}
	
	vRetResult = prAllow.operateOnAllowances(dbOP,request,4);
  if (vRetResult != null) {
	
	int i = 0; int iPage = 1; int iCount = 0;
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = vRetResult.size()/(15*iMaxRecPerPage);	
	if(vRetResult.size() % iMaxRecPerPage > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="18" colspan="5" class="thinborderBOTTOM">&nbsp;</td>
    </tr>
	  <%
	  if((WI.fillTextValue("with_schedule")).equals("1"))
	    strTemp = "EMPLOYEES WITH " + strAllowanceName + " ALLOWANCE";
	  else
	    strTemp = "EMPLOYEES WITHOUT " + strAllowanceName + " ALLOWANCE";
	  %>	
    <tr> 
      <td height="25" colspan="5" align="center" class="thinborderBOTTOMLEFTRIGHT"><strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td width="4%" height="24" align="center" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
      <td width="9%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>EMPLOYEE ID </strong></font></td>
      <td width="37%" align="center" class="thinborderBOTTOMRIGHT"><font size="1"><strong>EMPLOYEE NAME </strong></font></td>
      <td align="center" class="thinborderBOTTOMRIGHT"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
      <%if(WI.fillTextValue("with_schedule").equals("1") && bolFixed){%>
			<td align="center" class="thinborderBOTTOMRIGHT"><strong><font size="1">AMOUNT</font></strong></td>
			<%}%>
    </tr>
    <%for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=15,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			}
			else 
				bolPageBreak = false;			
		%>	
    <tr> 
      <td height="24" align="center" class="thinborderBOTTOMLEFTRIGHT"><span class="thinborderTOPLEFT"><%=iIncr%></span></td>
			<td class="thinborderBOTTOMRIGHT">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<td class="thinborderBOTTOMRIGHT"><font size="1"><strong>&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+3), (String)vRetResult.elementAt(i+4),
							(String)vRetResult.elementAt(i+5), 4).toUpperCase()%></strong></font></td>
      <%if((String)vRetResult.elementAt(i + 6)== null || (String)vRetResult.elementAt(i + 7)== null){
		  	strTemp = "";			
		  }else{
		  	strTemp = " - ";
		  }
		%>							
			<td width="39%" class="thinborderBOTTOMRIGHT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 7),"")%></td>
		  <%if(WI.fillTextValue("with_schedule").equals("1") && bolFixed){
				strAmount = CommonUtil.formatFloat(strAmount, true);
				strAmount = ConversionTable.replaceString(strAmount, ",","");
				dTotal += Double.parseDouble(strAmount);
			%>			
			<td width="11%" align="right" class="thinborderBOTTOMRIGHT"><%=strAmount%>&nbsp;</td>
			<%}%>
    </tr>

    <%}// end for loop%>
  </table>
  <%if (iNumRec < vRetResult.size()){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()%>
<%if(bolFixed){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="89%" align="right"><strong>TOTAL <%=strAllowanceName%> ALLOWANCE : </strong></td>
    <td width="11%" align="right"><strong><%=CommonUtil.formatFloat(dTotal, true)%>&nbsp;</strong></td>
  </tr>
</table>
<%}%>
<%} //end end upper most if (vRetResult !=null)%>

</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
