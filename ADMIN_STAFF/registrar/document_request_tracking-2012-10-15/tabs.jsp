<%@ page language="java" import="utility.*, java.util.Vector" %>
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
        <td width="16%" bgcolor="#FF0000" align="center" class="thinborderBOTTOM"><strong><font color="#FFFFFF">HOME</font></strong></td>
<%}else{%>
        <td width="16%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="request_due_made.jsp?pgIndex=0">
			<strong><font color="#000000">HOME</font></strong></a></td>		
<%}if(iPgIndex == 1){%>
        <td width="16%" align="center" bgcolor="#FF0000" class="thinborderBOTTOM"><strong><font color="#FFFFFF">RECORD</font></strong></td>
<%}else{%>
        <td width="16%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="record_document_request.jsp?pgIndex=1">
			<strong><font color="#000000">RECORD</font></strong></a></td>
<%}
if(iPgIndex == 2){%>
        <td width="16%" align="center" bgcolor="#FF0000" class="thinborderBOTTOM"><strong><font color="#FFFFFF">RELEASE</font></strong></td>
<%}else{%>
        <td width="16%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="release_document.jsp?pgIndex=2">
			<strong><font color="#000000">RELEASE</font></strong></a></td>
<%}
if(iPgIndex == 3){%>
        <td width="16%" align="center" bgcolor="#FF0000" class="thinborderBOTTOM"><strong><font color="#FFFFFF">SEARCH</font></strong></td>
<%}else{%>
        <td width="16%" bgcolor="#FFCC99" align="center" class="thinborderBOTTOM"><a href="search_request.jsp?pgIndex=3">
			<strong><font color="#000000">SEARCH</font></strong></a></td>
<%}%>
		<td width="36%" align="right" bgcolor="#FFCC99" class="thinborderBOTTOM"><strong>TODAY'S (<%=new WebInterface().getTodaysDate(1)%>) LOG</strong>&nbsp;&nbsp;</td>
	</tr>
</table>
