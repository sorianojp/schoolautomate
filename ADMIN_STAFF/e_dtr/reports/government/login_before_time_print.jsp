<%@page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTRExtn, eDTR.eDTRUtil, 
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

    TD.thinborderBottom {
    border-bottom: solid 1px #000000;
		font-family: Arial, Verdana, Geneva,  Helvetica, sans-serif;
		font-size: 12px;  
    }
</style>
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	Calendar calTemp = Calendar.getInstance();
	String strTemp2 = null;
	int iSearchResult =0;
	int iIndex = 0;
	int iCount = 0;
	String strMonths = WI.fillTextValue("month_of");
 	String strYear = WI.fillTextValue("year_of");
	if(strMonths.length() == 0)
		strMonths = Integer.toString(calTemp.get(Calendar.MONTH) + 1);
	if(strYear.length() == 0)
		strYear = Integer.toString(calTemp.get(Calendar.YEAR));

	//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-View/Print DTR","login_before_time_print.jsp");
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
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"login_before_time_print.jsp");
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
ReportEDTRExtn RE = new ReportEDTRExtn(request);
if(strErrMsg == null) 
	strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","0","5"};
String strShowOpt = WI.getStrValue(WI.fillTextValue("DateDefaultSpecify"), "1");
String[] astrMonth={" &nbsp;", "January", "February", "March", "April", "May", "June",
					 "July","August", "September","October", "November", "December"};
	int j = 0;
	int iTimes = 0;
	int i = 0;
 
	Vector vDates = null;
	boolean bolPageBreak = false;
	vRetResult = RE.searchEarlyLoginSummary(dbOP);

	if (vRetResult != null) {
	int iPage = 1; 
	int iMaxRecPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("num_rec_page"),"20"));

	int iNumRec = 0;//System.out.println(vRetResult);
	int iIncr    = 1;
	int iTotalPages = (vRetResult.size())/(20*iMaxRecPerPage);	
	if((vRetResult.size() % (20*iMaxRecPerPage)) > 0) ++iTotalPages;
	 for (;iNumRec < vRetResult.size();iPage++){
%>
<body onLoad="javascript:window.print();">
<form name="dtr_op">
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <%
		strTemp2 = WI.getStrValue(WI.fillTextValue("am_pm"), "1");
		if(strTemp2.equals("1"))
			strTemp2 = " PM";
		else
			strTemp2 = " AM";

		strTemp = "";		
		if(bolIsSchool)
			strTemp += "FACULTY MEMBERS/STAFF ";
		else
			strTemp += " EMPLOYEES ";
		strTemp += " WHO SWIPED IN BEFORE " + WI.fillTextValue("hour") + " : " + WI.fillTextValue("minute") + strTemp2;
	%>
	<tr>
    <td colspan="2" align="center"><strong><%=strTemp%></strong></td>
  </tr>
	<%
		if(strShowOpt.equals("2"))
			strTemp = "For the Month of " + astrMonth[Integer.parseInt(WI.fillTextValue("month_of"))] + ", " + WI.fillTextValue("year_of") ;
		else
			strTemp = "For the Period " + WI.fillTextValue("from_date") + " to " + WI.fillTextValue("to_date");
	%>
  <tr>
    <td colspan="2" align="center" style="font-size:11px;"><%=strTemp%></td>
  </tr>
  <tr>
    <td colspan="2">&nbsp;</td>
  </tr>
  <tr>
    <td width="85%">AGENCY : <em><strong><%=SchoolInformation.getSchoolName(dbOP, true, false)%></strong></em></td>
    <td width="15%" align="right">Page <%=iPage%> of <%=iTotalPages%></td>
  </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">		
    <tr >
      <td height="25" colspan="2" align="center" class="thinborder"><strong>NAME</strong></td>
      <td align="center" class="thinborder">Date When Swipe-In Was Incurred </td>			
			<td width="11%" align="center" class="thinborder">Total No. of Times</td>
    </tr>    
	<%
	for(iCount = 1; iNumRec<vRetResult.size(); iNumRec+=20,++iIncr, ++iCount){
	
		i = iNumRec;
		vDates = (Vector) vRetResult.elementAt(i+10);
		
		if (iCount > iMaxRecPerPage){
			bolPageBreak = true;
			break;
		}
		else 
			bolPageBreak = false;				
	%>
    <tr>
      <td width="4%" height="21" align="right" class="thinborder"><%=iIncr%>&nbsp;</td>
			<td width="20%" nowrap class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+1), "", 
												 (String)vRetResult.elementAt(i+2),4).toUpperCase()%></td>
			<%
				//strTemp = CommonUtil.convertVectorToCSV(vDates);
				strTemp = "";
				iTimes = 0;
				if(vDates != null && vDates.size() > 0){
					iTimes = vDates.size();
					for(j = 0; j < iTimes; j++){
						if(strTemp.length() == 0)
							strTemp = (String)vDates.elementAt(j);
						else
							strTemp += ", " +(String)vDates.elementAt(j);
					}
				}
			%>
      <td height="21" class="thinborder" width="65%">&nbsp;<%=strTemp%></td>			

			<td align="center" class="thinborder"><%=iTimes%></td>
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