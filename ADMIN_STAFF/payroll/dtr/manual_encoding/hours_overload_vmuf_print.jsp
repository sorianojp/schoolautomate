<%@ page language="java" import="utility.*,java.util.Vector,payroll.PReDTRME,payroll.OverloadMgmt" %>
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
<title>Print overload hours worked for VMUF</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","post_ded.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
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
														"Payroll","DTR",request.getRemoteAddr(),
														"encode_hours_overload_vmuf.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

	Vector vRetResult = null;
	Vector vSalaryPeriod 		= null;//detail of salary period.
	PReDTRME prEdtrME = new PReDTRME();
	OverloadMgmt Overload = new OverloadMgmt();
	int iSearchResult = 0;
	int i = 0;
	String strPayrollPeriod  = null;	
	strTemp = WI.getStrValue(WI.fillTextValue("with_schedule"),"1");
	boolean bolWithSched = strTemp.equals("1");
	boolean bolPageBreak = false;
	
	vRetResult = Overload.operateOnManualOverloadVMUF(dbOP,request, 4);
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	strTemp = WI.fillTextValue("sal_period_index");			
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
	if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
	  }//end of if condition.		  
	 }//end of for loop.	

	if (vRetResult != null) {			
		int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iTotalPages = vRetResult.size()/(13*iMaxRecPerPage);				
		int iIncr    = 1;
		int iPageNo = 1;
		if(vRetResult.size()%(13*iMaxRecPerPage) > 0)
			iTotalPages++;		
		for (;iNumRec < vRetResult.size();iPageNo++){	
%>
<body onLoad="javascript:window.print();">
<form method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="15%" height="20">&nbsp;</td>
			<%
				if(bolWithSched)
					strTemp = "WITH";
				else
					strTemp = "WITHOUT";				
			%>
      <td width="70%" height="20" align="center"><strong>LIST OF EMPLOYEES <%=strTemp%> OVERLOAD </strong><br>
          <span class="thinborderLEFT">Salary Schedule : <%=strPayrollPeriod%></span></td>
      <td width="15%" height="20">page : <%=iPageNo%> of <%=iTotalPages%></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="10" align="center" class="thinborder">&nbsp;</td>
    </tr>
    <tr>
      <td width="3%" rowspan="2" class="thinborder">&nbsp;</td>
      <td width="3%" rowspan="2" class="thinborder">&nbsp;</td> 
      <td width="26%" height="23" rowspan="2" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="32%" rowspan="2" align="center" class="thinborder"><strong>COLLEGE/ DEPARTMENT/ OFFICE</strong></td>
      <td height="24" colspan="3" align="center" class="thinborder"><strong><font size="1">WITHIN OFFICE HOURS </font></strong></td>
      <td colspan="3" align="center" class="thinborder"><strong><font size="1">OUTSIDE OFFICE HOURS</font></strong></td>
    </tr>
    <tr>
      <td width="6%" align="center" valign="bottom" class="thinborder"><strong><font size="1">%</font></strong></td>
      <td width="6%" align="center" valign="bottom" class="thinborder"><strong><font size="1">LEC HOURS</font></strong></td>
      <td width="6%" align="center" valign="bottom" class="thinborder"><strong><font size="1">LAB HOURS</font></strong></td>
      <td width="6%" align="center" valign="bottom" class="thinborder"><strong><font size="1">%</font></strong></td>
      <td width="6%" align="center" valign="bottom" class="thinborder"><strong><font size="1">LEC HOURS</font></strong></td>
      <td width="6%" align="center" valign="bottom" class="thinborder"><strong><font size="1">LAB HOURS</font></strong></td>
    </tr>
		<% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=13,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>	
    <tr>
      <td class="thinborder">&nbsp;<%=iIncr%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = "<br>";
		  }
		%>							
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%> </td>
		  <%			
			strTemp = (String)vRetResult.elementAt(i + 7);
			strTemp = WI.getStrValue(strTemp,"&nbsp;");
			%>
		  <td align="center" class="thinborder"><%=strTemp%></td>
		  <%
			strTemp = (String)vRetResult.elementAt(i + 8);
			strTemp = WI.getStrValue(strTemp,"&nbsp;");
			%>			
      <td align="center" class="thinborder"><%=strTemp%></td>
		  <%
				strTemp = (String)vRetResult.elementAt(i + 9);
				strTemp = WI.getStrValue(strTemp,"&nbsp;");
			%>
      <td align="center" class="thinborder"><%=strTemp%></td>
		  <%
				strTemp = (String)vRetResult.elementAt(i + 10);
				strTemp = WI.getStrValue(strTemp,"&nbsp;");
			%>
      <td align="center" class="thinborder"><%=strTemp%></td>
		  <%
				strTemp = (String)vRetResult.elementAt(i + 11);
				strTemp = WI.getStrValue(strTemp,"&nbsp;");
			%>			
      <td align="center" class="thinborder"><%=strTemp%></td>
		  <%
				strTemp = (String)vRetResult.elementAt(i + 12);
				strTemp = WI.getStrValue(strTemp,"&nbsp;");
			%>			
      <td align="center" class="thinborder"><%=strTemp%></td>
    </tr>
    <%} //end for loop%>
  </table>
  
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break ony if it is not last page.

	} //end for (iNumRec < vRetResult.size()
} //end end upper most if (vRetResult !=null)%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>