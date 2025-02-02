<%@page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTRExtn, eDTR.eDTRUtil, 
																java.util.Calendar, java.util.Date, eDTR.ReportEDTR" buffer="16kb"%>
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
		font-size: 12px;  
    }
		
		TD.BottomLeftRight {
    border-bottom: solid 1px #000000;
		border-left: solid 1px #000000;
		border-right: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;  
    }

    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;  
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
	Calendar calTemp = Calendar.getInstance();
	String strTemp2 = null;
	String strDayCount = null;
	int iSearchResult =0;
	int iIndex = 0;
	int iCount = 1;
	String strMonths = WI.fillTextValue("month_of");
 	String strYear = WI.fillTextValue("year_of");
	if(strMonths.length() == 0)
		strMonths = Integer.toString(calTemp.get(Calendar.MONTH) + 1);
	if(strYear.length() == 0)
		strYear = Integer.toString(calTemp.get(Calendar.YEAR));

	//add security herptExtn.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Print DTR","faculty_undertime_summary.jsp");
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
														"faculty_undertime_summary.jsp");
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
ReportEDTRExtn rptExtn = new ReportEDTRExtn(request);
ReportEDTR RE = new ReportEDTR(request);
if(strErrMsg == null) 
	strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};
String strShowOpt = WI.getStrValue(WI.fillTextValue("DateDefaultSpecify"), "1");
String[] astrMonth={" &nbsp;", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};

String strDateFr = null;
String strDateTo = null;
String strAMPM = null;
String strPrevAMPM = null;

Vector vAWOLDates = null;
Vector vEmpAWOL = null;
Integer iUserIndex = null;
Vector vNoWork = null;
Vector vEmpNoWork = null;
Date odTemp = null;
Date odPrevDate = null;
double dDaysAbsent = 0d;
int iTimesAbsent = 0;
String strCheckDate = null;
String strPrevDate = null;

String strToPrint = null;
boolean bolContinuous = false;
boolean bolEnd = false;

String strPrevRestDay = null;
int iIndexOfAwol = 0;
Vector vFinalList = new Vector();

int iIndexOf = 0;
	int i = 0;
	int j = 0;
	double dTempCounter = 0d;
	int k = 0;
	String strNoWorkDate = null;
	int iDateCompare = 0;
	String strNextDate = null;
	String strExpNextDate = null;
	boolean bolOkHalfDay = false;

//for(int j = 0; j < 15; j++)
//	System.out.println(WI.formatDate(WI.getTodaysDate(1),j));
 	vRetResult = RE.searchEDTR(dbOP, true);
	vAWOLDates = rptExtn.getEmployeeAbsences(dbOP);
	vNoWork = rptExtn.getDaysEmployeeNoWork(dbOP);
	boolean bolPageBreak = false;
	if (vRetResult != null) {
	int iPage = 1; 
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size())/(7*iMaxRecPerPage);	
	if((vRetResult.size() % (7*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){

%>
<body onLoad="javascript:window.print();">
<form method="post">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="header_">
     <tr>
		 	<%
			if (WI.fillTextValue("DateDefaultSpecify").equals("2")){
				strTemp = "MONTHLY";
				strTemp2 = "For the Month of " + astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))] + " " + WI.fillTextValue("year_of") ;
			} else {
				strTemp = "";
				strTemp2 = "For the Period " + WI.fillTextValue("from_date") + " to " + WI.fillTextValue("to_date");
			}
			%>
      <td height="18" colspan="2" align="center"><strong><%=strTemp%> SUMMARY REPORT OF FACULTY'S HALF-DAY UNDERTIME</strong></td>
    </tr>
     <tr>
       <td height="20" colspan="2" align="center"><%=strTemp2%></td>
     </tr>
     <tr>
       <td height="20" align="center">&nbsp;</td>
       <td align="center">&nbsp;</td>
     </tr>
     <tr>
       <td width="80%" height="25">AGENCY : <em><strong><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong></em></td>
       <td width="20%" align="center">Page <%=iPage%> of <%=iTotalPages%></td>
     </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">		
    <tr >
      <td height="25" colspan="2" align="center" class="thinborder">EMPLOYEES' NAME</td>
      <td align="center" class="thinborder" width="52%">Date When Half-Day Undertime was Incurred</td>			
			<td width="11%" align="center" class="thinborder">Total No. of Days Absent</td>
			<td width="12%" align="center" class="thinborder"><font size="1"> Total No. of Times Half-Day Undertime </font></td>
    </tr>    
<%
 	for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=7,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;				
	
 		iUserIndex = new Integer((String)vRetResult.elementAt(i+6));
		// System.out.println("iUserIndex " + iUserIndex);
		if(vAWOLDates != null){
			iIndexOf = vAWOLDates.indexOf(iUserIndex);
			if(iIndexOf != -1){
				vAWOLDates.remove(iIndexOf);
				vEmpAWOL = (Vector)vAWOLDates.remove(iIndexOf);			
			}else
				vEmpAWOL = null;			
		}else
			vEmpAWOL = null;
		
		if(vNoWork != null){
			//System.out.println("vNoWork " + vNoWork);
			iIndexOf = vNoWork.indexOf(iUserIndex);
			if(iIndexOf != -1){
				vNoWork.remove(iIndexOf);
				vEmpNoWork = (Vector)vNoWork.remove(iIndexOf);			
			}else
				vEmpNoWork = null;			
		}else
			vEmpNoWork = null;
		
		
		if(vEmpAWOL != null || vEmpNoWork != null){
			//vFinalList
			
			if(vEmpNoWork != null){
				for(j = 0; j < vEmpNoWork.size(); j++){
					strTemp = (String)vEmpNoWork.elementAt(j);
					if(vEmpAWOL != null){
						iIndexOf = vEmpAWOL.indexOf(strTemp);
						if(iIndexOf != -1){
							vEmpAWOL.remove(iIndexOf);
							vEmpAWOL.remove(iIndexOf);
						}
					}
				}				
			}			
		}

		// System.out.println("vEmpAWOL " + vEmpAWOL);
		// System.out.println("vEmpNoWork " + vEmpNoWork);
		
  strTemp = (String)vRetResult.elementAt(i+3);

	if(strTemp == null)
		strTemp = (String)vRetResult.elementAt(i+4);
	else if(vRetResult.elementAt(i+4) != null)
		strTemp += "/"+(String)vRetResult.elementAt(i+4);
%>
    <tr>
      <td width="3%" height="19" align="right" nowrap class="thinborder"><%=iIncr%>&nbsp;</td>
			<td width="21%" nowrap class="thinborder"><%=WI.formatName((String)vRetResult.elementAt(i+1), "", 
												 (String)vRetResult.elementAt(i+2),4).toUpperCase()%></td>
			<%
				//strTemp = CommonUtil.convertVectorToCSV(vEmpAWOL);
				/*
					March 24, 2010
					Warning... codes below were written when i was in a double depression and stupid mode.
					FYI: Stupid mode is the opposite of my autoprogram mode.
					so if naay error, dont be surprised... be more surprised kung walay error
					
					April 5, 2010
					back from vacation, my mind has somewhat cleared a little bit, so i was able to fix
					the problems previously encountered..
				*/
				strTemp = "";
 				dDaysAbsent = 0d;
				iTimesAbsent = 0;
				//System.out.println("---------------------------");
				//System.out.println("vEmpNoWork " + vEmpNoWork);
				//System.out.println("vEmpAWOL " + vEmpAWOL);
				strPrevDate = "";
				strPrevAMPM = "";
				if(vEmpAWOL != null && vEmpAWOL.size() > 0){
					for(j = 0; j < vEmpAWOL.size(); j+=2){
						bolOkHalfDay = false;
						strToPrint = (String)vEmpAWOL.elementAt(j);
						//System.out.println("strToPrint " + strToPrint + " +----------------------+ ");
						strDayCount = (String)vEmpAWOL.elementAt(j+1);
						strAMPM = "";
						bolContinuous = false;
						odTemp = ConversionTable.convertMMDDYYYYToDate(strToPrint);

						calTemp.setTime(odTemp);
						calTemp.add(Calendar.DAY_OF_YEAR, -1);

						strCheckDate = ConversionTable.convertMMDDYYYY(calTemp.getTime());

						//System.out.println("strToPrint " + strToPrint);
						//System.out.println("strPrevDate " + strPrevDate);
						//System.out.println("strCheckDate " + strCheckDate);
						if(!strDayCount.equals("2")){
							if(strDayCount.equals("0"))
								strAMPM = "am";
							else
								strAMPM = "pm";
						}
					
						if(strPrevDate.equals(strCheckDate)){
							if(j > 0){
								if(strPrevAMPM.equals("pm") || strPrevAMPM.length() == 0){
									if(strDayCount.equals("2") || (strDayCount.equals("0")))
										bolOkHalfDay = true;
								}
							}
							
							bolContinuous = true;
							bolEnd = false;
						}else {
							
							if(vEmpNoWork != null){
								//System.out.println("strCheckDate " + strCheckDate);
								while(vEmpNoWork.size() > 0){
									strNoWorkDate = (String)vEmpNoWork.elementAt(0);
									// if (strNoWorkDate > strCheckDate) == 1
									// if (strNoWorkDate = strCheckDate) == 0
									// if (strNoWorkDate < strCheckDate) == -1
									iDateCompare = ConversionTable.compareDate(strNoWorkDate, strCheckDate);
									if(iDateCompare == -1)
										vEmpNoWork.remove(0);
									else
										break;
								}
								
								iIndexOf = vEmpNoWork.indexOf(strCheckDate);
								if(iIndexOf != -1 && strPrevDate.length() > 0){
									vEmpNoWork.remove(iIndexOf);
									// System.out.println("iIndexOf " + iIndexOf);
									if(iIndexOf == 0)
										bolContinuous = true;
 								}
							} else
								bolContinuous = false;
						}
						
						if(strPrevAMPM.equals("am"))
							bolContinuous = false;
						
						if(strDayCount.equals("1")){
							if(j + 2 < vEmpAWOL.size()){
								strNextDate = (String)vEmpAWOL.elementAt(j+2);
								 
								calTemp.setTime(odTemp);
								calTemp.add(Calendar.DAY_OF_YEAR, 1);
								strExpNextDate = ConversionTable.convertMMDDYYYY(calTemp.getTime());
								iDateCompare = ConversionTable.compareDate(strExpNextDate, strNextDate);
								if(iDateCompare == 0 && !((String)vEmpAWOL.elementAt(j+3)).equals("1")){
									bolOkHalfDay = true;
								}
							}
						}
						
						if(strDayCount.equals("2"))
							dTempCounter++;
 						else
							dTempCounter += 0.5d;
						
						strPrevDate = ConversionTable.convertMMDDYYYY(odTemp);
						if(strDayCount.equals("0"))
							strPrevAMPM = "am";
						else if(strDayCount.equals("1"))
							strPrevAMPM = "pm";
						else
							strPrevAMPM = "";

						odPrevDate = odTemp;
						
						if(strDayCount.equals("2") || bolOkHalfDay || bolContinuous)
							continue;

						//System.out.println("strDayCount " + strDayCount);
 						if(strTemp.length() == 0){
 							strTemp = WI.formatDate(strToPrint, 9);							
							strTemp += strAMPM;
							//System.out.println("strTemp------- " + strTemp);	
						} else {
							if(!bolContinuous){
								strTemp += ", " + WI.formatDate(strToPrint, 9) + strAMPM;
 								dTempCounter = 0d;// reset absences counter
 							}
						}

						dDaysAbsent += 0.5d;
						
						if(!bolContinuous)
							iTimesAbsent++;
					}
				}
			%>
      <td height="19" class="thinborder" >&nbsp;<%=strTemp%></td>
			<td align="center" class="thinborder"><%=Double.toString(dDaysAbsent)%></td>
			<td align="center" class="thinborder"><%=iTimesAbsent%></td>
    </tr>
		<%}%>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always">&nbsp;</Div>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()%>
	
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td width="19%" align="right">&nbsp;</td>
    <td width="27%">&nbsp;</td>
    <td width="17%" align="right">&nbsp;</td>
    <td width="24%">&nbsp;</td>
    <td width="13%">&nbsp;</td>
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
    <td align="center" class="thinborderBottom"><strong><%=WI.fillTextValue("prepared_by").toUpperCase()%></strong></td>
    <td>&nbsp;</td>
    <td align="center" class="thinborderBottom"><strong><%=WI.fillTextValue("approved_by").toUpperCase()%></strong></td>
    <td>&nbsp;</td>
  </tr>
  <tr>
    <td align="right">&nbsp;</td>
    <td align="center" nowrap><%=WI.fillTextValue("title_1")%></td>
    <td>&nbsp;</td>
    <td align="center"><%=WI.fillTextValue("title_2")%></td>
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