<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
TABLE.thinborder { 
	border-top: solid 1px #FFA500;
	border-right: solid 1px #FFA500;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size:11px;
}
TD.thinborder {
	border-left: solid 1px #FFA500; 
	border-bottom: solid 1px #FFA500;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size:11px;
}
-->
</style>
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<%@ page language="java" import="utility.*,lms.MgmtCirculation,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp   = null;
//add security here.
	try
	{
		dbOP = new DBOperation();
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
	
	
	MgmtCirculation mgmtBP = new MgmtCirculation();
	Vector vRetResult = null; Vector vWHInfo = new Vector();
	
	int iYear = Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_"),"0"));
	if(iYear > 0) {
		vRetResult = mgmtBP.getHolidayCalendar(dbOP, iYear);
		if(vRetResult == null)
			strErrMsg = mgmtBP.getErrMsg();
		else	
			vWHInfo = (Vector)vRetResult.remove(0);
	}
%>

<body>
<form action="./holiday_calendar.jsp" method="post" name="form_">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#A8A8D5">
      <td height="25" colspan="2" bgcolor="#A8A8D5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
      LIBRARY HOLIDAY LIST ::::</strong></font></div></td> 
    </tr>
    <tr>
      <td width="68%" height="25" valign="top">Change Year :
        <select name="year_" onChange="document.form_.submit();">
          <%=dbOP.loadComboYear(WI.fillTextValue("year_"),5,3)%>
        </select>
      </td> 
      <td width="32%" rowspan="2" valign="top">
<%if(vWHInfo != null) {String[] astrConvertWeek = {"Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"};%>
			<table width="75%" cellpadding="0" cellspacing="0" class="thinborder">
				<tr>
					<td></td>
					<td></td>
				</tr>
			<%int iTemp = 0; boolean bolAM = false;
			for(int i = 0; i < vWHInfo.size(); i += 5){
				iTemp = Integer.parseInt((String)vWHInfo.elementAt(i + 1));
				if(iTemp > 12) {
					iTemp = iTemp - 12;
					bolAM = false;
				}
				else
					bolAM = true;
				if(vWHInfo.elementAt(i + 2).equals("0"))
					strTemp = Integer.toString(iTemp);
				else	
					strTemp = Integer.toString(iTemp)+":"+(String)vWHInfo.elementAt(i + 2);
				if(bolAM)
					strTemp = strTemp + "am - ";
				else	
					strTemp = strTemp + "pm - ";
			
				iTemp = Integer.parseInt((String)vWHInfo.elementAt(i + 3));
				if(iTemp > 12) {
					iTemp = iTemp - 12;
					bolAM = false;
				}
				else
					bolAM = true;
				if(vWHInfo.elementAt(i + 4).equals("0"))
					strTemp += Integer.toString(iTemp);
				else	
					strTemp += Integer.toString(iTemp)+":"+(String)vWHInfo.elementAt(i + 4);
				if(bolAM)
					strTemp = strTemp + "am";
				else	
					strTemp = strTemp + "pm";
			%>
				<tr>
					<td class="thinborder"><%=astrConvertWeek[Integer.parseInt((String)vWHInfo.elementAt(i))]%></td>
					<td class="thinborder"><%=strTemp%></td>
				</tr>
			<%}%>
			</table>	  
<%}//if(vWHInfo != null) {%>	  
	  
	  </td>
    </tr>
    <tr>
      <td height="25" align="center" valign="top"><font size="4">Today Date : <%=WI.getTodaysDate(2)%></font></td>
    </tr>
  </table>
<%if(strErrMsg != null){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25" colspan="4"><a href="fines.htm"></a> 
        &nbsp;&nbsp;<font size="3" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg,"Message : ","","")%></strong></font> 
      </td>
    </tr>
 </table> 
<%}
String strWDHeader ="<tr bgcolor=#FFFFCC><td class=thinborder width=30>SUN</td>"+
						"<td class=thinborder width=30>MON</td>"+
						"<td class=thinborder width=30>TUE</td>"+
						"<td class=thinborder width=30>WED</td>"+
						"<td class=thinborder width=30>THU</td>"+
						"<td class=thinborder width=30>FRI</td>"+
						"<td class=thinborder width=30>SAT</td></tr>";
if(vRetResult != null && vRetResult.size() > 0) {
int iDayOfWeek = ((Integer)vRetResult.remove(0)).intValue();
int iNoOfDays  = 0;//max number of days in a month.
boolean bolIsHoliday   = false; boolean bolIsToday = false; 
boolean bolIsSpecialCase = false;//special case appears when a date is holiday and start of month but it is not starting on sunday.
String strDate = null; 
java.util.Calendar cal = java.util.Calendar.getInstance();
String strToday = Integer.toString(cal.get(java.util.Calendar.MONTH ) + 1)+"/"+
				  Integer.toString(cal.get(java.util.Calendar.DAY_OF_MONTH))+"/"+
				  Integer.toString(cal.get(java.util.Calendar.YEAR));

String[] astrConvertMonth = {"January "+iYear,"February "+iYear,"March "+iYear,"April "+iYear,
							"May "+iYear,"June "+iYear,"July "+iYear,"August "+iYear,
							"September "+iYear,"October "+iYear,"November "+iYear,"December "+iYear};
%>	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
<%for(int i =0; i < 12;++i){
iNoOfDays = ((Integer)vRetResult.remove(0)).intValue();%>
    <tr> 
      <td width="32%" valign="top">&nbsp;<table class="thinborder" cellpadding="0" cellspacing="0" height="145">
	  <%for(int p =1; p <= iNoOfDays;){
	  	if(p == 1){%>
			<%="<tr><td class=thinborder colspan=7 align=center><b>"+astrConvertMonth[i]+"</b></td></tr>" + strWDHeader%>
		
		<%}//end of printing header%>
	  <tr>
	  	<%for(int q = 0; q < 7; ++q,++p){///actual printing.
			strDate = Integer.toString(i + 1)+"/"+Integer.toString(p)+"/"+Integer.toString(iYear);
			if(iDayOfWeek == q && vRetResult.size() > 0 && vRetResult.elementAt(0).equals(strDate)) {
				bolIsHoliday = true;
				bolIsSpecialCase = true;//by default all holidays are special case.. reset it if date is going to be printed.. 
				vRetResult.remove(0);
			}
			else 
				bolIsHoliday = false;
				
			if(strDate.equals(strToday))
				bolIsToday = true;
			else	
				bolIsToday = false;
			
			strTemp = "";
			if(iDayOfWeek == q && p <=iNoOfDays) {
				if(bolIsSpecialCase) {
					strTemp = "bgcolor=#cccccc";
				}
				bolIsSpecialCase = false;//reset here because holiday is going to be printed right away.. 
			}
			
			if(bolIsHoliday && !bolIsSpecialCase)
				strTemp = "bgcolor=#cccccc";
			else if(strTemp.length() == 0 && (iDayOfWeek != q || p >iNoOfDays) )
				strTemp = "bgcolor=#EEEEEE";
			%> 
	  		<td class="thinborder" <%=strTemp%>>
			<%if(iDayOfWeek == q && p <=iNoOfDays){%>
				<%if(bolIsToday){%><font style="font-size:18px; font-weight:bold; color:#FF0000"><%}%><%=p%><%if(bolIsToday){%></font><%}%><!--actual printing of date here -->
			<%++iDayOfWeek; if(iDayOfWeek == 7) iDayOfWeek = 0;}else{--p;%>&nbsp;<%}%></td>	  
	  <%}//inner for loop%></tr>
	  <%}%>
	  	</table>
	  </td>
<!--------- must copy the code above this td incase there will be any change -->
      <td width="2%">&nbsp;</td>
      <td width="32%" valign="top">&nbsp;<table class="thinborder" cellpadding="0" cellspacing="0" height="150">
	  <%++i;iNoOfDays = ((Integer)vRetResult.remove(0)).intValue();
	  for(int p =1; p <= iNoOfDays;){
	  	if(p == 1){%>
			<%="<tr><td class=thinborder colspan=7 align=center><b>"+astrConvertMonth[i]+"</b></td></tr>" + strWDHeader%>
		
		<%}//end of printing header%>
	  <tr>
	  	<%for(int q = 0; q < 7; ++q,++p){///actual printing.
			strDate = Integer.toString(i + 1)+"/"+Integer.toString(p)+"/"+Integer.toString(iYear);
			
			if(vRetResult.size() > 0 && vRetResult.elementAt(0).equals(strDate)) {
				bolIsHoliday = true;
				bolIsSpecialCase = true;//by default all holidays are special case.. reset it if date is going to be printed.. 
				vRetResult.remove(0);
			}
			else 
				bolIsHoliday = false;
			if(strDate.equals(strToday))
				bolIsToday = true;
			else	
				bolIsToday = false;

			strTemp = "";
			if(iDayOfWeek == q && p <=iNoOfDays) {
				if(bolIsSpecialCase) {
					strTemp = "bgcolor=#cccccc";
				}
				bolIsSpecialCase = false;//reset here because holiday is going to be printed right away.. 
			}
			
			if(bolIsHoliday && !bolIsSpecialCase)
				strTemp = "bgcolor=#cccccc";
			else if(strTemp.length() == 0 && (iDayOfWeek != q || p >iNoOfDays) )
				strTemp = "bgcolor=#EEEEEE";
			%> 
	  		<td class="thinborder" <%=strTemp%>>
			<%if(iDayOfWeek == q && p <=iNoOfDays){%>
				<%if(bolIsToday){%><font style="font-size:18px; font-weight:bold; color:#FF0000"><%}%><%=p%><%if(bolIsToday){%></font><%}%><!--actual printing of date here -->
			<%++iDayOfWeek; if(iDayOfWeek == 7) iDayOfWeek = 0;}else{--p;%>&nbsp;<%}%></td>	  
	  <%}//inner for loop%></tr>
	  <%}%>
	  	</table></td>
      <td width="2%">&nbsp;</td>
      <td width="32%" valign="top">&nbsp;<table class="thinborder" cellpadding="0" cellspacing="0" height="150">
	  <%++i;iNoOfDays = ((Integer)vRetResult.remove(0)).intValue();
	  for(int p =1; p <= iNoOfDays;){
	  	if(p == 1){%>
			<%="<tr><td class=thinborder colspan=7 align=center><b>"+astrConvertMonth[i]+"</b></td></tr>" + strWDHeader%>
		
		<%}//end of printing header%>
	  <tr>
	  	<%for(int q = 0; q < 7; ++q,++p){///actual printing.
			strDate = Integer.toString(i + 1)+"/"+Integer.toString(p)+"/"+Integer.toString(iYear);
			
			if(vRetResult.size() > 0 && vRetResult.elementAt(0).equals(strDate)) {
				bolIsHoliday = true;
				bolIsSpecialCase = true;//by default all holidays are special case.. reset it if date is going to be printed.. 
				vRetResult.remove(0);
			}
			else 
				bolIsHoliday = false;
			if(strDate.equals(strToday))
				bolIsToday = true;
			else	
				bolIsToday = false;

			strTemp = "";
			if(iDayOfWeek == q && p <=iNoOfDays) {
				if(bolIsSpecialCase)
					strTemp = "bgcolor=#cccccc";
				bolIsSpecialCase = false;//reset here because holiday is going to be printed right away.. 
			}
			
			if(bolIsHoliday && !bolIsSpecialCase)
				strTemp = "bgcolor=#cccccc";
			else if(strTemp.length() == 0 && (iDayOfWeek != q || p >iNoOfDays) )
				strTemp = "bgcolor=#EEEEEE";
			%> 
	  		<td class="thinborder" <%=strTemp%>>
			<%if(iDayOfWeek == q && p <=iNoOfDays){%>
				<%if(bolIsToday){%><font style="font-size:18px; font-weight:bold; color:#FF0000"><%}%><%=p%><%if(bolIsToday){%></font><%}%><!--actual printing of date here -->
			<%++iDayOfWeek; if(iDayOfWeek == 7) iDayOfWeek = 0;}else{--p;%>&nbsp;<%}%></td>	  
	  <%}//inner for loop%></tr>
	  <%}%>
	  	</table></td>
    </tr>
<%}//end of outer loop for loop%>
 </table>
<%}//end of calendar.. vRetResult > 0for(int i =0; i < 12;++i){%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>