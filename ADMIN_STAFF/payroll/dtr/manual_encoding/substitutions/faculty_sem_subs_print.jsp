<%@ page language="java" import="utility.*,java.util.Vector,payroll.PReDTRME" %>
<%
	WebInterface WI = new WebInterface(request);//to make sure , i call the dynamic opener form name to reload when close window is clicked.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
 %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print Faculty substitutions</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css"> 
</head>
<script language="JavaScript" src="../../../../../jscript/common.js"></script> 

<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strHasWeekly  = null;
 
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-MISC. DEDUCTIONS-Post Deductions","post_ded.jsp");

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
														"Payroll","DTR",request.getRemoteAddr(),
														"faculty_sem_subs.jsp");
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
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

	Vector vRetResult = null;
	PReDTRME prEdtrME = new PReDTRME();
	int i = 0; 
	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Trimester"}; 
	boolean bolPageBreak  = false;

	vRetResult = prEdtrME.operateOnSemSubstitutions(dbOP,request, 4);
	if (vRetResult != null) {	
		int j = 0; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){	 
%>
<body onLoad="javascript:window.print();">
<form name="form_"> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder">
    <tr> 
		<%if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = "WITH";
			else
				strTemp = "WITHOUT";
		%>	
      <td height="20" colspan="6" align="center" class="thinborder"><strong>LIST OF EMPLOYEES <%=strTemp%> ENCODED SUBSTITUTIONS FOR <%=astrConvertSem[Integer.parseInt(WI.fillTextValue("term"))]%> <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></strong></td>
    </tr>
    <tr>
      <td width="3%" rowspan="2" class="thinborder">&nbsp;</td>
      <td width="12%" rowspan="2" class="thinborder">&nbsp;</td> 
      <td width="35%" height="23" rowspan="2" align="center" class="thinborder"><strong><font size="1">EMPLOYEE NAME </font></strong></td>
      <td width="31%" rowspan="2" align="center" class="thinborder"><strong><font size="1">DEPARTMENT/OFFICE</font></strong></td>
      <td height="16" colspan="2" align="center" class="thinborder"><strong><font size="1">DURATION</font><font size="1"><a href="javascript:CopyHour();"></a></font></strong></td>
    </tr>
    <tr>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">Hours</font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">Minutes</font></strong></td>
    </tr>
		<%
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=13,++iIncr, ++iCount){
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
							(String)vRetResult.elementAt(i+4), 4).toUpperCase()%></strong></font>							</td>
      <%if((String)vRetResult.elementAt(i + 5)== null || (String)vRetResult.elementAt(i + 6)== null){
		  	strTemp = " ";			
		  }else{
		  	strTemp = " - ";
		  }
		%>							
      <td class="thinborder">&nbsp; <%=WI.getStrValue((String)vRetResult.elementAt(i + 5),"")%><%=strTemp%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6),"")%> </td>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 8);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>			
      <td align="center" class="thinborder"><strong><%=WI.getStrValue(strTemp, "&nbsp;")%></strong></td>
		<%
			strTemp = "";
			if(WI.fillTextValue("with_schedule").equals("1"))
				strTemp = (String)vRetResult.elementAt(i + 9);
			strTemp = WI.getStrValue(strTemp,"0");
			
			if(Double.parseDouble(strTemp) == 0d)
				strTemp = "";
		%>			
      <td align="center" class="thinborder"><strong><%=WI.getStrValue(strTemp, "&nbsp;")%></strong></td>
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