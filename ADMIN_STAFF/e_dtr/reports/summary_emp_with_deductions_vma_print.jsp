<%@ page language="java" import="utility.*,eDTR.ReportEDTR,java.util.Vector" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Summary of Employee DTR</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>
	.fontsize11{
		font-size : 11px;
	}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<body onLoad="javascript:window.print();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
 
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	
	Vector vRetResult = null;

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Reports & Statistics - Summary Emp with Absent","summary_emp_with_deductions_vma_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
	//authenticate this user.
	CommonUtil comUtil = new CommonUtil();
	int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
															"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
															"summary_emp_with_deductions_vma_print.jsp");	
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
	 
	int iSearchResult = 0;	
	int iDays = 0;
	int iHours = 0;
	int iMins = 0;
	int iRowCount = 0;
	double dTemp = 0d;

	ReportEDTR rD = new ReportEDTR(request);
	String[] astrConvertGender = {"M","F"};
	String[] astrMonth = {" Select Month"," January"," February", " March", " April", " May", " June",
							" July", " August", " September"," October", " November", " December"};
	boolean bolPageBreak = false;
	vRetResult = rD.viewDeductionsSummary(dbOP);
	if (vRetResult != null) {	
		int iCount = 0;
		int i = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		for (;iNumRec < vRetResult.size();){
%>
<form>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">   
  	<tr>
		<td align="center" height="50" valign="top">		
				<font size="2">
				<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
				</font>
				<font size="1">
					<%=SchoolInformation.getAddressLine1(dbOP,false,false)%>
				</font>	
		</td>
	</tr> 
    <tr>
			<%
				strTemp = WI.fillTextValue("strMonth");
				if(strTemp.length() > 0 && !strTemp.equals("0"))
					strTemp = astrMonth[Integer.parseInt(strTemp)] + " " + WI.fillTextValue("year_of");
				else
					strTemp = WI.fillTextValue("date_fr") + " - " + WI.fillTextValue("date_to");
				
			%>
      <td height="25" align="center"><strong>Summary of Employee DTR for <%=strTemp%></strong></td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
    <tr> 
		<td  width="2%" height="25" align="center"  class="thinborder"><strong><font size="1">&nbsp;</td>
      <td  width="10%" height="25" align="center"  class="thinborder"><strong><font size="1">EMPLOYEE 
          ID</font></strong></td>
      <td width="18%" align="center" class="thinborder"><strong><font size="1">EMPLOYEE 
          NAME</font></strong></td>
<% if (!strSchCode.startsWith("AUF")) {%>
      <%}%>
      <td width="19%" align="center" class="thinborder"><strong><font size="1">DIVISION/OFFICE</font></strong></td>
      <td width="18%" align="center" class="thinborder"><strong><font size="1">POSITION</font></strong></td>
      <td width="7%" align="center" class="thinborder"><strong><font size="1">HOURS WORKED</font></strong></td>
      <td width="6%" align="center" class="thinborder"><strong><font size="1">LATES (mins) </font></strong></td>
      <td width="8%" align="center" class="thinborder"><strong><font size="1">ABSENCES (days)</font></strong>      </td>
  	 <td width="12%" align="center" class="thinborder"><strong><font size="1">CONFORME </font></strong>      </td>
    </tr>
    <%		
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=14,++iIncr, ++iCount){
			i = iNumRec;
			if (iCount > iMaxRecPerPage){
				bolPageBreak = true;
				break;
			} else 
				bolPageBreak = false;			
		%>		
    <tr> 
		<td height="25" class="thinborder" align="right"><%=++iRowCount%>&nbsp;</td>
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder">&nbsp;<%=WebInterface.formatName((String)vRetResult.elementAt(i + 2),
	  (String)vRetResult.elementAt(i + 3),(String)vRetResult.elementAt(i + 4),4)%></td>     
      <%if(vRetResult.elementAt(i + 8) != null) {//outer loop.
	  		  if(vRetResult.elementAt(i + 9) != null) //inner loop.
						strTemp = (String)vRetResult.elementAt(i + 8) + "/ " + (String)vRetResult.elementAt(i + 9);
					else
						strTemp = (String)vRetResult.elementAt(i + 8);					
  		 	}else if(vRetResult.elementAt(i + 9) != null){//outer loop else
				 	strTemp = (String)vRetResult.elementAt(i + 9);
			  }%> 
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp, "&nbsp;")%></td>
	   <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i + 7)%></td>
	    <td align="right" class="thinborder">
			<%
				dTemp =  Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 13),"0"));
				if(dTemp > 0)
					strTemp = CommonUtil.formatFloat(dTemp,false );	
				else
					strTemp = "";	
			%>	
			<%=strTemp%> 
			&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 10), false);
				if(strTemp.equals("0"))
					strTemp = "";
					
				iDays = 0;
				iHours = 0;
				iMins = 0;
				
				iMins = (int)Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 10),"0"));					
				//iDays = iMins/480;
//				iMins = iMins%480;	
//				iHours  = iMins/60;
//				iMins = iMins%60;
//				
//				strTemp = "";
//				if(iDays > 0)
//					strTemp += " " + iDays + ((iDays == 1)? " day":" days");
//				if(iHours > 0)
//					strTemp += " " + iHours + ((iHours == 1)? " hour":" hours");
				if(iMins > 0){
					//strTemp +=  " " + iMins + ((iMins == 1)? " min":" mins");		
					strTemp = "" + iMins;
				}	
			%>	
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 11), false);
				if(strTemp.equals("0"))
					strTemp = "";
					
					iDays = 0;
				iHours = 0;
				iMins = 0;
				
				iMins = (int)Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 11),"0"));						
				iDays = iMins/480;
				iMins = iMins%480;	
				iHours  = iMins/60;
				iMins = iMins%60;
				
				strTemp = "";
				if(iDays > 0)
					strTemp +=  " " + iDays + ((iDays == 1)? " day":" days");
				if(iHours > 0)
					strTemp +=  " " + iHours + ((iHours == 1)? " hour":" hours");
				if(iMins > 0)
					strTemp +=  " " + iMins + ((iMins == 1)? " min":" mins");	
					
			%>	
     <!-- <td align="right" class="thinborder">
																				<%=WI.getStrValue(strTemp, "", " mins","")%>&nbsp;</td>-->
			<%
				strTemp = CommonUtil.formatFloat((String)vRetResult.elementAt(i + 12), false);
				if(strTemp.equals("0"))
					strTemp = "";
				iDays = 0;
				iHours = 0;
				iMins = 0;
				
				dTemp = Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 12),"0")) / 8;						
				dTemp = Double.parseDouble(CommonUtil.formatFloat(dTemp,false));
				strTemp = "";
				
				//iHours = (int)Double.parseDouble(WI.getStrValue((String)vRetResult.elementAt(i + 12),"0"));						
//				iDays = iHours/8;
//				iHours = iHours%8;					
//				
//				strTemp = "";
//				if(iDays > 0)
//					strTemp +=  " " + iDays + ((iDays == 1)? " day":" days");
//				if(iHours > 0)
//					strTemp +=  " " + iHours + ((iHours == 1)? " hour":" hours");
				if(dTemp > 0)
					strTemp = CommonUtil.formatFloat(dTemp,false);
						
			%>
      <td align="right" class="thinborder"><%=strTemp%>&nbsp;</td>
	  <td align="right" class="thinborder">&nbsp;</td>
    </tr>
    <%}//end of for loop to display employee information.%>
  </table>
  <table  bgcolor="#FFFFFF"width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="69%" height="25">&nbsp;</td>
      <td width="31%">&nbsp;</td>
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