<%@ page language="java" import="utility.*,java.util.Vector,payroll.PReDTRME, payroll.PRMiscEarnings" %>
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
	<title>Set Misc. deduction by batch</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
	<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
//add security here.
%>
<% 

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions (Batch)","post_earnings_batch.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
	}
catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","MISC. DEDUCTIONS",request.getRemoteAddr(),
														"post_earnings_batch.jsp");
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

	Vector vRetResult = null;
	PRMiscEarnings PREarnings = new PRMiscEarnings (request);
	int iSearchResult = 0;
	int i = 0;
  	
%>
<body onLoad="javascript:window.print();">

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="23" colspan="3">
		<a href="./post_earnings_batch.jsp">
			<img src="../../../images/go_back.gif" width="50" height="27" border="0">
		</a>
    </tr>
	<tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><strong>:::: 
        MISCELLANEOUS EARNINGS ::::</strong></td>
    </tr>
</table>
  <% 
  	vRetResult = PREarnings.operateOnMiscEarningsBatch(dbOP,4);
  %>
  <% if (vRetResult != null &&  vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="10" align="center" bgcolor="#FFFFFF" class="thinborder"><strong>LIST OF EMPLOYEES</strong></td>
    </tr>
    <tr>
      <td width="3%" class="thinborder">&nbsp;</td>
      <td width="10%" align="center" class="thinborder"><font size="1"><strong>EMPLOYEE ID </strong></font></td> 
      <td width="28%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="40%" align="center" class="thinborder"><strong>DEPARTMENT/OFFICE</strong></td>
      <td width="10%" align="center" class="thinborder"><strong><font size="1">AMOUNT</font><font size="1"></strong></td>
	  <%if(WI.fillTextValue("with_schedule").equals("1")){%>
		<td width="10%" align="center" class="thinborder"><strong><font size="1">EARNING BAL.</font><font size="1"></strong> <br>
		</td>
      <%}%>
    </tr>
    <% 	
		int iCount = 1;
		String strDisabled = null;
		double dEarnBal = 0.0;
		double dEarnAmt = 0.0;
		
		for (i = 0; i < vRetResult.size(); i+=9,iCount++){
			dEarnBal = Double.parseDouble( WI.getStrValue((String)vRetResult.elementAt(i + 8),"0"));
			dEarnAmt = Double.parseDouble( WI.getStrValue((String)vRetResult.elementAt(i + 6),"0"));
			if( dEarnBal < dEarnAmt ){
				strDisabled = " disabled";
			} else {
				strDisabled = "";
			}
	 %>
    <tr >
      <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
 			<input type="hidden" name="post_ded_index_<%=iCount%>" value="<%=vRetResult.elementAt(i+7)%>">			
			<input type="hidden" name="emp_id_<%=iCount%>" value="<%=vRetResult.elementAt(i+1)%>">			
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%></td>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1") && !WI.fillTextValue("copy_all").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 6);
			else{
				if(WI.fillTextValue("copy_all").equals("1"))
					strTemp = WI.fillTextValue("amount_1");
			}
			//strTemp = comUtil.formatFloat(strTemp, true);
			strTemp = WI.getStrValue(strTemp,"0");
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "&nbsp;";
		%>			
      <td align="center" class="thinborder">
	  	<strong> 
			<%=strTemp%>
		</strong>
	  </td>
		<%if(WI.fillTextValue("with_schedule").equals("1")){
			strTemp = "";
			strTemp = (String)vRetResult.elementAt(i+8);
			strTemp = WI.getStrValue(strTemp,"0");
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "&nbsp;";
		%>	
	  
	  <td align="center" class="thinborder"><strong> 
			<%=strTemp%>
	  </strong></td>
		<%}%>

    </tr>
    <%} //end for loop%>
    
    
    <input type="hidden" name="emp_count" value="<%=iCount%>">
  </table>
  
<% } // end vRetResult != null && vRetResult.size() > 0 %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_page">
  <input type="hidden" name="searchEmployee" > 
  <input type="hidden" name="page_action">	
	  <input type="hidden" name="copy_all">	

</body>
</html>
<%
dbOP.cleanUP();
%>