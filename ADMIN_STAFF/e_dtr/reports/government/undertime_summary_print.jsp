<%@page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil, 
																java.util.Calendar, java.util.Date" buffer="16kb"%>
<%
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if (strSchCode == null)
	strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
	.bgDynamic {
		background-color:<%=strColorScheme[1]%>
	}
	.footerDynamic {
		background-color:<%=strColorScheme[2]%>
	}

    table.thinborder {
    border-top: solid 1px #000000;
		border-right: solid 1px #000000;
    }
    TD.thinborder {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
    }
		
		TD.BottomLeftRight {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
    }

    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
		}
</style>
</head>
 <script language="JavaScript" src="../../../../jscript/common.js"></script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
  Vector vRetEDTR = new Vector();
	Calendar calTemp = Calendar.getInstance();
	String strTemp2 = null;
	String strTemp3 = null;
	int iSearchResult =0;
	int iIndex = 0;
	int iCount = 0;
	boolean bolUndertime = WI.fillTextValue("for_undertime").equals("1");
	String strAMPMSet = "";
	String strAM = null;
	String strPM = null;
	String strMonths = WI.fillTextValue("strMonth");
 	String strYear = WI.fillTextValue("sy_");
	if(strMonths.length() == 0)
		strMonths = Integer.toString(calTemp.get(Calendar.MONTH) + 1);
	if(strYear.length() == 0)
		strYear = Integer.toString(calTemp.get(Calendar.YEAR));

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Print DTR","undertime_summary.jsp");
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
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(),
														"undertime_summary.jsp");
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

//end of authenticaion code.
if(strErrMsg == null) strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};

ReportEDTR RE = new ReportEDTR(request);
Vector vDayInterval = null;

String strDateFr = null;
String strDateTo = null;
int iIndexOf  = 0;
String strLate = null;
String strUt = null;
int iWidth = 2;
int iCounter = 0;
String strShowOpt = WI.getStrValue(WI.fillTextValue("DateDefaultSpecify"), "1");

	//	long lSubTotalWorkingHr = 0l;//sub total total working hour of employee.
	long lTotalLateUt = 0l;
	long lLateUt = 0l;
	long lLateUtAM = 0l;
	long lLateUtPM = 0l;

	String[] astrMonth={" &nbsp;", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};

 	vRetResult = RE.searchEDTR(dbOP, true);

	if (vRetResult == null)
		strErrMsg = RE.getErrMsg();

//added by biswa to get from and to date.
	if(strShowOpt.equals("2")) {
		try{			
				if (strYear.length()> 0){
					if (Integer.parseInt(strYear) >= 2005)
						calTemp.set(Calendar.YEAR, Integer.parseInt(strYear));
				else
					strErrMsg = " Invalid year entry";
	
				}else{
					strYear = Integer.toString(calTemp.get(Calendar.YEAR));
				}
			}
			catch (NumberFormatException nfe){
			strErrMsg = " Invalid year entry";
			}
	
			calTemp.set(Calendar.DAY_OF_MONTH,1);
	
			 if(!strMonths.equals("0") && strMonths.length() > 0){
					calTemp.set(Calendar.MONTH,Integer.parseInt(strMonths)-1);
			 }else{
					strMonths = Integer.toString(calTemp.get(Calendar.MONTH) + 1);
			 }

				strDateFr = strMonths + "/01/" + calTemp.get(Calendar.YEAR);
				strDateTo = strMonths + "/" + Integer.toString(calTemp.getActualMaximum(Calendar.DAY_OF_MONTH))
						+ "/" + calTemp.get(Calendar.YEAR); 
	} else {
		strDateFr = WI.fillTextValue("from_date");
		strDateTo = WI.fillTextValue("to_date");
	}
 		vDayInterval = RE.getDayNDateDetail(strDateFr, strDateTo, true);		
 		if (vDayInterval == null)
			strErrMsg = RE.getErrMsg();
		else{
			iWidth = 80/vDayInterval.size();
		}

	int i = 0;
	boolean bolPageBreak = false;
	if (vRetResult != null && vDayInterval != null) {
	int iPage = 1; 
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size())/(7*iMaxRecPerPage);	
	if((vRetResult.size() % (7*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
%>
<body onLoad="javascript:window.print();">
<form name="dtr_op">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <%
		strTemp = "";
		strTemp2 = "";
		if(strShowOpt.equals("2"))
			strTemp = "MONTHLY ";
		
		strTemp += "SUMMARY REPORT OF ";
		
		if(bolIsSchool)
			strTemp += " FACULTY'S ";		
		else
			strTemp += " EMPLOYEE'S ";		
		
		if(bolUndertime)
			strTemp += " UNDERTIME";
		else
			strTemp += " TARDINESS";		
	%>
	<tr>
    <td colspan="2" align="center"><strong><%=strTemp%></strong></td>
  </tr>
	<%
		if(strShowOpt.equals("2"))
			strTemp = "for the Month of " + astrMonth[Integer.parseInt(WI.fillTextValue("strMonth"))] + ", " + WI.fillTextValue("sy_") ;
		else
			strTemp = "for the Period " + WI.fillTextValue("from_date") + " to " + WI.fillTextValue("to_date");
	%>
  <tr>
    <td colspan="2" align="center"><em><%=strTemp%></em></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td width="85%">AGENCY : <strong><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong></td>
    <td width="15%" align="right">Page <%=iPage%> of <%=iTotalPages%></td>
  </tr>
</table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">		
    <tr >
      <td width="12%" rowspan="2" align="center" class="thinborder"><strong>Name of Personnel </strong></td>
			<%if(bolUndertime)
					strTemp = "UNDERTIME - A.M./P.M. (Number of Minutes)";
				else
					strTemp = "TARDINESS - A.M./P.M. (Number of Minutes)";			
			%>
      <td height="25" colspan="<%=vDayInterval.size()%>" align="center" class="thinborder" ><strong><%=strTemp%></strong></td>
			<%
				if(bolUndertime){
					strTemp = "Total No. of Undertime Incurred (minutes)";
					strTemp2 = "No. of Times Undertime";
				}else{
					strTemp = "Total No. of Tardiness Incurred (minutes)";
					strTemp2 = "No. of Times Tardy";
				}
			%>
      <td width="5%" rowspan="2" align="center" class="thinborder"><%=strTemp%></td>
      <td width="3%" rowspan="2" align="center" class="thinborder"><%=strTemp2%></td>
    </tr>
    <tr >
      <%for(int iDay = 0; iDay < vDayInterval.size(); iDay+=2){%>
			<%
			strTemp2 = (String)vDayInterval.elementAt(iDay);
			strTemp = strTemp2.substring(0, strTemp2.length() - 5);
			%>
      <td height="25" colspan="2" align="center" class="thinborder"><%=strTemp%></td>			
			<%}%>
		</tr>    
<%
//as requestd, i have to show all the days worked and non worked.
		for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=7,++iIncr, ++iCount){
			lLateUt = 0l;
			lTotalLateUt = 0l;
			iCounter = 0;
	
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;		
			
	  strTemp = (String)vRetResult.elementAt(i+3);

	if(strTemp == null)
		strTemp = (String)vRetResult.elementAt(i+4);
	else if(vRetResult.elementAt(i+4) != null)
		strTemp += "/"+(String)vRetResult.elementAt(i+4);

	vRetEDTR = RE.getDTRDetails(dbOP, (String)vRetResult.elementAt(i), true, true);
%>
		
    <tr>
      <td height="21" nowrap class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+1), "", 
												 (String)vRetResult.elementAt(i+2),4).toUpperCase()%></td>
		<%
		 for(int iDay = 0; iDay < vDayInterval.size(); iDay+=2){
		 //System.out.println("---------- " + vDayInterval.elementAt(iDay));
			strTemp = "";
			strTemp2 = "";
			
			if(vRetEDTR != null){			
				if (vRetEDTR.size() == 1){//non DTR employees
					strTemp = (String) vRetEDTR.elementAt(0);
				}else{ 
					
					iIndexOf = 0;
					strAM = "";
					strPM = "";
					lLateUtAM = 0l;
					lLateUtPM = 0l;
					
					while(iIndexOf != -1){
						iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
						if(iIndexOf != -1){
							vRetEDTR.remove(iIndexOf); // remove timein_date
							vRetEDTR.remove(iIndexOf); // remove timeout_date
							
							strLate = (String)vRetEDTR.remove(iIndexOf); // remove late_time_in
							if(!bolUndertime)
								lLateUt = Long.parseLong(WI.getStrValue(strLate,"0"));
							
							strUt = (String)vRetEDTR.remove(iIndexOf); // remove under_time

							if(bolUndertime)
								lLateUt = Long.parseLong(WI.getStrValue(strUt,"0"));

							if(lLateUt > 0)
								iCounter++;
							
							lTotalLateUt += lLateUt;
							vRetEDTR.remove(iIndexOf); // remove '**' indicator
							strAMPMSet = (String)vRetEDTR.remove(iIndexOf); // remove am_pm_set
							strAMPMSet = WI.getStrValue(strAMPMSet);
							
							if(strAMPMSet.equals("0"))
								lLateUtAM += lLateUt;
							else if(strAMPMSet.equals("1"))
								lLateUtPM += lLateUt;
						
							vRetEDTR.remove(iIndexOf - 1); // remove timeout	
							vRetEDTR.remove(iIndexOf - 2); // remove timein							
							vRetEDTR.remove(iIndexOf - 3); // remove user_index
							vRetEDTR.remove(iIndexOf - 4); // remove wh_index
						}
						
						//iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
					}		
				}
			}
			
		%>			
			<%
				if(lLateUtAM > 0)
					strTemp = Long.toString(lLateUtAM);						
				else
					strTemp = "&nbsp;";
			%>		
      <td height="21" align="right" class="thinborder" width="<%=iWidth%>%"><%=strTemp%></td>			
			<%
			if(lLateUtPM > 0)
				strTemp = Long.toString(lLateUtPM);						
			else
				strTemp = "&nbsp;";          
			%>
			<td align="right" class="thinborder" width="<%=iWidth%>%"><%=strTemp%></td>
			<%}// end for loop%>
      <td align="right" class="thinborder"><%=lTotalLateUt%></td>
      <td align="right" class="thinborder"><%=iCounter%></td>
    </tr>
		<%}%>
  </table>
	
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always">&nbsp;</Div>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="20%" align="right">&nbsp;</td>
    <td width="20%">&nbsp;</td>
    <td width="20%" align="right">&nbsp;</td>
    <td width="20%">&nbsp;</td>
    <td width="20%">&nbsp;</td>
  </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td>&nbsp;</td>
    <td align="right">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td align="right">Prepared by: </td>
    <td>&nbsp;</td>
    <td align="right">Approved by : </td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td align="center"><strong><%=WI.fillTextValue("prepared_by").toUpperCase()%></strong></td>
    <td>&nbsp;</td>
    <td align="center"><strong><%=WI.fillTextValue("approved_by").toUpperCase()%></strong></td>
    <td>&nbsp;</td>
  </tr>
  
  <tr>
    <td align="right">&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
    <td>&nbsp;</td>
  </tr>
</table>
	
<%} //end end upper most if (vRetResult !=null)%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
