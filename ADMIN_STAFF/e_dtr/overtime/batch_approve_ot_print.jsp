<%@ page language="java" import="utility.*,java.util.Vector,eDTR.OverTime, eDTR.ReportEDTR, eDTR.eDTRUtil" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Validate / Approved Overtime</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 10px;
    }

</style>
</head>
<body onLoad="javascript:window.print();">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	int i = 3;
	
	boolean bolMyHome = WI.fillTextValue("my_home").equals("1");
	boolean bolIsSchool = false;
	if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
		bolIsSchool = true;
	boolean bolHasOTBreak = false;
//add security here.
	try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-OVERTIME MANAGEMENT-Approve Overtime(Batch)","batch_approve_ot.jsp");
		
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasOTBreak = (readPropFile.getImageFileExtn("HAS_OT_BREAK","0")).equals("1");
		
	}	catch(Exception exp){
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
														"eDaily Time Record","OVERTIME MANAGEMENT",request.getRemoteAddr(), 
														"batch_approve_ot.jsp");
if(iAccessLevel == 0){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","OVERTIME MANAGEMENT-Approve Overtime",request.getRemoteAddr(), 
														"batch_approve_ot.jsp");	
}														
// added for CLDHEI.. 
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome)
		iAccessLevel = 2;
}

if (strTemp == null) 
	strTemp = "";

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
	Vector vRetResult = null;
	ReportEDTR RE = new ReportEDTR(request); 
	boolean bolPageBreak = false;
		String strAMPM = " AM";
	int iHour = 0;
	int iMinute = 0;
	double dTime = 0d;
	vRetResult = RE.searchOvertime(dbOP, true);
	if (vRetResult != null) {	
		int j = 0; int iCount = 0;
		int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));
		int iNumRec = 0;//System.out.println(vRetResult);
		int iIncr    = 1;
		int iPage = 1;
		int iTotalPages = vRetResult.size()/(45*iMaxRecPerPage);	
		if(vRetResult.size() % (45*iMaxRecPerPage) > 0) 
			++iTotalPages;

		for (;iNumRec < vRetResult.size();iPage++){
%>
<form name="dtr_op">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
	<tr>
	  <td align="center"><strong><font size="2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
	  Overtime Requests </font></strong></td>
	  </tr>
	<tr>
		<td align="right">Page <%=iPage%> of <%=iTotalPages%></td>
	</tr>
</table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" class="thinborder" bgcolor="#FFFFFF">
	<tr>
		<td width="17%" align="center" class="thinborder"><strong><font size="1">Requested 
			by </font></strong></td>
		<td width="17%" align="center" class="thinborder"><font size="1"><strong>Requested 
			For</strong></font></td>
		<td width="17%" align="center" class="thinborder"><font size="1"><strong>OT 
			Date/Time</strong></font></td>
		<%if(bolHasOTBreak){%>
		<td width="16%" align="center" class="thinborder"><font size="1"><strong>Break</strong></font></td>
		<%}%>
		<td width="6%" align="center" class="thinborder"><font size="1"><strong>No. 
		of Hours</strong></font></td>
		<td width="18%" align="center" class="thinborder"><font size="1"><strong>Reason</strong></font></td>
		<td width="9%" align="center" class="thinborder"><font size="1"><strong>Status</strong></font></td>
	</tr>
	<tr>
<%
for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=45,++iIncr, ++iCount){
	i = iNumRec;
	if (iCount > iMaxRecPerPage){
		bolPageBreak = true;
		break;
	} else 
		bolPageBreak = false;			
	strTemp2 = WI.formatName((String)vRetResult.elementAt(i+15), 
						(String)vRetResult.elementAt(i+16), (String)vRetResult.elementAt(i+17), 4);
	strTemp = (String)vRetResult.elementAt(i);
	strTemp = WI.getStrValue(strTemp);
 %>
		<td class="thinborder">&nbsp;<%=WI.getStrValue(strTemp2, "", "(" + strTemp + ")","")%></td>
		<% if (strTemp.equals((String)vRetResult.elementAt(i+1)))
				strTemp = "&nbsp;";
			else{
				strTemp = WI.formatName((String)vRetResult.elementAt(i+18), 
									(String)vRetResult.elementAt(i+19), (String)vRetResult.elementAt(i+20), 4);
				strTemp += "(" + (String)vRetResult.elementAt(i+1) + ")";
			}
		%>
		<td class="thinborder">&nbsp;<%=strTemp%></td>
		<% 
			strTemp = eDTRUtil.formatWeekDay((String)vRetResult.elementAt(i+6));
			if (strTemp  == null || strTemp.length() < 1){
				strTemp = (String)vRetResult.elementAt(i+4);
			}else{
			strTemp = " every " + strTemp + "<br>(" + (String)vRetResult.elementAt(i+4) + 
					" - " +	(String)vRetResult.elementAt(i+5) + ")";
		}
	%>
		<td class="thinborder"><%=strTemp%><br>
		  <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+7),
																 (String)vRetResult.elementAt(i+8),
									 (String)vRetResult.elementAt(i+9))%> - 
      <%=eDTRUtil.formatTime((String)vRetResult.elementAt(i+10),
								 (String)vRetResult.elementAt(i+11),
							 (String)vRetResult.elementAt(i+12))%></td>
		<%if(bolHasOTBreak){%>
		<%
		strTemp = (String)vRetResult.elementAt(i+33);
		strTemp2 = (String)vRetResult.elementAt(i+34);
		if(strTemp != null && strTemp2 != null){
			dTime = Double.parseDouble(strTemp);
			if(dTime >= 12){
				strAMPM = " PM";
				if(dTime > 12)
					dTime = dTime - 12;
			}else{
				strAMPM = " AM";
			}
			
			iHour = (int)dTime;
			dTime = (dTime - iHour) * 60 + .02;
			iMinute = (int)dTime;
			if(iHour == 0)
				iHour = 12;
			
			strTemp = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + strAMPM;
			
			dTime = Double.parseDouble(strTemp2);
			if(dTime >= 12){
				strAMPM = " PM";
				if(dTime > 12)
					dTime = dTime - 12;
			} else {
				strAMPM = " AM";
			}
			
			iHour = (int)dTime;
			dTime = ((dTime - iHour) * 60) + .02;
			iMinute = (int)dTime;
			if(iHour == 0)
				iHour = 12;
			
			strTemp2 = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + strAMPM;
			
			strTemp += " - <br>" + strTemp2;
		} 
		%>								 
		<td class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
		<%}%>
		<td class="thinborder"><%=(String)vRetResult.elementAt(i+3)%></td>
		<%
			strTemp = (String)vRetResult.elementAt(i+29);
			strTemp = WI.getStrValue(strTemp,"&nbsp;");
		%>
		<td class="thinborder"><%=strTemp%></td>
		<%
		strTemp = (String)vRetResult.elementAt(i+13);
		if(strTemp.equals("1")){ 
			strTemp = "APPROVED";
		}else if (strTemp.equals("0")){
			strTemp = "DISAPPROVED";
		}else
			strTemp = "PENDING";
	%>
		<td class="thinborder"><font size="1">&nbsp;<%=strTemp%></font></td>
	</tr>
	<%}%>
</table>		
<table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr > 
		<td height="25">&nbsp;</td>
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