<%@ page language="java" import="utility.*, visitor.VisitLog, java.util.Vector" %>
<%
	WebInterface WI = new WebInterface(request);
%>
<style type="text/css">
a:hover {
	font-weight: bolder;
}
a:link {
	color: #FFFFFF;
}
a:active {
	color: #FFFFFF;
}
a:visited {
	color: #FFFFFF;
}</style>
<%
int iPgIndex = Integer.parseInt(request.getParameter("pgIndex"));
 %>    <table border="0" cellpadding="0" cellspacing="0" bgcolor="#D2AE72" height="30" width="100%">
      <tr>		
<%if(iPgIndex == 0){%>
        <td width="8%" bgcolor="#FF0000" align="center" class="thinborderBOTTOM"><strong><font color="#FFFFFF">HOME</font></strong></td>
<%}else{%>
        <td width="8%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="total_visitors.jsp?pgIndex=0">
			<strong><font color="#000000">HOME</font></strong></a></td>		
<%}if(iPgIndex == 1){%>
        <td width="8%" align="center" bgcolor="#FF0000" class="thinborderBOTTOM"><strong><font color="#FFFFFF">RECORD</font></strong></td>
<%}else{%>
        <td width="8%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="record_going_in_first.jsp?pgIndex=1">
			<strong><font color="#000000">RECORD</font></strong></a></td>
<%}
if(iPgIndex == 2){%>
        <td width="8%" align="center" bgcolor="#FF0000" class="thinborderBOTTOM"><strong><font color="#FFFFFF">SEARCH</font></strong></td>
<%}else{%>
        <td width="8%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="search_visitor_log.jsp?pgIndex=2">
			<strong><font color="#000000">SEARCH</font></strong></a></td>
<%}
if(iPgIndex == 3){%>
        <td width="8%" align="center" bgcolor="#FF0000" class="thinborderBOTTOM"><strong><font color="#FFFFFF">TERMINAL MGMT</font></strong></td>
<%}else{%>
        <td width="8%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="visit_terminal_mgmt.jsp?pgIndex=3">
			<strong><font color="#000000">TERMINAL MGMT</font></strong></a></td>
<%}
if(iPgIndex == 4){%>
        <td width="8%" align="center" bgcolor="#FF0000" class="thinborderBOTTOM"><strong><font color="#FFFFFF">EVENT MGMT</font></strong></td>
<%}else{%>
        <td width="8%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="event_mgmt.jsp?pgIndex=4">
			<strong><font color="#000000">EVENT MGMT</font></strong></a></td>
<%}%>
		<td width="20%" align="right" bgcolor="#FFCC99" class="thinborderBOTTOM"><strong>TODAY'S (<%=WI.getTodaysDate(1)%>) LOG</strong>&nbsp;&nbsp;</td>
	</tr>
</table>
