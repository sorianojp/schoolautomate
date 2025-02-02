<%@page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil, 
																java.util.Calendar, java.util.Date, eDTR.ReportEDTRExtn" 
																buffer="16kb"%>
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
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
		font-size: 10px;  
    }
		
		TD.thinborderReg {
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
		font-size: 9px;  
    }

    TD.NoBorder {
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 9px;  
		}
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script> 
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
	int iCol = 0;
	int iSearchResult =0;
	int iIndex = 0;
	int iCount = 0;
	double dTemp = 0d;
	boolean bolShowUT = WI.fillTextValue("show_ut").length() > 0;
	boolean bolShowLate = WI.fillTextValue("show_late").length() > 0;
	boolean bolShowLwop = WI.fillTextValue("show_lwop").length() > 0;
	
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
								"Admin/staff-eDaily Time Record-View/Print DTR","attendance_summary_tsu.jsp");
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
														"attendance_summary_tsu.jsp");
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

//end of authenticaion code.
if(strErrMsg == null) strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};

	ReportEDTR RE = new ReportEDTR(request);
	ReportEDTRExtn rptExtn = new ReportEDTRExtn(request);
	Vector vDayInterval = null;
	Vector vAllLeaves = null;
	Vector vLeaveBenefits = null;
	int iVarCols = 0;
	
	String strDateFr = null;
	String strDateTo = null;
	int iIndexOf  = 0;
	String strLate = null;
	String strUt = null;
	int iWidth = 2;
	int iCounter = 1;
	int l = 0;
	long lTotalUt = 0l;
	long lTotalLate = 0l;	
	long lUndertime = 0l;
	long lLate = 0l;
	double[] adTotal = null;

	Vector vEmpLeavesWP = null; // leaves with pay
	Vector vEmpLeavesWoutP = null; // leaves without pay
	Vector vLeavePerDay = null;
	Integer iObjUserIndex = null;
	String strShowOpt = WI.getStrValue(WI.fillTextValue("DateDefaultSpecify"), "1");

String[] astrMonth={" &nbsp;", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};
vLeaveBenefits = rptExtn.getLeaveBenefits(dbOP);
	vRetResult = RE.searchEDTR(dbOP, true);
	if( WI.fillTextValue("DateDefaultSpecify").equals("2")) {
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

	vDayInterval = RE.getDayNDateDetail(strDateFr,strDateTo, true);		
	if (vDayInterval == null)
		strErrMsg = RE.getErrMsg();
	else{
		iWidth = 80/vDayInterval.size();
	}
	vAllLeaves = rptExtn.getEmployeeLeaveWithName(dbOP, strDateFr , strDateTo); 
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
	 iVarCols = 0;
%>
<body onLoad="javascript:window.print();">
<form name="dtr_op">
  <table width="100%" border="0" cellpadding="2" cellspacing="0"  bgcolor="#FFFFFF">
    <tr >
		<%
			if(strShowOpt.equals("2"))
				strTemp = "for the Month of " + astrMonth[Integer.parseInt(WI.fillTextValue("strMonth"))] + ", " + WI.fillTextValue("sy_") ;
			else
				strTemp = "for the Period " + WI.fillTextValue("from_date") + " to " + WI.fillTextValue("to_date");
		%>		
      <td height="25" colspan="2" align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
        ATTENDANCE SUMMARY <%=strTemp%></strong></td>
    </tr>
    <tr >
      <td height="25" colspan="2" align="center">&nbsp;</td>
    </tr>
	</table>	
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">		
    <tr >
      <td width="11%" height="25" rowspan="2" align="center" class="thinborder"><strong>Name</strong></td>
			<%
			if(bolShowUT)
				iVarCols++;
			
			if(bolShowLate)
				iVarCols++;
			
			if(bolShowLwop)
				iVarCols++;
			iCounter = 1;
			for(l = 0; l < vLeaveBenefits.size();l+=5, iCounter++){
				if(WI.fillTextValue("leave_type_"+iCounter).length() > 0)
					iVarCols++;
			}	
			for(int iDay = 0; iDay < vDayInterval.size(); iDay+=2){%>
			<%
			strTemp2 = (String)vDayInterval.elementAt(iDay);
			strTemp = strTemp2.substring(0,strTemp2.length() - 5);
			%>
      <td colspan="<%=iVarCols%>" align="center" class="thinborder"><%=strTemp%></td>						
			<%}%>
			<td colspan="<%=iVarCols%>" align="center" class="thinborder">TOTAL</td>		
		</tr>		
    <tr >      
		<%for(int iDay = 0; iDay < vDayInterval.size(); iDay+=2){
			iCounter = 1;
		%>		
			<%for(l = 0; l < vLeaveBenefits.size();l+=5, iCounter++){
				if(WI.fillTextValue("leave_type_"+iCounter).length() > 0){
					//strTemp = Integer.toString(iCounter);
					strTemp = WI.getStrValue((String)vLeaveBenefits.elementAt(l+2),Integer.toString(iCounter));
					if(strTemp.length() == 1){
						strTemp = "&nbsp;" + strTemp + "&nbsp;";
					}				
			%>
			<td align="center" class="thinborder"><%=strTemp%></td>      
			<%}
			}%>
			<%if(bolShowLwop){%>
			<td align="center" class="thinborder">NP</td>
			<%}%>
			<%if(bolShowUT){%>
      <td align="center" class="thinborder">UT</td>
			<%}%>
			<%if(bolShowLate){%>
      <td align="center" class="thinborder">&nbsp;T&nbsp;</td>			
			<%}%>
			<%}// END FOR vDayInterval.size() %>
			<%
			iCounter = 1;
			for(l = 0; l < vLeaveBenefits.size();l+=5, iCounter++){
				if(WI.fillTextValue("leave_type_"+iCounter).length() > 0){
					//strTemp = Integer.toString(iCounter);
					strTemp = WI.getStrValue((String)vLeaveBenefits.elementAt(l+2),Integer.toString(iCounter));
					if(strTemp.length() == 1){
						strTemp = "&nbsp;" + strTemp + "&nbsp;";
					}				
			%>
			<td width="7%" align="center" class="thinborder"><%=strTemp%></td>
			<%}
			}%>
			<%if(bolShowLwop){%>
			<td width="7%" align="center" class="thinborder">NP</td>
			<%}%>
			<%if(bolShowUT){%>
			<td width="7%" align="center" class="thinborder">UT</td>
			<%}%>
			<%if(bolShowLate){%>
			<td width="6%" align="center" class="thinborder">&nbsp;T&nbsp;</td>
			<%}%>
    </tr>    
	<%for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=7,++iIncr, ++iCount){
		i = iNumRec;
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;		
		adTotal = new double[(vLeaveBenefits.size()/5) + 3];
		//vEmpLeaves
		iObjUserIndex = new Integer((String)vRetResult.elementAt(i+6));
		if(vAllLeaves != null){
			vEmpLeavesWP = new Vector();
			vEmpLeavesWoutP = new Vector();
			vLeavePerDay = new Vector();
			iIndexOf = vAllLeaves.indexOf(iObjUserIndex);
 			while(iIndexOf != -1){
				if(((String)vAllLeaves.elementAt(iIndexOf+3)).equals("0")){
					vAllLeaves.remove(iIndexOf); // remove user index(Integer)
					vEmpLeavesWoutP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove date
					vEmpLeavesWoutP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove leave hours/days
					vEmpLeavesWoutP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove with[1]/ without pay[0]
					vEmpLeavesWoutP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove leave status[0-dwop, 1-hwop, 2- dwp, 3-hwp]
					vEmpLeavesWoutP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove leave sub type
					vEmpLeavesWoutP.addElement((Long)vAllLeaves.remove(iIndexOf)); // remove leave type index (Long)
				} else {
					vAllLeaves.remove(iIndexOf); // remove user index(Integer)
					vEmpLeavesWP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove date
					vEmpLeavesWP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove leave hours/days
					vEmpLeavesWP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove with[1]/ without pay[0]
					vEmpLeavesWP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove leave status[0-dwop, 1-hwop, 2- dwp, 3-hwp]
					vEmpLeavesWP.addElement((String)vAllLeaves.remove(iIndexOf)); // remove leave sub type
					vEmpLeavesWP.addElement((Long)vAllLeaves.remove(iIndexOf)); // remove leave type index (Long)
				}
					vAllLeaves.remove(iIndexOf);// free
					vAllLeaves.remove(iIndexOf);// free
					vAllLeaves.remove(iIndexOf);// free				
				iIndexOf = vAllLeaves.indexOf(iObjUserIndex);
			}
			
			//System.out.println("iObjUserIndex---- " + iObjUserIndex);
			//System.out.println("vEmpLeavesWP " + vEmpLeavesWP);
			//System.out.println("vEmpLeavesWoutP " + vEmpLeavesWoutP);
		}
		
		lLate = 0l;
		lUndertime = 0l;
		lTotalUt = 0l;
		lTotalLate = 0l;

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
		%>			
		<%
		if(vEmpLeavesWP != null){
			iIndexOf = vEmpLeavesWP.indexOf((String)vDayInterval.elementAt(iDay));
			while(iIndexOf != -1){
				vEmpLeavesWP.remove(iIndexOf); // remove date						
				vLeavePerDay.addElement((String)vEmpLeavesWP.remove(iIndexOf)); // remove leave hours/days
				vLeavePerDay.addElement((String)vEmpLeavesWP.remove(iIndexOf)); // remove with[1]/ without pay[0]
				vLeavePerDay.addElement((String)vEmpLeavesWP.remove(iIndexOf)); // remove leave status
				vLeavePerDay.addElement((String)vEmpLeavesWP.remove(iIndexOf)); // remove leave sub type
				vLeavePerDay.addElement((Long)vEmpLeavesWP.remove(iIndexOf)); // remove leave type index
				iIndexOf = vEmpLeavesWP.indexOf((String)vDayInterval.elementAt(iDay));
			}// end while
		}
		iCounter = 1;
		for(l = 0; l < vLeaveBenefits.size();l+=5,iCounter++){
			strTemp = "";
			if(WI.fillTextValue("leave_type_"+iCounter).length() > 0){
			//iIndexOf = vEmpLeavesWP.indexOf((String)vDayInterval.elementAt(iDay));
				if(vLeavePerDay != null){
					iIndexOf = vLeavePerDay.indexOf((Long)vLeaveBenefits.elementAt(l));
					while(iIndexOf != -1){
						iIndexOf = iIndexOf - 4;
						strTemp = (String)vLeavePerDay.remove(iIndexOf); // remove leave hours/days
						vLeavePerDay.remove(iIndexOf); // remove with[1]/ without pay[0]
						vLeavePerDay.remove(iIndexOf); // remove leave status
						vLeavePerDay.remove(iIndexOf); // remove leave sub type
						vLeavePerDay.remove(iIndexOf); // remove leave type index
						iIndexOf = vLeavePerDay.indexOf((Long)vLeaveBenefits.elementAt(l));
					}// end while
				}
				strTemp2 = CommonUtil.formatFloat(strTemp, true);
				strTemp2 = ConversionTable.replaceString(strTemp2, ",","");
				adTotal[iCounter-1] += Double.parseDouble(strTemp2);
			%>
		<td align="right" class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<%}
		}%>			
		
		<%
			if(bolShowLwop){
				strTemp = "";
				if(vEmpLeavesWoutP != null){
					iIndexOf = vEmpLeavesWoutP.indexOf((String)vDayInterval.elementAt(iDay));
					while(iIndexOf != -1){
						vEmpLeavesWoutP.remove(iIndexOf); // remove date						
						strTemp = (String)vEmpLeavesWoutP.remove(iIndexOf); // remove leave hours/days
						vEmpLeavesWoutP.remove(iIndexOf); // remove with[1]/ without pay[0]
						vEmpLeavesWoutP.remove(iIndexOf); // remove leave status
						vEmpLeavesWoutP.remove(iIndexOf); // remove leave sub type
						vEmpLeavesWoutP.remove(iIndexOf); // remove leave type index
						iIndexOf = vEmpLeavesWoutP.indexOf((String)vDayInterval.elementAt(iDay));
					}// end while
				}
				strTemp2 = CommonUtil.formatFloat(strTemp, false);
				strTemp2 = ConversionTable.replaceString(strTemp2, ",","");
				dTemp = Double.parseDouble(strTemp2);
				adTotal[iCounter-1] += dTemp;

				if(dTemp == 0d)
					strTemp2 = "";
			%>		
			<td align="right" class="thinborder"><%=WI.getStrValue(strTemp2,"&nbsp;")%></td>
			<%}// end if bolShowLwop%>

			<%			
				strAM = "";
				strPM = "";
				lLate = 0l;
				lUndertime = 0l;					
			strLate = "";
			strUt = "";
			if(vRetEDTR != null){			
				if (vRetEDTR.size() == 1){//non DTR employees
					strTemp = (String) vRetEDTR.elementAt(0);
				}else{
					iIndexOf = 0;
					while(iIndexOf != -1){
						iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
						if(iIndexOf != -1){
							vRetEDTR.remove(iIndexOf); // remove timein_date
							vRetEDTR.remove(iIndexOf); // remove timeout_date
							
							strLate = (String)vRetEDTR.remove(iIndexOf); // remove late_time_in
							if(bolShowLate)
								lLate += Long.parseLong(WI.getStrValue(strLate,"0"));
 							
							if(lLate == 0)
								strLate = "&nbsp;";
							else
								strLate = Long.toString(lLate);
							
							strUt = (String)vRetEDTR.remove(iIndexOf); // remove under_time

							if(bolShowUT)
								lUndertime += Long.parseLong(WI.getStrValue(strUt,"0"));

							if(lUndertime == 0)
								strUt = "&nbsp;";
							else
								strUt = Long.toString(lUndertime);
							
							vRetEDTR.remove(iIndexOf); // remove '**' indicator
							strAMPMSet = (String)vRetEDTR.remove(iIndexOf); // remove am_pm_set
							strAMPMSet = WI.getStrValue(strAMPMSet);
							
					
							vRetEDTR.remove(iIndexOf - 1); // remove timeout	
							vRetEDTR.remove(iIndexOf - 2); // remove timein							
							vRetEDTR.remove(iIndexOf - 3); // remove user_index
							vRetEDTR.remove(iIndexOf - 4); // remove wh_index
						}
						
						//iIndexOf = vRetEDTR.indexOf((String)vDayInterval.elementAt(iDay));
					}
					
					lTotalUt +=lUndertime;
					lTotalLate += lLate;					
				}// end else
			}			
				adTotal[iCounter] += (double)lUndertime;				
				adTotal[iCounter+1] += (double)lLate;
			%>
			<%if(bolShowUT){%>
      <td height="21" align="right" class="thinborder"><%=WI.getStrValue(strUt,"&nbsp;")%></td>	
			<%}// end bolShowUT%>		
			<%if(bolShowLate){%>
			<td align="right" class="thinborder"><%=WI.getStrValue(strLate,"&nbsp;")%></td>						
			<%}%>
			<%}// end inner for loop%>
			
			<%
			iCounter = 1;
			for(l = 0; l < vLeaveBenefits.size();l+=5, iCounter++){
				if(WI.fillTextValue("leave_type_"+iCounter).length() > 0){
			%>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat(adTotal[iCounter-1], false)%></td>
			<%}
			}%>
 			<%if(bolShowLwop){%>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat(adTotal[iCounter-1], false)%></td>
			<%}%>
			<%if(bolShowUT){%>
			<td align="right" class="thinborder"><%=CommonUtil.formatFloat(adTotal[iCounter], false)%></td>
			<%}%>
			<%if(bolShowLate){%>
      <td align="right" class="thinborder"><%=CommonUtil.formatFloat(adTotal[iCounter+1], false)%></td>
			<%}%>
    </tr>
		<%}// end employee for loop%>
  </table>
  <%if (bolPageBreak){%>
<DIV style="page-break-before:always">&nbsp;</Div>
<%}//page break ony if it is not last page.
	} //end for (iNumRec < vRetResult.size()%>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>&nbsp;</td>
  </tr>
</table>

<%if(vLeaveBenefits != null && vLeaveBenefits.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">
		<%
		iCounter = 1;
		for(l = 0; l < vLeaveBenefits.size();){
			iCol = 0;
		%>
		<tr>
			<%
			for(; l < vLeaveBenefits.size() && iCol < 4;l+=5, iCol++, iCounter++){
			%>
			<td class="thinborder">
			<strong><%=iCounter%></strong> - <%=(String)vLeaveBenefits.elementAt(l+1)%> <%=WI.getStrValue((String)vLeaveBenefits.elementAt(l+2), "(",")","")%></td>
			<%}%>			
			<%while(iCol < 4){
				iCol ++;
			%>
			<td class="thinborder">&nbsp;</td>
			<%}%>
		</tr>
		<%}%>
</table>
<%}%>
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
