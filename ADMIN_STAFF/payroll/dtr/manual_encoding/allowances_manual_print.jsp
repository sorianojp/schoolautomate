<%@ page language="java" import="utility.*,java.util.Vector,payroll.PReDTRME" %>
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
<title>print manually encoded allowances</title>
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
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Post Deductions","allowances_manual_print.jsp");

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
														"allowances_manual_print.jsp");
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
	int iSearchResult = 0;
	int i = 0;
	String strPayrollPeriod  = null;
	boolean bolPageBreak = false;

	vRetResult = prEdtrME.operateOnManualAllowance(dbOP,request, 4);
	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	strTemp = WI.fillTextValue("sal_period_index");				
	for(i = 0; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
		if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
			 strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 7);
			 break;
		}
	}	
		 
	if (vRetResult != null) {	
		int j = 0; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){	
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="10">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="20" colspan="5" class="thinborder"><div align="center"><strong>LIST OF EMPLOYEES WITH MANUALLY ENCODED ALLOWANCE FOR <%=strPayrollPeriod%></strong></div></td>
    </tr>
    <tr>
      <td width="4%" class="thinborder">&nbsp;</td>
      <td width="7%" class="thinborder">&nbsp;</td> 
      <td width="33%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="44%" align="center" class="thinborder"><strong>DEPARTMENT/OFFICE</strong></td>
      <td width="12%" align="center" class="thinborder">&nbsp;</td>
    </tr>
		<%
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=8,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			
		%>
    <tr>
      <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iCount%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
			<input type="hidden" name="user_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%> </td>
    <%
		  strTemp = (String)vRetResult.elementAt(i + 7);
			// strTemp = WI.getStrValue(strTemp,"0");		
			strTemp = CommonUtil.formatFloat(strTemp,true);			
		%>
		  <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
		  <%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1") && !WI.fillTextValue("copy_all").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 7);
			else{
				if(WI.fillTextValue("copy_all").equals("1"))
					strTemp = WI.fillTextValue("amount_1");
			}
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>			
    </tr>
    <%} //end for loop%>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td height="18">&nbsp;</td>
    </tr>
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