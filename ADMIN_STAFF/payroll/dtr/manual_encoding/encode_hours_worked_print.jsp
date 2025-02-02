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
<title>PRINT FACULTY HOURS WORKED</title>
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
														"post_ded.jsp");
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
	String strSlash = null;

	vSalaryPeriod = prEdtrME.operateOnSalaryPeriodNew(dbOP, request, 4);
	
	strTemp = WI.fillTextValue("sal_period_index");			
	for(; vSalaryPeriod != null && i < vSalaryPeriod.size(); i += 10) {
	if(strTemp.equals((String)vSalaryPeriod.elementAt(i))) {
		strPayrollPeriod = (String)vSalaryPeriod.elementAt(i + 6) +" - "+(String)vSalaryPeriod.elementAt(i + 7);
	  }//end of if condition.		  
	 }//end of for loop.

	vRetResult = prEdtrME.operateOnManualFacHours(dbOP,request, 4);
	if (vRetResult != null) {			
		int iCount = 0;
		int iTemp  = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iPageNo = 1;
		int iTotalPages = vRetResult.size()/(8*iMaxRecPerPage);				
		if(vRetResult.size()%(8*iMaxRecPerPage) > 0)
			iTotalPages++;		
		for (;iNumRec < vRetResult.size();iPageNo++){	
%>
<body onLoad="javascript:window.print();">
<form name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr> 
      <td width="15%" height="27" class="thinborderBOTTOM">&nbsp;</td>
      <td width="70%" height="27" align="center" class="thinborderBOTTOM"><strong>LIST OF EMPLOYEES WITH TEACHING LOAD<br>
        </strong><span class="thinborderLEFT">Salary Schedule : <%=strPayrollPeriod%></span></td>
      <td width="15%" height="27" class="thinborderBOTTOM">page : <%=iPageNo%> of <%=iTotalPages%></td>
    </tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
    <tr>
      <td width="4%" class="thinborder">&nbsp;</td>
      <td width="8%" class="thinborder">&nbsp;</td> 
      <td width="37%" height="23" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="33%" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
      <td width="18%" align="center" class="thinborderBOTTOMLEFTRIGHT"><strong><font size="1">HOURS WORKED</font></strong></td>
    </tr>
		<% 
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=9,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;			
	%>		 
    <tr>
      <td class="thinborder"><span class="thinborderTOPLEFT">&nbsp;<%=iIncr%></span></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td height="25" class="thinborder"><font size="1"><strong>&nbsp;&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+2), (String)vRetResult.elementAt(i+3),
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font></td>
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>							
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%> </td>
		  <%
				strSlash = "";
				strTemp = "";
				strTemp2 = "";
				if(WI.fillTextValue("with_schedule").equals("1")){
					strSlash = " and ";
					strTemp = (String)vRetResult.elementAt(i + 7);
					iTemp = Integer.parseInt(strTemp);
					if(iTemp <= 0){
						strTemp = "";
						strSlash = "";
					}
					
					strTemp2 = (String)vRetResult.elementAt(i + 8);
					iTemp = Integer.parseInt(strTemp2);
					if(iTemp <= 0){
						strTemp2 = "";
						strSlash = "";
					}						
				}
			%>			
		  <td align="right" class="thinborderBOTTOMLEFTRIGHT"><%=WI.getStrValue(strTemp,"","hr(s)" + strSlash,"")%><%=WI.getStrValue(strTemp2,"","min(s)","")%>&nbsp;</td>
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