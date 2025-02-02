<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<style>
TD.thinborder {
    border-left: solid 1px #94CFDA;
    border-bottom: solid 1px #94CFDA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
TABLE.thinborder {
    border-top: solid 1px #94CFDA;
    border-right: solid 1px #94CFDA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

a:link {
	color: #000000;
	text-decoration: none;
}
a:visited {
	color: #000000;
	text-decoration: none;

}
a:hover {
	font-weight: bold;
	color: #000000;
	text-decoration: none;

}
a:active {
	font-weight: bold;
	color: #000000;
	text-decoration: none;

}
</style>
<%@ page language="java" import="utility.*, java.util.Vector " buffer="16kb"%>
<%
	WebInterface WI = new WebInterface(request);
	Vector vCal = null;
	String strTemp = "";
	String strTableBg = "";
	String strFonCol = "";
	boolean bStart = false;
	int iCurMonth = Integer.parseInt(WI.getTodaysDate(1).substring(0,1))-1;
	int iCurYear = Integer.parseInt(WI.getTodaysDate(2).substring(WI.getTodaysDate(2).length()-4));
	MyCalendar myCal = new MyCalendar();
	vCal = myCal.makeCal(WI.fillTextValue("month"), WI.fillTextValue("year"));
	
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
   <tr bgcolor="aliceblue">
   <td align="center" colspan="7" valign="middle" height="30" class="thinborder">
 <!-- <a href="#"><img src="../../images/myImages/fr.gif" border="0"></a>
   <a href="#"><img src="../../images/myImages/prev.gif" border="0"></a>
 -->
    <%	strTemp = WI.fillTextValue("month");
	    	if (strTemp.length()==0)
   		strTemp = Integer.toString(iCurMonth);
    %>
   <select name="month" style="font-size:10px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif" 
   onchange="ReloadPage();">
	<%if (strTemp.compareTo("0")==0){%>
   		<option value="0" selected>January</option>
 	<%} else {%>	
 		<option value="0">January</option>
	<%} if (strTemp.compareTo("1")==0){%>
 		<option value="1" selected>February</option>
 	<%} else {%>	
 		<option value="1">February</option>
	<%} if (strTemp.compareTo("2")==0){%>
  		<option value="2" selected>March</option>
	<%} else {%>	
  		<option value="2">March</option>
	<%} if (strTemp.compareTo("3")==0){%>   	
   		<option value="3" selected>April</option>
	<%} else {%>	
   		<option value="3">April</option>
   	<%} if (strTemp.compareTo("4")==0){%>   	
		<option value="4" selected>May</option>
	<%} else {%>	
		<option value="4">May</option>
	<%} if (strTemp.compareTo("5")==0){%>   	
		<option value="5" selected>June</option>
	<%} else {%>	
		<option value="5">June</option>
	<%} if (strTemp.compareTo("6")==0){%>   	
		<option value="6" selected>July</option>
	<%} else {%>	
		<option value="6">July</option>
	<%} if (strTemp.compareTo("7")==0){%>   	
 		<option value="7" selected>August</option>
	<%} else {%>	
 		<option value="7">August</option>
	<%} if (strTemp.compareTo("8")==0){%>   	
  		<option value="8" selected>September</option>
	<%} else {%>	
  		<option value="8">September</option>
	<%} if (strTemp.compareTo("9")==0){%>   	
   		<option value="9" selected>October</option>
	<%} else {%>	
   		<option value="9">October</option>
	<%} if (strTemp.compareTo("10")==0){%>   	
		<option value="10" selected>November</option>
	<%} else {%>	
		<option value="10">November</option>
	<%} if (strTemp.compareTo("11")==0){%>   	
		<option value="11" selected>December</option>
	<%} else {%>	
		<option value="11">December</option>
	<%}%>
   </select>
   <%	strTemp = WI.fillTextValue("year");
   		if (strTemp.length()==0)
   		strTemp = Integer.toString(iCurYear);
   %>
    <select name="year" style="font-size:10px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif" 
    onchange="ReloadPage();" >
	<%for (int i = iCurYear-2; i <= iCurYear+2; ++i){
		if (strTemp.compareTo(Integer.toString(i))==0){%>
		<option value="<%=i%>" selected><%=i%></option>
		<%} else {%>
		<option value="<%=i%>"><%=i%></option>
	<%}}%>
    </select>
<!--
   <a href="javascript:NextMonth();"><img src="../../images/myImages/next.gif" border="0"></a>
   <a href="#"><img src="../../images/myImages/ff.gif" border="0"></a>
-->
   </td>
   </tr>
   <tr bgcolor="aliceblue">
   <td width="10%" align="center" height="25" class="thinborder"><font size="1" color="red"><strong>S</strong></font></td>
   <td width="15%" align="center" class="thinborder"><font size="1"><strong>M</strong></font></td>
   <td width="15%" align="center" class="thinborder"><font size="1"><strong>T</strong></font></td>
   <td width="15%" align="center" class="thinborder"><font size="1"><strong>W</strong></font></td>
   <td width="15%" align="center" class="thinborder"><font size="1"><strong>TH</strong></font></td>
   <td width="15%" align="center" class="thinborder"><font size="1"><strong>F</strong></font></td>
   <td width="15%" align="center" class="thinborder"><font size="1"><strong>S</strong></font></td>
   </tr>
   <%
   if (vCal != null){
   int iCtr;
   for (int i = 0; i<84;){
   iCtr = 0;%>
   <tr height="25">
   <%
   while (iCtr<=6)
   {
  	 if (iCtr == 0 || iCtr == 6)
   		strTableBg = "bgcolor = gainsboro";
	 else
   		strTableBg ="bgcolor= #FFFFFF";
	
   	if (((String)vCal.elementAt(i+1)).compareTo("1")==0) {
   		if (!bStart)
   			bStart = true;
     	else bStart = false;	
   	}
   	if (bStart)
   		strFonCol = "color = black"; 
	else
   		strFonCol = "color = orange"; 
   	
   if (((String)vCal.elementAt(i)).compareTo(WI.getTodaysDate(1))==0){
   %>
   <td align="center" <%=strTableBg%> class="thinborder" ><a href="./event_day.jsp?dateNow=<%=(String)vCal.elementAt(i)%>" target="organizermainFrame"> <font size="2" color="red"><strong><%=(String)vCal.elementAt(i+1)%></strong></font></a></td>
	<%}else{%>
   <td align="center" <%=strTableBg%> class="thinborder"><a href="./event_day.jsp?dateNow=<%=(String)vCal.elementAt(i)%>" target="organizermainFrame"><font size="1" <%=strFonCol%>><%=(String)vCal.elementAt(i+1)%></font></a></td>
	<%}
   i+=2;
   ++iCtr;
   }%>
   </tr>
   <%}}%>
   <tr>
		<td colspan="7" align="center" bgcolor="aliceblue" height="25">
		<font size="1"><strong><%=WI.getTodaysDate(2)%></strong></font></td>   
   </tr>
</table>
