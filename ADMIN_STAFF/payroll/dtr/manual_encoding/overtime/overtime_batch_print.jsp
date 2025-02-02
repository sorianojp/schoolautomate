<%@ page language="java" import="utility.*,java.util.Vector,payroll.OvertimeMgmt, payroll.PReDTRME" %>
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
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strHasWeekly = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Post Deductions","encode_manual_adjust.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strHasWeekly = readPropFile.getImageFileExtn("PAYROLL_WEEKLY","0");	
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
														"PAYROLL","DTR",request.getRemoteAddr(),
														"encode_manual_adjust.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"overtime_batch_print.jsp");
		
		if(iAccessLevel == 0){//NOT AUTHORIZED.
			dbOP.cleanUP();
			response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
			return;
		}	
}

	Vector vRetResult = null;
	Vector vSalaryPeriod 		= null;//detail of salary period.
	OvertimeMgmt OTMgmt = new OvertimeMgmt();
	PReDTRME prEdtrME = new PReDTRME();
	int iSearchResult = 0;
	int i = 0;
	double dTemp = 0d;
	int iTemp  = 0;
	String strPayrollPeriod  = null;
	String strSign  = null;
	
	vRetResult = OTMgmt.operateOnBatchOvertime(dbOP,request);
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
		int iTotalPages = vRetResult.size()/(11*iMaxRecPerPage);				
		int iIncr    = 1;
		int iPageNo = 1;
		boolean bolPageBreak  = false;
		if(vRetResult.size()%(11*iMaxRecPerPage) > 0)
			iTotalPages++;		
		for (;iNumRec < vRetResult.size();iPageNo++){	
%>

<body onLoad="javascript:window.print();">
<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="7" class="thinborder"><div align="center"><strong>LIST OF EMPLOYEES WITH OVERTIME </strong></div></td>
    </tr>
    <tr>
      <td width="4%" class="thinborder">&nbsp;</td>
      <td width="7%" class="thinborder">&nbsp;</td> 
      <td width="29%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="26%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>      
      <td width="11%" align="center" valign="bottom" class="thinborder"><strong><font size="1">CODE</font></strong></td>
      <td width="12%" align="center" valign="bottom" class="thinborder"><strong><font size="1">WORK DURATION</font></strong></td>			
      <td width="11%" align="center" valign="bottom" class="thinborder"><strong><font size="1">AMOUNT</font></strong></td>
    </tr>
		<% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=11,++iIncr, ++iCount){
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
			<%
					strTemp = (String)vRetResult.elementAt(i+1);
			%>
      <td class="thinborder">&nbsp;<%=strTemp%></td> 
			<%
					strTemp = WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4), 4).toUpperCase();
			%>
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=strTemp%></strong></font></td>
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }

					strTemp2 = WI.getStrValue((String)vRetResult.elementAt(i + 5),"") + strTemp + WI.getStrValue((String)vRetResult.elementAt(i + 6),"");
		%>
      <td class="thinborder">&nbsp;<%=strTemp2%></td>
		  <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
		  <% strSign = " and ";
				strTemp = (String)vRetResult.elementAt(i+8);
				iTemp = Integer.parseInt(ConversionTable.replaceString(strTemp,",",""));				
				if(iTemp == 0){
					strTemp = "";
					strSign = "";
				}		

				strTemp2 = (String)vRetResult.elementAt(i+10);				
				iTemp = Integer.parseInt(ConversionTable.replaceString(strTemp2,",",""));
				if(iTemp == 0){
					strTemp2 = "";
					strSign = "";
				}						
			%>
		  <td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"", " hr(s)" + strSign,"")%><%=WI.getStrValue(strTemp2,"", " min ","")%></td>
			<%			
			strTemp = (String)vRetResult.elementAt(i + 9);
			strTemp = WI.getStrValue(strTemp,"0");
			dTemp = Double.parseDouble(strTemp);
			strTemp = CommonUtil.formatFloat(dTemp,2);
			
			if(dTemp == 0d)
				strTemp = "";
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>			
			<%
					if(((String)vRetResult.elementAt(i + 8)).equals("1"))
						strTemp = "Added";
					else
						strTemp = "Deducted";
			%>
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